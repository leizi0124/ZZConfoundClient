//
//  ZZPathModel.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/30.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "ZZPathModel.h"

@implementation ZZPathModel
- (instancetype)init {
    if (self = [super init]) {
        self.filesArray = [NSMutableArray array];
        self.dirsArray = [NSMutableArray array];
    }
    return self;
}
@end
