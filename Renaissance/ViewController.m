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

@import SceneKit;

double radians(float degrees) {
    return ( degrees * 3.14159265 ) / 180.0;
}

@interface ViewController ()
{
    SCNNode *cameraNode;
    CGFloat speed;
    SCNNode *geometryNode;
    BOOL fullSpeedMode;
    NSTimer * frameUpateTimer;
    
    NSTimer * oscTransmitTimer;
    NSInteger areaId;
    NSInteger weather;
}

@property (nonatomic,strong) SCNView *sceneKitView;
@property (nonatomic,strong) SCNScene *sceneKitScene;
@property (nonatomic,strong) NSMutableArray *allNodeArray;
@property (nonatomic,strong) NSTimer * timer;

@property (nonatomic) int nodeCount;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation ViewController
@synthesize sceneKitView,sceneKitScene;
@synthesize allNodeArray,nodeCount,timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    speed = 0.0f;
    areaId = 1;
    fullSpeedMode = NO;
    
    [[OSCManager sharedInstance] setAddress:@"169.254.172.171"];
    [[OSCManager sharedInstance] setPort:7400];
    
    geometryNode = [SCNNode node];
    sceneKitView = [[SCNView alloc] initWithFrame:self.view.bounds];
    sceneKitScene = [SCNScene scene];
    sceneKitView.allowsCameraControl = NO;
    sceneKitView.jitteringEnabled = YES;
    sceneKitView.scene = sceneKitScene;
    sceneKitView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:sceneKitView];
    sceneKitView.autoenablesDefaultLighting = YES;
    sceneKitView.showsStatistics = YES;
    
    sceneKitView.debugOptions = SCNDebugOptionShowWireframe;
    
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 150, 150);
    cameraNode.eulerAngles = SCNVector3Make(radians(-45.0), 0, 0);
    
    [sceneKitView.scene.rootNode addChildNode:cameraNode];
    [sceneKitView setPointOfView:cameraNode];
    
    cameraNode.camera.zNear = 0.001;
    cameraNode.camera.zFar = 99999999;
    cameraNode.camera.yFov = 60.0;
    cameraNode.camera.xFov = 60.0;
    
    allNodeArray = [NSMutableArray array];
    for (int i = 0; i < 1000; i++)
    {
        NSMutableArray *nodeArray = [NSMutableArray array];
        for (int k = 0; k < 3; k ++)
        {
            //NSLog(@"NUMBER %d",i);
            SCNBox *sceneKitBox = [SCNBox boxWithWidth:15 height:(arc4random()%100 + 10) length:15 chamferRadius:0.0f];
            SCNNode *boxNode = [SCNNode nodeWithGeometry:sceneKitBox];
            
            boxNode.hidden = YES;
            
            CGFloat nextX = (k-1) * 40 + -50.0f + arc4random()% (k * 40);

            boxNode.position = SCNVector3Make(nextX,-sceneKitBox.height - 10, -i*50);
            [geometryNode addChildNode:boxNode];
            [nodeArray addObject:boxNode];
        }
        [allNodeArray addObject:nodeArray];
    }
    
    SCNMaterial *mat = [SCNMaterial material];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.geometryFlipped = YES;
    
    mat.diffuse.contents = [self imageWithView:view];
    
    SCNPlane *floor = [SCNPlane planeWithWidth:10000 height:10000];
    floor.widthSegmentCount = 100;
    floor.heightSegmentCount = 100;
    //floor.reflectivity = 0.0f;
    floor.materials = @[mat];
    
    SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.eulerAngles = SCNVector3Make(radians(-90), 0, 0);
    
    [geometryNode addChildNode:floorNode];
    //geometryNode.transform = SCNMatrix4MakeRotation(radians(0.0f),1,0,0);
    
    [sceneKitView.scene.rootNode addChildNode:geometryNode];
    
    nodeCount = 0;
    timer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(buildingLevelUp) userInfo:nil repeats:YES];
    frameUpateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(frameUpdate:) userInfo:nil repeats:YES];
    oscTransmitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/15.0f target:self selector:@selector(uploadData:) userInfo:nil repeats:YES];
    
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
//            CGPoint now = [touch locationInView:(SCNView *)self.view];
//            CGPoint prev = [touch previousLocationInView:(SCNView *)self.view];
//            CGFloat translation_y = now.y - prev.y;
//            NSLog(@"change in y :%f",translation_y);
            CGPoint now = [touch locationInView:(SCNView *)self.view];
            CGPoint prev = [touch previousLocationInView:(SCNView *)self.view];
            CGFloat translation_y = now.y - prev.y;
            NSLog(@"change in y :%f",translation_y);
            geometryNode.position = SCNVector3Make(geometryNode.position.x,geometryNode.position.y,geometryNode.position.z - translation_y);
            
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
    self.motionManager.showsDeviceMovementDisplay = NO;
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
             //[[OSCManager sharedInstance] sendPacketWithDictionary:motionAttitudeDict];
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
                 //[[OSCManager sharedInstance] sendPacketWithDictionary:motionGyroDict];
             }];
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
}

