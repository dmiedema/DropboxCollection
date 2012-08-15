//
//  AppDelegate.m
//  DropboxCollection
//
//  Created by Ryan Mullins on 8/14/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "AppDelegate.h"

#define DB_APP_KEY @"am1b7b0nkux3g30"
#define DB_APP_SECRET @"opp3cb7tfaacuut"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"main" bundle:nil];
    UIViewController * root = [storyboard instantiateInitialViewController];
    
    DBSession * session = [[DBSession alloc] initWithAppKey:DB_APP_KEY appSecret:DB_APP_SECRET root:kDBRootDropbox];
    [DBSession setSharedSession:session];
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:root];
    }
    
    [self.window setRootViewController:root];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma DropboxSDK

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"Session is linked!");
        }
        
        return YES;
    }
    
    return NO;
}

@end
