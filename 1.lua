-- ==============================================
-- VIPER X VINAY MOD - MERGED WITH NEW UPDATE
-- ==============================================

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}

local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local ESpecialMovementType = import("ESpecialMovementType")
local ESpiderSwingMoveState = import("ESpiderSwingMoveState")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local EStateType = import("EStateType")
local ESTEPoseState = import("ESTEPoseState")
local EGameModeType = import("EGameModeType")
local STExtraGameStateBase = import("STExtraGameStateBase")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
local KismetMathLibrary = import("KismetMathLibrary")

-- ==============================================
-- FPS UNLOCK
-- ==============================================
local logic_setting_graphics_1 = package.loaded["client.slua.logic.setting.logic_setting_graphics"] or require("client.slua.logic.setting.logic_setting_graphics")
local GSC_FPS_1 = package.loaded["client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS"] or require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
local GSC_FPSFT_1 = package.loaded["client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT"] or require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
local GraphicSettingDB_1 = package.loaded["client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB"] or require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")

if logic_setting_graphics_1 then
    local var_132 = logic_setting_graphics_1.SetFPS
    function logic_setting_graphics_1.SetFPS(gameInstance, FPSLevel)
        if FPSLevel == 8 and GraphicSettingDB_1 then
            local var_234 = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneSwitch)
            if not var_234 then 
                GraphicSettingDB_1:UpdateUIData(GraphicSettingDB_1.FPSFineTuneSwitch, true) 
            end
        end
        if var_132 then 
            var_132(gameInstance, FPSLevel) 
        end
        if FPSLevel == 8 and GraphicSettingDB_1 then
            GraphicSettingDB_1:UpdateUIData(GraphicSettingDB_1.FPSFineTuneNum, 165)
            gameInstance:ExecuteCMD("t.MaxFPS", "165")
            gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
        end
    end
end

if GSC_FPS_1 and GSC_FPS_1.__inner_impl then
    local var_160 = GSC_FPS_1.__inner_impl
    function var_160:GetMaxFPSLevel() return 8, 8 end
    function var_160:CanChangeQualityAndFPSPreCheck() return true end
    function var_160:InitRealSupportFPS()
        local var_29 = {}
        for i = 1, 8 do var_29[i] = {true, true} end
        if GraphicSettingDB_1 then GraphicSettingDB_1:UpdateUIData(GraphicSettingDB_1.RealSupportFPS, var_29, false) end
        return var_29
    end
    function var_160:SetFPSAndQualityEnable(bEnable)
        if self.UIRoot and self.UIRoot.Image_Mask then self:SetWidgetVisible(self.UIRoot.Image_Mask, false) end
    end
    function var_160:UpdateSelectedFPSState(selectedLevel)
        local var_37 = { [2]="NodeFps20", [3]="NodeFps25", [4]="NodeFps30", [5]="NodeFps40", [6]="NodeFps60", [7]="NodeFps90", [8]="NodeFps120" }
        if not self.UIRoot then return end
        for level, name in pairs(var_37) do
            if self.UIRoot[name] then
                self:WidgetSelfHit(self.UIRoot[name])
                self.UIRoot[name]:SetIsEnabled(true)
                local var_54 = self.UIRoot["WidgetSwitcher_" .. level]
                if var_54 then var_54:SetActiveWidgetIndex(level == selectedLevel and 0 or 1) end
            end
        end
    end
    local var_58 = var_160.UpdateUI
    function var_160:UpdateUI()
        if var_58 then pcall(var_58, self) end
        self:SelfHitTestInvisible()
        self:InitRealSupportFPS()
        self:SetFPSAndQualityEnable(true)
        local var_222 = 8
        if GraphicSettingDB_1 then
            if GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.CustomTab) == 2 then
                var_222 = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.LobbyFPS) or 8
            else
                var_222 = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.SelectedFPS) or 8
            end
        end
        self:UpdateSelectedFPSState(var_222)
    end
    function var_160:DoClickFPS(FPSLevel)
        if slua.isValid(self.UIRoot) then
            if GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.CustomTab) == 2 then
                GraphicSettingDB_1:UpdateUIData(GraphicSettingDB_1.LobbyFPS, FPSLevel)
            else
                GraphicSettingDB_1:UpdateSelectedFPS(FPSLevel)
            end
            self:UpdateSelectedFPSState(FPSLevel)
            if self:GetParentUI() then 
                self:GetParentUI():SaveQualityAndFPS()
                self:GetParentUI():SetDirty(true) 
            end
        end
    end
end

if GSC_FPSFT_1 and GSC_FPSFT_1.__inner_impl then
    local var_13 = GSC_FPSFT_1.__inner_impl
    local var_93, var_203 = 90, 5
    local function func_6(val, min, max) return val < min and min or (val > max and max or val) end
    function var_13:ShowOrHide() 
        self:SelfHitTestInvisible() 
        if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end 
    end
    function var_13:InitFPSFTSwitch()
        local sw = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneSwitch)
        if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(sw, true) end
        if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, sw) end
        if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
        if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
    end
    function var_13:InitFPSFTValue165()
        local var_202 = self.UIRoot
        local sw = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneSwitch)
        local var_69 = sw and GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneNum) or 165
        var_202.Slider_screen3:SetLocked(not sw)
        var_202.ProgressBar_screen3:SetFillColorAndOpacity(sw and FLinearColor(1,1,1,1) or FLinearColor(1,0.625,0.6,1))
        local var_60 = (var_69 - var_93) / (165 - var_93)
        var_202.Veihclescreen3:SetText(LocUtil.LocalizeResFormat(10567, var_69))
        var_202.Slider_screen3:SetValue(var_60)
        var_202.ProgressBar_screen3:SetPercent(var_60)
    end
    function var_13:OnFPSFTValueChange3(var_69)
        GraphicSettingDB_1:UpdateUIData(GraphicSettingDB_1.FPSFineTuneNum, var_69)
        self:InitFPSFTValue165()
        if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
        local var_43 = GraphicSettingDB_1.GetGameInstance and GraphicSettingDB_1.GetGameInstance()
        if var_43 then 
            var_43:ExecuteCMD("t.MaxFPS", tostring(var_69))
            var_43:ExecuteCMD("r.FrameRateLimit", tostring(var_69)) 
        end
    end
    function var_13:OnFPSFTSliderValueChange3(var_174)
        if GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneSwitch) then
            local var_69 = KismetMathLibrary.FCeil(var_174 * (165 - var_93) / var_203) * var_203 + var_93
            self:OnFPSFTValueChange3(func_6(var_69, var_93, 165))
        end
    end
    function var_13:OnFPSFTAdd3()
        local var_69 = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneNum)
        if var_69 then self:OnFPSFTValueChange3(math.min(165, var_69 + var_203)) end
    end
    function var_13:OnFPSFTMinus3()
        local var_69 = GraphicSettingDB_1:GetUIData(GraphicSettingDB_1.FPSFineTuneNum)
        if var_69 then self:OnFPSFTValueChange3(math.max(var_93, var_69 - var_203)) end
    end
    var_13.OnFPSFTAdd = var_13.OnFPSFTAdd3 
    var_13.OnFPSFTMinus = var_13.OnFPSFTMinus3
    var_13.OnFPSFTSliderValueChange = var_13.OnFPSFTSliderValueChange3
end

-- ==============================================
-- CONFIG TABLE (CLAMPED FOR SAFETY)
-- ==============================================
_G.VIPER_Config = {
    IPAD_VIEW_TPP = 90,
    IPAD_VIEW_FPP = 103,
    AIMBOT_ENABLED = false,
    AIMBOT_SPEED = 50,
    AIMBOT_FOV = 30,
    REDUCE_SPREAD = 30,
    REDUCE_RECOIL_H = 30,
    REDUCE_RECOIL_V = 30,
    REDUCE_SCOPE_SHAKE = 30,
    ESP_ENABLED = false,
    ESP_ANTENNA_COLOR = 0,
    ESP_ANTENNA_HEIGHT = 5000,
}

function _G.VIPER_GetVal(id)
    local map = {
        ["IPAD_VIEW_TPP"] = "IPAD_VIEW_TPP",
        ["IPAD_VIEW_FPP"] = "IPAD_VIEW_FPP",
        ["AIMBOT"] = "AIMBOT_ENABLED",
        ["SPEED_AIMBOT"] = "AIMBOT_SPEED",
        ["FOV_AIMBOT"] = "AIMBOT_FOV",
        ["THU_TAM"] = "REDUCE_SPREAD",
        ["GIAM_GIAT_NGANG"] = "REDUCE_RECOIL_H",
        ["GIAM_GIAT_DOC"] = "REDUCE_RECOIL_V",
        ["GIAM_RUNG_SCOPE"] = "REDUCE_SCOPE_SHAKE",
        ["ESP_ENABLE"] = "ESP_ENABLED",
        ["ESP_ANTENNA_COLOR"] = "ESP_ANTENNA_COLOR",
        ["ESP_ANTENNA_HEIGHT"] = "ESP_ANTENNA_HEIGHT",
    }
    local key = map[id]
    if key then
        local val = _G.VIPER_Config[key]
        if id == "AIMBOT" or id == "ESP_ENABLE" then
            return val and 1 or 0
        end
        return val or 0
    end
    return 0
end

function _G.VIPER_SetVal(id, value)
    local map = {
        ["IPAD_VIEW_TPP"] = "IPAD_VIEW_TPP",
        ["IPAD_VIEW_FPP"] = "IPAD_VIEW_FPP",
        ["AIMBOT"] = "AIMBOT_ENABLED",
        ["SPEED_AIMBOT"] = "AIMBOT_SPEED",
        ["FOV_AIMBOT"] = "AIMBOT_FOV",
        ["THU_TAM"] = "REDUCE_SPREAD",
        ["REDUCE_RECOIL_H"] = "REDUCE_RECOIL_H",
        ["REDUCE_RECOIL_V"] = "REDUCE_RECOIL_V",
        ["REDUCE_SCOPE_SHAKE"] = "REDUCE_SCOPE_SHAKE",
        ["ESP_ENABLE"] = "ESP_ENABLED",
        ["ESP_ANTENNA_COLOR"] = "ESP_ANTENNA_COLOR",
        ["ESP_ANTENNA_HEIGHT"] = "ESP_ANTENNA_HEIGHT",
    }
    local key = map[id]
    if key then
        if key == "REDUCE_SPREAD" or key == "REDUCE_RECOIL_H" or key == "REDUCE_RECOIL_V" or key == "REDUCE_SCOPE_SHAKE" then
            value = math.max(0, math.min(60, value))
        end
        if key == "AIMBOT_SPEED" then
            value = math.max(0, math.min(100, value))
        end
        if key == "AIMBOT_FOV" then
            value = math.max(0, math.min(100, value))
        end
        _G.VIPER_Config[key] = value
    end
end

-- ==============================================
-- FAKE UID SYSTEM
-- ==============================================
_G.VIPER_FakeUID = ""

