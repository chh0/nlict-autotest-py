from .funcs import get_file_in_lines 
from .funcs import write_lines_to_files
import re  

def change_test_mode(is_test_mode, ConfigFilePATH):
    lines = get_file_in_lines(ConfigFilePATH)
    for i in lines:
        if 'IS_TEST_MODE' in i:
            break
    index = lines.index(i)
    if is_test_mode and 'false' in i:
        i = re.sub("false", "true", i)
    if not is_test_mode and 'true' in i:
        i = re.sub("true", "false", i)
    lines[index] = i
    write_lines_to_files(lines, ConfigFilePATH)

def add_to_gTestPlayTable(play_name, ConfigFilePATH):
    lines = get_file_in_lines(ConfigFilePATH)
    for i in lines:
        if 'Test/TestWs' in i:
            break
    index = lines.index(i)
    line = re.sub("TestWs", play_name, i)
    lines.insert(index, line)
    write_lines_to_files(lines, ConfigFilePATH)



# move_play_file('TEMP/', '.', 'xx.lua')

# ConfigFilePATH = 'TEMP/Config.lua'
# change_test_mode(False, PATH)
# add_to_gTestPlayTable('???', ConfigFilePATH)
# str = "214213ewxyz@gmail.com"
# print(re.sub("[a-z]*@", "abc@", str))