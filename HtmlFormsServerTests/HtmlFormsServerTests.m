//
//  HtmlFormsServerTests.m
//  HtmlFormsServerTests
//
//  Created by Nicholas Gulachek on 4/23/25.
//

#import <HtmlFormsServer/HtmlFormsServer.h>
#import <XCTest/XCTest.h>

// Client API
#include <catui.h>
#include <html_forms.h>
#include <msgstream.h>
#include <unixsocket.h>

#define PORT 9999

@interface ServerThread : NSThread <HtmlFormsServerDelegate>

@property NSURL *_Nullable mostRecentURL;
@property NSInteger windowId;
@property BOOL windowClosed;
@property BOOL hasErrorMsg;

- (nonnull instancetype)initWithCatuiFd:(int)catuiFd
                                 server:(HtmlFormsServer *)server;

@end

@implementation ServerThread {
  int catuiFd_;
  HtmlFormsServer *server_;
}

- (nonnull instancetype)initWithCatuiFd:(int)catuiFd
                                 server:(HtmlFormsServer *)server {
  self->catuiFd_ = catuiFd;
  self->server_ = server;
  server.delegate = self;
  self.mostRecentURL = nil;
  self.windowClosed = NO;
  self.windowId = -1;
  return [super init];
}

- (void)main {
  int client = unix_accept(self->catuiFd_);
  XCTAssertGreaterThan(client, -1);

  char connect_buf[CATUI_CONNECT_SIZE];
  size_t msgSize;
  int ec = msgstream_fd_recv(client, connect_buf, CATUI_CONNECT_SIZE, &msgSize);
  XCTAssertEqual(ec, MSGSTREAM_OK);

  // Don't actually care about validating the catui connect request. Let's just
  // assume it worked
  [self->server_ connectClientFd:client];
  [self->server_ start];
}

- (void)openUrl:(NSURL *_Nonnull)url window:(NSInteger)windowId {
  XCTAssertGreaterThan(windowId, -1);
  XCTAssertTrue(self.windowId == -1 || windowId == self.windowId);

  self.mostRecentURL = url;
  self.windowId = windowId;
}

- (void)closeWindow:(NSInteger)windowId {
  XCTAssertGreaterThan(windowId, -1);
  XCTAssertTrue(windowId == self.windowId);

  self.windowClosed = YES;
  self.windowId = -1;
}

- (void)showErrorMessage:(NSString *_Nonnull)errMsg window:(NSInteger)windowId {
  XCTAssertGreaterThan(windowId, -1);
  XCTAssertTrue(windowId == self.windowId);

  self.hasErrorMsg = YES;
}

@end

@interface HtmlFormsServerTests : XCTestCase
@property NSURL *_Nullable sessionDir;
@property NSURL *_Nullable catuiPath;
@property int catuiFd;
@end

@implementation HtmlFormsServerTests

- (void)setUp {
  NSFileManager *fman = [NSFileManager defaultManager];
  NSURL *tempDir = [fman temporaryDirectory];
  self.sessionDir =
      [tempDir URLByAppendingPathComponent:@"HtmlFormsServerTests"];

  // Remove in case prior test aborted
  [fman removeItemAtURL:self.sessionDir error:nil];

  BOOL success = [fman createDirectoryAtURL:self.sessionDir
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
  XCTAssertTrue(success);

  self.catuiFd = unix_socket();
  XCTAssertGreaterThan(self.catuiFd, -1);

  self.catuiPath =
      [tempDir URLByAppendingPathComponent:@"HtmlFormsServerTests-catui.sock"];
  [fman removeItemAtURL:self.catuiPath error:nil];

  const char *catuiPathCStr =
      [[self.catuiPath path] cStringUsingEncoding:NSUTF8StringEncoding];
  setenv("CATUI_ADDRESS", catuiPathCStr, 1);
  XCTAssertFalse(unix_bind(self.catuiFd, catuiPathCStr));
  XCTAssertFalse(unix_listen(self.catuiFd, 8));
}

- (void)tearDown {
  NSFileManager *fman = [NSFileManager defaultManager];
  [fman removeItemAtURL:self.sessionDir error:nil];
  [fman removeItemAtURL:self.catuiPath error:nil];
}

- (void)testCanInitializeServer {
  HtmlFormsServer *server =
      [[HtmlFormsServer alloc] initWithPort:PORT sessionDir:self.sessionDir];
  XCTAssertNotNil(server);
}

- (void)testNavigationInformsDelegateOpenUrl {
  HtmlFormsServer *server =
      [[HtmlFormsServer alloc] initWithPort:PORT sessionDir:self.sessionDir];
  XCTAssertNotNil(server);

  ServerThread *th = [[ServerThread alloc] initWithCatuiFd:self.catuiFd
                                                    server:server];
  [th start];

  html_connection *con;
  XCTAssertTrue(html_connect(&con));

  html_navigate(con, "/index.html");

  int i = 0;
  NSURL *url = nil;
  while (!url && i++ < 1000) {
    url = th.mostRecentURL;
    [NSThread sleepForTimeInterval:0.01];
  }

  XCTAssertTrue([[url path] hasSuffix:@"/index.html"]);
}

- (void)testDisconnectInformsDelegateCloseWindow {
  HtmlFormsServer *server =
      [[HtmlFormsServer alloc] initWithPort:PORT sessionDir:self.sessionDir];
  XCTAssertNotNil(server);

  ServerThread *th = [[ServerThread alloc] initWithCatuiFd:self.catuiFd
                                                    server:server];
  [th start];

  html_connection *con;
  XCTAssertTrue(html_connect(&con));

  html_navigate(con, "/index.html");
  html_disconnect(con);

  int i = 0;
  while (!th.windowClosed && i++ < 1000) {
    [NSThread sleepForTimeInterval:0.01];
  }

  XCTAssertTrue(th.windowClosed);
}

- (void)testForcefulSocketCloseInformsServerShowError {
  HtmlFormsServer *server =
      [[HtmlFormsServer alloc] initWithPort:PORT sessionDir:self.sessionDir];
  XCTAssertNotNil(server);

  ServerThread *th = [[ServerThread alloc] initWithCatuiFd:self.catuiFd
                                                    server:server];
  [th start];

  html_connection *con;
  XCTAssertTrue(html_connect(&con));

  html_navigate(con, "/index.html");
  close(html_connection_fd(con));

  int i = 0;
  while (!th.hasErrorMsg && i++ < 1000) {
    [NSThread sleepForTimeInterval:0.01];
  }

  XCTAssertTrue(th.hasErrorMsg);
  html_disconnect(con);
}

- (void)testCloseWindowServerSideRequestsCloseClientSide {
  HtmlFormsServer *server =
      [[HtmlFormsServer alloc] initWithPort:PORT sessionDir:self.sessionDir];
  XCTAssertNotNil(server);

  ServerThread *th = [[ServerThread alloc] initWithCatuiFd:self.catuiFd
                                                    server:server];
  [th start];

  html_connection *con;
  XCTAssertTrue(html_connect(&con));

  html_navigate(con, "/index.html");

  int i = 0;
  NSInteger windowId = -1;
  while (windowId < 0 && i++ < 1000) {
    windowId = th.windowId;
    [NSThread sleepForTimeInterval:0.01];
  }

  XCTAssertGreaterThan(windowId, -1);
  [server closeWindow:windowId];

  char buf[4];
  size_t msgSize;
  int ret = html_recv(con, buf, sizeof(buf), &msgSize);

  XCTAssertFalse(ret);
  XCTAssertTrue(html_close_requested(con));

  html_disconnect(con);
}

@end