function _G.VIPER_GenerateFakeUID()
    local region = math.random(1, 9)
    local rest = ""
    for i = 1, 10 do
        rest = rest .. tostring(math.random(0, 9))
    end
    local uid = region .. rest
    while #uid < 11 do uid = uid .. tostring(math.random(0, 9)) end
    while #uid > 11 do uid = uid:sub(1, -2) end
    return uid
end

function _G.VIPER_ApplyFakeUID(fakeUID)
    if not fakeUID or fakeUID == "" then
        fakeUID = _G.VIPER_GenerateFakeUID()
    end
    
    _G.VIPER_FakeUID = fakeUID
    
    _G.LocalPlayerUID = fakeUID
    _G.PlayerUID = fakeUID
    _G.CurrentUID = fakeUID
    _G.LocalPlayerId = fakeUID
    
    pcall(function()
        local PlayerState = package.loaded["GameLua.GameCore.PlayerState"]
        if PlayerState then
            if PlayerState.GetUniqueId then
                local orig = PlayerState.GetUniqueId
                PlayerState.GetUniqueId = function(self)
                    local pc = GameplayData.GetPlayerController()
                    if slua.isValid(pc) then
                        local ps = pc:GetPlayerState()
                        if self == ps then
                            return _G.VIPER_FakeUID
                        end
                    end
                    return orig(self)
                end
            end
            
            if PlayerState.GetUID then
                local orig = PlayerState.GetUID
                PlayerState.GetUID = function(self)
                    local pc = GameplayData.GetPlayerController()
                    if slua.isValid(pc) then
                        local ps = pc:GetPlayerState()
                        if self == ps then
                            return _G.VIPER_FakeUID
                        end
                    end
                    return orig(self)
                end
            end
            
            local origIndex = PlayerState.__index
            PlayerState.__index = function(self, key)
                if key == "UID" or key == "uid" or key == "UniqueId" or key == "PlayerUID" then
                    local pc = GameplayData.GetPlayerController()
                    if slua.isValid(pc) then
                        local ps = pc:GetPlayerState()
                        if self == ps then
                            return _G.VIPER_FakeUID
                        end
                    end
                end
                if origIndex then return origIndex(self, key) end
                return nil
            end
        end
        
        local GameplayData_1 = require("GameLua.GameCore.Data.GameplayData")
        if GameplayData_1 then
            if GameplayData_1.GetPlayerUID then
                local orig = GameplayData_1.GetPlayerUID
                GameplayData_1.GetPlayerUID = function()
                    return _G.VIPER_FakeUID
                end
            end
            if GameplayData_1.GetPlayerKey then
                local orig = GameplayData_1.GetPlayerKey
                GameplayData_1.GetPlayerKey = function()
                    return _G.VIPER_FakeUID
                end
            end
            if GameplayData_1.GetPlayerId then
                local orig = GameplayData_1.GetPlayerId
                GameplayData_1.GetPlayerId = function()
                    return _G.VIPER_FakeUID
                end
            end
        end
        
        local pc = GameplayData.GetPlayerController()
        if slua.isValid(pc) then
            if pc.GetPlayerUID then
                local orig = pc.GetPlayerUID
                pc.GetPlayerUID = function()
                    return _G.VIPER_FakeUID
                end
            end
        end
    end)
end

function _G.VIPER_InitFakeUID()
    local initialUID = _G.VIPER_GenerateFakeUID()
    _G.VIPER_ApplyFakeUID(initialUID)
    print("[VIPER] Fake UID system active: " .. _G.VIPER_FakeUID)
end

_G.VIPER_InitFakeUID()

-- ==============================================
-- FAKE TEXT MAP FOR MENU
-- ==============================================
local FakeTextMap = {
    [999000] = "VIPER X VINAY MODS",
    [999001] = "iPad View",
    [999002] = "Aimbot",
    [999003] = "Weapon Mods",
    [999004] = "ESP Features",
    [999100] = "TPP FOV",
    [999101] = "FPP FOV",
    [999200] = "Aimbot",
    [999201] = "Aimbot Speed",
    [999202] = "Aimbot FOV",
    [999300] = "Reduce Spread",
    [999301] = "Reduce Horizontal Recoil",
    [999302] = "Reduce Vertical Recoil",
    [999303] = "Reduce Scope Shake",
    [999400] = "Long Thick Line ESP",
    [999401] = "Line Color",
    [999402] = "Line Height",
}

-- ==============================================
-- SETTINGS MENU
-- ==============================================
function _G.InitVIPERSettingsMenu()
    if _G.VIPER_MenuInitialized then return end
    _G.VIPER_MenuInitialized = true
    
    local LocUtil = _G.LocUtil
    if not LocUtil then
        pcall(function() LocUtil = require("client.common.LocUtil") end)
    end
    if LocUtil and not LocUtil._IsVIPERMenuHooked then
        local originalGetLocalizeResStr = LocUtil.GetLocalizeResStr
        LocUtil.GetLocalizeResStr = function(key)
            if type(key) == "number" then
                if FakeTextMap[key] then
                    return FakeTextMap[key]
                end
            end
            if type(key) == "string" then
                local num = tonumber(key)
                if num and FakeTextMap[num] then
                    return FakeTextMap[num]
                end
                if not num then
                    return key
                end
            end
            if originalGetLocalizeResStr then
                return originalGetLocalizeResStr(key)
            end
            return key
        end
        LocUtil._IsVIPERMenuHooked = true
    end
    
    local SettingPageDefine, SettingCatalog, AliasMap
    
    local paths = {
        { "client.logic.NewSetting.SettingPageDefine", "client.logic.NewSetting.SettingCatalog", "client.slua.umg.NewSetting.Item.AliasMap" },
        { "client.slua.logic.setting.SettingPageDefine", "client.slua.logic.setting.SettingCatalog", "client.slua.umg.NewSetting.Item.AliasMap" },
    }
    
    for _, pathSet in ipairs(paths) do
        local ok1, result1 = pcall(require, pathSet[1])
        local ok2, result2 = pcall(require, pathSet[2])
        local ok3, result3 = pcall(require, pathSet[3])
        if ok1 and ok2 and ok3 then
            SettingPageDefine = result1
            SettingCatalog = result2
            AliasMap = result3
            break
        end
    end
    
    if not SettingPageDefine or not SettingCatalog or not AliasMap then
        print("[VIPER] Failed to load settings modules")
        return
    end
    
    if SettingPageDefine.VIPERMenu then return end
    
    local VIPERMenu = {
        Key = "VIPERMenu",
        Text = 999000,
        UIKey = "Setting_Page_Privacy",
        Category = {}
    }
    
    local Cat_iPad = {
        Key = "Cat_iPad",
        Text = 999001,
        Stack = {
            {
                Key = "IPAD_TPP",
                UI = AliasMap.Slider,
                Text = 999100,
                Min = 90,
                Max = 150,
                Step = 5,
                IsPercent = false,
                GetFunc = function() return _G.VIPER_Config.IPAD_VIEW_TPP end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.IPAD_VIEW_TPP = value
                    return true
                end
            },
            {
                Key = "IPAD_FPP",
                UI = AliasMap.Slider,
                Text = 999101,
                Min = 103,
                Max = 150,
                Step = 5,
                IsPercent = false,
                GetFunc = function() return _G.VIPER_Config.IPAD_VIEW_FPP end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.IPAD_VIEW_FPP = value
                    return true
                end
            }
        }
    }
    table.insert(VIPERMenu.Category, Cat_iPad)
    
    local Cat_Aimbot = {
        Key = "Cat_Aimbot",
        Text = 999002,
        Stack = {
            {
                Key = "AIMBOT_ENABLE",
                UI = AliasMap.TitleSwitcher,
                Text = 999200,
                GetFunc = function() return _G.VIPER_Config.AIMBOT_ENABLED end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.AIMBOT_ENABLED = value
                    return true
                end
            },
            {
                Key = "AIMBOT_SPEED_SLIDER",
                UI = AliasMap.Slider,
                Text = 999201,
                Min = 0,
                Max = 100,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.AIMBOT_SPEED end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.AIMBOT_SPEED = math.max(0, math.min(100, value))
                    return true
                end
            },
            {
                Key = "AIMBOT_FOV_SLIDER",
                UI = AliasMap.Slider,
                Text = 999202,
                Min = 0,
                Max = 100,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.AIMBOT_FOV end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.AIMBOT_FOV = math.max(0, math.min(100, value))
                    return true
                end
            }
        }
    }
    table.insert(VIPERMenu.Category, Cat_Aimbot)
    
    local Cat_Weapon = {
        Key = "Cat_Weapon",
        Text = 999003,
        Stack = {
            {
                Key = "REDUCE_SPREAD_SLIDER",
                UI = AliasMap.Slider,
                Text = 999300,
                Min = 0,
                Max = 60,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.REDUCE_SPREAD end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.REDUCE_SPREAD = math.max(0, math.min(60, value))
                    return true
                end
            },
            {
                Key = "REDUCE_RECOIL_H_SLIDER",
                UI = AliasMap.Slider,
                Text = 999301,
                Min = 0,
                Max = 60,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.REDUCE_RECOIL_H end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.REDUCE_RECOIL_H = math.max(0, math.min(60, value))
                    return true
                end
            },
            {
                Key = "REDUCE_RECOIL_V_SLIDER",
                UI = AliasMap.Slider,
                Text = 999302,
                Min = 0,
                Max = 60,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.REDUCE_RECOIL_V end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.REDUCE_RECOIL_V = math.max(0, math.min(60, value))
                    return true
                end
            },
            {
                Key = "REDUCE_SCOPE_SHAKE_SLIDER",
                UI = AliasMap.Slider,
                Text = 999303,
                Min = 0,
                Max = 60,
                Step = 10,
                IsPercent = true,
                GetFunc = function() return _G.VIPER_Config.REDUCE_SCOPE_SHAKE end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.REDUCE_SCOPE_SHAKE = math.max(0, math.min(60, value))
                    return true
                end
            }
        }
    }
    table.insert(VIPERMenu.Category, Cat_Weapon)
    
    local Cat_ESP = {
        Key = "Cat_ESP",
        Text = 999004,
        Stack = {
            {
                Key = "ESP_ENABLE",
                UI = AliasMap.TitleSwitcher,
                Text = 999400,
                GetFunc = function() return _G.VIPER_Config.ESP_ENABLED end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.ESP_ENABLED = value
                    return true
                end
            },
            {
                Key = "ESP_ANTENNA_COLOR",
                UI = AliasMap.DropDown,
                Text = 999401,
                Options = {
                    {Key=0, Value="Black"},
                    {Key=1, Value="Red"},
                    {Key=2, Value="Blue"},
                    {Key=3, Value="Yellow"},
                    {Key=4, Value="Purple"},
                    {Key=5, Value="Cyan"},
                    {Key=6, Value="Orange"},
                    {Key=7, Value="White"},
                    {Key=8, Value="Green"},
                },
                GetFunc = function() return _G.VIPER_Config.ESP_ANTENNA_COLOR end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.ESP_ANTENNA_COLOR = value
                    return true
                end
            },
            {
                Key = "ESP_ANTENNA_HEIGHT",
                UI = AliasMap.Slider,
                Text = 999402,
                Min = 100,
                Max = 5000,
                Step = 100,
                IsPercent = false,
                GetFunc = function() return _G.VIPER_Config.ESP_ANTENNA_HEIGHT end,
                SetFunc = function(ctrl, value)
                    _G.VIPER_Config.ESP_ANTENNA_HEIGHT = value
                    return true
                end
            }
        }
    }
    table.insert(VIPERMenu.Category, Cat_ESP)
    
    SettingPageDefine.VIPERMenu = VIPERMenu
    table.insert(SettingCatalog, SettingPageDefine.VIPERMenu)
    
    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsVIPERMenuHooked then
        local originalShowUI = UIManager.ShowUI
        
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local argCount = select("#", ...)
            
            if config and config.keyName then
                local lowerKeyName = string.lower(config.keyName)
                if string.find(lowerKeyName, "setting") then
                    local catalog = args[1]
                    if type(catalog) == "table" then
                        local hasVIPERMenu = false
                        for _, page in ipairs(catalog) do
                            if type(page) == "table" and page.Key == "VIPERMenu" then
                                hasVIPERMenu = true
                                break
                            end
                        end
                        if not hasVIPERMenu then
                            table.insert(catalog, SettingPageDefine.VIPERMenu)
                        end
                    end
                end
            end
            
            return originalShowUI(config, table.unpack(args, 1, argCount))
        end
        
        UIManager._IsVIPERMenuHooked = true
    end
    
    print("[VIPER] Settings menu initialized successfully!")
