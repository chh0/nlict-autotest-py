local DSS = bit:_or(flag.allow_dss,flag.dodge_ball)--avoid_ball_and_shoot_line)
USE_ZGET = CGetSettings("Messi/USE_ZGET", "Bool")
local staticDefPos  = {
    CGeoPoint:new_local(-3500,3000),
    CGeoPoint:new_local(-3500,2000),
    CGeoPoint:new_local(-3500,-3000),
    CGeoPoint:new_local(-3500,-2000),
}

--激进单后卫打法开关
local AGRESSIVE = 0

--大巴防守开关
local BUSDEFENSE = 0

--灵活防守开关：实时匹配zback，针对在禁区两侧调度频繁的队伍
local FLEXIBLE_DEF = 0

--更多后卫
local MORE_BACK = 0

--后场解围
local KICK_OUT = 1

--更保守的进攻
local CONSERV_ATT = 1

--宁工专属小开关
local NE_DEF = 1
local NE_TEST = false

local leaderNum = function ()
    return messi:leaderNum()
end
local receiverNum = function ()
    return messi:receiverNum()
end
function getPassPos()
    local rPos = function ()
        return messi:passPos()
    end
    return rPos
end

function goaliePassPos()
    local gPos = function ()
        if player.posX("Leader") > 0 then
            return player.pos("Leader")
        else
            return messi:goaliePassPos()
        end
    end
    return gPos
end

function getPassVel()
    local vel = function ()
        if messi:needChip() then 
            return messi:passVel() * 0.95
        end

        return messi:passVel() * 1.2
    end
    return vel
end

function getAttackerNum(i)
    return function ()
        return defenceSquence:getAttackNum(i)
    end
end

function getOurNum()
    return vision:getValidNum()
end

function getTheirNum()
    return vision:getTheirValidNum()
end

function getFlag()
    local flag = function ()
        local f = flag.dribble + flag.safe + flag.rush
        if messi:needChip() then
            f = f + flag.chip
        end
        if messi:needKick() then
            f = f + flag.kick
        end
        return f
    end
    return flag
end

local function ourBallJumpCond()
    local state = messi:nextState()
    local attackerAmount = defenceSquence:attackerAmount()
    if attackerAmount < 0 then 
        attackerAmount = 0
    elseif attackerAmount > 5 then
        attackerAmount = 5
    end

    if state == "Pass" and ball.inOurPenaltyCheck(50) then --zak debug: Goalie kick ball
        return "GoalKick"
    end

    if BUSDEFENSE == 1 then
        gRoleNum["Leader"] = leaderNum() 
        return "BusDefense"
    end

    if getOurNum() == 5 then
        gRoleNum["Leader"] = leaderNum() 
        return "6car"
    end
    if getOurNum() == 4 then
        gRoleNum["Leader"] = leaderNum() 
        return "5car"
    end
    if getOurNum() == 3 then
        gRoleNum["Leader"] = leaderNum() 
        return "4car"
    end

    if getOurNum() == 2 then
        gRoleNum["Leader"] = leaderNum()
        return "3cardefend"
    end
    if getOurNum() == 1 then 
        gRoleNum["Leader"] = leaderNum()
        return "2cardefend"
    end

    if state == "Pass" and AGRESSIVE == 1 and attackerAmout < 2 then 
        --绕过match直接赋值
        local leader = leaderNum()
        local receiver = receiverNum()
        -- print("valid:", receiver, player.valid(receiver))
        if getOurNum() > 5 then 
            if leader ~= receiver and player.valid(receiver) then
                gRoleNum["Leader"] = leader
                gRoleNum["Receiver"] = receiver                
            else
                gRoleNum["Leader"] = leader
            end
        end
        return "APass"..attackerAmount
    end

    if state == "Pass" then 
        --绕过match直接赋值
        local leader = leaderNum()
        local receiver = receiverNum()
        -- print("valid:", receiver, player.valid(receiver))
        if getOurNum() > 5 then 
            if leader ~= receiver and player.valid(receiver) then
                gRoleNum["Leader"] = leader
                gRoleNum["Receiver"] = receiver
            else
                gRoleNum["Leader"] = leader
            end
        end
        if CONSERV_ATT == 1 and attackerAmount <= 3 then
            return "CON_ATT"..attackerAmount
        else
            return "Pass"..attackerAmount
        end

    elseif state == "GetBall" then

        if getOurNum() > 5 then 
            gRoleNum["Leader"] = leaderNum()
        end
        if attackerAmount > 2 and MORE_BACK == 1 then
            return "MOREBACK"..attackerAmount
        elseif NE_DEF and attackerAmount < 4 then
            return "NE_DEF"..attackerAmount
        elseif getTheirNum() < 6 and getTheirNum() > 0 then
            if attackerAmount > 3 then
                attackerAmount = 3
            end
            return "LESS"..attackerAmount
        else
            return "GetBall"..attackerAmount
        end

    elseif state == "fix" then
        gRoleNum["Leader"] = leaderNum()
        return "fix"
    end

    return "initState"
