//
//  IntroViewController.m
//  Renaissance
//
//  Created by Fincher Justin on 15/12/28.
//  Copyright © 2015年 叔 陈. All rights reserved.
//
#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "IntroViewController.h"
#import "SceneViewController.h"
@import SceneKit;


@interface IntroViewController ()<SCNSceneRendererDelegate>

@property (strong,nonatomic) SCNView * backgroundView;
@property (strong,nonatomic) SCNScene * introScene;
@property (strong,nonatomic) SCNNode *cameraNode;
@property (strong,nonatomic) SCNSphere * sunSphere;
@property (strong,nonatomic) SCNNode * sunSphereNode;
@property (nonatomic,strong)NSTimer *sunAnimationTimer;
@property (nonatomic)BOOL isSunAnimationTimer;

@property (strong,nonatomic) UITextField * IPTextField;
@property (strong,nonatomic) UITextField * PortTextField;
@property (strong,nonatomic) UIView * textFieldView;

@property (strong,nonatomic) UIButton *loginButton;

@end

@implementation IntroViewController
@synthesize backgroundView,loginButton;
@synthesize introScene,cameraNode;
@synthesize sunSphere,sunSphereNode;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackgoundView];
    [self setTextField];
}

- (void)setBackgoundView
{
    backgroundView = [[SCNView alloc] initWithFrame:self.view.bounds];
    backgroundView.allowsCameraControl = NO;
    backgroundView.jitteringEnabled = YES;
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundView];
    backgroundView.autoenablesDefaultLighting = YES;
    backgroundView.showsStatistics = NO;
    backgroundView.debugOptions = SCNDebugOptionShowWireframe;
    
    introScene = [SCNScene scene];
    self.backgroundView.scene = introScene;
    
    sunSphere = [SCNSphere sphereWithRadius:1000.0];
    sunSphere.segmentCount = 1;
    sunSphereNode = [SCNNode nodeWithGeometry:sunSphere];
    SCNMaterial *sunBlankMaterial = [SCNMaterial material];
    sunBlankMaterial.transparency = 0.0;
    sunBlankMaterial.doubleSided = YES;
    sunBlankMaterial.transparencyMode = SCNTransparencyModeAOne;
    sunSphere.materials = @[sunBlankMaterial];
    sunSphereNode.position = SCNVector3Make(0.0, 1200.0, -2500.0);
    self.sunAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(SunSphereSegment) userInfo:nil repeats:YES];
    self.isSunAnimationTimer = YES;
    [introScene.rootNode addChildNode:sunSphereNode];
    
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0.0, 150.0, 150.0);
    cameraNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0);
    
    [introScene.rootNode addChildNode:cameraNode];
    [backgroundView setPointOfView:cameraNode];
    cameraNode.camera.zNear = 0.001;
    cameraNode.camera.zFar = 99999999;
    cameraNode.camera.yFov = 70.0;
    cameraNode.camera.xFov = 60.0;
    
    
    SCNText *periscopeText = [SCNText textWithString:@"PERISCOPE" extrusionDepth:100.0f];
    periscopeText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:500];
    SCNNode *periscopeTextNode = [SCNNode node];
    SCNMaterial *periscopeTextNodeMaterial = [SCNMaterial material];
    periscopeTextNodeMaterial.transparency = 0.0;
    periscopeTextNodeMaterial.doubleSided = YES;
    periscopeTextNodeMaterial.transparencyMode = SCNTransparencyModeAOne;
    periscopeTextNodeMaterial.doubleSided = YES;
    periscopeText.materials = @[periscopeTextNodeMaterial];
    periscopeTextNode.geometry = periscopeText;
    periscopeTextNode.position = SCNVector3Make(-1250., -500.0, -2500.0);
    //periscopeTextNode.scale = SCNVector3Make(1, 1, 1);
    //[introScene.rootNode addChildNode:periscopeTextNode];
    
}

- (void)SunSphereSegment
{
    if (self.isSunAnimationTimer)
    {
        sunSphere.segmentCount ++;
        if (sunSphere.segmentCount > 20)
        {
            self.isSunAnimationTimer = NO;
        }
    }else
    {
        sunSphere.segmentCount --;
        if (sunSphere.segmentCount < 4)
        {
            self.isSunAnimationTimer = YES;
        }
    }
    
}

- (void)setTextField
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 50)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"PERISCOPE";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *IPLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 70, 60, 30)];
    //IPLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    IPLabel.textColor = [UIColor whiteColor];
    IPLabel.text = @"IP : ";
    IPLabel.textAlignment = NSTextAlignmentLeft;
    
    self.IPTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 70, 200, 30)];
    UIColor *whiteColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.IPTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"eg: 192.168.0.2" attributes:@{NSForegroundColorAttributeName: whiteColor}];
    self.IPTextField.textAlignment = NSTextAlignmentCenter;
    self.IPTextField.textColor = [UIColor whiteColor];
    self.IPTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.IPTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    UILabel *portLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 60, 30)];
    //IPLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    portLabel.textColor = [UIColor whiteColor];
    portLabel.text = @"Port : ";
    portLabel.textAlignment = NSTextAlignmentLeft;
    
    self.PortTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    self.PortTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"eg: 6400" attributes:@{NSForegroundColorAttributeName: whiteColor}];
    self.PortTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.PortTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.PortTextField.textAlignment = NSTextAlignmentCenter;
    self.PortTextField.textColor = [UIColor whiteColor];
    
    self.textFieldView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 320)/2, self.view.frame.size.height-280, 320, 280)];
    
    [self.textFieldView addSubview:self.IPTextField];
    [self.textFieldView addSubview:self.PortTextField];
    [self.textFieldView addSubview:titleLabel];
    [self.textFieldView addSubview:IPLabel];
    [self.textFieldView addSubview:portLabel];
    [self.view addSubview:self.textFieldView];
    
    
    UIImageView * buttonView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 280-62.5, 320, 62.5)];
    buttonView.image = [UIImage imageNamed:@"Button"];
    [self.textFieldView addSubview:buttonView];
    
    loginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 280-62.5, 320, 62.5)];
    [self.textFieldView addSubview:loginButton];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)login
{
    SceneViewController *VC = [[SceneViewController alloc] init];
    VC.address = self.IPTextField.text;
    VC.port = self.PortTextField.text;
    [self presentViewController:VC animated:YES completion:^(void){}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden { return YES; }

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
