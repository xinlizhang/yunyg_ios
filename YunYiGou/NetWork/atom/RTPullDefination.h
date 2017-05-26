//
//  RTPullDefination.h
//  PullVIew
//
//  Created by Sharon on 14-8-11.
//  Copyright (c) 2014年 OuyangRenshuang. All rights reserved.
//

#define DEFAULT_ARROW_IMAGE         [UIImage imageNamed:@"blueArrow.png"]
#define DEFAULT_BACKGROUND_COLOR    [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:0.0]
#define DEFAULT_TEXT_COLOR          [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define DEFAULT_ACTIVITY_INDICATOR_STYLE    UIActivityIndicatorViewStyleGray

#define FLIP_ANIMATION_DURATION 0.18f

#define PULL_AREA_HEIGTH 60.0f
#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)

#define aMinute 60
#define anHour 3600
#define aDay 86400

typedef enum{
    EGOOPullPulling = 0,
    EGOOPullNormal,
    EGOOPullLoading,
} EGOPullState;




