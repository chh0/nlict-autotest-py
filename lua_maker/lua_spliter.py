import re

def split_lua_play(PATH):

    end1 = 100000
    end2 = 100000

    with open(PATH, "r") as f:
        lines = f.readlines()

    for i in range(len(lines)):
        if re.match(r'^\s*firstState\s*=', lines[i]):
            end1 = i
            # print(lines[end1])

    part1 = lines[:end1]
    firstState_line = lines[end1]

    for i in range(end1, len(lines)):
        if re.match(r'^\s*name\s*=', lines[i]):
            end2 = i

    part2 = lines[end1+1: end2]
    name_line = lines[end2]
    part3 = lines[end2+1:]


    if end1 == 100000:
        print("[ lua_spliter.py ] err in find end1")
    if end2 == 100000:
        print("[ lua_spliter.py ] err in find end2")

    return {
        "part1":part1,
        "part2":part2,
        "part3":part3,
        "firstState_line":firstState_line,
        "name_line":name_line
    }

def print_lines(lines):
    for i in lines:
        print(i, end="")

def print_lua_dict(lua_dict):
    print_lines(lua_dict["part1"])
    print("=====  ==============================  ==================")
    print(lua_dict["firstState_line"], end="")
    print("=====  ==============================  ==================")
    print_lines(lua_dict["part2"])
    print("=====  ==============================  ==================")
    print(lua_dict["name_line"], end="")
    print("=====  ==============================  ==================")
    print_lines(lua_dict["part3"])

print_lua_dict(split_lua_play("autotest0.lua"))