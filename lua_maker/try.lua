-- local x = (ppp == nil)
-- local y = (x == nil)
-- print(x)
-- print(y)


-- local file = assert(io.open("xxx.txt", 'a'), 'Error loading file');
-- file:write("e21edwefwefewf\n")
-- file:close()

-- local file = assert(io.open("xxxx.txt", 'r'), 'Error loading file');
-- print(file == nil)

function try(func)
    local success, result = pcall(func)
    if success then
        return result
    else
        return nil, result -- return nil and error message
    end
end

-- example usage
function my_func()
    local file = assert(io.open("xxx.txt", 'r'), 'Error loading file')
    return file
end

local result, err = try(my_func)

if not result then
    print("Error occurred: ")
else
    print("Result: ")
end
