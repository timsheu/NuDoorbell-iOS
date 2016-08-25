//
//  CommandGenerator.h
//  
//
//  Created by Chia-Cheng Hsu on 2016/2/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandPool.h"
#import "SettingPool.h"
#import "PlayerManager.h"
@interface CommandGenerator : NSObject
+ (NSString *)generateInfoCommandWithName:(NSString *)string;
+ (NSString *)generateInfoCommandWithName:(NSString *)string parameters:(NSArray *)array;
@end
