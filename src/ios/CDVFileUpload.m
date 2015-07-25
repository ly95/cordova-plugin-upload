#import "CDVFileUpload.h"

@implementation CDVFileUpload

- (void)upload:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* msg = @"ok";
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
    
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end