- (void)frameUpdate:(id)sender
{
    geometryNode.position = SCNVector3Make(geometryNode.position.x,geometryNode.position.y,geometryNode.position.z + speed * 1.5f);
    
}

- (void)tapEvent:(id)sender
{
    // 发送点击事件
    if(fullSpeedMode)
    {
        fullSpeedMode = NO;
    }
    else
    {
        fullSpeedMode = YES;
    }
    
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    CGPoint location = [t locationInView:self.view];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@2,@([NSString stringWithFormat:@"%.1f",location.x].floatValue),@([NSString stringWithFormat:@"%.1f",location.y].floatValue)] forKeys:@[@"date_type",@"location_x",@"location_y"]];
    [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
}

- (void)uploadData:(id)sender
{
    if (nodeCount == allNodeArray.count)
    {
        [timer invalidate];
        nodeCount = 0;
    }
    else
    {
        NSMutableArray *nodeArray = [allNodeArray objectAtIndex:nodeCount];
        NSLog(@"%lu",(unsigned long)nodeArray.count);
        
        CGFloat maxHeight = 0.0f;
        SCNNode *t_node = nodeArray.firstObject;
        CGFloat minHeight = [(SCNBox *)t_node.geometry height];
        
        for (SCNNode * node in nodeArray)
        {
            CGFloat height = [(SCNBox *)node.geometry height];
            
            if(height >= maxHeight)
                maxHeight = height;
            
            if(height <= minHeight)
                minHeight = height;
        }
        
        if(speed <= 0.9f)
        {
            speed = speed + 0.0005 * nodeCount;
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@(maxHeight),@(minHeight),@(speed),@(areaId),@(1),@5] forKeys:@[@"max_height",@"min_height",@"speed",@"area_id",@"weather",@"data_type"]];
        [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
    }
}

- (void)buildingLevelUp
{
    if (nodeCount == allNodeArray.count)
    {
        for(NSArray *array in allNodeArray)
        {
            for(SCNNode *node in array)
            {
                [node removeFromParentNode];
            }
        }
        [timer invalidate];
        nodeCount = 0;
    }else
    {
        NSMutableArray *nodeArray = [allNodeArray objectAtIndex:nodeCount];
        NSLog(@"%lu",(unsigned long)nodeArray.count);
        for (SCNNode * node in nodeArray)
        {
            SCNVector3 SCNPosition = node.position;
            if(SCNPosition.y >= 0)
            {
                continue;
            }
            
            node.hidden = NO;
            
            [CATransaction begin];
            CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
            positionAnimation.toValue = [NSNumber numberWithDouble:2.0f];
            positionAnimation.duration = 1.0;
            positionAnimation.removedOnCompletion = NO;
            positionAnimation.autoreverses = NO;
            positionAnimation.repeatCount = 1;
            positionAnimation.fillMode = kCAFillModeForwards;
            [CATransaction setCompletionBlock:^
             {
                 //node.position = NewSCNPosition;
             }];
            [node addAnimation:positionAnimation forKey:@"position.z"];
            [CATransaction commit];
        }
        nodeCount ++;
    }
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
