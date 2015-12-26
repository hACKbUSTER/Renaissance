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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[OSCManager sharedInstance] setAddress:@"169.254.172.171"];
    [[OSCManager sharedInstance] setPort:7400];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
    [self.view addGestureRecognizer:tap];
    
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
