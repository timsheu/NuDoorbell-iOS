//
//  FCMExecutive.m
//  NuDoorbell
//
//  Created by Chia-Cheng Hsu on 8/25/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "FCMExecutive.h"
#import "PlayerManager.h"
@implementation FCMExecutive

+ (FCMExecutive *) sharedInstance{
    static FCMExecutive *executive = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executive = [[self alloc] init];
    });
    return executive;
}

- (id) init{
    if (self = [super init]) {
        TAG = @"FCMExecutive";
        shmadiaManager = [ShmadiaConnectManager sharedInstance];
    }
    return self;
}

- (void) retrivedMessage:(NSDictionary *) dictionary{
    NSArray *keys = [NSArray arrayWithArray:[dictionary allKeys]];
    NSString *messageType = @"IP Data";
    if (dictionary.count > 0) {
        for (NSString *string in keys) {
            if ([string isEqualToString:@"aps"]) {
                messageType = @"Ring";
            }
            NSString *log = [dictionary objectForKey:string];
            DDLogDebug(@"%@: %@, %@", TAG, string, log);
        }
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *dic = [manager.dictionarySetting objectForKey:@"Setup Camera"];
        
        if ([messageType isEqualToString:@"Ring"]) {
            NSDictionary *apsAlert = [dictionary objectForKey:@"aps"];
            NSDictionary *alert = [apsAlert objectForKey:@"alert"];
            DDLogDebug(@"%@: aps: %@", TAG, [alert objectForKey:@"body"]);
            [_delegate openLiveStream];
        } else if ([messageType isEqualToString:@"IP Data"]){
            NSArray *messageInfoArray = @[@"PublicIPAddr", @"PrivateIPAddr", @"HTTPPort", @"RTSPPort"];
            NSString *retriveInfo;
            for (NSString *string in messageInfoArray) {
                retriveInfo = [dictionary objectForKey:string];
                if (retriveInfo) {
                    [dic setValue:retriveInfo forKey:string];
                }else {
                    DDLogDebug(@"%@: key \"%@\" has nil info", TAG, string);
                }
            }
            [self modifyURLWithPublicIP];
            [_delegate restartLiveStream];
        }
    }
}

- (void) modifyURLWithPublicIP{
    NSMutableDictionary *cameraDic = [PlayerManager.sharedInstance.dictionarySetting objectForKey:@"Setup Camera"];
    NSString *cameraIP = [cameraDic objectForKey:@"PublicIPAddr"];
    NSString *URL = [cameraDic objectForKey:@"URL"];
    NSString *oldIP;
    NSArray *splitURL = [URL componentsSeparatedByString:@"/"];
    if (splitURL.count > 1) {
        oldIP = [splitURL objectAtIndex:2];
    }
    NSString *newURL = [URL stringByReplacingOccurrencesOfString:oldIP withString:cameraIP];
    [cameraDic setObject:newURL forKey:@"URL"];
    [PlayerManager.sharedInstance updateSettingPropertyList];
}

@end
