local RectanglePos  = {
	CGeoPoint:new_local(-3000,0),
	CGeoPoint:new_local(3000,0)
}

local adjustPos = {
	CGeoPoint:new_local(-1000,1000),
}

local time = 20
local min_acc = 3000
local max_acc = 6000
local target_dir = 0
local angle_thre = math.pi/10
local waitTime = 200
local bound = 2500
local fail_num = 0
local success_num = 0
local fail_num_max = 3
local success_num_max = 3
local max_vel = 0
local max_vel_local = 0

local getAcc = function()
	return (min_acc+max_acc)/2
end

local CurrentPos = function()
	return player.pos("Leader")
end

local function showdebug()
	debugEngine:gui_debug_line(RectanglePos[1],RectanglePos[2],4)
	debugEngine:gui_debug_x(CurrentPos(),1)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1000),string.format("angle_err: %.2f",math.abs(player.dir("Leader")-target_dir)),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1200),string.format("min_acc: %d",min_acc),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1400),string.format("max_acc: %d",max_acc),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1600),string.format("max_vel: %d",max_vel),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1800),string.format("max_vel_local: %d",max_vel_local),3)
end

gPlayTable.CreatePlay{

firstState = "wait",
["run1"] = {
	switch = function()
		showdebug()
		if max_vel < player.velMod("Leader") then
			max_vel = player.velMod("Leader")
		end
		if max_vel_local < player.velMod("Leader") then
			max_vel_local = player.velMod("Leader")
		end
		if math.abs(player.dir("Leader")-target_dir) > angle_thre and math.abs(player.posX("Leader")) < bound then
			return "fail"
		end		
		if bufcnt(player.toTargetDist("Leader")<50,time) then
			return "run"..2
		end
	end,
	Leader = task.goCmuRush(RectanglePos[2],target_dir, getAcc),
	match = "{L}"
},
["run2"] = {
	switch = function()
		showdebug()
		if max_vel < player.velMod("Leader") then
			max_vel = player.velMod("Leader")
		end
		if max_vel_local < player.velMod("Leader") then
			max_vel_local = player.velMod("Leader")
		end
		if math.abs(player.dir("Leader")-target_dir) > angle_thre and math.abs(player.posX("Leader")) < bound then
			return "fail"
		end
		if bufcnt(player.toTargetDist("Leader")<50,time) then
			return "success"
		end
	end,
	Leader = task.goCmuRush(RectanglePos[1],target_dir,getAcc),
	match = "{L}"
},
["wait"] = {
	switch = function()
		showdebug()
		if max_acc - min_acc < 30 then
			return "stop"
		end
		max_vel_local = 0
		if bufcnt(true, waitTime) then
			return "run"..1
		end
	end,
	Leader = task.goCmuRush(RectanglePos[1],target_dir),
	match = "{L}"
},

["success"] = {
	switch = function()
		showdebug()
		success_num = success_num + 1
		fail_num = 0
		if success_num > success_num_max - 1 then
			success_num = 0
			max_acc = max_acc + min_acc / 2
		end
		min_acc = getAcc()
		return "wait"
	end,
	Leader = task.goCmuRush(RectanglePos[1],target_dir),
	match = "{L}"
},

["fail"] = {
	switch = function()
		showdebug()
		if bufcnt(player.toTargetDist("Leader")<10,time) then
			success_num = 0
			fail_num = fail_num + 1
			if fail_num > fail_num_max - 1 then
				fail_num = 0
				min_acc = min_acc / 2
			end
			max_acc = getAcc()
			return "wait"
			end
	end,
	Leader = task.goCmuRush(adjustPos[1],_,1000),
	match = ""
},

["stop"] = {
	switch = function()
		showdebug()
		-- return "stop"
	end,
	Leader = task.stop(),
	match = ""
},


name = "TestMove2",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}