#include <cstddef>
#include <iostream>
#include <napi.h>
#include <sstream>
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
NSString *_getNSStringAt(const CallbackInfo& info, size_t index) {
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

Buffer _copyNSDataToBuffer(const Env& env, NSData *data) {
  uint8_t *pData = (uint8_t *)data.bytes;
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

Napi::Value setData(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string", "Buffer"});
    Env env = info.Env();

    // arg1: format
    NSString *format = _getNSStringAt(info, 0);

    // arg2: buf
    Buffer b = info[1].As<Buffer>();
    uint8_t *buf = b.Data();
    size_t length = b.Length();

    // no copy
    // this will cause electron app to freeze, don't know why
    // NSData *data = [NSData dataWithBytesNoCopy:buf
    //                                     length:(NSUInteger)length
    //                               freeWhenDone:NO];

    // copy
    NSData *data = [NSData dataWithBytes:buf length:(NSUInteger)length];
#ifdef DEBUG
    NSLog(@"setData: format=%@, buf.length=%zu", format, length);
#endif

    // format
    [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];

    // setData
    bool success = [NSPasteboard.generalPasteboard setData:data forType:format];
#ifdef DEBUG
    NSLog(@"writeToClipboard: result = %i", success);
#endif

    return Napi::Boolean::New(env, success);
  }
}

Napi::Value setDataAll(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string", "Array<Buffer>"});
    Env env = info.Env();

    // arg1: format
    NSString *format = _getNSStringAt(info, 0);

    // arg2: buffers
    Napi::Array arr = info[1].As<Napi::Array>();
    NSMutableArray<NSPasteboardItem *> *items = [NSMutableArray arrayWithCapacity:arr.Length()];
    for (uint32_t i = 0; i < arr.Length(); i++) {
      Napi::Value val = arr.Get(i);
      Buffer buf = val.As<Buffer>();
      uint8_t *bufData = buf.Data();
      size_t length = buf.Length();
      NSData *data = [NSData dataWithBytes:bufData length:(NSUInteger)length];

      NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
      [item setData:data forType:format];
      [items addObject:item];
    }
#ifdef DEBUG
    NSLog(@"setDataAll: format=%@, items.length=%lu", format, (unsigned long)items.count);
#endif

    [NSPasteboard.generalPasteboard clearContents];
    bool success = [NSPasteboard.generalPasteboard writeObjects:items];
#ifdef DEBUG
    NSLog(@"writeToClipboard: result = %i", success);
#endif

    return Napi::Boolean::New(env, success);
  }
}

Value dataForType(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    Env env = info.Env();

    NSString *dataType = _getNSStringAt(info, 0);
    NSData *data = [NSPasteboard.generalPasteboard dataForType:dataType];
    auto buf = _copyNSDataToBuffer(env, data);
    return buf;
  }
}

Value allDataForType(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    Env env = info.Env();

    NSString *dataType = _getNSStringAt(info, 0);

    std::vector<Buffer> buffers;
    NSArray<NSPasteboardItem *> *items = [NSPasteboard.generalPasteboard pasteboardItems];
    for (NSPasteboardItem *item in items) {
      // Get data for the specified type
      NSData *data = [item dataForType:dataType];
      if (data) {
        auto buf = _copyNSDataToBuffer(env, data);
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
#endif

Object Init(Env env, Object exports) {
  Napi::HandleScope scope(env);
#ifdef __APPLE__
  // clear
  exports.Set(String::New(env, "clearContents"), Function::New(env, clearContents));

  // read
  exports.Set(String::New(env, "dataForType"), Function::New(env, dataForType));
  exports.Set(String::New(env, "allDataForType"), Function::New(env, allDataForType)); // array

  // write
  exports.Set(String::New(env, "setData"), Function::New(env, setData));
  exports.Set(String::New(env, "setDataAll"), Function::New(env, setDataAll)); // array
#endif
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
