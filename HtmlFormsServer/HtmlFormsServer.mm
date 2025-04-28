//
//  HtmlFormsServer.m
//  HtmlFormsServer
//
//  Created by Nicholas Gulachek on 4/27/25.
//

#import <Foundation/Foundation.h>
#import <HtmlFormsServer/HtmlFormsServer.h>

#include <html_forms_server.h>
#include <os/log.h>

@implementation HtmlFormsServer {
    html_forms_server *server_;
    BOOL is_running_;
    os_log_t log_;
}

static void evt_callback(const html_forms_server_event *evt, void *ctx) {
    if (!(evt && ctx))
        return;
    
    HtmlFormsServer *server = (__bridge HtmlFormsServer*)ctx;
    [server handleEvent:evt];
}

-(nonnull instancetype)initWithPort:(NSInteger)port sessionDir:(NSURL *)sessionDir {
    unsigned short shortPort = port;
    NSString *sessionDirStr = [sessionDir path];
    const char *sessionDirCstr = [sessionDirStr cStringUsingEncoding:NSUTF8StringEncoding];
    self->server_ = html_forms_server_init(shortPort, sessionDirCstr);
    self->is_running_ = NO;
    self->log_ = os_log_create("com.gulachek.HtmlFormsServer", "server");
    return self;
}

-(void) dealloc{
    [self stop];
    html_forms_server_free(self->server_);
}

-(void)connectClientFd:(int)clientFd {
    html_forms_server_connect(self->server_, clientFd);
}

-(void) start{
    if (self->is_running_)
        return;
    
    self->is_running_ = YES;
    html_forms_server_set_event_callback(self->server_, evt_callback, (__bridge void*)self);
    html_forms_server_run(self->server_);
}

-(void) stop{
    if (!self->is_running_)
        return;
    
    self->is_running_ = NO;
    html_forms_server_set_event_callback(self->server_, nil, nil);
    html_forms_server_stop(self->server_);
}

-(void) handleEvent:(const html_forms_server_event *)evt {
    id<HtmlFormsServerDelegate> del = self.delegate;
    if (!del)
        return;
    
    if (evt->type == HTML_FORMS_SERVER_EVENT_OPEN_URL) {
        NSInteger winId = evt->data.open_url.window_id;
        NSString *urlStr = [NSString stringWithCString:evt->data.open_url.url encoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        [del openUrl:url window:winId];
    } else if (evt->type == HTML_FORMS_SERVER_EVENT_CLOSE_WINDOW) {
        NSInteger winId = evt->data.close_win.window_id;
        [del closeWindow:winId];
    } else {
        os_log(self->log_, "Received server event with unknown type (type=%d)", evt->type);
    }
}

@end
