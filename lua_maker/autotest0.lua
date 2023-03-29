local RectanglePos  = {
	CGeoPoint:new_local(3000,2000),
	CGeoPoint:new_local(3000,-2000),
	CGeoPoint:new_local(-3000,-2000),
	CGeoPoint:new_local(-3000,2000),
}
local vel = CVector:new_local(0, 0)
local wait_time = 20
local DSS_FLAG = bit:_or(flag.allow_dss, flag.dodge_ball)

local CurrentPos = function()
	return function()
		return player.pos("Kicker")
	end
end

function show_rectangle_raw()
	debugEngine:gui_debug_line(RectanglePos[1],RectanglePos[2],4)
	debugEngine:gui_debug_line(RectanglePos[2],RectanglePos[3],4)
	debugEngine:gui_debug_line(RectanglePos[3],RectanglePos[4],4)
	debugEngine:gui_debug_line(RectanglePos[4],RectanglePos[1],4)
end


function WriteFile()
	local fileName = "/home/zjunlict/chh/kun_latast/temp/points.txt"
	local file = io.open("/home/zjunlict/chh/kun_latast/temp/points.txt","a+")
	local contents = ''
	contents = contents..tostring(player.posX("Kicker"))..','..tostring(player.posY("Kicker"))
	file:write(contents..'\n')
    file:close()
end


gPlayTable.CreatePlay{

------------------------------------------------------------------------------------------------------

firstState = "run1",


------------------------------------------------------------------------------------------------------

["run1"] = {
	switch = function()
		show_rectangle_raw()
		WriteFile()
		if bufcnt(player.toTargetDist("Kicker")<10,wait_time) then
			return "run"..2
		end
	end,
	Kicker = task.goCmuRush(RectanglePos[1],0, _, DSS_FLAG),
	match = "k"
},
["run2"] = {
	switch = function()
		show_rectangle_raw()
		WriteFile()
		if bufcnt(player.toTargetDist("Kicker")<10,wait_time) then
			return "run"..3
		end
	end,
	Kicker = task.goCmuRush(RectanglePos[2],0, _, DSS_FLAG),
	match = "k"
},
["run3"] = {
	switch = function()
		show_rectangle_raw()
		WriteFile()
		if bufcnt(player.toTargetDist("Kicker")<10,wait_time) then
			return "run"..4
		end
	end,
	Kicker = task.goCmuRush(RectanglePos[3],0, _, DSS_FLAG),
	match = "k"
},
["run4"] = {
	switch = function()
		show_rectangle_raw()
		WriteFile()
		if bufcnt(player.toTargetDist("Kicker")<10,wait_time) then
			return "run"..1
		end
	end,
	Kicker = task.goCmuRush(RectanglePos[4],0, _, DSS_FLAG),
	match = "k"
},


------------------------------------------------------------------------------------------------------

name = "autotest0",


------------------------------------------------------------------------------------------------------


applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
