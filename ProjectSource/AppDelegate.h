//
//  AppDelegate.h
//  
//
//  Created by Chia-Cheng Hsu on 2016/1/18.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCrash.h"
#import "KSCrashInstallation+Alert.h"
#import "KSCrashInstallationStandard.h"
#import "KSCrashInstallationQuincyHockey.h"
#import "KSCrashInstallationEmail.h"
#import "KSCrashInstallationVictory.h"
#import "PlayerManager.h"
#import "FCMExecutive.h"
#import <arpa/inet.h>

#define APP_VERSION @"1.0.5"

@import Firebase;
@interface AppDelegate : UIResponder <UIApplicationDelegate, ShmadiaDelegate>{
    NSString *TAG, *refreshedToken;
    BOOL tokenRefreshed;
}

@property (strong, nonatomic) UIWindow *window;


@end

