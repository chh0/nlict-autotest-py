local CYCLE = 0
local SUM_CYCLE = 60*TEST_SECOND
local COUNT = 0
local draw = function()
	debugEngine:gui_debug_line(CGeoPoint:new_local(300,200),CGeoPoint:new_local(300,-200),2)
	debugEngine:gui_debug_line(CGeoPoint:new_local(300,-200),CGeoPoint:new_local(-300,-200),2)
	debugEngine:gui_debug_line(CGeoPoint:new_local(-300,-200),CGeoPoint:new_local(-300,200),2)
	debugEngine:gui_debug_line(CGeoPoint:new_local(-300,200),CGeoPoint:new_local(300,200),2)
	debugEngine:gui_debug_line(CGeoPoint:new_local(250,150),CGeoPoint:new_local(-250,-150),7)
	debugEngine:gui_debug_x(CGeoPoint:new_local(250,150),5)
	debugEngine:gui_debug_x(CGeoPoint:new_local(-250,-150),5)
	if END then
		debugEngine:gui_debug_msg(CGeoPoint:new_local(-240, 110),"测试结束!  ".. CYCLE .. " / " .. SUM_CYCLE,0)
		debugEngine:gui_debug_msg(CGeoPoint:new_local(-240, 130),"最终到点次数 ： " .. COUNT,1)
	else
		debugEngine:gui_debug_msg(CGeoPoint:new_local(-240, 110),"测试帧数 ： " .. CYCLE .. " / " .. SUM_CYCLE,0)
		debugEngine:gui_debug_msg(CGeoPoint:new_local(-240, 130),"到点次数 ： " .. COUNT,0)
	end
end
local DSS_FLAG = bit:_or(flag.allow_dss,flag.not_avoid_their_vehicle)
local SPOS = {
	CGeoPoint:new_local(180,110),
	CGeoPoint:new_local(-180,-110),
	CGeoPoint:new_local(170,50),
	CGeoPoint:new_local(-170,-50),
	CGeoPoint:new_local(70,90),
	CGeoPoint:new_local(-70,-90),
	CGeoPoint:new_local(80,-15),
	CGeoPoint:new_local(-80,15)
}
local spos = function(count)
	return function()
		return SPOS[count]
	end
end

local TARGET_POS = {
	CGeoPoint:new_local(-250,-150),
	CGeoPoint:new_local(250,150)
}
local TARGET_POINT = CGeoPoint:new_local(250,150)
local target = 1
local START = false
local END = false
local dpos = function(count)
	local calc = function(p,tp,ap,r)
		local line = CGeoLine:new_local(p,tp)
		local sp = ap+Utils.Polar2Vector(r,-math.pi/4)
		local ep = ap+Utils.Polar2Vector(r,3*math.pi/4)
		local seg = CGeoSegment:new_local(sp,ep);
		debugEngine:gui_debug_line(sp,ep,1)
		local inter = CGeoLineLineIntersection:new_local(line,seg);
		local t = inter:IntersectPoint();
		if seg:IsPointOnLineOnSegment(t) then
			return t
		else
			if (sp-t):mod() < (ep-t):mod() then
				return sp
			else
				return ep
			end
		end
	end
	return function()
		if enemy.valid(TEST_ENEMY) then
			local p = CGeoPoint:new_local(enemy.posX(TEST_ENEMY),enemy.posY(TEST_ENEMY))
			return calc(p,TARGET_POINT,SPOS[count],RESERVE_DISTANCE)
		else
			return CGeoPoint:new_local(SPOS[count])
		end
	end
end

local judge = function()
	if END then
		return nil
	end
	if START and END == false then
		CYCLE = CYCLE + 1
		if CYCLE >= SUM_CYCLE then
			CYCLE = SUM_CYCLE
			END = true
		end
	end
	local enemy_pos = CGeoPoint:new_local(enemy.posX(TEST_ENEMY),enemy.posY(TEST_ENEMY))
	if (enemy_pos - TARGET_POS[target]):mod() < 10 then
		target = 3 - target
		if START == false then
			START = true
		else
			COUNT = COUNT + 1
		end
	end
end

gPlayTable.CreatePlay{

firstState = "test",

["test"] = {
	switch = function()
		draw()
		if enemy.valid(TEST_ENEMY) then
			judge()
		else
			debugEngine:gui_debug_msg(CGeoPoint:new_local(-240, 170),"当前测试车号为："..TEST_ENEMY .. " ，请确认是否在场")
		end
	end,
	Leader   = task.goCmuRush(dpos(1),-math.pi/4,_,DSS_FLAG),
	Special  = task.goCmuRush(dpos(2),-math.pi/4,_,DSS_FLAG),
	Middle   = task.goCmuRush(dpos(3),-math.pi/4,_,DSS_FLAG),
	Defender = task.goCmuRush(dpos(4),-math.pi/4,_,DSS_FLAG),
	Assister = task.goCmuRush(dpos(5),-math.pi/4,_,DSS_FLAG),
	Fronter  = task.goCmuRush(dpos(6),-math.pi/4,_,DSS_FLAG),
	Center   = task.goCmuRush(dpos(7),-math.pi/4,_,DSS_FLAG),
	Breaker  = task.goCmuRush(dpos(8),-math.pi/4,_,DSS_FLAG),
	match    = "[LADMSFCB]"
},


name = "TestScript",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}
