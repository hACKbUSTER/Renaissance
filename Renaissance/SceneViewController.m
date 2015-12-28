//
//  ViewController.m
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f)
#define radians(__ANGLE__) ( (__ANGLE__) * 3.14159265 ) / 180.0

#import "SceneViewController.h"
#import "OSCManager.h"
#include <CoreMotion/CoreMotion.h>

@import SceneKit;

@interface SceneViewController ()
{
    /**
     *  相机node
     */
    SCNNode *cameraNode;
    
    /**
     *  当前速度，需要转化为位移量
     */
    CGFloat speed;
    
    /**
     *  整体的node
     */
    SCNNode *geometryNode;
    
    /**
     *  全速前进？是否需要
     */
    BOOL fullSpeedMode;
    
    /**
     *  刷新frame的timer
     */
    NSTimer * frameUpateTimer;
    
    /**
     *  osc协议发送数据包的timer
     */
    NSTimer * oscTransmitTimer;
    /**
     *  区域编号
     */
    AreaId areaId;
    /**
     *  天气编号
     */
    WeatherId weather;
    
    BOOL hasReturnZero;
    
    NSInteger nodeArrayCount;
    
    NSInteger buildingMaxHeight;
    
    NSInteger fps;
    
    CGFloat maxHeight;
    CGFloat minHeight;
    
    TimeInDay timeInDay;
}

@property (nonatomic,strong) SCNView *sceneKitView;
@property (nonatomic,strong) SCNScene *sceneKitScene;
@property (nonatomic,strong) NSMutableArray *allNodeArray;
@property (nonatomic,strong) SCNNode *rainNode;
@property (nonatomic) int nodeCount;
@property (nonatomic,strong) SCNParticleSystem *rainParticle;
@property (nonatomic, strong) CMMotionManager *motionManager;


@property (nonatomic,strong)SCNSphere *sunSphereOuter;
@property (nonatomic,strong)NSTimer *sunExpandAnimationTimer;
@property (nonatomic,strong)SCNNode *sunSphereOuterNode;
@property (nonatomic) BOOL isSunAnimating;

@property (nonatomic,strong)NSMutableArray *cloudArray;
@property (nonatomic,strong)NSMutableArray *starArray;
@end

@implementation SceneViewController
@synthesize sceneKitView,sceneKitScene;
@synthesize allNodeArray,nodeCount;
@synthesize rainNode,rainParticle;
@synthesize sunSphereOuter,sunExpandAnimationTimer,sunSphereOuterNode,isSunAnimating;
@synthesize cloudArray,starArray;
@synthesize address,port;

- (void)rainParticleSystem
{
    rainParticle = [SCNParticleSystem particleSystem];
    rainParticle.loops = YES;
    SCNBox *rainShape = [SCNBox boxWithWidth:200 height:200 length:200 chamferRadius:0];
 
    rainParticle.particleImage = [UIImage imageNamed:@"rainParticle.png"];
    rainParticle.birthRate = 0;
    rainParticle.particleVelocity = 100;
    rainParticle.birthDirection = SCNParticleBirthDirectionConstant;
    rainParticle.spreadingAngle = 0;
    rainParticle.emittingDirection = SCNVector3Make(0, -radians(180), 0);
    rainParticle.emitterShape = rainShape;
    rainParticle.affectedByGravity = YES;
    rainParticle.particleSize = 5;
    //rainParticle.
    
    rainNode = [SCNNode node];
    rainNode.position = SCNVector3Make(0, 200, 0);
    [rainNode addParticleSystem:rainParticle];
    [cameraNode addChildNode:rainNode];
}

- (void)sunSystem
{

    NSLog(@"sunSystem SHOULD RUN ONLY  ONCE");
    sunSphereOuter = [SCNSphere sphereWithRadius:200];
    sunSphereOuter.segmentCount = 1;
    sunSphereOuterNode = [SCNNode nodeWithGeometry:sunSphereOuter];
    SCNMaterial *sunBlankMaterial = [SCNMaterial material];
    sunBlankMaterial.transparency = 0.0;
    sunBlankMaterial.doubleSided = YES;
    sunBlankMaterial.transparencyMode = SCNTransparencyModeAOne;
    sunSphereOuter.materials = @[sunBlankMaterial];
    sunSphereOuterNode.position = SCNVector3Make(0, 700, -3000);
    
    [sceneKitScene.rootNode addChildNode:sunSphereOuterNode];
    //[self sunExpandAnimation];
    
    isSunAnimating = NO;
    
}

