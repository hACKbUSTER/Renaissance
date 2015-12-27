//
//  ViewController.h
//  Renaissance
//
//  Created by 叔 陈 on 15/12/26.
//  Copyright © 2015年 叔 陈. All rights reserved.
//

#import <UIKit/UIKit.h>

double radians(float degrees) {
    return ( degrees * 3.14159265 ) / 180.0;
}

typedef NS_ENUM(NSInteger, TimeInDay) {
    TimeMorning = 1,
    TimeNoon = 2,
    TimeNight = 3
};

typedef NS_ENUM(NSInteger, AreaId) {
    AreaCity = 1,
    AreaTrainStation = 2,
    AreaRiver = 3
};

typedef NS_ENUM(NSInteger, WeatherId) {
    WeatherNormal = 1,
    WeatherRainy = 2,
    WeatherWindy = 3,
};

@interface ViewController : UIViewController

@end