end

pcall(function() _G.InitVIPERSettingsMenu() end)

-- ==============================================
-- BANNER
-- ==============================================
_G.VIPER_BannerShown = false

_G.ShowVIPERSpawnBanner = function()
    if _G.VIPER_BannerShown then return end
    
    pcall(function()
        local logic_common_msg_box = require("client.slua.logic.common.logic_common_msg_box")
        if logic_common_msg_box and logic_common_msg_box.Show then
            logic_common_msg_box.Show(
                4,
                "VIPER X VINAY",
                "----------------------------------------\n" ..
                "                                        \n" ..
                "     ULTIMATE MOD LOADED                \n" ..
                "         VIPER x VINAY                  \n" ..
                "                                        \n" ..
                "     All features are ready!            \n" ..
                "     Open Settings -> VIPER MOD         \n" ..
                "                                        \n" ..
                "          Enjoy!                        \n" ..
                "                                        \n" ..
                "----------------------------------------",
                function() end,
                function() end,
                "OK",
                ""
            )
            
            _G.VIPER_BannerShown = true
            print("[VIPER] Popup banner shown: VIPER x VINAY")
        end
    end)
end

-- ==============================================
-- ESP HELPER FUNCTIONS
-- ==============================================
local function IsPawnAlive(p)
    if not slua.isValid(p) then return false end
    if p.HealthStatus then
        return p.HealthStatus ~= 2
    end
    if p.IsAlive then return p:IsAlive() end
    return p.GetHealth and 0 < (p:GetHealth() or 0) or false
end

local function GetAntennaColor(colorIndex)
    local colors = {
        [0] = {R=0,G=0,B=0,A=255},
        [1] = {R=255,G=0,B=0,A=255},
        [2] = {R=0,G=0,B=255,A=255},
        [3] = {R=255,G=255,B=0,A=255},
        [4] = {R=128,G=0,B=255,A=255},
        [5] = {R=0,G=255,B=255,A=255},
        [6] = {R=255,G=100,B=0,A=255},
        [7] = {R=255,G=255,B=255,A=255},
        [8] = {R=0,G=255,B=0,A=255},
    }
    return colors[colorIndex] or colors[0]
end

local function DrawLongThickLine(HUD, target, dist)
    if dist > 300 then return end
    
    local colorIndex = _G.VIPER_Config.ESP_ANTENNA_COLOR or 0
    local antennaColor = GetAntennaColor(colorIndex)
    
    local antennaHeight = _G.VIPER_Config.ESP_ANTENNA_HEIGHT or 5000
    if antennaHeight < 100 then antennaHeight = 100 end
    if antennaHeight > 5000 then antennaHeight = 5000 end
    
    local step = 20
    for i = 0, antennaHeight, step do
        HUD:AddDebugText("|", target, 0.04,
            {X=0, Y=0, Z=115 + i},
            {X=0, Y=0, Z=115 + i},
            antennaColor, true, false, true, nil, 1.5, true)
    end
end

local function MainESP()
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end
        
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        local HUD = pc:GetHUD()
        if not slua.isValid(HUD) then return end
        
        local espEnabled = _G.VIPER_GetVal("ESP_ENABLE") == 1
        if not espEnabled then return end
        
        local myTeamId = localPlayer.TeamID or 0
        local myLoc = localPlayer:K2_GetActorLocation()
        local allPawns = Game:GetAllPlayerPawns() or {}
        
        for _, target in pairs(allPawns) do
            if slua.isValid(target) and target ~= localPlayer and target.TeamID ~= myTeamId and IsPawnAlive(target) then
                local targetLoc = target:K2_GetActorLocation()
                local dist = FVector.Dist2D(myLoc, targetLoc) / 100
                
                if dist < 300 then
                    DrawLongThickLine(HUD, target, dist)
                end
            end
        end
    end)
end

-- ==============================================
-- ENHANCED BYPASSES
-- ==============================================

-- 1. ULTIMATE LOG/TELEMETRY BLOCKER
function _G.InitializeUltimateLogBlocker()
    print('[UltimateLogBlocker] Initializing...')
    pcall(function()
        local ScreenshotMaker_1 = import("ScreenshotMaker")
        if ScreenshotMaker_1 then
            ScreenshotMaker_1.MakePicture = function() return "" end
            ScreenshotMaker_1.ReMakePicture = function() return "" end
            ScreenshotMaker_1.HasCaptured = function() return true end
        end

        local TLog_1 = package.loaded["TLog"] or _G.TLog
        if TLog_1 then
            TLog_1.Info = function() end
            TLog_1.Warning = function() end
            TLog_1.Error = function() end
            TLog_1.Debug = function() end
            TLog_1.Report = function() end
        end

        local CrashSight_1 = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight_1 then
            CrashSight_1.ReportException = function() end
            CrashSight_1.SetCustomData = function() end
            CrashSight_1.Log = function() end
        end
        
        local GameReportUtils_1 = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GameReportUtils_1 then
            GameReportUtils_1.BugglyPostExceptionFull = function() return false end
            GameReportUtils_1.CheckCanBugglyPostException = function() return false end
            GameReportUtils_1.ReplayReportData = function() end
            GameReportUtils_1.ReportGameException = function() end
        end

        local ClientToolsReport_1 = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if ClientToolsReport_1 then
            ClientToolsReport_1.SendReport = function() end
            ClientToolsReport_1.SendException = function() end
        end

        local tlog_report_utils_1 = package.loaded["client.slua.config.tlog.tlog_report_utils"]
        if tlog_report_utils_1 then
            tlog_report_utils_1.ReportTLogEvent = function() end
        end

        local UGCNewTLogReport_1 = package.loaded["client.slua.logic.ugc.UGCNewTLogReport"] or package.loaded["client.slua.data.BasicData.BasicDataTLogReport"]
        if UGCNewTLogReport_1 then
            UGCNewTLogReport_1.SendExposeReq = function() end
            UGCNewTLogReport_1.SendInteractionReq = function() end
            UGCNewTLogReport_1.TLogReport = function() end
        end
        
        local logic_ugc_tlog_1 = package.loaded["client.slua.logic.ugc.logic_ugc_tlog"]
        if logic_ugc_tlog_1 then
            logic_ugc_tlog_1.SendModTLog = function() end
            logic_ugc_tlog_1.ReportStay = function() end
        end

        local ClientTLogUtil_1 = package.loaded["GameLua.Mod.BaseMod.Client.ClientTLog.ClientTLogUtil"]
        if ClientTLogUtil_1 then
            ClientTLogUtil_1.ReportGeneralCountByBRPhase = function() end
            ClientTLogUtil_1.ReportCommonTLogDataByBRPhase = function() end
        end

        local GameplayData_1 = require("GameLua.GameCore.Data.GameplayData")
        if GameplayData_1 then
            local var_235 = GameplayData_1.GetPlayerControllerSafety and GameplayData_1.GetPlayerControllerSafety() or GameplayData_1.GetPlayerController()
            if slua.isValid(var_235) and var_235.ReportCrashKitFeature then
                var_235.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException = function() end
            end
        end
    end)
    print('[UltimateLogBlocker] Active!')
end

-- 2. ENHANCED SCANNER BLOCKER
function _G.InitializeEnhancedScannerBlocker()
    print('[EnhancedScannerBlocker] Initializing...')
    pcall(function()
        local SubsystemMgr_1 = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        
        if SubsystemMgr_1 then
            local var_74 = SubsystemMgr_1:Get("AFKReportorSubsystem")
            if var_74 then 
                var_74.PlayerHaveAction = function() end
                var_74.ReportAFK = function() end
            end

            local var_198 = SubsystemMgr_1:Get("ClientDataStatistcsSubsystem")
            if var_198 then
                var_198.StartToCheck = function() end
                var_198.DelayCount = 0
                if var_198.ReportPingDelayTimer then
                    var_198:RemoveGameTimer(var_198.ReportPingDelayTimer)
                    var_198.ReportPingDelayTimer = nil
                end
            end

            local var_108 = SubsystemMgr_1:Get("AvatarExceptionSubsystem")
            if var_108 then
                var_108.ReportException = function() end
                var_108.BindPlayerCharacter = function() end
                var_108.CheckAvatarValid = function() return true end
            end
            
            local var_179 = SubsystemMgr_1:Get("ShootVerifySubSystemClient")
            if var_179 then
                var_179.ReportVerifyFail = function() end
                var_179.OnVerifyFailed = function() end
            end
        end

        local CreativeModeBlueprintLibrary_1 = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary_1 then
            CreativeModeBlueprintLibrary_1.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeModeBlueprintLibrary_1.GetContentDiffData = function() return true, "BYPASSED" end
        end

        local AvatarExceptionPlayerInst_1 = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvatarExceptionPlayerInst_1 then
            AvatarExceptionPlayerInst_1.CheckAvatarException = function() end
            AvatarExceptionPlayerInst_1.CheckAvatarExceptionOnce = function() end
            AvatarExceptionPlayerInst_1.ReportAvatarException = function() end
            AvatarExceptionPlayerInst_1.CheckSlotMeshVisible = function() return false end
            AvatarExceptionPlayerInst_1.CheckPawnVisible = function() return false end
            AvatarExceptionPlayerInst_1.CheckCanBugglyPostException = function() return false end
        end

        local AvatarCheckerModule_1 = package.loaded["blacklist.slua.logic.lobby_gm.AvatarCheckerModule"]
        if AvatarCheckerModule_1 then
            AvatarCheckerModule_1.CheckAvatar = function() return true end
            AvatarCheckerModule_1.ReportException = function() end
        end

        local logic_memory_warning_1 = package.loaded["client.slua.logic.memory_warning.logic_memory_warning"]
        if logic_memory_warning_1 then
            logic_memory_warning_1.OnMemoryWarning = function() end
            logic_memory_warning_1.ReportMemoryWarning = function() end
        end

        local logic_store_game_interface_1 = package.loaded["client.slua.logic.store.logic_store_game_interface"]
        if logic_store_game_interface_1 then
            logic_store_game_interface_1.IsStoreGameSupported = function() return true end 
            logic_store_game_interface_1.NotifyGetPGSLoginInfo = function() end 
        end

        local VoiceChatSubsystem_1 = package.loaded["GameLua.Mod.BaseMod.Client.Voice.VoiceChatSubsystem"]
        if VoiceChatSubsystem_1 then
            VoiceChatSubsystem_1.OnPlayerSubmitComplaint = function() end
        end

        local TssSdk_1 = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk_1 then
            local var_206 = TssSdk_1.OnRecvData
            TssSdk_1.OnRecvData = function(data)
                if type(data) == "string" and (string.find(data, "report") or string.find(data, "exception") or string.find(data, "scan")) then
                    return
                end
                if var_206 then var_206(data) end
            end
            
            TssSdk_1.SendReportInfo = function() end
            TssSdk_1.ScanMemory = function() return true end
            TssSdk_1.IsEmulator = function() return false end
            TssSdk_1.GetTssSdkReportInfo = function() return "" end
            TssSdk_1.StartAntiData = function() end
            TssSdk_1.StopAntiData = function() end
        end
    end)
    print('[EnhancedScannerBlocker] Active!')
