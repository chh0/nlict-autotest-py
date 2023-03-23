import os

def print_file(PATH):
    with open(PATH, "r") as f:
        lines = f.readlines()
        for i in lines:
            print(i, end="")

def get_file_in_lines(PATH):
    with open(PATH, "r") as f:
        lines = f.readlines()
        return lines

def write_lines_to_files(lines, PATH):
    with open(PATH, "w") as f:
        for i in lines:
            f.write(i)

def move_play_file(Path0, Path1, file_name):
    os.system('cp ' + Path0 + '/' + file_name + ' ' + Path1 + '/' + file_name)


# lines = ['123', '234\n', '32543\n']
# write_lines_to_files(lines, '1.txt')

# def set_config_lua_test(PATH):
#     with open(PATH, "r") as f:
#         lines = f.readlines()

# txt = "The rain in Spain"
# x = re.search("^The.*Spain$", txt)
# print(x)

# txt = "The rain in Spain"
# x = re.findall("ai", txt)
# print(x)

# txt = "The rain in Spain"
# x = re.search("\s", txt)

# print(x.start())

# txt = "The rain in Spain"
# x = re.search("ins", txt)
# print(x)

# print('123' in '09876543')