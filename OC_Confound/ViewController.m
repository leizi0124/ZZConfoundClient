//
//  ViewController.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/19.
//  Copyright © 2018年 MacDemo. All rights reserved.
//
#import "ViewController.h"
#import "Tools.h"
#import "ZZFileTableView.h"
#import "ZZConfoundVC.h"
#import "ZZConfoundModel.h"
@interface ViewController ()
@property (nonatomic, copy) NSString *workPath;             //工作路径
@property (nonatomic, copy) NSString *productPath;          //生产路径
@property (nonatomic, copy) NSArray *rootPaths;             //生产路径
@property (nonatomic, strong) NSView *documentView;
@property (nonatomic, assign) NSInteger pageNumber;         //页数
@property (nonatomic, assign) NSInteger maxPages;           //最大页数
@end
@implementation ViewController

- (void)viewDidLoad {
    self.title = @"oc代码混淆工具";
    [super viewDidLoad];
    
    self.pageNumber = 0;
    
    self.documentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.pathScrollView.frame.size.width, self.pathScrollView.frame.size.height)];
    self.pathScrollView.documentView = self.documentView;
    
    for (NSInteger index = 0; index < 10; index++) {
        ZZFileTableView *tableview = [[ZZFileTableView alloc] initWithFrame:NSMakeRect(self.pathScrollView.frame.size.width * index, 0, self.pathScrollView.frame.size.width, self.pathScrollView.frame.size.height)];
        tableview.tableLevel = index + 1;
        tableview.delegate = self;
        [self.pathScrollView.contentView addSubview:tableview];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allTableReload) name:RELOAD_ALL_TABLE object:nil];
}
#pragma mark - 选择工作路径
- (IBAction)selectWorkPathAction:(NSButton *)sender {
    
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    
    __weak __typeof(self)weakSelf = self;
    
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            weakSelf.workPath = openPanel.URL.path;
            
            [[Tools sharedInstance].rootModel.filesArray removeAllObjects];
            [[Tools sharedInstance].rootModel.dirsArray removeAllObjects];
            
            [Tools findDirsModel:[Tools sharedInstance].rootModel rootFile:openPanel.URL.path];
            
            ZZFileTableView *zzTableview = [weakSelf getTableWithLevel:1];
            [zzTableview updateWith:[Tools sharedInstance].rootModel];
            [self defaultSetting];
            
            [Tools sharedInstance].selectPathChange = YES;
        }
    }];
}
#pragma mark - 默认位置及配置
- (void)defaultSetting {
    self.maxPages = 1;
    self.documentView.frame = NSMakeRect(0, 0, self.pathScrollView.frame.size.width, self.pathScrollView.frame.size.height);
    [self.pathScrollView.contentView scrollPoint:NSMakePoint(0, 0)];
}
#pragma mark - 选中文件夹
- (void)selectedFolder:(ZZPathModel *)pathModel tableview:(ZZFileTableView *)tableview {
    
    self.pageNumber = tableview.tableLevel;
    self.maxPages = tableview.tableLevel;
    self.documentView.frame = NSMakeRect(0, 0, self.pathScrollView.frame.size.width * (tableview.tableLevel + 1), self.pathScrollView.frame.size.height);
    
    ZZFileTableView *subTableview = [self getTableWithLevel:tableview.tableLevel + 1];
    [subTableview updateWith:pathModel];
    [self.pathScrollView.contentView scrollPoint:NSMakePoint(self.pathScrollView.frame.size.width * tableview.tableLevel, 0)];
}
#pragma mark - 上一页
- (IBAction)previousPageAction:(NSButton *)sender {
    
    self.pageNumber --;
    self.previousPageBtn.enabled = YES;
    self.nextPageBtn.enabled = YES;
    if (self.pageNumber <= 0) {
        self.pageNumber = 0;
        self.previousPageBtn.enabled = NO;;
    }
    [self.pathScrollView.contentView scrollPoint:NSMakePoint(self.pathScrollView.frame.size.width * self.pageNumber, 0)];
}
#pragma mark - 下一页
- (IBAction)nextPageAction:(id)sender {
    
    self.pageNumber ++;
    self.nextPageBtn.enabled = YES;
    self.previousPageBtn.enabled = YES;
    if (self.pageNumber >= self.maxPages) {
        self.pageNumber = self.maxPages;
        self.nextPageBtn.enabled = NO;
    }
    
    [self.pathScrollView.contentView scrollPoint:NSMakePoint(self.pathScrollView.frame.size.width * self.pageNumber, 0)];
}
#pragma mark - 刷新所有tableview
- (void)allTableReload {
    for (NSView *subview in self.pathScrollView.contentView.subviews) {
        
        if ([subview.className isEqualToString:@"ZZFileTableView"]) {
            ZZFileTableView *tableView = (ZZFileTableView *)subview;
            [tableView reload];
        }
    }
}
#pragma mark - 根据level获取tableview
- (ZZFileTableView *)getTableWithLevel:(NSInteger)level {
    
    ZZFileTableView *tableView = nil;
    
    for (NSView *subview in self.pathScrollView.contentView.subviews) {
        
        if ([subview.className isEqualToString:@"ZZFileTableView"]) {
            tableView = (ZZFileTableView *)subview;
            
            if (tableView.tableLevel == level) {
                break;
            }
        }
    }
    return tableView;
}
#pragma mark - 混淆字段筛选
- (IBAction)okBtnAction:(NSButton *)sender {
    
    [self buildConfoundNameFile];
    
    if (![Tools sharedInstance].confoundArray.count) {
        [self showAlert:@"未选择文件"];
        return;
    }
    
    ZZConfoundVC *confoundVC = [[ZZConfoundVC alloc] init];
    [self presentViewControllerAsModalWindow:confoundVC];
}
#pragma mark - 生成混淆文件
- (IBAction)buildConfoundFile:(NSButton *)sender {
    
    [self buildConfoundNameFile];
    
    if (![Tools sharedInstance].confoundArray.count) {
        [self showAlert:@"未选择文件"];
        return;
    }
    
    NSMutableArray *selectedPropertyArray = [NSMutableArray array];
    NSMutableArray *selectedOtherArray = [NSMutableArray array];
    
    BOOL canConfound = NO;
    
    for (ZZConfoundModel *model in [Tools sharedInstance].confoundArray) {
        if (model.isSelected) {
            if (model.modelType == ZZPropertyType) {
                [selectedPropertyArray addObject:model.title];
            }else {
                [selectedOtherArray addObject:model.title];
            }
            
            canConfound = YES;
        }
    }
    
    if (!canConfound) {
        [self showAlert:@"没有需要混淆的字段"];
        return;
    }
    
    [self writeByFileName:@"SelectConfoundNames.txt" content:@{@"propertyname" : selectedPropertyArray, @"othername" : selectedOtherArray}];
    
    NSInteger pyResult = [[self runpyWithName:@"ZZBuildConfound"] integerValue];
    
    if (pyResult == 10000) {
        [self showAlert:@"混淆文件已生成！"];
    }else {
        [self showAlert:@"混淆文件生成失败！"];
    }
}
#pragma mark - 根据路径查找混淆字段
- (void)buildConfoundNameFile {
    
    if ([Tools sharedInstance].selectPathChange) {
        
        [Tools sharedInstance].selectPathChange = NO;
        NSArray *allPaths = [Tools getAllSelectedPath];
        [self writeByFileName:@"SelectConfoundFiles.txt" content:allPaths];
        
        NSString *pyResult = [self runpyWithName:@"ZZFindFields"];
        
        NSDictionary *confoundDict = [NSJSONSerialization JSONObjectWithData:[pyResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        
        [[Tools sharedInstance].confoundArray removeAllObjects];
        
        for (NSString *confoundName in confoundDict[@"propertyname"]) {
            ZZConfoundModel *model = [[ZZConfoundModel alloc] init];
            model.title = confoundName;
            model.isSelected = YES;
            model.modelType = ZZPropertyType;
            [[Tools sharedInstance].confoundArray addObject:model];
        }
        
        for (NSString *confoundName in confoundDict[@"othername"]) {
            ZZConfoundModel *model = [[ZZConfoundModel alloc] init];
            model.title = confoundName;
            model.isSelected = YES;
            model.modelType = ZZOtherType;
            [[Tools sharedInstance].confoundArray addObject:model];
        }
    }
}
#pragma mark - 更新配置文件
- (void)writeByFileName:(NSString *)fileName content:(id)content {
    //获取桌面路径/Users/jb-mac/Desktop/JBSDK_webpay_dev/JBSDK
//    NSString*bundel=[[NSBundle mainBundle] resourcePath];
//    NSString*deskTopLocation=[[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];

    NSString *deskTopLocation = [NSString stringWithFormat:@"/Users/%@/Desktop",NSUserName()];
    NSString *filePath = [deskTopLocation stringByAppendingString:[NSString stringWithFormat:@"/Confound/%@", fileName]];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager createDirectoryAtPath:[deskTopLocation stringByAppendingString:@"/Confound"] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        
        [self showAlert:@"文件操作失败"];
        return;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        
        [self showAlert:@"文件操作失败"];
        return;
    }
    
    //Data转换为JSON
    NSString *contentJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [manager createFileAtPath:filePath contents:[contentJson dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}
#pragma mark - 文件操作失败提示
- (void)showAlert:(NSString *)message {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
}
#pragma mark - 运行python文件
- (NSString *)runpyWithName:(NSString *)pyName {
    
    NSString *pyScriptPath = [[NSBundle mainBundle] pathForResource:pyName ofType:@"py"];
    NSTask *pythonTask = [[NSTask alloc]init];
    [pythonTask setLaunchPath:@"/bin/bash"];
    NSString *pyStr = [NSString stringWithFormat:@"python %@",pyScriptPath];
    
    [pythonTask setArguments:[NSArray arrayWithObjects:@"-c",pyStr, nil]];
    
    NSPipe *pipe = [[NSPipe alloc]init];
    [pythonTask setStandardOutput:pipe];
    
    [pythonTask launch];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return strReturnFromPython;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_ALL_TABLE object:nil];
}
@end
