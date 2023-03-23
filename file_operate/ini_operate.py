# import configparser

# config = configparser.ConfigParser()		
# config.read("config.ini")
# login = config['LOGIN']
# server = config['SERVER']

# config = configparser.ConfigParser()
# if not config.has_section("INFO"):
#     config.add_section("INFO")
#     config.set("INFO", "link", "www.codeforests.com")
#     config.set("INFO", "name", "ken")
# if not config.has_section("LOGIN"):
#     config.add_section("LOGIN")
#     config.set("LOGIN", "link", "www.codeforests.com")
#     config.set("LOGIN", "name", "ken")

# with open("example.ini", 'w') as configfile:
#     config.write(configfile)

import configparser

# def read_ini(PATH):
#     config = configparser.ConfigParser()
#     config.read(PATH)
#     print(dict(config))

# read_ini("config.ini")

'''
dict should be like
{
    'LOGIN': {
        'key1': 'value1',
        'key2': 'value2'
    },
    ...
}
'''
def write_ini(PATH, dict):
    config = configparser.ConfigParser()
    for key in dict:
        if not config.has_section(key):
            config.add_section(key)
            for key1 in dict[key]:
                config.set(key, key1, dict[key][key1])
    with open(PATH, 'w') as configfile:
        config.write(configfile)

    # if not config.has_section("INFO"):
    #     config.add_section("INFO")
    #     config.set("INFO", "link", "www.codeforests.com")
    #     config.set("INFO", "name", "ken")
    # if not config.has_section("LOGIN"):
    #     config.add_section("LOGIN")
    #     config.set("LOGIN", "link", "www.codeforests.com")
    #     config.set("LOGIN", "name", "ken")

# for i in {'qwe':'123', 'fed':'12332'}:
#     print(i)
def main():
    dict = {
        'LOGIN': {
            'key1': 'value1',
            'key2': 'value2'
        },
    }
    write_ini('rrr.ini', dict)

if __name__ == '__main__':
    main()