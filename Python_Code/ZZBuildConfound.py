#!/usr/bin/env python
#coding=utf8

import os
import json
import random

property_name_list = []
other_name_list = []
define_ok_list = []
define_rand_list = []

def writeDefineFile():
    global property_name_list
    global other_name_list
    global define_ok_list

    write_file_path = os.path.expanduser(r"~/Desktop/Confound/ZZConfuseDefine.h")

    confound_name_path = os.path.expanduser(r"~/Desktop/Confound/SelectConfoundNames.txt")

    if not os.path.exists(confound_name_path):
        print '10001'
        exit()

    with open(confound_name_path) as select_confound:

        content = select_confound.read()
        names_dict = json.loads(content)
        property_name_list = names_dict['propertyname']
        other_name_list = names_dict['othername']

    if os.path.exists(write_file_path):
        os.remove(write_file_path)

    with open(write_file_path, 'w+') as define_file:
        
        #property 变量
        define_file.write("//将该文件导入工程，在需要混淆的文件中引入，或者全局引入。\n\n//property变量:" + str(len(property_name_list)) + "\n")
        for property_name in property_name_list:
            if not property_name in define_ok_list:

                #随机字符串
                rand_name = randString()
                up_property_name = uperFirstString(property_name)
                up_rand_name = uperFirstString(rand_name)

                #添加去重
                define_ok_list.append(property_name)
                define_ok_list.append('_' + property_name)
                define_ok_list.append('set' + up_property_name)

                #编辑格式
                define_content = "# ifndef " + property_name + "\n" + "# define " + property_name + " " + rand_name + "\n" + "# endif" + "\n"
                define_content += "# ifndef " + '_' + property_name + "\n" + "# define " + '_' + property_name + ' ' + "_" + rand_name + "\n" + "# endif" + "\n"
                define_content += "# ifndef " + 'set' + up_property_name + "\n" + "# define " + 'set' + up_property_name + " " + 'set' + up_rand_name + "\n" + "# endif" + "\n\r"

                #写入文件
                define_file.write(define_content)

        #其他字段
        define_file.write("//其他字段:" + str(len(other_name_list)) + "\n")
        for other_name in other_name_list:
            if not other_name in define_ok_list:
                define_ok_list.append(other_name)
                define_content = "# ifndef " + other_name + "\n" + "# define " + other_name + " " + randString() + "\n" + "# endif" + "\n\r"
                define_file.write(define_content)

#随机字符串
def randString():
    global define_rand_list
    rand_list = ['a','b','c','d','e','f','g','h','i','z','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    ran_str = ''.join(random.sample(rand_list, 8))

    while ran_str in define_rand_list:
        ran_str = ''.join(random.sample(rand_list, 8))

    define_rand_list.append(ran_str)

    return ran_str

#首字母转大写
def uperFirstString(up_string):
    first_zm = up_string[0]
    up_string = first_zm.upper() + up_string[1:]
    return up_string

writeDefineFile()
print '10000'