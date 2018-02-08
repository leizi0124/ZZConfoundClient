#!/usr/bin/env python
#coding=utf8
import os
import json
import re

#文件路径
all_m_files = []
#失败数
failure_num = 0
#正则失败数
re_failure_num = 0

config_path = os.path.expanduser(r"~/Desktop/Confound/SelectConfoundFiles.txt")
with open(config_path) as file:
    content = file.read()
    all_m_files = json.loads(content)

find_file = False
config_file = ''
for m_file in all_m_files:
    if ".xcodeproj" in m_file:
        config_file = m_file
        find_file = True
        break

if find_file == False:
    json_result = json.dumps({"failure_num": failure_num, "re_failure_num": re_failure_num, "result": "0" ,"xcode_file" : "0"}, ensure_ascii=False, encoding='UTF-8')
    print json_result
    exit()

new_file_index = 1
old_name_list = []
new_name_list = []

file_count = 0

for m_file in all_m_files:
    if os.path.splitext(m_file)[1] == '.m' or os.path.splitext(m_file)[1] == '.mm':

        if not 'Test' in m_file:
            file_count += 1
            old_file_name = re.search("/(\w+?\+?\w+?)\.m{1,2}$", m_file)
            if not old_file_name == None:
                old_re_name = old_file_name.group(1) +'.m'
                new_name = "aaaaaaaa" + str(new_file_index) +'.m'
                old_name_list.append(old_re_name)
                new_name_list.append(new_name)
                new_file_name = m_file.replace(old_re_name, new_name)
                try:
                    os.rename(os.path.join(m_file), os.path.join(new_file_name))
                except:
                    failure_num = failure_num + 1

                new_file_index += 1
            else:
                re_failure_num = re_failure_num + 1

#修改配置文件
with open(config_file) as config_content_file:
    config_content = config_content_file.read()
    for index, old_name in enumerate(old_name_list):
        config_content = config_content.replace(old_name, new_name_list[index])

file_object = open(config_file, 'w')
file_object.write(config_content)
file_object.close()
json_result = json.dumps({"failure_num": failure_num, "re_failure_num": re_failure_num, "result": "1" ,"xcode_file" : "1"}, ensure_ascii=False, encoding='UTF-8')
print json_result