end

function leaderTask (t, w, p, f)
    return function()
        if USE_ZGET then
            return task.zget(pos.getPassPos(), _, getPassVel(), getFlag())
        elseif NE_TEST and messi:nextState() == "Pass" and player.infraredOn(leaderNum()) then
            return task.openSpeed(-300,0,1.5,_,_,flag.dribble,_,_)
        elseif KICK_OUT == 1 and player.posX(leaderNum()) < - param.pitchLength / 2 + param.penaltyDepth + 1000 then
            debugEngine:gui_debug_msg(CGeoPoint:new_local(-5000,2500),"Clearance!!!")
            if player.posY(leaderNum()) > 0 then
                return task.zget(CGeoPoint:new_local(param.pitchLength / 2 - param.penaltyDepth - 500, - param.penaltyWidth / 2 - 500),_,5400, flag.kick + flag.chip)
            else
                return task.zget(CGeoPoint:new_local(param.pitchLength / 2 - param.penaltyDepth - 500, param.penaltyWidth / 2 + 500),_,5400, flag.kick + flag.chip)
            end
        else
            return task.zattack(pos.getPassPos(), _, getPassVel(), getFlag())
        end
    end
end

function receiverTask (p,d)
    return function ()
        if getOurNum() <= 6 and messi:nextState() == "GetBall" then 
           return task.zmarking("Zero",_,getAttackerNum(0))
        elseif KICK_OUT == 1 and player.posX(leaderNum()) < - param.pitchLength / 2 + param.penaltyDepth + 1000 then
            if player.posY(leaderNum()) > 0 then
                return task.goCmuRush(CGeoPoint:new_local(param.pitchLength / 2 - param.penaltyDepth - 500, - param.penaltyWidth / 2 - 500),player.toBallDir,_,DSS)
            else
                return task.goCmuRush(CGeoPoint:new_local(param.pitchLength / 2 - param.penaltyDepth - 500, param.penaltyWidth / 2 + 500),player.toBallDir,_,DSS)
            end
        end
        return task.goCmuRush(pos.getReceivePos(),player.toBallDir,_,DSS)
    end
end

function getStaticDefPos(num)
    return function()
        if ball.posY() < 0 then
            if num==0 then
                return staticDefPos[1]
            elseif num==1 then
                return staticDefPos[4]
            end
        else
            if num==0 then
                return staticDefPos[2]
            elseif num==1 then
                return staticDefPos[3]
            end
        end
    end
end

gPlayTable.CreatePlay{
firstState = "initState",
["stop"] = {
    switch = function ()

    end,
    Leader   = task.stop(),
    Receiver = task.stop(),
    Center   = task.stop(),
    Breaker  = task.stop(),
    Assister = task.stop(),
    Defender = task.stop(),
    Fronter  = task.stop(),
    Goalie   = task.stop(),
    match    = "[LRCBADF]"
},

["initState"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(3)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "[L][R][CBA][DF]"
},

["Pass0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(3)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][CBA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CBA]"
        else 
            return "{L}[DF][R][CBA]"
        end
    end,
},

["Pass1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(3)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][CBA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CBA]"
        else 
            return "{L}[DF][R][CBA]"
        end
    end,
},

["Pass2"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(3)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][CBA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CBA]"
        else 
            return "{L}[DF][R][CBA]"
        end
    end,
},

["Pass3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()
        
        if getOurNum() <= 3 then
            return "(FD)[L][R][C][BA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[FD][C][BA]"
        else 
            return "{L}[FD][R][C][BA]"
        end
    end,
},

