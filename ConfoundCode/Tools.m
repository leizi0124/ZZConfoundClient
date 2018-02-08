//
//  Tools.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/23.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "Tools.h"
@interface Tools ()
@property (nonatomic, strong) NSMutableArray *selectedPaths;    //选中文件路径
@end
@implementation Tools
+ (instancetype)sharedInstance {
    static Tools *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[Tools alloc] init];
        tool.rootModel = [[ZZPathModel alloc] init];
        tool.selectedPaths = [NSMutableArray array];
        tool.confoundArray = [NSMutableArray array];
    });
    return tool;
}
#pragma mark - 判断路径性质
+ (ZZPathType)pathType:(NSString *)path {
    
    ZZPathType pathType =kPathTypeNil;
    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
    {
        // 存在
        if (isDir) {
            pathType = kPathTypeDir;
        } else {
            pathType = kPathTypeFile;
        }
    }
    
    return pathType;
}
+ (NSColor *)RGB:(NSString *)color {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return [NSColor clearColor];
    }
    
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [NSColor clearColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [NSColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
#pragma mark - 查找混淆路径
+ (void)findDirsModel:(ZZPathModel *)model rootFile:(NSString *)rootFile {
    
    model.rootPath = rootFile;
    NSArray *allfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootFile error:nil];
    for (NSString *subPath in allfiles) {
        NSString *subRootPath = [NSString stringWithFormat:@"%@/%@",rootFile,subPath];
        ZZPathType type = [Tools pathType:subRootPath];

        switch (type) {
            case kPathTypeFile:{//文件
                ZZPathModel *fileModel = [[ZZPathModel alloc] init];
                fileModel.rootPath = subRootPath;
                fileModel.title = subPath;
                fileModel.superTitle = model.title;
                [model.filesArray addObject:fileModel];
            }
                break;
            case kPathTypeDir:{//文件夹
                ZZPathModel *dirModel = [[ZZPathModel alloc] init];
                dirModel.rootPath = subRootPath;
                dirModel.title = subPath;
                dirModel.isDir = YES;
                dirModel.superTitle = model.title;
                [model.dirsArray addObject:dirModel];
                [self findDirsModel:dirModel rootFile:dirModel.rootPath];
            }
                break;
            default:
                break;
        }
    }
}
#pragma mark - 选中所有子目录
+ (void)subfiles:(ZZPathModel *)model selectState:(BOOL)selectState {
    
    if (model.isDir) {

        for (ZZPathModel *subModel in model.filesArray) {
            subModel.isSelected = selectState;
        }
        for (ZZPathModel *subModel in model.dirsArray) {
            [self subfiles:subModel selectState:selectState];
        }
    }
        
    model.isSelected = selectState;
    
    NSString *superPathString = [model.rootPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",[Tools sharedInstance].rootModel.rootPath] withString:@""];
    superPathString = [superPathString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",model.title] withString:@""];
    NSArray *superDirTitles = [superPathString componentsSeparatedByString:@"/"];
    
    for (NSInteger index = 0; index < superDirTitles.count; index++) {
        if (selectState) {//选中文件
            NSString *superDirTitle = superDirTitles[superDirTitles.count - 1 - index];
            ZZPathModel *superDirModel = [self findModelWith:superDirTitle rootModel:[Tools sharedInstance].rootModel];
            
            BOOL subfilesAllSelected = YES;
            
            if (superDirModel) {
                for (ZZPathModel *brotherModel in superDirModel.filesArray) {
                    if (!brotherModel.isSelected) {
                        subfilesAllSelected = NO;
                        break;
                    }
                }
                for (ZZPathModel *brotherModel in superDirModel.dirsArray) {
                    if (!brotherModel.isSelected) {
                        subfilesAllSelected = NO;
                        break;
                    }
                }
                if (subfilesAllSelected) {
                    superDirModel.isSelected = YES;
                }
            }
        }else {//取消选中文件
            NSString *superDirTitle = superDirTitles[index];
            
            ZZPathModel *superDirModel = [self findModelWith:superDirTitle rootModel:[Tools sharedInstance].rootModel];
            
            if (superDirModel) {
                superDirModel.isSelected = NO;
            }
            
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_ALL_TABLE" object:nil];
}
#pragma mark - 按title查找对象
+ (ZZPathModel *)findModelWith:(NSString *)title rootModel:(ZZPathModel *)rootModel {

    for (ZZPathModel *dirModel in rootModel.dirsArray) {
        
        if ([dirModel.title isEqualToString:title]) {
            return dirModel;
        }else {
            ZZPathModel *result = [self findModelWith:title rootModel:dirModel];
            if (result) {
                return result;
            }
        }
    }
    
    return nil;
}
#pragma mark - 获取所有选中路径
+ (NSArray *)getAllSelectedPath {
    [[Tools sharedInstance].selectedPaths removeAllObjects];
    
    [self modelSelectedPath:[Tools sharedInstance].rootModel];
    
    return [Tools sharedInstance].selectedPaths;
}
#pragma mark - 获取model选中路径
+ (void)modelSelectedPath:(ZZPathModel *)model {

    for (ZZPathModel *fileModel in model.filesArray) {
        if (fileModel.isSelected) {
            [[Tools sharedInstance].selectedPaths addObject:fileModel.rootPath];
        }
    }
    for (ZZPathModel *dirModel in model.dirsArray) {
        [self modelSelectedPath:dirModel];
    }
}
#pragma mark - 弹框提示
+ (void)showAlert:(NSString *)content inView:(NSView *)view {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:content];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[view window] completionHandler:nil];
}
#pragma mark - 相关配置文件操作
+ (BOOL)writeByFileName:(NSString *)fileName content:(id)content {
    
    NSString *deskTopLocation = [NSString stringWithFormat:@"/Users/%@/Desktop",NSUserName()];
    NSString *filePath = [deskTopLocation stringByAppendingString:[NSString stringWithFormat:@"/Confound/%@", fileName]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager createDirectoryAtPath:[deskTopLocation stringByAppendingString:@"/Confound"] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        
        return NO;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        
        return NO;
    }
    
    //Data转换为JSON
    NSString *contentJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [manager createFileAtPath:filePath contents:[contentJson dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}
@end
