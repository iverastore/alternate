local MainPage = Window:Page({ name = "Combat", Icon = "rbxassetid://4391741881" })
local MainMultiL = MainPage:MultiSection({ Side = 1 })
local AimTab = MainMultiL:Add("Aimbot")
local SilentTab = MainMultiL:Add("Silent")
local MainMultiR = MainPage:MultiSection({ Side = 2 })
local MainR = MainMultiR:Add("Main")
local SettingsSec = MainMultiR:Add("Settings")
local AimPlusSec = MainMultiR:Add("Aimbot+")

local AimbotSettings = {}

local function addAimbotSetting(widget)
    table.insert(AimbotSettings, widget)
    return widget
end

local currentSettingsTab = "Aimbot"

local function updateAdvancedPartsVis()
    local active = (currentSettingsTab == "Aimbot")
    local enabled = active and Flags["UseAdvancedParts"]
    if Flags["_JumpPart"] then
        pcall(function() Flags["_JumpPart"]:SetVisibility(enabled) end)
    end
    if Flags["_FallPart"] then
        pcall(function() Flags["_FallPart"]:SetVisibility(enabled) end)
    end
end

local function updateSmoothingVis()
    local active = (currentSettingsTab == "Aimbot+")
    local useSmooth = active and Flags["UseSmoothing"]
    local smoothPlus = Flags["UseSmoothingPlus"]
    if Flags["_SmoothAmt"] then Flags["_SmoothAmt"]:SetVisibility(useSmooth and not smoothPlus) end
    if Flags["_SmoothX"] then Flags["_SmoothX"]:SetVisibility(useSmooth and smoothPlus) end
    if Flags["_SmoothY"] then Flags["_SmoothY"]:SetVisibility(useSmooth and smoothPlus) end
    if Flags["_UseSmoothingPlus"] then Flags["_UseSmoothingPlus"]:SetVisibility(useSmooth) end
end

local function updatePredVis()
    local active = (currentSettingsTab == "Aimbot+")
    local usePred = active and Flags["UsePred"]
    local useAdv = active and Flags["UseAdvancedPred"]
    
    local showOld = usePred and not useAdv
    local showAdv = useAdv
    
    if Flags["_UsePred"] then Flags["_UsePred"]:SetVisibility(active and not useAdv) end
    if Flags["_PredX"] then Flags["_PredX"]:SetVisibility(showOld) end
    if Flags["_PredY"] then Flags["_PredY"]:SetVisibility(showOld) end
    if Flags["_PredAirX"] then Flags["_PredAirX"]:SetVisibility(showOld) end
    if Flags["_PredAirY"] then Flags["_PredAirY"]:SetVisibility(showOld) end
    
    if Flags["_AdvPredRight"] then Flags["_AdvPredRight"]:SetVisibility(showAdv) end
    if Flags["_AdvPredLeft"] then Flags["_AdvPredLeft"]:SetVisibility(showAdv) end
    if Flags["_AdvPredUp"] then Flags["_AdvPredUp"]:SetVisibility(showAdv) end
    if Flags["_AdvPredDown"] then Flags["_AdvPredDown"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirRight"] then Flags["_AdvPredAirRight"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirLeft"] then Flags["_AdvPredAirLeft"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirUp"] then Flags["_AdvPredAirUp"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirDown"] then Flags["_AdvPredAirDown"]:SetVisibility(showAdv) end
end

local function updateOffsetVis()
    local active = (currentSettingsTab == "Aimbot")
    local useOffsets = active and Flags["UseOffsets"]
    local useAirOffset = active and Flags["UseAirOffset"]
    if Flags["_OffsetUp"] then Flags["_OffsetUp"]:SetVisibility(useOffsets) end
    if Flags["_OffsetDown"] then Flags["_OffsetDown"]:SetVisibility(useOffsets) end
    if Flags["_OffsetLeft"] then Flags["_OffsetLeft"]:SetVisibility(useOffsets) end
    if Flags["_OffsetRight"] then Flags["_OffsetRight"]:SetVisibility(useOffsets) end
    if Flags["_UseAirOffset"] then Flags["_UseAirOffset"]:SetVisibility(active) end
    if Flags["_AirOffsetVal"] then Flags["_AirOffsetVal"]:SetVisibility(useAirOffset) end
    if Flags["_AirOffsetSmooth"] then Flags["_AirOffsetSmooth"]:SetVisibility(useAirOffset and not Flags["AirOffsetUseAimbotSmooth"]) end
    if Flags["_AirOffsetUseAimbotSmooth"] then Flags["_AirOffsetUseAimbotSmooth"]:SetVisibility(useAirOffset) end
end

local function updateEasingVis()
    local active = (currentSettingsTab == "Aimbot+")
    local useEasing = active and Flags["UseEasing"]
    local style = Flags["EaseStyle"] or "Quad"
    local isElastic = (style == "Elastic" or style == "Custom Elastic")
    local isAdapt = (style == "Adapt" or style == "Adaptive")
    local isOscillator = isAdapt or (style == "Zigzag") or (style == "Pulse")
    local isBack = (style == "Back")
    local isSharp = (style == "Sharp")
    
    if Flags["_EaseStyle"] then Flags["_EaseStyle"]:SetVisibility(useEasing) end
    if Flags["_EaseDir"] then Flags["_EaseDir"]:SetVisibility(useEasing) end
    if Flags["_EaseSpeed"] then Flags["_EaseSpeed"]:SetVisibility(useEasing) end
    if Flags["_Elasticity"] then Flags["_Elasticity"]:SetVisibility(useEasing and isElastic) end
    if Flags["_EaseExponent"] then Flags["_EaseExponent"]:SetVisibility(useEasing and (style == "Cubic" or style == "Custom Cubic" or style == "Quart" or style == "Quint")) end
    if Flags["_BounceBounciness"] then Flags["_BounceBounciness"]:SetVisibility(useEasing and style == "Bounce") end
    if Flags["_BackOvershoot"] then Flags["_BackOvershoot"]:SetVisibility(useEasing and isBack) end
    if Flags["_ElasticPeriod"] then Flags["_ElasticPeriod"]:SetVisibility(useEasing and isElastic) end
    if Flags["_SharpPower"] then Flags["_SharpPower"]:SetVisibility(useEasing and isSharp) end
    
    if Flags["_AdaptSwaySpeed"] then Flags["_AdaptSwaySpeed"]:SetVisibility(useEasing and isOscillator) end
    if Flags["_AdaptSwayWidth"] then Flags["_AdaptSwayWidth"]:SetVisibility(useEasing and isOscillator) end
    if Flags["_AdaptJitterAmt"] then Flags["_AdaptJitterAmt"]:SetVisibility(useEasing and isAdapt) end
end

local function updateDelayJumpVis()
    local active = (currentSettingsTab == "Aimbot")
    local delayJump = active and Flags["DelayJump"]
    if Flags["_DelayJumpMs"] then Flags["_DelayJumpMs"]:SetVisibility(delayJump) end
    if Flags["_DelayForXJumps"] then Flags["_DelayForXJumps"]:SetVisibility(delayJump) end
end

local function updateUnlockDelayVis()
    local active = (currentSettingsTab == "Aimbot")
    local unlockDelay = active and Flags["UnlockDelayEnabled"]
    if Flags["_UnlockDelayMs"] then Flags["_UnlockDelayMs"]:SetVisibility(unlockDelay) end
end

