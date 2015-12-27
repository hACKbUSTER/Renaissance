//
//  OSCManager.h
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "F53OSC.h"

@interface OSCManager : NSObject

@property (nonatomic, strong) F53OSCClient *oscClient;
+ (OSCManager *) sharedInstance;

- (void)sendPacketWithPattern:(NSString *)pattern Value:(NSArray *)array;
- (void)setAddress:(NSString *)address;
- (void)connect;
- (void)setPort:(NSInteger)port;
- (void)sendPacketWithDictionary:(NSDictionary *)dictionary;
@end
