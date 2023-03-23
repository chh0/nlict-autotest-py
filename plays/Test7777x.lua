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

["run1"] = {
	switch = function()
		if bufcnt(player.toTargetDist("Kicker")<10,time) then
			return "run"..2--math.random(4)
		end
	end,
	Kicker = task.goCmuRush(testPos[1],math.pi, _, DSS_FLAG),
	-- Kicker = task.goBezierRush(testPos[3],0, _, DSS_FLAG, _, vel),
	match = ""
},
["run2"] = {
	switch = function()
		if bufcnt(player.toTargetDist("Kicker")<10,time) then
			return "run"..1
		end
	end,
	Kicker = task.goCmuRush(testPos[3],0, _, DSS_FLAG),
	-- Kicker = task.goBezierRush(testPos[4],math.pi, _, DSS_FLAG, _, vel),
	match = ""
},
["run3"] = {
	switch = function()
		if bufcnt(player.toTargetDist("Kicker")<50,time) then
			return "run"..4
		end
	end,
	Kicker = task.goCmuRush(testPos[2],0, _, DSS_FLAG),
	-- Kicker = task.goBezierRush(testPos[1],0, _, DSS_FLAG, _, vel),
	match = ""
},
["run4"] = {
	switch = function()
		if bufcnt(player.toTargetDist("Kicker")<50,time) then
			return "run"..3--math.random(4)
		end
	end,
	Kicker = task.goCmuRush(testPos[4],math.pi, _, DSS_FLAG),
	-- Kicker = task.goBezierRush(testPos[2],math.pi, _, DSS_FLAG, _, vel),
	match = ""
},

name = "Test7777x",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
