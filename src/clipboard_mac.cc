#include <iostream>

#include <nan.h>
#include <node.h>
#include <node_buffer.h>
#include <v8.h>

#ifdef __APPLE__
#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#endif

using namespace std;
using namespace v8;

#ifdef __APPLE__
NSString *getStringArg(const Nan::FunctionCallbackInfo<Value> &info,
                       int index) {
  Nan::Utf8String valInUtf8String(info[index]);
  std::string valInStdString(*valInUtf8String);
  NSString *val = [NSString stringWithUTF8String:valInStdString.c_str()];
  return val;
}

NAN_METHOD(clearContents) {
#ifdef DEBUG
  NSLog(@"clearContents ...");
#endif

  // clear
  [NSPasteboard.generalPasteboard clearContents];
}

NAN_METHOD(setData) {
  if (info.Length() < 2) {
    Nan::ThrowTypeError("wrong number of arguments");
    return;
  }
  if (!info[0]->IsString() || !info[1]->IsObject()) {
    Nan::ThrowTypeError(
        "arguments type does not match (format: string, buf: Buffer)");
    return;
  }
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // arg1: format
  NSString *format = getStringArg(info, 0);

  // arg2: buf
  char *buf = node::Buffer::Data(info[1]);
  size_t length = node::Buffer::Length(info[1]);
  NSData *data = [NSData dataWithBytesNoCopy:buf
                                      length:(NSUInteger)length
                                freeWhenDone:NO];
#ifdef DEBUG
  NSLog(@"setData: format=%@, buf.length=%@", format, length);
#endif

  // format
  [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];

  // setData
  BOOL success = [NSPasteboard.generalPasteboard setData:data forType:format];
#ifdef DEBUG
  NSLog(@"writeToClipboard: result = %i", success);
#endif

  info.GetReturnValue().Set(Nan::New<v8::Boolean>(success));
  [pool drain];
}

NAN_METHOD(dataForType) {
  if (info.Length() < 1) {
    Nan::ThrowTypeError("wrong number of arguments");
    return;
  }
  if (!info[0]->IsString()) {
    Nan::ThrowTypeError("string expected");
    return;
  }
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *dataType = getStringArg(info, 0);
  NSData *data = [NSPasteboard.generalPasteboard dataForType:dataType];
  char *pData = (char *)data.bytes;
  uint32_t len = (uint32_t)data.length;
  v8::Local<v8::Object> ret = Nan::CopyBuffer(pData, len).ToLocalChecked();

  info.GetReturnValue().Set(ret);
  [pool drain];
}

#endif

void init(v8::Local<v8::Object> exports) {
  Nan::HandleScope scope;
#ifdef __APPLE__
  // clear
  Nan::SetMethod(exports, "clearContents", clearContents);

  // write
  Nan::SetMethod(exports, "setData", setData);

  // read
  Nan::SetMethod(exports, "dataForType", dataForType);
#endif
}

NODE_MODULE(NODE_GYP_MODULE_NAME, init)