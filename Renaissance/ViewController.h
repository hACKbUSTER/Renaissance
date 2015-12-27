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
    TimeMorning,
    TimeNoon,
    TimeNight
};

typedef NS_ENUM(NSInteger, AreaId) {
    AreaCity,
    AreaTrainStation,
    AreaRiver
};

typedef NS_ENUM(NSInteger, WeatherId) {
    WeatherNormal,
    WeatherRainy,
    WeatherWindy,
};

@interface ViewController : UIViewController

@end

