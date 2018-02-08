//
//  Tools.h
//  MacDemo
//
//  Created by JB-Mac on 2018/1/23.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZPathModel.h"
#define RELOAD_ALL_TABLE @"RELOAD_ALL_TABLE"
#define ADD_NORMAL_CONFOUNDS @"ADD_NORMAL_CONFOUNDS"    //自定义混淆字段
#define ADD_NORMAL_FILTERS @"ADD_NORMAL_FILTERS"        //自定义过滤字段
typedef NS_OPTIONS(NSInteger, ZZPathType) {
    kPathTypeNil = 0,   //不存在路径
    kPathTypeFile,      //文件
    kPathTypeDir,       //文件夹
};

@interface Tools : NSObject
@property (nonatomic, strong) ZZPathModel *rootModel;           //文件路径
@property (nonatomic, strong) NSMutableArray *confoundArray;    //python返回混淆字段
@property (nonatomic, assign) BOOL selectPathChange;            //选中文件发生变化

+ (instancetype)sharedInstance;
+ (NSColor *)RGB:(NSString *)color;
//判断路径类型
+ (ZZPathType)pathType:(NSString *)path;
//查找混淆路径
+ (void)findDirsModel:(ZZPathModel *)model rootFile:(NSString *)rootFile;
//选中所有子目录
+ (void)subfiles:(ZZPathModel *)model selectState:(BOOL)selectState;
//获取所有选中路径
+ (NSArray *)getAllSelectedPath;
//弹框提示
+ (void)showAlert:(NSString *)content inView:(NSView *)view;
//配置文件相关操作 返回成功或者失败
+ (BOOL)writeByFileName:(NSString *)fileName content:(id)content;
@end
