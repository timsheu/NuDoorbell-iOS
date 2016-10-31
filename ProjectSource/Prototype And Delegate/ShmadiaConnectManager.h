//
//  ShmadiaConnectManager.h
//  NuDoorbell
//
//  Created by Chia-Cheng Hsu on 8/26/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventMsgDef.h"
#import "GCDAsyncSocket.h"

#define SHMADIA_LOGIN_DEFAULT_PORT 5542
#define SHMADIA_LOGIN_PACKET_LENGTH 344 // 8+64+1+4+255+4+4+4, See EventMsgDef.h
#define SHMADIA_LOGIN_RESPONSE_LENGTH 32 // 8+4*6, See EventMsgDef.h
#define TEST_UUID @"00000001"
#define SERVER_IP @"192.168.8.9"
enum{
    SHMADIA_TAG_DEFAULT = 0,
    SHMADIA_TAG_READ_PACKET_LENGTH,
    SHMADIA_TAG_WRITE_LOGIN,
    SHMADIA_TAG_READ_RESPONSE,
};

@class PlayerManager;
@protocol ShmadiaDelegate <NSObject>
- (void) didConnectedToShmadia;
- (void) didReadDataFromShmadia:(NSData *) data;
@end

@interface ShmadiaConnectManager : NSObject <GCDAsyncSocketDelegate>{
    GCDAsyncSocket *socket;
    NSMutableArray *connectedSocket;
    dispatch_queue_t socketQueue;
    int connectTry;
    S_EVENTMSG_LOGIN_REQ shmadiaLoginRequest;
    S_EVENTMSG_LOGIN_RESP shmadiaLoginResponse;
    NSString *TAG;
    int localTag;
    NSMutableData *mutableData;
}

@property BOOL isConnected;
@property (nonatomic, weak) id <ShmadiaDelegate> delegate;
+ (ShmadiaConnectManager *) sharedInstance;
- (id) init;
- (void) connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int) tag;
- (void) disconnectFormHost;
- (void) writeLoginData:(NSData *)data withTag:(int) tag;
- (void) writeDefaultLoginDataToShmadia;
- (void) setupShmadiaLoginRequestPackage:(NSString *)fcmToken;

@end