["Pass4"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("First",_,getAttackerNum(0)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(1)),
    Assister = task.zdrag(pos.getOtherPos(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()
        
        if getOurNum() <= 3 then
            return "(DF)[L][R][CB][A]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CB][A]"
        else 
            return "{L}[DF][R][CB][A]"
        end
    end,
},

["Pass5"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("First",_,getAttackerNum(0)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(1)),
    Assister = task.zmarking("Third",_,getAttackerNum(2)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()
        
        if getOurNum() <= 3 then
            return "(DF)[L][R][CBA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CBA]"
        else 
            return "{L}[DF][R][CBA]"
        end
    end,
},

["GetBall0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Breaker  = task.zsupport(),
    Assister = task.zsupport(),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["GetBall1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zsupport(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Assister = task.goCmuRush(getStaticDefPos(1),player.toBallDir,_,DSS),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["GetBall2"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.goCmuRush(getStaticDefPos(1),player.toBallDir,_,DSS),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][CB][AR]"
        else
            return "{L}(DF)[CB][AR]"
        end
    end,
},

["GetBall3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zsupport(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("Second",_,getAttackerNum(2)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][ACB][R]"
        else
            return "{L}(DF)[ACB][R]"
        end
    end,
},

["GetBall4"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("Zero",_,getAttackerNum(0)),
    Center   = task.zmarking("First",_,getAttackerNum(1)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(2)),
    Assister = task.zmarking("Third",_,getAttackerNum(3)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][ACBR]"
        else
            return "{L}(DF)[ACBR]"
        end
    end,
},

["GetBall5"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("Zero",_,getAttackerNum(0)),
    Center   = task.zmarking("First",_,getAttackerNum(1)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(2)),
    Assister = task.zmarking("Third",_,getAttackerNum(3)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][ACBR]"
        else
            return "{L}(DF)[ACBR]"
        end
    end,
},

["GoalKick"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = task.zdrag(pos.getOtherPos(1)),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(4)),
    Breaker  = task.zdrag(pos.getOtherPos(3)),
    Assister = task.zdrag(pos.getOtherPos(2)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos(),_,flag.kick + flag.chip),
    match    = "(L)[DF][RCBA]"
},

["fix"] = {
    switch = function ()
        local nextState = ourBallJumpCond()
        if nextState ~= "fix" then
            return nextState
        end
    end,
    Leader   = task.goCmuRush(pos.getLeaderWaitPos(),player.toBallDir,_,flag.allow_dss),
    Receiver = receiverTask(),
    Center   = task.continue(),
    Breaker  = task.continue(),
    Defender = task.continue(),
    Assister = task.continue(),
    Fronter  = task.continue(),
    Goalie   = task.continue(),
    match    = "{L}[R][ABCDF]"
},

["2cardefend"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "[L]" 
},

["3cardefend"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "[L][R]" 
},

["4car"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zsupport(),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "{L}(C)[R]" 
},

["5car"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zback(2,1),
    Defender = task.zback(2,2),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "{L}(CD)[R]" 
},

["6car"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zback(2,1),
    Defender = task.zback(2,2),
    Assister = task.zmarking("First",_,getAttackerNum(1)),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = "{L}(CD)[A][R]" 
},


["LESS0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zsupport(),
    Assister = task.zsupport(),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["LESS1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zsupport(),
    Assister = task.zsupport(),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["LESS2"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zsupport(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("First",_,getAttackerNum(1)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][CB][AR]"
        else
            return "{L}(DF)[CB][AR]"
        end
    end,
},

["LESS3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("Zero",_,getAttackerNum(0)),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("Second",_,getAttackerNum(2)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][CBA][R]"
        else
            return "{L}(DF)[CBA][R]"
        end
    end,
},

["MOREBACK3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("Zero",_,getAttackerNum(0)),
    Center   = task.zmarking("First",_,getAttackerNum(1)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(2)),
    Assister = task.zback(3,3),
    Defender = task.zback(3,2),
    Fronter  = task.zback(3,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DFA][CBR]"
        else
            return "{L}(DFA)[CBR]"
        end
    end,
},

["MOREBACK4"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("Zero",_,getAttackerNum(0)),
    Center   = task.zmarking("First",_,getAttackerNum(1)),
    Breaker  = task.zmarking("Second",_,getAttackerNum(2)),
    Assister = task.zback(3,3),
    Defender = task.zback(3,2),
    Fronter  = task.zback(3,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DFA][CBR]"
        else
            return "{L}(DFA)[CBR]"
        end
    end,
},

["MOREBACK5"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zmarking("First",_,getAttackerNum(1)),
    Center   = task.zmarking("Second",_,getAttackerNum(2)),
    Breaker  = task.zmarking("Third",_,getAttackerNum(3)),
    Assister = task.zback(3,3),
    Defender = task.zback(3,2),
    Fronter  = task.zback(3,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DFA][CBR]"
        else
            return "{L}(DFA)[CBR]"
        end
    end,
},

["BusDefense"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zback(5,1),
    Breaker  = task.zback(5,2),
    Defender = task.zback(5,3),
    Assister = task.zback(5,4),
    Fronter  = task.zback(5,5),
    Goalie   = task.zgoalie(),
    match    = "{L}[CBDAF][R]"
},

["APass0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(1)),
    Breaker  = task.zdrag(pos.getOtherPos(2)),
    Fronter  = task.zdrag(pos.getOtherPos(3)),
    Assister = task.zdrag(pos.getOtherPos(4)),
    Defender = task.zback(1,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(D)[L][R][CABF]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[D][CABF]"
        else 
            return "{L}[D][R][CABF]"
        end
    end,
},

["APass1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(3)),
    Assister = task.zdrag(pos.getOtherPos(2)),
    Breaker  = task.zdrag(pos.getOtherPos(1)),
    Fronter  = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Defender = task.zback(1,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(D)[L][R][C][AB][F]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[D][CAB][F]"
        else 
            return "{L}[D][R][CAB][F]"
        end
    end,
},

["CON_ATT0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(2)),
    Breaker  = task.zdrag(pos.getOtherPos(1)),
    Assister = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][CB][A]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CB][A]"
        else 
            return "{L}[DF][R][CB][A]"
        end
    end,
},

["CON_ATT1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zdrag(pos.getOtherPos(1)),
    Breaker  = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Assister = task.zmarking("Zero",_,getAttackerNum(0)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][A][B][C]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][A][B][C]"
        else 
            return "{L}[DF][R][A][B][C]"
        end
    end,
},

["CON_ATT2"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("Zero",_,getAttackerNum(0)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][BA][C]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][BA][C]"
        else 
            return "{L}[DF][R][BA][C]"
        end
    end,
},

["CON_ATT3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = receiverTask(),
    Center   = task.zmarking("Second",_,getAttackerNum(2)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("Zero",_,getAttackerNum(0)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function ()
        local leader = leaderNum()
        local receiver = receiverNum()

        if getOurNum() <= 3 then
            return "(DF)[L][R][CBA]"
        elseif leader ~= receiver and player.valid(receiver) then 
            return  "{LR}[DF][CBA]"
        else 
            return "{L}[DF][R][CBA]"
        end
    end,
},

["NE_DEF0"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zhelper(),
    Center   = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Breaker  = task.zsupport(),
    Assister = task.zsupport(),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["NE_DEF1"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zhelper(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Assister = task.goCmuRush(getStaticDefPos(1),player.toBallDir,_,DSS),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][C][AB][R]"
        else
            return "{L}(DF)[C][AB][R]"
        end
    end,
},

["NE_DEF2"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zhelper(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.goCmuRush(getStaticDefPos(0),player.toBallDir,_,DSS),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][CB][AR]"
        else
            return "{L}(DF)[CB][AR]"
        end
    end,
},

["NE_DEF3"] = {
    switch = function ()
        return ourBallJumpCond()
    end,
    Leader   = leaderTask(),
    Receiver = task.zhelper(),
    Center   = task.zmarking("Zero",_,getAttackerNum(0)),
    Breaker  = task.zmarking("First",_,getAttackerNum(1)),
    Assister = task.zmarking("Second",_,getAttackerNum(2)),
    Defender = task.zback(2,2),
    Fronter  = task.zback(2,1),
    Goalie   = task.zgoalie(goaliePassPos()),
    match    = function()
        if FLEXIBLE_DEF then
            return "{L}[DF][ACB][R]"
        else
            return "{L}(DF)[ACB][R]"
        end
    end,
},

name = "messi_8v8",
applicable ={
    exp = "a",
    a = true
},
attribute = "attack",
timeout = 99999
}