- (void)sunExpandAnimation
{
    if (!isSunAnimating)
    {
        NSLog(@"sunExpandAnimation");
        sunSphereOuterNode.hidden = NO;
        isSunAnimating = YES;
        sunExpandAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(addSunSphereSegment) userInfo:nil repeats:YES];
    }
}

- (void)addSunSphereSegment
{
    NSLog(@"addSunSphereSegment : %ld",(long)sunSphereOuter.segmentCount);
    
    if ([(SCNSphere *)sunSphereOuterNode.geometry segmentCount] <=20)
    {
        [(SCNSphere *)sunSphereOuterNode.geometry setSegmentCount:[(SCNSphere *)sunSphereOuterNode.geometry segmentCount] + 1];
    }
    //sunSphereOuterNode.eulerAngles = SCNVector3Make(sunSphereOuterNode.eulerAngles.x, sunSphereOuterNode.eulerAngles.y+ radians(20), sunSphereOuterNode.eulerAngles.z);
    //sunSphereOuterNode.geometry = sunSphereOuter;
    if (sunSphereOuter.segmentCount >= 20)
    {
        [sunExpandAnimationTimer invalidate];
        isSunAnimating = NO;
    }
}

- (void)sunDestroyAnimation
{
    NSLog(@"sunDestroyAnimation");
    if (!isSunAnimating)
    {
        isSunAnimating = YES;
        sunExpandAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(minusSunSphereSegment) userInfo:nil repeats:YES];
    }

}

