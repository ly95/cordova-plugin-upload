#import <Cordova/CDV.h>

@interface CDVFileUpload : CDVPlugin
{
    NSString *_callbackId;
}

- (void) upload:(CDVInvokedUrlCommand*)command;

@end