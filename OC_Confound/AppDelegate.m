//
//  AppDelegate.m
//  OC_Confound
//
//  Created by JB-Mac on 2018/2/2.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *bundel = [[NSBundle mainBundle] resourcePath];
    NSString *deskTopLocation = [[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[deskTopLocation stringByAppendingString:@"/Confound"] error:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