end

-- 3. REPLAY & TELEMETRY BLOCKER
function _G.InitializeReplayTelemetryBlocker()
    print('[ReplayBlocker] Initializing...')
    pcall(function()
        local SubsystemMgr_1 = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        
        local var_94 = SubsystemMgr_1 and SubsystemMgr_1:Get("RescueBtnReplayTraceSubsystem")
        if var_94 then
            var_94.ReportTrace = function() end
            var_94.StartTickMonitor = function() end
            var_94.TickMonitorCheck = function() end
            var_94.ReportTickMonitorHeartbeat = function() end
        end

        local var_80 = SubsystemMgr_1 and SubsystemMgr_1:Get("GameReportSubsystem")
        if var_80 then
            var_80.ReplayReportData = function() return false end
            var_80.CheckCanBugglyPostException = function() return false end
            var_80.BugglyPostExceptionFull = function() return false end
            var_80.GetClientReplayDataReporter = function() return nil end
            
            if var_80.Reporter then
                var_80.Reporter.ReportIntArrayData = function() end
                var_80.Reporter.ReportUInt8ArrayData = function() end
                var_80.Reporter.ReportFloatArrayData = function() end
            end
        end

        local logic_report_replay_1 = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logic_report_replay_1 then
            logic_report_replay_1.ReportReplay = function() end
            logic_report_replay_1.SendReportReq = function() end
        end

        local logic_home_report_1 = package.loaded["client.slua.logic.home.logic_home_report"]
        if logic_home_report_1 then
            logic_home_report_1.ShowInGameReportUI = function() end
            logic_home_report_1.SendReport = function() end
        end
    end)
    print('[ReplayBlocker] Active!')
end

-- 4. HIGGS BOSON DISABLER
function _G.DisableHiggsBoson()
    local var_163 = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not var_163 or not slua.isValid(var_163) then return end
    if var_163.HiggsBoson then
        var_163.HiggsBoson.bMHActive = false
        var_163.HiggsBoson.bCallPreReplication = false
        var_163.HiggsBoson.bIsDeviceMatch = false
        var_163.HiggsBoson.bIsEmulator = false
    end
    if var_163.HiggsBosonComponent then
        var_163.HiggsBosonComponent.bMHActive = false
        var_163.HiggsBosonComponent:ControlMHActive(0)
    end
end

-- 5. ANTI-CHEAT HOOKS
function _G.InitializeAntiCheatHooks()
    print('[AntiCheat] Initializing bypass system...')
    pcall(function()
        local HiggsBosonComponent_1 = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent_1 and HiggsBosonComponent_1.StaticShowSecurityAlertInDev then
            HiggsBosonComponent_1.StaticShowSecurityAlertInDev = function() end
        end
    end)

    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = function(HiggsBosonComponent_1) end
        _G.AvatarCheckCallback.OnReportItemID = function(HiggsBosonComponent_1) end
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(var_163)
            if slua.isValid(var_163) and var_163.HiggsBosonComponent then
                var_163.HiggsBosonComponent:ControlMHActive(0)
                var_163.HiggsBosonComponent.bMHActive = false
            end
        end
    end

    pcall(function()
        local HiggsBosonComponent_2 = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent_2 and HiggsBosonComponent_2.BlackList then
            for k in pairs(HiggsBosonComponent_2.BlackList) do HiggsBosonComponent_2.BlackList[k] = nil end
        end
    end)

    _G.BlackList = {}

    pcall(function()
        _G.GlobalPlayerCoronaData = _G.GlobalPlayerCoronaData or {}
        _G.GlobalPlayerCheatTimes = _G.GlobalPlayerCheatTimes or {}
        local mt = getmetatable(_G.GlobalPlayerCoronaData) or {}
        mt.__newindex = function(t, k, v) end
        setmetatable(_G.GlobalPlayerCoronaData, mt)
    end)

    pcall(function()
        if _G.GameSafeCallbacks and _G.GameSafeCallbacks.RecordStrategyTimestampInReplay then
            _G.GameSafeCallbacks.RecordStrategyTimestampInReplay = function(...) end
            _G.GameSafeCallbacks.DoAttackFlowStrategy = function() end
            _G.GameSafeCallbacks.GetScriptReportContent = function() return "" end
        end
    end)

    pcall(function()
        local STExtraBlueprintFunctionLibrary_1 = import("STExtraBlueprintFunctionLibrary")
        if STExtraBlueprintFunctionLibrary_1 then
            STExtraBlueprintFunctionLibrary_1.IsDevelopment = function() return false end
        end
    end)
    print('[AntiCheat] Bypass system activated!')
end

-- 6. ANTI-REPORT SYSTEM
function _G.InitializeAntiReport()
    print('[AntiReport] Initializing System...')
    pcall(function()
        local var_51 = { "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem" }
        local var_78 = nil
        for _, path in ipairs(var_51) do
            if package.loaded[path] then var_78 = package.loaded[path] break end
            local var_176, var_199 = pcall(require, path)
            if var_176 and var_199 then var_78 = var_199 break end
        end
        if var_78 then
            var_78.OnInit = function(self) return end
            var_78._OnPlayerKilledOtherPlayer = function() return end
            var_78._RecordFatalDamager = function() return end
            var_78._OnDeathReplayDataWhenFatalDamaged = function() return end
            var_78._RecordMurdererFromDeathReplayData = function() return end
            var_78._RecordTeammatePlayerInfo = function() return end
            var_78._OnBattleResult = function() return end
            var_78._OnShowQuickReportMutualExclusiveUI = function() return end
            var_78.GetFatalDamagerMap = function() return {} end
            var_78.GetCachedTeammateName2InfoMap = function() return {} end
            var_78.GetTeammateName2InfoMapDuringBattle = function() return {} end
            var_78.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
            var_78.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
        end
    end)

    pcall(function()
        local var_51 = { "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem", "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem" }
        local var_39 = nil
        for _, path in ipairs(var_51) do
            if package.loaded[path] then var_39 = package.loaded[path] break end
            local var_176, var_199 = pcall(require, path)
            if var_176 and var_199 then var_39 = var_199 break end
        end
        if var_39 then
            var_39.OnInit = function(self) return end
            var_39._OnNearDeathOrRescued = function() return end
            var_39._OnCharacterDied = function() return end
            var_39._OnTeammateDamage = function() return end
            var_39._OnPlayerSettlementStart = function() return end
            var_39._AddKnockDownerToBattleResult = function() return end
            var_39._AddKillerToBattleResult = function() return end
            var_39._AddTeammateMurderToBattleResult = function() return end
            var_39._AddFatalDamagerMapToBattleResult = function() return end
            var_39._AddMLKillerUIDToBattleResult = function() return end
            var_39._SaveHistoricalTeammateInfo = function() return end
            var_39._RecordFatalDamager = function() return end
            var_39._RecordTeammateMurderer = function() return end
        end
    end)

    pcall(function()
        local ReportPlayerUtils_1 = require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if ReportPlayerUtils_1 then
            ReportPlayerUtils_1.RecordFatalDamager = function() return end
            ReportPlayerUtils_1.IsUsingHistoricalTeammateInfo = function() return false end
            ReportPlayerUtils_1.IsCharacterDeliverAI = function() return false end
        end
    end)

    pcall(function()
        local SecurityCommonUtils_1 = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if SecurityCommonUtils_1 then
            SecurityCommonUtils_1.ExtractPlayerBasicInfo = function() return {} end
            SecurityCommonUtils_1.LogIf = function() return false end
        end
    end)

    pcall(function()
        local ClientQuickReportMaliciousTeammate_1 = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
        if ClientQuickReportMaliciousTeammate_1 then
            ClientQuickReportMaliciousTeammate_1.OnShowMutualExclusiveUI = function() return end
            ClientQuickReportMaliciousTeammate_1.OnHideMutualExclusiveUI = function() return end
        end
    end)
    print('[AntiReport] System Fully Active!')
end

