
local x1 = 24443
local x2 = 43333
local x3 = "f4d423s4f"

local table1 = {
    x1 = 23,
    x2 = 43,
    x3 = "f4ds4f"
}


local write_names_to_file = function(param_table)
    for key,value in pairs(param_table) do
        print(key, value)
    end
end

local write_values_to_file = function(param_table)
    for key,value in pairs(param_table) do
        print(key, value)
    end
end

write_to_file(table1)
print(x1)
print(table1.x1)