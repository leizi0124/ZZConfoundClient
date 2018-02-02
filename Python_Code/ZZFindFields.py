#!/usr/bin/env python
#coding=utf8
import os
import json
import re

#属性名
property_name_list = []
#普通属性名
normal_pro_name_list = []
#类名
class_name_list = []
#字典key值
dict_key_list = []
#方法名提取
method_name_list = []
#文件路径
path_array = []

config_path = os.path.expanduser(r"~/Desktop/Confound/SelectConfoundFiles.txt")

with open(config_path) as file:
    content = file.read()
    path_array = json.loads(content)

if len(path_array) <= 0:
    print []
    exit()

#查找混淆内容
def findconfoundfields(file_path):
    with open(file_path) as file:
        lines = file.readlines()

        for line_content in lines:

            if "@property" in line_content:     #@property  变量名

                find_list = re.search("^@property\s*\(.+?\)\s*\w+\s*\*?\s*(\w+?);", line_content)

                if not find_list == None:
                    if not find_list.group(1) == None:
                            # print '属性名',find_list.group(1)
                            if not find_list.group(1) in property_name_list:
                                property_name_list.append(find_list.group(1))

            elif '@interface' in line_content:      #类名 @interface JBSDKPopOption : UIView
                find_list = re.search("^@interface\s+(\w+?)\s*:\s*\w+$", line_content)
                if not find_list == None:
                    if not find_list.group(1) == None:
                        # print '类名',find_list.group(1)
                        if not find_list.group(1) in class_name_list:
                            class_name_list.append(find_list.group(1))

            else:

                #普通属性  UIImageView *arrowView;
                find_list = re.search("^\s*(\w+?)\s*\*\s*(\w+?);$", line_content)
                if not find_list == None:
                    if not find_list.group(1) == None and not find_list.group(2) == None:
                        if not find_list.group(1) == 'return':
                            normal_pro_name = find_list.group(2)
                            if normal_pro_name[0] == '_':
                                normal_pro_name = normal_pro_name.replace('_','')

                            if not normal_pro_name in normal_pro_name_list:
                                normal_pro_name_list.append(normal_pro_name)

                #查字典key值
                find_list = re.search("@\"([\w\d]+?)\"", line_content)
                if not find_list == None:
                    if not find_list.group(1) == None:
                        if not find_list.group(1) in dict_key_list:
                            dict_key_list.append(find_list.group(1))

                #方法名 无参数或一个参数 - (void)JBSDKLoginCallBack;
                find_list = re.search("^\s*-\s*\(\w+?\)\s*(\w+)", line_content)
                if not find_list == None:
                    if not find_list.group(1) == None:
                        if not find_list.group(1) in method_name_list:
                            method_name_list.append(find_list.group(1))

                # 方法名 两个参数 - (void)JBSDKLoginCallBack:(BOOL)loginState uid:(NSString *)uid token:(NSString *)token;
                find_list = re.search("^\s*-\s*\(.+?\)\s*\w+?\s*:\s*\(\w+?\)\s*\w+?\s+?(\w+?):\(.*?\)\s*\w+?\s*[;{]$", line_content)
                if not find_list == None:
                    if not find_list.group(1) == None:

                        if not find_list.group(1) in method_name_list:
                            method_name_list.append(find_list.group(1))

                #换行后的方法名
                # + (void)phoneRegister:(NSString *)phoneNum
                # password:(NSString *)password
                # code:(NSString *)code
                find_list = re.search("^\s*(\w+?)\s*:\s*\(.+?\)\s*\w+\s*;?$",line_content)
                if not find_list == None:
                    if not find_list.group(1) == None:

                        if not find_list.group(1) in method_name_list:
                            method_name_list.append(find_list.group(1))


for file_path in path_array:
    findconfoundfields(file_path)

ex_clude_list = ['allocWithZone','copyWithZone','dealloc','viewDidLoad','shouldAutorotate','supportedInterfaceOrientations','preferredInterfaceOrientationForPresentation',
                 'didReceiveMemoryWarning','prefersStatusBarHidden','viewDidAppear','textFieldShouldReturn','touchesBegan','viewWillAppear','viewWillDisappear','alertView',
                 'tableView','initWithStyle','reuseIdentifier','numberOfSectionsInTableView','layoutSubviews','setSelected','animated','setValue','numberOfComponentsInPickerView',
                 'layout','initWithFrame','init','textFieldWillEditing','webViewDidFinishLoad','image','show','webView','webViewDidStartLoad','length','charset','srcLen',
                 'destBytes','destLen','textViewShouldBeginEditing','option_setupPopOption','_setupParams','_tapGesturePressed','JSONObject','password','description','pickView',
                 'pickerView','state','array','rightView','leftViewRectForBounds','rightViewRectForBounds','textRectForBounds']

# results = property_name_list + normal_pro_name_list + class_name_list + method_name_list + ex_clude_list
ex_clude_list = ex_clude_list + dict_key_list

#property属性名
return_property_name_list = []
for confound_name in property_name_list:
    if not confound_name in ex_clude_list:
        return_property_name_list.append(confound_name)

#其他字段
other_list = normal_pro_name_list + class_name_list + method_name_list
return_other_list = []
for confound_name in other_list:
    if not confound_name in ex_clude_list:
        return_other_list.append(confound_name)

return_result = {'propertyname' : return_property_name_list,
                 'othername' : return_other_list}

json_result = json.dumps(return_result, ensure_ascii=False, encoding='UTF-8')

print json_result