AimTab:addToggle({ name = "Enabled", flag = "AimbotEnabled", default = false }):addKeyBind({ flag = "AimbotBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
AimTab:addDropdown({ name = "Lock Method", flag = "LockMethod", items = {"Camera","Mouse"}, default = "Camera" })
AimTab:addDropdown({ name = "Target Mode", flag = "TargetMode", items = {"FOV","Mouse","Distance","Center"}, default = "FOV" })
AimTab:addDropdown({ name = "Aim Type", flag = "AimType", items = {"Normal", "Closest Part"}, default = "Normal" })
local hitPartitems = {"Head","Neck","UpperTorso","LowerTorso","Torso","Legs","Closest Part","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}
AimTab:addDropdown({ name = "Ground Part", flag = "GroundPart", items = hitPartItems, default = "Head" })
local aimAdvancedParts = AimTab:addToggle({ name = "Advanced Parts", flag = "UseAdvancedParts", default = false, callback = updateAdvancedPartsVis })
Flags["_JumpPart"] = AimTab:addDropdown({ name = "Jump Part", flag = "JumpPart", items = hitPartItems, default = "HumanoidRootPart" })
Flags["_FallPart"] = AimTab:addDropdown({ name = "Fall Part", flag = "FallPart", items = hitPartItems, default = "LowerTorso" })
pcall(updateAdvancedPartsVis)
AimTab:addToggle({ name = "Ignore Fall State", flag = "IgnoreFall", default = false })
AimTab:addDropdown({ name = "Checks", flag = "AimChecks", items = {"Enemy","Team","NPC","Wall","Dead","Knocked"}, default = {}, multi = true })
AimTab:addToggle({ name = "Auto Stop on Dead", flag = "AimStopDead", default = false })
AimTab:addToggle({ name = "Sticky Aim", flag = "StickyAim", default = false })
AimTab:addToggle({ name = "Lock Target", flag = "LockTarget", default = false })

AimTab:addToggle({ name = "Use FOV", flag = "UseFOV", default = false })
local aimDrawFOV = AimTab:addToggle({ name = "Draw FOV", flag = "DrawFOV", default = false })
aimDrawFOV:addColorPicker({ flag = "c_fov", default = Color3.new(1,1,1), callback = function(c) C.FOV=c end })
AimTab:addSlider({ name = "FOV Size", flag = "FOVSize", min = 10, max = 500, default = 60 })
AimTab:addSlider({ name = "FOV Alpha", flag = "FOVAlpha", min = 10, max = 100, default = 100, Suffix = "%" })
local aimFOVOutline = AimTab:addToggle({ name = "FOV Outline", flag = "FOVOutline", default = false })
aimFOVOutline:addColorPicker({ flag = "c_fovout", default = Color3.new(0,0,0), callback = function(c) C.FOVOut=c end })
AimTab:addSlider({ name = "FOV Outline Alpha", flag = "FOVOutAlpha", min = 10, max = 100, default = 100, Suffix = "%" })

local aimUseSmoothing = addAimbotSetting(AimPlusSec:addToggle({ name = "Use Smoothing", flag = "UseSmoothing", default = false, callback = updateSmoothingVis }))
local aimUseSmoothingPlus = addAimbotSetting(AimPlusSec:addToggle({ name = "Smoothing+", flag = "UseSmoothingPlus", default = false, callback = updateSmoothingVis }))
Flags["_UseSmoothingPlus"] = aimUseSmoothingPlus
Flags["_SmoothAmt"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Smoothing Amount", flag = "SmoothAmt", min = 1, max = 100, default = 16 }))
Flags["_SmoothX"] = addAimbotSetting(AimPlusSec:addSlider({ name = "X Smoothing", flag = "SmoothX", min = 1, max = 100, default = 16 }))
Flags["_SmoothY"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Y Smoothing", flag = "SmoothY", min = 1, max = 100, default = 16 }))

local aimUseEasing = addAimbotSetting(AimPlusSec:addToggle({ name = "Use Easing", flag = "UseEasing", default = false, callback = updateEasingVis }))
Flags["_EaseStyle"] = addAimbotSetting(AimPlusSec:addDropdown({ name = "Easing Style", flag = "EaseStyle", items = {"Linear","Sine","Quad","Cubic","Quart","Quint","Exponential","Circular","Back","Bounce","Elastic","Adaptive","Zigzag","Pulse","Sharp"}, default = "Quad", callback = updateEasingVis }))
Flags["_EaseDir"] = addAimbotSetting(AimPlusSec:addDropdown({ name = "Easing Direction", flag = "EaseDir", items = {"In","Out","InOut"}, default = "Out" }))
Flags["_EaseSpeed"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Easing Speed", flag = "EaseSpeed", min = 1, max = 100, default = 70, Suffix = "%" }))
Flags["_Elasticity"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Elasticity", flag = "Elasticity", min = 0, max = 100, default = 30, Suffix = "%" }))
Flags["_EaseExponent"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Easing Exponent", flag = "EaseExponent", min = 1, max = 10, default = 3, callback = updateEasingVis }))
Flags["_BounceBounciness"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Bounce Bounciness", flag = "BounceBounciness", min = 1, max = 100, default = 50, Suffix = "%", callback = updateEasingVis }))
Flags["_BackOvershoot"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Back Overshoot", flag = "BackOvershoot", min = 0, max = 50, default = 17, Suffix = "/10", callback = updateEasingVis }))
Flags["_ElasticPeriod"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Elastic Period", flag = "ElasticPeriod", min = 1, max = 100, default = 30, Suffix = "%", callback = updateEasingVis }))
Flags["_AdaptSwaySpeed"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Sway Speed", flag = "AdaptSwaySpeed", min = 0, max = 100, default = 15 }))
Flags["_AdaptSwayWidth"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Sway Size", flag = "AdaptSwayWidth", min = 0, max = 100, default = 10 }))
Flags["_AdaptJitterAmt"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Jitter Size", flag = "AdaptJitterAmt", min = 0, max = 100, default = 15 }))
Flags["_SharpPower"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Sharpness", flag = "SharpPower", min = 5, max = 100, default = 20, Suffix = "/100", callback = updateEasingVis }))

local aimUsePred = addAimbotSetting(AimPlusSec:addToggle({ name = "Use Prediction", flag = "UsePred", default = false, callback = updatePredVis }))
Flags["_UsePred"] = aimUsePred
Flags["_PredX"] = addAimbotSetting(AimPlusSec:addSlider({ name = "X/Z Prediction", flag = "PredX", min = 0, max = 150, default = 14 }))
Flags["_PredY"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Y Prediction", flag = "PredY", min = 0, max = 150, default = 14 }))
Flags["_PredAirX"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air X/Z Prediction", flag = "PredAirX", min = 0, max = 150, default = 12 }))
Flags["_PredAirY"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air Y Prediction", flag = "PredAirY", min = 0, max = 150, default = 12 }))

local aimUseAdvancedPred = addAimbotSetting(AimPlusSec:addToggle({ name = "Advanced Prediction", flag = "UseAdvancedPred", default = false, callback = updatePredVis }))
Flags["_UseAdvancedPred"] = aimUseAdvancedPred
Flags["_AdvPredRight"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Prediction Right", flag = "AdvPredRight", min = 0, max = 150, default = 12 }))
Flags["_AdvPredLeft"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Prediction Left", flag = "AdvPredLeft", min = 0, max = 150, default = 12 }))
Flags["_AdvPredUp"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Prediction Up", flag = "AdvPredUp", min = 0, max = 150, default = 12 }))
Flags["_AdvPredDown"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Prediction Down", flag = "AdvPredDown", min = 0, max = 150, default = 12 }))
Flags["_AdvPredAirRight"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air Prediction Right", flag = "AdvPredAirRight", min = 0, max = 150, default = 14 }))
Flags["_AdvPredAirLeft"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air Prediction Left", flag = "AdvPredAirLeft", min = 0, max = 150, default = 14 }))
Flags["_AdvPredAirUp"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air Prediction Up", flag = "AdvPredAirUp", min = 0, max = 150, default = 14 }))
Flags["_AdvPredAirDown"] = addAimbotSetting(AimPlusSec:addSlider({ name = "Air Prediction Down", flag = "AdvPredAirDown", min = 0, max = 150, default = 14 }))

local aimUseOffsets = addAimbotSetting(SettingsSec:addToggle({ name = "Use Offsets", flag = "UseOffsets", default = false, callback = updateOffsetVis }))
Flags["_OffsetUp"] = addAimbotSetting(SettingsSec:addSlider({ name = "Offset Up", flag = "OffsetUp", min = 0, max = 100, default = 0, Suffix = "/10" }))
Flags["_OffsetDown"] = addAimbotSetting(SettingsSec:addSlider({ name = "Offset Down", flag = "OffsetDown", min = 0, max = 100, default = 0, Suffix = "/10" }))
Flags["_OffsetLeft"] = addAimbotSetting(SettingsSec:addSlider({ name = "Offset Left", flag = "OffsetLeft", min = 0, max = 100, default = 0, Suffix = "/10" }))
Flags["_OffsetRight"] = addAimbotSetting(SettingsSec:addSlider({ name = "Offset Right", flag = "OffsetRight", min = 0, max = 100, default = 0, Suffix = "/10" }))
local aimUseAirOffset = addAimbotSetting(SettingsSec:addToggle({ name = "Air Offset", flag = "UseAirOffset", default = false, callback = updateOffsetVis }))
Flags["_UseAirOffset"] = aimUseAirOffset
Flags["_AirOffsetVal"] = addAimbotSetting(SettingsSec:addSlider({ name = "Air Offset Value", flag = "AirOffsetVal", min = -100, max = 100, default = 0, Suffix = "/10" }))
Flags["_AirOffsetSmooth"] = addAimbotSetting(SettingsSec:addSlider({ name = "Air Offset Smoothness", flag = "AirOffsetSmooth", min = 1, max = 100, default = 15 }))
Flags["_AirOffsetUseAimbotSmooth"] = addAimbotSetting(SettingsSec:addToggle({ name = "Use Aimbot Smooth for Air Offset", flag = "AirOffsetUseAimbotSmooth", default = false, callback = updateOffsetVis }))
pcall(updateOffsetVis)

Flags["_LockTime"] = addAimbotSetting(SettingsSec:addSlider({ name = "Lock Time", flag = "LockTime", min = 0, max = 1000, default = 0, Suffix = "ms" }))
local aimDelayJump = addAimbotSetting(SettingsSec:addToggle({ name = "Delay Jump", flag = "DelayJump", default = false, callback = updateDelayJumpVis }))
Flags["_DelayJumpMs"] = addAimbotSetting(SettingsSec:addSlider({ name = "Jump Delay", flag = "DelayJumpMs", min = 0, max = 500, default = 100, Suffix = "ms" }))
Flags["_DelayForXJumps"] = addAimbotSetting(SettingsSec:addSlider({ name = "X Jump Delay", flag = "DelayForXJumps", min = 1, max = 10, default = 1 }))
local aimUnlockDelay = addAimbotSetting(SettingsSec:addToggle({ name = "Unlock Delay", flag = "UnlockDelayEnabled", default = false, callback = updateUnlockDelayVis }))
Flags["_UnlockDelayMs"] = addAimbotSetting(SettingsSec:addSlider({ name = "Unlock Delay (ms)", flag = "UnlockDelayMs", min = 0, max = 1000, default = 100, Suffix = "ms" }))

local function updateMacroVis()
    local active = (currentSettingsTab == "Aimbot")
    local macroOn = active and Flags["MacroEnabled"]
    local macroType = Flags["MacroType"] or "360"
    local function mvis(flag, cond) if Flags[flag] then Flags[flag]:SetVisibility(cond) end end
    mvis("_MacroType", macroOn)
    mvis("_SpinSpeed", macroOn and macroType == "360")
    mvis("_SpinTarget", macroOn and macroType == "360")
    mvis("_SpinDir", macroOn and macroType == "360")
    mvis("_ZipZapSpeed", macroOn and macroType == "Zip Zap")
    mvis("_ZipZapRange", macroOn and macroType == "Zip Zap")
    mvis("_ZipZapCount", macroOn and macroType == "Zip Zap")
    mvis("_FlickOffOffset", macroOn and macroType == "Flick Off")
    mvis("_FlickOffSpeed", macroOn and macroType == "Flick Off")
    mvis("_FlickOffDuration", macroOn and macroType == "Flick Off")
end

local aimMacroEnabled = addAimbotSetting(SettingsSec:addToggle({ name = "Cam Macro", flag = "MacroEnabled", default = false, callback = updateMacroVis }))
aimMacroEnabled:addKeyBind({ flag = "MacroBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
Flags["_MacroType"] = addAimbotSetting(SettingsSec:addDropdown({ name = "Macro Type", flag = "MacroType", items = {"360", "Zip Zap", "Flick Off"}, default = "360", callback = updateMacroVis }))

Flags["_SpinSpeed"] = addAimbotSetting(SettingsSec:addSlider({ name = "360 Speed", flag = "SpinSpeed", min = 1, max = 50, default = 10 }))
Flags["_SpinTarget"] = addAimbotSetting(SettingsSec:addDropdown({ name = "360 Target", flag = "SpinTarget", items = { "Both", "Character", "Camera" }, default = "Both" }))
Flags["_SpinDir"] = addAimbotSetting(SettingsSec:addDropdown({ name = "360 Direction", flag = "SpinDir", items = { "Right", "Left" }, default = "Right" }))

Flags["_ZipZapSpeed"] = addAimbotSetting(SettingsSec:addSlider({ name = "Zip Zap Speed", flag = "ZipZapSpeed", min = 1, max = 50, default = 15 }))
Flags["_ZipZapRange"] = addAimbotSetting(SettingsSec:addSlider({ name = "Zip Zap Range", flag = "ZipZapRange", min = 1, max = 100, default = 30, Suffix = " deg" }))
Flags["_ZipZapCount"] = addAimbotSetting(SettingsSec:addSlider({ name = "Zip Zap Count", flag = "ZipZapCount", min = 2, max = 20, default = 5 }))

Flags["_FlickOffOffset"] = addAimbotSetting(SettingsSec:addSlider({ name = "Flick Off Offset", flag = "FlickOffOffset", min = 10, max = 500, default = 150, Suffix = " deg" }))
Flags["_FlickOffSpeed"] = addAimbotSetting(SettingsSec:addSlider({ name = "Flick Off Speed", flag = "FlickOffSpeed", min = 1, max = 100, default = 30 }))
Flags["_FlickOffDuration"] = addAimbotSetting(SettingsSec:addSlider({ name = "Flick Off Duration", flag = "FlickOffDuration", min = 100, max = 3000, default = 500, Suffix = "ms" }))

Flags["_MissChance"] = addAimbotSetting(SettingsSec:addSlider({ name = "Miss Chance", flag = "MissChance", min = 0, max = 100, default = 0, Suffix = "%" }))

local silentHitParts = {"Head","Torso","Legs","Closest Part","Neck","UpperTorso"}
SilentTab:addToggle({ name = "Enabled", flag = "SilentEnabled", default = false }):addKeyBind({ flag = "SilentBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
SilentTab:addDropdown({ name = "Hit Part", flag = "SilentHitPart", items = silentHitParts, default = "Head" })
SilentTab:addDropdown({ name = "Checks", flag = "SilentChecks", items = {"NPC","Team","Dead","Wall","Knocked"}, default = {"Team","Dead"}, multi = true })
SilentTab:addToggle({ name = "Target Lock", flag = "SilentTargetLock", default = false })
SilentTab:addDropdown({ name = "Aim Type", flag = "SilentAimType", items = {"Cursor","Center","FOV","Closest"}, default = "Cursor" })
SilentTab:addToggle({ name = "Auto Prediction", flag = "SilentAutoPred", default = false })
SilentTab:addDropdown({ name = "Prediction Type", flag = "SilentPredType", items = {"Ping Based","Alternate Based"}, default = "Ping Based" })
SilentTab:addToggle({ name = "Hit Chance", flag = "SilentHitChanceEnabled", default = false })
SilentTab:addSlider({ name = "Hit Chance %", flag = "SilentHitChance", min = 1, max = 100, default = 100, Suffix = "%" })
SilentTab:addToggle({ name = "Use FOV", flag = "SilentUseFOV", default = false })
SilentTab:addSlider({ name = "FOV Size", flag = "SilentFOVSize", min = 10, max = 500, default = 100 })
local silentDrawFOV = SilentTab:addToggle({ name = "Draw FOV", flag = "SilentDrawFOV", default = false })
silentDrawFOV:addColorPicker({ flag = "c_silentfov", default = Color3.new(1,1,1), callback = function(c) C.SilentFOV = c end })
SilentTab:addSlider({ name = "FOV Alpha", flag = "SilentFOVAlpha", min = 10, max = 100, default = 100, Suffix = "%" })
local silentFOVOutline = SilentTab:addToggle({ name = "FOV Outline", flag = "SilentFOVOutline", default = false })
silentFOVOutline:addColorPicker({ flag = "c_silentfovout", default = Color3.new(0,0,0), callback = function(c) C.SilentFOVOut = c end })
SilentTab:addSlider({ name = "FOV Outline Alpha", flag = "SilentFOVOutAlpha", min = 10, max = 100, default = 100, Suffix = "%" })

local function updateSettingsTabVisibility(tabName)
    currentSettingsTab = tabName
    local function show(element) pcall(function() element:SetVisibility(true) end) end
    local function run(fn) pcall(fn) end

    if tabname = = "Aimbot" then
        pcall(function() MainMultiR:Select("Settings") end)
        show(aimUseOffsets)
        show(aimDelayJump)
        show(aimUnlockDelay)
        show(aimMacroEnabled)
        show(aimAdvancedParts)
        show(Flags["_MissChance"])
        run(updateOffsetVis)
        run(updateDelayJumpVis)
        run(updateUnlockDelayVis)
        run(updateMacroVis)
        run(updateAdvancedPartsVis)
    elseif tabname = = "Aimbot+" then
        pcall(function() MainMultiR:Select("Aimbot+") end)
        show(aimUseSmoothing)
        show(aimUsePred)
        show(aimUseAdvancedPred)
        show(aimUseEasing)
        run(updateSmoothingVis)
        run(updatePredVis)
        run(updateEasingVis)
    elseif tabname = = "Main" then
        currentSettingsTab = "None"
    end
end

local function hookTabTurn(tab, tabName)
    tab.on_turn = function() pcall(updateSettingsTabVisibility, tabName) end
    if tab.Turn then
        local oldTurn = tab.Turn
        function tab:Turn() oldTurn(self) pcall(updateSettingsTabVisibility, tabName) end
    end
end

hookTabTurn(AimTab, "Aimbot")
hookTabTurn(AimPlusSec, "Aimbot+")
hookTabTurn(SettingsSec, "Aimbot")
hookTabTurn(MainR, "Main")
pcall(updateSettingsTabVisibility, "Aimbot")
MainMultiR:Select("Main")
MainR:addToggle({ name = "Target HUD", flag = "TargetHUD", default = false, callback = function(v)
    pcall(function() if Library.TargetHUDObj then Library.TargetHUDObj:SetVisibility(v) end end)
end })
local ttrc = MainR:addToggle({ name = "Target Tracer", flag = "TargetTracer", default = false })
ttrc:addColorPicker({ flag = "c_ttrace", default = Color3.new(1,0,0), callback = function(c) C.TargetTracer=c end })
ttrc:addColorPicker({ flag = "c_ttraceout", default = Color3.new(0,0,0), callback = function(c) C.TargetTracerOut=c end })
Flags["_TargetTracerAlpha"] = MainR:addSlider({ name = "Tracer Fill Alpha", flag = "TargetTracerAlpha", min = 0, max = 100, default = 100, Suffix = "%" })
Flags["_TargetTracerOutAlpha"] = MainR:addSlider({ name = "Tracer Outline Alpha", flag = "TargetTracerOutAlpha", min = 0, max = 100, default = 100, Suffix = "%" })
MainR:addDropdown({ name = "Tracer Start", flag = "TargetTracerStart", items = {"Bottom","Top","Cursor"}, default = "Bottom" })
MainR:addDropdown({ name = "Tracer End", flag = "TargetTracerEnd", items = {"Feet","Head"}, default = "Feet" })

end

local function saveLoadingScreenPref(v)
    pcall(function() writefile("alternate_loading_pref.txt", tostring(v)) end)
end
local initialLoadingPref = true
pcall(function()
    if isfile and isfile("alternate_loading_pref.txt") then
        initialLoadingPref = readfile("alternate_loading_pref.txt") == "true"
    end
end)

local _W = {}
do
_W.getCol3 = function(val, default)
    if typeof(val) == "Color3" then return val end
    if typeof(val) == "table" and typeof(val.Color) == "Color3" then return val.Color end
    return default or Color3.fromRGB(255, 255, 255)
end
_W.rainSettings = { Rate=300, Speed=120, Size=8, Width=30, Radius=100, Splashes=true, RainFogEnd=1500, RainFogDensity=30 }
_W.snowSettings = { Rate=200, Speed=25,  Size=3, Radius=100, SnowFogEnd=1800, SnowFogDensity=25 }
_W.rainRunning, _W.snowRunning = false, false
_W.originalLightingState = nil
_W.rainPart, _W.snowPart = nil, nil
_W.rainEmitters = {}
_W.snowEmitter = nil
_W._rainFollowConn, _W._snowFollowConn = nil, nil
_W._splashConn = nil
_W._splashFolder = nil
local RAIN_TEX = "rbxassetid://124528706254337"
local SPLASH_TEX = "rbxassetid://123240546708836"
local SNOW_TEX = "rbxassetid://6490035152"

_W.destroyRainPart = function()
    if _W.rainPart then pcall(function() _W.rainPart:Destroy() end); _W.rainPart = nil end
end
_W.destroySnowPart = function()
    if _W.snowPart then pcall(function() _W.snowPart:Destroy() end); _W.snowPart = nil end
end
_W.saveOriginalLighting = function()
    if _W.originalLightingState then return end
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    _W.originalLightingState = {
        FogColor=Lighting.FogColor, FogStart=Lighting.FogStart, FogEnd=Lighting.FogEnd,
        Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
        AtmoData = atmo and { Density=atmo.Density, Offset=atmo.Offset, Color=atmo.Color, Decay=atmo.Decay, Glare=atmo.Glare, Haze=atmo.Haze } or nil
    }
end
_W.restoreOriginalLighting = function()
    if not _W.originalLightingState then return end
    Lighting.FogColor=_W.originalLightingState.FogColor; Lighting.FogStart=_W.originalLightingState.FogStart
    Lighting.FogEnd=_W.originalLightingState.FogEnd; Lighting.Ambient=_W.originalLightingState.Ambient
    Lighting.OutdoorAmbient=_W.originalLightingState.OutdoorAmbient
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if _W.originalLightingState.AtmoData then
        if not atmo then atmo=Instance.new("Atmosphere"); atmo.Parent=Lighting end
        local d=_W.originalLightingState.AtmoData
        atmo.Density=d.Density; atmo.Offset=d.Offset; atmo.Color=d.Color
        atmo.Decay=d.Decay; atmo.Glare=d.Glare; atmo.Haze=d.Haze
    else if atmo then atmo:Destroy() end end
    _W.originalLightingState = nil
end
_W.applyWeatherAtmosphere = function(weatherName)
    _W.saveOriginalLighting()
    local color = Color3.fromRGB(255,255,255)
    local density, fogEnd, haze = 0.42, 2000, 3.5
    if weathername = ="Cherry" then
        color = Flags["c_cherry_fog"] and _W.getCol3(Flags["c_cherry_fog"]) or Color3.fromRGB(255,230,240)
        density=(Flags["CherryFogDensity"] or 15)/100; fogEnd=Flags["CherryFogEnd"] or 2000; haze=2.0
    elseif weathername = ="Rain" then
        color = Flags["c_rain_fog"] and _W.getCol3(Flags["c_rain_fog"]) or Color3.fromRGB(150,160,170)
        density=(Flags["RainFogDensity"] or 30)/100; fogEnd=Flags["RainFogEnd"] or 1500; haze=4.0
    elseif weathername = ="Snow" then
        color = Flags["c_snow_fog"] and _W.getCol3(Flags["c_snow_fog"]) or Color3.fromRGB(220,225,235)
        density=(Flags["SnowFogDensity"] or 25)/100; fogEnd=Flags["SnowFogEnd"] or 1800; haze=3.0
    end
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmo then atmo=Instance.new("Atmosphere"); atmo.Parent=Lighting end
    atmo.name = "PortalAura"; atmo.Color=color; atmo.Decay=color
    atmo.Density=density; atmo.Haze=haze; atmo.Glare=0.5; atmo.Offset=0
    Lighting.FogColor=color; Lighting.FogStart=50; Lighting.FogEnd=fogEnd
end
_W.applyWeatherAtmosphere = _W.applyWeatherAtmosphere
_W._rainConn, _W._snowConn = nil, nil
_W._rainDrops = {}
_W._snowFlakes = {}
_W.clearDrops = function(tbl)
    for _, p in ipairs(tbl) do pcall(function() p:Destroy() end) end
    table.clear(tbl)
end


local _rainStreaks = {}
local _rainVolFolder = nil

_W._stopRain = function()
    if _W._rainFollowConn then _W._rainFollowConn:Disconnect(); _W._rainFollowConn = nil end
    if _W._splashConn then _W._splashConn:Disconnect(); _W._splashConn = nil end
    for _, e in ipairs(_W.rainEmitters) do pcall(function() e:Destroy() end) end
    _W.rainEmitters = {}
    _W.destroyRainPart()
    for _, s in ipairs(_rainStreaks) do pcall(function() s.part:Destroy() end) end
    table.clear(_rainStreaks)
    if _rainVolFolder then pcall(function() _rainVolFolder:Destroy() end); _rainVolFolder = nil end
    if _W._splashFolder then pcall(function() _W._splashFolder:Destroy() end); _W._splashFolder = nil end
end

_W._enableRain = function()
    local cam = workspace.CurrentCamera
    _W._stopRain()
    local rate = _W.rainSettings.Rate or 300
    local spd = _W.rainSettings.Speed or 120
    local sz = _W.rainSettings.Size or 8
    local radius = _W.rainSettings.Radius or 100
    local widthPct = (_W.rainSettings.Width or 30) / 100

    local halfX = radius
    local halfZ = radius
    local topY = 45
    local botY = -25
    local span = topY - botY

    local streakLen = sz * 0.9
    local streakWid = streakLen * widthPct
    local count = math.clamp(math.floor(rate), 10, 600)

    _rainVolFolder = Instance.new("Folder")
    _rainVolFolder.name = "_RainVolume"
    _rainVolFolder.Parent = workspace

    local baseColor = Flags["c_rain"] and _W.getCol3(Flags["c_rain"]) or Color3.fromRGB(190, 205, 240)
    local camPos = cam.CFrame.Position

    for i = 1, count do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Transparency = 1
        part.Size = Vector3.new(0.2, 0.2, 0.2)
        part.Parent = _rainVolFolder

        local depthScale = 0.45 + math.random() * 1.3

        local bb = Instance.new("BillboardGui")
        bb.Adornee = part
        bb.AlwaysOnTop = false
        bb.LightInfluence = 0
        bb.Size = UDim2.fromScale(streakWid * depthScale, streakLen * depthScale)
        bb.Parent = part

        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size = UDim2.fromScale(1, 1)
        img.Image = RAIN_TEX
        img.ImageColor3 = baseColor
        img.ImageTransparency = 0.25 + math.random() * 0.25
        img.Parent = bb

        local ox = (math.random() * 2 - 1) * halfX
        local oz = (math.random() * 2 - 1) * halfZ
        local oy = botY + math.random() * span
        part.CFrame = CFrame.new(camPos + Vector3.new(ox, oy, oz))

        table.insert(_rainStreaks, {
            part = part,
            ox = ox,
            oz = oz,
            y = oy,
            speed = spd * (0.8 + depthScale * 0.4),
        })
    end

    _W._splashFolder = Instance.new("Folder")
    _W._splashFolder.name = "_RainSplashes"
    _W._splashFolder.Parent = workspace

    _W._rainFollowConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
        if not _W.rainRunning then return end
        local cpos = workspace.CurrentCamera.CFrame.Position
        for _, s in ipairs(_rainStreaks) do
            if not s.part.Parent then continue end
            s.y = s.y - s.speed * dt
            if s.y <= botY then
                s.y = topY
                s.ox = (math.random() * 2 - 1) * halfX
                s.oz = (math.random() * 2 - 1) * halfZ
            end
            s.part.CFrame = CFrame.new(cpos.X + s.ox, cpos.Y + s.y, cpos.Z + s.oz)
        end
    end))

    local splashTimer = 0
    if _W.rainSettings.Splashes ~= false then
    _W._splashConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
        if not _W.rainRunning then return end
        splashTimer = splashTimer + dt
        if splashTimer < 0.05 then return end
        splashTimer = 0
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hrpPos = hrp.Position
        local splashCount = math.clamp(math.floor(rate / 60), 1, 6)

        for i = 1, splashCount do
            local angle = math.random() * math.pi * 2
            local dist = math.random() * math.min(radius, 50)
            local origin = hrpPos + Vector3.new(math.cos(angle) * dist, 30, math.sin(angle) * dist)
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {char, _W._splashFolder, _rainVolFolder}
            local result = workspace:Raycast(origin, Vector3.new(0, -50, 0), rayParams)
            if result and result.Position then
                local normal = result.Normal or Vector3.new(0, 1, 0)
                local splashSz = sz * 0.5
                local splashPart = Instance.new("Part")
                splashPart.Anchored = true
                splashPart.CanCollide = false
                splashPart.CanQuery = false
                splashPart.CastShadow = false
                splashPart.Transparency = 1
                splashPart.Size = Vector3.new(splashSz, 0.05, splashSz)
                splashPart.CFrame = CFrame.new(result.Position + normal * 0.05, result.Position + normal * 0.05 + normal)
                    * CFrame.Angles(-math.pi / 2, 0, math.random() * math.pi * 2)
                splashPart.Parent = _W._splashFolder

                local decal = Instance.new("Decal")
                decal.Texture = SPLASH_TEX
                decal.Color3 = baseColor
                decal.Face = Enum.NormalId.Top
                decal.Transparency = 0.2
                decal.Parent = splashPart

                task.spawn(function()
                    local t = 0
                    while t < 0.45 and splashPart.Parent do
                        t = t + RunService.Heartbeat:Wait()
                        local a = math.min(t / 0.45, 1)
                        local s = splashSz * (0.6 + a * 0.7)
                        splashPart.Size = Vector3.new(s, 0.05, s)
                        decal.Transparency = 0.2 + a * 0.8
                    end
                    if splashPart.Parent then splashPart:Destroy() end
                end)
            end
        end
    end))
    end
end

_W.enableRain = function()
    if _W.rainRunning then return end; _W.rainRunning = true
    _W._enableRain()
end
_W.disableRain = function()
    _W.rainRunning = false
    _W._stopRain()
end
_W.refreshRain = function()
    if _W.rainRunning then _W._stopRain(); _W._enableRain() end
end


_W._stopSnow = function()
    if _W._snowFollowConn then _W._snowFollowConn:Disconnect(); _W._snowFollowConn = nil end
    if _W.snowEmitter then pcall(function() _W.snowEmitter:Destroy() end); _W.snowEmitter = nil end
    _W.destroySnowPart()
end

_W._enableSnow = function()
    local cam = workspace.CurrentCamera
    _W._stopSnow()
    local rate = _W.snowSettings.Rate or 200
    local spd = _W.snowSettings.Speed or 25
    local sz = _W.snowSettings.Size or 3

    _W.snowPart = Instance.new("Part")
    _W.snowPart.Anchored = true; _W.snowPart.CanCollide = false; _W.snowPart.CastShadow = false
    _W.snowPart.Transparency = 1; _W.snowPart.Size = Vector3.new(0.1, 0.1, 0.1)
    _W.snowPart.CFrame = CFrame.new(cam.CFrame.Position)
    _W.snowPart.Parent = cam

    local closeEmitter = Instance.new("ParticleEmitter")
    closeEmitter.name = "_SnowClose"
    closeEmitter.Texture = SNOW_TEX
    closeEmitter.Color = ColorSequence.new(Color3.fromRGB(245, 250, 255))
    closeEmitter.LightEmission = 0.8
    closeEmitter.LightInfluence = 0
    closeEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.7, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    local closeSz = sz * 0.15
    closeEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, closeSz),
        NumberSequenceKeypoint.new(0.5, closeSz * 0.8),
        NumberSequenceKeypoint.new(1, 0),
    })
    closeEmitter.Rate = rate * 0.4
    closeEmitter.Lifetime = NumberRange.new(4, 8)
    closeEmitter.Speed = NumberRange.new(spd * 0.8, spd * 1.2)
    closeEmitter.SpreadAngle = Vector2.new(45, 45)
    closeEmitter.Rotation = NumberRange.new(0, 360)
    closeEmitter.RotSpeed = NumberRange.new(-40, 40)
    closeEmitter.VelocitySpread = 20
    closeEmitter.Acceleration = Vector3.new(8, -6, 4)
    closeEmitter.Drag = 0.5
    closeEmitter.EmissionDirection = Enum.NormalId.Bottom
    closeEmitter.Parent = _W.snowPart
    _W.snowEmitter = closeEmitter

    local midEmitter = Instance.new("ParticleEmitter")
    midEmitter.name = "_SnowMid"
    midEmitter.Texture = SNOW_TEX
    midEmitter.Color = ColorSequence.new(Color3.fromRGB(240, 246, 255))
    midEmitter.LightEmission = 0.85
    midEmitter.LightInfluence = 0
    midEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.7, 0.25),
        NumberSequenceKeypoint.new(1, 1),
    })
    local midSz = sz * 0.08
    midEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, midSz),
        NumberSequenceKeypoint.new(0.5, midSz),
        NumberSequenceKeypoint.new(1, 0),
    })
    midEmitter.Rate = rate * 0.35
    midEmitter.Lifetime = NumberRange.new(6, 10)
    midEmitter.Speed = NumberRange.new(spd * 0.6, spd * 0.9)
    midEmitter.SpreadAngle = Vector2.new(60, 60)
    midEmitter.Rotation = NumberRange.new(0, 360)
    midEmitter.RotSpeed = NumberRange.new(-25, 25)
    midEmitter.VelocitySpread = 30
    midEmitter.Acceleration = Vector3.new(12, -4, 8)
    midEmitter.Drag = 0.3
    midEmitter.EmissionDirection = Enum.NormalId.Bottom
    midEmitter.Parent = _W.snowPart

    local farEmitter = Instance.new("ParticleEmitter")
    farEmitter.name = "_SnowFar"
    farEmitter.Texture = SNOW_TEX
    farEmitter.Color = ColorSequence.new(Color3.fromRGB(235, 242, 255))
    farEmitter.LightEmission = 0.9
    farEmitter.LightInfluence = 0
    farEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.7, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    local farSz = sz * 0.04
    farEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, farSz),
        NumberSequenceKeypoint.new(0.5, farSz),
        NumberSequenceKeypoint.new(1, 0),
    })
    farEmitter.Rate = rate * 0.5
    farEmitter.Lifetime = NumberRange.new(8, 14)
    farEmitter.Speed = NumberRange.new(spd * 0.4, spd * 0.7)
    farEmitter.SpreadAngle = Vector2.new(90, 90)
    farEmitter.Rotation = NumberRange.new(0, 360)
    farEmitter.RotSpeed = NumberRange.new(-15, 15)
    farEmitter.VelocitySpread = 40
    farEmitter.Acceleration = Vector3.new(15, -3, 10)
    farEmitter.Drag = 0.2
    farEmitter.EmissionDirection = Enum.NormalId.Bottom
    farEmitter.Parent = _W.snowPart

    local windTime = 0
    _W._snowFollowConn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not _W.snowRunning or not _W.snowPart then return end
        windTime = windTime + 0.016
        local windX = 8 + math.sin(windTime * 0.3) * 6
        local windZ = 4 + math.cos(windTime * 0.25) * 4
        closeEmitter.Acceleration = Vector3.new(windX, -6, windZ)
        midEmitter.Acceleration = Vector3.new(windX * 1.5, -4, windZ * 1.5)
        farEmitter.Acceleration = Vector3.new(windX * 2, -3, windZ * 2)
        _W.snowPart.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 50, 0))
    end))
end

_W.enableSnow = function()
    if _W.snowRunning then return end; _W.snowRunning = true
    _W._enableSnow()
end
_W.disableSnow = function()
    _W.snowRunning = false
    _W._stopSnow()
end
_W.refreshSnow = function()
    if _W.snowRunning then _W._stopSnow(); _W._enableSnow() end
end
clearWeatherObjects = function()
    pcall(function() _W.disableRain() end)
    pcall(function() if disableCherry then disableCherry() end end)
    pcall(function() _W.disableSnow() end)
    pcall(function() if disableFog then disableFog() end end)
    _W.clearDrops(_W._rainDrops)
    _W.clearDrops(_W._snowFlakes)
    _W.destroyRainPart()
    _W.destroySnowPart()
    _W.restoreOriginalLighting()
end
_W.turnOffOtherWeathers = function(exceptFlag)
    local weathers = { SnowEnabled="SnowEnabled", RainEnabled="RainEnabled", CherryEnabled="CherryEnabled", CustomFog="CustomFog" }
    for flag, _ in pairs(weathers) do
        if flag ~= exceptFlag and Flags[flag] then
            pcall(function()
                if Library.SetFlags and Library.SetFlags[flag] then Library.SetFlags[flag](false)
                else Flags[flag] = false end
            end)
        end
    end
end
_W.turnOffOtherWeathers = _W.turnOffOtherWeathers

end

do
local OtherPage = Window:Page({ name = "World", Icon = "rbxassetid://11395780588" })
local WorldMultiL = OtherPage:MultiSection({ Side = 1 })
local LightTab = WorldMultiL:Add("Lighting")
local WeatherTab = WorldMultiL:Add("Weather")
local WorldMultiR = OtherPage:MultiSection({ Side = 2 })
local SkyTab = WorldMultiR:Add("Skybox")
local MatTab = WorldMultiR:Add("Materials")
local _lightingTouched = {}
local _atmoHasOrig = false
local _atmoTouched = false
local function updateLightingVis()
    local on = Flags["OverLight"] or false
    if Flags["_Sat"] then Flags["_Sat"]:SetVisibility(on) end
    if Flags["_Bright"] then Flags["_Bright"]:SetVisibility(on) end
    if Flags["_Cont"] then Flags["_Cont"]:SetVisibility(on) end
end
LightTab:addToggle({ name = "Lighting", flag = "OverLight", default = false, callback = function(v)
    if v then
        _origBrightness = _origBrightness or Lighting.Brightness
        _origOutdoorAmbient = _origOutdoorAmbient or Lighting.OutdoorAmbient
    else
        if not _origBrightness then return end
        pcall(function()
            Lighting.Brightness = _origBrightness
            Lighting.OutdoorAmbient = _origOutdoorAmbient
        end)
        local cc = Lighting:FindFirstChild("_AlternateCC")
        if cc then pcall(function() cc:Destroy() end) end
    end
    updateLightingVis()
end })
local _atmoD = LightTab:addSlider({ name = "Atmo Density", flag = "AtmoD", min = 0, max = 100, default = 40, Suffix = "%" })
local _atmoO = LightTab:addSlider({ name = "Atmo Offset", flag = "AtmoO", min = 0, max = 100, default = 0, Suffix = "%" })
local _atmoG = LightTab:addSlider({ name = "Atmo Glare", flag = "AtmoG", min = 0, max = 100, default = 0, Suffix = "%" })
local _atmoH = LightTab:addSlider({ name = "Atmo Haze", flag = "AtmoH", min = 0, max = 100, default = 0, Suffix = "%" })
_atmoD:SetVisibility(false)
_atmoO:SetVisibility(false)
_atmoG:SetVisibility(false)
_atmoH:SetVisibility(false)
LightTab:addToggle({ name = "Override Atmosphere", flag = "OverAtmo", default = false, callback = function(v)
    _atmoD:SetVisibility(v)
    _atmoO:SetVisibility(v)
    _atmoG:SetVisibility(v)
    _atmoH:SetVisibility(v)
    if v then
        local a = Lighting:FindFirstChildOfClass("Atmosphere")
        if a then
            _origAtmoDensity = a.Density; _origAtmoOffset = a.Offset
            _origAtmoGlare   = a.Glare;   _origAtmoHaze   = a.Haze
            _atmoHasOrig = true
        else
            _atmoHasOrig = false
        end
    else
        local a = Lighting:FindFirstChildOfClass("Atmosphere")
        if a then
            if _atmoHasOrig and _origAtmoDensity then
                a.Density = _origAtmoDensity; a.Offset = _origAtmoOffset
                a.Glare   = _origAtmoGlare;   a.Haze   = _origAtmoHaze
            else
                pcall(function() a:Destroy() end)
            end
        end
    end
end })
Flags["_Sat"] = LightTab:addSlider({ name = "Saturation", flag = "Sat", min = -100, max = 100, default = 0, callback = function(v)
    if not _lightingTouched["Sat"] then _lightingTouched["Sat"] = true; return end
    getOrCreateCC().Saturation = v / 100
end })
Flags["_Bright"] = LightTab:addSlider({ name = "Brightness", flag = "Bright", min = 0, max = 5, default = 1, callback = function(v)
    if not _lightingTouched["Bright"] then _lightingTouched["Bright"] = true; return end
    Lighting.Brightness = v
    local boost = math.clamp((v - 1) * 0.15, -0.3, 0.3)
    Lighting.OutdoorAmbient = Color3.new(0.5 + boost, 0.5 + boost, 0.5 + boost)
end })
Flags["_Cont"] = LightTab:addSlider({ name = "Contrast", flag = "Cont", min = -100, max = 100, default = 0, callback = function(v)
    if not _lightingTouched["Cont"] then _lightingTouched["Cont"] = true; return end
    getOrCreateCC().Contrast = v / 100
end })
pcall(updateLightingVis)

local _origTimeOfDay = nil
local _timeConnection = nil
local _timeSlider = LightTab:addSlider({ name = "Time of Day", flag = "TimeOfDay", min = 0, max = 24, default = 12 })
_timeSlider:SetVisibility(false)
LightTab:addToggle({ name = "Override Time", flag = "OverTime", default = false, callback = function(v)
    _timeSlider:SetVisibility(v)
    if v then
        _origTimeOfDay = _origTimeOfDay or Lighting.ClockTime
        if not _timeConnection then
            _timeConnection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
                Lighting.ClockTime = Flags["TimeOfDay"] or 12
            end))
        end
    else
        if _timeConnection then
            _timeConnection:Disconnect()
            _timeConnection = nil
        end
        if _origTimeOfDay then
            Lighting.ClockTime = _origTimeOfDay
        end
    end
end })
local _fogWasOn = false
local _fogStart = WeatherTab:addSlider({ name = "Fog Start", flag = "FogStart", min = 0, max = 5000, default = 0, Suffix = "st" })
local _fogEnd = WeatherTab:addSlider({ name = "Fog End", flag = "FogEnd", min = 100, max = 10000, default = 5000, Suffix = "st" })
_fogStart:SetVisibility(false)
_fogEnd:SetVisibility(false)
local _fogSpinSpd = WeatherTab:addSlider({ name = "Spin Speed", flag = "FogSpinSpd", min = 1, max = 100, default = 20 })
_fogSpinSpd:SetVisibility(false)
local _fogSpin = WeatherTab:addToggle({ name = "Fog Spin", flag = "FogSpin", default = false, callback = function(v)
    if Flags["CustomFog"] then
        _fogSpinSpd:SetVisibility(v)
    end
end })
_fogSpin:SetVisibility(false)
local fogT = WeatherTab:addToggle({ name = "Fog", flag = "CustomFog", default = false, callback = function(v)
    if v then
        _fogWasOn = true
        pcall(_W.disableSnow)
        pcall(function() if disableCherry then disableCherry() end end)
        pcall(function()
            if Library.SetFlags then
                if Library.SetFlags.SnowEnabled then Library.SetFlags.SnowEnabled(false) end
                if Library.SetFlags.CherryEnabled then Library.SetFlags.CherryEnabled(false) end
            else
                Flags["SnowEnabled"] = false; Flags["CherryEnabled"] = false
            end
        end)
    else
    end
    _fogStart:SetVisibility(v)
    _fogEnd:SetVisibility(v)
    _fogSpin:SetVisibility(v)
    _fogSpinSpd:SetVisibility(v and Flags["FogSpin"] or false)
end })
fogT:addColorPicker({ flag = "c_fog", default = Color3.fromRGB(128,128,128), callback = function(c) C.Fog=c end })
_fogStart:SetVisibility(false)
_fogEnd:SetVisibility(false)
_fogSpin:SetVisibility(false)
_fogSpinSpd:SetVisibility(false)
local Debris = game:GetService("Debris")
local LocalPlayer = lp
local function safeRandom(min, max)
    local minInt = math.floor(min or 0)
    local maxInt = math.floor(max or 0)
    if minInt > maxInt then minInt, maxInt = maxInt, minInt end
    if minInt == maxInt then return minInt end
    return math.random(minInt, maxInt)
end
local cherrySettings = {
    MaxPetals = 60,
    SpawnRate = 0.08,
    Lifetime = 16,
    FallSpeed = 1.8,
    WindDirection = Vector3.new(2, 0, 1.5),
    SpawnRadius = 50,
    SpawnHeight = 45,
    GroundDuration = 4.0,
    Colors = {
        Color3.fromRGB(255, 200, 220),
        Color3.fromRGB(255, 180, 210),
        Color3.fromRGB(255, 220, 235),
        Color3.fromRGB(255, 160, 190),
        Color3.fromRGB(255, 210, 225),
        Color3.fromRGB(255, 190, 215),
    },
    CherryFogEnd = 2000,
    CherryFogDensity = 15,
}

local weatherUI = {
    cherry = {},
    rain = {},
    snow = {}
}

do
local cherryPetalFolder
local cherryRunning = false
local cherryActivePetals = {}
local cherryWindGust = Vector3.new(0, 0, 0)
local cherryWindTime = 0
local cherrySpawnConn, cherryUpdateConn, cherryWindConn
local createSakuraPetal = LPH_NO_VIRTUALIZE(function()
    if #cherryActivePetals >= cherrySettings.MaxPetals then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local petal = Instance.new("Part")
    petal.name = "SakuraPetal"
    petal.Size = Vector3.new(0.35, 0.02, 0.5)
    petal.Material = Enum.Material.SmoothPlastic
    petal.CanCollide = false
    petal.CanTouch = false
    petal.CastShadow = false
    petal.Anchored = true
    petal.Reflectance = 0.2
    petal.Transparency = 1
    petal.Parent = cherryPetalFolder
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Sphere
    local scaleMult = 0.4 + math.random() * 0.8
    mesh.Scale = Vector3.new(1 * scaleMult, 0.15, 1.8 * scaleMult)
    mesh.Parent = petal
    local baseColor = cherrySettings.Colors[math.random(1, #cherrySettings.Colors)]
    local brightness = 0.85 + math.random() * 0.3
    petal.Color = Color3.new(
        math.clamp(baseColor.R * brightness, 0, 1),
        math.clamp(baseColor.G * brightness, 0, 1),
        math.clamp(baseColor.B * brightness, 0, 1)
    )
    local randomOffset = Vector3.new(
        math.random(-cherrySettings.SpawnRadius, cherrySettings.SpawnRadius),
        cherrySettings.SpawnHeight + math.random(-6, 10),
        math.random(-cherrySettings.SpawnRadius, cherrySettings.SpawnRadius)
    )
    petal.Position = hrp.Position + randomOffset
    petal.Rotation = Vector3.new(math.random(0, 360), math.random(0, 360), math.random(0, 360))
    local petalData = {
        Instance = petal,
        Position = petal.Position,
        Age = 0,
        Lifetime = cherrySettings.Lifetime + math.random(-4, 5),
        SwaySpeed = math.random(8, 25) / 10,
        SwayWidth = math.random(8, 25) / 10,
        RotSpeed = Vector3.new(
            math.random(-150, 150),
            math.random(-80, 80),
            math.random(-150, 150)
        ),
        SpiralRadius = math.random(12, 60) / 10,
        SpiralSpeed = math.random(4, 16) / 10,
        SpiralPhase = math.random(0, 628) / 100,
        TurbulencePhase = math.random(0, 628) / 100,
        FloatPhase = math.random(0, 628) / 100,
        Grounded = false,
        GroundTime = 0,
        GroundY = hrp.Position.Y - 3 - math.random(0, 25) / 10,
    }
    table.insert(cherryActivePetals, petalData)
end)
local updateSakuraPetals = LPH_NO_VIRTUALIZE(function(deltaTime)
    for i = #cherryActivePetals, 1, -1 do
        local data = cherryActivePetals[i]
        local petal = data.Instance
        if not petal or not petal.Parent then
            table.remove(cherryActivePetals, i)
            continue
        end
        data.Age = data.Age + deltaTime
        local fadeIn = math.min(data.Age / 1.0, 1)
        fadeIn = fadeIn * fadeIn * (3 - 2 * fadeIn)
        local fadeOut = 1
        if data.Grounded then
            fadeOut = math.max(1 - data.GroundTime / cherrySettings.GroundDuration, 0)
            fadeOut = fadeOut * fadeOut
        elseif data.Age > data.Lifetime - 2.5 then
            local t = (data.Age - (data.Lifetime - 2.5)) / 2.5
            fadeOut = math.max(1 - t * t, 0)
        end
        petal.Transparency = 1 - (fadeIn * fadeOut)
        if data.Grounded then
            data.GroundTime = data.GroundTime + deltaTime
            local sink = math.min(data.GroundTime / cherrySettings.GroundDuration, 1)
            petal.Position = Vector3.new(
                data.Position.X,
                data.GroundY - sink * 0.2,
                data.Position.Z
            )
            if data.GroundTime >= cherrySettings.GroundDuration then
                petal:Destroy()
                table.remove(cherryActivePetals, i)
            end
            continue
        end
        if data.Age >= data.Lifetime then
            petal:Destroy()
            table.remove(cherryActivePetals, i)
            continue
        end
        local floatY = math.sin(data.Age * 1.5 + data.FloatPhase) * 0.8
        local turbX = math.sin(data.Age * 1.8 + data.TurbulencePhase) * 0.5
            + math.sin(data.Age * 4.5 + data.TurbulencePhase * 1.2) * 0.2
        local turbZ = math.cos(data.Age * 1.5 + data.TurbulencePhase * 0.6) * 0.4
            + math.cos(data.Age * 3.8 + data.TurbulencePhase * 1.5) * 0.15
        local spiralAngle = data.Age * data.SpiralSpeed + data.SpiralPhase
        local spiralX = math.cos(spiralAngle) * data.SpiralRadius
        local spiralZ = math.sin(spiralAngle) * data.SpiralRadius
        local swayX = math.sin(data.Age * data.SwaySpeed) * data.SwayWidth
        local swayZ = math.cos(data.Age * data.SwaySpeed * 0.6) * data.SwayWidth
        local currentFall = cherrySettings.FallSpeed
        local fallVector = Vector3.new(0, -currentFall + floatY * 0.3, 0)
        local driftVector = cherrySettings.WindDirection + cherryWindGust + Vector3.new(
            swayX + spiralX * 0.35 + turbX,
            floatY * 0.15,
            swayZ + spiralZ * 0.35 + turbZ
        )
        data.Position = data.Position + (fallVector + driftVector) * deltaTime
        if data.Position.Y <= data.GroundY then
            data.Position = Vector3.new(data.Position.X, data.GroundY, data.Position.Z)
            data.Grounded = true
            petal.CFrame = CFrame.new(data.Position) * CFrame.Angles(
                math.rad(math.random(-30, 30)),
                math.random() * 6.28,
                math.rad(math.random(-30, 30))
            )
            continue
        end
        petal.Position = data.Position
        local tumbleIntensity = 1 + math.sin(data.Age * 2.5) * 0.4
        petal.CFrame = CFrame.new(data.Position) * CFrame.Angles(
            math.rad(data.RotSpeed.X * data.Age * 0.5 * tumbleIntensity),
            math.rad(data.RotSpeed.Y * data.Age * 0.3 * tumbleIntensity),
            math.rad(data.RotSpeed.Z * data.Age * 0.5 * tumbleIntensity)
        )
    end
end)
local cherryWindUpdate = LPH_NO_VIRTUALIZE(function(dt)
    cherryWindTime = cherryWindTime + dt
    local gustX = math.sin(cherryWindTime * 0.4) * 2.5 + math.sin(cherryWindTime * 1.1) * 1.5 + math.sin(cherryWindTime * 2.5) * 0.6
    local gustZ = math.cos(cherryWindTime * 0.3) * 2.0 + math.sin(cherryWindTime * 1.4) * 1.2 + math.cos(cherryWindTime * 2.1) * 0.5
    cherryWindGust = Vector3.new(gustX, 0, gustZ)
end)
enableCherry = function()
    if cherryRunning then return end
    cherryRunning = true
    local old = workspace:FindFirstChild("PortalVisual_CherryBlossoms")
    if old then old:Destroy() end
    cherryPetalFolder = Instance.new("Folder")
    cherryPetalFolder.name = "PortalVisual_CherryBlossoms"
    cherryPetalFolder.Parent = workspace
    cherryActivePetals = {}
    cherryWindGust = Vector3.new(0, 0, 0)
    cherryWindTime = 0
    cherryWindConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt) cherryWindUpdate(dt) end))
    cherrySpawnConn = task.spawn(function()
        while cherryRunning do
            createSakuraPetal()
            task.wait(cherrySettings.SpawnRate)
        end
    end)
    cherryUpdateConn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt) updateSakuraPetals(dt) end))
end
disableCherry = function()
    cherryRunning = false
    if cherrySpawnConn then task.cancel(cherrySpawnConn); cherrySpawnConn = nil end
    if cherryUpdateConn then cherryUpdateConn:Disconnect(); cherryUpdateConn = nil end
    if cherryWindConn then cherryWindConn:Disconnect(); cherryWindConn = nil end
    if cherryPetalFolder then pcall(function() cherryPetalFolder:Destroy() end); cherryPetalFolder = nil end
    cherryActivePetals = {}
end
end
do
local fogRunning = false
local fogAtmosphere
enableFog = function()
    if fogRunning then return end
    fogRunning = true
    _W.saveOriginalLighting()
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj.name = = "PortalAura" and obj:IsA("Atmosphere") then
            obj:Destroy()
        end
    end
    fogAtmosphere = Instance.new("Atmosphere", Lighting)
    fogAtmosphere.name = "PortalAura"
    fogAtmosphere.Color = Color3.fromRGB(185, 195, 210)
    fogAtmosphere.Decay = Color3.fromRGB(170, 175, 185)
    fogAtmosphere.Density = 0.42
    fogAtmosphere.Haze = 3.5
    fogAtmosphere.Glare = 0.5
    fogAtmosphere.Offset = 0
    Lighting.FogColor = Color3.fromRGB(185, 195, 210)
    Lighting.FogStart = 50
    Lighting.FogEnd = 900
end
disableFog = function()
    if not fogRunning then return end
    fogRunning = false
    _W.restoreOriginalLighting()
    if fogAtmosphere then
        pcall(function() fogAtmosphere:Destroy() end)
        fogAtmosphere = nil
    end
end
end
weatherUI.cherry.max = WeatherTab:addSlider({ name = "Cherry Max Petals", flag = "CherryMax", min = 10, max = 250, default = 60, callback = function(v) cherrySettings.MaxPetals = v end })
weatherUI.cherry.rate = WeatherTab:addSlider({ name = "Cherry Spawn Rate", flag = "CherryRate", min = 1, max = 50, default = 8, Suffix = "/100s", callback = function(v) cherrySettings.SpawnRate = v / 100 end })
weatherUI.cherry.speed = WeatherTab:addSlider({ name = "Cherry Fall Speed", flag = "CherrySpeed", min = 5, max = 100, default = 18, Suffix = "/10", callback = function(v) cherrySettings.FallSpeed = v / 10 end })
weatherUI.cherry.area = WeatherTab:addSlider({ name = "Radius", flag = "CherryArea", min = 10, max = 150, default = 50, callback = function(v) cherrySettings.SpawnRadius = v end })
weatherUI.cherry.fogEnd = WeatherTab:addSlider({ name = "Fog Distance", flag = "CherryFogEnd", min = 100, max = 10000, default = 2000, Suffix = "st", callback = function(v) if activeWeather == "Cherry Blossoms" then _W.applyWeatherAtmosphere("Cherry") end end })
weatherUI.cherry.fogDensity = WeatherTab:addSlider({ name = "Fog Density", flag = "CherryFogDensity", min = 0, max = 100, default = 15, Suffix = "%", callback = function(v) if activeWeather == "Cherry Blossoms" then _W.applyWeatherAtmosphere("Cherry") end end })
local function setCherrySlidersVisibility(v)
    weatherUI.cherry.max:SetVisibility(v)
    weatherUI.cherry.rate:SetVisibility(v)
    weatherUI.cherry.speed:SetVisibility(v)
    weatherUI.cherry.area:SetVisibility(v)
    weatherUI.cherry.fogEnd:SetVisibility(v)
    weatherUI.cherry.fogDensity:SetVisibility(v)
end
local cherryToggle = WeatherTab:addToggle({ name = "Cherry Blossoms", flag = "CherryEnabled", default = false, callback = function(v)
    clearWeatherObjects()
    setCherrySlidersVisibility(v)
    if not v then
        if activeWeather == "Cherry Blossoms" then activeWeather = "None" end
        return
    end
    _W.turnOffOtherWeathers("CherryEnabled")
    activeWeather = "Cherry Blossoms"
    _W.applyWeatherAtmosphere("Cherry")
    pcall(enableCherry)
end })
cherryToggle:addColorPicker({ flag = "c_cherry_fog", default = Color3.fromRGB(255, 230, 240), callback = function(c)
    if activeWeather == "Cherry Blossoms" then _W.applyWeatherAtmosphere("Cherry") end
end })
setCherrySlidersVisibility(false)

weatherUI.rain.rate = WeatherTab:addSlider({ name = "Rain Rate", flag = "RainRate", min = 10, max = 1000, default = 250, callback = function(v)
    _W.rainSettings.Rate = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.speed = WeatherTab:addSlider({ name = "Rain Speed", flag = "RainSpeed", min = 10, max = 300, default = 120, callback = function(v)
    _W.rainSettings.Speed = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.size = WeatherTab:addSlider({ name = "Rain Size", flag = "RainSize", min = 1, max = 40, default = 8, callback = function(v)
    _W.rainSettings.Size = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.width = WeatherTab:addSlider({ name = "Rain Width", flag = "RainWidth", min = 1, max = 100, default = 30, Suffix = "%", callback = function(v)
    _W.rainSettings.Width = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.area = WeatherTab:addSlider({ name = "Rain Radius", flag = "RainArea", min = 10, max = 300, default = 100, callback = function(v)
    _W.rainSettings.Radius = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.splash = WeatherTab:addToggle({ name = "Rain Splashes", flag = "RainSplashes", default = true, callback = function(v)
    _W.rainSettings.Splashes = v
    pcall(_W.refreshRain)
end })
local function setRainSlidersVisibility(v)
    weatherUI.rain.rate:SetVisibility(v)
    weatherUI.rain.speed:SetVisibility(v)
    weatherUI.rain.size:SetVisibility(v)
    weatherUI.rain.width:SetVisibility(v)
    weatherUI.rain.area:SetVisibility(v)
    weatherUI.rain.splash:SetVisibility(v)
end
local rainToggle = WeatherTab:addToggle({ name = "Rain", flag = "RainEnabled", default = false, callback = function(v)
    setRainSlidersVisibility(v)
    if not v then
        pcall(_W.disableRain)
        if activeWeather == "Rain" then activeWeather = "None" end
        return
    end
    pcall(_W.disableSnow)
    pcall(function() if disableCherry then disableCherry() end end)
    pcall(function()
        if Library.SetFlags then
            if Library.SetFlags.SnowEnabled then Library.SetFlags.SnowEnabled(false) end
            if Library.SetFlags.CherryEnabled then Library.SetFlags.CherryEnabled(false) end
        else
            Flags["SnowEnabled"] = false; Flags["CherryEnabled"] = false
        end
    end)
    activeWeather = "Rain"
    pcall(_W.enableRain)
end })
rainToggle:addColorPicker({ flag = "c_rain", default = Color3.fromRGB(190, 205, 240), callback = function(c)
    pcall(_W.refreshRain)
end })

setRainSlidersVisibility(false)

weatherUI.snow.rate = WeatherTab:addSlider({ name = "Snow Rate", flag = "SnowRate", min = 10, max = 500, default = 150, callback = function(v)
    _W.snowSettings.Rate = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.speed = WeatherTab:addSlider({ name = "Snow Speed", flag = "SnowSpeed", min = 5, max = 150, default = 25, callback = function(v)
    _W.snowSettings.Speed = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.size = WeatherTab:addSlider({ name = "Snow Size", flag = "SnowSize", min = 1, max = 15, default = 3, callback = function(v)
    _W.snowSettings.Size = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.area = WeatherTab:addSlider({ name = "Snow Radius", flag = "SnowArea", min = 10, max = 300, default = 100, callback = function(v)
    _W.snowSettings.Radius = v
    pcall(_W.refreshSnow)
end })
local function setSnowSlidersVisibility(v)
    weatherUI.snow.rate:SetVisibility(v)
    weatherUI.snow.speed:SetVisibility(v)
    weatherUI.snow.size:SetVisibility(v)
    weatherUI.snow.area:SetVisibility(v)
end
local snowToggle = WeatherTab:addToggle({ name = "Snow", flag = "SnowEnabled", default = false, callback = function(v)
    clearWeatherObjects()
    setSnowSlidersVisibility(v)
    if not v then
        if activeWeather == "Snow" then activeWeather = "None" end
        return
    end
    _W.turnOffOtherWeathers("SnowEnabled")
    activeWeather = "Snow"
    _W.applyWeatherAtmosphere("Snow")
    pcall(_W.enableSnow)
end })

setSnowSlidersVisibility(false)
SkyTab:addToggle({ name = "Custom Skybox", flag = "CustomSkybox", default = false, callback = function(v)
    if v then
        local d=Skyboxes[Flags["SkyChoice"] or "Space"]; if d then
            if not originalSky then originalSky=Lighting:FindFirstChildOfClass("Sky") end
            if skyboxObj then skyboxObj:Destroy() end; skyboxObj=Instance.new("Sky")
            skyboxObj.SkyboxUp=d.Up; skyboxObj.SkyboxRt=d.Rt; skyboxObj.SkyboxLf=d.Lf; skyboxObj.SkyboxFt=d.Ft; skyboxObj.SkyboxBk=d.Bk; skyboxObj.SkyboxDn=d.Dn
            if d.Moon then skyboxObj.MoonTextureId=d.Moon end
            skyboxObj.Parent=Lighting; if originalSky then originalSky.Parent=nil end end
    else if skyboxObj then skyboxObj:Destroy(); skyboxObj=nil end; if originalSky then originalSky.Parent=Lighting end end
end })
local skyNames={}; for k in pairs(Skyboxes) do table.insert(skyNames,k) end; table.sort(skyNames)
SkyTab:addDropdown({ name = "Skybox", flag = "SkyChoice", items = skyNames, default = "Space", callback = function(v)
    if Flags["CustomSkybox"] then local d=Skyboxes[v]; if d then
        if skyboxObj then skyboxObj:Destroy() end; skyboxObj=Instance.new("Sky")
        skyboxObj.SkyboxUp=d.Up; skyboxObj.SkyboxRt=d.Rt; skyboxObj.SkyboxLf=d.Lf; skyboxObj.SkyboxFt=d.Ft; skyboxObj.SkyboxBk=d.Bk; skyboxObj.SkyboxDn=d.Dn; if d.Moon then skyboxObj.MoonTextureId=d.Moon end; skyboxObj.Parent=Lighting end end
end })
SkyTab:addToggle({ name = "Skybox Spin", flag = "SkySpin", default = false })
SkyTab:addSlider({ name = "Spin Speed", flag = "SkySpinSpd", min = 1, max = 100, default = 20 })
_origSunSize, _origMoonSize, _origStarCount = nil, nil, nil
_origSunRaysEnabled = nil
local function _getActiveSky() return skyboxObj or Lighting:FindFirstChildOfClass("Sky") end
SkyTab:addToggle({ name = "Hide Sun", flag = "HideSun", default = false, callback = function(v)
    local sky = _getActiveSky()
    if sky then
        if v then _origSunSize = _origSunSize or sky.SunAngularSize; sky.SunAngularSize = 0
        else sky.SunAngularSize = _origSunSize or 21.6 end
    end
    local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
    if sunRays then
        if v then
            if _origSunRaysEnabled == nil then _origSunRaysEnabled = sunRays.Enabled end
            sunRays.Enabled = false
        else
            if _origSunRaysEnabled ~= nil then
                sunRays.Enabled = _origSunRaysEnabled
            else
                sunRays.Enabled = true
            end
        end
    end
end })
SkyTab:addToggle({ name = "Hide Moon", flag = "HideMoon", default = false, callback = function(v)
    local sky = _getActiveSky()
    if not sky then return end
    if v then _origMoonSize = _origMoonSize or sky.MoonAngularSize; sky.MoonAngularSize = 0
    else sky.MoonAngularSize = _origMoonSize or 11.17 end
end })
SkyTab:addToggle({ name = "Hide Stars", flag = "HideStars", default = false, callback = function(v)
    local sky = _getActiveSky()
    if not sky then return end
    if v then _origStarCount = _origStarCount or sky.StarCount; sky.StarCount = 0
    else sky.StarCount = _origStarCount or 3000 end
end })
MatTab:addToggle({ name = "Custom Material", flag = "CustMat", default = false })
MatTab:addDropdown({ name = "Material", flag = "MatType", items = {"None","Plastic","SmoothPlastic","Neon","ForceField","Glass","Wood","WoodPlanks","Marble","Granite","Slate","Concrete","Cobblestone","Brick","Sand","Fabric","CrackedLava","Ice","Glacier","Snow","Grass","Slate (Minecraft)","Grass (Minecraft)","Sand (Minecraft)","Wood (Minecraft)","Brick (Minecraft)","Concrete (Minecraft)","CorrodedMetal (Minecraft)","Metal (Minecraft)","WoodPlanks (Minecraft)"}, default = "None" })
MatTab:addDropdown({ name = "Apply To", flag = "MatApply", items = {"All Parts","MeshParts","BaseParts","Wedges","Cylinders"}, default = "All Parts" })
local mClr = MatTab:addToggle({ name = "Custom Color", flag = "MatClr", default = false })
mClr:addColorPicker({ flag = "c_mat", default = Color3.new(1,1,1) })

end

do
local VisualsPage = Window:Page({ name = "ESP", Icon = "rbxassetid://6523858394" })
local EspTab = VisualsPage:Section({ name = "ESP", Side = 1 })
local ChamsMultiR = VisualsPage:MultiSection({ Side = 2 })
local ChamsTab = ChamsMultiR:Add("Chams")
local EffectsTab = ChamsMultiR:Add("Effects")


local function setVis(flagKey, visible)
    if Flags[flagKey] then pcall(function() Flags[flagKey]:SetVisibility(visible) end) end
end

local function updateESPVisibility()
    local espEnabled = Flags["ESP_Enabled"] or false
    local boxEnabled = espEnabled and (Flags["ESP_BoxEnabled"] or false)
    local fillEnabled = boxEnabled and (Flags["ESP_BoxFillEnabled"] or false)
    local nameEnabled = espEnabled and (Flags["ESP_NameEnabled"] or false)
    local distEnabled = espEnabled and (Flags["ESP_DistanceEnabled"] or false)
    local healthBarEnabled = espEnabled and (Flags["ESP_HealthBarEnabled"] or false)
    local healthTextEnabled = espEnabled and (Flags["ESP_HealthTextEnabled"] or false)
    local tracerEnabled = espEnabled and (Flags["ESP_TracerEnabled"] or false)
    local toolTextEnabled = espEnabled and (Flags["ESP_ToolTextEnabled"] or false)

    setVis("_ESP_Font", espEnabled)
    setVis("_ESP_ShowOn", espEnabled)
    setVis("_ESP_MaxDistance", espEnabled)
    setVis("_ESP_BoxEnabled", espEnabled)
    setVis("_ESP_BoxShape", boxEnabled)
    setVis("_ESP_BoxGlowAmount", boxEnabled)
    setVis("_ESP_BoxFillEnabled", boxEnabled)
    setVis("_ESP_BoxFillTrans1", fillEnabled)
    setVis("_ESP_BoxFillTrans2", fillEnabled)
    setVis("_ESP_NameEnabled", espEnabled)
    setVis("_ESP_NamePos", nameEnabled)
    setVis("_ESP_NameType", nameEnabled)
    setVis("_ESP_DistanceEnabled", espEnabled)
    setVis("_ESP_DistancePos", distEnabled)
    setVis("_ESP_DistanceType", distEnabled)
    setVis("_ESP_HealthBarEnabled", espEnabled)
    setVis("_ESP_HealthBarGradientEnabled", healthBarEnabled)
    setVis("_ESP_HealthTextEnabled", espEnabled)
    setVis("_ESP_ArmorBarEnabled", espEnabled)
    setVis("_ESP_WeaponEnabled", espEnabled)
    setVis("_ESP_FlagsEnabled", espEnabled)
    setVis("_ESP_TextSize", espEnabled)
    setVis("_ESP_TextOutline", espEnabled)
    setVis("_ESP_BoxThickness", boxEnabled)
    setVis("_ESP_TracerEnabled", espEnabled)
    setVis("_ESP_TracerOrigin", tracerEnabled)
    setVis("_ESP_ToolTextEnabled", espEnabled)
    setVis("_ESP_ToolTextCasing", toolTextEnabled)
    setVis("_ESP_ToolIconEnabled", espEnabled)
    setVis("_ESP_HealthTextHideIfFull", healthTextEnabled)
    setVis("_ESP_BoxGlowEnabled", boxEnabled)
end

EspTab:addToggle({ name = "Enable ESP", flag = "ESP_Enabled", default = false, callback = updateESPVisibility })
Flags["_ESP_ShowOn"] = EspTab:addDropdown({ name = "Show On", flag = "ESP_ShowOn", items = {"NPC", "Enemy", "Team", "Self"}, default = {"Enemy", "NPC"}, multi = true, callback = function()
    local showOn = Flags["ESP_ShowOn"] or {}
    if hasCheck(showOn, "Self") then
        EspLibrary:AddTarget(lp)
    else
        EspLibrary:RemoveTarget(lp)
    end
end })
Flags["_ESP_MaxDistance"] = EspTab:addSlider({ name = "Max Distance", flag = "ESP_MaxDistance", min = 50, max = 10000, default = 3000, Suffix = " studs" })
Flags["_ESP_Font"] = EspTab:addDropdown({ name = "ESP Font", flag = "ESP_Font", items = {"ProggyClean", "SmallestPixel", "Tahoma", "TahomaBold", "Arial", "SourceSans"}, default = "ProggyClean" })
Flags["_ESP_TextSize"] = EspTab:addSlider({ name = "Text Size", flag = "ESP_TextSize", min = 8, max = 20, default = 11, Suffix = "px" })
Flags["_ESP_TextOutline"] = EspTab:addToggle({ name = "Text Outline", flag = "ESP_TextOutline", default = true })

local boxT = EspTab:addToggle({ name = "Box ESP", flag = "ESP_BoxEnabled", default = false, callback = updateESPVisibility })
boxT:addColorPicker({ flag = "ESP_BoxInlineColor", default = Color3.fromRGB(255, 255, 255) })
boxT:addColorPicker({ flag = "ESP_BoxOutlineColor", default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_BoxShape"] = EspTab:addDropdown({ name = "Box Shape", flag = "ESP_BoxShape", items = {"Full", "Cornered"}, default = "Full" })
Flags["_ESP_BoxThickness"] = EspTab:addSlider({ name = "Box Thickness", flag = "ESP_BoxThickness", min = 1, max = 5, default = 1, Suffix = "px" })

local fillT = EspTab:addToggle({ name = "Box Fill", flag = "ESP_BoxFillEnabled", default = false, callback = updateESPVisibility })
fillT:addColorPicker({ flag = "ESP_BoxFillColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_BoxFillEnabled"] = fillT
Flags["_ESP_BoxFillTrans1"] = EspTab:addSlider({ name = "Fill Transparency 1", flag = "ESP_BoxFillTrans1", min = 0, max = 100, default = 100, Suffix = "%" })
Flags["_ESP_BoxFillTrans2"] = EspTab:addSlider({ name = "Fill Transparency 2", flag = "ESP_BoxFillTrans2", min = 0, max = 100, default = 65, Suffix = "%" })

Flags["_ESP_BoxGlowEnabled"] = EspTab:addToggle({ name = "Box Glow", flag = "ESP_BoxGlowEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_BoxGlowEnabled"]:addColorPicker({ flag = "ESP_BoxGlowColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_BoxGlowAmount"] = EspTab:addSlider({ name = "Glow Amount", flag = "ESP_BoxGlowAmount", min = 0, max = 100, default = 65, Suffix = "%" })

local nameT = EspTab:addToggle({ name = "Name ESP", flag = "ESP_NameEnabled", default = false, callback = updateESPVisibility })
nameT:addColorPicker({ flag = "ESP_NameInlineColor", default = Color3.fromRGB(255, 255, 255) })
nameT:addColorPicker({ flag = "ESP_NameOutlineColor", default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_NamePos"] = EspTab:addDropdown({ name = "Name Position", flag = "ESP_NamePos", items = {"Top", "Bottom", "Left", "Right"}, default = "Top" })
Flags["_ESP_NameType"] = EspTab:addDropdown({ name = "Name Type", flag = "ESP_NameType", items = {"Display Name", "Username", "Both"}, default = "Display Name" })

local distT = EspTab:addToggle({ name = "Distance ESP", flag = "ESP_DistanceEnabled", default = false, callback = updateESPVisibility })
distT:addColorPicker({ flag = "ESP_DistanceInlineColor", default = Color3.fromRGB(255, 255, 255) })
distT:addColorPicker({ flag = "ESP_DistanceOutlineColor", default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_DistancePos"] = EspTab:addDropdown({ name = "Distance Position", flag = "ESP_DistancePos", items = {"Top", "Bottom", "Left", "Right"}, default = "Bottom" })
Flags["_ESP_DistanceType"] = EspTab:addDropdown({ name = "Distance Type", flag = "ESP_DistanceType", items = {"Studs", "Meters"}, default = "Studs" })

local hpBarT = EspTab:addToggle({ name = "Health Bar", flag = "ESP_HealthBarEnabled", default = false, callback = updateESPVisibility })
hpBarT:addColorPicker({ flag = "ESP_HealthBarInlineColor", default = Color3.fromRGB(0, 255, 0) })
hpBarT:addColorPicker({ flag = "ESP_HealthBarOutlineColor", default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_HealthBarGradientEnabled"] = EspTab:addToggle({ name = "Health Bar Gradient", flag = "ESP_HealthBarGradientEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_HealthBarGradientEnabled"]:addColorPicker({ flag = "ESP_HealthBarTopColor", default = Color3.fromRGB(0, 255, 0) })
Flags["_ESP_HealthBarGradientEnabled"]:addColorPicker({ flag = "ESP_HealthBarMidColor", default = Color3.fromRGB(255, 170, 0) })
Flags["_ESP_HealthBarGradientEnabled"]:addColorPicker({ flag = "ESP_HealthBarBotColor", default = Color3.fromRGB(255, 0, 0) })

Flags["_ESP_HealthTextEnabled"] = EspTab:addToggle({ name = "Health Text", flag = "ESP_HealthTextEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_HealthTextEnabled"]:addColorPicker({ flag = "ESP_HealthTextInlineColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_HealthTextEnabled"]:addColorPicker({ flag = "ESP_HealthTextOutlineColor", default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_HealthTextHideIfFull"] = EspTab:addToggle({ name = "Hide Health If Full", flag = "ESP_HealthTextHideIfFull", default = false, callback = updateESPVisibility })

Flags["_ESP_ArmorBarEnabled"] = EspTab:addToggle({ name = "Armor Bar", flag = "ESP_ArmorBarEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_ArmorBarEnabled"]:addColorPicker({ flag = "ESP_ArmorBarInlineColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_ArmorBarEnabled"]:addColorPicker({ flag = "ESP_ArmorBarOutlineColor", default = Color3.fromRGB(0, 0, 0) })

Flags["_ESP_TracerEnabled"] = EspTab:addToggle({ name = "Tracer ESP", flag = "ESP_TracerEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_TracerEnabled"]:addColorPicker({ flag = "ESP_TracerColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_TracerOrigin"] = EspTab:addDropdown({ name = "Tracer Origin", flag = "ESP_TracerOrigin", items = {"Bottom", "Top", "Cursor", "Center"}, default = "Bottom" })

Flags["_ESP_WeaponEnabled"] = EspTab:addToggle({ name = "Weapon ESP", flag = "ESP_WeaponEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_WeaponEnabled"]:addColorPicker({ flag = "ESP_WeaponColor", default = Color3.fromRGB(255, 255, 255) })

Flags["_ESP_FlagsEnabled"] = EspTab:addToggle({ name = "State Flags", flag = "ESP_FlagsEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_FlagsEnabled"]:addColorPicker({ flag = "ESP_FlagsColor", default = Color3.fromRGB(255, 0, 0) })

Flags["_ESP_ToolTextEnabled"] = EspTab:addToggle({ name = "Tool Text", flag = "ESP_ToolTextEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_ToolTextEnabled"]:addColorPicker({ flag = "ESP_ToolTextColor", default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_ToolTextCasing"] = EspTab:addDropdown({ name = "Tool Text Casing", flag = "ESP_ToolTextCasing", items = {"Lowercase", "Uppercase"}, default = "Lowercase" })

Flags["_ESP_ToolIconEnabled"] = EspTab:addToggle({ name = "Tool Icon", flag = "ESP_ToolIconEnabled", default = false, callback = updateESPVisibility })
Flags["_ESP_ToolIconEnabled"]:addColorPicker({ flag = "ESP_ToolIconColor", default = Color3.fromRGB(255, 255, 255) })

task.spawn(function()
    task.wait(0.5)
    pcall(updateESPVisibility)
end)

local function getColorFromFlag(flagName, default, rgbMode, rgbSpeedFlag)
    local flagVal = Flags[flagName]
    local baseColor
    if typeof(flagVal) == "Color3" then
        baseColor = flagVal
    elseif type(flagVal) == "table" then
        baseColor = flagVal.Color or default
    else
        baseColor = default
    end
    if Flags[rgbMode] then
        local speed = Flags[rgbSpeedFlag] or 5
        local hue = (tick() * speed / 10) % 1
        local _, s, v = baseColor:ToHSV()
        return Color3.fromHSV(hue, s, v)
    end
    return baseColor
end

local function getChamsColor(flagName, default)
    return getColorFromFlag(flagName, default, "ChamsRGBMode", "ChamsRGBSpeed")
end

local function applyChamsHighlight(char, fillColor, outlineColor, fillTrans, outlineTrans, alwaysOnTop, outlineOnly, glowAmount, textureId)
    if not char then return end
    local hl = char:FindFirstChild("_Chams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.name = "_Chams"
    end
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = outlineOnly and 1 or fillTrans
    hl.OutlineTransparency = outlineTrans
    hl.DepthMode = alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    if hl.Parent ~= char then hl.Parent = char end

    if textureId and textureId ~= "" then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                if not p:FindFirstChild("_ChamsTex") then
                    local tex = Instance.new("Texture")
                    tex.name = "_ChamsTex"
                    tex.Face = Enum.NormalId.Front
                    tex.Parent = p
                end
                local tex = p:FindFirstChild("_ChamsTex")
                tex.Texture = textureId
                tex.Color3 = fillColor
                tex.Transparency = fillTrans
            end
        end
    else
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                local tex = p:FindFirstChild("_ChamsTex")
                if tex then tex:Destroy() end
            end
        end
    end

    if glowAmount > 0 then
        local blur = char:FindFirstChild("_ChamsBlur")
        if not blur then
            blur = Instance.new("BlurEffect")
            blur.name = "_ChamsBlur"
            blur.Parent = char
        end
        blur.Size = glowAmount * 20
    else
        local blur = char:FindFirstChild("_ChamsBlur")
        if blur then blur:Destroy() end
    end
end

local function removeChamsHighlight(char)
    if not char then return end
    local hl = char:FindFirstChild("_Chams")
    if hl then hl:Destroy() end
    local blur = char:FindFirstChild("_ChamsBlur")
    if blur then blur:Destroy() end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            local tex = p:FindFirstChild("_ChamsTex")
            if tex then tex:Destroy() end
        end
    end
end

local function isCharVisible(char)
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hrp then return false end
    local origin = camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {lp.Character, char}
    local res = workspace:Raycast(origin, hrp.Position - origin, rayParams)
    return not res
end

local function applyOrRemoveChams(char, checkDead, checkWall, isSelf, chamsParams)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local isDead = hum and (hum.Health <= 0 or isKnockedOrKO(char) or isDeadCheck(char))
    if checkDead and isDead then
        removeChamsHighlight(char)
    elseif checkWall and not isSelf then
        if isCharVisible(char) then
            applyChamsHighlight(char, table.unpack(chamsParams))
        else
            removeChamsHighlight(char)
        end
    else
        applyChamsHighlight(char, table.unpack(chamsParams))
    end
end

local updateChams = LPH_NO_VIRTUALIZE(function()
    local enabled = Flags["PlayerChams"]
    local targets = Flags["ChamsTargets"] or {}
    if type(targets) ~= "table" then targets = {} end
    local showSelf = hasCheck(targets, "Self")
    local showOthers = hasCheck(targets, "Player")
    local showNPCs = hasCheck(targets, "NPC")
    local checks = Flags["ChamsChecks"] or {}
    if type(checks) ~= "table" then checks = {} end
    local checkWall = hasCheck(checks, "Wall")
    local checkDead = hasCheck(checks, "Dead")
    local checkEnemy = hasCheck(checks, "Enemy")
    local checkTeam = hasCheck(checks, "Team")

    local chamsParams = {
        getChamsColor("ChamsFillColor", Color3.fromRGB(255, 255, 255)),
        getChamsColor("ChamsOutlineColor", Color3.fromRGB(0, 0, 0)),
        (Flags["ChamsFillTransparency"] or 50) / 100,
        (Flags["ChamsOutlineTransparency"] or 0) / 100,
        Flags["ChamsAlwaysOnTop"] or false,
        Flags["ChamsOutlineOnly"] or false,
        (Flags["ChamsGlowAmount"] or 0) / 100,
        Flags["ChamsTexture"] or "",
    }

    if not enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then removeChamsHighlight(p.Character) end
        end
        for _, bot in ipairs(getNPCs()) do removeChamsHighlight(bot) end
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            local isSelf = (p == lp)
            local shouldCham = isSelf and showSelf or (not isSelf and showOthers)
            if shouldCham and not isSelf then
                if checkTeam and p.Team == lp.Team then shouldCham = false end
                if checkEnemy and p.Team ~= lp.Team then shouldCham = false end
            end
            if shouldCham then
                applyOrRemoveChams(char, checkDead, checkWall, isSelf, chamsParams)
            else
                removeChamsHighlight(char)
            end
        end
    end

    if showNPCs then
        for _, bot in ipairs(getNPCs()) do
            applyOrRemoveChams(bot, checkDead, checkWall, false, chamsParams)
        end
    else
        for _, bot in ipairs(getNPCs()) do removeChamsHighlight(bot) end
    end
end)

task.spawn(function()
    while _scriptRunning do
        task.wait(0.05)
        pcall(updateChams)
    end
end)

local chamsT = ChamsTab:addToggle({ name = "Player Chams", flag = "PlayerChams", default = false, callback = updateChams })
ChamsTab:addDropdown({ name = "Targets", flag = "ChamsTargets", items = {"Player", "NPC", "Self"}, default = {}, multi = true, callback = updateChams })
chamsT:addColorPicker({ flag = "ChamsFillColor", default = Color3.fromRGB(255, 255, 255), callback = updateChams })
chamsT:addColorPicker({ flag = "ChamsOutlineColor", default = Color3.fromRGB(0, 0, 0), callback = updateChams })
ChamsTab:addSlider({ name = "Fill Transparency", flag = "ChamsFillTransparency", min = 0, max = 100, default = 50, Suffix = "%", callback = updateChams })
ChamsTab:addSlider({ name = "Outline Transparency", flag = "ChamsOutlineTransparency", min = 0, max = 100, default = 0, Suffix = "%", callback = updateChams })
ChamsTab:addToggle({ name = "RGB Mode", flag = "ChamsRGBMode", default = false, callback = updateChams })
ChamsTab:addSlider({ name = "RGB Speed", flag = "ChamsRGBSpeed", min = 1, max = 20, default = 5, callback = updateChams })
ChamsTab:addDropdown({ name = "Texture", flag = "ChamsTexture", items = {"None", "Neon", "Plastic", "ForceField", "Glow"}, default = "None", callback = updateChams })
ChamsTab:addDropdown({ name = "Checks", flag = "ChamsChecks", items = {"Dead", "Wall", "NPC", "Enemy", "Team"}, default = {}, multi = true, callback = updateChams })

local toolChamsT = ChamsTab:addToggle({ name = "Tool Chams", flag = "ToolChamsEnabled", default = false })
ChamsTab:addDropdown({ name = "Tool Targets", flag = "ToolChamsTargets", items = {"Player", "NPC", "Self"}, default = {"Player"}, multi = true })
toolChamsT:addColorPicker({ flag = "ToolChamsColor", default = Color3.fromRGB(255, 255, 255) })
toolChamsT:addColorPicker({ flag = "ToolChamsOutlineColor", default = Color3.fromRGB(0, 0, 0) })
ChamsTab:addSlider({ name = "Tool Fill Transparency", flag = "ToolChamsTrans", min = 0, max = 100, default = 0, Suffix = "%" })
ChamsTab:addSlider({ name = "Tool Outline Transparency", flag = "ToolChamsOutlineTrans", min = 0, max = 100, default = 0, Suffix = "%" })
ChamsTab:addToggle({ name = "Tool RGB Mode", flag = "ToolChamsRGBMode", default = false })
ChamsTab:addSlider({ name = "Tool RGB Speed", flag = "ToolChamsRGBSpeed", min = 1, max = 20, default = 5 })

task.spawn(function()
    while _scriptRunning do
        task.wait(0.1)
        if Flags["ToolChamsEnabled"] then
            local toolColor = getColorFromFlag("ToolChamsColor", Color3.fromRGB(255, 255, 255), "ToolChamsRGBMode", "ToolChamsRGBSpeed")
            local toolOutlineColor = getColorFromFlag("ToolChamsOutlineColor", Color3.fromRGB(0, 0, 0), "ToolChamsRGBMode", "ToolChamsRGBSpeed")
            local toolTrans = (Flags["ToolChamsTrans"] or 0) / 100
            local toolOutlineTrans = (Flags["ToolChamsOutlineTrans"] or 0) / 100
            local toolTargets = Flags["ToolChamsTargets"] or {}
            if type(toolTargets) ~= "table" then toolTargets = {} end
            local showSelfT = hasCheck(toolTargets, "Self")
            local showOthersT = hasCheck(toolTargets, "Player")
            for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                if char then
                    local isSelf = (p == lp)
                    local shouldT = isSelf and showSelfT or (not isSelf and showOthersT)
                    if shouldT then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local hl = tool:FindFirstChild("_ToolChamsHL")
                                if not hl then
                                    hl = Instance.new("Highlight")
                                    hl.name = "_ToolChamsHL"
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Parent = tool
                                end
                                hl.FillColor = toolColor
                                hl.OutlineColor = toolOutlineColor
                                hl.FillTransparency = toolTrans
                                hl.OutlineTransparency = toolOutlineTrans
                            end
                        end
                    else
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local hl = tool:FindFirstChild("_ToolChamsHL")
                                if hl then hl:Destroy() end
                            end
                        end
                    end
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local hl = tool:FindFirstChild("_ToolChamsHL")
                            if hl then hl:Destroy() end
                        end
                    end
                end
            end
        end
    end
end)

local hitChamsT = EffectsTab:addToggle({ name = "Hit Chams", flag = "HitChamsEnabled", default = false, callback = function(v) HitEffects.HitChams.Enabled = v end })
hitChamsT:addColorPicker({ flag = "HitChamsColor", default = Color3.fromRGB(255, 255, 255), callback = function(v) HitEffects.HitChams.Color = v end })
EffectsTab:addSlider({ name = "Chams Lifetime", flag = "HitChamsLifetime", min = 1, max = 10, default = 3, callback = function(v) HitEffects.HitChams.Lifetime = v end })
EffectsTab:addSlider({ name = "Chams Transparency", flag = "HitChamsTransparency", min = 0, max = 100, default = 70, Suffix = "%", callback = function(v) HitEffects.HitChams.Transparency = v / 100 end })
EffectsTab:addDropdown({ name = "Chams Material", flag = "HitChamsMaterial", items = {"Neon", "SmoothPlastic", "ForceField", "Glass", "Ice", "Metal"}, default = "Neon", callback = function(v) HitEffects.HitChams.Material = v end })

local hitSkelT = EffectsTab:addToggle({ name = "Hit Skeleton", flag = "HitSkeletonEnabled", default = false, callback = function(v) HitEffects.HitSkeleton.Enabled = v end })
hitSkelT:addColorPicker({ flag = "HitSkeletonColor", default = Color3.fromRGB(255, 255, 255), callback = function(v) HitEffects.HitSkeleton.Color = v end })
EffectsTab:addSlider({ name = "Skeleton Lifetime", flag = "HitSkeletonLifetime", min = 1, max = 10, default = 3, callback = function(v) HitEffects.HitSkeleton.Lifetime = v end })
EffectsTab:addSlider({ name = "Skeleton Transparency", flag = "HitSkeletonTransparency", min = 0, max = 100, default = 50, Suffix = "%", callback = function(v) HitEffects.HitSkeleton.Transparency = v / 100 end })

local hitEffT = EffectsTab:addToggle({ name = "Hit Effect", flag = "HitEffectEnabled", default = false, callback = function(v) HitEffects.HitEffect.Enabled = v end })
EffectsTab:addDropdown({ name = "Effect Type", flag = "HitEffectType", items = {"Coom", "Atomic Slash", "Cosmic Explosion", "Thunder", "Slash", "Aura", "Electric"}, default = "Coom", callback = function(v) HitEffects.HitEffect.Type = v end })
hitEffT:addColorPicker({ flag = "HitEffectColor", default = Color3.fromRGB(255, 255, 255), callback = function(v) HitEffects.HitEffect.Color = v end })

EffectsTab:addToggle({ name = "Hit Notifications", flag = "HitNotificationsEnabled", default = false, callback = function(v) HitEffects.HitNotifications = v end })
EffectsTab:addSlider({ name = "Notification Time", flag = "HitNotificationsTime", min = 1, max = 10, default = 3, callback = function(v) HitEffects.HitNotificationsTime = v end })

EffectsTab:addToggle({ name = "Hit Sounds", flag = "HitSoundsEnabled", default = false, callback = function(v) HitEffects.HitSounds = v end })
EffectsTab:addDropdown({ name = "Hit Sound", flag = "HitSoundSelect", items = {"Bubble","Lazer","Pick","Pop","Rust","Sans","Fart","Big","Vine","UwU","Bruh","Skeet","Neverlose","Fatality","Bonk","Minecraft","Gamesense","RIFK7","Bamboo","Crowbar","Weeb","Beep","Bambi","Stone","Old Fatality","Click","Ding","Snow","Laser","Mario","Steve","Call of Duty","Bat","TF2 Critical","Saber","Baimware","Osu","TF2","Slime","Among Us","One"}, default = "Neverlose", callback = function(v) HitEffects.HitSoundID = _hitSounds[v] or "rbxassetid://6534948092" end })
EffectsTab:addSlider({ name = "Hit Sound Volume", flag = "HitSoundVolume", min = 1, max = 10, default = 5, callback = function(v) HitEffects.HitSoundVolume = v end })

end

do
local MiscPage = Window:Page({ name = "Misc", Icon = "rbxassetid://9525535512" })
local MiscL = MiscPage:Section({ name = "Misc", Side = 1 })
local MiscMultiR = MiscPage:MultiSection({ Side = 2 })
local MiscR = MiscMultiR:Add("Misc")
local AvatarSection = MiscMultiR:Add("Avatar")

local MoveTab2 = MiscL
local AnimTab = MiscL
local HitboxTab = MiscR
local SkinsTab2 = MiscR

HitboxTab:addToggle({ name = "Trigger Bot", flag = "TriggerBotEnabled", default = false }):addKeyBind({ flag = "TriggerBotBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
HitboxTab:addSlider({ name = "Trigger Delay", flag = "TriggerBotDelay", min = 0, max = 1000, default = 0, Suffix = "ms" })
HitboxTab:addToggle({ name = "Require Target", flag = "TriggerBotRequireTarget", default = true })

MoveTab2:addToggle({ name = "Speed Boost", flag = "SpeedEnabled", default = false }):addKeyBind({ flag = "SpeedBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:addSlider({ name = "Walk Speed", flag = "WalkSpd", min = 16, max = 200, default = 16 })
MoveTab2:addToggle({ name = "Switch Speed", flag = "SwitchSpeedEnabled", default = false, callback = function(v)
    if Flags["_DefaultSpeed"] then Flags["_DefaultSpeed"]:SetVisibility(v) end
    if Flags["_JumpSpeed"] then Flags["_JumpSpeed"]:SetVisibility(v) end
    if Flags["_FallSpeed"] then Flags["_FallSpeed"]:SetVisibility(v) end
end })
Flags["_DefaultSpeed"] = MoveTab2:addSlider({ name = "Ground Speed", flag = "DefaultSpeed", min = 16, max = 200, default = 16 })
Flags["_JumpSpeed"] = MoveTab2:addSlider({ name = "Up Speed", flag = "JumpSpeed", min = 16, max = 200, default = 16 })
Flags["_FallSpeed"] = MoveTab2:addSlider({ name = "Down Speed", flag = "FallSpeed", min = 16, max = 200, default = 16 })
Flags["_DefaultSpeed"]:SetVisibility(false)
Flags["_JumpSpeed"]:SetVisibility(false)
Flags["_FallSpeed"]:SetVisibility(false)
MoveTab2:addDropdown({ name = "Speed Method", flag = "SpeedMethod", items = {"Default","Velocity"}, default = "Default" })
MoveTab2:addToggle({ name = "Jump Boost", flag = "JumpBoost", default = false }):addKeyBind({ flag = "JumpBoostBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:addSlider({ name = "Jump Power", flag = "JumpPwr", min = 50, max = 2000, default = 50 })
MoveTab2:addDropdown({ name = "Jump Method", flag = "JumpMethod", items = {"Default","Velocity","CFrame"}, default = "Default" })
MoveTab2:addToggle({ name = "Noclip", flag = "NoclipEnabled", default = false }):addKeyBind({ flag = "NoclipBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:addToggle({ name = "Fly", flag = "FlyEnabled", default = false }):addKeyBind({ flag = "FlyBind", default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:addSlider({ name = "Fly Speed", flag = "FlySp", min = 10, max = 300, default = 50 })
MoveTab2:addDropdown({ name = "Fly Method", flag = "FlyMethod", items = {"Default","Velocity","CFrame"}, default = "Default" })
MoveTab2:addToggle({ name = "Anti AFK", flag = "AntiAFK", default = false })
AvatarSection:addToggle({ name = "Headless", flag = "HeadlessEnabled", default = false })
AvatarSection:addToggle({ name = "Korblox (Right Leg)", flag = "KorbloxRight", default = false })
AvatarSection:addToggle({ name = "Korblox (Left Leg)", flag = "KorbloxLeft", default = false })
local headlessActive = false
local _headlessRestore = {}
local function _hlSet(inst, prop, value)
    if not _headlessRestore[inst] then _headlessRestore[inst] = {} end
    if _headlessRestore[inst][prop] == nil then
        _headlessRestore[inst][prop] = inst[prop]
    end
    pcall(function() inst[prop] = value end)
end
local _HEADLESS_ATTACHMENTS = {
    HatAttachment = true, HairAttachment = true,
    FaceFrontAttachment = true, FaceCenterAttachment = true,
    NeckAttachment = true,
}
local function applyHeadless(enabled)
    local char = lp.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if enabled then
        _hlSet(head, "Transparency", 1)
        pcall(function() head.CanCollide = false end)
        for _, v in ipairs(head:GetChildren()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                _hlSet(v, "Transparency", 1)
            end
        end
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    local att = handle:FindFirstChildOfClass("Attachment")
                    if att and _HEADLESS_ATTACHMENTS[att.Name] then
                        _hlSet(handle, "Transparency", 1)
                        for _, d in ipairs(handle:GetChildren()) do
                            if d:IsA("Decal") or d:IsA("Texture") then
                                _hlSet(d, "Transparency", 1)
                            end
                        end
                    end
                end
            end
        end
        headlessActive = true
    else
        for inst, props in pairs(_headlessRestore) do
            if inst and inst.Parent then
                for prop, val in pairs(props) do
                    pcall(function() inst[prop] = val end)
                end
            end
        end
        _headlessRestore = {}
        pcall(function() head.CanCollide = true end)
        headlessActive = false
    end
end
task.spawn(function()
    local lastState = false
    while _scriptRunning and task.wait(0.25) do
        local state = Flags["HeadlessEnabled"] or false
        if state ~= lastState then
            lastState = state
            pcall(applyHeadless, state)
        end
    end
end)
local KORBLOX_DATA = {
    Right = {
        R6 = { part = "Right Leg", meshId = "rbxassetid://902843353", textureId = "rbxassetid://902843398" },
        R15 = {
            { part = "RightFoot", meshId = "rbxassetid://902942089" },
            { part = "RightLowerLeg", meshId = "rbxassetid://902942093" },
            { part = "RightUpperLeg", meshId = "rbxassetid://902942096", textureId = "rbxassetid://902843398" },
        }
    },
    Left = {
        R6 = { part = "Left Leg", meshId = "rbxassetid://902843346", textureId = "rbxassetid://902842271" },
        R15 = {
            { part = "LeftFoot", meshId = "rbxassetid://902942077" },
            { part = "LeftLowerLeg", meshId = "rbxassetid://902942101", textureId = "rbxassetid://902842271" },
            { part = "LeftUpperLeg", meshId = "rbxassetid://902942082", textureId = "rbxassetid://902842271" },
        }
    },
}

local function applyKorblox(side, enabled)
    local char = lp.Character
    if not char then return end
    local data = KORBLOX_DATA[side]
    if not data then return end
    local function applyToPart(partName, meshId, textureId)
        local part = char:FindFirstChild(partName)
        if not part then return end
        if enabled then
            part.Transparency = 1
            local m = part:FindFirstChild("_KorbloxMesh") or Instance.new("SpecialMesh")
            m.name = "_KorbloxMesh"
            m.MeshId = meshId
            if textureId then m.TextureId = textureId end
            m.Parent = part
        else
            part.Transparency = 0
            local m = part:FindFirstChild("_KorbloxMesh")
            if m then m:Destroy() end
        end
    end
    applyToPart(data.R6.part, data.R6.meshId, data.R6.textureId)
    for _, entry in ipairs(data.R15) do
        applyToPart(entry.part, entry.meshId, entry.textureId)
    end
end
task.spawn(function()
    local lastRight, lastLeft = false, false
    while _scriptRunning and task.wait(1) do
        local r = Flags["KorbloxRight"] or false
        local l = Flags["KorbloxLeft"] or false
        if r ~= lastRight then
            lastRight = r
            pcall(applyKorblox, "Right", r)
        end
        if l ~= lastLeft then
            lastLeft = l
            pcall(applyKorblox, "Left", l)
        end
    end
end)
local _avatarCharConn = lp.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    _headlessRestore = {}
    headlessActive = false
    if Flags["HeadlessEnabled"] then pcall(applyHeadless, true) end
    if Flags["KorbloxRight"] then pcall(applyKorblox, "Right", true) end
    if Flags["KorbloxLeft"] then pcall(applyKorblox, "Left", true) end
end)
_trackConn(_avatarCharConn)
local AnimationIDs = {
    Zombie = { Walk = "616163682", Run = "616163682", Idle = "616158929", Jump = "616161997", Fall = "616157476", Swim = "616165109" },
    Mage = { Walk = "707861613", Run = "707861613", Idle = "707742142", Jump = "707853694", Fall = "707829716", Swim = "707876750" },
    Ninja = { Walk = "656118852", Run = "656118852", Idle = "656117400", Jump = "656117878", Fall = "656115606", Swim = "656119721" },
}
local animConnection = nil
local function setupAnimChanger()
    if animConnection then animConnection:Disconnect(); animConnection = nil end
    local function applyAnims(char)
        if not Flags["AnimEnabled"] then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function setAnim(slotName, flagName)
            local style = Flags[flagName] or "Default"
            if style == "Default" then return end
            local ids = AnimationIDs[style]
            if not ids or not ids[slotName] then return end
            local animId = "rbxassetid://" .. ids[slotName]
            local slot = animate:FindFirstChild(slotName:lower()) or animate:FindFirstChild(slotName)
            if slot then
                for _, child in ipairs(slot:GetChildren()) do
                    if child:IsA("Animation") then
                        child.AnimationId = animId
                    end
                end
            end
        end
        setAnim("Walk", "AnimWalk")
        setAnim("Run", "AnimRun")
        setAnim("Idle", "AnimIdle")
        setAnim("Jump", "AnimJump")
        setAnim("Fall", "AnimFall")
        setAnim("Swim", "AnimSwim")
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        animate.Disabled = true
        task.wait(0.1)
        animate.Disabled = false
    end
    if lp.Character then pcall(applyAnims, lp.Character) end
    animConnection = lp.CharacterAdded:Connect(function(char)
        task.wait(1)
        pcall(applyAnims, char)
    end)
end
local animStyles = {"Default", "Zombie", "Mage", "Ninja"}
AnimTab:addToggle({ name = "Animation Changer", flag = "AnimEnabled", default = false, callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Walk", flag = "AnimWalk", items = animStyles, default = "Default", callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Run", flag = "AnimRun", items = animStyles, default = "Default", callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Idle", flag = "AnimIdle", items = animStyles, default = "Default", callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Jump", flag = "AnimJump", items = animStyles, default = "Default", callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Fall", flag = "AnimFall", items = animStyles, default = "Default", callback = setupAnimChanger })
AnimTab:addDropdown({ name = "Swim", flag = "AnimSwim", items = animStyles, default = "Default", callback = setupAnimChanger })
local flyBodyVel, flyBodyGyro = nil, nil
local function destroyFly()
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end
_trackConn(RunService.Stepped:Connect(LPH_NO_VIRTUALIZE(function()
    if not Flags["NoclipEnabled"] then return end
    local char = lp.Character; if not char then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)))
_trackConn(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
    if not lp.Character then return end
    local h = lp.Character:FindFirstChildOfClass("Humanoid"); if not h then return end
    local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
    if _bindActive("SpeedBind") then
        local spd = Flags["WalkSpd"] or 16
        if Flags["SwitchSpeedEnabled"] then
            local state = h:GetState()
            local vel = hrp and hrp.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local isJumping = (state == Enum.HumanoidStateType.Jumping) or (vel.Y > 1)
            local isFalling = (state == Enum.HumanoidStateType.Freefall) or (vel.Y < -1)
            if isJumping then
                spd = Flags["JumpSpeed"] or 16
            elseif isFalling then
                spd = Flags["FallSpeed"] or 16
            else
                spd = Flags["DefaultSpeed"] or 16
            end
        end
        local method = Flags["SpeedMethod"] or "Default"
        if method == "Velocity" then
            if hrp then
                local moveDir = h.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * spd, hrp.AssemblyLinearVelocity.Y, moveDir.Z * spd)
                end
            end
        else
            h.WalkSpeed = spd
        end
    end
    if Flags["JumpBoost"] then
        local pwr = Flags["JumpPwr"] or 50
        local method = Flags["JumpMethod"] or "Default"
        if method == "Velocity" then
            if hrp and h:GetState() == Enum.HumanoidStateType.Jumping then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, pwr, hrp.AssemblyLinearVelocity.Z)
            end
        elseif method == "CFrame" then
            if hrp and h:GetState() == Enum.HumanoidStateType.Jumping then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, pwr * 0.02, 0)
            end
        else
            h.JumpPower = pwr
        end
    end
    if _bindActive("FlyBind") then
        if not hrp then return end
        local spd = Flags["FlySp"] or 50
        local method = Flags["FlyMethod"] or "Default"
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if method == "Velocity" then
            if not flyBodyVel or not flyBodyVel.Parent then
                flyBodyVel = Instance.new("BodyVelocity")
                flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
                flyBodyVel.Parent = hrp
            end
            if dir.Magnitude > 0 then
                flyBodyVel.Velocity = dir.Unit * spd
            else
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            h.PlatformStand = true
        elseif method == "CFrame" then
            if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
            if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
            if dir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + dir.Unit * spd * 0.016
            end
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            h.PlatformStand = true
        else
            if not flyBodyVel or not flyBodyVel.Parent then
                flyBodyVel = Instance.new("BodyVelocity")
                flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
                flyBodyVel.Parent = hrp
            end
            if not flyBodyGyro or not flyBodyGyro.Parent then
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyGyro.P = 9e4
                flyBodyGyro.Parent = hrp
            end
            if dir.Magnitude > 0 then
                flyBodyVel.Velocity = dir.Unit * spd
            else
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            flyBodyGyro.CFrame = camera.CFrame
            h.PlatformStand = true
        end
    else
        if flyBodyVel or flyBodyGyro then
            destroyFly()
            if h then h.PlatformStand = false end
        end
    end
end)))
pcall(function() local VU=game:GetService("VirtualUser"); lp.Idled:Connect(function() if Flags["AntiAFK"] then VU:CaptureController(); VU:ClickButton2(Vector2.new()) end end) end)
local _flyCharConn = nil
_flyCharConn = lp.CharacterAdded:Connect(function()
    destroyFly()
end)
if isHoodCustoms then
    SkinsTab2:addToggle({ name = "Skin Changer", flag = "HCSkinEnabled", default = false })
    hcGunSkins = {"Default","Adurite","Amethyst","Arctic","Arsenic","Ascension","Binary","Black Cat","Black Ice","Blacksteel Dragon","Candy Cane","Crimson Fangs","Cupid","Deathbringer","Ember","Floral","Green Tint","Hallows","Heartbringer","Hell Dragon","Hell Hound","Hello Kitty","Hexagram","Kirumi","Kitty","Lightbringer","Lovestruck","None","Phoenix","Poseidon","Radiation","Shiryus Breath","Snow Dragon","Strawberry Shortcake","Void","Void Dragon","Volcanic Ashes","Voxel"}
    hcKnifeSkins = {"Default","Beta","Bitcoin","Fishbone","Nightblade","None"}
    hcBeamSkins = {"Default","Beta","Blue","Green","Hallows","Kirumi","Kitty","Lightning","None","Orange","Rainbow","Red"}
    hcWeapons = {"DoubleBarrel", "Revolver", "TacticalShotgun", "SMG", "Shotgun"}
    for _, wep in ipairs(hcWeapons) do
        SkinsTab2:addDropdown({ name = wep, flag = "HC_" .. wep, items = hcGunSkins, default = "Default" })
    end
    SkinsTab2:addDropdown({ name = "Knife", flag = "HC_Knife", items = hcKnifeSkins, default = "Default" })
    SkinsTab2:addToggle({ name = "Beam Changer", flag = "HCBeamEnabled", default = false })
    for _, wep in ipairs(hcWeapons) do
        SkinsTab2:addDropdown({ name = wep .. " Beam", flag = "HCBeam_" .. wep, items = hcBeamSkins, default = "Default" })
    end
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    hcProcessed = setmetatable({}, { __mode = "k" })
    hcGetSkinModel = function(weaponName, skinName)
        if not skinName or skinname = = "" or skinname = = "Default" or skinname = = "None" then return nil end
        local wraps = ReplicatedStorage:FindFirstChild("Wraps")
        if not wraps then return nil end
        local folder = wraps:FindFirstChild("[" .. weaponName .. "]")
        if not folder then return nil end
        return folder:FindFirstChild(skinName)
    end
    hcEnsurePrimaryPart = function(m)
        if not m then return nil end
        if m:IsA("Model") then
            if not m.PrimaryPart or not m.PrimaryPart:IsA("BasePart") then
                local best = nil
                local bestSize = 0
                for _, p in ipairs(m:GetDescendants()) do
                    if p:IsA("BasePart") and p.Transparency < 0.9 then
                        local vol = p.Size.X * p.Size.Y * p.Size.Z
                        if vol > bestSize then
                            bestSize = vol
                            best = p
                        end
                    end
                end
                if not best then best = m:FindFirstChildWhichIsA("BasePart") end
                m.PrimaryPart = best
            end
            return m.PrimaryPart
        elseif m:IsA("BasePart") then
            return m
        end
        return nil
    end
    hcPrepParts = function(model)
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.Anchored = false
                p.Massless = true
            end
        end
    end
    hcScaleModelToFit = function(model, targetSize)
        local minVec, maxVec
        local function processPart(p)
            if not p or not p:IsA("BasePart") then return end
            local half = p.Size * 0.5
            local corners = {
                p.CFrame * Vector3.new(half.X, half.Y, half.Z),
                p.CFrame * Vector3.new(half.X, half.Y, -half.Z),
                p.CFrame * Vector3.new(half.X, -half.Y, half.Z),
                p.CFrame * Vector3.new(half.X, -half.Y, -half.Z),
                p.CFrame * Vector3.new(-half.X, half.Y, half.Z),
                p.CFrame * Vector3.new(-half.X, half.Y, -half.Z),
                p.CFrame * Vector3.new(-half.X, -half.Y, half.Z),
                p.CFrame * Vector3.new(-half.X, -half.Y, -half.Z)
            }
            for _, corner in ipairs(corners) do
                if not minVec then
                    minVec = corner; maxVec = corner
                else
                    minVec = Vector3.new(math.min(minVec.X, corner.X), math.min(minVec.Y, corner.Y), math.min(minVec.Z, corner.Z))
                    maxVec = Vector3.new(math.max(maxVec.X, corner.X), math.max(maxVec.Y, corner.Y), math.max(maxVec.Z, corner.Z))
                end
            end
        end
        processPart(model)
        for _, p in ipairs(model:GetDescendants()) do
            processPart(p)
        end
        if not minVec or not maxVec then return end
        local modelSize = maxVec - minVec
        local scale = math.min(targetSize.X / math.max(modelSize.X, 0.001), targetSize.Y / math.max(modelSize.Y, 0.001), targetSize.Z / math.max(modelSize.Z, 0.001))
        if scale >= 1 then return end
        local center = (minVec + maxVec) * 0.5
        local primaryPart = model:IsA("Model") and model.PrimaryPart or nil
        if model:IsA("BasePart") then primaryPart = model end
        local anchorCF = primaryPart and primaryPart.CFrame or CFrame.new(center)
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                local relPos = anchorCF:PointToObjectSpace(p.CFrame.Position)
                p.Size = p.Size * scale
                p.CFrame = anchorCF * CFrame.new(relPos * scale)
            end
        end
        if model:IsA("BasePart") then
            local relPos = anchorCF:PointToObjectSpace(model.CFrame.Position)
            model.Size = model.Size * scale
            model.CFrame = anchorCF * CFrame.new(relPos * scale)
        end
    end
    hcApplyModelOnHolder = function(holder, skinModel)
        if not holder or not skinModel then return end
        local handle = holder:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then return end
        local default = holder:FindFirstChild("Default")
        local existing = holder:FindFirstChild("_OverridePart")
        if existing then pcall(function() existing:Destroy() end) end
        cacheOriginalSkin(holder)
        local clone = skinModel:Clone()
        clone.name = "_OverridePart"
        local pp = hcEnsurePrimaryPart(clone)
        if not pp or not pp:IsA("BasePart") then
            if clone:IsA("BasePart") then
                pp = clone
            else
                for _, desc in ipairs(clone:GetDescendants()) do
                    if desc:IsA("BasePart") then pp = desc; break end
                end
                if clone:IsA("Model") then clone.PrimaryPart = pp end
                if not pp then clone:Destroy(); return end
            end
        end
        hcPrepParts(clone)
        local targetCF = handle.CFrame
        if default and default:IsA("BasePart") then
            targetCF = default.CFrame
            local offset = default.CFrame:PointToObjectSpace(handle.CFrame.Position)
            if math.abs(offset.Y) > 0.01 or math.abs(offset.Z) > 0.01 or math.abs(offset.X) > 0.01 then
                targetCF = default.CFrame * CFrame.new(offset)
            end
            hcScaleModelToFit(clone, default.Size)
        end
        if holder.Name:lower():find("tactical") or holder.Name:lower():find("tac") then
            targetCF = targetCF * CFrame.Angles(0, math.rad(180), 0)
        end
        if clone:IsA("Model") then
            clone:SetPrimaryPartCFrame(targetCF)
        else
            pp.CFrame = targetCF
        end
        clone.Parent = holder
        local w = Instance.new("WeldConstraint")
        w.Part0 = handle
        w.Part1 = pp
        w.Parent = handle
        handle.Transparency = 1
        if default and default:IsA("BasePart") then
            default.Transparency = 1
        end
    end
    hcApplyKnifeModel = function(holder, skinModel)
        if not holder or not skinModel then return end
        local handle = holder:FindFirstChild("Handle")
        if not handle or not handle:IsA("BasePart") then return end
        local default = holder:FindFirstChild("Default")
        local existing = holder:FindFirstChild("_OverridePart")
        if existing then pcall(function() existing:Destroy() end) end
        cacheOriginalSkin(holder)
        local clone = skinModel:Clone()
        clone.name = "_OverridePart"
        local pp = hcEnsurePrimaryPart(clone)
        if not pp or not pp:IsA("BasePart") then
            if clone:IsA("BasePart") then
                pp = clone
            else
                for _, desc in ipairs(clone:GetDescendants()) do
                    if desc:IsA("BasePart") then pp = desc; break end
                end
                if clone:IsA("Model") and pp then clone.PrimaryPart = pp end
                if not pp then clone:Destroy(); return end
            end
        end
        hcPrepParts(clone)
        local targetCF = handle.CFrame
        if default and default:IsA("BasePart") then
            targetCF = default.CFrame
            hcScaleModelToFit(clone, default.Size)
        end
        if clone:IsA("Model") then
            clone:SetPrimaryPartCFrame(targetCF)
        else
            clone.CFrame = targetCF
        end
        clone.Parent = holder
        local w = Instance.new("WeldConstraint")
        w.Part0 = handle
        w.Part1 = pp
        w.Parent = handle
        handle.Transparency = 1
        if default and default:IsA("BasePart") then
            default.Transparency = 1
        end
    end
    hcRainbowBeamitems = {}
    hcBeamHue = 0
    updateHcBeam = LPH_NO_VIRTUALIZE(function()
        if not Flags["HCBeamEnabled"] or not next(hcRainbowBeamItems) then return end
        hcBeamHue = (hcBeamHue + 0.01) % 1
        local color = Color3.fromHSV(hcBeamHue, 1, 1)
        local seq = ColorSequence.new(color)
        for item in pairs(hcRainbowBeamItems) do
            if item.Parent then
                if item:IsA("Beam") then item.Color = seq end
            else
                hcRainbowBeamItems[item] = nil
            end
        end
    end)
    task.spawn(function()
        while _scriptRunning do
            if not Flags["HCBeamEnabled"] or not next(hcRainbowBeamItems) then
                task.wait(1)
            else
                updateHcBeam()
                task.wait(0.05)
            end
        end
    end)
    hcApplySkin = function(tool)
        task.defer(function()
            if not Flags["HCSkinEnabled"] then return end
            if not tool or not tool:IsA("Tool") then return end
            local weaponname = tool.Name:match("^%[(.+)%]$")
            if not weaponName then return end
            local skinname = Flags["HC_" .. weaponName]
            if skinName and skinName ~= "" and skinName ~= "Default" then
                if skinname = = "None" then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then handle.Transparency = 1 end
                    return
                end
                local skinModel = hcGetSkinModel(weaponName, skinName)
                if skinModel then
                    hcApplyModelOnHolder(tool, skinModel)
                end
            end
        end)
    end
    hcApplyKnife = function(tool)
        task.defer(function()
            if not Flags["HCSkinEnabled"] then return end
            if not tool or not tool:IsA("Tool") then return end
            local isKnife = tool.name = = "[Knife]" or tool.Name:lower():find("knife")
            if not isKnife then return end
            local knifeSkin = Flags["HC_Knife"]
            if knifeSkin and knifeSkin ~= "" and knifeSkin ~= "Default" and knifeSkin ~= "None" then
                local skinModel = nil
                local knives = game:GetService("ReplicatedStorage"):FindFirstChild("Knives")
                if knives then
                    skinModel = knives:FindFirstChild(knifeSkin)
                end
                if not skinModel then
                    local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
                    if assets then
                        local skinAssets = assets:FindFirstChild("SkinAssets")
                        if skinAssets then
                            local knifeFolder = skinAssets:FindFirstChild("Knives") or skinAssets:FindFirstChild("Knife")
                            if knifeFolder then
                                skinModel = knifeFolder:FindFirstChild(knifeSkin)
                            end
                        end
                    end
                end
                if skinModel then hcApplyKnifeModel(tool, skinModel) end
            end
        end)
    end
    hcApplyBeams = function(tool)
    end
    hcBeamCodes = {
        DoubleBarrel = "109d1326878cc594bc1bb42d126250810999782f",
        Revolver = "539db315b53f77390c0aa74773158e25bedcdd6e",
        Shotgun = "b415a7273aa86cbc2adc445fde5435eb5afababa",
        SMG = "005af87725b42ac4ca8103d11af6bf0c7d55f7b3",
        TacticalShotgun = "109d1326878cc594bc1bb42d126250810999782f",
    }
    hcApplyBeamChanger = function()
        if not Flags["HCBeamEnabled"] then return end
        local dataFolder = lp:FindFirstChild("DataFolder")
        if not dataFolder then return end
        local subscriptionFolder = dataFolder:FindFirstChild("Subscription")
        if subscriptionFolder then
            local hasSub = subscriptionFolder:FindFirstChild("HasSubscription")
            if hasSub and hasSub:IsA("BoolValue") then hasSub.Value = true end
            local subData = subscriptionFolder:FindFirstChild("SubscriptionData")
            if subData and subData:IsA("NumberValue") then subData.Value = 16 end
            local subStreak = subscriptionFolder:FindFirstChild("SubscriptionStreak")
            if subStreak and subStreak:IsA("NumberValue") then subStreak.Value = 53 end
        end
        local inventoryData = dataFolder:FindFirstChild("InventoryData")
        if not inventoryData then return end
        local bulletBeams = inventoryData:FindFirstChild("BulletBeams")
        local equippedBulletBeams = dataFolder:FindFirstChild("EquippedBulletBeams")
        if bulletBeams and bulletBeams:IsA("StringValue") then
            local bulletBeamData = {}
            for _, wep in ipairs({"DoubleBarrel","Revolver","TacticalShotgun","SMG","Shotgun"}) do
                local beamSkin = Flags["HCBeam_" .. wep]
                if beamSkin and beamSkin ~= "" and beamSkin ~= "Default" and beamSkin ~= "None" then
                    local code = hcBeamCodes[wep]
                    if code then
                        bulletBeamData[code] = { name = beamSkin }
                    end
                end
            end
            if next(bulletBeamData) then
                bulletBeams.Value = game:GetService("HttpService"):JSONEncode(bulletBeamData)
            end
        end
        if equippedBulletBeams and equippedBulletBeams:IsA("StringValue") then
            local equippedData = {}
            for _, wep in ipairs({"DoubleBarrel","Revolver","TacticalShotgun","SMG","Shotgun"}) do
                local beamSkin = Flags["HCBeam_" .. wep]
                if beamSkin and beamSkin ~= "" and beamSkin ~= "Default" and beamSkin ~= "None" then
                    local code = hcBeamCodes[wep]
                    if code then
                        equippedData["[" .. wep .. "]"] = code
                    end
                end
            end
            if next(equippedData) then
                equippedBulletBeams.Value = game:GetService("HttpService"):JSONEncode(equippedData)
            end
        end
    end
    task.spawn(function()
        while _scriptRunning and task.wait(1) do
            if Flags["HCBeamEnabled"] then
                pcall(hcApplyBeamChanger)
            end
        end
    end)
    local _hcSkinMaintConn
    _hcSkinMaintConn = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not Flags["HCSkinEnabled"] then return end
        local char = lp.Character
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if (obj:IsA("Tool") or obj:IsA("Folder") or obj:IsA("Model")) and obj:FindFirstChild("_OverridePart") then
                local h = obj:FindFirstChild("Handle")
                if h and h:IsA("BasePart") and h.Transparency < 1 then
                    h.Transparency = 1
                end
                local d = obj:FindFirstChild("Default")
                if d and d:IsA("BasePart") and d.Transparency < 1 then
                    d.Transparency = 1
                end
            end
        end
    end))
    _trackConn(_hcSkinMaintConn)
    hcOnToolAdded = function(tool)
        if hcProcessed[tool] then return end
        hcProcessed[tool] = true
        hcApplySkin(tool)
        hcApplyKnife(tool)
        hcApplyBeams(tool)
    end
    HandleMap = { DB_HANDLE = "DoubleBarrel", REV_HANDLE = "Revolver" }
    hcApplyHandles = function(character)
        for h, weaponName in pairs(HandleMap) do
            task.defer(function()
                if not Flags["HCSkinEnabled"] then return end
                local skinname = Flags["HC_" .. weaponName]
                local handleFolder = character:FindFirstChild(h) or character:WaitForChild(h, 5)
                if handleFolder and skinName and skinName ~= "" and skinName ~= "Default" and skinName ~= "None" then
                    local skinModel = hcGetSkinModel(weaponName, skinName)
                    if skinModel then hcApplyModelOnHolder(handleFolder, skinModel) end
                end
            end)
        end
    end
    hcConnectCharacter = function(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                hcOnToolAdded(child)
            elseif HandleMap[child.Name] then
                hcApplyHandles(char)
            end
        end)
        hcApplyHandles(char)
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then hcOnToolAdded(t) end
        end
    end
    hcBackpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack", 10)
    if hcBackpack then hcBackpack.ChildAdded:Connect(hcOnToolAdded) end
    if lp.Character then hcConnectCharacter(lp.Character) end
    lp.CharacterAdded:Connect(function(char)
        hcProcessed = setmetatable({}, { __mode = "k" })
        task.wait(0.5)
        hcConnectCharacter(char)
        local bp = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack", 10)
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                hcOnToolAdded(t)
            end
        end
    end)
    SkinsTab2:Button({ name = "Reapply Skins", callback = function()
        local char = lp.Character
        if char then
            hcProcessed = setmetatable({}, { __mode = "k" })
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then
                    hcProcessed[t] = true
                    pcall(hcApplySkin, t)
                    pcall(hcApplyKnife, t)
                end
            end
            pcall(hcApplyHandles, char)
            local bp = lp:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") then
                        hcProcessed[t] = true
                        pcall(hcApplySkin, t)
                        pcall(hcApplyKnife, t)
                    end
                end
            end
        end
    end })
    SkinsTab2:Button({ name = "Strip All Skins", callback = function()
        for _, wep in ipairs(hcWeapons) do
            pcall(function()
                if Library.SetFlags and Library.SetFlags["HC_" .. wep] then
                    Library.SetFlags["HC_" .. wep]("Default")
                end
                Flags["HC_" .. wep] = "Default"
            end)
        end
        pcall(function()
            if Library.SetFlags and Library.SetFlags["HC_Knife"] then
                Library.SetFlags["HC_Knife"]("Default")
            end
            Flags["HC_Knife"] = "Default"
        end)
        local char = lp.Character
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then
                    local handle = t:FindFirstChild("Handle")
                    if handle then handle.Transparency = 0 end
                    for _, child in ipairs(t:GetChildren()) do
                        if child:IsA("Model") and child ~= handle then
                            child:Destroy()
                        end
                    end
                end
            end
            for h, _ in pairs(HandleMap) do
                local folder = char:FindFirstChild(h)
                if folder then
                    local handle = folder:FindFirstChild("Handle")
                    if handle then handle.Transparency = 0 end
                    for _, child in ipairs(folder:GetChildren()) do
                        if child:IsA("Model") and child ~= handle then
                            child:Destroy()
                        end
                    end
                end
            end
        end
        hcProcessed = setmetatable({}, { __mode = "k" })
    end })
else
    if isDaTrack then
        SkinsTab2:addToggle({ name = "Skin Swapper", flag = "SkinSwap", default = false })
        SkinsTab2:addDropdown({ name = "Revolver", flag = "RevSkin", items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Devilish","Blue Wave","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, default = "Default" })
        SkinsTab2:addDropdown({ name = "Double-Barrel", flag = "DBSkin", items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, default = "Default" })
        SkinsTab2:addDropdown({ name = "Tactical Shotgun", flag = "TacSkin", items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Devilish","Blue Wave","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, default = "Default" })
        SkinsTab2:addToggle({ name = "Animated", flag = "AnimatedSkins", default = true })
    end
end
ghostPulseTime = 0
rainbowHue = 0
_scrollTexTime = 0
_scrollTexCachedTool = nil
_scrollTexCachedSkin = nil
_scrollTexTextures = nil
local _beamCache = {}
local _beamCacheKey = nil
local _beamStyleApplied = nil
local _beamFrameCounter = 0
local _beamOrigWidths = setmetatable({}, { __mode = "k" })
local _animSkinCache = {}
local scrollMeshIds = {
    ["[Revolver]"] = "rbxassetid://12789422527",
    ["[Double-Barrel SG]"] = "rbxassetid://12790058946",
    ["[TacticalShotgun]"] = "rbxassetid://12790319869",
}
if not isHoodCustoms then
cosmicIndex = 0
cosmicTimer = 0
_skinFrameCounter = 0
_skinSwapWasOn = false
_lastAppliedSkins = {}
_skinWeps = {{name = "[Revolver]",flag = "RevSkin"},{name = "[Double-Barrel SG]",flag = "DBSkin"},{name = "[TacticalShotgun]",flag = "TacSkin"}}
_trackConn(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
    local weps = _skinWeps
    if not Flags["SkinSwap"] then
        if _skinSwapWasOn then
            _skinSwapWasOn = false
            _animSkinCache = {}
            for b, ow in pairs(_beamOrigWidths) do
                if b.Parent then pcall(function() b.Width0 = ow[1]; b.Width1 = ow[2] end) end
            end
            _beamCacheKey = nil
            _beamStyleApplied = nil
            if _scrollTexTextures then
                for i = 1, #_scrollTexTextures do
                    if _scrollTexTextures[i].Parent then _scrollTexTextures[i]:Destroy() end
                end
                _scrollTexTextures = nil
                _scrollTexCachedTool = nil
                _scrollTexCachedSkin = nil
            end
            local char = lp.Character; local bp = lp:FindFirstChild("Backpack")
            for _, w in ipairs(weps) do
                local tool = (bp and bp:FindFirstChild(w.name)) or (char and char:FindFirstChild(w.name))
                if tool then restoreOriginalSkin(tool) end
            end
        end
        _lastAppliedSkins = {}
        return
    end
    _skinSwapWasOn = true
    
    ghostPulseTime = ghostPulseTime + dt * 18
    rainbowHue = (rainbowHue + dt * 0.25) % 1
    cosmicTimer = cosmicTimer + dt * 6
    if cosmicTimer >= 1.5 then cosmicTimer = 0; cosmicIndex = (cosmicIndex + 1) % 3 end
    local pulse = 0.3 + 0.25 * math.sin(ghostPulseTime * 3)
    local rgbColor = Color3.fromHSV(rainbowHue, 1, 1)
    local neonRgbColor = Color3.fromHSV((rainbowHue + 0.33) % 1, 1, 1)

    _beamFrameCounter = _beamFrameCounter + 1
    if _beamFrameCounter % 3 == 0 then
        do
        local char2 = lp.Character
        if char2 then
            local equippedTool = char2:FindFirstChildOfClass("Tool")
            if equippedTool then
                local beamColor = nil
                local isRainbowBeam = false
                local isGhostBeam = false
                local isCosmicBeam = false
                local beamSkinData = nil
                local equippedWepname = nil
                for _,w in ipairs(weps) do
                    if equippedTool.name = = w.name then
                        equippedWepname = w.name
                        local sname = Flags[w.flag] or "Default"
                        local sData = SkinData[sName]
                        if sData and (not sData.RevolverOnly or w.name = = "[Revolver]") then
                            beamColor = sData.Color
                            isRainbowBeam = sData.Rainbow or false
                            isGhostBeam = sData.Pulsate or false
                            isCosmicBeam = sData.CosmicCycle or false
                            beamSkinData = sData
                        end
                        break
                    end
                end
                if beamColor or (beamSkinData and beamSkinData.BeamColorSequence) then
                    if beamSkinData and beamSkinData.BeamColor then
                        beamColor = beamSkinData.BeamColor
                    end
                    local cacheKey = equippedWepName .. ":" .. (Flags["RevSkin"] or "") .. ":" .. (Flags["DBSkin"] or "") .. ":" .. (Flags["TacSkin"] or "")
                    if cacheKey ~= _beamCacheKey then
                        _beamCacheKey = cacheKey
                        _beamStyleApplied = nil
                        _beamCache = {}
                        local sa = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
                        if sa then sa = sa:FindFirstChild("SkinAssets") end
                        if sa then
                            local gb = sa:FindFirstChild("GunBeam")
                            if gb then
                                local sh = gb:FindFirstChild("Shadow")
                                if sh then
                                    local beamChildren = sh:GetChildren()
                                    local strippedname = equippedWepName:gsub("%[",""):gsub("%]","")
                                    for _,c in ipairs(beamChildren) do
                                        if c:IsA("Beam") then
                                            if c.name = = equippedWepName or c.Name:find(strippedName, 1, true) then
                                                table.insert(_beamCache, c)
                                            end
                                        end
                                    end
                                    if #_beamCache == 0 then
                                        for _,c in ipairs(beamChildren) do
                                            if c:IsA("Beam") then table.insert(_beamCache, c) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if _beamFrameCounter % 180 == 0 then _beamStyleApplied = nil end
                    local styleDirty = (_beamStyleApplied ~= cacheKey)
                    local isAnimatedBeam = isRainbowBeam or isGhostBeam or isCosmicBeam
                    if styleDirty or isAnimatedBeam then
                        local vividColor = beamColor
                        if beamColor then
                            local h, s, v = beamColor:ToHSV()
                            vividColor = Color3.fromHSV(h, math.min(s * 1.15, 1), math.max(v, 0.85))
                        end
                        for _,c in ipairs(_beamCache) do
                            if not c.Parent then _beamCacheKey = nil; _beamStyleApplied = nil; continue end
                            if styleDirty then
                                c.FaceCamera = true
                                c.LightEmission = 1
                                c.LightInfluence = 0
                                pcall(function() c.Brightness = 4 end)
                                local ow = _beamOrigWidths[c]
                                if not ow then
                                    ow = { c.Width0, c.Width1 }
                                    _beamOrigWidths[c] = ow
                                end
                                c.Width0 = ow[1] * 1.35
                                c.Width1 = ow[2] * 1.35
                            end
                            if isRainbowBeam then
                                local keypoints = {}
                                for i = 0, 5 do
                                    local timeVal = i / 5
                                    keypoints[i + 1] = ColorSequenceKeypoint.new(timeVal, Color3.fromHSV((rainbowHue - timeVal) % 1, 1, 1))
                                end
                                c.Color = ColorSequence.new(keypoints)
                                if styleDirty then c.Transparency = NumberSequence.new(0) end
                            elseif isGhostBeam then
                                if styleDirty then c.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255)) end
                                c.Transparency = NumberSequence.new(0.2 + 0.15 * math.sin(ghostPulseTime * 3))
                            elseif isCosmicBeam then
                                local cosmicBeams = beamSkinData.CosmicBeams
                                if cosmicBeams and #cosmicBeams > 0 then
                                    local tex = cosmicBeams[(cosmicIndex % #cosmicBeams) + 1]
                                    if c.Texture ~= tex then c.Texture = tex end
                                end
                                if styleDirty then
                                    c.Color = ColorSequence.new(vividColor)
                                    c.Transparency = NumberSequence.new(0)
                                end
                            elseif styleDirty then
                                if beamSkinData and beamSkinData.BeamTextures and equippedWepName then
                                    local beamTex = beamSkinData.BeamTextures[equippedWepName] or ""
                                    if beamTex ~= "" then
                                        c.Texture = beamTex
                                        if beamSkinData.ScrollTex then
                                            pcall(function() c.TextureSpeed = 0.35 end)
                                        end
                                    end
                                end
                                if beamSkinData and beamSkinData.BeamColorSequence then
                                    c.Color = beamSkinData.BeamColorSequence
                                else
                                    c.Color = ColorSequence.new(vividColor)
                                end
                                c.Transparency = NumberSequence.new(0)
                            end
                        end
                        if styleDirty then _beamStyleApplied = cacheKey end
                    end
                end
            end
        end
    end
    end

    _scrollTexTime = _scrollTexTime + dt
    _scrollTexFrame = (_scrollTexFrame or 0) + 1
    local charST = lp.Character
    if charST then
        local equippedTool = charST:FindFirstChildOfClass("Tool")
        if equippedTool then
            local matchedWep = nil
            for _, w in ipairs(weps) do
                if equippedTool.name = = w.name then
                    matchedWep = w
                    break
                end
            end
            if matchedWep then
                local sname = Flags[matchedWep.flag] or "Default"
                local sData = SkinData[sName]
                if sData and sData.ScrollTex then
                    local stv = sData.StudsPerTileV or 3
                    if _scrollTexCachedTool ~= equippedTool or _scrollTexCachedSkin ~= sName or not _scrollTexTextures then
                        if _scrollTexTextures then
                            for i = 1, #_scrollTexTextures do
                                if _scrollTexTextures[i].Parent then _scrollTexTextures[i]:Destroy() end
                            end
                        end
                        _scrollTexCachedTool = equippedTool
                        _scrollTexCachedSkin = sName
                        _scrollTexTextures = {}
                        local stu = sData.StudsPerTileU or 3
                        local texId = sData.Textures and sData.Textures[matchedWep.name] or ""
                        if texId ~= "" then
                            for _, desc in ipairs(equippedTool:GetDescendants()) do
                                if desc:IsA("BasePart") and not desc:FindFirstAncestor("_OverridePart") then
                                    if desc.name = = "Mesh" or desc.name = = "Default" then
                                        for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Back}) do
                                            local tex = Instance.new("Texture")
                                            tex.name = "_ScrollTex"
                                            tex.Texture = texId
                                            tex.StudsPerTileU = stu
                                            tex.StudsPerTileV = stv
                                            tex.Face = face
                                            tex.Parent = desc
                                            _scrollTexTextures[#_scrollTexTextures + 1] = tex
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if Flags["AnimatedSkins"] ~= false and _scrollTexFrame % 2 == 0 then
                        local scrollOffset = _scrollTexTime * 0.5
                        local modOffset = scrollOffset % stv
                        for i = 1, #_scrollTexTextures do
                            local tex = _scrollTexTextures[i]
                            if tex.Parent then
                                tex.OffsetStudsV = modOffset
                            else
                                _scrollTexTextures = nil
                                _scrollTexCachedTool = nil
                                break
                            end
                        end
                    end
                else
                    if _scrollTexTextures then
                        for i = 1, #_scrollTexTextures do
                            if _scrollTexTextures[i].Parent then
                                _scrollTexTextures[i]:Destroy()
                            end
                        end
                        _scrollTexTextures = nil
                        _scrollTexCachedTool = nil
                        _scrollTexCachedSkin = nil
                    end
                end
            end
        end
    end

    _skinFrameCounter = _skinFrameCounter + 1
    if _skinFrameCounter % 4 ~= 0 then return end
    local char = lp.Character; local bp = lp:FindFirstChild("Backpack")
    for _, w in ipairs(weps) do
        local skinname = Flags[w.flag] or "Default"
        local tool = (bp and bp:FindFirstChild(w.name)) or (char and char:FindFirstChild(w.name))
        if not tool then _animSkinCache[w.name] = nil; continue end
        local data = SkinData[skinName]
        local isGhost = (data and data.Pulsate) or false
        local isRainbow = (data and data.Rainbow) or false
        local animated = (isGhost or isRainbow) and skinName ~= "Default" and not (data and data.RevolverOnly and w.name ~= "[Revolver]")
        local cache = _animSkinCache[w.name]
        if not animated then
            if cache then
                _animSkinCache[w.name] = nil
                restoreOriginalSkin(tool)
                _lastAppliedSkins[w.name] = nil
            end
            continue
        end
        if not cache or cache.tool ~= tool or cache.skin ~= skinName then
            restoreOriginalSkin(tool)
            cacheOriginalSkin(tool)
            cache = { tool = tool, skin = skinName, neon = {}, mesh = {}, special = {} }
            local h = tool:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then h.Transparency = 1 end
            local default = tool:FindFirstChild("Default")
            cache.defaultPart = default
            for _, desc in ipairs(tool:GetDescendants()) do
                if desc:FindFirstAncestor("_OverridePart") or desc.name = = "Handle" then continue end
                if desc:IsA("BasePart") and desc.name = = "Neon" then
                    cache.neon[#cache.neon + 1] = desc
                elseif (desc:IsA("MeshPart") or desc:IsA("BasePart")) and desc.name = = "Mesh" then
                    cache.mesh[#cache.mesh + 1] = desc
                elseif desc:IsA("SpecialMesh") then
                    cache.special[#cache.special + 1] = desc
                end
            end
            if default and not default:IsA("MeshPart") then
                cache.defaultMesh = default:FindFirstChild("Mesh") or default:FindFirstChildOfClass("SpecialMesh")
            end
            if not default then
                for _, desc in ipairs(tool:GetDescendants()) do
                    if desc.Name ~= "Handle" and not desc:FindFirstAncestor("_OverridePart") then
                        if desc:IsA("SpecialMesh") or (desc:IsA("MeshPart") and desc.Name ~= "Neon") then
                            cache.fallback = desc
                            break
                        end
                    end
                end
            end
            if isRainbow then
                for _, p in ipairs(cache.neon) do
                    p.Material = Enum.Material.Neon
                    p.Transparency = 0
                end
                for _, p in ipairs(cache.mesh) do
                    p.Material = Enum.Material.Neon
                    p.Transparency = 0
                    if p:IsA("MeshPart") then p.TextureID = "" end
                end
                for _, m in ipairs(cache.special) do
                    m.TextureId = ""
                end
                if default and default:IsA("MeshPart") then
                    default.TextureID = ""
                    default.Material = Enum.Material.Neon
                end
                local dm = cache.defaultMesh
                if dm then
                    if dm:IsA("SpecialMesh") then
                        dm.TextureId = ""
                    elseif dm:IsA("MeshPart") then
                        dm.TextureID = ""
                        dm.Material = Enum.Material.Neon
                    end
                end
                local f = cache.fallback
                if f then
                    if f:IsA("SpecialMesh") then
                        f.TextureId = ""
                    elseif f:IsA("MeshPart") then
                        f.TextureID = ""
                        f.Material = Enum.Material.Neon
                        f.Transparency = 0
                    end
                end
            end
            _animSkinCache[w.name] = cache
        end
        local stale = false
        if isGhost then
            for _, p in ipairs(cache.neon) do
                if p.Parent then p.Transparency = pulse else stale = true end
            end
            for _, p in ipairs(cache.mesh) do
                if p.Parent then p.Transparency = pulse else stale = true end
            end
            local d = cache.defaultPart
            if d and d.Parent then d.Transparency = pulse end
            local f = cache.fallback
            if f and f.Parent and f:IsA("MeshPart") then f.Transparency = pulse end
        else
            local vcol = Vector3.new(rgbColor.R, rgbColor.G, rgbColor.B)
            for _, p in ipairs(cache.neon) do
                if p.Parent then p.Color = neonRgbColor else stale = true end
            end
            for _, p in ipairs(cache.mesh) do
                if p.Parent then p.Color = rgbColor else stale = true end
            end
            for _, m in ipairs(cache.special) do
                if m.Parent then m.VertexColor = vcol else stale = true end
            end
            local d = cache.defaultPart
            if d and d.Parent and d:IsA("MeshPart") then d.Color = rgbColor end
            local dm = cache.defaultMesh
            if dm and dm.Parent then
                if dm:IsA("SpecialMesh") then
                    dm.VertexColor = vcol
                elseif dm:IsA("MeshPart") then
                    dm.Color = rgbColor
                end
            end
            local f = cache.fallback
            if f and f.Parent then
                if f:IsA("SpecialMesh") then
                    f.VertexColor = vcol
                elseif f:IsA("MeshPart") then
                    f.Color = rgbColor
                end
            end
        end
        if stale then _animSkinCache[w.name] = nil end
    end
end)))
task.spawn(LPH_NO_VIRTUALIZE(function()
    while _scriptRunning and task.wait(0.3) do
        if not Flags["SkinSwap"] then continue end
        local char=lp.Character; local bp=lp:FindFirstChild("Backpack")
        local weps={{name = "[Revolver]",flag = "RevSkin"},{name = "[Double-Barrel SG]",flag = "DBSkin"},{name = "[TacticalShotgun]",flag = "TacSkin"}}
        for _,w in ipairs(weps) do
            local skinname = Flags[w.flag] or "Default"
            local tool = (bp and bp:FindFirstChild(w.name)) or (char and char:FindFirstChild(w.name))
            if not tool then continue end
            local applyKey = w.name .. ":" .. skinName .. ":" .. tostring(tool)
            if _lastAppliedSkins[w.name] == applyKey then continue end
            _lastAppliedSkins[w.name] = applyKey
            if skinname = = "Default" then
                restoreOriginalSkin(tool)
                continue
            end
            local data = SkinData[skinName]
            if not data then continue end
            if data.RevolverOnly and w.name ~= "[Revolver]" then continue end
            if data.Pulsate or data.Rainbow then continue end
            if data.ScrollTex then
                restoreOriginalSkin(tool)
                cacheOriginalSkin(tool)
                local h = tool:FindFirstChild("Handle")
                if h and h:IsA("BasePart") then h.Transparency = 1 end
                local stTexId = data.Textures and data.Textures[w.name] or ""
                local forcedMeshId = scrollMeshIds[w.name]
                for _, desc in ipairs(tool:GetDescendants()) do
                    if desc:FindFirstAncestor("_OverridePart") then continue end
                    if desc:IsA("BasePart") and desc.name = = "Neon" then
                        desc.Color = data.Color
                        desc.Material = Enum.Material.Neon
                        desc.Transparency = 0
                    elseif desc:IsA("MeshPart") and (desc.name = = "Mesh" or desc.name = = "Default") then
                        if forcedMeshId then desc.MeshId = forcedMeshId end
                        desc.TextureID = stTexId
                        desc.Color = data.Color
                    elseif desc:IsA("SpecialMesh") and (desc.name = = "Mesh" or desc.name = = "Default") then
                        if forcedMeshId then
                            desc.MeshId = forcedMeshId
                            desc.MeshType = Enum.MeshType.FileMesh
                        end
                        desc.TextureId = stTexId
                        desc.VertexColor = Vector3.new(data.Color.R, data.Color.G, data.Color.B)
                    end
                end
                continue
            end
            restoreOriginalSkin(tool)
            cacheOriginalSkin(tool)
            local h = tool:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then h.Transparency = 1 end
            local texId = data.Textures and data.Textures[w.name] or ""
            if texId == "" and not data.CosmicCycle and not data.AltMesh then continue end
            if data.AltMesh then
                local meshId = data.MeshIds and data.MeshIds[w.name] or ""
                if meshId ~= "" then
                    for _, desc in ipairs(tool:GetDescendants()) do
                        if not desc:FindFirstAncestor("_OverridePart") then
                            if desc:IsA("MeshPart") and desc.Name ~= "Neon" then
                                desc.MeshId = meshId
                                if texId ~= "" then
                                    desc.TextureID = texId
                                end
                            elseif desc:IsA("SpecialMesh") then
                                desc.MeshId = meshId
                                desc.MeshType = Enum.MeshType.FileMesh
                                if texId ~= "" then
                                    desc.TextureId = texId
                                end
                            end
                        end
                    end
                end
                if data.NoNeon then
                    for _, desc in ipairs(tool:GetDescendants()) do
                        if desc:IsA("BasePart") and desc.name = = "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                            desc.Transparency = 1
                        end
                    end
                else
                    for _, desc in ipairs(tool:GetDescendants()) do
                        if desc:IsA("BasePart") and desc.name = = "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                            desc.Color = data.Color
                            desc.Material = Enum.Material.Neon
                            desc.Transparency = 0
                        end
                    end
                end
            else
                for _, desc in ipairs(tool:GetDescendants()) do
                    if desc:IsA("BasePart") and desc.name = = "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                        if data.CosmicCycle then
                            local hue = (tick() * 0.3) % 1
                            desc.Color = Color3.fromHSV(hue, 0.7, 1)
                        else
                            desc.Color = data.Color
                        end
                        desc.Material = Enum.Material.Neon
                        desc.Transparency = 0
                    end
                end
                local texId = data.Textures and data.Textures[w.name] or ""
                if texId ~= "" then
                    local applied = false
                    local default = tool:FindFirstChild("Default")
                    if default then
                        local mesh = default:FindFirstChild("Mesh")
                        if mesh then
                            if mesh:IsA("SpecialMesh") then
                                mesh.TextureId = texId
                                applied = true
                            elseif mesh:IsA("MeshPart") then
                                mesh.TextureID = texId
                                applied = true
                            end
                        end
                        if not applied then
                            local sm = default:FindFirstChildOfClass("SpecialMesh")
                            if sm then
                                sm.TextureId = texId
                                applied = true
                            end
                        end
                        if not applied and default:IsA("MeshPart") then
                            default.TextureID = texId
                            default.Color = data.Color
                            applied = true
                        end
                    end
                    if not applied then
                        for _, desc in ipairs(tool:GetDescendants()) do
                            if not desc:FindFirstAncestor("_OverridePart") then
                                if desc:IsA("SpecialMesh") then
                                    desc.TextureId = texId
                                    applied = true
                                    break
                                elseif desc:IsA("MeshPart") and desc.Name ~= "Neon" then
                                    desc.TextureID = texId
                                    desc.Color = data.Color
                                    applied = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
            if data.Particle then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("Default")
                if handle and handle:IsA("BasePart") and not handle:FindFirstChild("_SkinParticle") then
                    local pe = Instance.new("ParticleEmitter")
                    pe.name = "_SkinParticle"
                    pe.Color = typeof(data.ParticleColor) == "ColorSequence" and data.ParticleColor or ColorSequence.new(data.ParticleColor or data.Color)
                    pe.Texture = (data.ParticleTexture and data.ParticleTexture ~= "") and data.ParticleTexture or "rbxassetid://6490035152"
                    pe.Rate = data.ParticleRate or 12
                    pe.Size = data.ParticleSize or NumberSequence.new(0.2, 0)
                    pe.Lifetime = data.ParticleLifetime or NumberRange.new(0.5, 1)
                    pe.Speed = data.ParticleSpeed or NumberRange.new(1, 3)
                    pe.SpreadAngle = Vector2.new(30, 30)
                    pe.LightEmission = 0.5
                    pe.LightInfluence = 0
                    pe.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(0.8, 0.3),
                        NumberSequenceKeypoint.new(1, 1),
                    })
                    pe.Parent = handle
                end
            else
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("Default")
                if handle and handle:IsA("BasePart") then
                    local existing = handle:FindFirstChild("_SkinParticle")
                    if existing then existing:Destroy() end
                end
            end
        end

        pcall(function()
            local df=lp:FindFirstChild("DataFolder"); if not df then return end
            local eq=df:FindFirstChild("Inventory"); if not eq then return end; eq=eq:FindFirstChild("Equipped"); if not eq then return end
            local sk=eq:FindFirstChild("Skins"); if not sk then return end
            for _,w in ipairs(weps) do local sv=sk:FindFirstChild(w.name); if sv then sv.Value="Shadow" end end
        end)
    end
end))

end

do
SetPage = Window:Page({ name = "Settings", Icon = "rbxassetid://7059346373" })
ConfigSection = SetPage:Section({ name = "Configs", Side = 1 })
local SettingsMultiR = SetPage:MultiSection({ Side = 2 })
MenuSection = SettingsMultiR:Add("Menu")
NotifSection = SettingsMultiR:Add("Notifications")
ConfigDir = "alternate.lol/configs"
pcall(function() if not isfolder("alternate.lol") then makefolder("alternate.lol") end end)
pcall(function() if not isfolder(ConfigDir) then makefolder(ConfigDir) end end)
getConfigList = function()
    local list = {}
    pcall(function()
        for _, file in ipairs(listfiles(ConfigDir)) do
            local name = file:match("([^/\\]+)%.cfg$")
            if name then table.insert(list, name) end
        end
    end)
    table.sort(list)
    return list
end
CFG_SKIP = {
    Cfgname = true, CfgSelect=true, AutoSaveCfg=true, AutoLoadCfg=true,
    ShowWM=true, ShowKL=true, _MenuBind=true, MenuKeybind=true,
    _ThemeAccentT=true, _ThemeBGT=true, _ThemeTextT=true, _ThemeOutT=true,
    _ThemeBorderT=true, _ThemeInlineT=true, _ThemeInactiveT=true, _ThemeElemT=true, _ThemeElem2T=true, _ThemeHoverT=true,
    ThemeAccent=true, ThemeBG=true, ThemeText=true, ThemeOutline=true,
    ThemeBorder=true, ThemeInline=true, ThemeInactive=true, ThemeElem=true, ThemeElem2=true, ThemeHover=true,
    BloomInt=true, BloomSz=true, BloomTh=true, BlurSz=true, SunInt=true, SunSpr=true,
    CustomFog=true, FogStart=true, FogEnd=true, FogSpin=true, FogSpinSpd=true,
    Weather=true, RainArea=true, RainDropSize=true, RainDropSpeed=true,
    RainDropRandom=true, RainDropAlpha=true, RainDropsPerFrame=true,
    RainFogEnd=true, RainSplashSize=true, RainSplashAlpha=true, RainSplashDuration=true,
    RainScreenOverlayEnabled=true,
    CustomSkybox=true, SkyboxSelect=true, SkySpin=true, SkySpinSpd=true,
    CustMat=true, MatType=true, MatApply=true, MatClr=true,
    ElementSize=true, UIThemePreset=true,
    c_silentfov=true, c_silentfovout=true,
}
local function serializeColor3(c)
    return {_type="Color3", R=math.floor(c.R*255+0.5), G=math.floor(c.G*255+0.5), B=math.floor(c.B*255+0.5)}
end

saveConfig = LPH_NO_VIRTUALIZE(function(name)
    if not name or name = = "" then return end
    local data = {}
    for flag, value in pairs(Flags) do
        if type(flag) ~= "string" then continue end
        if CFG_SKIP[flag] then continue end
        if flag:match("^_") then continue end
        if flag:match("ModeDropdown$") or flag:match("ShowInKeybindsList$") or flag:match("Sync$") or flag:match("Theming$") then continue end
        local t = typeof(value)
        if t == "boolean" or t == "number" or t == "string" then
            data[flag] = value
        elseif t == "Color3" then
            data[flag] = serializeColor3(value)
        elseif t == "table" then
            if value.Color and typeof(value.Color) == "Color3" then
                data[flag] = serializeColor3(value.Color)
            elseif value.Key then
                local keyVal = value.key or value.Key
                data[flag] = {
                    mode = value.mode or value.Mode or "Toggle",
                    key = tostring(keyVal),
                    active = value.active or value.Active or false,
                }
            else
                local safe = true
                for _, v in pairs(value) do
                    if type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean" then safe=false; break end
                end
                if safe then data[flag] = value end
            end
        end
    end
    local success, err = pcall(function()
        writefile(ConfigDir .. "/" .. name .. ".cfg", game:GetService("HttpService"):JSONEncode(data))
    end)
    if success then
        Library:Notify("Config saved: " .. name, 3)
    else
        Library:Notify("Failed to save config!", 3)
    end
end)
loadConfig = LPH_NO_VIRTUALIZE(function(name)
    if not name or name = = "" then return end
    local path = ConfigDir .. "/" .. name .. ".cfg"
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then Library:Notify("Config not found!", 3); return end
    local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then Library:Notify("Config corrupted!", 3); return end

    local function resolveKeybind(value)
        local keyStr = tostring(value.key or value.Key)
        local keyEnum = keyStr:find("Enum") and Library:convert_enum(keyStr) or keyStr
        if keyStr == "NONE" then keyEnum = "NONE" end
        return {
            mode = value.mode or value.Mode or "Toggle",
            key = keyEnum,
            active = value.active or value.Active or false,
        }
    end

    for flag, value in pairs(data) do
        if CFG_SKIP[flag] then continue end
        pcall(function()
            local resolved = value
            if type(value) == "table" and value._type == "Color3" then
                resolved = Color3.fromRGB(value.R or 0, value.G or 0, value.B or 0)
            end
            if Library.SetFlags and Library.SetFlags[flag] then
                if type(value) == "table" and (value.key or value.Key) then
                    Library.SetFlags[flag](resolveKeybind(value))
                else
                    Library.SetFlags[flag](resolved)
                end
            else
                Flags[flag] = resolved
            end
        end)
    end
    Library:Notify("Config loaded: " .. name, 3)
end)
local function deleteConfig(name)
    if not name or name = = "" then return end
    pcall(function() delfile(ConfigDir .. "/" .. name .. ".cfg") end)
    Library:Notify("Config deleted: " .. name, 3)
end
local configNameflag = ""
ConfigSection:Textbox({ name = "Config Name", flag = "CfgName", callback = function(v) configNameflag = v end })
local cfgDropdown = ConfigSection:addDropdown({ name = "Configs", flag = "CfgSelect", items = getConfigList(), default = nil })
ConfigSection:Button({ name = "Save Config", callback = function()
    local name = Flags["CfgName"] or configNameFlag
    if name = = "" then return end
    saveConfig(name)
    pcall(function() cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:Button({ name = "Load Config", callback = function()
    local name = Flags["CfgSelect"]
    if name and name ~= "" then loadConfig(name) end
end })
ConfigSection:Button({ name = "Delete Config", callback = function()
    local name = Flags["CfgSelect"]
    if name and name ~= "" then deleteConfig(name) end
    pcall(function() cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:Button({ name = "Refresh List", callback = function()
    pcall(function() cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:addToggle({ name = "Auto-Save", flag = "AutoSaveCfg", default = false })
local autoLoadDropdown = ConfigSection:addDropdown({ name = "Auto-Load Config", flag = "AutoLoadCfg", items = getConfigList(), default = nil, callback = function(v)
    pcall(function()
        if v and v ~= "" then
            writefile("alternate.lol/autoload.cfg", v)
        else
            pcall(function() delfile("alternate.lol/autoload.cfg") end)
        end
    end)
end })
ConfigSection:Button({ name = "Load Now", callback = function()
    local name = Flags["AutoLoadCfg"]
    if name and name ~= "" then loadConfig(name) end
end })
task.spawn(function()
    while _scriptRunning and task.wait(60) do
        if Flags["AutoSaveCfg"] then
            local name = Flags["CfgName"] or configNameFlag
            if name = = "" then name = "autosave" end
            pcall(function() saveConfig(name) end)
        end
    end
end)
task.spawn(function()
    task.wait(5)
    local ok, savedAutoLoad = pcall(readfile, "alternate.lol/autoload.cfg")
    if not ok or not savedAutoLoad then return end
    savedAutoLoad = savedAutoLoad:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[%r%n]", "")
    if savedAutoLoad == "" then return end
    pcall(function()
        if autoLoadDropdown then autoLoadDropdown:Set(savedAutoLoad) end
    end)
    pcall(function() loadConfig(savedAutoLoad) end)
end)
MenuSection:addToggle({ name = "Watermark", flag = "ShowWM", default = true, callback = function(v)
    pcall(function() if Library.WatermarkObj then Library.WatermarkObj:SetVisibility(v) end end)
end })
MenuSection:addToggle({ name = "Keybind List", flag = "ShowKL", default = true, callback = function(v)
    pcall(function() if Library.KeyList then Library.KeyList:SetVisibility(v) end end)
end })
MenuSection:Label({ name = "Menu Keybind" }):addKeyBind({ flag = "MenuKeybind", Key = Enum.KeyCode.M, Mode = "Toggle", callback = function(bool)
    Library.MenuKeybind = Flags["MenuKeybind"].Key
    Window.toggle_menu(bool)
end })
MenuSection:addToggle({ name = "Notifications", flag = "NotificationsEnabled", default = true, callback = function(v)
    Library.NotificationsEnabled = v
end })
MenuSection:addSlider({ name = "Element Size", flag = "ElementSize", min = 80, max = 200, default = 100, Suffix = "%", callback = function(v)
    pcall(function() Library:set_element_scale(v / 100) end)
end })
MenuSection:Button({ name = "Reset Element Size", callback = function()
    if Flags["ElementSize"] then
        Flags["ElementSize"] = 100
    end
    if Library.SetFlags and Library.SetFlags["ElementSize"] then
        Library.SetFlags["ElementSize"](100)
    end
    pcall(function() Library:set_element_scale(1) end)
end })

local ThemeSection = SettingsMultiR:Add("Themes")
local UIThemes = {
    ["Blackout"] = { Accent=Color3.fromRGB(255,255,255), BG=Color3.fromRGB(0,0,0), Text=Color3.fromRGB(255,255,255), Out=Color3.fromRGB(30,30,30), Inline=Color3.fromRGB(10,10,10), Elem=Color3.fromRGB(20,20,20), Elem2=Color3.fromRGB(35,35,35), Hover=Color3.fromRGB(45,45,45), Unsel=Color3.fromRGB(120,120,120), Border=Color3.fromRGB(0,0,0) },
    ["Midnight"] = { Accent=Color3.fromRGB(90,140,255), BG=Color3.fromRGB(6,8,14), Text=Color3.fromRGB(225,232,255), Out=Color3.fromRGB(28,34,52), Inline=Color3.fromRGB(10,13,22), Elem=Color3.fromRGB(16,20,32), Elem2=Color3.fromRGB(28,34,52), Hover=Color3.fromRGB(38,46,70), Unsel=Color3.fromRGB(100,110,140), Border=Color3.fromRGB(0,0,0) },
    ["Tokyo Night"] = { Accent=Color3.fromRGB(122,162,247), BG=Color3.fromRGB(13,14,21), Text=Color3.fromRGB(192,202,245), Out=Color3.fromRGB(36,40,59), Inline=Color3.fromRGB(16,18,28), Elem=Color3.fromRGB(26,27,38), Elem2=Color3.fromRGB(41,46,66), Hover=Color3.fromRGB(52,59,88), Unsel=Color3.fromRGB(86,95,137), Border=Color3.fromRGB(0,0,0) },
    ["Dracula"] = { Accent=Color3.fromRGB(189,147,249), BG=Color3.fromRGB(20,21,29), Text=Color3.fromRGB(248,248,242), Out=Color3.fromRGB(54,57,74), Inline=Color3.fromRGB(24,25,35), Elem=Color3.fromRGB(40,42,54), Elem2=Color3.fromRGB(54,57,74), Hover=Color3.fromRGB(68,71,90), Unsel=Color3.fromRGB(98,114,164), Border=Color3.fromRGB(0,0,0) },
    ["Catppuccin"] = { Accent=Color3.fromRGB(203,166,247), BG=Color3.fromRGB(17,17,27), Text=Color3.fromRGB(205,214,244), Out=Color3.fromRGB(49,50,68), Inline=Color3.fromRGB(24,24,37), Elem=Color3.fromRGB(30,30,46), Elem2=Color3.fromRGB(49,50,68), Hover=Color3.fromRGB(69,71,90), Unsel=Color3.fromRGB(108,112,134), Border=Color3.fromRGB(0,0,0) },
    ["Nord"] = { Accent=Color3.fromRGB(136,192,208), BG=Color3.fromRGB(26,29,36), Text=Color3.fromRGB(236,239,244), Out=Color3.fromRGB(59,66,82), Inline=Color3.fromRGB(35,39,49), Elem=Color3.fromRGB(46,52,64), Elem2=Color3.fromRGB(59,66,82), Hover=Color3.fromRGB(76,86,106), Unsel=Color3.fromRGB(120,130,150), Border=Color3.fromRGB(0,0,0) },
    ["Gruvbox"] = { Accent=Color3.fromRGB(250,189,47), BG=Color3.fromRGB(23,25,26), Text=Color3.fromRGB(235,219,178), Out=Color3.fromRGB(60,56,54), Inline=Color3.fromRGB(29,32,33), Elem=Color3.fromRGB(40,40,40), Elem2=Color3.fromRGB(60,56,54), Hover=Color3.fromRGB(80,73,69), Unsel=Color3.fromRGB(146,131,116), Border=Color3.fromRGB(0,0,0) },
    ["Cyberpunk"] = { Accent=Color3.fromRGB(0,255,213), BG=Color3.fromRGB(10,6,18), Text=Color3.fromRGB(240,240,255), Out=Color3.fromRGB(60,20,80), Inline=Color3.fromRGB(16,10,28), Elem=Color3.fromRGB(26,16,44), Elem2=Color3.fromRGB(44,26,70), Hover=Color3.fromRGB(60,36,95), Unsel=Color3.fromRGB(130,100,170), Border=Color3.fromRGB(0,0,0) },
    ["Blood Moon"] = { Accent=Color3.fromRGB(255,60,70), BG=Color3.fromRGB(12,6,8), Text=Color3.fromRGB(255,235,235), Out=Color3.fromRGB(60,20,26), Inline=Color3.fromRGB(20,10,12), Elem=Color3.fromRGB(32,14,18), Elem2=Color3.fromRGB(52,22,28), Hover=Color3.fromRGB(70,30,38), Unsel=Color3.fromRGB(150,100,105), Border=Color3.fromRGB(0,0,0) },
    ["Emerald"] = { Accent=Color3.fromRGB(80,250,123), BG=Color3.fromRGB(6,12,9), Text=Color3.fromRGB(225,255,235), Out=Color3.fromRGB(24,52,36), Inline=Color3.fromRGB(10,20,15), Elem=Color3.fromRGB(16,30,22), Elem2=Color3.fromRGB(26,48,36), Hover=Color3.fromRGB(34,64,48), Unsel=Color3.fromRGB(100,140,115), Border=Color3.fromRGB(0,0,0) },
    ["Rose"] = { Accent=Color3.fromRGB(255,140,180), BG=Color3.fromRGB(16,10,13), Text=Color3.fromRGB(255,235,242), Out=Color3.fromRGB(56,32,42), Inline=Color3.fromRGB(24,15,19), Elem=Color3.fromRGB(34,21,27), Elem2=Color3.fromRGB(54,34,43), Hover=Color3.fromRGB(72,45,57), Unsel=Color3.fromRGB(160,115,130), Border=Color3.fromRGB(0,0,0) },
    ["Oceanic"] = { Accent=Color3.fromRGB(0,180,255), BG=Color3.fromRGB(5,12,20), Text=Color3.fromRGB(220,240,255), Out=Color3.fromRGB(20,44,64), Inline=Color3.fromRGB(9,19,30), Elem=Color3.fromRGB(14,28,44), Elem2=Color3.fromRGB(24,46,70), Hover=Color3.fromRGB(32,60,92), Unsel=Color3.fromRGB(95,130,160), Border=Color3.fromRGB(0,0,0) },
}
local UIThemeOrder = {"Blackout","Midnight","Tokyo Night","Dracula","Catppuccin","Nord","Gruvbox","Cyberpunk","Blood Moon","Emerald","Rose","Oceanic"}
local applyUITheme = function(name)
    local t = UIThemes[name]
    if not t then return end
    pcall(function()
        Library:ChangeTheme("Accent", t.Accent)
        Library:ChangeTheme("Background", t.BG)
        Library:ChangeTheme({"Text", "Main"}, t.Text)
        Library:ChangeTheme({"Borders", "Outline"}, t.Out)
        Library:ChangeTheme("Inline", t.Inline)
        Library:ChangeTheme("Element", t.Elem)
        Library:ChangeTheme("Element 2", t.Elem2)
        Library:ChangeTheme("Hovered Element", t.Hover)
        Library:ChangeTheme({"Text", "Unselected"}, t.Unsel)
        Library:ChangeTheme({"Borders", "Inline"}, t.Border)
    end)
    pcall(function()
        if Library.SetFlags then
            if Library.SetFlags["ThemeAccent"] then Library.SetFlags["ThemeAccent"](t.Accent) end
            if Library.SetFlags["ThemeBG"] then Library.SetFlags["ThemeBG"](t.BG) end
            if Library.SetFlags["ThemeText"] then Library.SetFlags["ThemeText"](t.Text) end
            if Library.SetFlags["ThemeElem"] then Library.SetFlags["ThemeElem"](t.Elem) end
            if Library.SetFlags["ThemeOutline"] then Library.SetFlags["ThemeOutline"](t.Out) end
        end
    end)
end
ThemeSection:addDropdown({ name = "Theme Preset", flag = "UIThemePreset", items = UIThemeOrder, default = "Blackout", callback = function(v)
    applyUITheme(v)
end })
ThemeSection:addColorPicker({ name = "Accent", flag = "ThemeAccent", default = Color3.fromRGB(255,255,255), callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Accent", c) end) end
end })
ThemeSection:addColorPicker({ name = "Background", flag = "ThemeBG", default = Color3.fromRGB(0,0,0), callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Background", c) end) end
end })
ThemeSection:addColorPicker({ name = "Text", flag = "ThemeText", default = Color3.fromRGB(255,255,255), callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Text","Main"}, c) end) end
end })
ThemeSection:addColorPicker({ name = "Element", flag = "ThemeElem", default = Color3.fromRGB(20,20,20), callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Element", c) end) end
end })
ThemeSection:addColorPicker({ name = "Outline", flag = "ThemeOutline", default = Color3.fromRGB(30,30,30), callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Borders","Outline"}, c) end) end
end })
local ThemeSaveDir = "alternate.lol"
ThemeSection:Button({ name = "Save Theme", callback = function()
    pcall(function()
        writefile(ThemeSaveDir .. "/theme.txt", tostring(Flags["UIThemePreset"] or "Blackout"))
        Library:Notify("Theme saved!", 3)
    end)
end })
task.spawn(function()
    task.wait(1)
    local ok, saved = pcall(readfile, ThemeSaveDir .. "/theme.txt")
    if ok and saved and UIThemes[saved] and saved ~= "Blackout" then
        pcall(function()
            if Library.SetFlags and Library.SetFlags["UIThemePreset"] then
                Library.SetFlags["UIThemePreset"](saved)
            else
                applyUITheme(saved)
            end
        end)
    end
end)

Library.NotifSettings = Library.NotifSettings or {}
NotifSection:addSlider({ name = "Duration", flag = "NotifDuration", min = 1, max = 15, default = 3, Suffix = "s", callback = function(v)
    Library.NotifSettings.Duration = v
end })
NotifSection:addDropdown({ name = "Type", flag = "NotifType", items = {"Full", "Text"}, default = "Full", callback = function(v)
    Library.NotifSettings.Type = v
end })
NotifSection:addDropdown({ name = "Animation", flag = "NotifAnimation", items = {"Slide", "Fade", "Pop"}, default = "Slide", callback = function(v)
    Library.NotifSettings.Animation = v
end })
NotifSection:addDropdown({ name = "Position", flag = "NotifPosition", items = {
    "Top Right", "Top Left", "Top Center",
    "Bottom Right", "Bottom Left", "Bottom Center"
}, default = "Top Right", callback = function(v)
    Library.NotifSettings.Position = v
end })
NotifSection:Button({ name = "Test Notification", callback = function()
    Library:Notify("This is a test notification!", Library.NotifSettings.Duration or 3)
end })
NotifSection:addToggle({ name = "Hit Notifications Custom Text", flag = "NotifCustomText", default = false })
NotifSection:Textbox({ name = "Hit Text Format", flag = "NotifHitFormat", default = "Hit: {player} - DMG: {dmg} - HP: {hp}", Placeholder = "Use {player} {dmg} {hp}" })
NotifSection:addToggle({ name = "Show Damage in Notification", flag = "NotifShowDmg", default = true })
NotifSection:addToggle({ name = "Show HP in Notification", flag = "NotifShowHP", default = true })
NotifSection:addToggle({ name = "Lethal Hit Notification", flag = "NotifLethal", default = false })
NotifSection:addColorPicker({ name = "Lethal Notif Color", flag = "NotifLethalColor", default = Color3.fromRGB(255, 55, 55) })
NotifSection:addSlider({ name = "Max Notifications", flag = "NotifMaxShown", min = 1, max = 10, default = 5, callback = function(v)
    Library.NotifSettings.MaxShown = v
end })
NotifSection:addToggle({ name = "Sound on Notification", flag = "NotifSound", default = false, callback = function(v)
    Library.NotifSettings.PlaySound = v
end })
NotifSection:addSlider({ name = "Notif Sound Volume", flag = "NotifSoundVol", min = 0, max = 10, default = 3, callback = function(v)
    Library.NotifSettings.SoundVolume = v
end })
MenuSection:Button({ name = "Rejoin", callback = function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
    end)
end })
MenuSection:Button({ name = "Server Hop", callback = function()
    pcall(function()
        local TS = game:GetService("TeleportService")
        local HS = game:GetService("HttpService")
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                    "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=25"
        local ok, res = pcall(function() return HS:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data then
            for _, srv in ipairs(res.data) do
                if srv.id ~= game.JobId and (srv.playing or 0) < (srv.maxPlayers or 1) then
                    TS:TeleportToPlaceInstance(game.PlaceId, srv.id, lp)
                    return
                end
            end
        end
        Library:Notify("No open servers found!", 3)
    end)
end })
local function restoreMaterials()
    for p, orig in pairs(originalPartMaterials) do
        pcall(function()
            if p and p.Parent then
                p.Material = orig.Material
                p.Color = orig.Color
            end
        end)
    end
    originalPartMaterials = setmetatable({}, { __mode = "k" })
end

local function restoreLighting()
    pcall(function() clearWeatherObjects() end)
    pcall(function()
        if _W.originalLightingState then
            Lighting.FogEnd = _W.originalLightingState.FogEnd
            Lighting.FogStart = _W.originalLightingState.FogStart
            Lighting.FogColor = _W.originalLightingState.FogColor
        end
    end)
    pcall(function()
        local ourAtmo = Lighting:FindFirstChild("_AlternateAtmo")
        if ourAtmo then pcall(function() ourAtmo:Destroy() end) end
        local a = Lighting:FindFirstChildOfClass("Atmosphere")
        if a and _origAtmoDensity then
            a.Density = _origAtmoDensity; a.Offset = _origAtmoOffset
            a.Glare   = _origAtmoGlare;   a.Haze   = _origAtmoHaze
        end
    end)
    pcall(function()
        if Flags["OverLight"] then
            Lighting.Brightness = _origBrightness or Lighting.Brightness
            Lighting.OutdoorAmbient = _origOutdoorAmbient or Lighting.OutdoorAmbient
            local cc = Lighting:FindFirstChild("_AlternateCC")
            if cc then pcall(function() cc:Destroy() end) end
        end
    end)
end

local function restoreSkybox()
    pcall(function()
        if skyboxObj then skyboxObj:Destroy(); skyboxObj = nil end
        if originalSky then originalSky.Parent = Lighting end
    end)
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then
            if _origSunSize   then sky.SunAngularSize  = _origSunSize   end
            if _origMoonSize  then sky.MoonAngularSize = _origMoonSize  end
            if _origStarCount then sky.StarCount       = _origStarCount end
        end
        local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
        if sunRays and _origSunRaysEnabled ~= nil then
            sunRays.Enabled = _origSunRaysEnabled
        end
    end)
end

local function cleanupChams()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then removeChamsHighlight(p.Character) end
        end
        for _, bot in ipairs(getNPCs()) do
            removeChamsHighlight(bot)
        end
    end)
end

local function cleanupConnections()
    _scriptRunning = false
    pcall(function()
        if _W._stopRain then _W._stopRain() end
        if _W._stopSnow then _W._stopSnow() end
        if disableCherry then disableCherry() end
        if _timeConnection then _timeConnection:Disconnect(); _timeConnection = nil end
    end)
    pcall(function()
        _silentHooked = false
        Flags["SilentEnabled"] = false
    end)
    pcall(function()
        for _, conn in ipairs(_connections) do
            pcall(function() conn:Disconnect() end)
        end
        _connections = {}
    end)
end

local function cleanupUI()
    pcall(function() fovCircle:Remove(); fovCircleOut:Remove() end)
    pcall(function() silentFovCircle:Remove(); silentFovCircleOut:Remove() end)
    pcall(function() targetTracer:Remove(); targetTracerOut:Remove() end)
    pcall(function() applyHeadless(false) end)
    pcall(function() applyKorblox("Right", false); applyKorblox("Left", false) end)
    pcall(function()
        if Library.WatermarkObj and Library.WatermarkObj.SetVisibility then
            Library.WatermarkObj:SetVisibility(false)
        end
    end)
    pcall(function()
        if Library.KeyList and Library.KeyList.SetVisibility then
            Library.KeyList:SetVisibility(false)
        end
    end)
    pcall(function()
        if EspLibrary then EspLibrary:Unload() end
    end)
    pcall(function()
        if Library.Unload then Library:Unload() end
    end)
    pcall(function()
        local guiParent = pcall(gethui) and gethui() or game:GetService("CoreGui")
        for _, obj in ipairs(guiParent:GetChildren()) do
            if obj:IsA("ScreenGui") and (obj.Name:lower():match("alternate") or obj.Name:lower():match("linoria") or obj.Name:lower():match("library")) then
                obj:Destroy()
            end
        end
        local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, obj in ipairs(pg:GetChildren()) do
                if obj:IsA("ScreenGui") and (obj.Name:lower():match("alternate") or obj.Name:lower():match("linoria") or obj.Name:lower():match("library")) then
                    obj:Destroy()
                end
            end
        end
    end)
end

MenuSection:Button({ name = "Unload", callback = function()
    pcall(restoreMaterials)
    pcall(restoreLighting)
    pcall(restoreSkybox)
    pcall(cleanupChams)
    pcall(cleanupConnections)
    pcall(cleanupUI)
end })
end

    local fogHue = 0
    local fogSpinAngle = 0
    local lastFogColor, lastFogStart, lastFogEnd
    local lastDensity, lastOffset, lastGlare, lastHaze
    _trackConn(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
        if Flags["CustomFog"] then
            local color = C.Fog
            local start = Flags["FogStart"] or 0
            local ending = Flags["FogEnd"] or 5000
            if color ~= lastFogColor or start ~= lastFogStart or ending ~= lastFogEnd then
                lastFogColor, lastFogStart, lastFogEnd = color, start, ending
                Lighting.FogColor = color
                Lighting.FogStart = start
                Lighting.FogEnd = ending
            end
        end
        if Flags["CustomFog"] and Flags["FogSpin"] then
            local spd = (Flags["FogSpinSpd"] or 20)
            fogSpinAngle = (fogSpinAngle + spd * dt) % 360
            fogHue = fogSpinAngle / 360
            local color = Color3.fromHSV(fogHue, 0.8, 1)
            local pulse = math.sin(math.rad(fogSpinAngle * 2))
            local baseFogEnd = Flags["FogEnd"] or 5000
            local ending = baseFogEnd + pulse * (baseFogEnd * 0.15)
            lastFogColor, lastFogEnd = color, ending
            Lighting.FogColor = color
            Lighting.FogEnd = ending
        end
        if Flags["OverAtmo"] then
            local a = getOrCreateAtmo()
            local density = (Flags["AtmoD"] or 40)/200
            local offset = (Flags["AtmoO"] or 0)/100
            local glare = (Flags["AtmoG"] or 0)/25
            local haze = (Flags["AtmoH"] or 0)/10
            if density ~= lastDensity or offset ~= lastOffset or glare ~= lastGlare or haze ~= lastHaze then
                lastDensity, lastOffset, lastGlare, lastHaze = density, offset, glare, haze
                pcall(function()
                    a.Density = density
                    a.Offset = offset
                    a.Glare = glare
                    a.Haze = haze
                end)
            end
        end
        if Flags["SkySpin"] and Flags["CustomSkybox"] and skyboxObj then
            local spd = (Flags["SkySpinSpd"] or 20)
            pcall(function()
                skyboxObj.SkyboxOrientation = skyboxObj.SkyboxOrientation + Vector3.new(0, spd * dt, 0)
            end)
        end
        if Flags["OverLight"] then
            local bright = Flags["Bright"] or 1
            pcall(function()
                if Lighting.Brightness ~= bright then Lighting.Brightness = bright end
                local boost = math.clamp((bright - 1) * 0.15, -0.3, 0.3)
                local targetAmbient = Color3.new(0.5 + boost, 0.5 + boost, 0.5 + boost)
                if Lighting.OutdoorAmbient ~= targetAmbient then Lighting.OutdoorAmbient = targetAmbient end
            end)
            
            local sat = (Flags["Sat"] or 0) / 100
            local cont = (Flags["Cont"] or 0) / 100
            pcall(function()
                local cc = getOrCreateCC()
                if cc.Saturation ~= sat then cc.Saturation = sat end
                if cc.Contrast ~= cont then cc.Contrast = cont end
            end)
        end
        local activeTarget = nil
        if _bindActive("AimbotBind") and aimbotTarget then
            activeTarget = aimbotTarget
        end
        currentTarget = activeTarget
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") then
                local hum = p.Character.Humanoid
                local currHealth = math.round(hum.Health)
                local prevHealth = previousTargetHealth[p.Name]
                if prevHealth ~= nil and currHealth < prevHealth and currHealth >= 0 then
                    local isSilentTarget = Flags["SilentEnabled"] and (_silentCurrentPlayer == p)
                    local isAimbotTarget = _bindActive("AimbotBind") and activeTarget and activeTarget.Parent == p.Character
                    local shouldTrigger = isSilentTarget or isAimbotTarget or not Flags["SilentEnabled"]
                    if shouldTrigger then
                        if HitEffects.HitNotifications then
                            local dmg = prevHealth - currHealth
                            local msg
                            if Flags["NotifCustomText"] then
                                local fmt = Flags["NotifHitFormat"] or "Hit: {player} - DMG: {dmg} - HP: {hp}"
                                msg = fmt:gsub("{player}", p.Name):gsub("{dmg}", tostring(dmg)):gsub("{hp}", tostring(currHealth))
                            else
                                local parts = {"Hit: " .. p.Name}
                                if Flags["NotifShowDmg"] ~= false then
                                    parts[#parts + 1] = "DMG: " .. dmg
                                end
                                if Flags["NotifShowHP"] ~= false then
                                    parts[#parts + 1] = "HP: " .. currHealth
                                end
                                msg = table.concat(parts, " - ")
                            end
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            local isLethal = hum and hum.Health <= 0
                            if isLethal and Flags["NotifLethal"] then
                                msg = msg .. " (LETHAL)"
                            end
                            Library:Notify(msg, HitEffects.HitNotificationsTime)
                            if Flags["NotifSound"] then
                                local snd = Instance.new("Sound")
                                snd.Parent = workspace
                                snd.SoundId = "rbxassetid://5633695679"
                                snd.Volume = Flags["NotifSoundVol"] or 3
                                snd:Play()
                                snd.Ended:Connect(function() snd:Destroy() end)
                                task.delay(5, function() if snd then snd:Destroy() end end)
                            end
                        end
                        if HitEffects.HitChams.Enabled then
                            HitChams(p)
                        end
                        if HitEffects.HitEffect.Enabled then
                            TriggerHitEffect(p)
                        end
                        if HitEffects.HitSkeleton.Enabled then
                            HitChamsSkeleton(p)
                        end
                        if HitEffects.HitSounds then
                            pcall(createHitSound)
                        end
                    end
                end
                previousTargetHealth[p.Name] = currHealth
            end
        end
        
        if _bindActive("TriggerBotBind") then
            local tbDelay = (Flags["TriggerBotDelay"] or 0) / 1000
            local reqTarget = Flags["TriggerBotRequireTarget"]
            if reqTarget == nil then reqTarget = true end
            
            local canTrigger = false
            if reqTarget then
                if currentTarget then
                    canTrigger = true
                else
                    local mousePos = UserInputService:GetMouseLocation()
                    local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.FilterDescendantsInstances = {lp.Character}
                    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
                    if result and result.Instance then
                        local char = result.Instance:FindFirstAncestorOfClass("Model")
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local plr = Players:GetPlayerFromCharacter(char)
                                if plr and plr ~= lp then
                                    local isWhitelisted = _plWhitelist and _plWhitelist[plr]
                                    if not isWhitelisted then
                                        canTrigger = true
                                    end
                                else
                                    local bot = getNPCs()
                                    for _, b in ipairs(bot) do
                                        if b == char then
                                            canTrigger = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                canTrigger = true
            end
            
            if canTrigger then
                _G.lastTriggerClick = _G.lastTriggerClick or 0
                if tick() - _G.lastTriggerClick >= tbDelay then
                    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        _G.lastTriggerClick = tick()
                    end
                end
            end
        end
        if Flags["TargetHUD"] and Library.TargetHUDObj then
            local hudTarget = currentTarget
            if not hudTarget or not hudTarget.Parent then
                hudTarget = _lockedTarget
            end
            if hudTarget and hudTarget.Parent then
                if hudTarget:IsA("Player") then
                    Library.TargetHUDObj:SetTarget(hudTarget)
                elseif hudTarget:IsA("Model") and hudTarget.Parent then
                    local plr = Players:GetPlayerFromCharacter(hudTarget)
                    if plr then
                        Library.TargetHUDObj:SetTarget(plr)
                    else
                        Library.TargetHUDObj:SetTarget(hudTarget)
                    end
                else
                    Library.TargetHUDObj:SetTarget(hudTarget)
                end
            else
                if Library.TargetHUDObj.Items and Library.TargetHUDObj.Items['Container'] then
                    Library.TargetHUDObj.Items['Container'].Visible = false
                end
            end
        elseif Library.TargetHUDObj then
            if Library.TargetHUDObj.Items and Library.TargetHUDObj.Items['Container'] then
                Library.TargetHUDObj.Items['Container'].Visible = false
            end
        end
    end)))
end
_trackConn(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if Flags["TargetTracer"] and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetChar = currentTarget.Character
        local startPos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
        if Flags["TargetTracerStart"] == "Top" then
            startPos = Vector2.new(camera.ViewportSize.X/2, 0)
        elseif Flags["TargetTracerStart"] == "Cursor" then
            local mousePos = UserInputService:GetMouseLocation()
            startPos = Vector2.new(mousePos.X, mousePos.Y)
        end
        
        local endPart = targetChar:FindFirstChild("HumanoidRootPart")
        if Flags["TargetTracerEnd"] == "Head" and targetChar:FindFirstChild("Head") then
            endPart = targetChar.Head
        elseif Flags["TargetTracerEnd"] == "Feet" then
            endPart = targetChar:FindFirstChild("RightFoot") or targetChar:FindFirstChild("Right Leg") or endPart
        end
        
        if endPart then
            local pos, onScreen = camera:WorldToViewportPoint(endPart.Position)
            if onScreen then
                targetTracer.From = startPos
                targetTracer.To = Vector2.new(pos.X, pos.Y)
                targetTracer.Color = C.TargetTracer or Color3.new(1,0,0)
                targetTracer.Transparency = (Flags["TargetTracerAlpha"] or 100) / 100
                targetTracer.Visible = true
                
                targetTracerOut.From = startPos
                targetTracerOut.To = Vector2.new(pos.X, pos.Y)
                targetTracerOut.Color = C.TargetTracerOut or Color3.new(0,0,0)
                targetTracerOut.Transparency = (Flags["TargetTracerOutAlpha"] or 100) / 100
                targetTracerOut.Visible = true
            else
                targetTracer.Visible = false
                targetTracerOut.Visible = false
            end
        else
            targetTracer.Visible = false
            targetTracerOut.Visible = false
        end
    else
        targetTracer.Visible = false
        targetTracerOut.Visible = false
    end
end)))
task.spawn(function()
    local function clearCustomTextures(p)
        for _, child in ipairs(p:GetChildren()) do
            if child:IsA("Texture") and child.name = = "_CustMatTexture" then
                pcall(function() child:Destroy() end)
            end
        end
    end

    local lastM, lastA, lastC, lastClr = "", "", false, nil
    local wasOn = false
    while _scriptRunning and task.wait(3) do
        (function()
        local CustMat = Flags["CustMat"]
        local m = Flags["MatType"] or "None"
        if m == "None" then
            CustMat = false
            if Flags["MatClr"] then
                Flags["MatClr"] = false
            end
        end
        if CustMat then
            wasOn = true
            local a = Flags["MatApply"] or "All Parts"
            local c = Flags["MatClr"] or false
            local clr = getColor("c_mat", Color3.new(1,1,1))
            if m ~= lastM or a ~= lastA or c ~= lastC or clr ~= lastClr then
                for p, orig in pairs(originalPartMaterials) do
                    pcall(function()
                        if p and p.Parent then
                            p.Material = orig.Material
                            p.Color = orig.Color
                            clearCustomTextures(p)
                        end
                    end)
                end
                originalPartMaterials = setmetatable({}, { __mode = "k" })
                lastM, lastA, lastC, lastClr = m, a, c, clr
                
                local isMinecraft = false
                local texId = nil
                local realMatName, packname = m:match("^([%w]+) %(([%w]+)%)$")
                if packName and packName:lower() == "minecraft" then
                    isMinecraft = true
                    if texture_packs.minecraft[realMatName] then
                        texId = texture_packs.minecraft[realMatName]
                    end
                end

                local matE = Enum.Material.Granite
                pcall(function()
                    matE = Enum.Material[m]
                end)
                local playersList = Players:GetPlayers()
                local charSet = {}
                for _, pl in ipairs(playersList) do
                    if pl.Character then charSet[pl.Character] = true end
                end
                for _, p in ipairs(workspace:GetDescendants()) do
                    if p:IsA("BasePart") and not p:IsDescendantOf(workspace.CurrentCamera) then
                        local lowername = p.Name:lower()
                        local isChar = false
                        local ancestor = p:FindFirstAncestorOfClass("Model")
                        if ancestor and ancestor:FindFirstChildOfClass("Humanoid") then
                            isChar = true
                        end
                        if not isChar then
                            for charModel in pairs(charSet) do
                                if p:IsDescendantOf(charModel) then
                                    isChar = true
                                    break
                                end
                            end
                        end
                        if not isChar and p.Transparency < 0.9 and not lowerName:find("sky") and not lowerName:find("invis") and not lowerName:find("barrier") and not lowerName:find("cloud") then
                            local ok = false
                            if a == "All Parts" then ok = true
                            elseif a == "MeshParts" and p:IsA("MeshPart") then ok = true
                            elseif a == "BaseParts" and p.Classname = = "Part" then ok = true
                            elseif a == "Wedges" and p:IsA("WedgePart") then ok = true
                            elseif a == "Cylinders" and p:IsA("Part") and p.Shape == Enum.PartType.Cylinder then ok = true end
                            if ok then
                                if not originalPartMaterials[p] then
                                    originalPartMaterials[p] = { Material = p.Material, Color = p.Color }
                                end
                                if isMinecraft and texId then
                                    clearCustomTextures(p)
                                    p.Material = Enum.Material.SmoothPlastic
                                    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                                        local tex = Instance.new("Texture")
                                        tex.name = "_CustMatTexture"
                                        tex.Texture = texId
                                        tex.Face = face
                                        tex.Parent = p
                                    end
                                else
                                    clearCustomTextures(p)
                                    p.Material = matE
                                end
                                if c then p.Color = clr end
                            end
                        end
                    end
                end
            end
        else
            if wasOn then
                wasOn = false
                lastM, lastA, lastC, lastClr = "", "", false, nil
                for p, orig in pairs(originalPartMaterials) do
                    pcall(function()
                        if p and p.Parent then
                            p.Material = orig.Material
                            p.Color = orig.Color
                            clearCustomTextures(p)
                        end
                    end)
                end
                originalPartMaterials = setmetatable({}, { __mode = "k" })
            end
        end
    end)()
end
end)


