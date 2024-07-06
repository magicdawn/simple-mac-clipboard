#include <iostream>
#include <napi.h>

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#endif

using namespace std;
using namespace Napi;

#ifdef __APPLE__
NSString *getStringArg(const CallbackInfo &info, int index) {
  Napi::String s = info[index].ToString();
  std::string valInStdString(s);
  NSString *val = [NSString stringWithUTF8String:valInStdString.c_str()];
  return val;
}

Value clearContents(const CallbackInfo &info) {
#ifdef DEBUG
  NSLog(@"clearContents ...");
#endif

  // clear
  [NSPasteboard.generalPasteboard clearContents];

  return info.Env().Undefined();
}

Value setData(const CallbackInfo &info) {
  Env env = info.Env();

  if (info.Length() < 2) {
    Napi::Error::New(env, "wrong number of arguments").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  if (!info[0].IsString() || !info[1].IsObject()) {
    Napi::Error::New(env, "arguments type does not match (format: string, buf: Buffer)").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // arg1: format
  NSString *format = getStringArg(info, 0);

  // arg2: buf
  // char *buf = node::Buffer::Data(info[1]);
  // size_t length = node::Buffer::Length(info[1]);
  Buffer<uint8_t> b = info[1].As<Buffer<uint8_t>>();
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
  BOOL success = [NSPasteboard.generalPasteboard setData:data forType:format];
#ifdef DEBUG
  NSLog(@"writeToClipboard: result = %i", success);
#endif

  [pool drain];
  return Napi::Boolean::New(env, success);
}

Value dataForType(const CallbackInfo &info) {
  Env env = info.Env();

  if (info.Length() < 1) {
    Napi::Error::New(env, "wrong number of arguments").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  if (!info[0].IsString()) {
    Napi::Error::New(env, "string expected").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *dataType = getStringArg(info, 0);
  NSData *data = [NSPasteboard.generalPasteboard dataForType:dataType];
  uint8_t *pData = (uint8_t *)data.bytes;
  uint32_t len = (uint32_t)data.length;
  Napi::Buffer<uint8_t> buf = Napi::Buffer<uint8_t>::Copy(env, pData, len);

  [pool drain];
  return buf;
}

Value allDataForType(const CallbackInfo &info) {
  Env env = info.Env();

  if (info.Length() < 1) {
    Napi::Error::New(env, "wrong number of arguments").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  if (!info[0].IsString()) {
    Napi::Error::New(env, "string expected").ThrowAsJavaScriptException();
    return env.Undefined();
  }

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *dataType = getStringArg(info, 0);

  std::vector<Napi::Buffer<uint8_t>> buffers;
  NSArray<NSPasteboardItem *> *items = [NSPasteboard.generalPasteboard pasteboardItems];
  for (NSPasteboardItem *item in items) {
    // Get data for the specified type
    NSData *data = [item dataForType:dataType];
    if (data) {
      uint8_t *pData = (uint8_t *)data.bytes;
      uint32_t len = (uint32_t)data.length;
      Napi::Buffer<uint8_t> buf = Napi::Buffer<uint8_t>::Copy(env, pData, len);
      buffers.push_back(buf);
    }
  }

  // Convert vector of buffers to JavaScript array
  Array result = Array::New(env, buffers.size());
  for (size_t i = 0; i < buffers.size(); ++i) {
    result.Set(i, buffers[i]);
  }

  [pool drain];
  return result;
}
#endif

Object Init(Env env, Object exports) {
  HandleScope scope(env);
#ifdef __APPLE__
  // clear
  exports.Set(String::New(env, "clearContents"), Function::New(env, clearContents));

  // write
  exports.Set(String::New(env, "setData"), Function::New(env, setData));

  // read first
  exports.Set(String::New(env, "dataForType"), Function::New(env, dataForType));

  // read all
  exports.Set(String::New(env, "allDataForType"), Function::New(env, allDataForType));
#endif

  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
