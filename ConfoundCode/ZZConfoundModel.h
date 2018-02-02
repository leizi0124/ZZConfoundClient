//
//  ZZConfoundModel.h
//  MacDemo
//
//  Created by JB-Mac on 2018/1/31.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSInteger, ZZModelType) {
    ZZPropertyType = 0,
    ZZOtherType,
};
@interface ZZConfoundModel : NSObject
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) ZZModelType modelType;
@end
