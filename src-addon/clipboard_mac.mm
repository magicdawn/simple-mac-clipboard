#include <cstddef>
#include <format>
#include <iostream>
#include <napi.h>
#include <sstream>
#include <stddef.h>
#include <stdint.h>
#include <string>
#include <vector>

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#endif

using namespace std;
using Napi::CallbackInfo;
using Napi::Env;
using Napi::Function;
using Napi::Object;
using Napi::String;
using Napi::Value;

using Buffer = Napi::Buffer<uint8_t>;

#ifdef __APPLE__
NSString* _getNSStringAt(const CallbackInfo& info, size_t index) {
  std::string s = info[index].ToString().Utf8Value();
  return [NSString stringWithUTF8String:s.c_str()];
}

void _validateArgs(const CallbackInfo& info, std::vector<std::string> expected) {
  if (info.Length() != expected.size()) {
    // std::format("expect {} arguments, actual passed {}", info.Length(), expected.size())
    std::stringstream ss;
    ss << "arguments count mismatch, expect " << expected.size() << " arguments, got " << info.Length();
    throw Napi::Error::New(info.Env(), ss.str());
  }

  // check type: only string or Buffer supported
  for (size_t i = 0; i < expected.size(); i++) {
    if (expected[i] == "string" && !info[i].IsString()) {
      std::stringstream ss;
      ss << "arguments type mismatch, arguments[" << i << "] must be string";
      throw Napi::Error::New(info.Env(), ss.str());
    }

    if (expected[i] == "Buffer" && !info[i].IsBuffer()) {
      std::stringstream ss;
      ss << "arguments type mismatch, arguments[" << i << "] must be Buffer";
      throw Napi::Error::New(info.Env(), ss.str());
    }

    if (expected[i] == "Array<Buffer>" || expected[i] == "Buffer[]") {
      std::stringstream ss;
      ss << "arguments type mismatch, arguments[" << i << "] must be Array<Buffer>";
      if (!info[i].IsArray()) {
        throw Napi::Error::New(info.Env(), ss.str());
      }
      Napi::Array arr = info[1].As<Napi::Array>();
      for (uint32_t i = 0; i < arr.Length(); i++) {
        Napi::Value val = arr[i];
        if (!val.IsBuffer()) {
          throw Napi::Error::New(info.Env(), ss.str());
        }
      }
    }
  }
}

// helpers
NSData* _createNsDataFromNapiValue(const Napi::Value& val) {
  NSData* data = nil;
  if (val.IsBuffer()) {
    Buffer buf = val.As<Buffer>();
    uint8_t* bufData = buf.Data();
    size_t length = buf.Length();
    data = [NSData dataWithBytes:bufData length:(NSUInteger)length];
  } else if (val.IsString()) {
    NSString* str = [NSString stringWithUTF8String:val.ToString().Utf8Value().c_str()];
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
  }
  return data;
}
Buffer _createNapiBufferFromNsData(const Env& env, NSData* data) {
  uint8_t* pData = (uint8_t*)data.bytes;
  uint32_t len = (uint32_t)data.length;
  Buffer buf = Buffer::Copy(env, pData, len);
  return buf;
}

Napi::Value clearContents(const CallbackInfo& info) {
#ifdef DEBUG
  NSLog(@"clearContents ...");
#endif
  // clear
  [NSPasteboard.generalPasteboard clearContents];
  return info.Env().Undefined();
}

// read
Value readBuffer(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    Env env = info.Env();
    NSString* dataType = _getNSStringAt(info, 0);
    NSData* data = [NSPasteboard.generalPasteboard dataForType:dataType];
    auto buf = _createNapiBufferFromNsData(env, data);
    return buf;
  }
}
Value readBuffers(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    Env env = info.Env();
    NSString* dataType = _getNSStringAt(info, 0);

    std::vector<Buffer> buffers;
    NSArray<NSPasteboardItem*>* items = [NSPasteboard.generalPasteboard pasteboardItems];
    for (NSPasteboardItem* item in items) {
      // Get data for the specified type
      NSData* data = [item dataForType:dataType];
      if (data) {
        auto buf = _createNapiBufferFromNsData(env, data);
        buffers.push_back(buf);
      }
    }

    // Convert vector of buffers to JavaScript array
    auto result = Napi::Array::New(env, buffers.size());
    for (size_t i = 0; i < buffers.size(); ++i) {
      result.Set(i, buffers[i]);
    }

    return result;
  }
}

