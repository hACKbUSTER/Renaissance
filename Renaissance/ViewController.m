//
//  ViewController.m
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//

#import "ViewController.h"
#import "OSCManager.h"

@interface ViewController ()
@property (nonatomic, strong) F53OSCClient *oscClient;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[OSCManager sharedInstance] setAddress:@"169.254.172.171"];
    [[OSCManager sharedInstance] setPort:7400];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchMoved");
    if(touches.count == 1)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[@5,@"test string!",@5.34] forKeys:@[@"test1",@"test2",@"test3"]];
        [[OSCManager sharedInstance] sendPacketWithDictionary:dict];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
