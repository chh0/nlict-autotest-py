
local exist_nums = {}
local all_num = 0
local start_poses = {}
local end_poses = {}
local time = 50
-- local target_dir = 0
local target_dir = math.pi/2
local angle_thre = math.pi/10
local fail_num_max = 3
local success_num_max = 3
local if_fail = {0,0,0,0,0,0,0,0,0}
local fail_num = {0,0,0,0,0,0,0,0,0}
local success_num = {0,0,0,0,0,0,0,0,0}
local max_vel = {0,0,0,0,0,0,0,0,0}
local max_vel_local = {0,0,0,0,0,0,0,0,0}
local min_acc = {3000,3000,3000,3000,3000,3000,3000,3000,3000,3000,3000}
local max_acc = {6000,6000,6000,6000,6000,6000,6000,6000,6000,6000,6000}

---------------------------------------
local file_name = os.date("%Y-%m-%d %H:%M:%S")
local get_data = function()
    return {
        min_acc1=min_acc[1],
        max_acc1=max_acc[1],
        time=os.date("%Y-%m-%d %H:%M:%S")
    }
end
local save_data = function()
    local data = get_data()
    local str = atest.h_tabletostring(data)
    atest.h_addtofile(file_name, str)
end
local send_data = function()
    local data = get_data()
    local str = atest.h_tabletostring(data)
    autest:H_Send_String("[DATA] "..str)
end

local getAcc = function(num)
	return function()
		return (min_acc[num]+max_acc[num])/2
	end
end

local get_max_vel = function(num)
	for i = 1,all_num do
		if max_vel[i] < player.velMod(exist_nums[i]) then
			max_vel[i] = player.velMod(exist_nums[i])
		end
		if max_vel_local[i] < player.velMod(exist_nums[i]) then
			max_vel_local[i] = player.velMod(exist_nums[i])
		end
	end
end

