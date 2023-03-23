-- local str = "1  2  3"
-- -- str = string.gsub(str, "%s*", "")
-- str = string.gsub(str, '^%s*(.-)%s*$', '%1')
-- print(str)

local function tableContains(tbl, element)
    for _, v in ipairs(tbl) do
        if (rawequal(v, element)) then
            return true;
        end
    end
    return false;
end
    

local x = {'123','234','345','456'}
-- print(x)
-- for i,k in pairs(x) do
--     print(i)
--     print(k);
-- end


-- print(tableContains(x, "000"))

-- table.insert(x, "000")



-- print(x)

-- print(x)
-- for i,k in pairs(x) do
--     print(i)
--     print(k);
-- end
-- print(tableContains(x, "000"))
print(not not(1>2))