-- 7. GAMEPLAY BYPASS
function _G.InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks or _G.GameplayCallbacks.IsBypassed then return end
        
        local GC = _G.GameplayCallbacks
        print('[GameplayBypass] Hooking GameplayCallbacks...')
        
        local var_129 = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            if InPlayerState and string.lower(tostring(InPlayerState)) == "cheatdetected" then return end
            if var_129 then return var_129(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason) end
        end

        local function func() return end
        local function func_9() return {} end
        local function func_3() return nil end
        
        GC.ReportAttackFlow = func
        GC.ReportSecAttackFlow = func
        GC.ReportHurtFlow = func
        GC.ReportFireArms = func
        GC.ReportVerifyInfoFlow = func
        GC.ReportMrpcsFlow = func
        GC.ReportPlayerBehavior = func
        GC.ReportTeammatHurt = func
        GC.ReportMisKillByTeammate = func
        GC.ReportForbitPick = func
        GC.ReportPlayerMoveRoute = func
        GC.ReportPlayerPosition = func
        GC.ReportVehicleMoveFlow = func
        GC.ReportSecTgameMovingFlow = func
        GC.ReportParachuteData = func
        GC.SendTssSdkAntiDataToLobby = func
        GC.SendDSErrorLogToLobby = func
        GC.SendDSErrorLogToLobbyOnece = func
        GC.SendDSHawkEyePatrolLogToLobby = func
        GC.ReportEquipmentFlow = func
        GC.ReportAimFlow = func
        GC.GetWeaponReport = func_9
        GC.GetOneWeaponReport = func_9
        GC.ReportHeavyWeaponBoxSpawnFlow = func
        GC.ReportHeavyWeaponBoxActivationFlow = func
        GC.ReportHeavyWeaponBoxOpenPlayerFlow = func
        GC.ReportHeavyWeaponBoxItemFlow = func
        GC.ReportPlayersPing = func
        GC.ReportPlayerIP = func
        GC.ReportPlayerFramePingRecord = func
        GC.OnDSConnectionSaturated = func
        GC.ReportDSNetSaturation = func
        GC.ReportNetContinuousSaturate = func
        GC.ReportDSNetRate = func
        GC.SendClientStats = func
        GC.SendServerAvgTickDelta = func
        GC.ReportCircleFlow = func
        GC.ReportDSCircleFlow = func
        GC.ReportJumpFlow = func
        GC.ReportAIStrategyInfo = func
        GC.SendAIDeliveryInfo = func
        GC.ReportDailyTaskInfo = func
        GC.ReportMatchRoomData = func
        GC.SendPlayerSpectatingLog = func
        GC.ReportIDCardProduceFlow = func
        GC.ReportIDCardPickUpFlow = func
        GC.ReportIDCardDestroyFlow = func
        GC.ReportRevivalFlow = func
        GC.ReportGameSetting = func
        GC.ReportGameSettingNew = func
        GC.ReportAntsVoiceTeamCreate = func
        GC.ReportAntsVoiceTeamQuit = func
        GC.ReportCommonInfo = func
        GC.ReportLightweightStat = func
        GC.SendSecTLog = func
        GC.SendDataMiningTLog = func
        GC.SendActivityTLog = func
        GC.GetGeneralTLogData = func_3
        
        GC.IsBypassed = true
    end)

    pcall(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.IsBypassed then
            local var_240 = NetUtil.SendPacket
            local var_227 = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportForbiddenPickupFlow"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1,
                ["ReportSecVehicleMoveFlow"]=1, ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1,
                ["report_character_all_drag"]=1, ["report_parachute_all_drag"]=1, ["report_vehicle_move_drag"]=1,
                ["on_tss_sdk_anti_data"]=1, ["report_unrealnet_exception"]=1, ["ReportPlayerEquipmentInfo"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["log_shooting_miss"]=1, ["report_heavy_weapon_box_activation_flow"]=1,
                ["report_heavy_weapon_box_item_flow"]=1, ["ReportCircleFlow"]=1, ["report_ds_player_circle_flow"]=1,
                ["ReportJumpFlow"]=1, ["ReportGameStartFlow"]=1, ["ReportGameEndFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_player_frame_ping_record"]=1, ["report_net_saturate"]=1,
                ["report_ds_netsaturate"]=1, ["report_ds_net_continuous_saturate"]=1, ["report_ds_netrate"]=1,
                ["report_unrealnet_clientstats"]=1, ["report_serverstat_avgtickdelta"]=1, ["report_all_players_address"]=1,
                ["report_ai_strategyinfo"]=1, ["ReportAIActionFlow"]=1, ["ReportGenerateMonsterFlow"]=1,
                ["report_ds_match_room_data"]=1, ["SendSpectatingLog"]=1, ["ReportIDCardProduceFlow"]=1,
                ["ReportIDCardPickUpFlow"]=1, ["ReportIDCardDestroyFlow"]=1, ["ReportRevivalFlow"]=1,
                ["ReportGameSetting"]=1, ["ReportGameSettingNew"]=1, ["ReportAntsVoiceTeamCreate"]=1,
                ["ReportAntsVoiceTeamQuit"]=1, ["report_common_info"]=1, ["report_common_battle_info"]=1,
                ["report_client_scan_result"]=1, ["tss_sdk_report"]=1, ["report_memory_exception"]=1,
                ["report_avatar_exception"]=1, ["report_ui_state"]=1, ["report_hit_reg_fail"]=1,
                ["report_character_state"]=1, ["report_vehicle_exception"]=1, ["report_camera_exception"]=1,
                ["ReportPlayerControllerStateChanged"]=1, ["ReportAvatarFlow"]=1,
                ["send_ugc_report_uni_mod_expose_req"]=1, 
                ["send_ugc_report_uni_mod_interactive_req"]=1,
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if var_227[packetName] then return end
                return var_240(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
    end)
end

-- 8. CONNECTION GUARD
function _G.InitializeConnectionGuard()
    pcall(function()
        if _G.ConnectionGuardInitialized or not _G.GameplayCallbacks then return end
        print('[ConnectionGuard] Initializing Shield...')
        
        local GC = _G.GameplayCallbacks
        local var_129 = GC.OnDSPlayerStateChanged

        GC.OnDSPlayerStateChanged = function(UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            local var_212 = InPlayerState and string.lower(tostring(InPlayerState)) or ""
            local var_125 = {
                ["cheatdetected"] = true, ["connectionlost"] = true,
                ["connectiontimeout"] = true, ["connectionexception"] = true,
                ["netdrivererror"] = true
            }
            if var_125[var_212] then return end
            if var_129 then
                pcall(var_129, UID, InPlayerState, bPureWatcher, bIsSafeExit, ParamReason)
            end
        end

        GC.OnPlayerNetConnectionClosed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerActorChannelError = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerRPCValidateFailed = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnPlayerSpectateException = function(GameID, UID, Reason, ErrorMessage) end
        GC.OnShutdownAfterError = function(GameID) end

        _G.ConnectionGuardInitialized = true
        print('[ConnectionGuard] Active & Protecting!')
    end)
end

-- 9. ZR/PR BYPASSES
function _G.InitializeZRPRBypasses()
    print('[Bypass] Initializing ZR and PR Bypasses...')
    pcall(function()
        local noop = function() end
        local returnTrue = function() return true end
        local returnZero = function() return 0 end
        local returnEmpty = function() return {} end
        local returnFalse = function() return false end

        local stExtraBlueprint = import("STExtraBlueprintFunctionLibrary")
        if stExtraBlueprint then 
            stExtraBlueprint.IsDevelopment = returnTrue 
        end

        if _G.BasicDataTLogReport then
            _G.BasicDataTLogReport.OnSendBatchReqMsg = noop
            _G.BasicDataTLogReport.OnImmediateReqMsg = noop
            _G.BasicDataTLogReport.send_report_event_duration_log = noop
            _G.BasicDataTLogReport.SendTlog = noop
        end

        if _G.TApmHelper then 
            _G.TApmHelper.postEvent = noop 
        end

        local sdm = _G.ServerDataMgr
        if sdm and sdm.DeletablePlayerResultKey then
            sdm.DeletablePlayerResultKey["SuspiciousHitCount"] = true
            sdm.DeletablePlayerResultKey["EspTotalSimTraceCnt"] = true
            sdm.DeletablePlayerResultKey["EspTotalImeFocusCnt"] = true
            sdm.DeletablePlayerResultKey["ClientGravityAnomalyCount"] = true
        end

        local hiaPath = "GameLua.Mod.BaseMod.Client.Security.ClientGlueHiaSystem"
        local hia = package.loaded[hiaPath] or require(hiaPath)
        if hia then
            hia.CheckHitIntegrity = returnTrue
            hia.InitSession = noop
            hia.OnBattleEnd = noop
        end
        if _G.ClientGlueHiaSystem then 
            _G.ClientGlueHiaSystem.CheckHitIntegrity = returnTrue 
        end

        local secUtilsPath = "GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils"
        local secUtils = package.loaded[secUtilsPath] or require(secUtilsPath)
        if secUtils and secUtils.EStrategyTypeInReplay then
            secUtils.EStrategyTypeInReplay.EspTotalSimTraceCnt = 0
            secUtils.EStrategyTypeInReplay.EspTotalImeFocusCnt = 0
            secUtils.EStrategyTypeInReplay.ClientGravityAnomalyCount = 0
            secUtils.EStrategyTypeInReplay.FlyingErrorCnt = 0
        end

        local pcNotifyPath = "GameLua.Mod.BaseMod.Common.Security.SecurityNotifyPCFeature"
        local pcNotify = package.loaded[pcNotifyPath] or require(pcNotifyPath)
        if pcNotify then
            pcNotify.ClientRPC_SyncBanID = noop
            pcNotify.ClientRPC_StrongTips = noop
            pcNotify.ClientRPC_NormalTips = noop
            pcNotify.Notify = noop
        end

        local SubsystemMgr = package.loaded["GameLua.GameCore.Module.Subsystem.SubsystemMgr"] or require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local patrolSubsystem = SubsystemMgr:Get("DSHawkEyePatrolSubsystem")
            if patrolSubsystem then 
                patrolSubsystem.MarkSuspiciousPlayer = noop 
            end
        end

        local clientBanLogicPath = "client.slua.logic.ban.ClientBanLogic"
        local ClientBanLogic = package.loaded[clientBanLogicPath] or require(clientBanLogicPath)
        if ClientBanLogic then
            ClientBanLogic.OnSyncBanInfo = noop
            ClientBanLogic.OnVoiceBanNotify = noop
        end

        local ttBanPath = "client.slua.logic.login.logic_tt_ban"
        local logic_tt_ban = package.loaded[ttBanPath] or require(ttBanPath)
        if logic_tt_ban then
            logic_tt_ban.GetCarrierInfo = function() return "[{\"mcc\":\"000\"}]" end
            logic_tt_ban.CheckIfCanCreateRole = returnTrue
        end

        local znq6Path = "GameLua.Mod.TDEvent.ZNQ6th.DS.ZNQ6thDSReviveSubsystem"
        local znq6Revive = package.loaded[znq6Path] or require(znq6Path)
        if znq6Revive then 
            znq6Revive.HaveNewItemForRevive = returnTrue 
        end
        local znq7Path = "GameLua.Mod.TDEvent.ZNQ7th.DS.ZNQ7DSReviveSubsystem"
        local znq7Revive = package.loaded[znq7Path] or require(znq7Path)
        if znq7Revive then 
            znq7Revive.HaveChanceRevival = returnTrue 
        end

        local dataLayerPath = "GameLua.Mod.BaseMod.Common.Subsystem.DataLayerSubsystem"
        local DataLayer = package.loaded[dataLayerPath] or require(dataLayerPath)
        if DataLayer then
            local origOnSpectator = DataLayer.OnSpectatorReplayChanged
            DataLayer.OnSpectatorReplayChanged = function(dlSelf)
                _G.IsBeingWatched = true
                if origOnSpectator then 
                    pcall(origOnSpectator, dlSelf) 
                end
            end
        end

        local dsActivePath = "GameLua.Mod.PlanBT.Gameplay.Subsystem.DSActiveSubsystem"
        local DSActive = package.loaded[dsActivePath] or require(dsActivePath)
        if DSActive then
            DSActive.DelayKickOutPlayer = noop
            DSActive.ActiveKickNotify = noop
        end

        local devDebugPath = "GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeDevDebugSubsystem"
        local CreativeDevDebug = package.loaded[devDebugPath] or require(devDebugPath)
        if CreativeDevDebug then 
            CreativeDevDebug.IsDebugPanelEnalbedCli = returnTrue 
        end
        local deathRecordPath = "GameLua.Mod.CreativeBase.Gameplay.Subsystem.CreativeModeDeathRecordSubsystem"
        local CreativeDeath = package.loaded[deathRecordPath] or require(deathRecordPath)
        if CreativeDeath then 
            CreativeDeath.OnPlayerKilled = noop 
        end

        local dsAITLogPath = "GameLua.Mod.BaseMod.DS.Security.DSAITLogSubsystem"
        local DSAITLog = package.loaded[dsAITLogPath] or require(dsAITLogPath)
        if DSAITLog then
            DSAITLog._UpdateTTKRecords = noop
            DSAITLog._UpdateOperatingFrequency = noop
        end
        local dsFightTLogPath = "GameLua.Mod.BaseMod.DS.Security.DSFightTLogSubsystem"
        local DSFightTLog = package.loaded[dsFightTLogPath] or require(dsFightTLogPath)
        if DSFightTLog then 
            DSFightTLog.GetSimpleFightData = returnEmpty 
        end
        local dsSecurityPath = "GameLua.Mod.BaseMod.DS.Security.DSSecurityTLogSubsystem"
        local DSSecurity = package.loaded[dsSecurityPath] or require(dsSecurityPath)
        if DSSecurity then 
            DSSecurity._OnReportServerJumpFlow = noop 
        end
        local dsCommonPath = "GameLua.Mod.BaseMod.DS.Security.DSCommonTLogSubsystem"
        local DSCommon = package.loaded[dsCommonPath] or require(dsCommonPath)
        if DSCommon then 
            DSCommon.HandleKillTlog = noop 
        end
        local dsReportPath = "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"
        local DSReport = package.loaded[dsReportPath] or require(dsReportPath)
        if DSReport then 
            DSReport._AddEnemyMapToBattleResult = noop 
        end

        local highlightDSPath = "GameLua.Mod.BaseMod.DS.Security.HighlightMomentSubsystem_DSChecker"
        local HighlightDS = package.loaded[highlightDSPath] or require(highlightDSPath)
        if HighlightDS then 
            HighlightDS.CheckFuncUpgradedWeaponKill = noop 
        end
        local icTLogPath = "GameLua.Mod.BaseMod.DS.Security.ICTLogSubsystem"
        local ICTLog = package.loaded[icTLogPath] or require(icTLogPath)
        if ICTLog then 
            ICTLog.SendICExceptionTLog = noop 
        end

        local inspectClientPath = "GameLua.Mod.BaseMod.Client.Security.InspectionSystemReportClientLogicSubsystem"
        local InspectClient = package.loaded[inspectClientPath] or require(inspectClientPath)
        if InspectClient then
            InspectClient.AskForInspector = noop
            InspectClient.ReportEnemy = noop
            InspectClient.KickOutOneTeam = noop
        end
        local inspectDSPath = "GameLua.Mod.BaseMod.DS.Security.InspectionSystemReportDSLogicSubsystem"
        local InspectDS = package.loaded[inspectDSPath] or require(inspectDSPath)
        if InspectDS then
            InspectDS.ServerKickOutOneTeamByPlayerImplementation = noop
            InspectDS.AddReportedCount = noop
        end

        local spectateReplayPath = "GameLua.Mod.BaseMod.Common.Subsystem.SpectateAndReplaySubsystem"
        local SpectateReplay = package.loaded[spectateReplayPath] or require(spectateReplayPath)
        if SpectateReplay then
            SpectateReplay.RequestGotoSpectatingImp = noop
            SpectateReplay.RequestGotoSpectating = noop
        end
        local clientHawkEyePath = "GameLua.Mod.BaseMod.Client.Security.ClientHawkEyePatrolSubsystem"
        local ClientHawkEye = package.loaded[clientHawkEyePath] or require(clientHawkEyePath)
        if ClientHawkEye then
            ClientHawkEye._OnHawkSync = noop
            ClientHawkEye._OnHawkReportSuccess = noop
            ClientHawkEye._StartExitGameTimer = noop
        end
        local behaviorScorePath = "GameLua.Mod.Escape.Gameplay.Subsystem.BehaviorScoreSubsystem"
        local BehaviorScore = package.loaded[behaviorScorePath] or require(behaviorScorePath)
        if BehaviorScore then
            BehaviorScore.OnHandleBehaviorScore = noop
            BehaviorScore.AIPerceptionScore = noop
        end

        local aiReplayPath = "GameLua.ExtraModule.MLAI.Client.AIReplaySubsystem"
        local AIReplay = package.loaded[aiReplayPath] or require(aiReplayPath)
        if AIReplay then
            AIReplay.ReportAllPlayerInfo = noop
            if AIReplay.uCompletePlayBack then 
                AIReplay.uCompletePlayBack.AddRecordMLAIInfo = noop 
            end
        end
        local aiTrackingPath = "GameLua.Mod.BaseMod.GamePlay.AI.AITrackingLogSubsystem"
        local AITracking = package.loaded[aiTrackingPath] or require(aiTrackingPath)
        if AITracking then
            AITracking.RealLogoutTimer = noop
            AITracking.LogQueue = {}
        end
        local tdmAFKPath = "GameLua.Mod.TDM.Gameplay.Subsystem.TDMAFKReportorSubsystem"
        local TDMAFK = package.loaded[tdmAFKPath] or require(tdmAFKPath)
        if TDMAFK then
            TDMAFK.SendAFKTips = noop
            TDMAFK.OnHandleLostConnection = noop
        end

        local dataMgrPath = "client.slua.logic.data.data_mgr"
        local DataMgr = package.loaded[dataMgrPath] or _G.DataMgr
        if DataMgr then
            DataMgr.GetWeaponSkinSoundVolumeInfoByGroup = function() return 0 end
        end
    end)
    print('[Bypass] OFFICIAL VIPER XVINAY Bypasses Initialized successfully!')
end

-- 10. DAMAGE VALIDATION BYPASS
function _G.InitializeDamageValidationBypass()
    print('[DamageBypass] Initializing damage validation bypass...')
    pcall(function()
        local DamageHandler = package.loaded["GameLua.Mod.BaseMod.GamePlay.Damage.DamageHandler"] or _G.DamageHandler
        if DamageHandler then
            if DamageHandler.CalculateDamage then
                local origCalc = DamageHandler.CalculateDamage
                DamageHandler.CalculateDamage = function(...)
                    local result = origCalc(...)
                    if result and result > 0 and result < 200 then
                        return result
                    end
                    return 30
                end
            end
            if DamageHandler.ValidateDamage then
                DamageHandler.ValidateDamage = function() return true end
            end
        end

        local HitHandler = package.loaded["GameLua.Mod.BaseMod.GamePlay.Hit.HitHandler"] or _G.HitHandler
        if HitHandler then
            if HitHandler.ValidateHit then
                HitHandler.ValidateHit = function() return true end
            end
            if HitHandler.ReportHit then
                HitHandler.ReportHit = function() end
            end
        end

        local WeaponEntity = import("ShootWeaponEntity")
        if WeaponEntity then
            if WeaponEntity.CalculateShotDamage then
                local origShot = WeaponEntity.CalculateShotDamage
                WeaponEntity.CalculateShotDamage = function(self, ...)
                    local result = origShot(self, ...)
                    if result and result > 0 and result < 200 then
                        return result
                    end
                    return 25
                end
            end
        end
    end)
    print('[DamageBypass] Active!')
end

-- 11. ULTIMATE REPORT CLEARER
function _G.InitializeReportClearer()
    print('[ReportClearer] Initializing report flag clearer...')
    pcall(function()
        local function ClearReportFlags()
            local pc = GameplayData.GetPlayerController()
            if not slua.isValid(pc) then return end
            local ps = pc:GetPlayerState()
            if not slua.isValid(ps) then return end
            
            if ps.SuspiciousFlags then ps.SuspiciousFlags = {} end
            if ps.SuspiciousCount then ps.SuspiciousCount = 0 end
            if ps.ReportFlags then ps.ReportFlags = {} end
            if ps.CheatFlags then ps.CheatFlags = {} end
            if ps.bIsSuspicious then ps.bIsSuspicious = false end
            if ps.bIsReported then ps.bIsReported = false end
            if ps.bIsCheater then ps.bIsCheater = false end
            if ps.bIsBanned then ps.bIsBanned = false end
        end

        local clearTimer = nil
        clearTimer = _G.AddGameTimer and _G:AddGameTimer(5.0, true, function()
            pcall(ClearReportFlags)
        end) or nil

        local PlayerStateClass = import("PlayerState")
        if PlayerStateClass then
            local origInit = PlayerStateClass.Init
            PlayerStateClass.Init = function(self, ...)
                local result = origInit(self, ...)
                self.SuspiciousFlags = {}
                self.SuspiciousCount = 0
                self.bIsSuspicious = false
                self.bIsReported = false
                self.bIsCheater = false
                self.bIsBanned = false
                return result
            end
        end
    end)
    print('[ReportClearer] Active!')
end

-- ==============================================
-- VIPER METHODS ON BRPlayerCharacterBase
-- ==============================================

function BRPlayerCharacterBase:ctor()
    self.bHasShownDevNotice = false 
    self.ESP_Timer = nil
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
  self:StartAdvancedSystems()
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  
  self:ForceEnableGiveUp()
  
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = {
        "bCanSelfRescue"
      }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
    self:AddControlEvent(self, "OnAttachedToVehicle", self.HandleOnAttachedToVehicle, self)
    self:AddControlEvent(self, "OnDetachedFromVehicle", self.HandleOnDetachedFromVehicle, self)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end

  EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client and GameplayData.RemoveCharacter ~= nil then
    GameplayData.RemoveCharacter(self.Object)
  end
  if self.ESP_Timer then
    self:RemoveGameTimer(self.ESP_Timer)
    self.ESP_Timer = nil
  end
end

-- ==============================================
-- VIPER GIVE UP SYSTEM
-- ==============================================

function BRPlayerCharacterBase:ForceEnableGiveUp()
    if not slua.isValid(self.Object) then return end
    self.bCanNearDeathGiveup = true
    print("[GIVEUP] Give up force enabled")
end

function BRPlayerCharacterBase:TriggerGiveUp()
    if not slua.isValid(self.Object) then return end
    
    print("[GIVEUP] Manual give up triggered")
    
    self.bCanNearDeathGiveup = true
    
    if self.Role == ENetRole.ROLE_AutonomousProxy then
        self:ServerRPC_NearDeathGiveupRescue()
        print("[GIVEUP] Give up RPC sent to server")
    else
        self:HandleNearDeathGiveupRescue()
        print("[GIVEUP] Give up handled directly on server")
    end
end

function BRPlayerCharacterBase:EmergencyGiveUp()
    if not slua.isValid(self.Object) then return end
    
    print("[GIVEUP] EMERGENCY give up triggered")
    
    local uNearDeathComp = self.NearDeatchComponent
    if slua.isValid(uNearDeathComp) then
        pcall(function()
            uNearDeathComp:TriggerGotoDieExplictly(self.Object)
            print("[GIVEUP] Emergency kill via NearDeathComponent")
        end)
    end
    
    pcall(function()
        self.Health = 0
        if self.SetHealth then
            self:SetHealth(0)
        end
        if self.bIsDead then
            self.bIsDead = true
        end
        if self.bIsDeadFlag then
            self.bIsDeadFlag = true
        end
        print("[GIVEUP] Emergency kill via health set to 0")
    end)
    
    pcall(function()
        if self.Role == ENetRole.ROLE_AutonomousProxy then
            self:ServerRPC_NearDeathGiveupRescue()
        end
    end)
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
    print("[GIVEUP] HandleNearDeathGiveupRescue called")
    
    local uNearDeathComp = self.NearDeatchComponent
    
    if not slua.isValid(uNearDeathComp) then
        print("[GIVEUP] NearDeathComponent is invalid, attempting to find it")
        uNearDeathComp = self:GetComponentByClass(import("NearDeathComponent"))
        if slua.isValid(uNearDeathComp) then
            self.NearDeatchComponent = uNearDeathComp
            print("[GIVEUP] NearDeathComponent found and assigned")
        end
    end
    
    if not slua.isValid(uNearDeathComp) then
        print("[GIVEUP] NearDeathComponent not found - cannot give up")
        return
    end
    
    if not self:IsNearDeath() then
        pcall(function()
            if uNearDeathComp.SetNearDeathState then
                uNearDeathComp:SetNearDeathState(true)
            end
        end)
    end
    
    self.bCanNearDeathGiveup = true
    print("[GIVEUP] bCanNearDeathGiveup forced to true")
    
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
        uPlayerState:AddGeneralCount(1613, 1, false)
        print("[GIVEUP] Give up logged to player state")
    end
    
    local success = pcall(function()
        uNearDeathComp:TriggerGotoDieExplictly(self.Object)
        print("[GIVEUP] Player killed via give up")
    end)
    
    if not success or self:IsNearDeath() then
        print("[GIVEUP] Fallback: setting health to 0")
        self.Health = 0
        if self.SetHealth then
            self:SetHealth(0)
        end
        if self.bIsDead then
            self.bIsDead = true
        end
        if self.bIsDeadFlag then
            self.bIsDeadFlag = true
        end
    end
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
    print("[GIVEUP] ServerRPC_NearDeathGiveupRescue called")
    self:HandleNearDeathGiveupRescue()
end

-- ==============================================
-- VIPER ADVANCED SYSTEMS
-- ==============================================

function BRPlayerCharacterBase:StartAdvancedSystems()
    if not Client then return end
    
    self:AddGameTimer(0.1, true, function()
        if not slua.isValid(self.Object) then return end
        
        self.bCanNearDeathGiveup = true
        
        local GameplayData_2 = GameplayData.GetPlayerCharacter()
        if not slua.isValid(GameplayData_2) then return end

        if self.Object == GameplayData_2 and not self.bHasShownDevNotice then
            if self.Object.IsAlive and self.Object:IsAlive() then
                self.bHasShownDevNotice = true
                print("[VIPER] MOD ACTIVE! Open Settings -> VIPER MOD")
                pcall(function() _G.ShowVIPERSpawnBanner() end)
            end
        end

        -- iPad View
        local var_162 = _G.VIPER_GetVal("IPAD_VIEW_TPP")
        if var_162 == 0 or var_162 < 90 then var_162 = 90 end
        
        local var_216 = _G.VIPER_GetVal("IPAD_VIEW_FPP")
        if var_216 == 0 or var_216 < 103 then var_216 = 103 end
        
        local var_116 = self.Object.ThirdPersonCameraComponent
        local var_192 = self.Object.FirstPersonCameraComponent
        local var_228 = self.Object.bIsWeaponAiming or false
        
        if not var_228 then
            if slua.isValid(var_116) and var_162 > 90 then 
                var_116:SetFieldOfView(var_162)
                var_116.FieldOfView = var_162 
            end
            if slua.isValid(var_192) and var_216 > 103 then 
                var_192:SetFieldOfView(var_216)
                var_192.FieldOfView = var_216 
            end
        end

        -- Weapon Mods (Clamped to avoid fake damage)
        if self.Object.GetCurrentWeapon then
            local var_120 = self.Object:GetCurrentWeapon()
            if slua.isValid(var_120) then
                local var_224 = os.clock()
                if self.LastWeaponEntity ~= var_120 then
                    self.LastWeaponEntity = var_120
                    self.bForceWeaponMod = true
                end
                
                if not self.LastWeaponModTime or var_224 > self.LastWeaponModTime + 2.0 then
                    self.bForceWeaponMod = true
                    self.LastWeaponModTime = var_224
                end
                
                if self.bForceWeaponMod or not var_120.bIsVIPERXVINAYded then
                    pcall(function()
                        local var_27 = var_120.ShootWeaponEntity_GEN_VARIABLE or var_120.ShootWeaponEntity
                        if slua.isValid(var_27) then
                            -- CLAMP VALUES TO SAFE RANGES TO PREVENT FAKE DAMAGE
                            local var_128 = math.max(0, math.min(0.6, _G.VIPER_GetVal("THU_TAM") / 100.0))
                            local var_127 = math.max(0, math.min(0.6, _G.VIPER_GetVal("GIAM_GIAT_NGANG") / 100.0))
                            local var_67 = math.max(0, math.min(0.6, _G.VIPER_GetVal("GIAM_GIAT_DOC") / 100.0))
                            local var_36 = math.max(0, math.min(0.6, _G.VIPER_GetVal("GIAM_RUNG_SCOPE") / 100.0))
                            
                            -- Never let deviation go below 1.0 to avoid server-side damage detection
                            local baseDeviation = 3.36
                            var_27.GameDeviationFactor = math.max(1.0, baseDeviation - (baseDeviation * var_128))
                            
                            -- Recoil factors - keep them above 0.3 to avoid zero-recoil detection
                            local baseHRecoil = 0.80
                            var_27.AccessoriesHRecoilFactor = math.max(0.3, baseHRecoil - (baseHRecoil * var_127))
                            
                            local baseVRecoil = 0.50
                            var_27.AccessoriesVRecoilFactor = math.max(0.2, baseVRecoil - (baseVRecoil * var_67))
                            
                            local baseRecoilKick = 0.20
                            var_27.RecoilKickADS = math.max(0.1, baseRecoilKick - (baseRecoilKick * var_36))

                            -- Aimbot (only if enabled and within safe bounds)
                            if _G.VIPER_GetVal("AIMBOT") == 1 then
                                if var_27.AutoAimingConfig then
                                    local var_76 = var_27.AutoAimingConfig
                                    local var_143 = math.max(0, math.min(1.0, _G.VIPER_GetVal("SPEED_AIMBOT") / 100.0))
                                    local var_123 = math.max(0, math.min(1.0, _G.VIPER_GetVal("FOV_AIMBOT") / 100.0))
                                    
                                    -- Safe speed range 3.0 to 5.5 (not too aggressive)
                                    local var_178 = 3.0 + (2.5 * var_143)
                                    local var_115 = 3.0 + (2.5 * var_123)
                                    
                                    if var_76.OuterRange then
                                        var_76.OuterRange.Speed = var_178
                                        var_76.OuterRange.SpeedRate = var_178
                                        var_76.OuterRange.RangeRate = var_115
                                        var_76.OuterRange.RangeRateSight = var_115
                                        var_76.OuterRange.SpeedRateSight = var_178
                                        var_76.OuterRange.CrouchRate = 1.0
                                        var_76.OuterRange.ProneRate = 1.0
                                        var_76.OuterRange.DyingRate = 0
                                    end
                                    if var_76.InnerRange then
                                        var_76.InnerRange.Speed = var_178
                                        var_76.InnerRange.SpeedRate = var_178
                                        var_76.InnerRange.RangeRate = var_115
                                        var_76.InnerRange.RangeRateSight = var_115
                                        var_76.InnerRange.SpeedRateSight = var_178
                                        var_76.InnerRange.CrouchRate = 1.0
                                        var_76.InnerRange.ProneRate = 1.0
                                        var_76.InnerRange.DyingRate = 0
                                    end
                                    var_27.AutoAimingConfig = var_76
                                end
                            end
                        end
                    end)
                    var_120.bIsVIPERXVINAYded = true
                    self.bForceWeaponMod = false
                end
            end
        end
        
        -- ESP
        if not self.ESP_Timer and (self.Object == GameplayData_2) then
            self.ESP_Timer = self:AddGameTimer(0.08, true, function()
                if slua.isValid(self.Object) and self.Object.IsAlive and self.Object:IsAlive() then
                    MainESP()
                end
            end)
        end
    end)
end

-- ==============================================
-- VIPER ORIGINAL METHODS (preserved)
-- ==============================================

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then
    return
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfigDisable then
    local EDynamicSimpleQueryConfigDisableMask = import("EDynamicSimpleQueryConfigDisableMask")
    self.STCharacterMovement:SetDynamicSimpleQueryConfigDisable(EDynamicSimpleQueryConfigDisableMask.Bit0, true)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local uGameState = GameplayData:GetGameState()
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
    local vRelativeRot = self.Mesh.RelativeRotation
    local vBaseRotationOffset = self.BaseRotationOffset
    local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
    print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
  end
end

function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:HandleOnAttachedToVehicle(var_131)
    if not slua.isValid(var_131) then return end
    print(bWriteLog and string.format("BRPlayerCharacterBase:HandleOnAttachedToVehicle", Game:GetObjName(var_131)))
    if self.Role == ENetRole.ROLE_SimulatedProxy then
        self:ClearAttachToVehicleTimer()
        self.nUpdatePlayerAttachToVehicleCount = 0
        self.nUpdatePlayerAttachToVehicleTimer = self:AddGameTimer(5, true, function()
            if slua.isValid(self.Object) and slua.isValid(var_131) then
                self:UpdatePlayerAttachToVehicle(var_131)
            end
        end)
        self.nFixMeshContainerTimer = self:AddGameTimer(3, true, function()
            if slua.isValid(self.Object) and slua.isValid(var_131) then
                self:FixMeshContainerOffsetIfNeeded(var_131)
            end
        end)
    end
end

function BRPlayerCharacterBase:HandleOnDetachedFromVehicle(uLastVehicle)
    if not slua.isValid(uLastVehicle) then return end
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnDetachedFromVehicle", uLastVehicle)
    if self.Role == ENetRole.ROLE_SimulatedProxy then
        self:ClearAttachToVehicleTimer()
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
end

function BRPlayerCharacterBase:UpdatePlayerAttachToVehicle(var_131)
    if not slua.isValid(self.Object) or not slua.isValid(var_131) then return end
    if not (slua.isValid(self.CapsuleComponent) and slua.isValid(self.Mesh)) or not slua.isValid(self.MeshContainer) then return end
    if not slua.isValid(self:GetCurrentVehicle()) then return end
    if Game:IsDriver(self.Object) then return end
    if not self.nUpdatePlayerAttachToVehicleCount then self.nUpdatePlayerAttachToVehicleCount = 0 end
    
    local ESTEPoseState_1 = import("ESTEPoseState")
    local var_177 = self.PoseState == ESTEPoseState_1.Stand
    local var_4 = self.CapsuleComponent:GetRelativeTransform():GetLocation()
    local var_196 = self.Mesh:GetRelativeTransform():GetLocation()
    local var_38 = self.MeshContainer:GetRelativeTransform():GetLocation().Z
    local var_71 = self.CapsuleComponent:GetScaledCapsuleRadius()
    local var_75 = self.CapsuleComponent:GetScaledCapsuleHalfHeight()
    local var_5 = -1 * self.StandHalfHeight
    local var_207 = self.StandRadius
    local var_154 = self.StandHalfHeight
    local var_25 = FVector(0, 0, 0)
    local var_102 = FVector(0, 0, self.StandHalfHeight)
    local var_35 = 1.0
    local var_200 = var_4:Equals(var_102, var_35)
    local var_149 = var_196:Equals(var_25, var_35)
    local var_42 = var_35 > math.abs(var_38 - var_5)
    local var_118 = var_35 > math.abs(var_71 - var_207)
    local var_28 = var_35 > math.abs(var_75 - var_154)
    local var_104 = var_177 and var_200 and var_149 and var_42 and var_118 and var_28
    
    if not var_104 then self.nUpdatePlayerAttachToVehicleCount = self.nUpdatePlayerAttachToVehicleCount + 1 else self.nUpdatePlayerAttachToVehicleCount = 0 end
    
    if self.nUpdatePlayerAttachToVehicleCount >= 3 and not var_104 then
        local var_235 = GameplayData.GetPlayerController()
        if var_235.ReportCrashKitFeature and var_235.ReportCrashKitFeature.ReportCharacterAttachedOnVehicleException then
            local var_14 = string.format("VehicleShapeType:%s PlayerKey:%s. Check Result:%d %d %d %d %d %d. Capsule.RelativeLoc:%s Capsule.Radius:%s Capsule.HalfHeight:%s Mesh.RelativeLoc:%s MeshContainer.RelativeLocZ:%s", tostring(var_131.VehicleShapeType), tostring(self.PlayerKey), var_177 and 1 or 0, var_200 and 1 or 0, var_149 and 1 or 0, var_42 and 1 or 0, var_118 and 1 or 0, var_28 and 1 or 0, var_4:ToString(), tostring(var_71), tostring(var_75), var_196:ToString(), tostring(var_38))
            var_235.ReportCrashKitFeature:ReportCharacterAttachedOnVehicleException(var_14)
        end
        self.nUpdatePlayerAttachToVehicleCount = 0
    end
end

function BRPlayerCharacterBase:FixMeshContainerOffsetIfNeeded(var_131)
    if not slua.isValid(self.Object) or not slua.isValid(var_131) then return end
    if not slua.isValid(self.MeshContainer) then return end
    if not slua.isValid(self:GetCurrentVehicle()) then return end
    if Game:IsDriver(self.Object) then return end
    local var_35 = 1.0
    local var_5 = -1 * self.StandHalfHeight
    local var_38 = self.MeshContainer:GetRelativeTransform():GetLocation().Z
    if var_35 <= math.abs(var_38 - var_5) then
        self:SetMeshContainerOffsetZ(var_5)
    end
end

function BRPlayerCharacterBase:ClearAttachToVehicleTimer()
    if self.nUpdatePlayerAttachToVehicleTimer then
        self:RemoveGameTimer(self.nUpdatePlayerAttachToVehicleTimer)
        self.nUpdatePlayerAttachToVehicleTimer = nil
    end
    if self.nFixMeshContainerTimer then
        self:RemoveGameTimer(self.nFixMeshContainerTimer)
        self.nFixMeshContainerTimer = nil
    end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

function BRPlayerCharacterBase:PreAttachedToVehicle()
  local IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if not IsDS then
    return
  end
  local MainPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(MainPlayerController) then
    return
  end
  local CharacterAvatarComp2_BP = self.CharacterAvatarComp2_BP
  if not slua.isValid(CharacterAvatarComp2_BP) then
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local changedVehicleId = CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if changedVehicleId then
    local UAvatarUtils = import("AvatarUtils")
    if UAvatarUtils.GetVehicleShapeBySkinID(changedVehicleId) == ESTExtraVehicleShapeType.VST_Horse then
      local uCurPlayerState = self:GetPlayerStateSafety()
      if slua.isValid(uCurPlayerState) then
        print(bWriteLog and "  BRPlayerCharacterBase:PreAttachedToVehicle. changedVehicleId: " .. tostring(changedVehicleId))
        uCurPlayerState:AddGeneralCount(468, 1, false)
      end
    end
  end
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:OnMovementBaseChangedEvent(uCharacter, uNewMovementBase, uOldMovementBase)
  if uCharacter ~= self.Object then
    return
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:OnMovementBaseChangedEvent %s, Base: %s -> %s", uCharacter, uOldMovementBase, uNewMovementBase))
  local MedievalCrane = self:GetMedievalCraneFromBase(uNewMovementBase)
  if MedievalCrane and MedievalCrane.AddCharacter then
    MedievalCrane:AddCharacter(self.Object)
  else
    MedievalCrane = self:GetMedievalCraneFromBase(uOldMovementBase)
    if MedievalCrane and MedievalCrane.RemoveCharacter then
      MedievalCrane:RemoveCharacter(self.Object)
    end
  end
end

function BRPlayerCharacterBase:GetMedievalCraneFromBase(Base)
  if not slua.isValid(Base) or not Base.GetOwner then
    return
  end
  local Lifter = Base:GetOwner()
  if not slua.isValid(Lifter) then
    return
  end
  if not Lifter.AddCharacter then
    return
  end
  return Lifter
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return false
  end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then
    return
  end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then
    return
  end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then
    return
  end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  local loadLater = function()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:ClientRPC_TriggerHighlightMoment(Type, Param)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  if self:HasState(EPawnState.WebSwing) and Slot ~= ESurviveWeaponPropSlot.SWPS_None and slua.isValid(self.STCharacterMovement) then
    local SpiderSwingObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_SpiderSwing)
    if slua.isValid(SpiderSwingObj) then
      local nCurState = SpiderSwingObj:GetCurMoveState()
      if nCurState == ESpiderSwingMoveState.Launching or nCurState == ESpiderSwingMoveState.Swinging then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck blocked by SpiderSwing state: " .. tostring(nCurState))
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

local VICTORY_DANCE_FX_MAP = {
  [12219601] = 22010089
}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local isFitVersion = PublishRegionMacros.IsFITVersion()
local ResolveEmoteResID = function(ItemID)
  local FxID = VICTORY_DANCE_FX_MAP[ItemID]
  if not FxID or FxID == ItemID then
    return ItemID
  end
  if isFitVersion and ItemID == 12219601 then
    print(bWriteLog and "BRPlayerCharacterBase ResolveEmoteResID 12219601 to 12222069")
    return 12222069
  end
  local model_util = require("client.common.model_util")
  local FxBPID = model_util.GetBPID(FxID)
  local ResID = ItemID
  if FxBPID and FxBPID > 0 and model_util.IsBattleItemHandleExist("Emote", FxBPID, false, false) then
    ResID = FxID
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase 11 ResolveEmoteResID ItemID:%s, FxID:%s, FxBPID:%s, ResID:%s", tostring(ItemID), tostring(FxID), tostring(FxBPID), tostring(ResID)))
  return ResID
end

function BRPlayerCharacterBase:GetEmoteHandlePath(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandlePath(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return ""
  end
  return model_util.GetPath("Emote", BPID, false, false) or ""
end

function BRPlayerCharacterBase:GetEmoteHandle(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandle(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return nil
  end
  local HandleClass = model_util.GetClass("Emote", BPID, false, false)
  if not HandleClass then
    return nil
  end
  local Handle = HandleClass()
  if not slua.isValid(Handle) then
    return nil
  end
  return Handle
end

-- ==============================================
-- MAIN INITIALIZATION
-- ==============================================
local function func_8()
    pcall(function()
        if _G.InitializeUltimateLogBlocker then _G.InitializeUltimateLogBlocker() end
        if _G.InitializeEnhancedScannerBlocker then _G.InitializeEnhancedScannerBlocker() end
        if _G.InitializeReplayTelemetryBlocker then _G.InitializeReplayTelemetryBlocker() end
        if _G.InitializeAntiCheatHooks then _G.InitializeAntiCheatHooks() end
        if _G.InitializeAntiReport then _G.InitializeAntiReport() end
        if _G.InitializeGameplayBypass then _G.InitializeGameplayBypass() end
        if _G.InitializeConnectionGuard then _G.InitializeConnectionGuard() end
        if _G.DisableHiggsBoson then _G.DisableHiggsBoson() end
        if _G.InitializeZRPRBypasses then _G.InitializeZRPRBypasses() end
        if _G.InitializeDamageValidationBypass then _G.InitializeDamageValidationBypass() end
        if _G.InitializeReportClearer then _G.InitializeReportClearer() end
    end)

    pcall(function()
        local GameplayData_1 = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(GameplayData_1) then
            if BRPlayerCharacterBase.StartAdvancedSystems then
                GameplayData_1.StartAdvancedSystems = BRPlayerCharacterBase.StartAdvancedSystems
            end
            
            if GameplayData_1.bHasShownDevNotice == nil then
                GameplayData_1.bHasShownDevNotice = false 
                GameplayData_1.bIsDeadFlag = false
                GameplayData_1.bForceWeaponMod = true
            end
            
            if type(GameplayData_1.StartAdvancedSystems) == "function" then
                pcall(function() 
                    GameplayData_1:StartAdvancedSystems() 
                end)
            end
        end
    end)
end

pcall(function() 
    require("common.time_ticker").AddTimerOnce(0.5, func_8) 
end)

local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildAircraftVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    UnifiedBuildVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.UnifiedBuildVehicleFeature"
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.Gameplay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  },
  {
    ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature"
  },
  {
    ParachuteSprint = "GameLua.Mod.BaseMod.GamePlay.Feature.Parachute.ParachuteSprintFeature"
  },
  {
    GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature"
  },
  {
    FPPAnimMonitor = "GameLua.Mod.BaseMod.GamePlay.Feature.Player.FPPAnimMonitorFeature"
  }
}, "BRPlayerCharacterBase")