local showdebug = function()
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1000),string.format("minacc	%d	%d	%d	%d	%d", min_acc[1],min_acc[2],min_acc[3],min_acc[4],min_acc[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1200),string.format("maxacc	%d	%d	%d	%d	%d", max_acc[1],max_acc[2],max_acc[3],max_acc[4],max_acc[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1400),string.format("s_num	%d	%d	%d	%d	%d", success_num[1],success_num[2],success_num[3],success_num[4],success_num[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1600),string.format("f_num	%d	%d	%d	%d	%d", fail_num[1],fail_num[2],fail_num[3],fail_num[4],fail_num[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,1800),string.format("failed	%d	%d	%d	%d	%d", if_fail[1],if_fail[2],if_fail[3],if_fail[4],if_fail[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,2000),string.format("max_v	%d	%d	%d	%d	%d", max_vel[1],max_vel[2],max_vel[3],max_vel[4],max_vel[5]),3)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,2200),string.format("max_vl	%d	%d	%d	%d	%d", max_vel_local[1],max_vel_local[2],max_vel_local[3],max_vel_local[4],max_vel_local[5]),3)
end

local update_param = function()
	for i = 1,all_num do
		if if_fail[i] == 1 then
			max_acc[i] = (max_acc[i] + min_acc[i]) / 2
			fail_num[i] = fail_num[i] + 1
			success_num[i] = 0
		else
			min_acc[i] = (max_acc[i] + min_acc[i]) / 2
			success_num[i] = success_num[i] + 1
			fail_num[i] = 0
		end
		if fail_num[i] > fail_num_max - 1 then
			min_acc[i] = min_acc[i] / 2
			fail_num[i] = 0
		elseif success_num[i] > success_num_max - 1 then
			max_acc[i] = max_acc[i] + min_acc[i] / 2
			success_num[i] = 0
		end
	end
	if_fail = {0,0,0,0,0,0,0,0,0}
	max_vel_local = {0,0,0,0,0,0,0,0,0}
end

local init = function()
	exist_nums = {}
	for i=0,param.maxPlayer-1 do
		if player.valid(i) then
			table.insert(exist_nums,i)
		end
	end
	if table.getn(exist_nums) <= 0 then
		print("Error : no robots in field?")
	end
end

local get_poses = function()
	all_num = table.getn(exist_nums)
	if all_num <= 0 then
		print("Error : not init yet?")
	end
	local height = 6000
	local length = 9000
	local edgeX = 1500
	local edgeY = 1000
	local gap = (height-edgeY*2) / (all_num)
	local posY = edgeY
	for i = 1,all_num do
		table.insert(start_poses, CGeoPoint:new_local(edgeX-length/2,edgeY-height/2+gap*(i-0.5)))
		table.insert(end_poses, CGeoPoint:new_local(length/2-edgeX,edgeY-height/2+gap*(i-0.5)))
	end
end

local get_num = function(num)
	return function()
		if num > table.getn(exist_nums) then
			return -1
		end
		if num == table.getn(exist_nums) then
			return exist_nums[num]
		end
		local index = num % table.getn(exist_nums)
		return exist_nums[index]
	end
end

local check_arrive = function()
	for key, value in pairs(exist_nums) do
		if player.toPointDist(value, start_poses[key]) > 50 and player.toPointDist(value, end_poses[key]) > 50 then
			return false
		end
	end 
	return true
end

local check_fail = function()
	for key, value in pairs(exist_nums) do
		if math.abs(player.dir(value)-target_dir) > angle_thre then
			if_fail[key] = 1
		end
	end 
end

local get_start_pos = function(num)
	return function()
		if num > all_num then
			return CGeoPoint:new_local(0, 0)
		else
			return start_poses[num]
		end
	end
end

local get_end_pos = function(num)
	return function()
		if num > all_num then
			return CGeoPoint:new_local(0, 0)
		else
			return end_poses[num]
		end
	end
end

gPlayTable.CreatePlay{
	firstState = "init",
	["init"] = {
		switch = function()
			init()
			get_poses()
			return "start"
		end,
		match = ""
	},
	["start"] = {
		switch = function()
			showdebug()
			if bufcnt(check_arrive(),time) then
				return "run"..1
			end
		end,
		[get_num(1)] = task.goCmuRush(get_start_pos(1), target_dir), 
		[get_num(2)] = task.goCmuRush(get_start_pos(2), target_dir), 
		[get_num(3)] = task.goCmuRush(get_start_pos(3), target_dir), 
		[get_num(4)] = task.goCmuRush(get_start_pos(4), target_dir),
		[get_num(5)] = task.goCmuRush(get_start_pos(5), target_dir),  
		[get_num(6)] = task.goCmuRush(get_start_pos(6), target_dir), 
		[get_num(7)] = task.goCmuRush(get_start_pos(7), target_dir), 
		[get_num(8)] = task.goCmuRush(get_start_pos(8), target_dir), 
		[get_num(9)] = task.goCmuRush(get_start_pos(9), target_dir), 
		match = ""
	},
	["run1"] = {
		switch = function()
			check_fail()
			showdebug()
			get_max_vel()
            save_data()
            send_data()
			if bufcnt(check_arrive(),time) then
				atest.h_reset()
                update_param()
                return "start"
			end
		end,
		[get_num(1)] = task.goCmuRush(get_end_pos(1), target_dir, getAcc(1)), 
		[get_num(2)] = task.goCmuRush(get_end_pos(2), target_dir, getAcc(2)), 
		[get_num(3)] = task.goCmuRush(get_end_pos(3), target_dir, getAcc(3)), 
		[get_num(4)] = task.goCmuRush(get_end_pos(4), target_dir, getAcc(4)),
		[get_num(5)] = task.goCmuRush(get_end_pos(5), target_dir, getAcc(5)),  
		[get_num(6)] = task.goCmuRush(get_end_pos(6), target_dir, getAcc(6)), 
		[get_num(7)] = task.goCmuRush(get_end_pos(7), target_dir, getAcc(7)), 
		[get_num(8)] = task.goCmuRush(get_end_pos(8), target_dir, getAcc(8)), 
		[get_num(9)] = task.goCmuRush(get_end_pos(9), target_dir, getAcc(9)), 
		match = ""
	},

	name = "AUTO_TEST_B",
	applicable ={
		exp = "a",
		a = true
	},
	attribute = "attack",
	timeout = 99999
}