- (void)minusSunSphereSegment
{
    NSLog(@"minusSunSphereSegment");
    //sunSphereOuter.segmentCount = sunSphereOuter.segmentCount - 1;
    [(SCNSphere *)sunSphereOuterNode.geometry setSegmentCount:[(SCNSphere *)sunSphereOuterNode.geometry segmentCount] - 1];
    if (sunSphereOuter.segmentCount <= 2)
    {
        [sunExpandAnimationTimer invalidate];
        sunSphereOuterNode.hidden = YES;
        isSunAnimating = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //cloud
    cloudArray = [[NSMutableArray alloc] init];
    
    speed = 0.2f;
    areaId = AreaTrainStation;//AreaCity;
    nodeArrayCount = 120;
    buildingMaxHeight = 200;
    timeInDay = TimeMorning;
    weather = WeatherNormal;
    
    fullSpeedMode = YES;
    hasReturnZero = NO;
    
    [[OSCManager sharedInstance] setAddress:address];
    [[OSCManager sharedInstance] setPort:[port intValue]];
    [[OSCManager sharedInstance] connect];
    
    geometryNode = [SCNNode node];
    sceneKitView = [[SCNView alloc] initWithFrame:self.view.bounds];
    sceneKitScene = [SCNScene scene];
    sceneKitView.allowsCameraControl = NO;
    sceneKitView.jitteringEnabled = YES;
    sceneKitView.scene = sceneKitScene;
    sceneKitView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:sceneKitView];
    sceneKitView.autoenablesDefaultLighting = YES;
    sceneKitView.showsStatistics = NO;
    
    sceneKitView.debugOptions = SCNDebugOptionShowWireframe;
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 150, 150);
    cameraNode.eulerAngles = SCNVector3Make(radians(-30.0), 0, 0);
    
    [sceneKitView.scene.rootNode addChildNode:cameraNode];
    [sceneKitView setPointOfView:cameraNode];
    
    cameraNode.camera.zNear = 0.001;
    cameraNode.camera.zFar = 99999999;
    cameraNode.camera.yFov = 70.0;
    cameraNode.camera.xFov = 60.0;
    
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = [UIImage imageNamed:@"Black"];
    
    allNodeArray = [NSMutableArray array];
    for (int i = 0; i < nodeArrayCount; i++)
    {
        NSMutableArray *nodeArray = [NSMutableArray array];
        NSInteger count = arc4random()%4 + 2;
        for (int k = 0; k < count; k ++)
        {
            CGFloat height = (arc4random()%buildingMaxHeight + 10.0f);
            if(i>30 && i< 60)
            {
                // 屌爆了！
                height = 0.0f;
            }
            
            SCNBox *sceneKitBox = [SCNBox boxWithWidth:15 height:height length:15 chamferRadius:0.0f];
            sceneKitBox.materials = @[mat];
            SCNNode *boxNode = [SCNNode nodeWithGeometry:sceneKitBox];
            boxNode.hidden = YES;
            
            CGFloat nextX = -50.0f + arc4random()%100;
            
            boxNode.position = SCNVector3Make(nextX, -sceneKitBox.height - 10.0f, -(i + 3)*50);
            [geometryNode addChildNode:boxNode];
            [nodeArray addObject:boxNode];
            
        }
        [allNodeArray addObject:nodeArray];
    }
    
    SCNPlane *floor = [SCNPlane planeWithWidth:1000 height:30000];
    floor.widthSegmentCount = 10;
    floor.heightSegmentCount = 300;
    floor.materials = @[mat];
    
    SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.eulerAngles = SCNVector3Make(radians(-90), 0, 0);
    
    [geometryNode addChildNode:floorNode];
    //geometryNode.transform = SCNMatrix4MakeRotation(radians(0.0f),1,0,0);
    
    [sceneKitView.scene.rootNode addChildNode:geometryNode];
    
    nodeCount = 0;
    frameUpateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(frameUpdate:) userInfo:nil repeats:YES];
    fps = 0;
    oscTransmitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/15.0f target:self selector:@selector(uploadData:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
    [self.view addGestureRecognizer:tap];
    
    [self initMotionManager];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@(0),@(0),@(0),@(0),@(0),@0] forKeys:@[@"max_height",@"min_height",@"speed",@"area_id",@"weather",@"data_type"]];
    [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
    
    [self rainParticleSystem];
    [self sunSystem];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchMoved");
    if(touches.count == 1)
    {
        UITouch *touch = [touches allObjects].firstObject;
        if(touch.phase == UITouchPhaseMoved)
        {
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
    
//    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
//        cameraNode.eulerAngles = SCNVector3Make(0, -motion.attitude.yaw/5, 0);
//        cameraNode.position = SCNVector3Make(10*CC_RADIANS_TO_DEGREES(-motion.attitude.roll), cameraNode.position.y, cameraNode.position.z);
//    }];
    /**
     
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
     
     **/
    
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
    if (nodeCount == allNodeArray.count)
    {
        for(NSArray *array in allNodeArray)
        {
            for(SCNNode *node in array)
            {
                node.hidden = YES;
//                [(SCNMaterial *)node.geometry.materials.firstObject diffuse].contents = nil;
//                [(SCNMaterial *)node.geometry.materials.firstObject normal].contents = nil;
                [node removeFromParentNode];
            }
        }
        [CATransaction begin];
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.z"];
        positionAnimation.toValue = [NSNumber numberWithDouble:0.0f];
        positionAnimation.duration = 1.0;
        positionAnimation.removedOnCompletion = NO;
        positionAnimation.autoreverses = NO;
        positionAnimation.repeatCount = 1;
        positionAnimation.fillMode = kCAFillModeForwards;
        [CATransaction setCompletionBlock:^
         {
             //                 node.position = SCNVector3Make(SCNPosition.x, 2.0f, SCNPosition.z);
             // 可以把之前的node移除掉一些
             //node.position = NewSCNPosition;
         }];
        [geometryNode addAnimation:positionAnimation forKey:@"position.z"];
        [CATransaction commit];
        
//        geometryNode.position = SCNVector3Make(geometryNode.position.x,geometryNode.position.y,0.0f);
        [frameUpateTimer invalidate];
        [oscTransmitTimer invalidate];
        nodeCount = 0;
        return;
    }
    
    if(nodeCount >= nodeArrayCount - 22)
    {
        // 最后20个减速
        if(fullSpeedMode)
            fullSpeedMode = NO;
    }
    
    if(speed < 1.0f && fullSpeedMode)
        speed = speed + 0.05/60;
    
    if(speed > 0.0f && !fullSpeedMode)
        speed = speed - 0.05/60;
    
    fps++;
    if(speed >= 1.0f)
    {
        // 匀速状态
        geometryNode.position = SCNVector3Make(geometryNode.position.x,geometryNode.position.y,geometryNode.position.z + speed * 1.2f);
    }
    else
    {
       geometryNode.position = SCNVector3Make(geometryNode.position.x,geometryNode.position.y,geometryNode.position.z + speed * 1.0f);
    }
    
    if(floorf(fps/40) >= 1.0f/speed)
    {
        NSMutableArray *nodeArray = [allNodeArray objectAtIndex:nodeCount];
        maxHeight = 0.0f;
        
        SCNNode *box = (SCNNode *)nodeArray.firstObject;
        minHeight = [(SCNBox *)box.geometry height];
        
        if(minHeight > 0.0f)
        {
            CGFloat right = (50 + arc4random()%50);
            SCNNode *treeLeft = [self treeNodeWithPosition:right];
            SCNNode *treeRight = [self treeNodeWithPosition:-right];
            
            [geometryNode addChildNode:treeLeft];
            [nodeArray addObject:treeLeft];
            [geometryNode addChildNode:treeRight];
            [nodeArray addObject:treeRight];
        }
        
        for (SCNNode * node in nodeArray)
        {
            CGFloat height = [(SCNBox *)node.geometry height];
            if(height > 0.0f)
                node.hidden = NO;
            
            if(height >= maxHeight)
                maxHeight = height;
            
            if(height <= minHeight && height > 0.0f)
                minHeight = height;

            
            [CATransaction begin];
            CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
            positionAnimation.toValue = [NSNumber numberWithDouble:10.0f];
//            positionAnimation.toValue = [NSNumber numberWithDouble:height];
            positionAnimation.duration = 1.0;
            positionAnimation.removedOnCompletion = NO;
            positionAnimation.autoreverses = NO;
            positionAnimation.repeatCount = 1;
            positionAnimation.fillMode = kCAFillModeForwards;
            [CATransaction setCompletionBlock:^
             {
//                 node.position = SCNVector3Make(SCNPosition.x, 2.0f, SCNPosition.z);
                 // 可以把之前的node移除掉一些
                 //node.position = NewSCNPosition
                 
                 if (nodeCount >= 20)
                 {
                     NSMutableArray *nodeArray = [allNodeArray objectAtIndex:(nodeCount - 20)];
                     for(SCNNode *node in nodeArray)
                     {
//                         [(SCNMaterial *)node.geometry.materials.firstObject diffuse].contents = nil;
//                         [(SCNMaterial *)node.geometry.materials.firstObject normal].contents = nil;
                         [node removeAllAnimations];
                         [node removeFromParentNode];
                     }
                 }
                 
             }];
            [node addAnimation:positionAnimation forKey:@"geometry.height"];
            [CATransaction commit];
        }
        nodeCount ++;
        NSLog(@"node count plus to:%d",nodeCount);
        fps = 0;
    }
    
    
    if (weather == WeatherWindy)
    {
        if (arc4random()%4 == 1)
        {
            SCNBox *cloudBox = [SCNBox boxWithWidth:20 height:2 length:20 chamferRadius:0];
            SCNNode *cloudBoxNode = [SCNNode nodeWithGeometry:cloudBox];
            cloudBoxNode.position = SCNVector3Make(-150.0+arc4random()%300, 150 + arc4random()%100, -(nodeCount + 3)*50);
            SCNMaterial *cloudBlankMaterial = [SCNMaterial material];
            cloudBlankMaterial.transparency = 0.0;
            //cloudBlankMaterial.transparent.contents = [UIImage imageNamed:@"Black"];
            cloudBox.materials = @[cloudBlankMaterial];
            [geometryNode addChildNode:cloudBoxNode];
            [cloudArray addObject:cloudBoxNode];
        }
        
    }
    
    if (timeInDay == TimeNight)
    {
        if (arc4random()%10 == 1)
        {
            SCNCone *starCone = [SCNCone coneWithTopRadius:1 bottomRadius:3 height:2];
            SCNNode *star = [SCNNode nodeWithGeometry:starCone];
            star.position = SCNVector3Make(-300.0 + arc4random()%600, 200.0+arc4random()%60, -(nodeCount + 8)*50);
            SCNMaterial *starMaterial = [SCNMaterial material];
            starMaterial.transparency = 0.0;
            starMaterial.transparencyMode = SCNTransparencyModeAOne;
            starCone.radialSegmentCount = 3;
            [geometryNode addChildNode:star];
            [starArray addObject:star];
        }
    }
    
    if (weather != WeatherWindy)
    {
        if(cloudArray.count > 0)
        {
            for (SCNNode* cloud in cloudArray)
            {
                [cloud removeFromParentNode];
            }
            [cloudArray removeAllObjects];
        }
    }
    
    if (timeInDay != TimeNight)
    {
        if(starArray.count > 0)
        {
            for (SCNNode* star in starArray)
            {
                [star removeFromParentNode];
            }
            [starArray removeAllObjects];
        }
    }

}

- (void)nightAnimationBegin
{
    
    
}

- (void)tapEvent:(id)sender
{
    // 发送点击
    
    
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    CGPoint location = [t locationInView:self.view];
    
    if(location.y <= self.view.frame.size.height /2.0f)
    {
        // tap top part
        if(timeInDay == TimeMorning)
        {
            if (!isSunAnimating)
            {
                timeInDay = TimeNoon;
                [self sunExpandAnimation];
            }
        }
        else if(timeInDay == TimeNoon)
        {
            if (!isSunAnimating)
            {
                timeInDay = TimeNight;
                [self sunDestroyAnimation];
            }
        }
        else if(timeInDay == TimeNight)
        {
            timeInDay = TimeMorning;
        }
    }
    else
    {
        // tap bottom part
        if(weather == WeatherNormal)
        {
            weather = WeatherRainy;
            if(rainParticle.birthRate <= 0.0f)
            {
                // 进入下雨情景
                rainParticle.birthRate = 200.0f;
            }
        }
        else if(weather == WeatherRainy)
        {
            weather = WeatherWindy;
            if(rainParticle.birthRate > 0.0f)
            {
                rainParticle.birthRate = 0.0f;
            }
        }
        else if(weather == WeatherWindy)
        {
            weather = WeatherNormal;
            if(rainParticle.birthRate > 0.0f)
            {
                rainParticle.birthRate = 0.0f;
            }
        }
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@2,@([NSString stringWithFormat:@"%.1f",location.x].floatValue),@([NSString stringWithFormat:@"%.1f",location.y].floatValue)] forKeys:@[@"date_type",@"location_x",@"location_y"]];
    //[[OSCManager sharedInstance] sendPacketWithDictionary:dict];
}

- (void)uploadData:(id)sender
{
    if (nodeCount == allNodeArray.count)
    {
        return;
    }
    else
    {        
        NSInteger area_id = areaId;
        NSInteger time_day = timeInDay;
        
        if(!hasReturnZero)
        {
            hasReturnZero = YES;
            area_id = 0;
            time_day = 0;
        }
        
        [[OSCManager sharedInstance] sendPacketWithPattern:[NSString stringWithFormat:@"/weather/min_height/speed/data_type/max_height/area_id/time"] Value:@[@(weather),@(minHeight/2.0f),@(speed),@5,@(maxHeight/2.0f),@(area_id),@(time_day)]];
    }
}


//- (UIImage *) imageWithView:(UIView *)view
//{
//    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return img;
//}


- (SCNNode *)treeNodeWithPosition:(CGFloat)treePositionX
{
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = [UIImage imageNamed:@"Black"];
    
    SCNCylinder *sceneKitTreeCylinder = [SCNCylinder cylinderWithRadius:4 height:10];
    sceneKitTreeCylinder.materials = @[mat];
    
    SCNNode *treeCylinderNode = [SCNNode nodeWithGeometry:sceneKitTreeCylinder];

    SCNCone *sceneKitTreeCone = [SCNCone coneWithTopRadius:0.1 bottomRadius:8 height:20];
    sceneKitTreeCone.materials = @[mat];
    
    sceneKitTreeCone.radialSegmentCount = 4 + arc4random()%2;
    sceneKitTreeCylinder.radialSegmentCount = 0 + arc4random()%2;
    SCNNode *treeConeNode = [SCNNode nodeWithGeometry:sceneKitTreeCone];
    SCNNode *treeNode = [SCNNode node];
    [treeNode addChildNode:treeCylinderNode];
    treeCylinderNode.position = SCNVector3Make(0, 0, 0);
    treeConeNode.position = SCNVector3Make(0, 10, 0);
    [treeNode addChildNode:treeConeNode];
    
    treeNode.position = SCNVector3Make(treePositionX, -40.0f, -(nodeCount + 5)*50);
    return treeNode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)RollWithDenominator:(int)denominator
{
    return 0 == arc4random_uniform(denominator);
}

-(BOOL)prefersStatusBarHidden { return YES; }

@end
