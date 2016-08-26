//
//  FCMExecutive.h
//  NuDoorbell
//
//  Created by Chia-Cheng Hsu on 8/25/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventMsgDef.h"
#import "ShmadiaConnectManager.h"

@class PlayerManager;

@protocol FCMExecutiveDelegate <NSObject>

@end

@interface FCMExecutive : NSObject{
    NSString *TAG;
    ShmadiaConnectManager *shmadiaManager;
}
- (id) init;
+ (FCMExecutive *) sharedInstance;
@property (nonatomic, weak) id <FCMExecutiveDelegate> delegate;
- (void)retrivedMessage:(NSDictionary *)dictionary;
@end
