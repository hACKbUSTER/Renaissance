//
//  ViewController.m
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f)

#import "ViewController.h"
#import "OSCManager.h"
#include <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[OSCManager sharedInstance] setAddress:@"169.254.172.171"];
    [[OSCManager sharedInstance] setPort:7400];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
    [self.view addGestureRecognizer:tap];
    
    [self initMotionManager];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchMoved");
    if(touches.count == 1)
    {
        UITouch *touch = [touches allObjects].firstObject;
        if(touch.phase == UITouchPhaseMoved)
        {
            CGPoint location = [touch locationInView:self.view];
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@1,@([NSString stringWithFormat:@"%.1f",location.x].floatValue),@([NSString stringWithFormat:@"%.1f",location.y].floatValue)] forKeys:@[@"date_type",@"location_x",@"location_y"]];
            [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
        }
        else
        {
            return;
        }
    }
}

- (void)initMotionManager
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.showsDeviceMovementDisplay = YES;
    self.motionManager.deviceMotionUpdateInterval = 1.0/30.0;
    if (([CMMotionManager availableAttitudeReferenceFrames] & CMAttitudeReferenceFrameXTrueNorthZVertical) != 0)
    {
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame: CMAttitudeReferenceFrameXTrueNorthZVertical
                                                           toQueue: [NSOperationQueue mainQueue]
                                                       withHandler: ^(CMDeviceMotion *motion, NSError *error)
         {
             double roll = CC_RADIANS_TO_DEGREES(motion.attitude.roll);
             double pitch = CC_RADIANS_TO_DEGREES(motion.attitude.pitch);
             double yaw = CC_RADIANS_TO_DEGREES(motion.attitude.yaw);
             //NSLog(@"roll : %.2f pitch : %.2f yaw : %.2f",roll,pitch,yaw);
             NSDictionary *motionAttitudeDict = [NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%.2f",roll],[NSString stringWithFormat:@"%.2f",pitch],[NSString stringWithFormat:@"%.2f",yaw],@4] forKeys:@[@"attitude_roll",@"attitude_pitch",@"attitude_yaw",@"date_type"]];
             [[OSCManager sharedInstance] sendPacketWithDictionary:motionAttitudeDict];
         }];
    }
    else
    {
        NSLog(@"DeviceMotion not Availabe!");
    }
    
    if([self.motionManager isGyroAvailable])
    {
        if([self.motionManager isGyroActive] == NO)
        {
            self.motionManager.gyroUpdateInterval = 1.0/30.0;
            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMGyroData *gyroData, NSError *error)
             {
                 double x = gyroData.rotationRate.x;
                 double y = gyroData.rotationRate.y;
                 double z = gyroData.rotationRate.z;
                 NSDictionary *motionGyroDict = [NSDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%.2f",x],[NSString stringWithFormat:@"%.2f",y],[NSString stringWithFormat:@"%.2f",z],@3] forKeys:@[@"gyro_x",@"gyro_y",@"gyro_z",@"date_type"]];
                 [[OSCManager sharedInstance] sendPacketWithDictionary:motionGyroDict];
             }];
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }


}

- (void)tapEvent:(id)sender
{
    // 发送点击事件
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    CGPoint location = [t locationInView:self.view];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@2,@([NSString stringWithFormat:@"%.1f",location.x].floatValue),@([NSString stringWithFormat:@"%.1f",location.y].floatValue)] forKeys:@[@"date_type",@"location_x",@"location_y"]];
    [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
