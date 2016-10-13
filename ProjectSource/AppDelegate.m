//
//  AppDelegate.m
//  
//
//  Created by Chia-Cheng Hsu on 2016/1/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    tokenRefreshed = NO;
    TAG = @"AppDelegate";
    // Override point for customization after application launch.
    KSCrashInstallationEmail *email = [KSCrashInstallationEmail sharedInstance];
    email.recipients = @[@"CCHSU20@nuvoton.com"];
    [email setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
    [email addConditionalAlertWithTitle:@"Crash Detected" message:@"The APP crashed last time it was launched. Send a crash report!" yesAnswer:@"Okay!" noAnswer:@"No thanks."];
    [email install];
    [email sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        DDLogDebug(@"test");
    }];
    
    // Register for remote notifications
    // iOS 8 or later
    // [START register_for_notifications]
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    // [END register_for_notifications]
    NSDictionary *dic = [PlayerManager.sharedInstance.dictionarySetting objectForKey:@"Setup Camera"];
    
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    NSString *version = [dic objectForKey:@"Version"];
    if (![version isEqualToString:@"1.0.2"] || version == nil) {
        [[PlayerManager sharedInstance] resetData];
    }
    
    NSString *token = [dic objectForKey:@"FCM Token"];
    if (token != nil) {
        ShmadiaConnectManager *manager = [ShmadiaConnectManager sharedInstance];
        manager.delegate = self;
        NSString *port = [NSString stringWithFormat:@"%d", SHMADIA_LOGIN_DEFAULT_PORT];
        [manager connectHost:SERVER_IP withPort:port withTag:SHMADIA_TAG_WRITE_LOGIN];
    }
    return YES;
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
//    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Pring full message.
    NSLog(@"%@: %@", TAG, userInfo);
    [[FCMExecutive sharedInstance] retrivedMessage:userInfo];
}
// [END receive_message]

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connectToFcm];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma following: Shmadia delegate

- (void)didConnectedToShmadia{
    DDLogDebug(@"%@: did connected to shmadia, attempt to write login message", TAG);
    [ShmadiaConnectManager.sharedInstance setupShmadiaLoginRequestPackage:refreshedToken];
}

- (void)didReadDataFromShmadia:(NSData *)data{
    DDLogDebug(@"%@: %@", TAG, data);
    S_EVENTMSG_LOGIN_RESP response;
    [data getBytes:&response length:data.length];
    DDLogDebug(@"%@: %d, %d, %d, %d, %@, %@, %d, %d", TAG,
               (int)response.sMsgHdr.eMsgType,
               (int)response.sMsgHdr.u32MsgLen,
               (int)response.eResult,
               (int)response.bDevOnline,
               [self ipConversion:response.u32DevPublicIP],
               [self ipConversion:response.u32DevPrivateIP],
               (int)response.u32DevHTTPPort,
               (int)response.u32DevRTSPPort);
    NSString *publicIP = [self ipConversion:(int)response.u32DevPublicIP];
    NSString *privateIP = [self ipConversion:(int)response.u32DevPrivateIP];
    NSString *httpPort = [NSString stringWithFormat:@"%u", response.u32DevHTTPPort];
    NSString *rtspPort = [NSString stringWithFormat:@"%u", response.u32DevRTSPPort];
    NSDictionary *dictionary = @{@"PublicIPAddr": publicIP, @"PrivateIPAddr": privateIP, @"HTTPPort": httpPort, @"RTSPPort": rtspPort};
    [FCMExecutive.sharedInstance retrivedMessage:dictionary];
}

#pragma following: FCM delegates

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    tokenRefreshed = YES;
    refreshedToken = [[FIRInstanceID instanceID] token];
    [[PlayerManager.sharedInstance dictionarySetting] setObject:refreshedToken forKey:@"FCM Token"];
    NSLog(@"InstanceID token: %@", refreshedToken);
    ShmadiaConnectManager *manager = [ShmadiaConnectManager sharedInstance];
    manager.delegate = self;
    NSString *port = [NSString stringWithFormat:@"%d", SHMADIA_LOGIN_DEFAULT_PORT];
    [manager connectHost:SERVER_IP withPort:port withTag:SHMADIA_TAG_WRITE_LOGIN];
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
            NSString *fcmToken = [[PlayerManager.sharedInstance.dictionarySetting objectForKey:@"Setup Camera"] objectForKey:@"FCM Token"];
            if (fcmToken && tokenRefreshed == NO) {
                ShmadiaConnectManager *manager = [ShmadiaConnectManager sharedInstance];
                manager.delegate = self;
                NSString *port = [NSString stringWithFormat:@"%d", SHMADIA_LOGIN_DEFAULT_PORT];
                [manager connectHost:SERVER_IP withPort:port withTag:SHMADIA_TAG_WRITE_LOGIN];
            }
        }
    }];
}
// [END connect_to_fcm]

#pragma following: utilities

- (NSString *) ipConversion:(uint32_t)number{
    NSString *result = @"-1";
    number = ntohl(number);
    struct in_addr a;
    a.s_addr = number;
    char *remote = inet_ntoa(a);
    if (remote) {
        result = [NSString stringWithUTF8String:remote];
    }else {
        DDLogDebug(@"%@: convert to nil, should never happen", TAG);
    }
    return result;
}

@end