// write
Napi::Value writeBuffer(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string", "Buffer"});
    Env env = info.Env();
    NSString* format = _getNSStringAt(info, 0);
    NSData* data = _createNsDataFromNapiValue(info[1]);
#ifdef DEBUG
    NSLog(@"writeBuffer: format=%@, buf.length=%zu", format, length);
#endif

    // format
    [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];

    // writeBuffer
    bool success = [NSPasteboard.generalPasteboard setData:data forType:format];
#ifdef DEBUG
    NSLog(@"NSPasteboard.generalPasteboard.setData: result = %i", success);
#endif

    return Napi::Boolean::New(env, success);
  }
}
Napi::Value writeBuffers(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string", "Array<Buffer>"});
    Env env = info.Env();

    // arg1: format
    NSString* format = _getNSStringAt(info, 0);

    // arg2: buffers
    Napi::Array arr = info[1].As<Napi::Array>();
    NSMutableArray<NSPasteboardItem*>* items = [NSMutableArray arrayWithCapacity:arr.Length()];
    for (uint32_t i = 0; i < arr.Length(); i++) {
      Napi::Value val = arr.Get(i);
      Buffer buf = val.As<Buffer>();
      uint8_t* bufData = buf.Data();
      size_t length = buf.Length();
      NSData* data = [NSData dataWithBytes:bufData length:(NSUInteger)length];

      NSPasteboardItem* item = [[NSPasteboardItem alloc] init];
      [item setData:data forType:format];
      [items addObject:item];
    }

    [NSPasteboard.generalPasteboard clearContents];
    bool success = [NSPasteboard.generalPasteboard writeObjects:items];
#ifdef DEBUG
    NSLog(@"NSPasteboard.generalPasteboard.setData: result = %i", success);
#endif

    return Napi::Boolean::New(env, success);
  }
}
Napi::Value writePasteboardItems(const CallbackInfo& info) {
  @autoreleasepool {
    size_t itemsLength = info.Length();

    // validate args
    for (size_t i = 0; i < itemsLength; i++) {
      Napi::Value val = info[i];
      if (!val.IsObject()) {
        // throw Napi::Error::New(info.Env(), std::format("arguments type mismatch, arguments[{}] must be an Object",
        // i));
        //
        // throw Napi::Error::New(
        //     info.Env(),
        //     [[NSString stringWithFormat:@"arguments type mismatch, arguments[%zu] must be an Object", i]
        //     UTF8String]);
        //
        std::stringstream ss;
        ss << "arguments type mismatch, arguments[" << i << "] must be an Object";
        throw Napi::Error::New(info.Env(), ss.str());
      }
    }

    Env env = info.Env();
    NSMutableArray<NSPasteboardItem*>* items = [NSMutableArray arrayWithCapacity:itemsLength];

    for (size_t i = 0; i < itemsLength; i++) {
      Napi::Object obj = info[i].As<Napi::Object>();
      NSPasteboardItem* item = [[NSPasteboardItem alloc] init];

      for (const auto& e : obj) {
        auto format = [NSString stringWithUTF8String:e.first.ToString().Utf8Value().c_str()];

        auto val = e.second.AsValue();
        NSData* data;
        if (val.IsBuffer()) {
          Buffer buf = val.As<Buffer>();
          uint8_t* bufData = buf.Data();
          size_t length = buf.Length();
          data = [NSData dataWithBytes:bufData length:(NSUInteger)length];
        } else if (val.IsString()) {
          NSString* str = [NSString stringWithUTF8String:val.ToString().Utf8Value().c_str()];
          data = [str dataUsingEncoding:NSUTF8StringEncoding];
        } else {
          std::stringstream ss;
          ss << "arguments type mismatch, arguments[" << i << "]." << e.first.ToString().Utf8Value()
             << " must be Buffer | string";
          throw Napi::Error::New(info.Env(), ss.str());
        }

#if DEBUG
        NSLog(@"NSPasteboardItem[%zu].setData: format=%@, data.length=%zu", i, format, data.length);
#endif
        [item setData:data forType:format];
      }

      [items addObject:item];
    }

    [NSPasteboard.generalPasteboard clearContents];
    bool success = [NSPasteboard.generalPasteboard writeObjects:items];
#ifdef DEBUG
    NSLog(@"NSPasteboard.generalPasteboard.writeObjects(%zu): result = %i", items.count, success);
#endif
    return Napi::Boolean::New(env, success);
  }
}
#endif

Object Init(Env env, Object exports) {
  Napi::HandleScope scope(env);
#ifdef __APPLE__
  // clear
  exports.Set(String::New(env, "clearContents"), Function::New(env, clearContents));

  // read
  exports.Set(String::New(env, "readBuffer"), Function::New(env, readBuffer));
  exports.Set(String::New(env, "readBuffers"), Function::New(env, readBuffers)); // array

  // write
  exports.Set(String::New(env, "writeBuffer"), Function::New(env, writeBuffer));
  exports.Set(String::New(env, "writeBuffers"), Function::New(env, writeBuffers));                 // format, buffer[]
  exports.Set(String::New(env, "writePasteboardItems"), Function::New(env, writePasteboardItems)); // [item1, item2]
#endif
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
