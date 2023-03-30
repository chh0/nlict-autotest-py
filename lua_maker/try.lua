-- local x = (ppp == nil)
-- local y = (x == nil)
-- print(x)
-- print(y)


-- local file = assert(io.open("xxx.txt", 'a'), 'Error loading file');
-- file:write("e21edwefwefewf\n")
-- file:close()

-- local file = assert(io.open("xxxx.txt", 'r'), 'Error loading file');
-- print(file == nil)

-- function try(func)
--     local success, result = pcall(func)
--     if success then
--         return result
--     else
--         return nil, result -- return nil and error message
--     end
-- end

-- -- example usage
-- function my_func()
--     local file = assert(io.open("xxx.txt", 'r'), 'Error loading file')
--     return file
-- end

-- local result, err = try(my_func)

-- if not result then
--     print("Error occurred: ")
-- else
--     print("Result: ")
-- end

-- x = {
--     a=1,
--     b=2,
--     c = 3,
--     d = 4
-- }


-- function h_tabletostring(tbl)
--     res = ""
--     for key,value in pairs(tbl) do
--         res = res .. key .. " " .. value .. " "
--     end
--     res = res .. "\n"
--     return res
-- end

-- print(h_tabletostring(x))

-- define a sample table
-- local my_table = {a = 1, b = 2, c = 3, d = 4}

-- -- sort the keys
function h_tabletostring(tbl)
    local sorted_keys = {}
    res = ""
    for k, v in pairs(tbl) do
        table.insert(sorted_keys, k)
    end
    table.sort(sorted_keys)
    for i, k in ipairs(sorted_keys) do
        res = res .. k .. " " .. tbl[k] .. " "
    end
    return res
end

-- -- print(h_tabletostring(my_table))


local x = 1
local y = 2
local z = {
    x=x,
    y=y
}
-- local z = {x[1]=x, y=y}
print(h_tabletostring(z))
-- z["x[1]"] = 3
-- print(h_tabletostring(z))

-- print(os.date("%Y-%m-%d %H:%M:%S"))