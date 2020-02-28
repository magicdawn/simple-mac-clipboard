#include <iostream>
#import <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/objc-runtime.h>

#include <node.h>
#include <v8.h>
#include <nan.h>

using namespace std;
using namespace v8;

NSString* getStringArg(const Nan::FunctionCallbackInfo<Value>& info, int index) {
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
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  NSString* path = getStringArg(info, 0);
  NSString* format = getStringArg(info, 1);
  #ifdef DEBUG
  NSLog(@"setStringData: path=%@, format=%@", path, format);
  #endif

  // format
  [NSPasteboard.generalPasteboard declareTypes:@[format] owner:nil];

  // setData
  NSData* pathData = [path dataUsingEncoding:NSUTF8StringEncoding];
  [NSPasteboard.generalPasteboard setData:pathData forType:format];
  NSLog(@"success writeToClipboard");

  [pool drain];
}

void init(v8::Local<v8::Object> exports)
{
  Nan::HandleScope scope;
  Nan::SetMethod(exports, "clearContents", clearContents);
  Nan::SetMethod(exports, "setStringData", setStringData);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, init)