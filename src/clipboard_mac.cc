#include <iostream>

#include <node.h>
#include <v8.h>
#include <nan.h>

#ifdef __APPLE__
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/objc-runtime.h>
#endif

using namespace std;
using namespace v8;

#ifdef __APPLE__
NSString *getStringArg(const Nan::FunctionCallbackInfo<Value> &info, int index)
{
  Nan::Utf8String valInUtf8String(info[index]);
  std::string valInStdString(*valInUtf8String);
  NSString *val = [NSString stringWithUTF8String:valInStdString.c_str()];
  return val;
}

NAN_METHOD(clearContents)
{
#ifdef DEBUG
  NSLog(@"clearContents ...");
#endif

  // clear
  [NSPasteboard.generalPasteboard clearContents];
}

NAN_METHOD(setStringData)
{
  if (info.Length() < 2)
  {
    Nan::ThrowTypeError("wrong number of arguments");
    return;
  }

  if (!info[0]->IsString() || !info[0]->IsString())
  {
    Nan::ThrowTypeError("arguments type does not match (data: string, format: string) => void");
    return;
  }

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *data = getStringArg(info, 0);
  NSString *format = getStringArg(info, 1);
#ifdef DEBUG
  NSLog(@"setStringData: data=%@, format=%@", data, format);
#endif

  // format
  [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];

  // setData
  NSData *nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
  BOOL success = [NSPasteboard.generalPasteboard setData:nsData forType:format];
#ifdef DEBUG
  NSLog(@"writeToClipboard: result = %i", success);
#endif

  info.GetReturnValue().Set(Nan::New<v8::Boolean>(success));
  [pool drain];
}
#endif

void init(v8::Local<v8::Object> exports)
{
  Nan::HandleScope scope;
#ifdef __APPLE__
  Nan::SetMethod(exports, "clearContents", clearContents);
  Nan::SetMethod(exports, "setStringData", setStringData);
#endif
}

NODE_MODULE(NODE_GYP_MODULE_NAME, init)