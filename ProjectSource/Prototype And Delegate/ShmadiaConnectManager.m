//
//  ShmadiaConnectManager.m
//  NuDoorbell
//
//  Created by Chia-Cheng Hsu on 8/26/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "ShmadiaConnectManager.h"
#import "PlayerManager.h"
@implementation ShmadiaConnectManager
- (id) init{
    if (self = [super init]) {
        TAG = @"ShmadiaConnectManager";
        _isConnected = NO;
        connectTry = 0;
        connectedSocket = [[NSMutableArray alloc] initWithCapacity:1];
        socketQueue = dispatch_queue_create("shmadiaQueue", NULL);
        socket = [[GCDAsyncSocket alloc] init];
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
        localTag = -1;
        mutableData = [[NSMutableData alloc] initWithCapacity:SHMADIA_LOGIN_PACKET_LENGTH];
    }
    return self;
}
+ (ShmadiaConnectManager *)sharedInstance{
    static ShmadiaConnectManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma following: GCDAyncSocket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    _isConnected = socket.isConnected;
    DDLogDebug(@"%@: did connect to host: %@, %d", TAG, host, (int)port);
    [_delegate didConnectedToShmadia];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    _isConnected = socket.isConnected;
    DDLogDebug(@"%@: did connect to host with error: %@", TAG, err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    DDLogDebug(@"%@: did write data with tag: %ld", TAG, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    DDLogDebug(@"%@: did read data with tag: %ld", TAG, tag);
    switch (tag) {
        case SHMADIA_TAG_READ_PACKET_LENGTH:
            DDLogDebug(@"%@: data length: %lu", TAG, (unsigned long)data.length);
            if (data.length == 8) {
                S_EVENTMSG_HEADER header;
                [data getBytes:&header length:data.length];
                DDLogDebug(@"%@: data content: %d, %d", TAG, header.eMsgType, header.u32MsgLen);
                int dataLength = (int) header.u32MsgLen;
                dataLength -= data.length;
                [socket readDataToLength:dataLength withTimeout:-1 tag:SHMADIA_TAG_READ_RESPONSE];
                if (mutableData.length != 0) {
                    mutableData = nil;
                    mutableData = [[NSMutableData alloc] initWithCapacity:SHMADIA_LOGIN_PACKET_LENGTH];
                }
                [mutableData appendData:data];
            }else {
                DDLogDebug(@"%@: data header is no equal to 8, should never happen.", TAG);
            }
            break;
        case SHMADIA_TAG_READ_RESPONSE:
            DDLogDebug(@"%@: data length: %lu", TAG, (unsigned long)data.length);
            if (data.length == SHMADIA_LOGIN_RESPONSE_LENGTH - 8) {
                [mutableData appendData:data];
                [_delegate didReadDataFromShmadia:mutableData];
                DDLogDebug(@"%@: data: %@", TAG, data);
            }else {
                DDLogDebug(@"%@: data length is no equal to 344, should never happen.", TAG);
            }
            break;
        default:
            break;
    }
}

#pragma following: ShemadiaConnectManager Functions

- (void)connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int)tag{
    if (socket) {
        DDLogDebug(@"%@: attempt to connect host: %@, %@, tag: %d", TAG, hostURL, hostPort, tag);
        [socket connectToHost:hostURL onPort:hostPort.intValue error:nil];
    }else {
        DDLogDebug(@"%@: socket is not initialize, should never happen", TAG);
    }
}

- (void)disconnectFormHost{
    _isConnected = socket.isConnected;
    if (_isConnected) {
        [socket disconnect];
    }else {
        DDLogDebug(@"%@: The socket is not connected. Nothing is to be done.", TAG);
    }
}

- (void)writeLoginData:(NSData *)data withTag:(int)tag{
    _isConnected = socket.isConnected;
    if (socket && _isConnected) {
        [socket readDataToLength:8 withTimeout:-1 tag:SHMADIA_TAG_READ_PACKET_LENGTH];
        [socket writeData:data withTimeout:-1 tag:SHMADIA_TAG_WRITE_LOGIN];
    }
}

- (void)writeDefaultLoginDataToShmadia{
    _isConnected = socket.isConnected;
    if (socket && _isConnected) {
        DDLogDebug(@"%@: %lu, %d", TAG, sizeof(shmadiaLoginRequest), shmadiaLoginRequest.sMsgHdr.u32MsgLen);
        NSData *data = [NSData dataWithBytes:&shmadiaLoginRequest length:shmadiaLoginRequest.sMsgHdr.u32MsgLen];
        DDLogDebug(@"%@, data: %@", TAG, data);
        [socket readDataToLength:8 withTimeout:-1 tag:SHMADIA_TAG_READ_PACKET_LENGTH];
        [socket writeData:data withTimeout:-1 tag:SHMADIA_TAG_WRITE_LOGIN];
    }
}

- (void)setupShmadiaLoginRequestPackage:(NSString *)fcmToken{
    shmadiaLoginRequest.sMsgHdr.eMsgType = eEVENTMSG_LOGIN;
    shmadiaLoginRequest.sMsgHdr.u32MsgLen = sizeof(shmadiaLoginRequest);
    NSString *uuidString = TEST_UUID;
    NSData *uuidData = [uuidString dataUsingEncoding:NSUTF8StringEncoding];
    [uuidData getBytes:shmadiaLoginRequest.szUUID length:uuidData.length];
    shmadiaLoginRequest.eRole = eEVENTMSG_ROLE_USER;
    NSData *tokenData = [fcmToken dataUsingEncoding:NSUTF8StringEncoding];
    [tokenData getBytes:shmadiaLoginRequest.szCloudRegID length:tokenData.length];
    [self writeDefaultLoginDataToShmadia];
}

@end
