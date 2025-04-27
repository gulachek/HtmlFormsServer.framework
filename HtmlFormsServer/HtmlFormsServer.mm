//
//  HtmlFormsServer.m
//  HtmlFormsServer
//
//  Created by Nicholas Gulachek on 4/27/25.
//

#import <Foundation/Foundation.h>
#import <HtmlFormsServer/HtmlFormsServer.h>

#include <html_forms_server.h>

@implementation HtmlFormsServer {
    html_forms_server *server_;
}

-(nonnull instancetype)initWithPort:(NSInteger)port sessionDir:(NSURL *)sessionDir {
    unsigned short shortPort = port;
    NSString *sessionDirStr = [sessionDir path];
    const char *sessionDirCstr = [sessionDirStr cStringUsingEncoding:NSUTF8StringEncoding];
    self->server_ = html_forms_server_init(shortPort, sessionDirCstr);
    return self;
}

-(void) start{
    
}

-(void) stop{
    
}

@end
