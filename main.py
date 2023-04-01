# import os

# from file_operate.funcs import move_play_file
# from grsim_operate import grsim
# from file_operate import change_config
# from file_operate import ini_operate

# PATH = "../kun_latast/Kun2/ZBin/"
# LuaFilePATH = PATH + "lua_scripts/"
# TestPATH = LuaFilePATH + "play/Test/"
# ConfigFilePATH = LuaFilePATH + "Config.lua"

# def Athena_open():
#     os.system(PATH + "Athena")

# ini_data = {
#     'MAIN':{
#         'yellow':"autotest_blue",
#         'blue':"autotest_yellow",
#     }
# }

# def Set_ini(PATH, dict):
#     ini_operate.write_ini(PATH, dict)

# def Init_Lua():
#     move_play_file('plays', TestPATH, "GoRectangle.lua")
#     move_play_file('plays', TestPATH, "GoRectangle.lua")
#     Set_ini(LuaFilePATH+'chenv.ini', ini_data) 


# TODO get info from Config.lua done
#      move play file here done
#      do essential changes
#      put generated file into Test/ done
#
#      launch both side of medusa --done
#
#      find a way to do grsim reset

# if __name__ == "__main__":
#     grsim.reset("scene1")













import os
import threading
import time
import re
import socket

UDP_IP = "127.0.0.1"
UDP_PORT = 24333
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

from grsim_operate import grsim

PATH = "/home/zjunlict/chh/kun_latast/Kun2/ZBin/"

def r():
    os.system("./open_medusa.sh")

def start_medusa():
    os.system("pkill Medusa")
    s1 = threading.Thread(target=r)
    s2 = threading.Thread(target=r)
    s1.start()
    time.sleep(3)
    s2.start()

def kill_medusa():
    os.system("pkill Medusa")

# "NUNIUND = 'r23ewr33r'" in lines
# get_value("NUNIUND", lines) to get 'r23ewr33r'
def get_value(attr, lines):
    for i in lines:
        parts = re.split("( |=|'|\"|\n)", i)
        parts = [p for p in parts if p not in (' ', '=', "'", '"', '\n') and p]
        # print(parts)
        if len(parts) > 1 and parts[0] == attr:
            if parts[1] == "true":
                return True
            elif parts[1] == "false":
                return False
            else:
                return parts[1]
    return -1

def find_play(name):
    dir_path = PATH + "lua_scripts/play"
    for root, dirs, files in os.walk(dir_path):
        if name+'.lua' in files:
            file_path = os.path.join(root, name+'.lua')
            return file_path
    else:
        return ""

def change_play_name(PATH, original, new):
    flag = False
    with open(PATH, "r") as f:
        lines = f.readlines()
    for i in range(len(lines)):
        if "name" in lines[i] and original in lines[i]:
            flag = True
            lines[i] = lines[i].replace(original, new)
            break
    with open(PATH, "w") as f:
        f.writelines(lines)
    if flag:
        return 1
    return 0

def add_send_state_line(PATH):
    with open(PATH, "r") as f:
        lines = f.readlines()
    end1 = -1
    end2 = -1
    for i in range(len(lines)):
        if re.match(r'^\s*firstState\s*=', lines[i]):
            end1 = i
    for i in range(end1, len(lines)):
        if re.match(r'^\s*name\s*=', lines[i]):
            end2 = i
    if end1 == -1 or end2 == -1:
        print("err in finding firstState")
        return 0
    switchs = []
    state_names = []
    flag = 0
    for i in range(end2-1, end1, -1):
        if re.match(r'^\s*switch\s*=\s*function\s*\(\s*\)', lines[i]):
            switchs.append(i)
            if flag == 1:
                print("err in finding state switch function")
                return 0
            flag = 1
        if flag:
            m = re.match('\s*\["', lines[i])
            if m:
                begin = m.span()[1]
                end = lines[i][m.span()[1]:].index("\"") + m.span()[1]
                n = re.match(r'"\]\s*=\s*{', lines[i][end:])
                # print(n, lines[i][end:])
                if n:
                    state_names.append(lines[i][begin:end])
                    flag = 0
    spaces = "\t\t\t"
    for i in range(len(switchs)):
        lines.insert(switchs[i]+1, spaces + "autest:H_Send_String(atest.y_or_b()..\"[STATE] in [" + state_names[i] + "] \")\n")

    with open(PATH, "w") as f:
        f.writelines(lines)
    return 1


