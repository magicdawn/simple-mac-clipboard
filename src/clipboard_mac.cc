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
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *path = getStringArg(info, 0);
  NSString *format = getStringArg(info, 1);
#ifdef DEBUG
  NSLog(@"setStringData: path=%@, format=%@", path, format);
#endif

  // format
  [NSPasteboard.generalPasteboard declareTypes:@[ format ] owner:nil];

  // setData
  NSData *pathData = [path dataUsingEncoding:NSUTF8StringEncoding];
  [NSPasteboard.generalPasteboard setData:pathData forType:format];
#ifdef DEBUG
  NSLog(@"success writeToClipboard");
#endif

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