//
//  OSCManager.m
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//

#import "OSCManager.h"

@interface OSCManager ()
{
    NSString *_address;
    NSInteger _port;
}
@end

@implementation OSCManager
+ (OSCManager *) sharedInstance
{
    static dispatch_once_t  onceToken;
    static OSCManager * sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OSCManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.oscClient = [[F53OSCClient alloc] init];
    }
    return self;
}

- (void)setAddress:(NSString *)address
{
    _address = address;
    return;
}

- (void)setPort:(NSInteger)port
{
    _port = port;
    return;
}

- (void)sendPacketWithDictionary:(NSDictionary *)dictionary
{
    NSString *pattern = @"";
    for(NSString *key in dictionary.allKeys)
    {
        pattern = [NSString stringWithFormat:@"%@/%@",pattern,key];
    }
    
    F53OSCMessage *message =
    [F53OSCMessage messageWithAddressPattern:pattern
                                   arguments:dictionary.allValues];
    [self.oscClient sendPacket:message toHost:_address onPort:_port];
    NSLog(@"send packet with pattern:%@ and values:%@",pattern,dictionary.allValues);
}
@end
