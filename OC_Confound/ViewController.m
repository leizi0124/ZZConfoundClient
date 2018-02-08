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
        [Tools showAlert:@"未选择文件" inView:self.view];
        return;
    }
    
    ZZConfoundVC *confoundVC = [[ZZConfoundVC alloc] init];
    [self presentViewControllerAsModalWindow:confoundVC];
}
#pragma mark - 生成混淆文件
- (IBAction)buildConfoundFile:(NSButton *)sender {
    
    [self setNormalConfound];
    
    [self buildConfoundNameFile];
    
    if (![Tools sharedInstance].confoundArray.count) {
        [Tools showAlert:@"未选择文件" inView:self.view];
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
        [Tools showAlert:@"没有需要混淆的字段" inView:self.view];
        return;
    }
    
    BOOL result = [Tools writeByFileName:@"SelectConfoundNames.txt" content:@{@"propertyname" : selectedPropertyArray, @"othername" : selectedOtherArray}];
    
    if (!result) {
        [Tools showAlert:@"文件操作失败" inView:self.view];
        return;
    }
    
    NSInteger pyResult = [[self runpyWithName:@"ZZBuildConfound"] integerValue];
    
    if (pyResult == 10000) {
        [Tools showAlert:@"混淆文件已生成！~/Desktop/Confound" inView:self.view];
    }else {
        [Tools showAlert:@"混淆文件生成失败！" inView:self.view];
    }
}
#pragma mark - 根据路径查找混淆字段
- (void)buildConfoundNameFile {
    
    if ([Tools sharedInstance].selectPathChange) {
        
        [Tools sharedInstance].selectPathChange = NO;
        NSArray *allPaths = [Tools getAllSelectedPath];
        BOOL result = [Tools writeByFileName:@"SelectConfoundFiles.txt" content:allPaths];
        
        if (!result) {
            [Tools showAlert:@"文件操作失败" inView:self.view];
            return;
        }
        
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
#pragma mark - 将默认设置写入配置
- (void)setNormalConfound {
    
    NSString *customConfound = [[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_CONFOUNDS];
    NSArray *confoundArray= [customConfound componentsSeparatedByString:@","];
    BOOL confoundResult = [Tools writeByFileName:@"customConfounds.txt" content:confoundArray];
    
    if (!confoundResult) {
        
        [Tools showAlert:@"自定义混淆字段文件操作失败" inView:self.view];
    }
    
    NSString *customFilter = [[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_FILTERS];
    NSArray *FilterArray= [customFilter componentsSeparatedByString:@","];
    BOOL filterResult = [Tools writeByFileName:@"customFilters.txt" content:FilterArray];
    
    if (!filterResult) {
        
        [Tools showAlert:@"自定义过滤字段文件操作失败" inView:self.view];
    }
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
#pragma mark - 文件名混淆
- (IBAction)confoundFilesName:(NSButton *)sender {
    
    [self buildConfoundNameFile];
    
    if (![Tools sharedInstance].confoundArray.count) {
        [Tools showAlert:@"未选择文件" inView:self.view];
        return;
    }
    
    BOOL findConfigFile = NO;
    
    for (NSString *filePath in [Tools getAllSelectedPath]) {
        if ([filePath rangeOfString:@"project.pbxproj"].location != NSNotFound) {
            findConfigFile = YES;
            break;
        }
    }
    
    if (!findConfigFile) {
        [Tools showAlert:@"失败，请勾选 xxx.xcodeproj 配置文件！" inView:self.view];
        return;
    }
    
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定混淆"];
    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:@"文件名混淆会修改配置文件,建议在分支上进行!"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1000) {
            
            NSString *result = [self runpyWithName:@"ZZFileNameConfound"];
            NSDictionary *confoundDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            
            if ([confoundDict[@"result"] integerValue] == 1) {
                
                [Tools showAlert:@"文件名混淆成功！" inView:self.view];
            }else {
                
                NSInteger re_failure_num = [confoundDict[@"re_failure_num"] integerValue];
                NSInteger failure_num = [confoundDict[@"failure_num"] integerValue];
                NSString *message = [NSString stringWithFormat:@"文件名混淆失败！\n正则失败数：%zd\n混淆失败数：%zd",re_failure_num,failure_num];
                [Tools showAlert:message inView:self.view];
            }
        }
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_ALL_TABLE object:nil];
}
@end
