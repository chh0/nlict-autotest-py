import os

from file_operate.funcs import move_play_file

from file_operate import change_config
from grsim_operate import grsim
from file_operate import ini_operate

PATH = "../kun_latast/Kun2/ZBin/"
TestPATH = "../kun_latast/Kun2/ZBin/lua_scripts/play/Test/"
LuaFilePATH = "../kun_latast/Kun2/ZBin/lua_scripts/"
ConfigFilePATH = "../kun_latast/Kun2/ZBin/lua_scripts/Config.lua"

# 1st
# open Athena
def Athena_open():
    os.system(PATH + "Athena")


# 2nd
# init Athena


# 3rd
# init Lua script
ini_data = {
    'MAIN':{
        'yellow':"GoRectangle",
        'blue':"GoRectangle",
        'test':'true',
    }
}

def Set_ini(PATH, dict):
    ini_operate.write_ini(PATH, dict)

def Init_Lua():
    move_play_file('plays', TestPATH, "GoRectangle.lua")
    move_play_file('plays', TestPATH, "GoRectangle.lua")
    Set_ini(LuaFilePATH+'chenv.ini', ini_data) 
# funcs.print_file(ConfigFilePATH)
grsim.reset()

# 1st
# open Athena

# 2nd
# init Athena

# 3rd
# init Lua script

# 4th
# run medusa of both side

# 5th
# kill both side of medusa

# 6th
# end process


if __name__ == "__main__":
    Init_Lua()
    # move_play_file('plays', TestPATH, "TestMove2.lua")
    # move_play_file('plays', TestPATH, "messi_8v8.lua")
    # Set_ini(LuaFilePATH+'chenv.ini', ini_data) 


