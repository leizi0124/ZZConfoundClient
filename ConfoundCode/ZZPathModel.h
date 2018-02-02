//
//  ZZPathModel.h
//  MacDemo
//
//  Created by JB-Mac on 2018/1/30.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZPathModel : NSObject
@property (nonatomic, strong) NSMutableArray *filesArray;
@property (nonatomic, strong) NSMutableArray *dirsArray;
@property (nonatomic, copy)   NSString *rootPath;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *superTitle;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, assign) BOOL isSelected;
@end
