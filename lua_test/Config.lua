IS_TEST_MODE = false
IS_SIMULATION = CGetIsSimulation()
USE_SWITCH = false
USE_AUTO_REFEREE = false
OPPONENT_NAME = "Other"
SAO_ACTION = CGetSettings("Alert/SaoAction","Int")
IS_YELLOW = CGetSettings("ZAlert/IsYellow","Bool")
IS_RIGHT = CGetSettings("ZAlert/IsRight", "Bool")
DEBUG_MATCH = CGetSettings("Debug/RoleMatch","Bool")
gStateFileNameString = string.format(os.date("%Y%m%d%H%M"))
USE_AUTO_TEST = false

-- gTestPlay = IS_YELLOW and "TestRun" or "TestSkill" 
-- gTestPlay = "TestRun"
gTestPlay = "NormalPlayMessi_8vs8"
-- gTestPlay = "TestWs"
-- gTestPlay = "TestRunXbox"
-- gTestPlay = "TestPass&Shoot"

gRoleFixNum = {
        ["Kicker"]   = {15},
        -- ["Goalie"]   = {15},
        -- ["Receiver"] = {} match before rolematch in messi by wangzai
}

-- 用来进行定位球的保持
-- 在考虑智能性时用table来进行配置，用于OurIndirectKick
gOurIndirectTable = {
        -- 在OurIndirectKick控制脚本中可以进行改变的值
        -- 上一次定位球的Cycle
        lastRefCycle = 0
}

gSkill = {
        "SmartGoto",
        "SimpleGoto",
        "RunMultiPos",
        "Stop",
        "GetBallV4",
        "FreeKickoff",
        "StaticGetBall",
        "GoAndTurnKickV3",
        "SlowGetBall",
        "ChaseKick",
        "ChaseKickV2",
        "CircleRush",
        "CircleRushV2",
        "ChaseBall",
        "DubinsGoto",
        "SelfPass",
        "AdvanceBall",
        "ReceivePass",
        "OpenSpeed",
        "Speed",
        "PenaltyGoalieV2",
        "PenaltyGoalie2017V1",
        "Marking",
        "ZMarking",
        "ZBlocking",
        "ZGoalie",
        "ZCasillas",
        "GotoMatchPos",
        "PenaltyKick2017V1",
        "PenaltyKick2017V2",
        "GoCmuRush",
        "ChinaTecRun",
        "BezierRush",
        "NoneZeroRush",
        "SpeedInRobot",
        "GoAvoidShootLine",
        "XBox",
        "ZPass",
        "ZSupport",
        "ZBreak",
        "ZAttack",
        "ZCirclePass",
        "DribbleTurnKick",
        "InterceptTouch",
        "HoldBall",
        "GoAndTurnKickV4",
        "ZDrag",
        "FetchBall",
        "ZBack",
        "ZHelper"
}

