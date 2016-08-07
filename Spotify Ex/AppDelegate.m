//
//  AppDelegate.m
//  Spotify Ex
//
//  Created by Jorge Jhamil Pineda Echeverria on 07/08/16.
//  Copyright © 2016 jjpe. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SPTAuth defaultInstance] setClientID:@"a06285cd764a4cccb28d4bcb48ba15df"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"spotify-ex-app-login://callback"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
    
    return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            // Call the -loginUsingSession: method to login SDK
            [self loginUsingSession:session];
        }];
        return YES;
    }
    
    return NO;
}

-(void)loginUsingSession:(SPTSession *)session {
    // Get the player instance
    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self;
    // Start the player (will start a thread)
    [self.player startWithClientId:@"a06285cd764a4cccb28d4bcb48ba15df" error:nil];
    // Login SDK before we can start playback
    [self.player loginWithAccessToken:session.accessToken];
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    NSURL *url = [NSURL URLWithString:@"spotify:track:58s6EuEYJdlb0kO7awm3Vp"];
    [self.player playURI:url callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** failed to play: %@", error);
            return;
        }
    }];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didEncounterError:(NSError *)error {
    if (error != nil) {
        NSLog(@"*** Playback got error: %@", error);
        return;
    }
}

@end
