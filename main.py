import os

from file_operate.funcs import move_play_file

from file_operate import change_config
from grsim_operate import grsim

PATH = "../kun_latast/Kun2/ZBin/"
TestPATH = "../kun_latast/Kun2/ZBin/lua_scripts/play/Test/"
ConfigFilePATH = "../kun_latast/Kun2/ZBin/lua_scripts/Config.lua"


def Athena_open():
    os.system(PATH + "Athena")

def Set_lua(play_name):
    change_config.change_test_mode(True, ConfigFilePATH)
    change_config.add_to_gTestPlayTable(play_name, ConfigFilePATH)
    move_play_file('plays', TestPATH, play_name)


# funcs.print_file(ConfigFilePATH)
grsim.reset()
    
# print_file(ConfigFilePATH)