gRefPlayTable = {
        "Ref/Ref_HaltV1",
        "Ref/Ref_OurTimeoutV1",
        "Ref/GameStop/Ref_StopZMarking",
        "Ref/GameStop/Ref_StopZMarking_6vs6",
        "Ref/GameStop/Ref_StopZMarking_8vs8",
        "Ref/GameStop/Ref_StopZMarking_11vs11",
-- BallPlacement
        "Ref/BallPlacement/Ref_BallPlace2Stop",
        "Ref/BallPlacement/Ref_BallPlace2Stop_6vs6",
        "Ref/BallPlacement/Ref_BallPlace2Stop_8vs8",
        "Ref/BallPlacement/Ref_BallPlace2Stop_11vs11",
-- Penalty
        "Ref/PenaltyDef/Ref_PenaltyDefV1",
        "Ref/PenaltyDef/Ref_PenaltyDefV1_6V6",
        "Ref/PenaltyDef/Ref_PenaltyDefV1_8V8",
        "Ref/PenaltyDef/Ref_Big_PenaltyDef_8V8",
        "Ref/PenaltyDef/Ref_PenaltyDef2017V1",
        "Ref/PenaltyDef/Ref_PenaltyDef2020V2",
        "Ref/PenaltyKick/Ref_PenaltyKickV3",
        "Ref/PenaltyKick/Ref_PenaltyKickV3_6V6",
        "Ref/PenaltyKick/Ref_PenaltyKickV3_8V8",
        "Ref/PenaltyKick/Ref_Big_PenaltyKick_8V8",
        "Ref/PenaltyKick/Ref_PenaltyKickV4",
        "Ref/PenaltyKick/Ref_PenaltyKick2017V1",
        "Ref/PenaltyKick/Ref_PenaltyKick2017V2",
        "Ref/PenaltyKick/Ref_BIG_penalty2021",
        "Ref/PenaltyDef/Ref_PenaltyDef_11V11",
        "Ref/PenaltyKick/Ref_PenaltyKick_11V11",
-- KickOff
        "Ref/KickOffDef/Ref_KickOffDefV1",
        "Ref/KickOffDef/Ref_KickOffDef_6vs6",
        "Ref/KickOffDef/Ref_KickOffDef_8vs8",
        "Ref/KickOffDef/Ref_KickOffDef_11vs11",        
        "Ref/KickOff/Ref_KickOffV601",
        "Ref/KickOff/Ref_KickOff_8vs8",
        "Ref/KickOff/Ref_KickOff_11vs11",
-- FreeKickDef
        "Ref/CornerDef/Ref_CornerDefV1",
        "Ref/CornerDef/Ref_CornerDefV2",
        "Ref/CornerDef/Ref_CornerDef_6vs6",
        "Ref/CornerDef/Ref_CornerDef_8vs8",
        "Ref/FrontDef/Ref_FrontDefV1",
        "Ref/FrontDef/Ref_FrontDef_6vs6",
        "Ref/FrontDef/Ref_FrontDef_8vs8",
        "Ref/MiddleDef/Ref_MiddleDefV1",
        "Ref/MiddleDef/Ref_MiddleDef_6vs6",
        "Ref/MiddleDef/Ref_MiddleDef_8vs8",
        "Ref/BackDef/Ref_BackDefV1",
        "Ref/BackDef/Ref_BackDef_6vs6",
        "Ref/BackDef/Ref_BackDef_8vs8",

        "Ref/FreeKickDef/Ref_FreeKickDef_8vs8",
        "Ref/FreeKickDef/Ref_FreeKickDef_11vs11",
-- FreeKick
        "Ref/FrontKick/Ref_FrontKickV801",
        "Ref/FrontKick/Ref_FrontKickV802",
        "Ref/FrontKick/Ref_FrontKickV803",
        "Ref/FrontKick/Ref_FrontKickV804",
        "Ref/FrontKick/Ref_FrontKickV805",
        "Ref/FrontKick/Ref_FrontKickV806",
        -- "Ref/FrontKick/Ref_FrontKickV807",
        "Ref/FrontKick/Ref_FrontKickV1901",

        "Ref/BackKick/Ref_BackKickV801",
        "Ref/BackKick/Ref_BackKickV802",

        "Ref/MiddleKick/Ref_MiddleKickV801",
        "Ref/MiddleKick/Ref_MiddleKickV802",
        "Ref/MiddleKick/Ref_MiddleKickV803",

        -- "Ref/CornerKick/Ref_CornerKickV666",
        "Ref/CornerKick/Ref_CornerKickV801",
        "Ref/CornerKick/Ref_CornerKickV802",
        "Ref/CornerKick/Ref_CornerKickV803",
        "Ref/CornerKick/Ref_CornerKickV804",
        "Ref/CornerKick/Ref_CornerKickV805",

        "Ref/FreeKick/Ref_FreeKick_8vs8",
        "Ref/FreeKick/Ref_FreeKick_11vs11",
}

gBayesPlayTable = {
        -- "Nor/NormalPlayPP",
        "Nor/NormalPlayZ", 
        "Nor/NormalPlayZ6", 
        "Nor/NormalPlayMessi",
        "Nor/NormalPlayMessi_6vs6",  
        "Nor/NormalPlayMessi_11vs11",
        "Nor/NormalPlayMessi_8vs8",     
        -- "Nor/NormalPlay4"
}

