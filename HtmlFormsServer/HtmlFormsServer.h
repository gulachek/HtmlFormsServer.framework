//
//  HtmlFormsServer.h
//  HtmlFormsServer
//
//  Created by Nicholas Gulachek on 4/23/25.
//

#import <Foundation/Foundation.h>

//! Project version number for HtmlFormsServer.
FOUNDATION_EXPORT double HtmlFormsServerVersionNumber;

//! Project version string for HtmlFormsServer.
FOUNDATION_EXPORT const unsigned char HtmlFormsServerVersionString[];

@protocol HtmlFormsServerDelegate <NSObject>

-(void)openUrl:(NSURL*_Nonnull)url windowId:(int)windowId;

@end

@interface HtmlFormsServer : NSObject

@property (weak) id<HtmlFormsServerDelegate> _Nullable delegate;

-(nonnull instancetype)initWithPort:(int)port sessionDir:(NSURL* _Nonnull)sessionDir;
-(void)start;
-(void)stop;

@end
