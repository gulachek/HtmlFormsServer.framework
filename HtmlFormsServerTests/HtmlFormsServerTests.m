//
//  HtmlFormsServerTests.m
//  HtmlFormsServerTests
//
//  Created by Nicholas Gulachek on 4/23/25.
//

#import <XCTest/XCTest.h>
#import <HtmlFormsServer/HtmlFormsServer.h>

@interface HtmlFormsServerTests : XCTestCase
@property NSURL*_Nullable sessionDir;
@end

@implementation HtmlFormsServerTests

- (void)setUp {
    NSFileManager *fman = [NSFileManager defaultManager];
    NSURL *tempDir = [fman temporaryDirectory];
    self.sessionDir = [tempDir URLByAppendingPathComponent:@"HtmlFormsServerTests"];
    
    // Remove in case prior test aborted
    [fman removeItemAtURL:self.sessionDir error:nil];
    
    BOOL success = [fman createDirectoryAtURL:self.sessionDir withIntermediateDirectories:YES attributes:nil error:nil];
    XCTAssertTrue(success);
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtURL:self.sessionDir error:nil];
}

- (void)testCanInitializeServer {
    HtmlFormsServer *server = [[HtmlFormsServer alloc] initWithPort:9999 sessionDir:self.sessionDir];
    XCTAssertNotNil(server);
}

@end