gTestPlayTable = {
        -- "Test/RunMilitaryBoxing",
        -- "Test/TestDynamicBackKick",
        -- "Test/TestDynamicBackKick2",
        -- "Test/TestDynamicKick",
        -- "Test/TestDynamicKickJamVersion",
        -- "Test/TestDynamicKickPickVersion",
        -- "Test/TestForCompensate",
        "Test/TestForFriction",
        -- "Test/TestTEB",
        "Test/TestForFrictionAuto",
        "Test/TestRun_autoshootfit",
        "Test/RunKickParamTest",
        "Test/TestRun",
        "Test/TestRegulation",
        "Test/TestDemo",
        "Test/TestScript",
        -- "Test/TestMatch",
        "Test/TestDSS",
        "Test/TestFreeKick",
        "Test/TestFreeKick_6vs6",
        "Test/TestFreeKick_6vs6_v2",
        "Test/TestFreeKick_use_chip_predict",
        "Test/TestFreeKick_TechChallenge",
        "Test/TestSkill",
        "Test/TestForChip",
        "Test/TestForBallState",
        -- "Test/TestZbreak",
        "Test/TestKeke",
        "Test/TestKeke2",
        "Test/TestNonZero",
        "Test/RegulationData",
        "Test/TestNonZeroV2",
        -- "Test/TestMultiple",
        -- "Test/TestSkill2",
        "Test/TestWs",
        "Test/TestPass&Shoot",
        "Test/TestRunXbox",
        "Test/TestWindPile",
        "Test/TestStopCar",
        "Test/AttackShow",
        "Test/DefendShow",
        "Test/TestCornerShow",
        "Test/zju"
}
-- used for test 
-- (USE_AUTO_TEST = true) to enter, else false
------------------------------------------------------------

--读全部
function load(fileName)
        assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
        local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
        local data = {};
        local section;
        for line in file:lines() do
            local tempSection = line:match('^%[([^%[%]]+)%]$');
            if(tempSection)then
                section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
                data[section] = data[section] or {};
            end
            local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
            if(param and value ~= nil)then
                value = string.gsub(value, '^%s*(.-)%s*$', '%1')
                if(tonumber(value))then
                    value = tonumber(value);
                elseif(value == 'true')then
                    value = true;
                elseif(value == 'false')then
                    value = false;
                end
                if(tonumber(param))then
                    param = tonumber(param);
                end
                data[section][param] = value;
            end
        end
        file:close();
        return data;
    end
--写全部
function save(fileName, data)
        assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
        assert(type(data) == 'table', 'Parameter "data" must be a table.');
        local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
        local contents = '';
        for section, param in pairs(data) do
                contents = contents .. ('[%s]\n'):format(section);
                for key, value in pairs(param) do
                        contents = contents .. ('%s=%s\n'):format(key, tostring(value));
                end
                contents = contents .. '\n';
        end
        file:write(contents);
        file:close();
    end
--读单条
function ReadIni(IniPath,Section,Key)
        local data=load(IniPath)
        return data[Section][Key]
end
--写单条
function WriteIni(IniPath,Section,Key,Value)
        local data=load(IniPath)
        data[Section][Key]=Value
        save(IniPath, data)
end
    
local function tableContains(tbl, element)
        for _, v in ipairs(tbl) do
                if (rawequal(v, element)) then
                        return true;
                end
        end
        return false;
end

if USE_AUTO_TEST then
        local data = load('/home/zjunlict/chh/kun_latast/Kun2/ZBin/lua_scripts/chenv.ini')
        local get_yellow_play = data.MAIN.yellow
        local get_blue_play = data.MAIN.blue
        local get_test_status = data.MAIN.test
        IS_TEST_MODE = get_test_status
        if not tableContains(gTestPlayTable, "Test/"..get_yellow_play) then
                table.insert(gTestPlayTable, "Test/"..get_yellow_play)
        end
        if not tableContains(gTestPlayTable, "Test/"..get_blue_play) then
                table.insert(gTestPlayTable, "Test/"..get_blue_play)
        end
        gTestPlay = IS_YELLOW and get_yellow_play or get_blue_play
        
end