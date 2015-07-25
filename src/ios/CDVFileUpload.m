#import "CDVFileUpload.h"
#import "CDVLocalFilesystem.h"

@implementation CDVFileUpload

- (void)upload:(CDVInvokedUrlCommand*)command
{
    NSError* __autoreleasing err = nil;
    
    _callbackId = command.callbackId;
    
    NSString *url = [command.arguments objectAtIndex:0];
    NSArray *uploadFiles = [command.arguments objectAtIndex:1];
    NSDictionary *postParams = [command.arguments objectAtIndex:2];
    
    NSMutableArray *filesData = [[NSMutableArray alloc] init];
    for (NSString *source in uploadFiles) {
        NSString* filePath = [source hasPrefix:@"/"] ? [source copy] : [(NSURL *)[NSURL URLWithString:source] path];
        if (filePath == nil) {
            NSLog(@"无法读取文件");
        } else {
            NSData* data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&err];
            if (!err) {
                [filesData addObject:data];
                NSLog(@"读取文件完成");
            } else {
                NSLog(@"读取文件失败");
            }
        }
    }
    
    [self uploadFileToServer:url filesData:filesData params:postParams];
}

- (void)uploadFileToServer:(NSString*)uri filesData: (NSMutableArray*) filesData params:(NSDictionary*) params {
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@", TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--", MPboundary];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uri]];
    
    NSMutableString *body= [[NSMutableString alloc] init];
    
    NSArray *keys= [params allKeys];
    
    for(int i=0; i<[keys count]; i++) {
        NSString *key=[keys objectAtIndex:i];
        [body appendFormat:@"%@\r\n",MPboundary];
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [body appendFormat:@"%@\r\n",[params objectForKey:key]];
    }
    [body appendFormat:@"%@\r\n",MPboundary];
    
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    for(int i = 0; i < [filesData count]; i++){
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        
        [imgbody appendFormat:@"%@\r\n", MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"File%d\"; filename=\"%d.jpg\"\r\n", i, i];
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];
        
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:[filesData objectAtIndex:i]];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        CDVPluginResult* result;
        
        if (connectionError) {
            NSLog(@"Httperror:%@ %ld", connectionError.localizedDescription, connectionError.code);
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: connectionError.localizedDescription];
        } else {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: responseString];
        }
        
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
    }];
}

@end