def main():
    ## Init

    # check if athena running
    not_Athena_running = os.system("ps cax | grep Athena")
    if not_Athena_running:
        print("haven't launched athena yet")
        return
    
    # get info from config.lua
    with open(PATH + "lua_scripts/Config.lua", "r") as f:
        lines = f.readlines()
    IS_TEST_MODE = get_value("IS_TEST_MODE", lines)
    USE_AUTO_TEST = get_value("USE_AUTO_TEST", lines)
    AUTO_TEST_B = get_value("AUTO_TEST_B", lines)
    AUTO_TEST_Y = get_value("AUTO_TEST_Y", lines)
    if -1 in [IS_TEST_MODE, USE_AUTO_TEST, AUTO_TEST_B, AUTO_TEST_Y]:
        print("load config err!")
        return
    if not IS_TEST_MODE or not USE_AUTO_TEST:
        print("config setting err")
        return

    # get given play path from name
    path_blue = find_play(AUTO_TEST_B)
    path_yellow = find_play(AUTO_TEST_Y)
    if not path_blue or not path_yellow:
        print("find play err")
        return
    
    # pull file and rename
    os.system("cp " + path_blue + " ./temp/AUTO_TEST_B.lua")
    os.system("cp " + path_yellow + " ./temp/AUTO_TEST_Y.lua")

    # add something into lua script
    b_changed = change_play_name("./temp/AUTO_TEST_B.lua", AUTO_TEST_B, "AUTO_TEST_B")
    y_changed = change_play_name("./temp/AUTO_TEST_Y.lua", AUTO_TEST_Y, "AUTO_TEST_Y")
    if not b_changed or not y_changed:
        print("change name err")
        return

    b_changed = add_send_state_line("./temp/AUTO_TEST_B.lua")
    y_changed = add_send_state_line("./temp/AUTO_TEST_Y.lua")
    if not b_changed or not y_changed:
        print("change name err")
        return

    # put file back into lua_scripts
    os.system("cp ./temp/AUTO_TEST_B.lua " + PATH + "lua_scripts/play/Test/AUTO_TEST_B.lua")
    os.system("cp ./temp/AUTO_TEST_Y.lua " + PATH + "lua_scripts/play/Test/AUTO_TEST_Y.lua")

    ## Main cycle
    # start grsim

    # load scene
    grsim.reset("scene1")

    # start medusa
    start_medusa()

    # doing cycle
    max_cycle = 10
    cnt_cycle = 0
    while True:
        data, addr = sock.recvfrom(1024)
        message = data.decode()
        print(message)
        if "RESET" in message:
            cnt_cycle += 1
            print("cycle count: ", cnt_cycle)
            grsim.reset("scene1")
            time.sleep(3)
        if cnt_cycle >= max_cycle:
            break


    # end medusa
    kill_medusa()

    


if __name__ == "__main__":
    main()
    pass


# PATH = "temp/AUTO_TEST_B.lua"
# with open(PATH, "r") as f:
#     lines = f.readlines()
# end1 = -1
# end2 = -1
# for i in range(len(lines)):
#     if re.match(r'^\s*firstState\s*=', lines[i]):
#         end1 = i
# for i in range(end1, len(lines)):
#     if re.match(r'^\s*name\s*=', lines[i]):
#         end2 = i
# switchs = []
# state_names = []
# flag = 0
# for i in range(end2-1, end1, -1):
#     if re.match(r'^\s*switch\s*=\s*function\s*\(\s*\)', lines[i]):
#         switchs.append(i)
#         if flag == 1:
#             print("err in finding state switch function")
#         flag = 1
#     if flag:
#         m = re.match('\s*\["', lines[i])
#         if m:
#             begin = m.span()[1]
#             end = lines[i][m.span()[1]:].index("\"") + m.span()[1]
#             n = re.match(r'"\]\s*=\s*{', lines[i][end:])
#             # print(n, lines[i][end:])
#             if n:
#                 state_names.append(lines[i][begin:end])
#                 flag = 0
# spaces = "\t\t\t"
# for i in range(len(switchs)):
#     lines.insert(switchs[i]+1, spaces + "autest:H_Send_String(\"[STATE] in [" + state_names[i] + "] \")\n")
#     # print(lines[switchs[i]], end="")
#     # print(state_names[i])

# with open(PATH, "w") as f:
#     f.writelines(lines)

# for i in lines:
#     print(i, end="")
    


# res = os.system("ps cax | grep Athena")
# # res = os.system("ps cax | grep 'kworker/u64:2-events_unbound'")
# print (res)


# change_play_name("./temp/AUTO_TEST_B.lua", "TestMove3", "AUTO_TEST_B")

# dir_path = '/home/zjunlict/chh/kun_latast/Kun2/ZBin/lua_scripts/play'

# for root, dirs, files in os.walk(dir_path):
#     if 'TestMove3.lua' in files:
#         file_path = os.path.join(root, 'TestMove3.lua')
#         print('Found file:', file_path)
#         break
# else:
#     print('File not found in', dir_path)

# print(get_value("USE_AUTO_TEST", lines))
# print(get_value("IS_TEST_MODE", lines))
# print(get_value("AUTO_TEST_B", lines))
# print(get_value("AUTO_TEST_Y", lines))

# start_medusa()
# cnt = 0
# while True:
#     time.sleep(1)
#     print("x")
#     cnt+=1
#     if cnt == 10:
#         kill_medusa()
# time.sleep(15)
# print('...')
# s1.join()
# s2.join()
# print('...')
# ini_data = {
#     'MAIN':{
#         'yellow':"autotest_blue",
#         'blue':"autotest_yellow",
#     }
# }

# os.system(PATH + "Medusa")