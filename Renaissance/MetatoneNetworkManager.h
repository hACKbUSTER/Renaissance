//
//  MetatoneNetworkManager.h
//  Metatone
//
//  Created by Charles Martin on 10/04/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//  Updated Version to work with F53OSC.
//

#import <Foundation/Foundation.h>
#import "F53OSC.h"
#import "SRWebSocket.h"


// IP Address method
#import <ifaddrs.h>
#import <arpa/inet.h>

@protocol MetatoneNetworkManagerDelegate <NSObject>
-(void) searchingForLoggingServer;
-(void) loggingServerFoundWithAddress: (NSString *) address andPort: (int) port andHostname:(NSString *) hostname;
-(void) stoppedSearchingForLoggingServer;
-(void) didReceiveMetatoneMessageFrom:(NSString*)device withName:(NSString*)name andState:(NSString*)state;
-(void) didReceiveGestureMessageFor:(NSString*)device withClass:(NSString*)class;
-(void) didReceiveEnsembleState:(NSString*)state withSpread:(NSNumber*)spread withRatio:(NSNumber*)ratio;
-(void) didReceiveEnsembleEvent:(NSString*)event forDevice:(NSString*)device withMeasure:(NSNumber*)measure;
-(void)didReceivePerformanceStartEvent:(NSString *)event forDevice:(NSString *)device withType:(NSNumber *)type andComposition:(NSNumber *)composition;
-(void)didReceivePerformanceEndEvent:(NSString *)event forDevice:(NSString *)device;
-(void) metatoneClientFoundWithAddress: (NSString *) address andPort: (int) port andHostname:(NSString *) hostname;
-(void) metatoneClientRemovedwithAddress: (NSString *) address andPort: (int) port andHostname:(NSString *) hostname;
@end

@interface MetatoneNetworkManager : NSObject <F53OSCPacketDestination,F53OSCClientDelegate, SRWebSocketDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (strong,nonatomic) F53OSCClient *oscClient;
@property (strong,nonatomic) F53OSCServer *oscServer;
@property (strong,nonatomic) SRWebSocket *classifierWebSocket;


//@property (strong, nonatomic) OSCConnection *connection;
@property (strong, nonatomic) NSString *loggingIPAddress;
@property (nonatomic) NSInteger loggingPort;
@property (strong, nonatomic) NSString *loggingHostname;
@property (strong, nonatomic) NSString *deviceID;
@property (strong,nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *localIPAddress;

@property (strong, nonatomic) NSString *webClassifierHostname;
@property (nonatomic) int webClassifierPort;

@property (strong, nonatomic) NSNetServiceBrowser *oscLoggerServiceBrowser;
@property (strong, nonatomic) NSNetServiceBrowser *metatoneServiceBrowser;
@property (strong, nonatomic) NSNetServiceBrowser *metatoneWebClassifierBrowser;
@property (strong, nonatomic) NSNetService *oscLoggerService;
@property (strong, nonatomic) NSNetService *metatoneNetService;
@property (strong, nonatomic) NSNetService *metatoneWebClassifierNetService;
@property (strong, nonatomic) NSMutableArray *remoteMetatoneIPAddresses;
@property (strong, nonatomic) NSMutableArray *remoteMetatoneNetServices;
@property (nonatomic) bool oscLogging;
@property (nonatomic) bool connectToWebClassifier;
@property (nonatomic) bool connectToLocalClassifier;
@property (nonatomic) bool connectToLocalWebSocket;


@property (nonatomic) bool connectedToLocalPerformanceServer;
@property (nonatomic) int connectedToServer;
@property (weak,nonatomic) id<MetatoneNetworkManagerDelegate> delegate;


+ (NSString *)getIPAddress;
+ (NSString *)getLocalBroadcastAddress;

// Designated Initialiser
- (MetatoneNetworkManager *) initWithDelegate: (id<MetatoneNetworkManagerDelegate>) delegate  shouldOscLog: (bool) osclogging;
- (MetatoneNetworkManager *) initWithDelegate: (id<MetatoneNetworkManagerDelegate>) delegate shouldOscLog: (bool) osclogging shouldConnectToWebClassifier: (bool) connectToWeb;
// Stops all searches and deletes records of remote services and addresses.
- (void)stopSearches;

- (void)sendMessageWithAccelerationX:(double) X Y:(double) Y Z:(double) Z;
//- (void)sendMessageWithTouch:(CGPoint) point Velocity:(CGFloat) vel;
- (void)sendMessageTouchEnded;
- (void)sendMesssageSwitch:(NSString *)name On:(BOOL)on;
- (void)sendMetatoneMessage:(NSString *)name withState:(NSString *)state;
- (void)sendMetatoneMessageViaServer:(NSString *)name withState:(NSString *)state;
- (void)closeClassifierWebSocket;

- (void) startConnectingToWebClassifier;
- (void) stopConnectingToWebClassifier;

@end
