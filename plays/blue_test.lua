local testPos  = {
	CGeoPoint:new_local(2000,-2300),
	CGeoPoint:new_local(1000,-300),
	CGeoPoint:new_local(-2000,2300),
	CGeoPoint:new_local(-1000,-1000)
}
local vel = CVector:new_local(0, 0)
local maxvel=0
local time = 120
local DSS_FLAG = bit:_or(flag.allow_dss, flag.dodge_ball)
gPlayTable.CreatePlay{

firstState = "test",
["test"] = {
	switch = function()
		if bufcnt(player.infraredOn("Leader"),5) then
			return "test2"
		end
	end,
	Leader = task.zget(),
	match = "[L]"
},

["test2"] = {
	switch = function()
		if not player.infraredOn("Leader") then
			return "test"
		end
	end,
	Leader = task.openSpeed(-800,200,3,0,flag.dribbling),
	match = "[L]"
},


name = "blue_test",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
