#include <cstddef>
#include <fmt/format.h>
#include <napi.h>
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

using Napi::CallbackInfo;
using Napi::Function;
using Buffer = Napi::Buffer<uint8_t>;

#ifdef __APPLE__
// helpers
void _validateArgs(const CallbackInfo& info, std::vector<std::string> expected) {
  Napi::Env env = info.Env();

  if (info.Length() != expected.size()) {
    throw Napi::Error::New(
      env,
      fmt::format("arguments count mismatch, expect {} arguments, got {}", info.Length(), expected.size())
    );
  }

  // check type: only string or Buffer supported
  for (size_t i = 0; i < expected.size(); i++) {
    std::string expectedType = expected[i];
    std::erase(expectedType, ' '); // remove space
    Napi::Value val = info[i];

    if (expectedType == "string" && !val.IsString()) {
      throw Napi::TypeError::New(env, fmt::format("arguments type mismatch, arguments[{}] must be string", i));
    }

    if (expectedType == "Buffer" && !val.IsBuffer()) {
      throw Napi::TypeError::New(env, fmt::format("arguments type mismatch, arguments[{}] must be Buffer", i));
    }

    if ((expectedType == "string|Buffer" || expectedType == "Buffer|string") && !val.IsBuffer() && !val.IsString()) {
      throw Napi::TypeError::New(env, fmt::format("arguments type mismatch, arguments[{}] must be string | Buffer", i));
    }

    if (expectedType == "Array<Buffer>" || expectedType == "Buffer[]") {
      std::string msg = fmt::format("arguments type mismatch, arguments[{}] must be Array<Buffer>", i);
      if (!val.IsArray()) {
        throw Napi::TypeError::New(env, msg);
      }
      Napi::Array arr = val.As<Napi::Array>();
      for (uint32_t i = 0; i < arr.Length(); i++) {
        Napi::Value val = arr[i];
        if (!val.IsBuffer()) {
          throw Napi::TypeError::New(env, msg);
        }
      }
    }
  }
}

NSString* _createNsString(const Napi::Value& val) {
  std::string s = val.ToString().Utf8Value();
  return [NSString stringWithUTF8String:s.c_str()];
}
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
Buffer _createNapiBufferFromNsData(const Napi::Env& env, NSData* data) {
  uint8_t* pData = (uint8_t*)data.bytes;
  uint32_t len = (uint32_t)data.length;
  Buffer buf = Buffer::Copy(env, pData, len);
  return buf;
}

Napi::Value clearContents(const CallbackInfo& info) {
  @autoreleasepool {
    [NSPasteboard.generalPasteboard clearContents];
    return info.Env().Undefined();
  }
}

// read
Napi::Value readBuffer(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    NSString* format = _createNsString(info[0]);
    NSData* data = [NSPasteboard.generalPasteboard dataForType:format];
    return _createNapiBufferFromNsData(info.Env(), data);
  }
}
Napi::Value readBuffers(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string"});
    NSString* dataType = _createNsString(info[0]);

    std::vector<Buffer> buffers;
    NSArray<NSPasteboardItem*>* items = [NSPasteboard.generalPasteboard pasteboardItems];
    for (NSPasteboardItem* item in items) {
      // Get data for the specified type
      NSData* data = [item dataForType:dataType];
      if (data) {
        Buffer buf = _createNapiBufferFromNsData(info.Env(), data);
        buffers.push_back(buf);
      }
    }

    // to js array
    Napi::Array result = Napi::Array::New(info.Env(), buffers.size());
    for (size_t i = 0; i < buffers.size(); ++i) {
      result.Set(i, buffers[i]);
    }

    return result;
  }
}

// write
Napi::Value writeVariadicPasteboardItems(const CallbackInfo& info) {
  @autoreleasepool {
    size_t itemsLength = info.Length();
    if (itemsLength == 0) {
      return Napi::Boolean::New(info.Env(), false);
    }

    // validate args
    for (size_t i = 0; i < itemsLength; i++) {
      Napi::Value val = info[i];
      if (!val.IsObject()) {
        throw Napi::TypeError::New(info.Env(), fmt::format("arguments type mismatch, arguments[{}] must be an Object", i));
      }
    }

    NSMutableArray<NSPasteboardItem*>* items = [NSMutableArray arrayWithCapacity:itemsLength];

    for (size_t i = 0; i < itemsLength; i++) {
      Napi::Object obj = info[i].As<Napi::Object>();
      NSPasteboardItem* item = [[NSPasteboardItem alloc] init];

      for (const auto& e : obj) {
        NSString* format = [NSString stringWithUTF8String:e.first.ToString().Utf8Value().c_str()];
        NSData* data = _createNsDataFromNapiValue(e.second.AsValue());
        if (!data) {
          throw Napi::TypeError::New(
            info.Env(),
            fmt::format("arguments type mismatch, arguments[{}].{} must be Buffer | string", i, e.first.ToString().Utf8Value())
          );
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
    return Napi::Boolean::New(info.Env(), success);
  }
}

// [NSPasteboard declareTypes:owner:] 是极早期版本的 macOS API
// 它对字符串的格式校验非常宽松，允许通过传统的非 UTI 字符串来建立剪贴板通道。
Napi::Value declareTypeAndSetData(const CallbackInfo& info) {
  @autoreleasepool {
    _validateArgs(info, {"string", "Buffer|string"});
    NSString* format = _createNsString(info[0]);
    NSData* data = _createNsDataFromNapiValue(info[1]);
    [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];
    bool success = [NSPasteboard.generalPasteboard setData:data forType:format];
    return Napi::Boolean::From(info.Env(), success);
  }
}
#endif

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  Napi::HandleScope scope(env);
#ifdef __APPLE__
  // clear
  exports.Set("clearContents", Function::New(env, clearContents));

  // read
  exports.Set("readBuffer", Function::New(env, readBuffer));
  exports.Set("readBuffers", Function::New(env, readBuffers)); // array

  // write
  exports.Set("writeVariadicPasteboardItems", Function::New(env, writeVariadicPasteboardItems)); // [item1, item2]
  exports.Set("declareTypeAndSetData", Function::New(env, declareTypeAndSetData));
#endif
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
