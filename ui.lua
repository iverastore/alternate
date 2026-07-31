if not LPH_OBFUSCATED then
    getgenv()["LPH_NO_" .. "VIRTUALIZE"] = function(f) return f end
    getgenv()["LPH_J" .. "IT"] = function(f) return f end
    getgenv()["LPH_J" .. "IT_MAX"] = function(f) return f end
end
pcall(function() if setfpscap then setfpscap(9999) end end)
Library = nil
hasCheck = LPH_NO_VIRTUALIZE(function(tbl, val)
    if type(tbl) ~= "table" then return false end
    if tbl[val] ~= nil then return true end
    return table.find(tbl, val) ~= nil
end)

getNPCs = LPH_NO_VIRTUALIZE(function()
    local botsFolder = workspace:FindFirstChild("Bots")
    if botsFolder then
        return botsFolder:GetChildren()
    end
    return {}
end)

clearWeatherObjects = nil
_origBrightness, _origOutdoorAmbient = nil, nil
_origAtmoDensity, _origAtmoOffset, _origAtmoGlare, _origAtmoHaze = nil, nil, nil, nil
_origSunSize, _origMoonSize, _origStarCount, _origSunRaysEnabled = nil, nil, nil, nil
originalPartMaterials = setmetatable({}, { __mode = "k" })
CoreGui = game:GetService("CoreGui")

local _uiFetchOk, _uiFetchErr = pcall(function()
    library, notifications, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/iverastore/alternate/refs/heads/main/ui.lua?cb=" .. tostring(tick())))()
end)
if not _uiFetchOk or not library then
    warn("[alternate] Failed to load UI library: " .. tostring(_uiFetchErr))
    return
end

dim2 = UDim2.new 
hex = Color3.fromHex 

_menuVisible = true
window = library:window({
    name = os.date('alternate.lol | %b %d %Y'),
    size = dim2(0, 516, 0, 563)
})  

TargetHud = library:targetHud({})
KeybindList = library:keybindList({})

CombatPage = window:tab({name = "Combat"})
VisualsPage = window:tab({name = "Visuals"})
MiscPage = window:tab({name = "Misc"})
SetPageObelus = window:tab({name = "Settings"})

Tabs = {
    Aimbot = CombatPage:subtab({name = "Aimbot"}),
    Silent = CombatPage:subtab({name = "Silent"}),
    AimbotPlus = CombatPage:subtab({name = "Aimbot+"}),
    VisualsMain = VisualsPage:subtab({name = "ESP/Chams/Effects"}),
    World = VisualsPage:subtab({name = "World"}),
    Movement = MiscPage:subtab({name = "Misc"}),
    MiscPlus = MiscPage:subtab({name = "Playerlist"}),
    SettingsMain = SetPageObelus:subtab({name = "Main"})
}

Cols = {}
getCol = function(subtab, side)
    if not Cols[subtab] then Cols[subtab] = {} end
    if not Cols[subtab][side] then
        Cols[subtab][side] = subtab:column({fill = true})
    end
    return Cols[subtab][side]
end

Secs = {}
getSec = function(subtab, side, name)
    local col = getCol(subtab, side)
    local key = tostring(col) .. name
    if not Secs[key] then
        Secs[key] = col:section({name = name})
    end
    return Secs[key]
end

Map = {
    ["Aimbot"] = { tab = Tabs.Aimbot, side = 1, name = "Aimbot" },
    ["Silent"] = { tab = Tabs.Silent, side = 1, name = "Silent Aim" },
    ["Main"] = { tab = Tabs.Aimbot, side = 2, name = "Target / Main" },
    ["AimbotSettings"] = { tab = Tabs.AimbotPlus, side = 1, name = "Settings" },
    ["Settings"] = { tab = Tabs.SettingsMain, side = 2, name = "Settings" },
    ["Aimbot+"] = { tab = Tabs.AimbotPlus, side = 2, name = "Aimbot+" },
    ["ESP"] = { tab = Tabs.VisualsMain, side = 1, name = "ESP" },
    ["Chams"] = { tab = Tabs.VisualsMain, side = 2, name = "Chams" },
    ["Effects"] = { tab = Tabs.VisualsMain, side = 2, name = "Effects" },
    ["Lighting"] = { tab = Tabs.World, side = 1, name = "Lighting" },
    ["Weather"] = { tab = Tabs.World, side = 1, name = "Weather" },
    ["Skybox"] = { tab = Tabs.World, side = 2, name = "Skybox" },
    ["Materials"] = { tab = Tabs.World, side = 2, name = "Materials" },
    ["Misc"] = { tab = Tabs.Movement, side = 1, name = "Movement" },
    ["MiscRight"] = { tab = Tabs.Movement, side = 2, name = "Triggerbot / Skins" },
    ["Avatar"] = { tab = Tabs.Movement, side = 2, name = "Avatar" },

    ["All Players"] = { tab = Tabs.MiscPlus, side = 1, name = "Player List" },
    ["Player Info"] = { tab = Tabs.MiscPlus, side = 2, name = "Actions" },
    ["Configs"] = { tab = Tabs.SettingsMain, side = 1, name = "Configs" },
    ["Menu"] = { tab = Tabs.SettingsMain, side = 2, name = "Menu" },
    ["Notifications"] = { tab = Tabs.SettingsMain, side = 2, name = "Notifications" },
    ["Themes"] = { tab = Tabs.SettingsMain, side = 2, name = "Themes" },
}

Flags = library.flags

wrapWidget = function(widget)
    widget.SetVisibility = function(self, state)
        pcall(function()
            if self.__ui then
                self.__ui.Visible = state
            elseif self.visible then
                self:visible(state)
            end
        end)
    end
    return widget
end

wrapSection = function(secName)
    local mapping = Map[secName] or { tab = Tabs.Aimbot, side = 1, name = secName }
    local sec = getSec(mapping.tab, mapping.side, mapping.name)
    local wrapper = { items = sec }
    
    function wrapper:Toggle(opts)
        local t = sec:addToggle({name = opts.Name, flag = opts.Flag, default = opts.Default, callback = opts.Callback})
        if not t then return { Colorpicker = function() return {} end, Keybind = function() return {} end, SetVisibility = function() end } end
        local w = wrapWidget(t)
        function w:Keybind(kopts)
            t:addKeyBind({name = kopts.Name or opts.Name, flag = kopts.Flag, key = kopts.Key, default = kopts.Default, mode = kopts.Mode, callback = kopts.Callback})
            return w
        end
        function w:Colorpicker(copts)
            t:addColorPicker({flag = copts.Flag, color = copts.Default, callback = copts.Callback})
            return w
        end
        return w
    end
    
    function wrapper:Slider(opts)
        local s = sec:addSlider({name = opts.Name, flag = opts.Flag, min = opts.Min, max = opts.Max, default = opts.Default, callback = opts.Callback})
        return wrapWidget(s or {})
    end
    
    function wrapper:Dropdown(opts)
        local d = sec:addDropdown({name = opts.Name, flag = opts.Flag, items = opts.Items, default = opts.Default, multi = opts.Multi, callback = opts.Callback})
        return wrapWidget(d or {})
    end
    
    function wrapper:Colorpicker(opts)
        local c = sec:addColorPicker({name = opts.Name, flag = opts.Flag, color = opts.Default, callback = opts.Callback})
        return wrapWidget(c or {})
    end
    
    function wrapper:Keybind(opts)
        local k = sec:addKeyBind({name = opts.Name, flag = opts.Flag, key = opts.Key, default = opts.Default, mode = opts.Mode, callback = opts.Callback})
        return wrapWidget(k or {})
    end
    
    function wrapper:Button(opts)
        local b = sec:addButton({name = opts.Name, callback = opts.Callback})
        if not b then return wrapWidget({}) end
        local w = wrapWidget(b)
        w.items = { button = b.__ui, object = b.__ui }
        return w
    end
    
    function wrapper:Label(opts)
        local l = sec:addLabel({name = opts.Name})
        if not l then return { Keybind = function() return {} end, SetVisibility = function() end } end
        local w = wrapWidget(l)
        function w:Keybind(kopts)
            l:addKeyBind({name = kopts.Name or opts.Name, flag = kopts.Flag, key = kopts.Key, default = kopts.Default, mode = kopts.Mode, callback = kopts.Callback})
            return w
        end
        function w.set(text)
            pcall(function()
                if l.__ui then
                    local lc = l.__ui:FindFirstChildOfClass("Frame")
                    if lc then
                        for _, child in ipairs(lc:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.Text = text
                                break
                            end
                        end
                    end
                end
            end)
        end
        return w
    end
    
    function wrapper:Textbox(opts)
        local b = sec:addTextBox({name = opts.Name, flag = opts.Flag, default = opts.Default, placeholder = opts.Placeholder or "config name", callback = opts.Callback})
        local w = wrapWidget(b or {})
        -- expose a .set(text) method to programmatically update the text value
        function w.set(text)
            if opts.Flag and Flags then
                Flags[opts.Flag] = text
            end
            pcall(function()
                if b and b.__ui then
                    local frame = b.__ui:FindFirstChildOfClass("Frame") or b.__ui
                    for _, child in ipairs(frame:GetDescendants()) do
                        if child:IsA("TextBox") then
                            child.Text = tostring(text)
                            break
                        end
                    end
                end
            end)
        end
        return w
    end
    
    return wrapper
end

LegacyWindow = {}
function LegacyWindow:Page(opts)
    local pageWrapper = {}
    function pageWrapper:Section(sopts) return wrapSection(sopts.Name) end
    function pageWrapper:MultiSection(mopts)
        local msWrapper = {}
        function msWrapper:Add(name) return wrapSection(name) end
        function msWrapper:Select(name) end
        return msWrapper
    end
    return pageWrapper
end

Window = LegacyWindow

Library = {
    Watermark = function(self, opts) 
        local wm = library:watermark({ name = (opts and opts.Name) or "alternate.lol" }) 
        return { SetVisibility = function(self, v) wm.Visible = v end }
    end,
    TargetHUD = function() return { SetVisibility = function(self, v) TargetHud:SetVisibility(v) end, SetTarget = function(self, t) TargetHud:SetTarget(t) end, Update = function(self) TargetHud:Update() end, Items = TargetHud.Items } end,
    KeybindList = function() return { SetVisibility = function(self, v) KeybindList.Visible = v end } end,
    PlayerList = function(opts) return nil end,
    ChangeTheme = function(self, key, color)
        if typeof(color) ~= "Color3" then return end
        pcall(function()
            if type(key) == "table" then
                for _, k in ipairs(key) do
                    self:ChangeTheme(k, color)
                end
                return
            end
            local themeMap = {
                ["Accent"] = "accent", ["accent"] = "accent",
                ["Background"] = "background", ["background"] = "background",
                ["Text"] = "text", ["text"] = "text", ["Main"] = "text",
                ["Text Outline"] = "text_outline", ["text_outline"] = "text_outline",
                ["Element"] = "element", ["element"] = "element",
                ["Element 2"] = "element2", ["element2"] = "element2",
                ["Outline"] = "outline", ["outline"] = "outline", ["Borders"] = "outline",
                ["Inline"] = "inline", ["inline"] = "inline",
                ["Hovered Element"] = "hover", ["hover"] = "hover",
                ["Unselected"] = "unselected", ["unselected"] = "unselected",
                ["Border"] = "border", ["border"] = "border",
                ["Glow"] = "glow", ["glow"] = "glow",
            }
            local mapped = themeMap[key]
            if mapped then
                library:updateTheme(mapped, color)
            end
        end)
    end,
    set_element_scale = function(self, scale)
        pcall(function()
            if library and library.set_element_scale then
                library:set_element_scale(scale)
            end
        end)
    end,
    Notify = function(self, msg, dur)
        pcall(function()
            notifications:create_notification({name = tostring(msg), duration = dur or Library.NotifSettings and Library.NotifSettings.Duration or 3})
        end)
    end,
    NotifSettings = { Duration = 3, Type = "Full", Animation = "Slide", Position = "Top Right" },
    SetFlags = library.config_flags,
    convert_enum = function(self, str)
        local ok, result = pcall(function()
            local parts = {}
            for part in str:gmatch("[^.]+") do table.insert(parts, part) end
            if #parts >= 3 then
                local enum = Enum[parts[2]]
                if enum then
                    return enum[parts[3]]
                end
            end
            return nil
        end)
        return ok and result or nil
    end,
    Flags = Flags
}

library.NotifSettings = Library.NotifSettings
pcall(function()
    local _bw = {
        Accent=Color3.fromRGB(255,255,255), BG=Color3.fromRGB(0,0,0),
        Text=Color3.fromRGB(255,255,255), Out=Color3.fromRGB(30,30,30),
        Inline=Color3.fromRGB(10,10,10), Elem=Color3.fromRGB(20,20,20),
        Elem2=Color3.fromRGB(35,35,35), Hover=Color3.fromRGB(45,45,45),
        Unsel=Color3.fromRGB(120,120,120), Border=Color3.fromRGB(0,0,0)
    }
    Library:ChangeTheme("Accent", _bw.Accent)
    Library:ChangeTheme("Background", _bw.BG)
    Library:ChangeTheme("Text", _bw.Text)
    Library:ChangeTheme("Outline", _bw.Out)
    Library:ChangeTheme("Inline", _bw.Inline)
    Library:ChangeTheme("Element", _bw.Elem)
    Library:ChangeTheme("Element 2", _bw.Elem2)
    Library:ChangeTheme("Hovered Element", _bw.Hover)
    Library:ChangeTheme("Unselected", _bw.Unsel)
    Library:ChangeTheme("Border", _bw.Border)
end)

Flags = Library.Flags
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Lighting = game:GetService("Lighting")
TweenService = game:GetService("TweenService")
GuiService = game:GetService("GuiService")


getOrCreateCC = LPH_NO_VIRTUALIZE(function()
    local cc = Lighting:FindFirstChild("_AlternateCC")
    if not cc or not cc:IsA("ColorCorrectionEffect") then
        if cc then pcall(function() cc:Destroy() end) end
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "_AlternateCC"
        cc.Parent = Lighting
    end
    cc.Enabled = true
    return cc
end)
getOrCreateAtmo = LPH_NO_VIRTUALIZE(function()
    local a = Lighting:FindFirstChildOfClass("Atmosphere")
    if a then return a end
    a = Lighting:FindFirstChild("_AlternateAtmo")
    if not a or not a:IsA("Atmosphere") then
        if a then pcall(function() a:Destroy() end) end
        a = Instance.new("Atmosphere")
        a.Name = "_AlternateAtmo"
        a.Parent = Lighting
    end
    return a
end)
lp = Players.LocalPlayer
camera = workspace.CurrentCamera
_connections = {}
_scriptRunning = true
_lockedTarget = nil
_plWhitelistLocal = nil
_trackConn = function(c) if c then table.insert(_connections, c) end; return c end
_bindCache = {}
_bindActive = LPH_JIT(function(bindFlag)
    local toggleFlag = _bindCache[bindFlag]
    if not toggleFlag then
        toggleFlag = bindFlag:gsub("Bind$", "Enabled")
        _bindCache[bindFlag] = toggleFlag
    end
    if Flags[toggleFlag] == false then return false end
    local b = Flags[bindFlag]
    if not b then return Flags[toggleFlag] == true end
    local keyStr = tostring(b.Key)
    if b.Key == "Enum.KeyCode.Unknown" or b.Key == nil or b.Key == "None" or keyStr:match("Unknown") or keyStr == "" then
        return false
    end
    return b.Toggled == true
end)

isDaTrack = table.find({72815132775027, 75159825516372, 90724401598574}, game.PlaceId) ~= nil
isHoodCustoms = table.find({9825515356, 11241892119, 80567999110374, 138995385694035}, game.PlaceId) ~= nil
isWarlords = game.PlaceId == 132582765993181
formatAssetId = function(id)
    if not id or id == "" then return "" end
    if typeof(id) == "number" or tostring(id):match("^%d+$") then
        return "rbxassetid://" .. id
    end
    return id
end
_originalToolProperties = setmetatable({}, {__mode = "k"})
cacheOriginalSkin = LPH_NO_VIRTUALIZE(function(tool)
    if _originalToolProperties[tool] then return end
    local cached = {}
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:IsA("SpecialMesh") then
            cached[desc] = {
                TextureId = desc.TextureId,
                MeshId = desc.MeshId,
                VertexColor = desc.VertexColor
            }
        elseif desc:IsA("MeshPart") then
            cached[desc] = {
                TextureID = desc.TextureID,
                MeshId = desc.MeshId,
                Color = desc.Color,
                Material = desc.Material,
                Transparency = desc.Transparency
            }
        elseif desc:IsA("BasePart") then
            cached[desc] = {
                Color = desc.Color,
                Material = desc.Material,
                Transparency = desc.Transparency
            }
        end
    end
    _originalToolProperties[tool] = cached
end)
restoreOriginalSkin = LPH_NO_VIRTUALIZE(function(tool)
    local cached = _originalToolProperties[tool]
    if cached then
        for desc, props in pairs(cached) do
            if desc:IsA("SpecialMesh") then
                desc.TextureId = props.TextureId
                desc.MeshId = props.MeshId
                desc.VertexColor = props.VertexColor
            elseif desc:IsA("MeshPart") then
                desc.TextureID = props.TextureID
                desc.MeshId = props.MeshId
                desc.Color = props.Color
                desc.Material = props.Material
                desc.Transparency = props.Transparency
            elseif desc:IsA("BasePart") then
                desc.Color = props.Color
                desc.Material = props.Material
                desc.Transparency = props.Transparency
            end
        end
    end
    local hadScrollTex = false
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc.Name == "_SkinParticle" or desc.Name == "_OverridePart" or desc.Name == "_ScrollTex" then
            if desc.Name == "_ScrollTex" then hadScrollTex = true end
            if desc.Parent then desc:Destroy() end
        end
    end
    if hadScrollTex then
        _scrollTexTextures = nil
        _scrollTexCachedTool = nil
        _scrollTexCachedSkin = nil
    end
    local h = tool:FindFirstChild("Handle")
    if h and h:IsA("BasePart") then
        local cached = _originalToolProperties[tool]
        if cached and cached[h] then
            h.Transparency = cached[h].Transparency or 0
        else
            h.Transparency = 0
        end
    end
end)
Library.WatermarkObj = Library:Watermark({ Name = "alternate.lol" })
Library.TargetHUDObj = Library:TargetHUD({})
Library.KeyList = Library:KeybindList({})
pcall(function()
    Library.PlayerListObj = Library:PlayerList({
        OnTeleport = function(player)
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end,
        OnSpectate = function(player)
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid") or player.Character.HumanoidRootPart
            end
        end,
        OnWhitelist = function(player)
            if _plWhitelistLocal[player] then
                _plWhitelistLocal[player] = nil
            else
                _plWhitelistLocal[player] = true
            end
        end,
        OnTarget = function(player)
            if _lockedTarget == player then
                _lockedTarget = nil
            else
                _lockedTarget = player
            end
        end
    })
end)
C = {
    Fog = Color3.fromRGB(128,128,128),
    FOV = Color3.new(1,1,1), FOVOut = Color3.new(0,0,0), FOVFill = Color3.new(1,1,1),
    TargetTracer = Color3.new(1,0,0), TargetTracerOut = Color3.new(0,0,0),
    ChinaHatColor = Color3.fromRGB(255,255,255), ChinaHatLightColor = Color3.fromRGB(255,255,255),
    CharMaterialColor = Color3.fromRGB(155,125,175), ToolMaterialColor = Color3.fromRGB(155,125,175),
    SilentFOV = Color3.new(1,1,1), SilentFOVOut = Color3.new(0,0,0), SilentFOVFill = Color3.new(1,1,1),
}
MATERIAL_LIST = {"ForceField","Neon","Plastic","SmoothPlastic","Wood","WoodPlanks","Marble","Slate","Concrete","Granite","Brick","Pebble","Cobblestone","Rock","DiamondPlate","Metal","CorrodedMetal","Foil","Grass","Sand","Fabric","Ice","Glass","Asphalt","LeafyGrass","Salt","Snow","Mud","Ground","Basalt","CrackedLava"}
getMaterialEnum = function(name)
    for _, m in ipairs(Enum.Material:GetEnumItems()) do
        if m.Name == name then return m end
    end
    return Enum.Material.Neon
end
selfChamsHL = nil
wepChamsHL = nil
Skyboxes = {
    Piss={Up="rbxassetid://2651437350",Rt="rbxassetid://2651436979",Lf="rbxassetid://2651436494",Ft="rbxassetid://2651435990",Bk="rbxassetid://2651432901",Dn="rbxassetid://2651434974"},
    Space={Up="rbxassetid://15983964246",Rt="rbxassetid://15983966246",Lf="rbxassetid://15983967420",Ft="rbxassetid://15983965025",Bk="rbxassetid://15983968922",Dn="rbxassetid://15983966825"},
    Dark={Up="rbxassetid://15470160563",Rt="rbxassetid://15470158022",Lf="rbxassetid://15470155938",Ft="rbxassetid://15470153860",Bk="rbxassetid://15470149279",Dn="rbxassetid://15470151245"},
    ["Space V2"]={Up="rbxassetid://16262366016",Rt="rbxassetid://16262363873",Lf="rbxassetid://16262362003",Ft="rbxassetid://16262360469",Bk="rbxassetid://16262356578",Dn="rbxassetid://16262358026"},
    Pink={Up="rbxassetid://12635316856",Rt="rbxassetid://12635315817",Lf="rbxassetid://12635313718",Ft="rbxassetid://12635312870",Bk="rbxassetid://12635309703",Dn="rbxassetid://12635311686"},
    Forest={Up="rbxassetid://237593929",Rt="rbxassetid://237593835",Lf="rbxassetid://237593861",Ft="rbxassetid://237593922",Bk="rbxassetid://237593887",Dn="rbxassetid://237593849"},
    Night={Up="rbxassetid://154185031",Rt="rbxassetid://154184972",Lf="rbxassetid://154184943",Ft="rbxassetid://154185021",Bk="rbxassetid://154185004",Dn="rbxassetid://154184960"},
    Lava={Up="rbxassetid://4776130793",Rt="rbxassetid://4776133150",Lf="rbxassetid://4776128425",Ft="rbxassetid://4776131365",Bk="rbxassetid://4776124334",Dn="rbxassetid://4776125375"},
    Rainy={Up="rbxassetid://4495867486",Rt="rbxassetid://4495866584",Lf="rbxassetid://4495866035",Ft="rbxassetid://4495865458",Bk="rbxassetid://4495864450",Dn="rbxassetid://4495864887"},
    Green={Up="rbxassetid://566611218",Rt="rbxassetid://566611300",Lf="rbxassetid://566611266",Ft="rbxassetid://566611142",Bk="rbxassetid://566611187",Dn="rbxassetid://566613198"},
    Nebulous={Up="rbxassetid://131036626982613",Rt="rbxassetid://103716549795832",Lf="rbxassetid://126542804346203",Ft="rbxassetid://107665368823185",Bk="rbxassetid://95020137072033",Dn="rbxassetid://92862258103959"},
    ["Blue Clouds"]={Lf="rbxassetid://113877479719528",Dn="rbxassetid://79704090322682",Up="rbxassetid://83295215834464",Bk="rbxassetid://130432680623409",Rt="rbxassetid://84246762168898",Ft="rbxassetid://114966033937119"},
    ["Candy Floss"]={Bk="rbxassetid://103994796436499",Dn="rbxassetid://88135141884296",Ft="rbxassetid://71705651078185",Lf="rbxassetid://83560072752341",Rt="rbxassetid://96879039628172",Up="rbxassetid://131043401069407"},
    ["Green Skies"]={Up="rbxassetid://11941773718",Rt="rbxassetid://11941774042",Lf="rbxassetid://11941774369",Ft="rbxassetid://11941774655",Dn="rbxassetid://11941774975",Bk="rbxassetid://11941775243"},
    ["White Skies"]={Up="rbxassetid://14638329084",Rt="rbxassetid://14627242578",Lf="rbxassetid://14627253604",Ft="rbxassetid://14627298624",Dn="rbxassetid://14638334572",Bk="rbxassetid://14627238543"},
    ["Blood Red"]={Bk="rbxassetid://108929045660200",Dn="rbxassetid://78646480540009",Ft="rbxassetid://90546017435179",Lf="rbxassetid://109838453114563",Rt="rbxassetid://94190734796082",Up="rbxassetid://126944775797063"},
    ["Scary"]={Up="rbxassetid://48020383",Rt="rbxassetid://48020254",Lf="rbxassetid://48020211",Ft="rbxassetid://48020234",Bk="rbxassetid://48020371",Dn="rbxassetid://48020144"},
    ["Realistic Day"]={Up="rbxassetid://15502526102",Rt="rbxassetid://15502523711",Lf="rbxassetid://15502522129",Ft="rbxassetid://15502524520",Bk="rbxassetid://15502525195",Dn="rbxassetid://15502522797"},
    ["Realistic Space"]={Up="rbxassetid://155441905",Rt="rbxassetid://155441874",Lf="rbxassetid://155441777",Ft="rbxassetid://155441818",Bk="rbxassetid://155441936",Dn="rbxassetid://155441802"},
    ["Classic"]={Up="rbxassetid://16960183792",Rt="rbxassetid://16960180775",Lf="rbxassetid://16960173960",Ft="rbxassetid://16960177173",Bk="rbxassetid://16960168607",Dn="rbxassetid://16960171251"},
    ["Sunset"]={Up="rbxassetid://541743441",Rt="rbxassetid://541743435",Lf="rbxassetid://541743436",Ft="rbxassetid://541743446",Bk="rbxassetid://541743453",Dn="rbxassetid://541743443"},
    ["HD Space"]={Up="rbxassetid://16876771721",Rt="rbxassetid://16876769447",Lf="rbxassetid://16876767659",Ft="rbxassetid://16876765234",Bk="rbxassetid://16876760844",Dn="rbxassetid://16876762818"},
    ["Cold Winter"]={Up="rbxassetid://5346761509",Rt="rbxassetid://5346761335",Lf="rbxassetid://5346761102",Ft="rbxassetid://5346760919",Bk="rbxassetid://5346760450",Dn="rbxassetid://5346760689"},
    ["Shiverfrost"]={Up="rbxassetid://11941773718",Rt="rbxassetid://11941774042",Lf="rbxassetid://11941774369",Ft="rbxassetid://11941774655",Bk="rbxassetid://11941775243",Dn="rbxassetid://11941774975"},
    ["Blue Nebula"]={Up="rbxassetid://88174897344210",Rt="rbxassetid://81731245279712",Lf="rbxassetid://72493016739936",Ft="rbxassetid://92947876187368",Bk="rbxassetid://135908594667929",Dn="rbxassetid://139584143501514"},
    ["Red Space"]={Up="rbxassetid://16563527042",Rt="rbxassetid://16563525361",Lf="rbxassetid://16563524305",Ft="rbxassetid://16563522248",Bk="rbxassetid://16563515269",Dn="rbxassetid://16563519063"},
    ["Green Clouds"]={Up="rbxassetid://921882259",Rt="rbxassetid://921881989",Lf="rbxassetid://921881811",Ft="rbxassetid://921882121",Bk="rbxassetid://921882045",Dn="rbxassetid://921881907"},
    ["Purple Clouds"]={Up="rbxassetid://17279864507",Rt="rbxassetid://17279862234",Lf="rbxassetid://17279860360",Ft="rbxassetid://17279858447",Bk="rbxassetid://17279854976",Dn="rbxassetid://17279856318"},
    ["Nibiru"]={Up="rbxassetid://16888795319",Rt="rbxassetid://16888793222",Lf="rbxassetid://16888791272",Ft="rbxassetid://16888789063",Bk="rbxassetid://16888782970",Dn="rbxassetid://16888785001"},
    ["Nebulae"]={Up="rbxassetid://15410066351",Rt="rbxassetid://15410065410",Lf="rbxassetid://15410064356",Ft="rbxassetid://15410062941",Bk="rbxassetid://15410060765",Dn="rbxassetid://15410061776"},
    ["Moody"]={Up="rbxassetid://16094726650",Rt="rbxassetid://16094722121",Lf="rbxassetid://16094718550",Ft="rbxassetid://16094725387",Bk="rbxassetid://16094723769",Dn="rbxassetid://16094720620"},
    ["Whistle"]={Up="rbxassetid://119554574473335",Rt="rbxassetid://73230217205735",Lf="rbxassetid://106597220421789",Ft="rbxassetid://134876166747769",Bk="rbxassetid://111497829836471",Dn="rbxassetid://85772401772303"},
    ["Crossroads"]={Up="http://www.roblox.com/asset/?id=144931564",Rt="http://www.roblox.com/asset/?id=144933299",Lf="http://www.roblox.com/asset/?id=144933244",Ft="http://www.roblox.com/asset/?id=144933262",Bk="http://www.roblox.com/asset/?id=144933338",Dn="http://www.roblox.com/asset/?id=144931530"},
    ["Abyss Blue"]={Up="rbxassetid://16269829700",Rt="rbxassetid://16269814948",Lf="rbxassetid://16269813852",Ft="rbxassetid://16269798011",Bk="rbxassetid://16269815885",Dn="rbxassetid://16269839652",Moon="rbxasset://sky/moon.jpg"},
    ["Red Castle Dark"]={Up="rbxassetid://15832429401",Rt="rbxassetid://15832431198",Lf="rbxassetid://15832430671",Ft="rbxassetid://15832430210",Bk="rbxassetid://15832429892",Dn="rbxassetid://15832430998"},
}
skyboxObj, originalSky = nil, nil
SkinData = {
    Purple = {
        Color = Color3.fromRGB(128, 0, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://95536417981530",
            ["[Double-Barrel SG]"] = "rbxassetid://95536417981530",
            ["[TacticalShotgun]"] = "rbxassetid://95536417981530",
        },
        BeamColor = Color3.fromRGB(128, 0, 255),
    },
    Red = {
        Color = Color3.fromRGB(255, 0, 0),
        Textures = {
            ["[Revolver]"] = "rbxassetid://82237815929149",
            ["[Double-Barrel SG]"] = "rbxassetid://95564445088276",
            ["[TacticalShotgun]"] = "rbxassetid://123985634348372",
        },
        BeamColor = Color3.fromRGB(255, 0, 0),
    },
    Green = {
        Color = Color3.fromRGB(0, 255, 0),
        Textures = {
            ["[Revolver]"] = "rbxassetid://132452748524027",
            ["[Double-Barrel SG]"] = "rbxassetid://102914992792464",
            ["[TacticalShotgun]"] = "rbxassetid://90365716305049",
        },
        BeamColor = Color3.fromRGB(0, 255, 0),
    },
    Blue = {
        Color = Color3.fromRGB(0, 100, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://73632510105038",
            ["[Double-Barrel SG]"] = "rbxassetid://85722433687063",
            ["[TacticalShotgun]"] = "rbxassetid://82790420203110",
        },
        BeamColor = Color3.fromRGB(0, 100, 255),
    },
    Grey = {
        Color = Color3.fromRGB(128, 128, 128),
        Textures = {
            ["[Revolver]"] = "rbxassetid://130234392575780",
            ["[Double-Barrel SG]"] = "rbxassetid://134238449133497",
            ["[TacticalShotgun]"] = "rbxassetid://111108079858916",
        },
        BeamColor = Color3.fromRGB(128, 128, 128),
    },
    Ghost = {
        Color = Color3.fromRGB(200, 200, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://130234392575780",
            ["[Double-Barrel SG]"] = "rbxassetid://134238449133497",
            ["[TacticalShotgun]"] = "rbxassetid://111108079858916",
        },
        Pulsate = true,
    },
    Rainbow = {
        Color = Color3.new(1, 1, 1),
        Textures = {
            ["[Revolver]"] = "",
            ["[Double-Barrel SG]"] = "",
            ["[TacticalShotgun]"] = "",
        },
        Rainbow = true,
        NeonRainbow = true,
    },
    Cosmic = {
        Color = Color3.fromRGB(100, 0, 200),
        Textures = {
            ["[Revolver]"] = "rbxassetid://70453478141305",
            ["[Double-Barrel SG]"] = "rbxassetid://70453478141305",
            ["[TacticalShotgun]"] = "rbxassetid://70453478141305",
        },
        CosmicCycle = true,
        CosmicBeams = {
            "rbxassetid://70453478141305",
            "rbxassetid://70453478141305",
            "rbxassetid://70453478141305",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://70453478141305",
            ["[Double-Barrel SG]"] = "rbxassetid://70453478141305",
            ["[TacticalShotgun]"] = "rbxassetid://70453478141305",
        },
        Particle = false,
        ParticleColor = Color3.fromRGB(150, 0, 255),
        ParticleTexture = "rbxassetid://6490035152",
        ParticleRate = 20,
        ParticleSize = NumberSequence.new(0.3, 0),
        ParticleLifetime = NumberRange.new(0.4, 0.8),
        ParticleSpeed = NumberRange.new(2, 5),
    },
    Sapphire = {
        Color = Color3.fromRGB(100, 150, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://138247911117407",
            ["[Double-Barrel SG]"] = "rbxassetid://72981459369871",
            ["[TacticalShotgun]"] = "rbxassetid://78406501322689",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://138247911117407",
            ["[Double-Barrel SG]"] = "rbxassetid://72981459369871",
            ["[TacticalShotgun]"] = "rbxassetid://78406501322689",
        },
    },
    Valedo = {
        Color = Color3.fromRGB(255, 200, 230),
        Textures = {
            ["[Revolver]"] = "rbxassetid://94709282192624",
            ["[Double-Barrel SG]"] = "rbxassetid://117891265755603",
            ["[TacticalShotgun]"] = "rbxassetid://81775658991326",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://94709282192624",
            ["[Double-Barrel SG]"] = "rbxassetid://117891265755603",
            ["[TacticalShotgun]"] = "rbxassetid://81775658991326",
        },
    },
    emrald = {
        Color = Color3.fromRGB(100, 255, 100),
        Textures = {
            ["[Revolver]"] = "rbxassetid://77712604897990",
            ["[Double-Barrel SG]"] = "rbxassetid://126084511022063",
            ["[TacticalShotgun]"] = "rbxassetid://93064864863244",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://77712604897990",
            ["[Double-Barrel SG]"] = "rbxassetid://126084511022063",
            ["[TacticalShotgun]"] = "rbxassetid://93064864863244",
        },
    },
    Angel = {
        Color = Color3.fromRGB(255, 80, 200),
        Textures = {
            ["[Revolver]"] = "rbxassetid://127027135533806",
            ["[Double-Barrel SG]"] = "rbxassetid://129105552219432",
            ["[TacticalShotgun]"] = "rbxassetid://87139157618738",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://127027135533806",
            ["[Double-Barrel SG]"] = "rbxassetid://129105552219432",
            ["[TacticalShotgun]"] = "rbxassetid://87139157618738",
        },
    },
    ["Dark Purple"] = {
        Color = Color3.fromRGB(60, 0, 120),
        Textures = {
            ["[Revolver]"] = "rbxassetid://85023957137765",
            ["[Double-Barrel SG]"] = "rbxassetid://130646532985970",
            ["[TacticalShotgun]"] = "rbxassetid://78130190379853",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://85023957137765",
            ["[Double-Barrel SG]"] = "rbxassetid://130646532985970",
            ["[TacticalShotgun]"] = "rbxassetid://78130190379853",
        },
    },
    RCB = {
        Color = Color3.fromRGB(255, 50, 50),
        Textures = {
            ["[Revolver]"] = "rbxassetid://138784517540755",
            ["[Double-Barrel SG]"] = "rbxassetid://121346737778397",
            ["[TacticalShotgun]"] = "rbxassetid://118141898855327",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://138784517540755",
            ["[Double-Barrel SG]"] = "rbxassetid://121346737778397",
            ["[TacticalShotgun]"] = "rbxassetid://118141898855327",
        },
    },
    Myosotis = {
        Color = Color3.fromRGB(200, 240, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://107252330426982",
            ["[Double-Barrel SG]"] = "rbxassetid://70406142516939",
            ["[TacticalShotgun]"] = "rbxassetid://140505054011299",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://107252330426982",
            ["[Double-Barrel SG]"] = "rbxassetid://70406142516939",
            ["[TacticalShotgun]"] = "rbxassetid://140505054011299",
        },
    },
    ["Axe Red"] = {
        Color = Color3.fromRGB(120, 0, 0),
        Textures = {
            ["[Revolver]"] = "rbxassetid://135143095360308",
            ["[Double-Barrel SG]"] = "rbxassetid://102174836088704",
            ["[TacticalShotgun]"] = "rbxassetid://72658192453064",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://135143095360308",
            ["[Double-Barrel SG]"] = "rbxassetid://102174836088704",
            ["[TacticalShotgun]"] = "rbxassetid://72658192453064",
        },
    },
    miku = {
        Color = Color3.fromRGB(255, 0, 127),
        Textures = {
            ["[Revolver]"] = "rbxassetid://85023957137765",
            ["[Double-Barrel SG]"] = "rbxassetid://130646532985970",
            ["[TacticalShotgun]"] = "rbxassetid://78130190379853",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://85023957137765",
            ["[Double-Barrel SG]"] = "rbxassetid://130646532985970",
            ["[TacticalShotgun]"] = "rbxassetid://78130190379853",
        },
        Particle = true,
        ParticleColor = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0.494118)),
            ColorSequenceKeypoint.new(0.487889, Color3.new(0, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0.494118))
        }),
        ParticleTexture = "rbxassetid://137954690905022",
        ParticleRate = 3,
        ParticleSize = NumberSequence.new(0.2, 0),
        ParticleLifetime = NumberRange.new(0.5, 1),
        ParticleSpeed = NumberRange.new(1, 3),
    },
    ["Ying Yang"] = {
        Color = Color3.fromRGB(255, 255, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://87900901146320",
            ["[Double-Barrel SG]"] = "rbxassetid://136604569632577",
            ["[TacticalShotgun]"] = "rbxassetid://80289073935248",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://87900901146320",
            ["[Double-Barrel SG]"] = "rbxassetid://136604569632577",
            ["[TacticalShotgun]"] = "rbxassetid://80289073935248",
        },
    },
    Yellow = {
        Color = Color3.fromRGB(255, 255, 0),
        Textures = {
            ["[Revolver]"] = "rbxassetid://94483221458963",
            ["[Double-Barrel SG]"] = "rbxassetid://97689623331490",
            ["[TacticalShotgun]"] = "rbxassetid://131211521153560",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://87900901146320",
            ["[Double-Barrel SG]"] = "rbxassetid://136604569632577",
            ["[TacticalShotgun]"] = "rbxassetid://80289073935248",
        },
    },
    Default = {
        Color = Color3.fromRGB(142, 97, 255),
        Textures = {
            ["[Revolver]"] = "rbxassetid://113408246543185",
            ["[Double-Barrel SG]"] = "rbxassetid://88315509598726",
            ["[TacticalShotgun]"] = "rbxassetid://125005095542809",
        },
    },
    ["Devilish"] = {
        Color = Color3.fromRGB(180, 20, 20),
        AltMesh = true,
        NoNeon = true,
        MeshIds = {
            ["[Revolver]"] = "rbxassetid://8117329945",
        },
        Textures = {
            ["[Revolver]"] = "rbxassetid://110656161046445",
        },
        BeamColorSequence = ColorSequence.new(Color3.fromRGB(120, 0, 0)),
        Particle = true,
        ParticleColor = Color3.fromRGB(180, 20, 20),
        ParticleTexture = "rbxassetid://6490035152",
        ParticleRate = 100,
        ParticleSize = NumberSequence.new(0.08, 0),
        ParticleLifetime = NumberRange.new(0.2, 0.5),
        ParticleSpeed = NumberRange.new(1, 3),
        RevolverOnly = true,
    },
    ["Blue Wave"] = {
        Color = Color3.fromRGB(0, 80, 200),
        AltMesh = true,
        NoNeon = true,
        MeshIds = {
            ["[Revolver]"] = "rbxassetid://8117329945",
        },
        Textures = {
            ["[Revolver]"] = "rbxassetid://12296360180",
        },
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 60, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
        RevolverOnly = true,
    },
    ["Purple Galaxy"] = {
        Color = Color3.fromRGB(140, 50, 255),
        BeamColor = Color3.fromRGB(180, 100, 255),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 0, 160)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 180, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://81557120048274",
            ["[Double-Barrel SG]"] = "rbxassetid://81557120048274",
            ["[TacticalShotgun]"] = "rbxassetid://81557120048274",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://81557120048274",
            ["[Double-Barrel SG]"] = "rbxassetid://81557120048274",
            ["[TacticalShotgun]"] = "rbxassetid://81557120048274",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Blue Nebula "] = {
        Color = Color3.fromRGB(30, 120, 255),
        BeamColor = Color3.fromRGB(80, 160, 255),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 40, 120)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 140, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 220, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://5203608965",
            ["[Double-Barrel SG]"] = "rbxassetid://5203608965",
            ["[TacticalShotgun]"] = "rbxassetid://5203608965",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://5203608965",
            ["[Double-Barrel SG]"] = "rbxassetid://5203608965",
            ["[TacticalShotgun]"] = "rbxassetid://5203608965",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Blood Flow"] = {
        Color = Color3.fromRGB(200, 20, 30),
        BeamColor = Color3.fromRGB(255, 60, 60),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 30, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 100)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://17489927766",
            ["[Double-Barrel SG]"] = "rbxassetid://17489927766",
            ["[TacticalShotgun]"] = "rbxassetid://17489927766",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://17489927766",
            ["[Double-Barrel SG]"] = "rbxassetid://17489927766",
            ["[TacticalShotgun]"] = "rbxassetid://17489927766",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Crystalized"] = {
        Color = Color3.fromRGB(120, 220, 255),
        BeamColor = Color3.fromRGB(180, 240, 255),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 180)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 250, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://124041545151832",
            ["[Double-Barrel SG]"] = "rbxassetid://124041545151832",
            ["[TacticalShotgun]"] = "rbxassetid://124041545151832",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://124041545151832",
            ["[Double-Barrel SG]"] = "rbxassetid://124041545151832",
            ["[TacticalShotgun]"] = "rbxassetid://124041545151832",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Genisis"] = {
        Color = Color3.fromRGB(100, 100, 110),
        BeamColor = Color3.fromRGB(160, 160, 180),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 120, 140)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 230)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://112871939871917",
            ["[Double-Barrel SG]"] = "rbxassetid://112871939871917",
            ["[TacticalShotgun]"] = "rbxassetid://112871939871917",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://112871939871917",
            ["[Double-Barrel SG]"] = "rbxassetid://112871939871917",
            ["[TacticalShotgun]"] = "rbxassetid://112871939871917",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Darkmatter"] = {
        Color = Color3.fromRGB(60, 10, 90),
        BeamColor = Color3.fromRGB(120, 40, 200),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 20, 140)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 80, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://109009659965338",
            ["[Double-Barrel SG]"] = "rbxassetid://109009659965338",
            ["[TacticalShotgun]"] = "rbxassetid://109009659965338",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://109009659965338",
            ["[Double-Barrel SG]"] = "rbxassetid://109009659965338",
            ["[TacticalShotgun]"] = "rbxassetid://109009659965338",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Bloodstone"] = {
        Color = Color3.fromRGB(140, 10, 30),
        BeamColor = Color3.fromRGB(200, 40, 60),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 10)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 20, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 80)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://137336490017295",
            ["[Double-Barrel SG]"] = "rbxassetid://137336490017295",
            ["[TacticalShotgun]"] = "rbxassetid://137336490017295",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://137336490017295",
            ["[Double-Barrel SG]"] = "rbxassetid://137336490017295",
            ["[TacticalShotgun]"] = "rbxassetid://137336490017295",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Abyss"] = {
        Color = Color3.fromRGB(20, 30, 70),
        BeamColor = Color3.fromRGB(40, 80, 180),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 140, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://137528184645576",
            ["[Double-Barrel SG]"] = "rbxassetid://137528184645576",
            ["[TacticalShotgun]"] = "rbxassetid://137528184645576",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://137528184645576",
            ["[Double-Barrel SG]"] = "rbxassetid://137528184645576",
            ["[TacticalShotgun]"] = "rbxassetid://137528184645576",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
    ["Absolute Zero"] = {
        Color = Color3.fromRGB(170, 230, 255),
        BeamColor = Color3.fromRGB(200, 240, 255),
        BeamColorSequence = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 230, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 250, 255)),
        }),
        Textures = {
            ["[Revolver]"] = "rbxassetid://118895789414719",
            ["[Double-Barrel SG]"] = "rbxassetid://118895789414719",
            ["[TacticalShotgun]"] = "rbxassetid://118895789414719",
        },
        BeamTextures = {
            ["[Revolver]"] = "rbxassetid://118895789414719",
            ["[Double-Barrel SG]"] = "rbxassetid://118895789414719",
            ["[TacticalShotgun]"] = "rbxassetid://118895789414719",
        },
        ScrollTex = true,
        StudsPerTileU = 1,
        StudsPerTileV = 1,
    },
}
fogSpinHue = 0
activeWeather = "None"
currentTarget = nil
aimbotTarget = nil
_plWhitelist = {}
previousTargetHealth = {}



_plWhitelistLocal = _plWhitelist
BODY_PARTS = {
    Head=true, UpperTorso=true, LowerTorso=true, Torso=true,
    LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
    RightUpperArm=true, RightLowerArm=true, RightHand=true,
    LeftUpperLeg=true, LeftLowerLeg=true, LeftFoot=true,
    RightUpperLeg=true, RightLowerLeg=true, RightFoot=true,
    ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true,
}
npcChams = {}
_origMatData = setmetatable({}, {__mode = "k"})
applyMaterialChams = function(char, matName, color)
    local matEnum = Enum.Material.ForceField
    local trans = 0
    if matName == "ForceField" then matEnum = Enum.Material.ForceField; trans = 0
    elseif matName == "Ghost" then matEnum = Enum.Material.Glass; trans = 0.5 end
    if not _origMatData[char] then _origMatData[char] = {} end
    local stored = _origMatData[char]
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and BODY_PARTS[p.Name] then
            if not stored[p] then
                stored[p] = {Material = p.Material, Transparency = p.Transparency}
            end
            p.Material = matEnum
            p.Transparency = trans
        end
    end
end
revertMaterialChams = function(char)
    local stored = _origMatData[char]
    if not stored then return end
    for p, data in pairs(stored) do
        if p and p.Parent then
            pcall(function()
                p.Material = data.Material
                p.Transparency = data.Transparency
            end)
        end
    end
    _origMatData[char] = nil
end
local _dummyDraw = { Visible = false, Color = Color3.new(), Thickness = 1, Filled = false, ZIndex = 1, NumSides = 64, Radius = 0, Position = Vector2.new(), PointA = Vector2.new(), PointB = Vector2.new(), From = Vector2.new(), To = Vector2.new(), Transparency = 1, Text = "", Font = 0, Size = 0, Center = false, Outline = false, OutlineColor = Color3.new() }
local _dummyDrawMT = { __index = function(_, k) return _dummyDraw[k] end, __newindex = function() end, Remove = function() end, Destroy = function() end }
local function safeDrawing(type)
    local ok, obj = pcall(Drawing.new, type)
    if ok and obj then return obj end
    return setmetatable({}, _dummyDrawMT)
end
fovCircle = safeDrawing("Circle"); fovCircle.Visible=false; fovCircle.Filled=false; fovCircle.Thickness=1; fovCircle.ZIndex=10; xpcall(function() fovCircle.NumSides=64 end, function() end)
fovCircleOut = safeDrawing("Circle"); fovCircleOut.Visible=false; fovCircleOut.Filled=false; fovCircleOut.Thickness=1.5; fovCircleOut.ZIndex=9; xpcall(function() fovCircleOut.NumSides=64 end, function() end)
fovCircleFill = safeDrawing("Circle"); fovCircleFill.Visible=false; fovCircleFill.Filled=true; fovCircleFill.ZIndex=8; xpcall(function() fovCircleFill.NumSides=64 end, function() end)
silentFovCircle = safeDrawing("Circle"); silentFovCircle.Visible=false; silentFovCircle.Filled=false; silentFovCircle.Thickness=1; silentFovCircle.ZIndex=10; xpcall(function() silentFovCircle.NumSides=64 end, function() end)
silentFovCircleOut = safeDrawing("Circle"); silentFovCircleOut.Visible=false; silentFovCircleOut.Filled=false; silentFovCircleOut.Thickness=1.5; silentFovCircleOut.ZIndex=9; xpcall(function() silentFovCircleOut.NumSides=64 end, function() end)
silentFovCircleFill = safeDrawing("Circle"); silentFovCircleFill.Visible=false; silentFovCircleFill.Filled=true; silentFovCircleFill.ZIndex=8; xpcall(function() silentFovCircleFill.NumSides=64 end, function() end)
targetTracerOut = safeDrawing("Line"); targetTracerOut.Visible=false; targetTracerOut.Thickness=3; targetTracerOut.ZIndex=8
targetTracer = safeDrawing("Line"); targetTracer.Visible=false; targetTracer.Thickness=1.5; targetTracer.ZIndex=9
local _fovAnimTime = 0
local _fovGradientHue = 0
_trackConn(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
    _fovAnimTime = _fovAnimTime + (dt or 0)
    _fovGradientHue = (_fovGradientHue + (dt or 0) * 0.15) % 1
    local mousePos = UserInputService:GetMouseLocation()
    local mid = Vector2.new(mousePos.X, mousePos.Y)
    if Flags["DrawFOV"] and _bindActive("AimbotBind") then
        local radius = Flags["FOVSize"] or 100
        fovCircle.Position=mid; fovCircle.Radius=radius
        fovCircle.Color=C.FOV; fovCircle.Transparency=0
        fovCircle.Visible=true
        fovCircleOut.Visible=false
        fovCircleFill.Visible=false
    else
        fovCircle.Visible=false; fovCircleOut.Visible=false; fovCircleFill.Visible=false
    end
    if Flags["SilentDrawFOV"] and Flags["SilentEnabled"] then
        local sRef = mid
        if Flags["SilentAimType"] == "Center" then
            sRef = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        end
        local radius = Flags["SilentFOVSize"] or 100
        silentFovCircle.Position=sRef; silentFovCircle.Radius=radius
        silentFovCircle.Color=C.SilentFOV or Color3.new(1,1,1); silentFovCircle.Transparency=0
        silentFovCircle.Visible=true
        silentFovCircleOut.Visible=false
        silentFovCircleFill.Visible=false
    else
        silentFovCircle.Visible=false; silentFovCircleOut.Visible=false; silentFovCircleFill.Visible=false
    end
end)))
_trackConn(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if Flags["AspectRatio"] then
        local resolution = (Flags["AspectRes"] or 80) / 100
        camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, resolution, 0, 0, 0, 1)
    end
end)))
isKnockedOrKO = LPH_NO_VIRTUALIZE(function(character)
    if not character then return false end
    local be = character:FindFirstChild("BodyEffects")
    if be then
        local ko = be:FindFirstChild("K.O"); if ko and ko.Value == true then return true end
    end
    return false
end)
isDeadCheck = LPH_NO_VIRTUALIZE(function(character)
    if not character then return false end
    local be = character:FindFirstChild("BodyEffects")
    if be then
        local sDeath = be:FindFirstChild("SDeath")
        if sDeath and sDeath.Value == true then return true end
    end
    return false
end)
hasSpawnProtection = LPH_NO_VIRTUALIZE(function(character)
    return false
end)
getClosestBodyPart = LPH_NO_VIRTUALIZE(function(character)
    local closest, shortest = nil, math.huge
    local mid = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local parts = {"Head","UpperTorso","LowerTorso","Torso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot","Left Arm","Right Arm","Left Leg","Right Leg"}
    for _, name in ipairs(parts) do
        local part = character:FindFirstChild(name)
        if part then
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mid).Magnitude
                if dist < shortest then shortest = dist; closest = part end
            end
        end
    end
    return closest
end)
getTargetPart = LPH_NO_VIRTUALIZE(function(char)
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local resolvedHitPart = "Head"
    if hum then
        local state = hum:GetState()
        local vel = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
        local isJumping = (state == Enum.HumanoidStateType.Jumping) or (vel.Y > 1)
        local isFalling = (state == Enum.HumanoidStateType.Freefall) or (vel.Y < -1)
        if Flags["DelayJump"] and isJumping then
            resolvedHitPart = Flags["UpTargetPart"] or "Head"
        elseif Flags["UseAdvancedParts"] then
            if isJumping then
                resolvedHitPart = Flags["JumpPart"] or "UpperTorso"
            elseif isFalling and not Flags["IgnoreFall"] then
                resolvedHitPart = Flags["FallPart"] or "LowerTorso"
            else
                resolvedHitPart = Flags["GroundPart"] or "Head"
            end
        else
            resolvedHitPart = Flags["GroundPart"] or "Head"
        end
    end
    local aimType = Flags["AimType"] or "Normal"
    local part
    if aimType == "Closest Part" then
        part = getClosestBodyPart(char)
        resolvedHitPart = part and part.Name or resolvedHitPart
    elseif resolvedHitPart == "Closest Part" then
        part = getClosestBodyPart(char)
        resolvedHitPart = part and part.Name or "Head"
    elseif resolvedHitPart == "Torso" then
        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        resolvedHitPart = part and part.Name or "Torso"
    elseif resolvedHitPart == "Legs" then
        part = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
        resolvedHitPart = part and part.Name or "Legs"
    else
        part = char:FindFirstChild(resolvedHitPart)
        if not part then
            if resolvedHitPart == "UpperTorso" or resolvedHitPart == "LowerTorso" then
                part = char:FindFirstChild("Torso")
                resolvedHitPart = "Torso"
            elseif resolvedHitPart == "Neck" then
                part = char:FindFirstChild("Head")
            end
        end
    end
    return part, resolvedHitPart
end)
_stickyRayParams = RaycastParams.new()
_stickyRayParams.FilterType = Enum.RaycastFilterType.Blacklist
_aimRayParams = RaycastParams.new()
_aimRayParams.FilterType = Enum.RaycastFilterType.Blacklist
_aimRayFilter = {nil, nil}
lastAimbotScanTime = 0
cachedAimbotTarget = nil
findAimbotTarget = LPH_NO_VIRTUALIZE(function()
    local now = tick()
    lastAimbotScanTime = now
    local closest, shortest = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local mid = Vector2.new(mousePos.X, mousePos.Y)
    local fovSize = Flags["FOVSize"] or 100
    local useFov = Flags["UseFOV"]
    local targetMode = Flags["TargetMode"] or "FOV"
    local checks = Flags["AimChecks"] or {}
    if type(checks) ~= "table" then checks = {} end
    local checkWall = hasCheck(checks, "Wall")
    local checkDead = hasCheck(checks, "Dead")
    local checkKnocked = hasCheck(checks, "Knocked")
    local checkTeam = hasCheck(checks, "Team")
    local checkEnemy = hasCheck(checks, "Enemy")
    local checkNPC = hasCheck(checks, "NPC")
    local myChar = lp.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local camPos = camera.CFrame.Position
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local ref = (targetMode == "FOV") and screenCenter or mid

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if _plWhitelist[player] then continue end
        local isTeammate = lp.Team ~= nil and player.Team == lp.Team
        if checkTeam and isTeammate then continue end
        if checkEnemy and not isTeammate then continue end
        local character = player.Character
        if not character then continue end
        local hum = character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if checkDead and (hum:GetState() == Enum.HumanoidStateType.Dead or isDeadCheck(character)) then continue end
        if checkKnocked and isKnockedOrKO(character) then continue end
        if hasSpawnProtection(character) then continue end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local hrpPos, hrpOnScreen = camera:WorldToViewportPoint(hrp.Position)
        if not hrpOnScreen then continue end
        local hrpMidDist = (Vector2.new(hrpPos.X, hrpPos.Y) - ref).Magnitude
        if useFov and targetMode ~= "Distance" and hrpMidDist > fovSize * 1.5 then continue end
        
        if targetMode == "Distance" then
            if not myHrp then continue end
            local hrp3dDist = (myHrp.Position - hrp.Position).Magnitude
            if hrp3dDist - 4 > shortest then continue end
        else
            if hrpMidDist - 30 > shortest then continue end
        end

        local part = getTargetPart(character)
        if not part then continue end
        local pos, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist
        if targetMode == "Distance" then
            if not myHrp then continue end
            dist = (myHrp.Position - part.Position).Magnitude
        elseif targetMode == "Mouse" then
            dist = (Vector2.new(pos.X, pos.Y) - mid).Magnitude
        else
            dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
        end
        if useFov and targetMode ~= "Distance" then
            if (Vector2.new(pos.X, pos.Y) - ref).Magnitude > fovSize then continue end
        end
        if dist < shortest then
            if checkWall and myChar then
                _aimRayFilter[1] = myChar
                _aimRayFilter[2] = character
                _aimRayParams.FilterDescendantsInstances = _aimRayFilter
                local result = workspace:Raycast(camPos, part.Position - camPos, _aimRayParams)
                if result then continue end
            end
            shortest = dist
            closest = part
        end
    end
    if checkNPC then
        for _, bot in ipairs(getNPCs()) do
            local hum = bot:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if checkDead and (hum:GetState() == Enum.HumanoidStateType.Dead or isDeadCheck(bot)) then continue end
            if checkKnocked and isKnockedOrKO(bot) then continue end
            if hasSpawnProtection(bot) then continue end
            local hrp = bot:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local hrpPos, hrpOnScreen = camera:WorldToViewportPoint(hrp.Position)
            if not hrpOnScreen then continue end
            local hrpMidDist = (Vector2.new(hrpPos.X, hrpPos.Y) - ref).Magnitude
            if useFov and targetMode ~= "Distance" and hrpMidDist > fovSize * 1.5 then continue end
            
            if targetMode == "Distance" then
                if not myHrp then continue end
                local hrp3dDist = (myHrp.Position - hrp.Position).Magnitude
                if hrp3dDist - 4 > shortest then continue end
            else
                if hrpMidDist - 30 > shortest then continue end
            end

            local part = getTargetPart(bot)
            if not part then continue end
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local dist
            if targetMode == "Distance" then
                if not myHrp then continue end
                dist = (myHrp.Position - part.Position).Magnitude
            elseif targetMode == "Mouse" then
                dist = (Vector2.new(pos.X, pos.Y) - mid).Magnitude
            else
                dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            end
            if useFov and targetMode ~= "Distance" then
                if (Vector2.new(pos.X, pos.Y) - ref).Magnitude > fovSize then continue end
            end
            if dist < shortest then
                if checkWall and myChar then
                    _aimRayFilter[1] = myChar
                    _aimRayFilter[2] = bot
                    _aimRayParams.FilterDescendantsInstances = _aimRayFilter
                    local result = workspace:Raycast(camPos, part.Position - camPos, _aimRayParams)
                    if result then continue end
                end
                shortest = dist
                closest = part
            end
        end
    end
    cachedAimbotTarget = closest
    return closest
end)
getPredictedPosition = nil
do
    local _targetStates = setmetatable({}, { __mode = "k" })

    local getTargetState = LPH_NO_VIRTUALIZE(function(char)
        local state = _targetStates[char]
        if not state then
            state = {
                smoothedVel = Vector3.new(0, 0, 0),
                prevSmoothedVel = Vector3.new(0, 0, 0),
                antiBlend = 0,
                wasInAir = false,
                smoothPredX = 0,
                smoothPredY = 0,
                lastUpdateTick = 0,
                cachedOffset = nil,
                smoothedAirOffset = 0
            }
            _targetStates[char] = state
        end
        return state
    end)

    local checkAnti = LPH_NO_VIRTUALIZE(function(char)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < -70 then return true end
        if vel.X > 450 or vel.X < -35 then return true end
        if vel.Y > 60 then return true end
        if vel.Z > 35 or vel.Z < -35 then return true end
        return false
    end)

    getPredictedPosition = LPH_NO_VIRTUALIZE(function(part, basePos, forceOn)
        local targetPos = basePos or part.Position
        local targetChar = part.Parent
        if not targetChar then return targetPos end
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        if not hrp then return targetPos end

        -- Apply manual offsets to target position BEFORE prediction
        if Flags["UseOffsets"] then
            local camCF = camera.CFrame
            local upOffset = (Flags["OffsetUp"] or 0) / 10
            local downOffset = (Flags["OffsetDown"] or 0) / 10
            local leftOffset = (Flags["OffsetLeft"] or 0) / 10
            local rightOffset = (Flags["OffsetRight"] or 0) / 10
            local rightXZ = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if rightXZ.Magnitude > 0.001 then rightXZ = rightXZ.Unit else rightXZ = Vector3.new(1, 0, 0) end
            local totalOffset = Vector3.new(0, upOffset - downOffset, 0) + rightXZ * (rightOffset - leftOffset)
            targetPos = targetPos + totalOffset
        end

        local usePrediction = forceOn or (Flags["UsePred"] or Flags["UseAdvancedPred"])
        if not usePrediction then
            return targetPos
        end

        local state = getTargetState(targetChar)
        local now = os.clock()
        local dt = state.lastUpdateTick == 0 and 0.016 or math.clamp(now - state.lastUpdateTick, 0.001, 0.1)
        state.lastUpdateTick = now

        local rawVel = hrp.AssemblyLinearVelocity
        local clampedRawVel = Vector3.new(
            math.clamp(rawVel.X, -85, 85),
            math.clamp(rawVel.Y, -65, 65),
            math.clamp(rawVel.Z, -85, 85)
        )

        local vel
        if Flags["UseSmoothing"] then
            local velAlpha = 1 - math.exp(-dt * 120)
            state.prevSmoothedVel = state.smoothedVel
            state.smoothedVel = state.smoothedVel:Lerp(clampedRawVel, math.clamp(velAlpha, 0.05, 0.95))
            vel = state.smoothedVel
        else
            state.prevSmoothedVel = state.smoothedVel
            state.smoothedVel = clampedRawVel
            vel = clampedRawVel
        end

        local advPred = Flags["UseAdvancedPred"]
        local targetPredX, targetPredY

        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        local humState = hum and hum:GetState()
        local rawInAir = hum and hum.FloorMaterial == Enum.Material.Air

        local isInAir = rawInAir
            or humState == Enum.HumanoidStateType.Jumping
            or humState == Enum.HumanoidStateType.Freefall
            or humState == Enum.HumanoidStateType.FallingDown
            or math.abs(rawVel.Y) > 0.15
        state.wasInAir = isInAir

        if advPred then
            if isInAir then
                local camRightXZ = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
                if camRightXZ.Magnitude > 0.001 then camRightXZ = camRightXZ.Unit else camRightXZ = Vector3.new(1,0,0) end
                local velXZ = Vector3.new(vel.X, 0, vel.Z)
                local rightDot = camRightXZ:Dot(velXZ)
                if rightDot > 0 then
                    targetPredX = (Flags["AdvPredAirRight"] or 24) / 200
                else
                    targetPredX = (Flags["AdvPredAirLeft"] or 24) / 200
                end
                -- Smooth Y prediction transition to prevent "forcing back" when jumping
                local upPred = (Flags["AdvPredAirUp"] or 24) / 200
                local downPred = (Flags["AdvPredAirDown"] or 24) / 200
                -- If going up, use up prediction. If going down, use down prediction. Blend smoothly at peak
                if vel.Y > 1 then
                    -- Going up: use up prediction fully
                    targetPredY = upPred
                elseif vel.Y < -1 then
                    -- Going down: use down prediction fully
                    targetPredY = downPred
                else
                    -- At peak or very near it: blend between them
                    local blend = (vel.Y + 1) / 2 -- -1 to 1 range mapped to 0-1
                    targetPredY = upPred * blend + downPred * (1 - blend)
                end
            else
                local camRightXZ = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
                if camRightXZ.Magnitude > 0.001 then camRightXZ = camRightXZ.Unit else camRightXZ = Vector3.new(1,0,0) end
                local velXZ = Vector3.new(vel.X, 0, vel.Z)
                local rightDot = camRightXZ:Dot(velXZ)
                if rightDot > 0 then
                    targetPredX = (Flags["AdvPredRight"] or 24) / 200
                else
                    targetPredX = (Flags["AdvPredLeft"] or 24) / 200
                end
                targetPredY = 0.05
            end
        else
            if isInAir then
                targetPredX = (Flags["PredAirX"] or 12) / 200
                targetPredY = (Flags["PredY"] or 30) / 150
                local airXZSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                if airXZSpeed > 4 then
                    local airBoost = math.clamp((airXZSpeed - 4) / 38, 0.08, 0.72)
                    targetPredX = targetPredX * (1 + airBoost)
                else
                    targetPredX = targetPredX * 1.08
                end
            else
                targetPredX = (Flags["PredX"] or 30) / 200
                targetPredY = (Flags["PredY"] or 30) / 200
            end
        end

        local coeffAlpha = Flags["UseSmoothing"] and (1 - math.exp(-dt * 80)) or 1
        state.smoothPredX = state.smoothPredX + (targetPredX - state.smoothPredX) * math.clamp(coeffAlpha, 0.05, 0.95)
        state.smoothPredY = state.smoothPredY + (targetPredY - state.smoothPredY) * math.clamp(coeffAlpha, 0.05, 0.95)

        local predX = state.smoothPredX
        local predY = state.smoothPredY

        local predStyle = Flags["PredStyle"] or "Classic"
        local normalOffset
        

        if predStyle == "Adaptive" then
            local dist = (camera.CFrame.Position - targetPos).Magnitude
            local distScale = math.clamp(dist / 90, 0.55, 1.35)
            local velMag = vel.Magnitude
            local velScale = math.clamp(1.08 - velMag / 260, 0.72, 1.08)
            local adaptScale = distScale * velScale
            normalOffset = Vector3.new(
                vel.X * predX * adaptScale,
                vel.Y * predY * adaptScale,
                vel.Z * predX * adaptScale
            )
        else
            local predVelY = vel.Y
            -- When in air, hold upward prediction at peak instead of snapping back to 0
            if isInAir and vel.Y > -2 and vel.Y < 2 then
                -- At peak: hold a small upward bias instead of collapsing
                predVelY = math.max(vel.Y, 2)
            elseif isInAir and vel.Y > 0 then
                -- Going up: boost slightly to stay ahead
                predVelY = vel.Y * 1.2
            end
            normalOffset = Vector3.new(vel.X * predX, predVelY * predY, vel.Z * predX)
            if isInAir then
                local airVelXZ = Vector3.new(vel.X, 0, vel.Z)
                local airSpeedXZ = airVelXZ.Magnitude
                if airSpeedXZ > 0.75 then
                    local airDir = airVelXZ.Unit
                    local extraLead = math.clamp((airSpeedXZ - 3) * predX * 0.095, 0.2, 5.2)
                    normalOffset = normalOffset + Vector3.new(airDir.X * extraLead, 0, airDir.Z * extraLead)
                end
            end
        end

        local antiTarget = checkAnti(targetChar)
        state.antiBlend = state.antiBlend + ((antiTarget and 1 or 0) - state.antiBlend) * 0.12

        local antiOffset = normalOffset
        if antiTarget or state.antiBlend > 0.01 then
            local hum2 = targetChar:FindFirstChildOfClass("Humanoid")
            if hum2 then
                local antiXZ = hum2.MoveDirection * hum2.WalkSpeed * predX
                antiOffset = Vector3.new(antiXZ.X, vel.Y * predY, antiXZ.Z)
            end
        end

        local blendedOffset = normalOffset:Lerp(antiOffset, state.antiBlend)

        local offsetAlpha = Flags["UseSmoothing"] and math.clamp(1 - math.exp(-dt * 100), 0.05, 0.95) or 1
        if isInAir then
            offsetAlpha = math.clamp(offsetAlpha * 1.35, 0.06, 0.95)
        end
        if not state.cachedOffset or not Flags["UseSmoothing"] then
            state.cachedOffset = blendedOffset
        else
            state.cachedOffset = state.cachedOffset:Lerp(blendedOffset, math.clamp(offsetAlpha, 0.01, 1))
        end

        local finalPos = targetPos + state.cachedOffset
        
        -- Apply air offset in prediction with smoothing
        if Flags["UseAirOffset"] then
            local targetHum3 = targetChar:FindFirstChildOfClass("Humanoid")
            if targetHum3 then
                local state2 = targetHum3:GetState()
                local vel2 = hrp.AssemblyLinearVelocity
                local isInAir2 = targetHum3.FloorMaterial == Enum.Material.Air
                    or state2 == Enum.HumanoidStateType.Jumping
                    or state2 == Enum.HumanoidStateType.Freefall
                    or state2 == Enum.HumanoidStateType.FallingDown
                    or math.abs(vel2.Y) > 0.15
                
                local targetAirOffset = 0
                if isInAir2 then
                    targetAirOffset = (Flags["AirOffsetVal"] or 0) / 10
                end
                
                -- Smooth the air offset using state
                local smoothVal = 10
                if Flags["AirOffsetUseAimbotSmooth"] then
                    smoothVal = Flags["SmoothY"] or 2
                else
                    smoothVal = Flags["AirOffsetSmooth"] or 2
                end
                
                local baseAlpha = math.clamp(1 / (smoothVal * 0.08 + 1), 0.025, 1)
                local alpha = math.clamp(1 - math.pow(1 - baseAlpha, dt * 60), 0.05, isInAir2 and 0.95 or 0.95)
                state.smoothedAirOffset = (state.smoothedAirOffset or 0) + (targetAirOffset - (state.smoothedAirOffset or 0)) * alpha
                
                if math.abs(state.smoothedAirOffset) < 0.01 then
                    state.smoothedAirOffset = 0
                end
                
                finalPos = finalPos + Vector3.new(0, state.smoothedAirOffset, 0)
            end
        end

        return finalPos
    end)

    resetPredictionState = function()
        _targetStates = setmetatable({}, { __mode = "k" })
    end
end
lockedAimTarget = nil
deadSpotEndTime = 0
_delayJumpCount = 0
_delayJumpTimer = 0
_fallDelayTimer = 0
_lastTargetInAir = false
_elasticVelocity = Vector3.new(0, 0, 0)
_aimTargetAcquireTime = nil
_aimWasEnabled = false
_aimFrameSkip = 0
_aimbotSetCamera = false
_lastAimbotCF = nil
_lastTarget = nil
_smoothedPredictedPos = nil
_lastAimbotTargetLostTime = nil
_currentAirOffset = 0
_lastAimbotTargetPos = nil
_lastAimbotTargetPlayer = nil
_lastPartSwitchTarget = nil
_currentPartOffset = Vector3.zero
_lockedResolvedPart = nil
_lockedResolvedHitPart = nil
_hasLockedTargetDuringThisPress = false
_targetDiedDuringThisPress = false
do
local _smoothedAimPos = nil
local _aimStartCF = nil
local _mouseRemainderX = 0
local _mouseRemainderY = 0
local _aimVelPitch = 0
local _aimVelYaw = 0
local _aimEaseProgress = 0
local _aimStartMousePos = nil

local _smoothDampAngle = LPH_NO_VIRTUALIZE(function(current, target, vel, smoothTime, dt)
    smoothTime = math.max(0.0001, smoothTime)
    local omega = 2 / smoothTime
    local change = current - target
    local expf = math.exp(-omega * dt)
    local temp = (vel + omega * change) * dt
    vel = (vel - omega * temp) * expf
    return target + (change + temp) * expf, vel
end)

local _easeCache = { style = "Quad", dir = "Out", sharp = 0.2, back = 1.7, bounce = 1, elasticPeriod = 0.3, elasticity = 1.3, swaySpeed = 1.5, swayWidth = 0.1, jitterAmt = 0.075 }
local _easeCacheFrame = -1

local applyEasing = LPH_JIT(function(t)
    t = math.clamp(t, 0, 1)
    local f = _easeCacheFrame
    if f ~= _aimFrameSkip then
        _easeCacheFrame = _aimFrameSkip
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local inAir = hum and hum.FloorMaterial == Enum.Material.Air
        _easeCache.style = (inAir and Flags["JumpEaseStyle"]) or Flags["EaseStyle"] or "Quad"
        _easeCache.dir = (inAir and (Flags["JumpEaseDir"] or Flags["EaseDir"])) or Flags["EaseDir"] or "Out"
        _easeCache.sharp = (Flags["SharpPower"] or 20) / 100
        _easeCache.back = (Flags["BackOvershoot"] or 17) / 10
        _easeCache.bounce = (Flags["BounceBounciness"] or 50) / 50
        _easeCache.elasticPeriod = (Flags["ElasticPeriod"] or 30) / 100
        _easeCache.elasticity = 1 + (Flags["Elasticity"] or 30) / 100
        _easeCache.swaySpeed = (Flags["AdaptSwaySpeed"] or 15) / 10
        _easeCache.swayWidth = (Flags["AdaptSwayWidth"] or 10) / 100
        _easeCache.jitterAmt = (Flags["AdaptJitterAmt"] or 15) / 200
        _easeCache.exponent = Flags["EaseExponent"] or nil
        _easeCache.blend = (Flags["EaseBlend"] or 100) / 100
    end
    local c = _easeCache
    local style = c.style
    local dir = c.dir

    if style == "Adaptive" or style == "Adapt" then
        local base
        if dir == "Out" then base = 1 - (1 - t) * (1 - t)
        elseif dir == "InOut" then base = t < 0.5 and 2 * t * t or 1 - ((1 - (2 - 2 * t)) * (1 - (2 - 2 * t))) / 2
        else base = t * t end
        local fade = 1 - t
        local sway = math.sin(os.clock() * c.swaySpeed) * c.swayWidth * fade
        local jit = (math.random() * 2 - 1) * c.jitterAmt * fade
        return math.clamp(base + sway + jit, 0, 1)
    elseif style == "Zigzag" then
        local cycles = 2 + math.floor(c.swaySpeed / 1.2)
        return math.clamp(t + math.sin(t * math.pi * cycles) * c.swayWidth * (1 - t), 0, 1)
    elseif style == "Pulse" then
        local cycles = 1 + math.floor(c.swaySpeed / 1.5)
        local amp = c.swayWidth / 1.5
        local env = math.sin(t * math.pi)
        return math.clamp(t + math.sin(t * math.pi * 2 * cycles) * amp * env, 0, 1)
    end

    local sharp = c.sharp
    local back = c.back
    local bounce = c.bounce
    local exponent = c.exponent
    local period = c.elasticPeriod
    local amp = c.elasticity

    local function _computeBase(s, x)
        if s == "Linear" then return x
        elseif s == "Sine" then return 1 - math.cos((x * math.pi) / 2)
        elseif s == "Quad" then return x * x
        elseif s == "Cubic" then return x * x * x
        elseif s == "Quart" then return x * x * x * x
        elseif s == "Quint" then return x * x * x * x * x
        elseif s == "Sextic" then return x * x * x * x * x * x
        elseif s == "Septic" then return x * x * x * x * x * x * x
        elseif s == "Octic" then return x * x * x * x * x * x * x * x
        elseif s == "Square Root" then return math.sqrt(x)
        elseif s == "Custom Power" then return x ^ (exponent or 3)
        elseif s == "Exponential" then return x <= 0 and 0 or 2 ^ (10 * (x - 1))
        elseif s == "Circular" then return 1 - math.sqrt(math.max(0, 1 - x * x))
        elseif s == "Sharp" then return x ^ (sharp or 0.2)
        elseif s == "Back" then
            local sb = back or 1.7
            return (sb + 1) * x * x * x - sb * x * x
        end
        return x * x
    end

    if style == "Bounce" then
        local n1 = 7.5625
        local d1 = 2.75
        local function _bounceOut(x)
            local r
            if x < 1 / d1 then
                r = n1 * x * x
            elseif x < 2 / d1 then
                local tt = x - 1.5 / d1
                r = n1 * tt * tt + 0.75
            elseif x < 2.5 / d1 then
                local tt = x - 2.25 / d1
                r = n1 * tt * tt + 0.9375
            else
                local tt = x - 2.625 / d1
                r = n1 * tt * tt + 0.984375
            end
            return r + (r - x) * (bounce - 1)
        end
        if dir == "In" then return 1 - _bounceOut(1 - t)
        elseif dir == "InOut" then
            if t < 0.5 then return (1 - _bounceOut(1 - 2 * t)) / 2 end
            return (1 + _bounceOut(2 * t - 1)) / 2
        end
        return _bounceOut(t)
    elseif style == "Elastic" or style == "Custom Elastic" then
        local function _elasticOut(x)
            if x <= 0 then return 0 end
            if x >= 1 then return 1 end
            local pp = period
            if pp <= 0 then pp = 0.3 end
            local s = pp / 4
            return amp * 2 ^ (-10 * x) * math.sin((x - s) * (2 * math.pi) / pp) + 1
        end
        if dir == "In" then return 1 - _elasticOut(1 - t)
        elseif dir == "InOut" then
            if t < 0.5 then return (1 - _elasticOut(1 - 2 * t)) / 2 end
            return (1 + _elasticOut(2 * t - 1)) / 2
        end
        return _elasticOut(t)
    end

    if dir == "Out" then
        return 1 - _computeBase(style, 1 - t)
    elseif dir == "InOut" then
        if t < 0.5 then return _computeBase(style, 2 * t) / 2 end
        return 1 - _computeBase(style, 2 - 2 * t) / 2
    end
    return _computeBase(style, t)
end)


_prevAimTarget = nil
_aimbotMissOffset = Vector3.new(0, 0, 0)
_aimbotShouldMiss = false

resetPredictionState = function()
    _targetStates = setmetatable({}, { __mode = "k" })
end

task.spawn(function()
    task.wait(2)
    _trackConn(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
        _aimFrameSkip = _aimFrameSkip + 1
        _aimbotSetCamera = false
        local aimbotActive = _bindActive("AimbotBind")
        if not aimbotActive then
            _prevAimTarget = nil
            _aimbotShouldMiss = false
            _aimbotMissOffset = Vector3.new(0, 0, 0)
            lockedAimTarget = nil
            _delayJumpCount = 0
            _delayJumpTimer = 0
            _fallDelayTimer = 0
            _aimTargetAcquireTime = nil
            _aimWasEnabled = false
            aimbotTarget = nil
            _lastAimbotTargetPos = nil
            _lastAimbotCF = nil
            _lastAimbotTargetPlayer = nil
            _lockedResolvedPart = nil
            _lockedResolvedHitPart = nil
            _hasLockedTargetDuringThisPress = false
            _targetDiedDuringThisPress = false
            _smoothedAimPos = nil
            _aimStartCF = nil
            _mouseRemainderX = 0
            _mouseRemainderY = 0
            _aimVelPitch = 0
            _aimVelYaw = 0
            _smoothedPredictedPos = nil
            _currentAirOffset = 0
            _lastTargetInAir = false
            _aimEaseProgress = 0
            _aimStartMousePos = nil
            resetPredictionState()
            return
        end
        if _macroActive then return end
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        local justActivated = not _aimWasEnabled
        _aimWasEnabled = true
        if justActivated then
            _aimEaseProgress = 0
            _aimStartCF = camera.CFrame
            _aimStartMousePos = UserInputService:GetMouseLocation()
        end
        local target = nil
        local fromLockedTarget = false
        local deadCheckTarget = lockedAimTarget or aimbotTarget
        local targetDied = false
        if deadCheckTarget then
            local char
            if deadCheckTarget:IsA("Player") then
                char = deadCheckTarget.Character
            elseif deadCheckTarget:IsA("BasePart") then
                char = deadCheckTarget.Parent
            else
                char = deadCheckTarget
            end
            if char and not (deadCheckTarget:IsA("BasePart") and deadCheckTarget.Name == "AimDeadSpot") then
                local shouldUnlock = not char:IsDescendantOf(workspace)
                if not shouldUnlock then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local isDead = (hum and (hum.Health < 1 or hum:GetState() == Enum.HumanoidStateType.Dead)) or isKnockedOrKO(char) or isDeadCheck(char)
                    if isDead then
                        if Flags["StayOnDeadspot"] then
                            local deadSpotPos
                            if deadCheckTarget:IsA("BasePart") then
                                deadSpotPos = deadCheckTarget.Position
                            elseif deadCheckTarget:IsA("Player") then
                                local deadChar = deadCheckTarget.Character
                                local deadHrp = deadChar and deadChar:FindFirstChild("HumanoidRootPart")
                                deadSpotPos = deadHrp and deadHrp.Position or (deadChar and deadChar:GetPivot().Position)
                            else
                                local deadHrp = char:FindFirstChild("HumanoidRootPart")
                                deadSpotPos = deadHrp and deadHrp.Position or char:GetPivot().Position
                            end
                            if deadSpotPos then
                                local deadspotPart = Instance.new("Part")
                                deadspotPart.Name = "AimDeadSpot"
                                deadspotPart.Anchored = true
                                deadspotPart.CanCollide = false
                                deadspotPart.Transparency = 1
                                deadspotPart.Size = Vector3.new(0.1, 0.1, 0.1)
                                deadspotPart.CFrame = CFrame.new(deadSpotPos)
                                deadspotPart.Parent = game:GetService("ReplicatedStorage")
                                local stayMs = Flags["DeadspotTime"] or 300
                                if type(stayMs) ~= "number" then stayMs = 300 end
                                stayMs = math.clamp(stayMs, 1, 10000)
                                game:GetService("Debris"):AddItem(deadspotPart, stayMs / 1000)
                                deadSpotEndTime = tick() + stayMs / 1000
                                lockedAimTarget = deadspotPart
                                aimbotTarget = nil
                            end
                        else
                            shouldUnlock = true
                            targetDied = true
                        end
                    end
                end
                if shouldUnlock then
                    lockedAimTarget = nil
                    aimbotTarget = nil
                    target = nil
                    if targetDied then
                        _targetDiedDuringThisPress = true
                        if Flags["AutoStopOnDeath"] then
                            Flags["AimbotEnabled"] = false
                            if Flags["AimbotBind"] then
                                Flags["AimbotBind"].Toggled = false
                            end
                            if _aimbotKeybindWidget then
                                pcall(function() _aimbotKeybindWidget:SetToggle(false) end)
                            end
                        end
                    end
                    return
                end
            end
        end
        if (Flags["LockTarget"] or Flags["StickyAim"]) and lockedAimTarget then
            local isDeadspot = lockedAimTarget.Name == "AimDeadSpot"
            if isDeadspot then
                if lockedAimTarget.Parent and tick() < deadSpotEndTime then
                    target = lockedAimTarget
                else
                    lockedAimTarget = nil
                    deadSpotEndTime = 0
                end
            else
                local char = lockedAimTarget.Parent
                if char and char.Parent then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and not isKnockedOrKO(char) and not isDeadCheck(char) and not hasSpawnProtection(char) then
                        if lockedAimTarget:IsDescendantOf(char) then
                            target = lockedAimTarget
                            fromLockedTarget = true
                        else
                            lockedAimTarget = nil
                        end
                    else
                        lockedAimTarget = nil
                        _targetDiedDuringThisPress = true
                    end
                else
                    lockedAimTarget = nil
                end
            end
        end
        if not target then
            if not _targetDiedDuringThisPress then
                _hasLockedTargetDuringThisPress = false
                target = findAimbotTarget()
                if target then
                    _aimTargetAcquireTime = _aimTargetAcquireTime or tick()
                    local lockMs = Flags["LockTime"] or 0
                    if lockMs <= 0 or tick() - _aimTargetAcquireTime >= lockMs / 1000 then
                        if Flags["StickyAim"] or Flags["LockTarget"] then
                            lockedAimTarget = target
                            _hasLockedTargetDuringThisPress = true
                        end
                    end
                end
            end
        end
        if target then
            if target ~= _prevAimTarget then
                _aimEaseProgress = 0
                _aimStartCF = camera.CFrame
                _aimStartMousePos = UserInputService:GetMouseLocation()
            end
            _prevAimTarget = target
            _lastTarget = target
            _lastAimbotTargetLostTime = nil
        else
            local useUnlockDelay = Flags["UnlockDelayEnabled"]
            local holdTime = useUnlockDelay and (Flags["UnlockDelayMs"] or 100) / 1000 or 0.15
            if not _lastAimbotTargetLostTime then
                _lastAimbotTargetLostTime = tick()
            end
            if tick() - _lastAimbotTargetLostTime < holdTime then
                if _lastTarget and _lastTarget.Parent and _lastTarget.Parent.Parent then
                    target = _lastTarget
                end
            else
                if _lastTarget and _lastTarget.Parent and not _targetDiedDuringThisPress then
                    local lastChar = _lastTarget.Parent
                    local hum = lastChar:FindFirstChildOfClass("Humanoid")
                    if hum and (hum.Health < 1 or hum:GetState() == Enum.HumanoidStateType.Dead
                        or isKnockedOrKO(lastChar) or isDeadCheck(lastChar)) then
                        _targetDiedDuringThisPress = true
                        if Flags["AutoStopOnDeath"] then
                            Flags["AimbotEnabled"] = false
                            if Flags["AimbotBind"] then
                                Flags["AimbotBind"].Toggled = false
                            end
                            if _aimbotKeybindWidget then
                                pcall(function() _aimbotKeybindWidget:SetToggle(false) end)
                            end
                        end
                    end
                end
                aimbotTarget = nil
                _lastAimbotTargetPos = nil
                _lastAimbotTargetPlayer = nil
                _lockedResolvedPart = nil
                _lockedResolvedHitPart = nil
                _smoothedAimPos = nil
                _aimStartCF = nil
                _mouseRemainderX = 0
                _mouseRemainderY = 0
                _aimVelPitch = 0
                _aimVelYaw = 0
                _smoothedPredictedPos = nil
                _currentAirOffset = 0
                _lastTargetInAir = false
                _aimEaseProgress = 0
                _aimStartMousePos = nil
                resetPredictionState()
                return
            end
        end
        if not target then
            _prevAimTarget = nil
            aimbotTarget = nil
            _lastAimbotTargetPos = nil
            _lastAimbotTargetPlayer = nil
            _lockedResolvedPart = nil
            _lockedResolvedHitPart = nil
            _smoothedAimPos = nil
            _aimStartCF = nil
            _mouseRemainderX = 0
            _mouseRemainderY = 0
            _smoothedPredictedPos = nil
            _aimVelPitch = 0
            _aimVelYaw = 0
            _currentAirOffset = 0
            _lastTargetInAir = false
            _aimEaseProgress = 0
            _aimStartMousePos = nil
            resetPredictionState()
            return
        end
        if target ~= _prevAimTarget then
            _aimEaseProgress = 0
            _prevAimTarget = target
            _aimStartCF = camera.CFrame
            _aimStartMousePos = UserInputService:GetMouseLocation()
            _smoothedAimPos = nil
            _currentPartOffset = nil
            _smoothedPredictedPos = nil
            _aimVelPitch = 0
            _aimVelYaw = 0
            _currentAirOffset = 0
            _lastTargetInAir = false
            _lockedResolvedPart = nil
            _lockedResolvedHitPart = nil
            resetPredictionState()
        elseif Flags["UseEasing"] and _lastAimbotTargetPos then
            local distMoved = (target.Position - _lastAimbotTargetPos).Magnitude
            if distMoved > 50 then
                _aimEaseProgress = 0
                _aimStartCF = camera.CFrame
                _aimStartMousePos = UserInputService:GetMouseLocation()
            end
        end
        if Flags["DelayJump"] then
            local targetChar = target.Parent
            if targetChar then
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                if targetHum then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    local vel = targetRoot and targetRoot.AssemblyLinearVelocity or Vector3.new()
                    local humState = targetHum:GetState()
                    local isAirborneNow = targetHum.FloorMaterial == Enum.Material.Air
                        or humState == Enum.HumanoidStateType.Jumping
                        or humState == Enum.HumanoidStateType.Freefall
                        or humState == Enum.HumanoidStateType.FallingDown
                        or math.abs(vel.Y) > 0.15
                    if isAirborneNow and not _lastTargetInAir then
                        _delayJumpTimer = tick()
                    end
                    _lastTargetInAir = isAirborneNow
                    if isAirborneNow and _delayJumpTimer ~= 0 then
                        local elapsed = (tick() - _delayJumpTimer) * 1000
                        if elapsed < (Flags["DelayJumpMs"] or 50) then
                            return
                        end
                    end
                    if not isAirborneNow then
                        _delayJumpTimer = 0
                    end
                end
            end
        end
        if Flags["FallDelay"] then
            local targetChar = target.Parent
            if targetChar then
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHum and targetHRP then
                    local isInAir = targetHum.FloorMaterial == Enum.Material.Air
                    local velY = targetHRP.AssemblyLinearVelocity.Y
                    if isInAir and velY < -5 then
                        if _fallDelayTimer == 0 then
                            _fallDelayTimer = tick()
                        end
                        local elapsed = (tick() - _fallDelayTimer) * 1000
                        if elapsed < (Flags["FallDelayMs"] or 50) then
                            return
                        end
                    else
                        _fallDelayTimer = 0
                    end
                end
            end
        end
        local plr = Players:GetPlayerFromCharacter(target.Parent)
        if plr then aimbotTarget = plr else aimbotTarget = nil end

        if Flags["AimbotSpectateTarget"] and aimbotTarget and aimbotTarget.Character then
            local targetHum = aimbotTarget.Character:FindFirstChildOfClass("Humanoid")
            if targetHum and camera.CameraSubject ~= targetHum then
                camera.CameraSubject = targetHum
            end
        else
            local expectedSubject = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if expectedSubject and camera.CameraSubject ~= expectedSubject and not _spectatingPlayer then
                camera.CameraSubject = expectedSubject
            end
        end
        local resolvedPart, resolvedHitPart
        if fromLockedTarget and _lockedResolvedPart and _lockedResolvedPart.Parent == target.Parent then
            resolvedPart = _lockedResolvedPart
            resolvedHitPart = _lockedResolvedHitPart or _lockedResolvedPart.Name
            target = resolvedPart
        elseif not fromLockedTarget then
            resolvedPart, resolvedHitPart = getTargetPart(target.Parent)
            if resolvedPart then
                target = resolvedPart
                if Flags["LockTarget"] or Flags["StickyAim"] then
                    _lockedResolvedPart = resolvedPart
                    _lockedResolvedHitPart = resolvedHitPart
                    lockedAimTarget = resolvedPart
                end
            end
        else
            resolvedHitPart = target.Name
            _lockedResolvedPart = target
            _lockedResolvedHitPart = resolvedHitPart
        end
        local targetPos = target.Position

        local targetHRP = target.Parent:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            local targetKey = target.Parent:GetDebugId()
            local relOffset = targetHRP.CFrame:PointToObjectSpace(target.Position)

            if _lastPartSwitchTarget ~= targetKey then
                _lastPartSwitchTarget = targetKey
            end
            _currentPartOffset = relOffset
        end
        if Flags["UsePred"] or Flags["UseAdvancedPred"] then
            local ok, rawPredPos = pcall(getPredictedPosition, target, targetPos)
            if ok and rawPredPos then
                targetPos = rawPredPos
            end
        end
        local char = target.Parent
        local partUp = target.CFrame.UpVector
        local partHalfY = target.Size.Y * 0.5
        if resolvedHitPart == "Neck" then
            targetPos = targetPos - partUp * partHalfY
        elseif resolvedHitPart == "UpperTorso" then
            targetPos = targetPos + partUp * (partHalfY * 0.6)
        elseif resolvedHitPart == "LowerTorso" or resolvedHitPart == "Torso" then
            targetPos = targetPos + partUp * (partHalfY * 0.3)
        elseif resolvedHitPart == "HumanoidRootPart" then
            targetPos = targetPos + partUp * 0.5
        end
        -- Offsets are now handled inside getPredictedPosition function

        local missChance = Flags["MissChance"] or 0
        if missChance > 0 and math.random(1, 100) <= missChance then
            local angle = math.random() * math.pi * 2
            local radius = math.random() * 3.5 + 1
            targetPos = targetPos + Vector3.new(math.cos(angle) * radius, math.random(-1.5, 1.5), math.sin(angle) * radius)
        end

        local targetPlr = Players:GetPlayerFromCharacter(target.Parent)
        _lastAimbotTargetPlayer = targetPlr
        _lastAimbotTargetPos = targetPos
        
        local aimPos = targetPos


        local lockMethod = Flags["LockMethod"] or "Camera"
        local camCF = camera.CFrame
        
        -- Guard against zero-distance aim (target directly on camera) to prevent instability
        if (aimPos - camCF.Position).Magnitude < 0.5 then return end
        local targetCF = CFrame.lookAt(camCF.Position, aimPos)

        _aimbotSetCamera = true

        local cl = camCF.LookVector
        local tl = targetCF.LookVector
        local curYaw = math.atan2(-cl.X, -cl.Z)
        local curPitch = math.asin(math.clamp(cl.Y, -1, 1))
        local desYaw = math.atan2(-tl.X, -tl.Z)
        local desPitch = math.asin(math.clamp(tl.Y, -1, 1))

        local dYaw = (desYaw - curYaw + math.pi) % (2 * math.pi) - math.pi
        local dPitch = desPitch - curPitch
        local targetYaw, targetPitch

        -- 1. Apply Easing (Unified angle-space interpolation)
        if Flags["UseEasing"] and _aimEaseProgress < 1 then
            local speed = math.clamp(Flags["EaseSpeed"] or 70, 1, 200)
            local duration = math.clamp(0.4 - (speed / 200) * 0.35, 0.02, 0.4)
            _aimEaseProgress = math.min(_aimEaseProgress + dt / duration, 1)
            local easedT = applyEasing(_aimEaseProgress)

            if _aimStartCF then
                local srcL = _aimStartCF.LookVector
                local startYaw = math.atan2(-srcL.X, -srcL.Z)
                local startPitch = math.asin(math.clamp(srcL.Y, -1, 1))
                local totalDYaw = (desYaw - startYaw + math.pi) % (2 * math.pi) - math.pi
                local totalDPitch = desPitch - startPitch

                targetYaw = startYaw + totalDYaw * easedT
                targetPitch = startPitch + totalDPitch * easedT
            else
                targetYaw = curYaw + dYaw * easedT
                targetPitch = curPitch + dPitch * easedT
            end
        else
            targetYaw = desYaw
            targetPitch = desPitch
        end

        local virtualCF = CFrame.new(camCF.Position) * CFrame.fromEulerAnglesYXZ(targetPitch, targetYaw, 0)

        if lockMethod == "Mouse" then
            -- Project the raw aimPos directly to screen for stable, accurate pixel delta
            local desiredScreenPos, onScreen = camera:WorldToViewportPoint(aimPos)
            if onScreen then
                local dx = desiredScreenPos.X - UserInputService:GetMouseLocation().X
                local dy = desiredScreenPos.Y - UserInputService:GetMouseLocation().Y

            if Flags["UseSmoothing"] then
                    -- Simple lerp smoothing: each direction independent
                    local smoothX, smoothY
                    if Flags["UseAdvSmoothing"] then
                        smoothX = dx < 0 and (Flags["AdvSmoothRight"] or 16) or (Flags["AdvSmoothLeft"] or 16)
                        smoothY = dy > 0 and (Flags["AdvSmoothDown"] or 16) or (Flags["AdvSmoothUp"] or 16)
                    else
                        smoothX = Flags["SmoothX"] or 16
                        smoothY = Flags["SmoothY"] or 16
                    end
                    local rateX = math.clamp(1 - (smoothX / 100), 0.05, 0.99)
                    local rateY = math.clamp(1 - (smoothY / 100), 0.05, 0.99)
                    local dampX = 1 - math.pow(1 - rateX, dt * 60)
                    local dampY = 1 - math.pow(1 - rateY, dt * 60)
                    dx = dx * dampX
                    dy = dy * dampY
                    if math.abs(dx) < 0.2 then dx = 0 end
                    if math.abs(dy) < 0.2 then dy = 0 end

                    _mouseRemainderX = _mouseRemainderX + dx
                    _mouseRemainderY = _mouseRemainderY + dy
                    local intX = math.round(_mouseRemainderX)
                    local intY = math.round(_mouseRemainderY)
                    _mouseRemainderX = _mouseRemainderX - intX
                    _mouseRemainderY = _mouseRemainderY - intY
                    if intX ~= 0 or intY ~= 0 then
                        if mousemoverel then mousemoverel(intX, intY) end
                    end
                else
                    -- Raw fast path: instant full snap, no accumulation lag
                    local intX = math.round(dx)
                    local intY = math.round(dy)
                    if intX ~= 0 or intY ~= 0 then
                        if mousemoverel then mousemoverel(intX, intY) end
                    end
                end
            end
        elseif lockMethod == "Camera" then
            -- Camera Locking method
            -- Detect player's mouse input: difference between what we set and where camera is now
            local playerYawDelta = 0
            local playerPitchDelta = 0
            if _lastAimbotCF then
                local lastL = _lastAimbotCF.LookVector
                local lastYaw = math.atan2(-lastL.X, -lastL.Z)
                local lastPitch = math.asin(math.clamp(lastL.Y, -1, 1))
                playerYawDelta = (curYaw - lastYaw + math.pi) % (2 * math.pi) - math.pi
                playerPitchDelta = curPitch - lastPitch
            end
            
            local diffYaw = (targetYaw - curYaw + math.pi) % (2 * math.pi) - math.pi
            local diffPitch = targetPitch - curPitch

            -- 3. Apply Smoothing
            local shouldSmooth = Flags["UseSmoothing"]
            if Flags["UseEasing"] and _aimEaseProgress < 1 then
                shouldSmooth = false -- Bypass exponential smoothing while easing curve is actively animating
            end
            
            if shouldSmooth then
                local smoothX = Flags["SmoothX"] or 16
                local smoothY = Flags["SmoothY"] or 16
                if Flags["UseAdvSmoothing"] then
                    smoothX = diffYaw < 0 and (Flags["AdvSmoothRight"] or 16) or (Flags["AdvSmoothLeft"] or 16)
                    smoothY = diffPitch > 0 and (Flags["AdvSmoothUp"] or 16) or (Flags["AdvSmoothDown"] or 16)
                end
                if Flags["DelayJump"] and _lastTargetInAir and Flags["JumpSmooth"] then
                    smoothX = Flags["JumpSmooth"] or 16
                    smoothY = Flags["JumpSmooth"] or 16
                end
                -- Simple lerp: low value = fast snap, high value = slow glide
                local rateX = math.clamp(1 - (smoothX / 100), 0.05, 0.99)
                local rateY = math.clamp(1 - (smoothY / 100), 0.05, 0.99)
                -- Frame-rate independent: apply per-frame damping
                local dampX = 1 - math.pow(1 - rateX, dt * 60)
                local dampY = 1 - math.pow(1 - rateY, dt * 60)
                diffYaw = diffYaw * dampX
                diffPitch = diffPitch * dampY
            end

            -- Blend player mouse input: allow partial camera freedom while locked
            local finalYaw = curYaw + diffYaw
            local finalPitch = curPitch + diffPitch
            if Flags["UseMouseBlend"] then
                local blendX = (Flags["MouseBlendX"] or 30) / 100
                local blendY = (Flags["MouseBlendY"] or 30) / 100
                finalYaw = finalYaw + playerYawDelta * blendX
                finalPitch = finalPitch + playerPitchDelta * blendY
            end
            local finalCF = CFrame.new(camCF.Position) * CFrame.fromEulerAnglesYXZ(finalPitch, finalYaw, 0)

            camera.CFrame = finalCF
            _lastAimbotCF = finalCF
        end
    end)))
end)

_silentLockedTarget = nil
_silentCurrentPlayer = nil
_silentRayParams = RaycastParams.new()
_silentRayParams.FilterType = Enum.RaycastFilterType.Blacklist

hasSilentCheck = LPH_NO_VIRTUALIZE(function(checks, name)
    if type(checks) ~= "table" then return false end
    for _, v in ipairs(checks) do
        if v == name then return true end
    end
    return false
end)

_silentCheckChar = LPH_NO_VIRTUALIZE(function(char, checkDead, checkKnocked, checkWall, aimType, useFov, fovSize, ref, camPos, myChar, bestDist)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    if checkDead and (hum:GetState() == Enum.HumanoidStateType.Dead or isDeadCheck(char)) then return nil end
    if checkKnocked and isKnockedOrKO(char) then return nil end
    if hasSpawnProtection(char) then return nil end
    local hitPartName = Flags["SilentHitPart"] or "Head"
    local part
    if hitPartName == "Closest Part" then
        part = getClosestBodyPart(char)
    elseif hitPartName == "Torso" then
        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif hitPartName == "Legs" then
        part = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
    else
        part = char:FindFirstChild(hitPartName)
        if not part then
            if hitPartName == "UpperTorso" or hitPartName == "LowerTorso" then
                part = char:FindFirstChild("Torso")
            elseif hitPartName == "Neck" then
                part = char:FindFirstChild("Head")
            end
        end
    end
    if not part then return nil end
    if not part.Parent then return nil end
    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
    local dist
    if aimType == "Closest" then
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        dist = (myHrp.Position - hrp.Position).Magnitude
    else
        dist = (screenVec - ref).Magnitude
    end
    if useFov and dist > fovSize then return nil end
    if dist < bestDist then
        if checkWall and myChar then
            _silentRayParams.FilterDescendantsInstances = {myChar, char}
            local result = workspace:Raycast(camPos, part.Position - camPos, _silentRayParams)
            if result then return nil end
        end
        return part, dist
    end
    return nil
end)

getSilentAimTarget = LPH_JIT(function()
    if not Flags["SilentEnabled"] then return nil end
    if Flags["SilentSyncAimbot"] then
        if _lastTarget and _lastTarget.Parent and _lastTarget.Parent.Parent then
            local char = _lastTarget.Parent
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
                and not isKnockedOrKO(char) and not isDeadCheck(char) then
                return _lastTarget
            end
        end
        if lockedAimTarget and lockedAimTarget.Parent and lockedAimTarget.Name ~= "AimDeadSpot" then
            local char = lockedAimTarget.Parent
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
                and not isKnockedOrKO(char) and not isDeadCheck(char) then
                return lockedAimTarget
            end
        end
        return nil
    end
    local checks = Flags["SilentChecks"] or {}
    if type(checks) ~= "table" then checks = {} end
    local checkTeam = hasSilentCheck(checks, "Team")
    local checkDead = hasSilentCheck(checks, "Dead")
    local checkWall = hasSilentCheck(checks, "Wall")
    local checkKnocked = hasSilentCheck(checks, "Knocked")
    local checkNPC = hasSilentCheck(checks, "NPC")
    local useFov = Flags["SilentUseFOV"]
    local fovSize = Flags["SilentFOVSize"] or 100
    local aimType = Flags["SilentAimType"] or "Cursor"
    local targetLock = Flags["SilentTargetLock"]
    local myChar = lp.Character
    local camPos = camera.CFrame.Position
    local mousePos = UserInputService:GetMouseLocation()
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local ref = (aimType == "Center") and screenCenter or mousePos

    local bestTarget, bestDist = nil, math.huge

    if targetLock and _silentLockedTarget then
        local char = _silentLockedTarget.Parent
        if char and char.Parent then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                if not (checkKnocked and isKnockedOrKO(char)) and not (checkDead and isDeadCheck(char)) then
                    local hitPartName = Flags["SilentHitPart"] or "Head"
                    local part
                    if hitPartName == "Closest Part" then
                        part = getClosestBodyPart(char)
                    elseif hitPartName == "Torso" then
                        part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    elseif hitPartName == "Legs" then
                        part = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
                    else
                        part = char:FindFirstChild(hitPartName)
                        if not part then
                            if hitPartName == "UpperTorso" or hitPartName == "LowerTorso" then
                                part = char:FindFirstChild("Torso")
                            elseif hitPartName == "Neck" then
                                part = char:FindFirstChild("Head")
                            end
                        end
                    end
                    if part then
                        local sp, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local sv = Vector2.new(sp.X, sp.Y)
                            local lockDist = (sv - ref).Magnitude
                            if not useFov or lockDist <= fovSize then
                                bestTarget = part
                                bestDist = lockDist * 0.6
                            end
                        end
                    end
                end
            end
        end
        if not bestTarget then _silentLockedTarget = nil end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if checkTeam and lp.Team ~= nil and player.Team == lp.Team then continue end
        local char = player.Character
        if not char then continue end
        local part, dist = _silentCheckChar(char, checkDead, checkKnocked, checkWall, aimType, useFov, fovSize, ref, camPos, myChar, bestDist)
        if part then bestTarget = part; bestDist = dist end
    end

    if checkNPC then
        for _, bot in ipairs(getNPCs()) do
            local part, dist = _silentCheckChar(bot, checkDead, checkKnocked, checkWall, aimType, useFov, fovSize, ref, camPos, myChar, bestDist)
            if part then bestTarget = part; bestDist = dist end
        end
    end

    if targetLock and bestTarget then
        _silentLockedTarget = bestTarget
    end

    if bestTarget and bestTarget.Parent then
        _silentCurrentPlayer = Players:GetPlayerFromCharacter(bestTarget.Parent)
    else
        _silentCurrentPlayer = nil
    end

    return bestTarget
end)

_silentOldIndex = nil
_silentHooked = false
_cachedPing = 0
_pingCacheTime = 0
_getPing = function()
    local now = tick()
    if now - _pingCacheTime < 1 then return _cachedPing end
    _pingCacheTime = now
    local stats = game:GetService("Stats")
    local ps = stats:FindFirstChild("PerformanceStats")
    if ps then
        local pingStat = ps:FindFirstChild("Ping")
        if pingStat then _cachedPing = pingStat.Value end
    end
    return _cachedPing
end
setupSilentAimHook = function()
    if _silentHooked then return end
    if isWarlords then return end
    _silentHooked = true
    _silentOldIndex = hookmetamethod(game, "__index", LPH_NO_VIRTUALIZE(function(self, key)
        if _silentHooked and not checkcaller() then
            if Flags["SilentEnabled"] and (key == "Hit" or key == "Origin") then
                local target = getSilentAimTarget()
                if target and target.Parent then
                    local hitPartName = Flags["SilentHitPart"] or "Head"
                    local hitPos = target.Position
                    local tChar = target.Parent
                    if hitPartName == "Neck" then
                        local head = tChar:FindFirstChild("Head")
                        if head then
                            hitPos = head.Position - Vector3.new(0, head.Size.Y * 0.5, 0)
                        end
                    elseif hitPartName == "UpperTorso" then
                        local up = target.CFrame.UpVector
                        hitPos = target.Position + up * (target.Size.Y * 0.3)
                    elseif hitPartName == "LowerTorso" then
                        local up = target.CFrame.UpVector
                        hitPos = target.Position + up * (target.Size.Y * 0.15)
                    elseif hitPartName == "Torso" then
                        local up = target.CFrame.UpVector
                        hitPos = target.Position + up * (target.Size.Y * 0.15)
                    elseif hitPartName == "HumanoidRootPart" then
                        local up = target.CFrame.UpVector
                        hitPos = target.Position + up * 0.5
                    end
                    if Flags["SilentHitChanceEnabled"] then
                        local chance = Flags["SilentHitChance"] or 100
                        if math.random(1, 100) > chance then
                            return _silentOldIndex(self, key)
                        end
                    end
                    if key == "Hit" then
                        return CFrame.new(hitPos)
                    elseif key == "Origin" then
                        return CFrame.new(hitPos)
                    end
                end
            end
        end
        return _silentOldIndex(self, key)
    end))
end
setupSilentAimHook()

EspLibrary = {
    ['Cache'] = {},
    ['Threads'] = {},
    ['Connections'] = {},
    ['Holder'] = nil
}

-- Setup safe metatable for EspLibrary
local espMeta = {}
function espMeta:__index(key)
    return rawget(EspLibrary, key)
end
setmetatable(EspLibrary, espMeta)

SmallestPixel = Font.fromEnum(Enum.Font.Code)
TahomaBold = Font.fromEnum(Enum.Font.SourceSansBold)
Tahoma = Font.fromEnum(Enum.Font.SourceSans)
ProggyClean = Font.fromEnum(Enum.Font.Code)
ProggyTiny = Font.fromEnum(Enum.Font.Code)

pcall(function()
    local HttpService = game:GetService("HttpService")
    local function FontsRegister(Name, Weight, Style, Asset)
        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end
        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end
        local Info = {
            name = Name,
            faces = {
                {
                    name = "Normal",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                },
            },
        }
        writefile(Name .. ".font", HttpService:JSONEncode(Info))
        return getcustomasset(Name .. ".font")
    end;

    local f_tahoma = FontsRegister("Tahoma", 400, "Normal", {
        Id = "Tahoma.ttf",
        Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"),
    })
    local f_xptahoma = FontsRegister("XPTahoma", 400, "Normal", {
        Id = "Tahoma8PTBOLD.ttf",
        Font = game:HttpGet("https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/TAHOMA-8PT-BOLD-WINDOWS-XP.TTF"),
    })
    local f_pixel = FontsRegister("SmallestPixel", 400, "Normal", {
        Id = "smallest_pixel-7.ttf",
        Font = game:HttpGet("https://raw.githubusercontent.com/sametexe001/luas/main/smallest_pixel-7.ttf")
    })
    local f_proggy = FontsRegister("ProggyTiny", 400, "Normal", {
        Id = "ProggyTinyyyy.ttf",
        Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyTiny.ttf")
    })
    local f_proggyclean = FontsRegister("ProggyClean", 400, "Normal", {
        Id = "ProggyClean.ttf",
        Font = game:HttpGet("https://github.com/i77lhm/storage/raw/main/fonts/ProggyClean.ttf"),
    })
    
    ProggyTiny = Font.new(f_proggyclean, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    TahomaBold = Font.new(f_xptahoma, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    ProggyClean = Font.new(f_proggyclean, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Tahoma = Font.new(f_tahoma, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    SmallestPixel = Font.new(f_pixel, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end)

function EspLibrary:CreateObjects(Name, Prop)
    local New = Instance.new(Name)
    for Property, Value in Prop or {} do
        New[Property] = Value
    end
    return New
end

function EspLibrary:CreateThreads(Name, Signal, Callback)
    local Connection = Signal:Connect(Callback)
    self.Threads[Name] = Connection
    return Connection
end

parentGui = (function() if gethui then local ok, res = pcall(gethui); if ok and res then return res end end return game:GetService("CoreGui") end)() or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
EspLibrary.Holder = EspLibrary:CreateObjects("ScreenGui", {
    Name = "\n",
    Parent = parentGui,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    IgnoreGuiInset = true,
})

function EspLibrary:InitEsp(Data)
    local Objects = Data.Objects

    Objects["TargetHolder"] = self:CreateObjects("Frame", {
        Parent = self.Holder,
        Visible = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["TopHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["TargetHolder"],
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = true,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, -2, 0, -5),
        Size = UDim2.new(1, 4, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["BottomHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["TargetHolder"],
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -2, 1, 3),
        Size = UDim2.new(1, 4, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["LeftHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["TargetHolder"],
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = true,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(0, -5, 0, -2),
        Size = UDim2.new(0, 0, 1, 4),
        BorderSizePixel = 0,
    })

    Objects["RightHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["TargetHolder"],
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 5, 0, -2),
        Size = UDim2.new(0, 0, 1, 4),
        BorderSizePixel = 0,
    })

    Objects["TopTextHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["TopHolder"],
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["BottomTextHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["BottomHolder"],
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["LeftTextHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["LeftHolder"],
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["RightTextHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["RightHolder"],
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    Objects["LeftBarHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["LeftHolder"],
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
    })

    Objects["BottomBarHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["BottomHolder"],
        LayoutOrder = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["TopTextHolder"],
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["BottomTextHolder"],
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, -1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["LeftTextHolder"],
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["RightTextHolder"],
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["LeftBarHolder"],
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["BottomBarHolder"],
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["TopHolder"],
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["BottomHolder"],
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["LeftHolder"],
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIListLayout", {
        Parent = Objects["RightHolder"],
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["TopTextHolder"],
        PaddingBottom = UDim.new(0, 0),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["BottomTextHolder"],
        PaddingTop = UDim.new(0, -1)
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["LeftTextHolder"],
        PaddingTop = UDim.new(0, -3),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["RightTextHolder"],
        PaddingTop = UDim.new(0, -3),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["LeftBarHolder"],
        PaddingRight = UDim.new(0, 0),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["BottomBarHolder"],
        PaddingTop = UDim.new(0, 2),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["LeftHolder"],
        PaddingRight = UDim.new(0, 1),
    })

    Objects["BoxGlow"] = self:CreateObjects("ImageLabel", {
        Parent = Objects["TargetHolder"],
        Image = "rbxassetid://110204605000367",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)),
        ImageTransparency = 0.65,
        ResampleMode = Enum.ResamplerMode.Pixelated,
        Visible = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -21, 0, -21),
        BorderSizePixel = 0,
    })

    Objects["BoxGlowGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["BoxGlow"],
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}),
    })

    self:CreateObjects("UIPadding", {
        Parent = Objects["BoxGlow"],
        PaddingTop = UDim.new(0, 21),
        PaddingBottom = UDim.new(0, 21),
        PaddingLeft = UDim.new(0, 21),
        PaddingRight = UDim.new(0, 21),
    })

    Objects["BoxOutlineHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["BoxGlow"],
        Visible = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Objects["BoxOutline"] = self:CreateObjects("UIStroke", {
        Parent = Objects["BoxOutlineHolder"],
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["BoxOutlineGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["BoxOutline"],
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        }),
    })

    Objects["BoxInlineHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["BoxGlow"],
        Visible = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 1, 0, 1),
        BorderSizePixel = 0,
    })

    Objects["BoxInline"] = self:CreateObjects("UIStroke", {
        Parent = Objects["BoxInlineHolder"],
        Color = Color3.fromRGB(255, 255, 255),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["BoxInlineGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["BoxInline"],
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
    })

    Objects["BoxFill"] = self:CreateObjects("Frame", {
        Parent = Objects["BoxGlow"],
        Visible = false,
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 1, 0, 1),
        BorderSizePixel = 0,
    })

    Objects["BoxFillGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["BoxFill"],
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        }),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1)}),
    })

    Objects["CornerHolder"] = self:CreateObjects("Frame", {
        Parent = Objects["BoxGlow"],
        Visible = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
    })

    for i = 1, 8 do
        Objects["Line_" .. i] = self:CreateObjects("Frame", {
            Parent = Objects["CornerHolder"],
            Visible = false,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        })
        self:CreateObjects("UIStroke", {
            Parent = Objects["Line_" .. i],
            Thickness = 1,
            LineJoinMode = Enum.LineJoinMode.Miter,
        })
    end

    Objects["HealthBarOutline"] = self:CreateObjects("Frame", {
        Parent = Objects["LeftBarHolder"],
        ZIndex = 5,
        LayoutOrder = 0,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        ClipsDescendants = false,
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["HealthBarOutline"],
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["HealthBar"] = self:CreateObjects("Frame", {
        Parent = Objects["HealthBarOutline"],
        ZIndex = 6,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ClipsDescendants = true,
    })

    Objects["HealthBarGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["HealthBar"],
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 170, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    })

    Objects["HealthBarText"] = self:CreateObjects("TextLabel", {
        Parent = Objects["HealthBarOutline"],
        FontFace = SmallestPixel,
        TextSize = 9,
        ZIndex = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 1, 0),
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["HealthBarText"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["ArmorBarOutline"] = self:CreateObjects("Frame", {
        Parent = Objects["BottomBarHolder"],
        ZIndex = 5,
        LayoutOrder = 0,
        Visible = false,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        ClipsDescendants = true,
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["ArmorBarOutline"],
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["ArmorBar"] = self:CreateObjects("Frame", {
        Parent = Objects["ArmorBarOutline"],
        ZIndex = 6,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    })

    Objects["ArmorBarGradient"] = self:CreateObjects("UIGradient", {
        Parent = Objects["ArmorBar"],
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
        }),
    })

    Objects["ArmorBarText"] = self:CreateObjects("TextLabel", {
        Parent = Objects["ArmorBar"],
        FontFace = SmallestPixel,
        TextSize = 9,
        ZIndex = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["ArmorBarText"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["TargetName"] = self:CreateObjects("TextLabel", {
        Parent = Objects["TopTextHolder"],
        FontFace = TahomaBold,
        TextSize = 12,
        LayoutOrder = 2,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["TargetName"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["Distance"] = self:CreateObjects("TextLabel", {
        Parent = Objects["BottomTextHolder"],
        FontFace = SmallestPixel,
        TextSize = 9,
        LayoutOrder = 2,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["Distance"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["WalkFlag"] = self:CreateObjects("TextLabel", {
        Parent = Objects["RightTextHolder"],
        FontFace = SmallestPixel,
        TextSize = 9,
        LayoutOrder = 1,
        TextColor3 = Color3.fromRGB(255, 0, 0),
        Text = "Walking",
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["WalkFlag"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["JumpFlag"] = self:CreateObjects("TextLabel", {
        Parent = Objects["RightTextHolder"],
        FontFace = SmallestPixel,
        TextSize = 9,
        LayoutOrder = 2,
        TextColor3 = Color3.fromRGB(144, 238, 144),
        Text = "Jumping",
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["JumpFlag"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["SwimmingFlag"] = self:CreateObjects("TextLabel", {
        Parent = Objects["RightTextHolder"],
        FontFace = SmallestPixel,
        TextSize = 9,
        LayoutOrder = 4,
        TextColor3 = Color3.fromRGB(0, 255, 255),
        Text = "Swimming",
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["SwimmingFlag"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["ToolIcon"] = self:CreateObjects("ImageLabel", {
        Parent = Objects["BottomTextHolder"],
        Image = "",
        ScaleType = Enum.ScaleType.Stretch,
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Size = UDim2.new(0, 16, 0, 16),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["ToolIcon"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
        Enabled = false,
    })

    Objects["Weapon"] = self:CreateObjects("TextLabel", {
        Parent = Objects["BottomTextHolder"],
        FontFace = SmallestPixel,
        TextSize = 9,
        LayoutOrder = 3,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = "none",
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0,
        Visible = false,
        BackgroundTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
    })

    self:CreateObjects("UIStroke", {
        Parent = Objects["Weapon"],
        Color = Color3.fromRGB(0, 0, 0),
        LineJoinMode = Enum.LineJoinMode.Miter,
    })

    Objects["TracerOutline"] = safeDrawing("Line")
    Objects["TracerOutline"].Visible = false
    Objects["TracerOutline"].Thickness = 1.5
    Objects["TracerOutline"].Color = Color3.fromRGB(0, 0, 0)
    Objects["TracerOutline"].ZIndex = 1

    Objects["TracerInline"] = safeDrawing("Line")
    Objects["TracerInline"].Visible = false
    Objects["TracerInline"].Thickness = 1
    Objects["TracerInline"].Color = Color3.fromRGB(255, 255, 255)
    Objects["TracerInline"].ZIndex = 2
end

getColor = LPH_NO_VIRTUALIZE(function(flagName, default)
    local val = Flags[flagName]
    if typeof(val) == "Color3" then
        return val
    elseif type(val) == "table" then
        if val.RGBMode and val.RGBMode ~= "Static" then
            local speed = val.RGBSpeed or 5
            local t = tick()
            local baseH, baseS, baseV = (val.Color or default):ToHSV()
            if val.RGBMode == "Rainbow" then
                local hue = (t * speed / 10) % 1
                return Color3.fromHSV(hue, baseS, baseV)
            elseif val.RGBMode == "Gradient" then
                local hue = (t * speed / 10) % 1
                return Color3.fromHSV(hue, 1, baseV)
            elseif val.RGBMode == "Pulse" then
                local pulse = 0.5 + 0.5 * math.sin(t * speed / 3)
                return Color3.fromHSV(baseH, baseS, pulse)
            elseif val.RGBMode == "Hue Shift" then
                local hue = (t * speed / 5) % 1
                return Color3.fromHSV(hue, baseS, baseV)
            elseif val.RGBMode == "Breathe" then
                local breathe = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * speed / 4))
                return Color3.fromHSV(baseH, baseS, breathe)
            end
        end
        if typeof(val.Color) == "Color3" then
            return val.Color
        end
    end
    return default
end)

getESPFont = LPH_NO_VIRTUALIZE(function()
    local selected = Flags["ESP_Font"] or "ProggyClean"
    if selected == "SmallestPixel" then
        return SmallestPixel
    elseif selected == "Tahoma" then
        return Tahoma
    elseif selected == "TahomaBold" then
        return TahomaBold
    elseif selected == "Arial" then
        return Font.fromEnum(Enum.Font.Arial)
    elseif selected == "SourceSans" then
        return Font.fromEnum(Enum.Font.SourceSans)
    end
    return ProggyClean
end)

CornerLayout = {
    {UDim2.new(0, -1, 0, -1), UDim2.new(0.2, 0, 0, 1), Vector2.new(0, 0), 0},
    {UDim2.new(0, -1, 0, -1), UDim2.new(0, 1, 0.2, 0), Vector2.new(0, 0), 180},
    {UDim2.new(1, 1, 0, -1), UDim2.new(0.2, 0, 0, 1), Vector2.new(1, 0), 0},
    {UDim2.new(1, 1, 0, -1), UDim2.new(0, 1, 0.2, 0), Vector2.new(1, 0), 180},
    {UDim2.new(0, -1, 1, 1), UDim2.new(0.2, 0, 0, 1), Vector2.new(0, 1), 0},
    {UDim2.new(0, -1, 1, 1), UDim2.new(0, 1, 0.2, 0), Vector2.new(0, 1), -180},
    {UDim2.new(1, 1, 1, 1), UDim2.new(0.2, 0, 0, 1), Vector2.new(1, 1), 0},
    {UDim2.new(1, 1, 1, 1), UDim2.new(0, 1, 0.2, 0), Vector2.new(1, 1), -180},
}

EspLibrary.CalculateBox = LPH_NO_VIRTUALIZE(function(self, Data)
    local RootPart = Data['RootPart']
    if not RootPart then
        return nil, nil, nil, nil, false
    end

    local RootScreen, OnScreen = camera:WorldToViewportPoint(RootPart.Position)
    if not OnScreen then
        return nil, nil, nil, nil, false
    end

    if Flags["ESP_DynamicBoxes"] or true then
        local Children = Data['Children']
        if not Children then
            return nil, nil, nil, nil, false
        end

        local IncludeAccessories = false
        local ScrMinX, ScrMinY = math.huge, math.huge
        local ScrMaxX, ScrMaxY = -math.huge, -math.huge
        local HasValidParts = false

        for _, Part in ipairs(Children) do
            if Part:IsA('BasePart') and Part.Transparency ~= 1 and Part ~= RootPart then
                local Parent = Part.Parent
                if Parent == nil then continue end
                if not IncludeAccessories and Parent:IsA('Accessory') then
                    continue
                end

                local PartScreen, PartOnScreen = camera:WorldToViewportPoint(Part.Position)
                if not PartOnScreen or PartScreen.Z <= 0 then
                    continue
                end

                HasValidParts = true
                local Cf = Part.CFrame
                local Sz = Part.Size
                local HX, HY, HZ = Sz.X * 0.5, Sz.Y * 0.5, Sz.Z * 0.5
                local RX, UY, LZ = Cf.RightVector, Cf.UpVector, Cf.LookVector
                
                local vPortY = camera.ViewportSize.Y
                local focalLength = vPortY / (2 * math.tan(math.rad(camera.FieldOfView) * 0.5))
                local DepthScale = focalLength / PartScreen.Z

                local Ex = (math.abs(RX.X * HX) + math.abs(UY.X * HY) + math.abs(LZ.X * HZ)) * DepthScale
                local Ey = (math.abs(RX.Y * HX) + math.abs(UY.Y * HY) + math.abs(LZ.Y * HZ)) * DepthScale

                local PMinX, PMaxX = PartScreen.X - Ex, PartScreen.X + Ex
                local PMinY, PMaxY = PartScreen.Y - Ey, PartScreen.Y + Ey

                if PMinX < ScrMinX then ScrMinX = PMinX end
                if PMaxX > ScrMaxX then ScrMaxX = PMaxX end
                if PMinY < ScrMinY then ScrMinY = PMinY end
                if PMaxY > ScrMaxY then ScrMaxY = PMaxY end
            end
        end

        if not HasValidParts then
            return nil, nil, nil, nil, false
        end

        local PadX = 0
        local PadY = 0
        local W = (ScrMaxX - ScrMinX) + PadX
        local H = (ScrMaxY - ScrMinY) + PadY

        return W, H, ScrMinX - (PadX * 0.5), ScrMinY - (PadY * 0.5), true
    else
        local vPortY = camera.ViewportSize.Y
        local Scale = (RootPart.Size.Y * vPortY) / (RootScreen.Z * 2)
        local W, H = 3 * Scale, 4.5 * Scale
        return W, H, RootScreen.X - (W * 0.5), RootScreen.Y - (H * 0.5), OnScreen
    end
end)

function EspLibrary:AddTarget(Target)
    if self.Cache[Target] then return end

    local isPlayer = Target:IsA("Player")
    if isPlayer and Target == lp then
        local showOn = Flags["ESP_ShowOn"] or {}
        if not hasCheck(showOn, "Self") then return end
    end

    local Data = {
        ['Target'] = Target,
        ['IsPlayer'] = isPlayer,
        ['Objects'] = {},
        ['Conns'] = {},
        ['Character'] = nil,
        ['RootPart'] = nil,
        ['Humanoid'] = nil,
        ['Children'] = nil,
        ['Health'] = 0,
        ['MaxHealth'] = 100,
        ['Armor'] = 100,
        ['MaxArmor'] = 100,
        ['CurrentTool'] = nil,
        ['Alive'] = false,
        ['LastW'] = nil,
        ['LastH'] = nil,
        ['LastX'] = nil,
        ['LastY'] = nil,
        ['WalkActive'] = false,
        ['JumpActive'] = false,
        ['FallingActive'] = false,
        ['SwimmingActive'] = false,
        ['LastGlowTop'] = nil,
        ['LastGlowBot'] = nil,
        ['LastGlowT1'] = nil,
        ['LastGlowT2'] = nil,
        ['LastGradTop'] = nil,
        ['LastGradBot'] = nil,
        ['LastFillTop'] = nil,
        ['LastFillBot'] = nil,
        ['LastFillT1'] = nil,
        ['LastFillT2'] = nil,
        ['LastDist'] = nil,
        ['LastDistColor'] = nil,
        ['LastDisplayName'] = nil,
        ['LastNameColor'] = nil,
        ['LastHealthTop'] = nil,
        ['LastHealthMid'] = nil,
        ['LastHealthBot'] = nil,
        ['LastHealthFloor'] = nil,
        ['LastRatio'] = nil,
        ['LastArmorTop'] = nil,
        ['LastArmorMid'] = nil,
        ['LastArmorBot'] = nil,
        ['LastArmorFloor'] = nil,
        ['LastArmorRatio'] = nil,
        ['LastWeapon'] = nil,
        ['LastWeaponColor'] = nil,
    }
    
    self:InitEsp(Data)
    self['Cache'][Target] = Data

    local HealthHandler = {}
    function HealthHandler.BindHealth(Humanoid)
        if Data['Conns']['Health'] then Data['Conns']['Health']:Disconnect() end
        if Data['Conns']['Died'] then Data['Conns']['Died']:Disconnect() end

        Data['Humanoid'] = Humanoid
        Data['Health'] = Humanoid.Health
        Data['MaxHealth'] = Humanoid.MaxHealth
        Data['Alive'] = Humanoid.Health > 0

        Data['Conns']['Health'] = Humanoid.HealthChanged:Connect(function(NewHealth)
            Data['Alive'] = NewHealth > 0
            Data['Health'] = NewHealth
        end)

        Data['Conns']['Died'] = Humanoid.Died:Connect(function()
            Data['Alive'] = false
        end)
    end
    Data['BindHealth'] = HealthHandler.BindHealth

    local ToolHandler = {}
    function ToolHandler.BindTool(Character)
        if Data['Conns']['ToolAdded'] then Data['Conns']['ToolAdded']:Disconnect() end
        if Data['Conns']['ToolRemoved'] then Data['Conns']['ToolRemoved']:Disconnect() end

        if Data['Children'] then
            for _, Child in ipairs(Data['Children']) do
                if Child:IsA('Tool') then
                    Data['CurrentTool'] = Child.Name
                    Data['CurrentToolInstance'] = Child
                    break
                end
            end
        end

        Data['Conns']['ToolAdded'] = Character.ChildAdded:Connect(function(Child)
            if Child:IsA('Tool') then
                Data['CurrentTool'] = Child.Name
                Data['CurrentToolInstance'] = Child
            end
        end)

        Data['Conns']['ToolRemoved'] = Character.ChildRemoved:Connect(function(Child)
            if Child:IsA('Tool') then
                Data['CurrentTool'] = nil
                Data['CurrentToolInstance'] = nil
            end
        end)
    end
    Data['BindTool'] = ToolHandler.BindTool

    local ChildHandler = {}
    function ChildHandler.BindChildren(Character)
        if Data['Conns']['ChildAdded'] then Data['Conns']['ChildAdded']:Disconnect() end
        if Data['Conns']['ChildRemoved'] then Data['Conns']['ChildRemoved']:Disconnect() end

        local Children = Character:GetChildren()
        Data['Children'] = Children

        Data['Conns']['ChildAdded'] = Character.ChildAdded:Connect(function(Child)
            table.insert(Children, Child)
        end)

        Data['Conns']['ChildRemoved'] = Character.ChildRemoved:Connect(function(Child)
            local idx = table.find(Children, Child)
            if idx then
                table.remove(Children, idx)
            end
        end)

        Data['BindTool'](Character)
    end
    Data['BindChildren'] = ChildHandler.BindChildren

    local FlagsHandler = {}
    function FlagsHandler.BindFlags(Humanoid)
        if Data['Conns']['MoveDir'] then Data['Conns']['MoveDir']:Disconnect() end
        if Data['Conns']['StateChange'] then Data['Conns']['StateChange']:Disconnect() end

        local Objects = Data['Objects']
        Data['JumpActive'] = false
        Data['WalkActive'] = false
        Data['FallingActive'] = false
        Data['SwimmingActive'] = false

        Objects['WalkFlag'].Visible = false
        Objects['JumpFlag'].Visible = false
        Objects['SwimmingFlag'].Visible = false

        Data['Conns']['MoveDir'] = Humanoid:GetPropertyChangedSignal('MoveDirection'):Connect(function()
            local Walking = Humanoid.MoveDirection ~= Vector3.zero
            if Walking and not Data['WalkActive'] then
                Data['WalkActive'] = true
                if Data['JumpActive'] then
                    Objects['WalkFlag'].LayoutOrder = 2
                else
                    Objects['WalkFlag'].LayoutOrder = 1
                    Objects['JumpFlag'].LayoutOrder = 2
                end
                Objects['WalkFlag'].Visible = Flags["ESP_FlagsEnabled"] or false
            elseif not Walking and Data['WalkActive'] then
                Data['WalkActive'] = false
                Objects['WalkFlag'].Visible = false
                if Data['JumpActive'] then
                    Objects['JumpFlag'].LayoutOrder = 1
                end
            end
        end)

        Data['Conns']['StateChange'] = Humanoid.StateChanged:Connect(function(_, NewState)
            if NewState == Enum.HumanoidStateType.Freefall and not Data['JumpActive'] then
                Data['JumpActive'] = true
                if Data['WalkActive'] then
                    Objects['JumpFlag'].LayoutOrder = 2
                else
                    Objects['JumpFlag'].LayoutOrder = 1
                    Objects['WalkFlag'].LayoutOrder = 2
                end
                Objects['JumpFlag'].Visible = Flags["ESP_FlagsEnabled"] or false
            elseif NewState ~= Enum.HumanoidStateType.Jumping and Data['JumpActive'] then
                Data['JumpActive'] = false
                Objects['JumpFlag'].Visible = false
                if Data['WalkActive'] then
                    Objects['WalkFlag'].LayoutOrder = 1
                end
            end

            if NewState == Enum.HumanoidStateType.Swimming and not Data['SwimmingActive'] then
                Data['SwimmingActive'] = true
                Objects['SwimmingFlag'].Visible = Flags["ESP_FlagsEnabled"] or false
            elseif NewState ~= Enum.HumanoidStateType.Swimming and Data['SwimmingActive'] then
                Data['SwimmingActive'] = false
                Objects['SwimmingFlag'].Visible = false
            end
        end)
    end
    Data['BindFlags'] = FlagsHandler.BindFlags

    local CharacterHandler = {}
    function CharacterHandler.OnCharacter(Character)
        Data['Character'] = Character
        Data['RootPart'] = nil
        Data['Humanoid'] = nil
        Data['Children'] = nil
        Data['Alive'] = false
        Data['WalkActive'] = false
        Data['JumpActive'] = false
        Data['FallingActive'] = false
        Data['SwimmingActive'] = false

        if not Character or not Character.Parent then return end

        local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 5)
        local Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid", 5)

        if not RootPart or not Humanoid then return end
        if not Character.Parent then return end

        Data['RootPart'] = RootPart
        Data['Humanoid'] = Humanoid

        Data['BindChildren'](Character)
        Data['BindHealth'](Humanoid)
        Data['BindFlags'](Humanoid)
    end

    if isPlayer then
        Data['Conns']['CharAdded'] = Target.CharacterAdded:Connect(function(Character)
            task.defer(CharacterHandler.OnCharacter, Character)
        end)
        if Target.Character and Target.Character.Parent then
            task.defer(CharacterHandler.OnCharacter, Target.Character)
        end
    else
        task.defer(CharacterHandler.OnCharacter, Target)
    end
end

function EspLibrary:RemoveTarget(Target)
    local Data = self['Cache'][Target]
    if not Data then return end

    for _, Conn in pairs(Data['Conns']) do
        Conn:Disconnect()
    end
    table.clear(Data['Conns'])

    if Data['Objects']['TracerOutline'] then
        Data['Objects']['TracerOutline']:Remove()
    end
    if Data['Objects']['TracerInline'] then
        Data['Objects']['TracerInline']:Remove()
    end
    if Data['Objects']['TargetHolder'] then
        Data['Objects']['TargetHolder']:Destroy()
    end
    table.clear(Data['Objects'])
    self['Cache'][Target] = nil
end

EspLibrary.Update = LPH_JIT(function(self, Target, Data)
    local Objects = Data['Objects']

    if not Data['RootPart'] or not Data['Alive'] then
        if Objects['TargetHolder'].Visible then
            Objects['TargetHolder'].Visible = false
        end
        if Objects['TracerOutline'] then Objects['TracerOutline'].Visible = false end
        if Objects['TracerInline'] then Objects['TracerInline'].Visible = false end
        return
    end

    local RootPos = Data['RootPart'].Position
    local Distance = math.floor((camera.CFrame.Position - RootPos).Magnitude)
    local MaxDist = Flags["ESP_MaxDistance"] or 3000

    if Distance > MaxDist then
        if Objects['TargetHolder'].Visible then
            Objects['TargetHolder'].Visible = false
        end
        if Objects['TracerOutline'] then Objects['TracerOutline'].Visible = false end
        if Objects['TracerInline'] then Objects['TracerInline'].Visible = false end
        return
    end

    local W, H, X, Y, OnScreen = self:CalculateBox(Data)
    if not OnScreen or not W then
        if Objects['TargetHolder'].Visible then
            Objects['TargetHolder'].Visible = false
        end
        if Objects['TracerOutline'] then Objects['TracerOutline'].Visible = false end
        if Objects['TracerInline'] then Objects['TracerInline'].Visible = false end
        return
    end

    local selectedFont = getESPFont()
    Objects['TargetName'].FontFace = selectedFont
    Objects['Distance'].FontFace = selectedFont
    Objects['HealthBarText'].FontFace = selectedFont
    Objects['ArmorBarText'].FontFace = selectedFont
    Objects['Weapon'].FontFace = selectedFont
    Objects['WalkFlag'].FontFace = selectedFont
    Objects['JumpFlag'].FontFace = selectedFont
    Objects['SwimmingFlag'].FontFace = selectedFont

    W = math.floor(W)
    H = math.floor(H)
    X = math.floor(X)
    Y = math.floor(Y)

    if not Objects['TargetHolder'].Visible then
        Objects['TargetHolder'].Visible = true
    end

    local DirtySizes = Data['LastW'] ~= W or Data['LastH'] ~= H
    local DirtyPosition = Data['LastX'] ~= X or Data['LastY'] ~= Y

    if DirtyPosition then
        Objects['TargetHolder'].Position = UDim2.fromOffset(X, Y)
        Data['LastX'] = X
        Data['LastY'] = Y
    end

    if DirtySizes then
        Objects['TargetHolder'].Size = UDim2.fromOffset(W, H)
        Objects['BoxGlow'].Size = UDim2.fromOffset(W + 42, H + 42)
        Objects['BoxOutlineHolder'].Size = UDim2.fromOffset(W + 2, H + 2)
        Objects['BoxInlineHolder'].Size = UDim2.fromOffset(W, H)
        Objects['BoxFill'].Size = UDim2.fromOffset(W, H)
        Objects['CornerHolder'].Size = UDim2.fromOffset(W + 2, H + 2)
        Data['LastW'] = W
        Data['LastH'] = H
    end

    local BoxEnabled = Flags["ESP_BoxEnabled"] or false
    if BoxEnabled then
        local BoxShape = Flags["ESP_BoxShape"] or "Full"
        local InlineColor = getColor("ESP_BoxInlineColor", Color3.fromRGB(255, 255, 255))
        local OutlineColor = getColor("ESP_BoxOutlineColor", Color3.fromRGB(0, 0, 0))
        
        local BoxThickness = 1
        
        local GlowEnabled = Flags["ESP_BoxGlowEnabled"] or false
        local GlowAmount = (Flags["ESP_BoxGlowAmount"] or 65) / 100
        if GlowEnabled then
            Objects['BoxGlow'].ImageTransparency = 1 - GlowAmount
            Objects['BoxGlowGradient'].Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, getColor("ESP_BoxGlowColor", InlineColor)),
                ColorSequenceKeypoint.new(1, getColor("ESP_BoxGlowColor", InlineColor))
            })
        else
            Objects['BoxGlow'].ImageTransparency = 1
        end

        if BoxShape == "Cornered" then
            Objects['BoxOutlineHolder'].Visible = false
            Objects['BoxInlineHolder'].Visible = false
            Objects['BoxFill'].Visible = false
            Objects['CornerHolder'].Visible = true

            for i = 1, 8 do
                local Line = Objects['Line_' .. i]
                local Stroke = Line:FindFirstChildOfClass('UIStroke')
                local LayoutEntry = CornerLayout[i]
                
                Line.Position = LayoutEntry[1]
                Line.Size = LayoutEntry[2]
                Line.AnchorPoint = LayoutEntry[3]
                Line.Rotation = LayoutEntry[4]
                Line.BackgroundColor3 = InlineColor
                if Stroke then
                    Stroke.Color = OutlineColor
                    Stroke.Thickness = BoxThickness
                end
                Line.Visible = true
            end
        else
            Objects['CornerHolder'].Visible = false
            for i = 1, 8 do
                Objects['Line_' .. i].Visible = false
            end
            Objects['BoxOutlineHolder'].Visible = true
            Objects['BoxInlineHolder'].Visible = true
            
            Objects['BoxOutline'].Thickness = BoxThickness + 1
            Objects['BoxInline'].Thickness = BoxThickness
            Objects['BoxInlineGradient'].Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, InlineColor),
                ColorSequenceKeypoint.new(1, InlineColor)
            })
            Objects['BoxOutlineGradient'].Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, OutlineColor),
                ColorSequenceKeypoint.new(1, OutlineColor)
            })

            local FillEnabled = Flags["ESP_BoxFillEnabled"] or false
            if FillEnabled then
                Objects['BoxFill'].Visible = true
                local fillTrans1 = (Flags["ESP_BoxFillTrans1"] or 100) / 100
                local fillTrans2 = (Flags["ESP_BoxFillTrans2"] or 65) / 100
                local fillColor = getColor("ESP_BoxFillColor", Color3.fromRGB(255, 255, 255))
                Objects['BoxFillGradient'].Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, fillColor),
                    ColorSequenceKeypoint.new(1, fillColor)
                })
                Objects['BoxFillGradient'].Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, fillTrans1),
                    NumberSequenceKeypoint.new(1, fillTrans2)
                })
            else
                Objects['BoxFill'].Visible = false
            end
        end
    else
        Objects['BoxGlow'].ImageTransparency = 1
        Objects['BoxOutlineHolder'].Visible = false
        Objects['BoxInlineHolder'].Visible = false
        Objects['BoxFill'].Visible = false
        Objects['CornerHolder'].Visible = false
        for i = 1, 8 do
            Objects['Line_' .. i].Visible = false
        end
    end

    local NameEnabled = Flags["ESP_NameEnabled"] or false
    local espTextSize = Flags["ESP_TextSize"] or 11
    local espTextOutline = Flags["ESP_TextOutline"] ~= false
    if NameEnabled then
        Objects['TargetName'].Visible = true
        
        local namePos = Flags["ESP_TextPos"] or "Top"
        local nameHolder = Objects[namePos .. "TextHolder"]
        if nameHolder and Objects["TargetName"].Parent ~= nameHolder then
            Objects["TargetName"].Parent = nameHolder
        end

        local nameStr = ""
        if Data.IsPlayer then
            local nameType = Flags["ESP_NameType"] or "Display Name"
            if nameType == "Display Name" then
                nameStr = Target.DisplayName
            elseif nameType == "Username" then
                nameStr = Target.Name
            else
                nameStr = Target.DisplayName .. " (@" .. Target.Name .. ")"
            end
        else
            nameStr = Target.Name
        end

        if Data['LastDisplayName'] ~= nameStr then
            Objects['TargetName'].Text = nameStr
            Data['LastDisplayName'] = nameStr
        end

        Objects['TargetName'].TextColor3 = getColor("ESP_NameInlineColor", Color3.fromRGB(255, 255, 255))
        Objects['TargetName'].TextSize = espTextSize
        local stroke = Objects['TargetName']:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = getColor("ESP_NameOutlineColor", Color3.fromRGB(0, 0, 0))
            stroke.Enabled = espTextOutline
        end
    else
        Objects['TargetName'].Visible = false
    end

    local DistEnabled = Flags["ESP_DistanceEnabled"] or false
    if DistEnabled then
        Objects['Distance'].Visible = true

        local distPos = Flags["ESP_TextPos"] or "Top"
        local distHolder = Objects[distPos .. "TextHolder"]
        if distHolder and Objects["Distance"].Parent ~= distHolder then
            Objects["Distance"].Parent = distHolder
        end

        local unit = Flags["ESP_DistanceType"] or "Studs"
        local distVal = Distance
        local suffix = "st"
        if unit == "Meters" then
            distVal = math.floor(Distance * 0.3048)
            suffix = "m"
        end

        if Data['LastDist'] ~= distVal then
            Objects['Distance'].Text = string.format("%d%s", distVal, suffix)
            Data['LastDist'] = distVal
        end

        Objects['Distance'].TextColor3 = getColor("ESP_DistanceInlineColor", Color3.fromRGB(255, 255, 255))
        Objects['Distance'].TextSize = espTextSize
        local stroke = Objects['Distance']:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = getColor("ESP_DistanceOutlineColor", Color3.fromRGB(0, 0, 0))
            stroke.Enabled = espTextOutline
        end
    else
        Objects['Distance'].Visible = false
    end

    local HealthBarEnabled = Flags["ESP_HealthBarEnabled"] or false
    if HealthBarEnabled then
        Objects['LeftBarHolder'].Visible = true
        Objects['HealthBarOutline'].Visible = true
        
        local Health = Data['Health'] or 0
        local MaxHealth = Data['MaxHealth'] or 100
        local Ratio = math.clamp(Health / MaxHealth, 0, 1)

        if Data['LastRatio'] ~= Ratio then
            Objects['HealthBar'].Size = UDim2.new(1, 0, Ratio, 0)
            Data['LastRatio'] = Ratio
        end

        local stroke = Objects['HealthBarOutline']:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = getColor("ESP_HealthBarOutlineColor", Color3.fromRGB(0, 0, 0))
        end

        local GradEnabled = Flags["ESP_HealthBarGradientEnabled"] or false
        if GradEnabled then
            local gTop = getColor("ESP_HealthBarTopColor", Color3.fromRGB(0, 255, 0))
            local gMid = getColor("ESP_HealthBarMidColor", Color3.fromRGB(255, 170, 0))
            local gBot = getColor("ESP_HealthBarBotColor", Color3.fromRGB(255, 0, 0))
            Objects['HealthBarGradient'].Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, gTop),
                ColorSequenceKeypoint.new(0.5, gMid),
                ColorSequenceKeypoint.new(1, gBot),
            })
        else
            local flatClr = getColor("ESP_HealthBarInlineColor", Color3.fromRGB(0, 255, 0))
            Objects['HealthBarGradient'].Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, flatClr),
                ColorSequenceKeypoint.new(1, flatClr)
            })
        end

        local HealthTextEnabled = Flags["ESP_HealthTextEnabled"] or false
        if HealthTextEnabled then
            Objects['HealthBarText'].Visible = true
            local flooredH = math.floor(Health)
            if Data['LastHealthFloor'] ~= flooredH then
                Objects['HealthBarText'].Text = string.format("%d", flooredH)
                Objects['HealthBarText'].Position = UDim2.new(1, -10, 1 - Ratio, 1)
                Data['LastHealthFloor'] = flooredH
            end
            Objects['HealthBarText'].TextColor3 = getColor("ESP_HealthTextInlineColor", Color3.fromRGB(255, 255, 255))
            local textStroke = Objects['HealthBarText']:FindFirstChildOfClass("UIStroke")
            if textStroke then
                textStroke.Color = getColor("ESP_HealthTextOutlineColor", Color3.fromRGB(0, 0, 0))
            end
        else
            Objects['HealthBarText'].Visible = false
        end
    else
        Objects['HealthBarOutline'].Visible = false
        Objects['HealthBarText'].Visible = false
        if not (Flags["ESP_ArmorBarEnabled"] or false) then
            Objects['LeftBarHolder'].Visible = false
        end
    end

    local ArmorBarEnabled = Flags["ESP_ArmorBarEnabled"] or false
    if ArmorBarEnabled then
        Objects['BottomBarHolder'].Visible = true
        Objects['ArmorBarOutline'].Visible = true

        local Ratio = math.clamp(Data['Armor'] / Data['MaxArmor'], 0, 1)
        if Data['LastArmorRatio'] ~= Ratio then
            Objects['ArmorBar'].Size = UDim2.new(Ratio, 0, 1, 0)
            Data['LastArmorRatio'] = Ratio
        end

        local stroke = Objects['ArmorBarOutline']:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = getColor("ESP_ArmorBarOutlineColor", Color3.fromRGB(0, 0, 0))
        end
        Objects['ArmorBar'].BackgroundColor3 = getColor("ESP_ArmorBarInlineColor", Color3.fromRGB(255, 255, 255))
    else
        Objects['ArmorBarOutline'].Visible = false
        Objects['ArmorBarText'].Visible = false
        Objects['BottomBarHolder'].Visible = false
    end

    local ToolIconEnabled = Flags["ESP_ToolIconEnabled"] or false
    if ToolIconEnabled then
        local toolInst = Data['CurrentToolInstance']
        if toolInst then
            local texId = toolInst.TextureId
            if texId and texId ~= "" then
                Objects['ToolIcon'].Image = texId
                Objects['ToolIcon'].Visible = true
                Objects['ToolIcon'].ImageColor3 = getColor("ESP_ToolIconColor", Color3.fromRGB(255, 255, 255))
                local size = Flags["ESP_ToolIconSize"] or 16
                Objects['ToolIcon'].Size = UDim2.new(0, size, 0, size)
                local offX = Flags["ESP_ToolIconOffsetX"] or 0
                local offY = Flags["ESP_ToolIconOffsetY"] or 0
                Objects['ToolIcon'].Position = UDim2.new(0.5, -size/2 + offX, 0, offY)
                Objects['ToolIcon'].ImageTransparency = (Flags["ESP_ToolIconTransparency"] or 0) / 100
                local istroke = Objects['ToolIcon']:FindFirstChildOfClass("UIStroke")
                if istroke then
                    istroke.Enabled = false -- no outline by default
                end
            else
                Objects['ToolIcon'].Visible = false
            end
        else
            Objects['ToolIcon'].Visible = false
        end
    else
        Objects['ToolIcon'].Visible = false
    end

    local WeaponEnabled = Flags["ESP_WeaponEnabled"] or false
    if WeaponEnabled then
        Objects['Weapon'].Visible = true
        local currentTool = Data['CurrentTool'] or "none"
        if Data['LastWeapon'] ~= currentTool then
            Objects['Weapon'].Text = currentTool
            Data['LastWeapon'] = currentTool
        end
        Objects['Weapon'].TextColor3 = getColor("ESP_WeaponColor", Color3.fromRGB(255, 255, 255))
        Objects['Weapon'].TextSize = espTextSize
        local wstroke = Objects['Weapon']:FindFirstChildOfClass("UIStroke")
        if wstroke then wstroke.Enabled = espTextOutline end
    else
        Objects['Weapon'].Visible = false
    end

    local FlagsEnabled = Flags["ESP_FlagsEnabled"] or false
    if FlagsEnabled then
        local Humanoid = Data['Humanoid']
        if Humanoid then
            local Walking = Humanoid.MoveDirection ~= Vector3.zero
            local Swimming = Humanoid:GetState() == Enum.HumanoidStateType.Swimming
            local Freefall = Humanoid:GetState() == Enum.HumanoidStateType.Freefall
            
            Objects['WalkFlag'].Visible = Walking
            Objects['JumpFlag'].Visible = Freefall
            Objects['SwimmingFlag'].Visible = Swimming
        else
            Objects['WalkFlag'].Visible = false
            Objects['JumpFlag'].Visible = false
            Objects['SwimmingFlag'].Visible = false
        end
        Objects['WalkFlag'].TextColor3 = getColor("ESP_FlagsColor", Color3.fromRGB(255, 0, 0))
        Objects['JumpFlag'].TextColor3 = getColor("ESP_FlagsColor", Color3.fromRGB(144, 238, 144))
        Objects['SwimmingFlag'].TextColor3 = getColor("ESP_FlagsColor", Color3.fromRGB(0, 255, 255))
    else
        Objects['WalkFlag'].Visible = false
        Objects['JumpFlag'].Visible = false
        Objects['SwimmingFlag'].Visible = false
    end

    local TracerEnabled = Flags["ESP_TracerEnabled"] or false
    if TracerEnabled then
        local origin = Flags["ESP_TracerOrigin"] or "Bottom"
        local viewport = camera.ViewportSize
        local fromPos
        if origin == "Bottom" then
            fromPos = Vector2.new(viewport.X * 0.5, viewport.Y)
        elseif origin == "Top" then
            fromPos = Vector2.new(viewport.X * 0.5, 0)
        elseif origin == "Center" then
            fromPos = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        else
            local mousePos = UserInputService:GetMouseLocation()
            fromPos = Vector2.new(mousePos.X, mousePos.Y)
        end
        local toPos = Vector2.new(X + W * 0.5, Y + H * 0.5)
        local tracerColor = getColor("ESP_TracerColor", Color3.fromRGB(255, 255, 255))
        local neonAmount = (Flags["ESP_TracerNeonAmount"] or 0) / 100

        Objects['TracerOutline'].From = fromPos
        Objects['TracerOutline'].To = toPos
        Objects['TracerOutline'].Color = Color3.fromRGB(0, 0, 0)
        Objects['TracerOutline'].Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount * 0.3) or 0
        Objects['TracerOutline'].Visible = true

        Objects['TracerInline'].From = fromPos
        Objects['TracerInline'].To = toPos
        Objects['TracerInline'].Color = tracerColor
        Objects['TracerInline'].Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount * 0.5) or 0
        Objects['TracerInline'].Visible = true
    else
        if Objects['TracerOutline'] then Objects['TracerOutline'].Visible = false end
        if Objects['TracerInline'] then Objects['TracerInline'].Visible = false end
    end
end)

shouldShowESP = LPH_JIT(function(Target)
    if not Flags["ESP_Enabled"] then return false end
    local showOn = Flags["ESP_ShowOn"] or {}
    local isPlayer = Target:IsA("Player")
    
    if isPlayer then
        if Target == lp then
            return hasCheck(showOn, "Self")
        end
        local isTeammate = (lp.Team ~= nil and Target.Team == lp.Team)
        if isTeammate then
            return hasCheck(showOn, "Team")
        else
            return hasCheck(showOn, "Enemy")
        end
    else
        return hasCheck(showOn, "NPC")
    end
end)

_espBotScanClock = 0
EspLibrary:CreateThreads('Renderer', RunService.RenderStepped, LPH_NO_VIRTUALIZE(function()
    if not Flags["ESP_Enabled"] then
        for _, Data in pairs(EspLibrary['Cache']) do
            if Data['Objects']['TargetHolder'] and Data['Objects']['TargetHolder'].Visible then
                Data['Objects']['TargetHolder'].Visible = false
            end
            if Data['Objects']['TracerOutline'] then Data['Objects']['TracerOutline'].Visible = false end
            if Data['Objects']['TracerInline'] then Data['Objects']['TracerInline'].Visible = false end
        end
        return
    end

    local now = os.clock()
    if now - _espBotScanClock >= 1 then
        _espBotScanClock = now
        local botsFolder = workspace:FindFirstChild("Bots")
        if botsFolder then
            for _, bot in ipairs(botsFolder:GetChildren()) do
                if bot:IsA("Model") and bot:FindFirstChildOfClass("Humanoid") then
                    EspLibrary:AddTarget(bot)
                end
            end
        end
    end

    for Target, Data in pairs(EspLibrary['Cache']) do
        if shouldShowESP(Target) then
            EspLibrary:Update(Target, Data)
        else
            if Data['Objects']['TargetHolder'] and Data['Objects']['TargetHolder'].Visible then
                Data['Objects']['TargetHolder'].Visible = false
            end
            if Data['Objects']['TracerOutline'] then Data['Objects']['TracerOutline'].Visible = false end
            if Data['Objects']['TracerInline'] then Data['Objects']['TracerInline'].Visible = false end
        end
    end
end))

for _, Player in ipairs(Players:GetPlayers()) do
    EspLibrary:AddTarget(Player)
end

EspLibrary:CreateThreads('PlayerAdded', Players.PlayerAdded, function(Player)
    EspLibrary:AddTarget(Player)
end)

EspLibrary:CreateThreads('PlayerRemoving', Players.PlayerRemoving, function(Player)
    EspLibrary:RemoveTarget(Player)
end)

function EspLibrary:Unload()
    for Target in pairs(self['Cache']) do
        self:RemoveTarget(Target)
    end
    for _, Conn in pairs(self['Connections']) do
        Conn:Disconnect()
    end
    table.clear(self['Connections'])
    for _, Conn in pairs(self['Threads']) do
        Conn:Disconnect()
    end
    table.clear(self['Threads'])
    if self['Holder'] then
        self['Holder']:Destroy()
        self['Holder'] = nil
    end
    table.clear(self['Cache'])
end


Workspace = game:GetService("Workspace")

CreateAtomicSlashEffect = function()
    local Part = Instance.new("Part")
    Part.Parent = Workspace
    local Attachment = Instance.new("Attachment")
    Attachment.Parent = Part

    local Crescents = Instance.new("ParticleEmitter")
    Crescents.Name = "Crescents"
    Crescents.Lifetime = NumberRange.new(0.19, 0.38)
    Crescents.SpreadAngle = Vector2.new(-360, 360)
    Crescents.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1932907, 0), NumberSequenceKeypoint.new(0.778754, 0), NumberSequenceKeypoint.new(1, 1)})
    Crescents.LightEmission = 10
    Crescents.Color = ColorSequence.new(Color3.fromRGB(160, 96, 255))
    Crescents.VelocitySpread = -360
    Crescents.Speed = NumberRange.new(0.0826858, 0.0826858)
    Crescents.Brightness = 4
    Crescents.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.398774, 8.8026266, 2.2834616), NumberSequenceKeypoint.new(1, 11.477972, 1.860431)})
    Crescents.Enabled = false
    Crescents.ZOffset = 0.4542207
    Crescents.Rate = 50
    Crescents.Texture = "rbxassetid://12509373457"
    Crescents.RotSpeed = NumberRange.new(800, 1000)
    Crescents.Rotation = NumberRange.new(-360, 360)
    Crescents.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Crescents.Parent = Attachment

    local Glow = Instance.new("ParticleEmitter")
    Glow.Name = "Glow"
    Glow.Lifetime = NumberRange.new(0.16, 0.16)
    Glow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1421725, 0.6182796), NumberSequenceKeypoint.new(1, 1)})
    Glow.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Glow.Speed = NumberRange.new(0, 0)
    Glow.Brightness = 5
    Glow.Size = NumberSequence.new(9.1873131, 16.5032349)
    Glow.Enabled = false
    Glow.ZOffset = -0.0565939
    Glow.Rate = 50
    Glow.Texture = "rbxassetid://8708637750"
    Glow.Parent = Attachment

    local Effect = Instance.new("ParticleEmitter")
    Effect.Name = "Effect"
    Effect.Lifetime = NumberRange.new(0.4, 0.7)
    Effect.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
    Effect.SpreadAngle = Vector2.new(360, -360)
    Effect.LockedToPart = true
    Effect.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1070999, 0.19375), NumberSequenceKeypoint.new(0.7761194, 0.88125), NumberSequenceKeypoint.new(1, 1)})
    Effect.LightEmission = 1
    Effect.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Effect.Drag = 1
    Effect.VelocitySpread = 360
    Effect.Speed = NumberRange.new(0.0036749, 0.0036749)
    Effect.Brightness = 2.0999999
    Effect.Size = NumberSequence.new(6.9680691, 9.9213123)
    Effect.Enabled = false
    Effect.ZOffset = 0.4777403
    Effect.Rate = 50
    Effect.Texture = "rbxassetid://9484012464"
    Effect.RotSpeed = NumberRange.new(-150, -150)
    Effect.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
    Effect.Rotation = NumberRange.new(50, 50)
    Effect.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
    Effect.Parent = Attachment

    local Gradient1 = Instance.new("ParticleEmitter")
    Gradient1.Name = "Gradient1"
    Gradient1.Lifetime = NumberRange.new(0.3, 0.3)
    Gradient1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.3), NumberSequenceKeypoint.new(1, 1)})
    Gradient1.Color = ColorSequence.new(Color3.fromRGB(173, 82, 252))
    Gradient1.Speed = NumberRange.new(0, 0)
    Gradient1.Brightness = 6
    Gradient1.Size = NumberSequence.new(0, 11.6261358)
    Gradient1.Enabled = false
    Gradient1.ZOffset = 0.9187313
    Gradient1.Rate = 50
    Gradient1.Texture = "rbxassetid://8196169974"
    Gradient1.Parent = Attachment

    local Shards = Instance.new("ParticleEmitter")
    Shards.Name = "Shards"
    Shards.Lifetime = NumberRange.new(0.19, 0.7)
    Shards.SpreadAngle = Vector2.new(-90, 90)
    Shards.Color = ColorSequence.new(Color3.fromRGB(179, 145, 253))
    Shards.Drag = 10
    Shards.Squash = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5705521, 0.4125001), NumberSequenceKeypoint.new(1, -0.9375)})
    Shards.Speed = NumberRange.new(97.7530136, 146.9970093)
    Shards.Brightness = 4
    Shards.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.284774, 1.2389833, 0.1534118), NumberSequenceKeypoint.new(1, 0)})
    Shards.Enabled = false
    Shards.Acceleration = Vector3.new(0, -56.961341857910156, 0)
    Shards.ZOffset = 0.5705321
    Shards.Rate = 50
    Shards.Texture = "rbxassetid://8030734851"
    Shards.Rotation = NumberRange.new(90, 90)
    Shards.Orientation = Enum.ParticleOrientation.VelocityParallel
    Shards.Parent = Attachment

    return Attachment
end

















end

do
local MainPage = Window:Page({ Name = "Combat", Icon = "rbxassetid://4391741881" })
local MainMultiL = MainPage:MultiSection({ Side = 1 })
local AimTab = MainMultiL:Add("Aimbot")
local SilentTab = MainMultiL:Add("Silent")
local MainMultiR = MainPage:MultiSection({ Side = 2 })
local MainR = MainMultiR:Add("Main")
local SettingsSec = MainMultiR:Add("AimbotSettings")
local AimPlusSec = MainMultiR:Add("Aimbot+")

local AimbotSettings = {}

local function addAimbotSetting(widget)
    table.insert(AimbotSettings, widget)
    return widget
end

local currentSettingsTab = "Aimbot"

local function updateAdvancedPartsVis()
    local enabled = Flags["UseAdvancedParts"]
    if Flags["_JumpPart"] then
        pcall(function() Flags["_JumpPart"]:SetVisibility(enabled) end)
    end
    if Flags["_FallPart"] then
        pcall(function() Flags["_FallPart"]:SetVisibility(enabled) end)
    end
end

local function updateSmoothingVis()
    local useSmooth = Flags["UseSmoothing"]
    local useAdv = Flags["UseAdvSmoothing"]
    if Flags["_SmoothX"] then Flags["_SmoothX"]:SetVisibility(useSmooth and not useAdv) end
    if Flags["_SmoothY"] then Flags["_SmoothY"]:SetVisibility(useSmooth and not useAdv) end
    if Flags["_UseAdvSmoothing"] then Flags["_UseAdvSmoothing"]:SetVisibility(useSmooth) end
    if Flags["_AdvSmoothRight"] then Flags["_AdvSmoothRight"]:SetVisibility(useSmooth and useAdv) end
    if Flags["_AdvSmoothLeft"] then Flags["_AdvSmoothLeft"]:SetVisibility(useSmooth and useAdv) end
    if Flags["_AdvSmoothUp"] then Flags["_AdvSmoothUp"]:SetVisibility(useSmooth and useAdv) end
    if Flags["_AdvSmoothDown"] then Flags["_AdvSmoothDown"]:SetVisibility(useSmooth and useAdv) end
    if Flags["_AirXSmoothing"] then Flags["_AirXSmoothing"]:SetVisibility(useSmooth and useAdv) end
end

local function updatePredVis()
    local usePred = Flags["UsePred"] == true
    local useAdv = Flags["UseAdvancedPred"] == true
    
    local showBasic = usePred and not useAdv
    local showAdv = usePred and useAdv
    local showAny = usePred
    
    if Flags["_PredStyle"] then Flags["_PredStyle"]:SetVisibility(showAny) end
    if Flags["_UseAdvancedPred"] then Flags["_UseAdvancedPred"]:SetVisibility(showAny) end
    
    -- Basic sliders: only when pred is on AND advanced is OFF
    if Flags["_PredX"] then Flags["_PredX"]:SetVisibility(showBasic) end
    if Flags["_PredY"] then Flags["_PredY"]:SetVisibility(showBasic) end
    if Flags["_PredAirX"] then Flags["_PredAirX"]:SetVisibility(showBasic) end
    
    -- Advanced sliders: only when pred is on AND advanced is ON
    if Flags["_AdvPredRight"] then Flags["_AdvPredRight"]:SetVisibility(showAdv) end
    if Flags["_AdvPredLeft"] then Flags["_AdvPredLeft"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirUp"] then Flags["_AdvPredAirUp"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirDown"] then Flags["_AdvPredAirDown"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirRight"] then Flags["_AdvPredAirRight"]:SetVisibility(showAdv) end
    if Flags["_AdvPredAirLeft"] then Flags["_AdvPredAirLeft"]:SetVisibility(showAdv) end
end

local function updateOffsetVis()
    local useOffsets = Flags["UseOffsets"]
    local useAirOffset = Flags["UseAirOffset"]
    if Flags["_OffsetUp"] then Flags["_OffsetUp"]:SetVisibility(useOffsets) end
    if Flags["_OffsetDown"] then Flags["_OffsetDown"]:SetVisibility(useOffsets) end
    if Flags["_OffsetLeft"] then Flags["_OffsetLeft"]:SetVisibility(useOffsets) end
    if Flags["_OffsetRight"] then Flags["_OffsetRight"]:SetVisibility(useOffsets) end
    if Flags["_UseAirOffset"] then Flags["_UseAirOffset"]:SetVisibility(true) end
    if Flags["_AirOffsetVal"] then Flags["_AirOffsetVal"]:SetVisibility(useAirOffset) end
    if Flags["_AirOffsetSmooth"] then Flags["_AirOffsetSmooth"]:SetVisibility(useAirOffset and not Flags["AirOffsetUseAimbotSmooth"]) end
    if Flags["_AirOffsetUseAimbotSmooth"] then Flags["_AirOffsetUseAimbotSmooth"]:SetVisibility(useAirOffset) end
end

local function updatePullResVis()
    local usePull = Flags["UsePullResistance"]
    if Flags["_PullResX"] then Flags["_PullResX"]:SetVisibility(usePull) end
    if Flags["_PullResY"] then Flags["_PullResY"]:SetVisibility(usePull) end
    local useDeadzone = Flags["UseDeadzone"]
    if Flags["_DeadzoneX"] then Flags["_DeadzoneX"]:SetVisibility(useDeadzone) end
    if Flags["_DeadzoneY"] then Flags["_DeadzoneY"]:SetVisibility(useDeadzone) end
end

local function updateEasingVis()
    local useEasing = Flags["UseEasing"]
    local style = Flags["EaseStyle"] or "Quad"
    local isElastic = (style == "Elastic" or style == "Custom Elastic")
    local isAdapt = (style == "Adapt" or style == "Adaptive")
    local isOscillator = isAdapt or (style == "Zigzag") or (style == "Pulse")
    local isBack = (style == "Back")
    local isSharp = (style == "Sharp")
    
    if Flags["_EaseStyle"] then Flags["_EaseStyle"]:SetVisibility(useEasing) end
    if Flags["_JumpEaseStyle"] then Flags["_JumpEaseStyle"]:SetVisibility(useEasing) end
    if Flags["_EaseDir"] then Flags["_EaseDir"]:SetVisibility(useEasing) end
    if Flags["_JumpEaseDir"] then Flags["_JumpEaseDir"]:SetVisibility(useEasing) end
    if Flags["_EaseSpeed"] then Flags["_EaseSpeed"]:SetVisibility(useEasing) end
    if Flags["_EaseBlend"] then Flags["_EaseBlend"]:SetVisibility(useEasing) end
    if Flags["_EaseResetDist"] then Flags["_EaseResetDist"]:SetVisibility(useEasing) end
    if Flags["_Elasticity"] then Flags["_Elasticity"]:SetVisibility(useEasing and isElastic) end
    if Flags["_EaseExponent"] then Flags["_EaseExponent"]:SetVisibility(useEasing and (style == "Custom Power" or style == "Cubic" or style == "Quart" or style == "Quint" or style == "Sextic" or style == "Septic" or style == "Octic")) end
    if Flags["_BounceBounciness"] then Flags["_BounceBounciness"]:SetVisibility(useEasing and style == "Bounce") end
    if Flags["_BackOvershoot"] then Flags["_BackOvershoot"]:SetVisibility(useEasing and isBack) end
    if Flags["_ElasticPeriod"] then Flags["_ElasticPeriod"]:SetVisibility(useEasing and isElastic) end
    if Flags["_SharpPower"] then Flags["_SharpPower"]:SetVisibility(useEasing and isSharp) end
    
    if Flags["_AdaptSwaySpeed"] then Flags["_AdaptSwaySpeed"]:SetVisibility(useEasing and isOscillator) end
    if Flags["_AdaptSwayWidth"] then Flags["_AdaptSwayWidth"]:SetVisibility(useEasing and isOscillator) end
    if Flags["_AdaptJitterAmt"] then Flags["_AdaptJitterAmt"]:SetVisibility(useEasing and isAdapt) end
end

local function updateDeadspotVis()
    local stay = Flags["StayOnDeadspot"]
    if Flags["_DeadspotTime"] then Flags["_DeadspotTime"]:SetVisibility(stay) end
end

local function updateDelayJumpVis()
    local delayJump = Flags["DelayJump"] == true
    if Flags["_DelayJumpMs"] then Flags["_DelayJumpMs"]:SetVisibility(delayJump) end
    if Flags["_DelayForXJumps"] then Flags["_DelayForXJumps"]:SetVisibility(delayJump) end
    if Flags["_JumpSmooth"] then Flags["_JumpSmooth"]:SetVisibility(delayJump) end
    if Flags["_UpTargetPart"] then Flags["_UpTargetPart"]:SetVisibility(delayJump) end
end

local function updateFallDelayVis()
    local fallDelay = Flags["FallDelay"]
    if Flags["_FallDelayMs"] then Flags["_FallDelayMs"]:SetVisibility(fallDelay) end
end

local function updateUnlockDelayVis()
    local unlockDelay = Flags["UnlockDelayEnabled"]
    if Flags["_UnlockDelayMs"] then Flags["_UnlockDelayMs"]:SetVisibility(unlockDelay) end
end

_aimbotKeybindWidget = AimTab:Toggle({ Name = "Enabled", Flag = "AimbotEnabled", Default = false }):Keybind({ Flag = "AimbotBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
local function updateLockMethodVis()
    local method = Flags["LockMethod"] or "Camera"
end
AimTab:Dropdown({ Name = "Lock Method", Flag = "LockMethod", Items = {"Camera","Mouse"}, Default = "Camera", Callback = updateLockMethodVis })
pcall(updateLockMethodVis)
AimTab:Dropdown({ Name = "Target Mode", Flag = "TargetMode", Items = {"FOV","Mouse","Distance","Center"}, Default = "FOV" })
AimTab:Dropdown({ Name = "Aim Type", Flag = "AimType", Items = {"Normal", "Closest Part"}, Default = "Normal" })
local hitPartItems = {"Head","Neck","UpperTorso","LowerTorso","Torso","Legs","Closest Part","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}
AimTab:Dropdown({ Name = "Ground Part", Flag = "GroundPart", Items = hitPartItems, Default = "Head" })
local aimAdvancedParts = AimTab:Toggle({ Name = "Advanced Parts", Flag = "UseAdvancedParts", Default = false, Callback = updateAdvancedPartsVis })
Flags["_JumpPart"] = AimTab:Dropdown({ Name = "Jump Part", Flag = "JumpPart", Items = hitPartItems, Default = "HumanoidRootPart" })
Flags["_FallPart"] = AimTab:Dropdown({ Name = "Fall Part", Flag = "FallPart", Items = hitPartItems, Default = "LowerTorso" })
pcall(updateAdvancedPartsVis)
AimTab:Toggle({ Name = "Ignore Fall State", Flag = "IgnoreFall", Default = false })
AimTab:Dropdown({ Name = "Checks", Flag = "AimChecks", Items = {"Enemy","Team","NPC","Wall","Dead","Knocked"}, Default = {}, Multi = true })
AimTab:Toggle({ Name = "Stay on Deadspot", Flag = "StayOnDeadspot", Default = false, Callback = updateDeadspotVis })
Flags["_DeadspotTime"] = AimTab:Slider({ Name = "Deadspot Time", Flag = "DeadspotTime", Min = 50, Max = 3000, Default = 300, Suffix = "ms" })
AimTab:Toggle({ Name = "Sticky Aim", Flag = "StickyAim", Default = false })
AimTab:Toggle({ Name = "Auto Stop on Death", Flag = "AutoStopOnDeath", Default = false })
AimTab:Toggle({ Name = "Lock Target", Flag = "LockTarget", Default = false })
AimTab:Toggle({ Name = "Spectate Target", Flag = "AimbotSpectateTarget", Default = false }):Keybind({ Flag = "SpectateTargetBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })

AimTab:Toggle({ Name = "Use FOV", Flag = "UseFOV", Default = false })
local aimDrawFOV = AimTab:Toggle({ Name = "Draw FOV", Flag = "DrawFOV", Default = false })
aimDrawFOV:Colorpicker({ Flag = "c_fov", Default = Color3.new(1,1,1), Callback = function(c) C.FOV=c end })
AimTab:Slider({ Name = "FOV Size", Flag = "FOVSize", Min = 10, Max = 500, Default = 60 })

local aimSmoothing = addAimbotSetting(AimPlusSec:Toggle({ Name = "Smoothing", Flag = "UseSmoothing", Default = false, Callback = updateSmoothingVis }))
Flags["_SmoothX"] = addAimbotSetting(AimPlusSec:Slider({ Name = "X Smoothing", Flag = "SmoothX", Min = 1, Max = 100, Default = 2 }))
Flags["_SmoothY"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Y Smoothing", Flag = "SmoothY", Min = 1, Max = 100, Default = 2 }))
Flags["_UseAdvSmoothing"] = addAimbotSetting(AimPlusSec:Toggle({ Name = "Advanced Smoothing", Flag = "UseAdvSmoothing", Default = false, Callback = updateSmoothingVis }))
Flags["_AdvSmoothRight"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Right Smoothing", Flag = "AdvSmoothRight", Min = 1, Max = 100, Default = 2 }))
Flags["_AdvSmoothLeft"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Left Smoothing", Flag = "AdvSmoothLeft", Min = 1, Max = 100, Default = 2 }))
Flags["_AdvSmoothUp"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Up Smoothing", Flag = "AdvSmoothUp", Min = 1, Max = 100, Default = 2 }))
Flags["_AdvSmoothDown"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Down Smoothing", Flag = "AdvSmoothDown", Min = 1, Max = 100, Default = 2 }))
Flags["_UseMouseBlend"] = addAimbotSetting(AimPlusSec:Toggle({ Name = "Mouse Blend", Flag = "UseMouseBlend", Default = false }))
Flags["_MouseBlendX"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Mouse Blend X/Z", Flag = "MouseBlendX", Min = 1, Max = 100, Default = 30, Suffix = "%" }))
Flags["_MouseBlendY"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Mouse Blend Y", Flag = "MouseBlendY", Min = 1, Max = 100, Default = 30, Suffix = "%" }))
Flags["_AirXSmoothing"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air X Smoothing", Flag = "AirXSmoothing", Min = 1, Max = 100, Default = 2 }))

local aimPred = addAimbotSetting(AimPlusSec:Toggle({ Name = "Prediction", Flag = "UsePred", Default = false, Callback = updatePredVis }))
Flags["_PredStyle"] = addAimbotSetting(AimPlusSec:Dropdown({ Name = "Pred Style", Flag = "PredStyle", Items = {"Classic","Adaptive"}, Default = "Classic" }))
Flags["_PredX"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Ground X/Z Prediction", Flag = "PredX", Min = 0, Max = 150, Default = 3 }))
Flags["_PredY"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Ground Y Prediction", Flag = "PredY", Min = 0, Max = 150, Default = 3 }))
Flags["_PredAirX"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air X/Z Prediction", Flag = "PredAirX", Min = 0, Max = 150, Default = 2 }))

Flags["_UseAdvancedPred"] = addAimbotSetting(AimPlusSec:Toggle({ Name = "Advanced Prediction", Flag = "UseAdvancedPred", Default = false, Callback = updatePredVis }))
Flags["_AdvPredRight"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Ground Prediction Right", Flag = "AdvPredRight", Min = 0, Max = 150, Default = 12 }))
Flags["_AdvPredLeft"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Ground Prediction Left", Flag = "AdvPredLeft", Min = 0, Max = 150, Default = 12 }))
Flags["_AdvPredAirUp"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air Prediction Up", Flag = "AdvPredAirUp", Min = 0, Max = 150, Default = 14 }))
Flags["_AdvPredAirDown"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air Prediction Down", Flag = "AdvPredAirDown", Min = 0, Max = 150, Default = 10 }))
Flags["_AdvPredAirRight"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air Prediction Right", Flag = "AdvPredAirRight", Min = 0, Max = 150, Default = 14 }))
Flags["_AdvPredAirLeft"] = addAimbotSetting(AimPlusSec:Slider({ Name = "Air Prediction Left", Flag = "AdvPredAirLeft", Min = 0, Max = 150, Default = 14 }))



-- Macro Toggle
-- Macro widgets live in AimTab (left panel) – always visible when aimbot section is open
AimTab:Toggle({ Name = "Macro", Flag = "MacroEnabled", Default = false, Callback = function() pcall(updateMacroTypeVis) end }):Keybind({ Flag = "MacroBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })

Flags["_MacroType"] = AimTab:Dropdown({
    Name = "Macro Type", Flag = "MacroType",
    Items = {"Infuse", "360", "Ziggy"}, Default = "Infuse",
    Callback = function() pcall(updateMacroTypeVis) end
})

Flags["_MacroSpeed"] = AimTab:Slider({ Name = "Macro Speed", Flag = "MacroSpeed", Min = 20, Max = 500, Default = 100, Suffix = "ms" })
Flags["_Macro360Dir"] = AimTab:Dropdown({ Name = "Spin Direction", Flag = "Macro360Dir", Items = {"Right","Left"}, Default = "Right" })

local function updateMacroTypeVis()
    local t = Flags["MacroType"] or "Infuse"
    local is360 = t == "360"
    local enabled = Flags["MacroEnabled"]
    if Flags["_MacroSpeed"] then Flags["_MacroSpeed"]:SetVisibility(enabled) end
    if Flags["_Macro360Dir"] then Flags["_Macro360Dir"]:SetVisibility(enabled and is360) end
    if Flags["_MacroType"] then Flags["_MacroType"]:SetVisibility(enabled) end
end
pcall(updateMacroTypeVis)


pcall(updateSmoothingVis)
pcall(updatePredVis)
pcall(updateEasingVis)
pcall(updateDeadspotVis)

local aimUseOffsets = addAimbotSetting(SettingsSec:Toggle({ Name = "Use Offsets", Flag = "UseOffsets", Default = false, Callback = updateOffsetVis }))
Flags["_OffsetUp"] = addAimbotSetting(SettingsSec:Slider({ Name = "Offset Up", Flag = "OffsetUp", Min = 0, Max = 100, Default = 0, Suffix = "/10" }))
Flags["_OffsetDown"] = addAimbotSetting(SettingsSec:Slider({ Name = "Offset Down", Flag = "OffsetDown", Min = 0, Max = 100, Default = 0, Suffix = "/10" }))
Flags["_OffsetLeft"] = addAimbotSetting(SettingsSec:Slider({ Name = "Offset Left", Flag = "OffsetLeft", Min = 0, Max = 100, Default = 0, Suffix = "/10" }))
Flags["_OffsetRight"] = addAimbotSetting(SettingsSec:Slider({ Name = "Offset Right", Flag = "OffsetRight", Min = 0, Max = 100, Default = 0, Suffix = "/10" }))
local aimUseAirOffset = addAimbotSetting(SettingsSec:Toggle({ Name = "Air Offset", Flag = "UseAirOffset", Default = false, Callback = updateOffsetVis }))
Flags["_UseAirOffset"] = aimUseAirOffset
Flags["_AirOffsetVal"] = addAimbotSetting(SettingsSec:Slider({ Name = "Air Offset Value", Flag = "AirOffsetVal", Min = -100, Max = 100, Default = 0, Suffix = "/10" }))
Flags["_AirOffsetSmooth"] = addAimbotSetting(SettingsSec:Slider({ Name = "Air Offset Smoothness", Flag = "AirOffsetSmooth", Min = 1, Max = 100, Default = 2 }))
Flags["_AirOffsetUseAimbotSmooth"] = addAimbotSetting(SettingsSec:Toggle({ Name = "Use Aimbot Smooth for Air Offset", Flag = "AirOffsetUseAimbotSmooth", Default = false, Callback = updateOffsetVis }))
pcall(updateOffsetVis)

Flags["_LockTime"] = addAimbotSetting(SettingsSec:Slider({ Name = "Lock Time", Flag = "LockTime", Min = 0, Max = 1000, Default = 0, Suffix = "ms" }))
local aimDelayJump = addAimbotSetting(SettingsSec:Toggle({ Name = "Delay Jump", Flag = "DelayJump", Default = false, Callback = updateDelayJumpVis }))
Flags["_DelayJumpMs"] = addAimbotSetting(SettingsSec:Slider({ Name = "Jump Delay", Flag = "DelayJumpMs", Min = 0, Max = 500, Default = 50, Suffix = "ms" }))
Flags["_JumpSmooth"] = addAimbotSetting(SettingsSec:Slider({ Name = "Jump Smooth", Flag = "JumpSmooth", Min = 1, Max = 100, Default = 2 }))
Flags["_UpTargetPart"] = addAimbotSetting(SettingsSec:Dropdown({ Name = "Up Target Part", Flag = "UpTargetPart", Items = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, Default = "Head" }))
local aimFallDelay = addAimbotSetting(SettingsSec:Toggle({ Name = "Fall Delay", Flag = "FallDelay", Default = false, Callback = updateFallDelayVis }))
Flags["_FallDelayMs"] = addAimbotSetting(SettingsSec:Slider({ Name = "Fall Delay (ms)", Flag = "FallDelayMs", Min = 0, Max = 1000, Default = 50, Suffix = "ms" }))
local aimUnlockDelay = addAimbotSetting(SettingsSec:Toggle({ Name = "Unlock Delay", Flag = "UnlockDelayEnabled", Default = false, Callback = updateUnlockDelayVis }))
Flags["_UnlockDelayMs"] = addAimbotSetting(SettingsSec:Slider({ Name = "Unlock Delay (ms)", Flag = "UnlockDelayMs", Min = 0, Max = 1000, Default = 100, Suffix = "ms" }))

Flags["_MissChance"] = addAimbotSetting(SettingsSec:Slider({ Name = "Miss Chance", Flag = "MissChance", Min = 0, Max = 100, Default = 0, Suffix = "%" }))

local aimUseEasing = addAimbotSetting(SettingsSec:Toggle({ Name = "Use Easing", Flag = "UseEasing", Default = false, Callback = updateEasingVis }))
Flags["_EaseStyle"] = addAimbotSetting(SettingsSec:Dropdown({ Name = "Easing Style", Flag = "EaseStyle", Items = {"Linear","Sine","Quad","Cubic","Quart","Quint","Sextic","Septic","Octic","Square Root","Custom Power","Exponential","Circular","Back","Bounce","Elastic","Adaptive","Zigzag","Pulse","Sharp"}, Default = "Quad", Callback = updateEasingVis }))
Flags["_JumpEaseStyle"] = addAimbotSetting(SettingsSec:Dropdown({ Name = "Jump Easing Style", Flag = "JumpEaseStyle", Items = {"Linear","Sine","Quad","Cubic","Quart","Quint","Sextic","Septic","Octic","Square Root","Custom Power","Exponential","Circular","Back","Bounce","Elastic","Adaptive","Zigzag","Pulse","Sharp"}, Default = "Quad", Callback = updateEasingVis }))
Flags["_EaseDir"] = addAimbotSetting(SettingsSec:Dropdown({ Name = "Easing Direction", Flag = "EaseDir", Items = {"In","Out","InOut"}, Default = "Out" }))
Flags["_JumpEaseDir"] = addAimbotSetting(SettingsSec:Dropdown({ Name = "Jump Easing Direction", Flag = "JumpEaseDir", Items = {"In","Out","InOut"}, Default = "Out" }))
Flags["_EaseSpeed"] = addAimbotSetting(SettingsSec:Slider({ Name = "Easing Speed", Flag = "EaseSpeed", Min = 1, Max = 200, Default = 70, Suffix = "%" }))
Flags["_EaseBlend"] = addAimbotSetting(SettingsSec:Slider({ Name = "Ease Blend", Flag = "EaseBlend", Min = 0, Max = 100, Default = 100, Suffix = "%" }))
Flags["_EaseResetDist"] = addAimbotSetting(SettingsSec:Slider({ Name = "Reset Distance", Flag = "EaseResetDist", Min = 0, Max = 50, Default = 0, Suffix = " studs" }))
Flags["_Elasticity"] = addAimbotSetting(SettingsSec:Slider({ Name = "Elasticity", Flag = "Elasticity", Min = 0, Max = 100, Default = 30, Suffix = "%" }))
Flags["_EaseExponent"] = addAimbotSetting(SettingsSec:Slider({ Name = "Easing Exponent", Flag = "EaseExponent", Min = 1, Max = 10, Default = 3, Callback = updateEasingVis }))
Flags["_BounceBounciness"] = addAimbotSetting(SettingsSec:Slider({ Name = "Bounce Bounciness", Flag = "BounceBounciness", Min = 1, Max = 100, Default = 50, Suffix = "%", Callback = updateEasingVis }))
Flags["_BackOvershoot"] = addAimbotSetting(SettingsSec:Slider({ Name = "Back Overshoot", Flag = "BackOvershoot", Min = 0, Max = 50, Default = 17, Suffix = "/10", Callback = updateEasingVis }))
Flags["_ElasticPeriod"] = addAimbotSetting(SettingsSec:Slider({ Name = "Elastic Period", Flag = "ElasticPeriod", Min = 1, Max = 100, Default = 30, Suffix = "%", Callback = updateEasingVis }))
Flags["_AdaptSwaySpeed"] = addAimbotSetting(SettingsSec:Slider({ Name = "Sway Speed", Flag = "AdaptSwaySpeed", Min = 0, Max = 100, Default = 15 }))
Flags["_AdaptSwayWidth"] = addAimbotSetting(SettingsSec:Slider({ Name = "Sway Size", Flag = "AdaptSwayWidth", Min = 0, Max = 100, Default = 10 }))
Flags["_AdaptJitterAmt"] = addAimbotSetting(SettingsSec:Slider({ Name = "Jitter Size", Flag = "AdaptJitterAmt", Min = 0, Max = 100, Default = 15 }))
Flags["_SharpPower"] = addAimbotSetting(SettingsSec:Slider({ Name = "Sharpness", Flag = "SharpPower", Min = 5, Max = 100, Default = 20, Suffix = "/100", Callback = updateEasingVis }))

local silentHitParts = {"Head","Torso","Legs","Closest Part","Neck","UpperTorso"}
SilentTab:Toggle({ Name = "Enabled", Flag = "SilentEnabled", Default = false }):Keybind({ Flag = "SilentBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
SilentTab:Dropdown({ Name = "Hit Part", Flag = "SilentHitPart", Items = silentHitParts, Default = "Head" })
SilentTab:Dropdown({ Name = "Checks", Flag = "SilentChecks", Items = {"NPC","Team","Dead","Wall","Knocked"}, Default = {"Team","Dead"}, Multi = true })
SilentTab:Toggle({ Name = "Target Lock", Flag = "SilentTargetLock", Default = false })
SilentTab:Toggle({ Name = "Sync with Aimbot", Flag = "SilentSyncAimbot", Default = false })
SilentTab:Dropdown({ Name = "Aim Type", Flag = "SilentAimType", Items = {"Cursor","Center","FOV","Closest"}, Default = "Cursor" })
-- Silent auto prediction toggle removed
SilentTab:Toggle({ Name = "Hit Chance", Flag = "SilentHitChanceEnabled", Default = false })
SilentTab:Slider({ Name = "Hit Chance %", Flag = "SilentHitChance", Min = 1, Max = 100, Default = 100, Suffix = "%" })
SilentTab:Toggle({ Name = "Use FOV", Flag = "SilentUseFOV", Default = false })
SilentTab:Slider({ Name = "FOV Size", Flag = "SilentFOVSize", Min = 10, Max = 500, Default = 100 })
local silentDrawFOV = SilentTab:Toggle({ Name = "Draw FOV", Flag = "SilentDrawFOV", Default = false })
silentDrawFOV:Colorpicker({ Flag = "c_silentfov", Default = Color3.new(1,1,1), Callback = function(c) C.SilentFOV = c end })


local function updateSettingsTabVisibility(tabName)
    currentSettingsTab = tabName
    local function show(element) pcall(function() element:SetVisibility(true) end) end
    local function run(fn) pcall(fn) end

    if tabName == "Aimbot" then
        pcall(function() MainMultiR:Select("Settings") end)
        show(aimUseOffsets)
        show(aimDelayJump)
        show(aimFallDelay)
        show(aimUnlockDelay)
        show(aimAdvancedParts)
        show(Flags["_MissChance"])
        show(aimUseEasing)
        run(updateOffsetVis)
        run(updateDelayJumpVis)
        run(updateFallDelayVis)
        run(updateUnlockDelayVis)
        run(updateAdvancedPartsVis)
        run(updateEasingVis)
    elseif tabName == "Aimbot+" then
        pcall(function() MainMultiR:Select("Aimbot+") end)
        show(aimSmoothing)
        show(aimPred)
        run(updateSmoothingVis)
        run(updatePredVis)
    elseif tabName == "Main" then
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
MainR:Toggle({ Name = "Target HUD", Flag = "TargetHUD", Default = false, Callback = function(v)
    pcall(function() if Library.TargetHUDObj then Library.TargetHUDObj:SetVisibility(v) end end)
end })
MainR:Toggle({ Name = "Avatar Display", Flag = "TargetHUDAvatar", Default = true, Callback = function()
    pcall(function() if Library.TargetHUDObj then Library.TargetHUDObj:Update() end end)
end })
local ttrc = MainR:Toggle({ Name = "Target Tracer", Flag = "TargetTracer", Default = false })
ttrc:Colorpicker({ Flag = "c_ttrace", Default = Color3.new(1,0,0), Callback = function(c) C.TargetTracer=c end })
ttrc:Colorpicker({ Flag = "c_ttraceout", Default = Color3.new(0,0,0), Callback = function(c) C.TargetTracerOut=c end })
Flags["_TargetTracerAlpha"] = MainR:Slider({ Name = "Tracer Fill Alpha", Flag = "TargetTracerAlpha", Min = 0, Max = 100, Default = 100, Suffix = "%" })
Flags["_TargetTracerOutAlpha"] = MainR:Slider({ Name = "Tracer Outline Alpha", Flag = "TargetTracerOutAlpha", Min = 0, Max = 100, Default = 100, Suffix = "%" })
MainR:Dropdown({ Name = "Tracer Start", Flag = "TargetTracerStart", Items = {"Bottom","Top","Cursor"}, Default = "Bottom" })
MainR:Dropdown({ Name = "Tracer End", Flag = "TargetTracerEnd", Items = {"Feet","Head"}, Default = "Feet" })

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
    if weatherName=="Cherry" then
        color = Flags["c_cherry_fog"] and _W.getCol3(Flags["c_cherry_fog"]) or Color3.fromRGB(255,230,240)
        density=(Flags["CherryFogDensity"] or 15)/100; fogEnd=Flags["CherryFogEnd"] or 2000; haze=2.0
    elseif weatherName=="Rain" then
        color = Flags["c_rain_fog"] and _W.getCol3(Flags["c_rain_fog"]) or Color3.fromRGB(150,160,170)
        density=(Flags["RainFogDensity"] or 30)/100; fogEnd=Flags["RainFogEnd"] or 1500; haze=4.0
    elseif weatherName=="Snow" then
        color = Flags["c_snow_fog"] and _W.getCol3(Flags["c_snow_fog"]) or Color3.fromRGB(220,225,235)
        density=(Flags["SnowFogDensity"] or 25)/100; fogEnd=Flags["SnowFogEnd"] or 1800; haze=3.0
    end
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmo then atmo=Instance.new("Atmosphere"); atmo.Parent=Lighting end
    atmo.Name="PortalAura"; atmo.Color=color; atmo.Decay=color
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
    local count = math.clamp(math.floor(rate), 10, 250)

    _rainVolFolder = Instance.new("Folder")
    _rainVolFolder.Name = "_RainVolume"
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
    _W._splashFolder.Name = "_RainSplashes"
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
        if splashTimer < 0.1 then return end
        splashTimer = 0
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hrpPos = hrp.Position
        local splashCount = math.clamp(math.floor(rate / 100), 1, 3)

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
    _W.snowPart.Transparency = 1; _W.snowPart.Size = Vector3.new(120, 1, 120)
    _W.snowPart.CFrame = CFrame.new(cam.CFrame.Position + Vector3.new(0, 50, 0))
    _W.snowPart.Parent = cam

    local closeEmitter = Instance.new("ParticleEmitter")
    closeEmitter.Name = "_SnowClose"
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
    midEmitter.Name = "_SnowMid"
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
    farEmitter.Name = "_SnowFar"
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
    _W.clearDrops(_W._rainDrops)
    _W.clearDrops(_W._snowFlakes)
    _W.destroyRainPart()
    _W.destroySnowPart()
end
_W.turnOffOtherWeathers = function(exceptFlag)
    local weathers = { SnowEnabled="SnowEnabled", RainEnabled="RainEnabled", CherryEnabled="CherryEnabled" }
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
local OtherPage = Window:Page({ Name = "World", Icon = "rbxassetid://11395780588" })
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
LightTab:Toggle({ Name = "Lighting", Flag = "OverLight", Default = false, Callback = function(v)
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
local _atmoD = LightTab:Slider({ Name = "Atmo Density", Flag = "AtmoD", Min = 0, Max = 100, Default = 40, Suffix = "%" })
local _atmoO = LightTab:Slider({ Name = "Atmo Offset", Flag = "AtmoO", Min = 0, Max = 100, Default = 0, Suffix = "%" })
local _atmoG = LightTab:Slider({ Name = "Atmo Glare", Flag = "AtmoG", Min = 0, Max = 100, Default = 0, Suffix = "%" })
local _atmoH = LightTab:Slider({ Name = "Atmo Haze", Flag = "AtmoH", Min = 0, Max = 100, Default = 0, Suffix = "%" })
_atmoD:SetVisibility(false)
_atmoO:SetVisibility(false)
_atmoG:SetVisibility(false)
_atmoH:SetVisibility(false)
LightTab:Toggle({ Name = "Override Atmosphere", Flag = "OverAtmo", Default = false, Callback = function(v)
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
Flags["_Sat"] = LightTab:Slider({ Name = "Saturation", Flag = "Sat", Min = -100, Max = 100, Default = 0, Callback = function(v)
    if not _lightingTouched["Sat"] then _lightingTouched["Sat"] = true; return end
    getOrCreateCC().Saturation = v / 100
end })
Flags["_Bright"] = LightTab:Slider({ Name = "Brightness", Flag = "Bright", Min = 0, Max = 5, Default = 1, Callback = function(v)
    if not _lightingTouched["Bright"] then _lightingTouched["Bright"] = true; return end
    Lighting.Brightness = v
    local boost = math.clamp((v - 1) * 0.15, -0.3, 0.3)
    Lighting.OutdoorAmbient = Color3.new(0.5 + boost, 0.5 + boost, 0.5 + boost)
end })
Flags["_Cont"] = LightTab:Slider({ Name = "Contrast", Flag = "Cont", Min = -100, Max = 100, Default = 0, Callback = function(v)
    if not _lightingTouched["Cont"] then _lightingTouched["Cont"] = true; return end
    getOrCreateCC().Contrast = v / 100
end })
pcall(updateLightingVis)

local _origTimeOfDay = nil
local _timeConnection = nil
local _timeSlider = LightTab:Slider({ Name = "Time of Day", Flag = "TimeOfDay", Min = 0, Max = 24, Default = 12 })
_timeSlider:SetVisibility(false)
LightTab:Toggle({ Name = "Override Time", Flag = "OverTime", Default = false, Callback = function(v)
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
local _fogStart = WeatherTab:Slider({ Name = "Fog Start", Flag = "FogStart", Min = 0, Max = 5000, Default = 0, Suffix = "st" })
local _fogEnd = WeatherTab:Slider({ Name = "Fog End", Flag = "FogEnd", Min = 100, Max = 10000, Default = 5000, Suffix = "st" })
_fogStart:SetVisibility(false)
_fogEnd:SetVisibility(false)
local _fogSpinSpd = WeatherTab:Slider({ Name = "Spin Speed", Flag = "FogSpinSpd", Min = 1, Max = 100, Default = 20 })
_fogSpinSpd:SetVisibility(false)
local _fogSpin = WeatherTab:Toggle({ Name = "Fog Spin", Flag = "FogSpin", Default = false, Callback = function(v)
    if Flags["CustomFog"] then
        _fogSpinSpd:SetVisibility(v)
    end
end })
_fogSpin:SetVisibility(false)
local fogT = WeatherTab:Toggle({ Name = "Fog", Flag = "CustomFog", Default = false, Callback = function(v)
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
fogT:Colorpicker({ Flag = "c_fog", Default = Color3.fromRGB(128,128,128), Callback = function(c) C.Fog=c end })
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
    petal.Name = "SakuraPetal"
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
    cherryPetalFolder.Name = "PortalVisual_CherryBlossoms"
    cherryPetalFolder.Parent = workspace
    cherryActivePetals = {}
    cherryWindGust = Vector3.new(0, 0, 0)
    cherryWindTime = 0
    cherryWindConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt) cherryWindUpdate(dt) end))
    cherrySpawnConn = task.spawn(LPH_NO_VIRTUALIZE(function()
        while cherryRunning do
            createSakuraPetal()
            task.wait(cherrySettings.SpawnRate)
        end
    end))
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
        if obj.Name == "PortalAura" and obj:IsA("Atmosphere") then
            obj:Destroy()
        end
    end
    fogAtmosphere = Instance.new("Atmosphere", Lighting)
    fogAtmosphere.Name = "PortalAura"
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
weatherUI.cherry.max = WeatherTab:Slider({ Name = "Cherry Max Petals", Flag = "CherryMax", Min = 10, Max = 250, Default = 60, Callback = function(v) cherrySettings.MaxPetals = v end })
weatherUI.cherry.rate = WeatherTab:Slider({ Name = "Cherry Spawn Rate", Flag = "CherryRate", Min = 1, Max = 50, Default = 8, Suffix = "/100s", Callback = function(v) cherrySettings.SpawnRate = v / 100 end })
weatherUI.cherry.speed = WeatherTab:Slider({ Name = "Cherry Fall Speed", Flag = "CherrySpeed", Min = 5, Max = 100, Default = 18, Suffix = "/10", Callback = function(v) cherrySettings.FallSpeed = v / 10 end })
weatherUI.cherry.area = WeatherTab:Slider({ Name = "Radius", Flag = "CherryArea", Min = 10, Max = 150, Default = 50, Callback = function(v) cherrySettings.SpawnRadius = v end })
weatherUI.cherry.fogEnd = WeatherTab:Slider({ Name = "Fog Distance", Flag = "CherryFogEnd", Min = 100, Max = 10000, Default = 2000, Suffix = "st", Callback = function(v) if activeWeather == "Cherry Blossoms" then _W.applyWeatherAtmosphere("Cherry") end end })
weatherUI.cherry.fogDensity = WeatherTab:Slider({ Name = "Fog Density", Flag = "CherryFogDensity", Min = 0, Max = 100, Default = 15, Suffix = "%", Callback = function(v) if activeWeather == "Cherry Blossoms" then _W.applyWeatherAtmosphere("Cherry") end end })
local function setCherrySlidersVisibility(v)
    weatherUI.cherry.max:SetVisibility(v)
    weatherUI.cherry.rate:SetVisibility(v)
    weatherUI.cherry.speed:SetVisibility(v)
    weatherUI.cherry.area:SetVisibility(v)
    weatherUI.cherry.fogEnd:SetVisibility(v)
    weatherUI.cherry.fogDensity:SetVisibility(v)
end
local cherryToggle = WeatherTab:Toggle({ Name = "Cherry Blossoms", Flag = "CherryEnabled", Default = false, Callback = function(v)
    clearWeatherObjects()
    setCherrySlidersVisibility(v)
    if not v then
        if activeWeather == "Cherry Blossoms" then activeWeather = "None" end
        return
    end
    _W.turnOffOtherWeathers("CherryEnabled")
    activeWeather = "Cherry Blossoms"
    pcall(enableCherry)
end })
cherryToggle:Colorpicker({ Flag = "c_cherry_fog", Default = Color3.fromRGB(255, 230, 240), Callback = function(c)
end })
setCherrySlidersVisibility(false)

weatherUI.rain.rate = WeatherTab:Slider({ Name = "Rain Rate", Flag = "RainRate", Min = 10, Max = 1000, Default = 250, Callback = function(v)
    _W.rainSettings.Rate = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.speed = WeatherTab:Slider({ Name = "Rain Speed", Flag = "RainSpeed", Min = 10, Max = 300, Default = 120, Callback = function(v)
    _W.rainSettings.Speed = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.size = WeatherTab:Slider({ Name = "Rain Size", Flag = "RainSize", Min = 1, Max = 40, Default = 8, Callback = function(v)
    _W.rainSettings.Size = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.width = WeatherTab:Slider({ Name = "Rain Width", Flag = "RainWidth", Min = 1, Max = 100, Default = 30, Suffix = "%", Callback = function(v)
    _W.rainSettings.Width = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.area = WeatherTab:Slider({ Name = "Rain Radius", Flag = "RainArea", Min = 10, Max = 300, Default = 100, Callback = function(v)
    _W.rainSettings.Radius = v
    pcall(_W.refreshRain)
end })
weatherUI.rain.splash = WeatherTab:Toggle({ Name = "Rain Splashes", Flag = "RainSplashes", Default = true, Callback = function(v)
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
local rainToggle = WeatherTab:Toggle({ Name = "Rain", Flag = "RainEnabled", Default = false, Callback = function(v)
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
rainToggle:Colorpicker({ Flag = "c_rain", Default = Color3.fromRGB(190, 205, 240), Callback = function(c)
    pcall(_W.refreshRain)
end })

setRainSlidersVisibility(false)

weatherUI.snow.rate = WeatherTab:Slider({ Name = "Snow Rate", Flag = "SnowRate", Min = 10, Max = 500, Default = 150, Callback = function(v)
    _W.snowSettings.Rate = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.speed = WeatherTab:Slider({ Name = "Snow Speed", Flag = "SnowSpeed", Min = 5, Max = 150, Default = 25, Callback = function(v)
    _W.snowSettings.Speed = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.size = WeatherTab:Slider({ Name = "Snow Size", Flag = "SnowSize", Min = 1, Max = 15, Default = 3, Callback = function(v)
    _W.snowSettings.Size = v
    pcall(_W.refreshSnow)
end })
weatherUI.snow.area = WeatherTab:Slider({ Name = "Snow Radius", Flag = "SnowArea", Min = 10, Max = 300, Default = 100, Callback = function(v)
    _W.snowSettings.Radius = v
    pcall(_W.refreshSnow)
end })
local function setSnowSlidersVisibility(v)
    weatherUI.snow.rate:SetVisibility(v)
    weatherUI.snow.speed:SetVisibility(v)
    weatherUI.snow.size:SetVisibility(v)
    weatherUI.snow.area:SetVisibility(v)
end
local snowToggle = WeatherTab:Toggle({ Name = "Snow", Flag = "SnowEnabled", Default = false, Callback = function(v)
    clearWeatherObjects()
    setSnowSlidersVisibility(v)
    if not v then
        if activeWeather == "Snow" then activeWeather = "None" end
        return
    end
    _W.turnOffOtherWeathers("SnowEnabled")
    activeWeather = "Snow"
    pcall(_W.enableSnow)
end })

setSnowSlidersVisibility(false)
SkyTab:Toggle({ Name = "Custom Skybox", Flag = "CustomSkybox", Default = false, Callback = function(v)
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
SkyTab:Dropdown({ Name = "Skybox", Flag = "SkyChoice", Items = skyNames, Default = "Space", Callback = function(v)
    if Flags["CustomSkybox"] then local d=Skyboxes[v]; if d then
        if skyboxObj then skyboxObj:Destroy() end; skyboxObj=Instance.new("Sky")
        skyboxObj.SkyboxUp=d.Up; skyboxObj.SkyboxRt=d.Rt; skyboxObj.SkyboxLf=d.Lf; skyboxObj.SkyboxFt=d.Ft; skyboxObj.SkyboxBk=d.Bk; skyboxObj.SkyboxDn=d.Dn; if d.Moon then skyboxObj.MoonTextureId=d.Moon end; skyboxObj.Parent=Lighting end end
end })
SkyTab:Toggle({ Name = "Skybox Spin", Flag = "SkySpin", Default = false })
SkyTab:Slider({ Name = "Spin Speed", Flag = "SkySpinSpd", Min = 1, Max = 100, Default = 20 })
_origSunSize, _origMoonSize, _origStarCount = nil, nil, nil
_origSunRaysEnabled = nil
local function _getActiveSky() return skyboxObj or Lighting:FindFirstChildOfClass("Sky") end
SkyTab:Toggle({ Name = "Hide Sun", Flag = "HideSun", Default = false, Callback = function(v)
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
SkyTab:Toggle({ Name = "Hide Moon", Flag = "HideMoon", Default = false, Callback = function(v)
    local sky = _getActiveSky()
    if not sky then return end
    if v then _origMoonSize = _origMoonSize or sky.MoonAngularSize; sky.MoonAngularSize = 0
    else sky.MoonAngularSize = _origMoonSize or 11.17 end
end })
SkyTab:Toggle({ Name = "Hide Stars", Flag = "HideStars", Default = false, Callback = function(v)
    local sky = _getActiveSky()
    if not sky then return end
    if v then _origStarCount = _origStarCount or sky.StarCount; sky.StarCount = 0
    else sky.StarCount = _origStarCount or 3000 end
end })
MatTab:Toggle({ Name = "Custom Material", Flag = "CustMat", Default = false })
MatTab:Dropdown({ Name = "Material", Flag = "MatType", Items = {"None","Plastic","SmoothPlastic","Neon","ForceField","Glass","Wood","WoodPlanks","Marble","Granite","Slate","Concrete","Cobblestone","Brick","Sand","Fabric","CrackedLava","Ice","Glacier","Snow","Grass"}, Default = "None" })
MatTab:Dropdown({ Name = "Apply To", Flag = "MatApply", Items = {"All Parts","MeshParts","BaseParts","Wedges","Cylinders"}, Default = "All Parts" })
local mClr = MatTab:Toggle({ Name = "Custom Color", Flag = "MatClr", Default = false })
mClr:Colorpicker({ Flag = "c_mat", Default = Color3.new(1,1,1) })

end

do
local VisualsPage = Window:Page({ Name = "ESP", Icon = "rbxassetid://6523858394" })
local EspTab = VisualsPage:Section({ Name = "ESP", Side = 1 })
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
    setVis("_ESP_TextPos", nameEnabled or distEnabled)
    setVis("_ESP_NameType", nameEnabled)
    setVis("_ESP_DistanceEnabled", espEnabled)
    setVis("_ESP_DistanceType", distEnabled)
    setVis("_ESP_HealthBarEnabled", espEnabled)
    setVis("_ESP_HealthBarGradientEnabled", healthBarEnabled)
    setVis("_ESP_HealthTextEnabled", espEnabled)
    setVis("_ESP_ArmorBarEnabled", espEnabled)
    setVis("_ESP_WeaponEnabled", espEnabled)
    setVis("_ESP_FlagsEnabled", espEnabled)
    setVis("_ESP_TextSize", espEnabled)
    setVis("_ESP_TextOutline", espEnabled)
    setVis("_ESP_TracerEnabled", espEnabled)
    setVis("_ESP_TracerOrigin", tracerEnabled)
    setVis("_ESP_ToolIconEnabled", espEnabled)
    setVis("_ESP_HealthTextHideIfFull", healthTextEnabled)
    setVis("_ESP_BoxGlowEnabled", boxEnabled)
end

EspTab:Toggle({ Name = "Enable ESP", Flag = "ESP_Enabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_ShowOn"] = EspTab:Dropdown({ Name = "Show On", Flag = "ESP_ShowOn", Items = {"NPC", "Enemy", "Team", "Self"}, Default = {"Enemy", "NPC"}, Multi = true, Callback = function()
    local showOn = Flags["ESP_ShowOn"] or {}
    if hasCheck(showOn, "Self") then
        EspLibrary:AddTarget(lp)
    else
        EspLibrary:RemoveTarget(lp)
    end
end })
Flags["_ESP_MaxDistance"] = EspTab:Slider({ Name = "Max Distance", Flag = "ESP_MaxDistance", Min = 50, Max = 10000, Default = 3000, Suffix = " studs" })
Flags["_ESP_Font"] = EspTab:Dropdown({ Name = "ESP Font", Flag = "ESP_Font", Items = {"ProggyClean", "SmallestPixel", "Tahoma", "TahomaBold", "Arial", "SourceSans"}, Default = "ProggyClean" })
Flags["_ESP_TextSize"] = EspTab:Slider({ Name = "Text Size", Flag = "ESP_TextSize", Min = 8, Max = 20, Default = 11, Suffix = "px" })
Flags["_ESP_TextOutline"] = EspTab:Toggle({ Name = "Text Outline", Flag = "ESP_TextOutline", Default = true })

local boxT = EspTab:Toggle({ Name = "Box ESP", Flag = "ESP_BoxEnabled", Default = false, Callback = updateESPVisibility })
boxT:Colorpicker({ Flag = "ESP_BoxInlineColor", Default = Color3.fromRGB(255, 255, 255) })
boxT:Colorpicker({ Flag = "ESP_BoxOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_BoxShape"] = EspTab:Dropdown({ Name = "Box Shape", Flag = "ESP_BoxShape", Items = {"Full", "Cornered"}, Default = "Full" })
Flags["_ESP_TextPos"] = EspTab:Dropdown({ Name = "Text Position", Flag = "ESP_TextPos", Items = {"Top", "Bottom", "Left", "Right"}, Default = "Top" })

local fillT = EspTab:Toggle({ Name = "Box Fill", Flag = "ESP_BoxFillEnabled", Default = false, Callback = updateESPVisibility })
fillT:Colorpicker({ Flag = "ESP_BoxFillColor", Default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_BoxFillEnabled"] = fillT
Flags["_ESP_BoxFillTrans1"] = EspTab:Slider({ Name = "Fill Transparency 1", Flag = "ESP_BoxFillTrans1", Min = 0, Max = 100, Default = 100, Suffix = "%" })
Flags["_ESP_BoxFillTrans2"] = EspTab:Slider({ Name = "Fill Transparency 2", Flag = "ESP_BoxFillTrans2", Min = 0, Max = 100, Default = 65, Suffix = "%" })

Flags["_ESP_BoxGlowEnabled"] = EspTab:Toggle({ Name = "Box Glow", Flag = "ESP_BoxGlowEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_BoxGlowEnabled"]:Colorpicker({ Flag = "ESP_BoxGlowColor", Default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_BoxGlowAmount"] = EspTab:Slider({ Name = "Glow Amount", Flag = "ESP_BoxGlowAmount", Min = 0, Max = 100, Default = 65, Suffix = "%" })

local nameT = EspTab:Toggle({ Name = "Name ESP", Flag = "ESP_NameEnabled", Default = false, Callback = updateESPVisibility })
nameT:Colorpicker({ Flag = "ESP_NameInlineColor", Default = Color3.fromRGB(255, 255, 255) })
nameT:Colorpicker({ Flag = "ESP_NameOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_NameType"] = EspTab:Dropdown({ Name = "Name Type", Flag = "ESP_NameType", Items = {"Display Name", "Username", "Both"}, Default = "Display Name" })

local distT = EspTab:Toggle({ Name = "Distance ESP", Flag = "ESP_DistanceEnabled", Default = false, Callback = updateESPVisibility })
distT:Colorpicker({ Flag = "ESP_DistanceInlineColor", Default = Color3.fromRGB(255, 255, 255) })
distT:Colorpicker({ Flag = "ESP_DistanceOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_DistanceType"] = EspTab:Dropdown({ Name = "Distance Type", Flag = "ESP_DistanceType", Items = {"Studs", "Meters"}, Default = "Studs" })

local hpBarT = EspTab:Toggle({ Name = "Health Bar", Flag = "ESP_HealthBarEnabled", Default = false, Callback = updateESPVisibility })
hpBarT:Colorpicker({ Flag = "ESP_HealthBarInlineColor", Default = Color3.fromRGB(0, 255, 0) })
hpBarT:Colorpicker({ Flag = "ESP_HealthBarOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_HealthBarGradientEnabled"] = EspTab:Toggle({ Name = "Health Bar Gradient", Flag = "ESP_HealthBarGradientEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_HealthBarGradientEnabled"]:Colorpicker({ Flag = "ESP_HealthBarTopColor", Default = Color3.fromRGB(0, 255, 0) })
Flags["_ESP_HealthBarGradientEnabled"]:Colorpicker({ Flag = "ESP_HealthBarMidColor", Default = Color3.fromRGB(255, 170, 0) })
Flags["_ESP_HealthBarGradientEnabled"]:Colorpicker({ Flag = "ESP_HealthBarBotColor", Default = Color3.fromRGB(255, 0, 0) })

Flags["_ESP_HealthTextEnabled"] = EspTab:Toggle({ Name = "Health Text", Flag = "ESP_HealthTextEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_HealthTextEnabled"]:Colorpicker({ Flag = "ESP_HealthTextInlineColor", Default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_HealthTextEnabled"]:Colorpicker({ Flag = "ESP_HealthTextOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
Flags["_ESP_HealthTextHideIfFull"] = EspTab:Toggle({ Name = "Hide Health If Full", Flag = "ESP_HealthTextHideIfFull", Default = false, Callback = updateESPVisibility })

Flags["_ESP_ArmorBarEnabled"] = EspTab:Toggle({ Name = "Armor Bar", Flag = "ESP_ArmorBarEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_ArmorBarEnabled"]:Colorpicker({ Flag = "ESP_ArmorBarInlineColor", Default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_ArmorBarEnabled"]:Colorpicker({ Flag = "ESP_ArmorBarOutlineColor", Default = Color3.fromRGB(0, 0, 0) })

Flags["_ESP_TracerEnabled"] = EspTab:Toggle({ Name = "Tracer ESP", Flag = "ESP_TracerEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_TracerEnabled"]:Colorpicker({ Flag = "ESP_TracerColor", Default = Color3.fromRGB(255, 255, 255) })
Flags["_ESP_TracerOrigin"] = EspTab:Dropdown({ Name = "Tracer Origin", Flag = "ESP_TracerOrigin", Items = {"Bottom", "Top", "Cursor", "Center"}, Default = "Bottom" })
EspTab:Slider({ Name = "Tracer Neon Amount", Flag = "ESP_TracerNeonAmount", Min = 0, Max = 100, Default = 0 })

Flags["_ESP_WeaponEnabled"] = EspTab:Toggle({ Name = "Weapon ESP", Flag = "ESP_WeaponEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_WeaponEnabled"]:Colorpicker({ Flag = "ESP_WeaponColor", Default = Color3.fromRGB(255, 255, 255) })

Flags["_ESP_FlagsEnabled"] = EspTab:Toggle({ Name = "State Flags", Flag = "ESP_FlagsEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_FlagsEnabled"]:Colorpicker({ Flag = "ESP_FlagsColor", Default = Color3.fromRGB(255, 0, 0) })

-- Tool Icon settings (no outline box, pos/size/transparency)
Flags["_ESP_ToolIconEnabled"] = EspTab:Toggle({ Name = "Tool Icon", Flag = "ESP_ToolIconEnabled", Default = false, Callback = updateESPVisibility })
Flags["_ESP_ToolIconEnabled"]:Colorpicker({ Flag = "ESP_ToolIconColor", Default = Color3.fromRGB(255, 255, 255) })
EspTab:Slider({ Name = "Tool Icon Size", Flag = "ESP_ToolIconSize", Min = 8, Max = 64, Default = 16, Callback = updateESPVisibility })
EspTab:Slider({ Name = "Tool Icon X Offset", Flag = "ESP_ToolIconOffsetX", Min = -100, Max = 100, Default = 0, Callback = updateESPVisibility })
EspTab:Slider({ Name = "Tool Icon Y Offset", Flag = "ESP_ToolIconOffsetY", Min = -100, Max = 100, Default = 0, Callback = updateESPVisibility })
EspTab:Slider({ Name = "Tool Icon Transparency", Flag = "ESP_ToolIconTransparency", Min = 0, Max = 100, Default = 0, Suffix = "%", Callback = updateESPVisibility })

task.spawn(function()
    task.wait(0.5)
    pcall(updateESPVisibility)
end)

getColorFromFlag = LPH_NO_VIRTUALIZE(function(flagName, default, rgbMode, rgbSpeedFlag)
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
end)

getChamsColor = LPH_NO_VIRTUALIZE(function(flagName, default)
    return getColorFromFlag(flagName, default, "ChamsRGBMode", "ChamsRGBSpeed")
end)

applyChamsHighlight = LPH_NO_VIRTUALIZE(function(char, fillColor, outlineColor, fillTrans, outlineTrans, alwaysOnTop, outlineOnly, glowAmount, textureId)
    if not char then return end
    local hl = char:FindFirstChild("_Chams")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "_Chams"
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
                    tex.Name = "_ChamsTex"
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
            blur.Name = "_ChamsBlur"
            blur.Parent = char
        end
        blur.Size = glowAmount * 20
    else
        local blur = char:FindFirstChild("_ChamsBlur")
        if blur then blur:Destroy() end
    end
end)

removeChamsHighlight = LPH_NO_VIRTUALIZE(function(char)
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
end)

isCharVisible = LPH_NO_VIRTUALIZE(function(char)
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hrp then return false end
    local origin = camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {lp.Character, char}
    local res = workspace:Raycast(origin, hrp.Position - origin, rayParams)
    return not res
end)

local applyOrRemoveChams = LPH_NO_VIRTUALIZE(function(char, checkDead, checkWall, isSelf, chamsParams)
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
end)

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

task.spawn(LPH_NO_VIRTUALIZE(function()
    while _scriptRunning do
        task.wait(0.05)
        pcall(updateChams)
    end
end))

local chamsT = ChamsTab:Toggle({ Name = "Player Chams", Flag = "PlayerChams", Default = false, Callback = updateChams })
ChamsTab:Dropdown({ Name = "Targets", Flag = "ChamsTargets", Items = {"Player", "NPC", "Self"}, Default = {}, Multi = true, Callback = updateChams })
chamsT:Colorpicker({ Flag = "ChamsFillColor", Default = Color3.fromRGB(255, 255, 255), Callback = updateChams })
chamsT:Colorpicker({ Flag = "ChamsOutlineColor", Default = Color3.fromRGB(0, 0, 0), Callback = updateChams })
ChamsTab:Slider({ Name = "Fill Transparency", Flag = "ChamsFillTransparency", Min = 0, Max = 100, Default = 50, Suffix = "%", Callback = updateChams })
ChamsTab:Slider({ Name = "Outline Transparency", Flag = "ChamsOutlineTransparency", Min = 0, Max = 100, Default = 0, Suffix = "%", Callback = updateChams })
ChamsTab:Toggle({ Name = "RGB Mode", Flag = "ChamsRGBMode", Default = false, Callback = updateChams })
ChamsTab:Slider({ Name = "RGB Speed", Flag = "ChamsRGBSpeed", Min = 1, Max = 20, Default = 5, Callback = updateChams })
ChamsTab:Dropdown({ Name = "Texture", Flag = "ChamsTexture", Items = {"None", "Neon", "Plastic", "ForceField", "Glow"}, Default = "None", Callback = updateChams })
ChamsTab:Dropdown({ Name = "Checks", Flag = "ChamsChecks", Items = {"Dead", "Wall", "NPC", "Enemy", "Team"}, Default = {}, Multi = true, Callback = updateChams })

local toolChamsT = ChamsTab:Toggle({ Name = "Tool Chams", Flag = "ToolChamsEnabled", Default = false })
ChamsTab:Dropdown({ Name = "Tool Targets", Flag = "ToolChamsTargets", Items = {"Player", "NPC", "Self"}, Default = {"Player"}, Multi = true })
toolChamsT:Colorpicker({ Flag = "ToolChamsColor", Default = Color3.fromRGB(255, 255, 255) })
toolChamsT:Colorpicker({ Flag = "ToolChamsOutlineColor", Default = Color3.fromRGB(0, 0, 0) })
ChamsTab:Slider({ Name = "Tool Fill Transparency", Flag = "ToolChamsTrans", Min = 0, Max = 100, Default = 0, Suffix = "%" })
ChamsTab:Slider({ Name = "Tool Outline Transparency", Flag = "ToolChamsOutlineTrans", Min = 0, Max = 100, Default = 0, Suffix = "%" })
ChamsTab:Toggle({ Name = "Tool RGB Mode", Flag = "ToolChamsRGBMode", Default = false })
ChamsTab:Slider({ Name = "Tool RGB Speed", Flag = "ToolChamsRGBSpeed", Min = 1, Max = 20, Default = 5 })

task.spawn(LPH_NO_VIRTUALIZE(function()
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
                                    hl.Name = "_ToolChamsHL"
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
end))



end

do
local MiscPage = Window:Page({ Name = "Misc", Icon = "rbxassetid://9525535512" })
local MiscL = MiscPage:Section({ Name = "Misc", Side = 1 })
local MiscMultiR = MiscPage:MultiSection({ Side = 2 })
local MiscR = MiscMultiR:Add("MiscRight")
local AvatarSection = MiscMultiR:Add("Avatar")
-- Desync section removed

local MoveTab2 = MiscL
local AnimTab = MiscL
local TriggerBotTab = MiscR
local SkinsTab2 = MiscR

TriggerBotTab:Toggle({ Name = "Trigger Bot", Flag = "TriggerBotEnabled", Default = false }):Keybind({ Flag = "TriggerBotBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
TriggerBotTab:Slider({ Name = "Trigger Delay", Flag = "TriggerBotDelay", Min = 0, Max = 1000, Default = 0, Suffix = "ms" })
TriggerBotTab:Toggle({ Name = "Require Target", Flag = "TriggerBotRequireTarget", Default = true })
TriggerBotTab:Toggle({ Name = "Require Knife", Flag = "TriggerBotRequireKnife", Default = false })

MoveTab2:Toggle({ Name = "Speed Boost", Flag = "SpeedEnabled", Default = false }):Keybind({ Flag = "SpeedBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:Slider({ Name = "Walk Speed", Flag = "WalkSpd", Min = 16, Max = 200, Default = 16 })
MoveTab2:Dropdown({ Name = "Speed Method", Flag = "SpeedMethod", Items = {"Default","Velocity"}, Default = "Default" })
MoveTab2:Toggle({ Name = "Jump Boost", Flag = "JumpBoost", Default = false }):Keybind({ Flag = "JumpBoostBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:Slider({ Name = "Jump Power", Flag = "JumpPwr", Min = 50, Max = 2000, Default = 50 })
MoveTab2:Dropdown({ Name = "Jump Method", Flag = "JumpMethod", Items = {"Default","Velocity","CFrame"}, Default = "Default" })
MoveTab2:Toggle({ Name = "Noclip", Flag = "NoclipEnabled", Default = false }):Keybind({ Flag = "NoclipBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:Toggle({ Name = "Fly", Flag = "FlyEnabled", Default = false }):Keybind({ Flag = "FlyBind", Default = Enum.KeyCode.Unknown, Mode = "Toggle" })
MoveTab2:Slider({ Name = "Fly Speed", Flag = "FlySp", Min = 10, Max = 300, Default = 50 })
MoveTab2:Dropdown({ Name = "Fly Method", Flag = "FlyMethod", Items = {"Default","Velocity","CFrame"}, Default = "Default" })
MoveTab2:Toggle({ Name = "Anti AFK", Flag = "AntiAFK", Default = false })
AvatarSection:Toggle({ Name = "Headless", Flag = "HeadlessEnabled", Default = false })
AvatarSection:Toggle({ Name = "Korblox (Right Leg)", Flag = "KorbloxRight", Default = false })
AvatarSection:Toggle({ Name = "Korblox (Left Leg)", Flag = "KorbloxLeft", Default = false })

-- Desync UI removed

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
            m.Name = "_KorbloxMesh"
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
    Zombie = {
        idle1 = "rbxassetid://10921344533",
        idle2 = "rbxassetid://10921345304",
        run = "rbxassetid://616163682",
        walk = "rbxassetid://616168032",
        jump = "rbxassetid://616161997",
        fall = "rbxassetid://616157476",
        climb = "rbxassetid://616156119",
        swim = "rbxassetid://616165109",
    },
    Ninja = {
        idle1 = "rbxassetid://656117400",
        idle2 = "rbxassetid://656118341",
        run = "rbxassetid://656118852",
        walk = "rbxassetid://656121766",
        jump = "rbxassetid://656117878",
        fall = "rbxassetid://656115606",
        climb = "rbxassetid://656114359",
        swim = "rbxassetid://656119721",
    },
    Mage = {
        idle1 = "rbxassetid://707742142",
        idle2 = "rbxassetid://707742142",
        run = "rbxassetid://707861613",
        walk = "rbxassetid://707861613",
        jump = "rbxassetid://707853694",
        fall = "rbxassetid://707829716",
        climb = "rbxassetid://707829716",
        swim = "rbxassetid://707876750",
    },
}

local animConnection = nil
local _feAnimConn = nil
local function setupAnimChanger()
    if animConnection then animConnection:Disconnect(); animConnection = nil end
    if _feAnimConn then _feAnimConn:Disconnect(); _feAnimConn = nil end

    if not Flags["AnimEnabled"] then return end

    local function getAnimId(slot, flag)
        local style = Flags[flag] or "Default"
        if style == "Default" then return nil end
        local ids = AnimationIDs[style]
        return ids and ids[slot]
    end

    local function setAnimateIds(char, doRestart)
        local animate = char:FindFirstChild("Animate")
        if not animate then return end

        local function setPath(root, path, id)
            if not id then return end
            local obj = root
            for _, name in ipairs(path) do
                obj = obj:FindFirstChild(name)
                if not obj then return end
            end
            if obj and obj:IsA("Animation") then
                obj.AnimationId = id
            end
        end

        setPath(animate, {"idle", "Animation1"}, getAnimId("idle1", "AnimIdle"))
        setPath(animate, {"idle", "Animation2"}, getAnimId("idle2", "AnimIdle"))
        setPath(animate, {"run", "RunAnim"}, getAnimId("run", "AnimRun"))
        setPath(animate, {"walk", "WalkAnim"}, getAnimId("walk", "AnimWalk"))
        setPath(animate, {"jump", "JumpAnim"}, getAnimId("jump", "AnimJump"))
        setPath(animate, {"fall", "FallAnim"}, getAnimId("fall", "AnimFall"))
        setPath(animate, {"climb", "ClimbAnim"}, getAnimId("climb", "AnimWalk"))
        setPath(animate, {"swim", "Swim"}, getAnimId("swim", "AnimSwim"))

        if doRestart and animate:IsA("LocalScript") then
            pcall(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        pcall(function() track:Stop(0) end)
                    end
                end
                local clone = animate:Clone()
                clone.Disabled = false
                clone.Parent = char
                animate:Destroy()
            end)
        end
    end

    local function applyToChar(char, doRestart)
        pcall(setAnimateIds, char, doRestart)
    end

    if lp.Character then
        task.spawn(applyToChar, lp.Character, true)
    end
    animConnection = lp.CharacterAdded:Connect(function(char)
        task.wait(1)
        applyToChar(char, true)
    end)
end
local animStyles = {"Default", "Zombie", "Mage", "Ninja"}
AnimTab:Toggle({ Name = "Animation Changer", Flag = "AnimEnabled", Default = false, Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Walk", Flag = "AnimWalk", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Run", Flag = "AnimRun", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Idle", Flag = "AnimIdle", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Jump", Flag = "AnimJump", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Fall", Flag = "AnimFall", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
AnimTab:Dropdown({ Name = "Swim", Flag = "AnimSwim", Items = animStyles, Default = "Default", Callback = setupAnimChanger })
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
    SkinsTab2:Toggle({ Name = "Skin Changer", Flag = "HCSkinEnabled", Default = false })
    hcGunSkins = {"Default","Adurite","Amethyst","Arctic","Arsenic","Ascension","Binary","Black Cat","Black Ice","Blacksteel Dragon","Candy Cane","Crimson Fangs","Cupid","Deathbringer","Ember","Floral","Green Tint","Hallows","Heartbringer","Hell Dragon","Hell Hound","Hello Kitty","Hexagram","Kirumi","Kitty","Lightbringer","Lovestruck","None","Phoenix","Poseidon","Radiation","Shiryus Breath","Snow Dragon","Strawberry Shortcake","Void","Void Dragon","Volcanic Ashes","Voxel"}
    hcKnifeSkins = {"Default","Beta","Bitcoin","Fishbone","Nightblade","None"}
    hcBeamSkins = {"Default","Beta","Blue","Green","Hallows","Kirumi","Kitty","Lightning","None","Orange","Rainbow","Red"}
    hcWeapons = {"DoubleBarrel", "Revolver", "TacticalShotgun", "SMG", "Shotgun"}
    for _, wep in ipairs(hcWeapons) do
        SkinsTab2:Dropdown({ Name = wep, Flag = "HC_" .. wep, Items = hcGunSkins, Default = "Default" })
    end
    SkinsTab2:Dropdown({ Name = "Knife", Flag = "HC_Knife", Items = hcKnifeSkins, Default = "Default" })
    SkinsTab2:Toggle({ Name = "Beam Changer", Flag = "HCBeamEnabled", Default = false })
    for _, wep in ipairs(hcWeapons) do
        SkinsTab2:Dropdown({ Name = wep .. " Beam", Flag = "HCBeam_" .. wep, Items = hcBeamSkins, Default = "Default" })
    end
    SkinsTab2:Slider({ Name = "Neon Amount", Flag = "HCNeonAmount", Min = 0, Max = 100, Default = 0 })
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    hcProcessed = setmetatable({}, { __mode = "k" })
    hcGetSkinModel = function(weaponName, skinName)
        if not skinName or skinName == "" or skinName == "Default" or skinName == "None" then return nil end
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
        local neonAmount = (Flags["HCNeonAmount"] or 0) / 100
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.Anchored = false
                p.Massless = true
                if neonAmount > 0 then
                    p.Material = Enum.Material.Neon
                    p.Transparency = math.max(0, 1 - neonAmount)
                end
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
        clone.Name = "_OverridePart"
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
        clone.Name = "_OverridePart"
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
    hcRainbowBeamItems = {}
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
    task.spawn(LPH_NO_VIRTUALIZE(function()
        while _scriptRunning do
            if not Flags["HCBeamEnabled"] or not next(hcRainbowBeamItems) then
                task.wait(1)
            else
                updateHcBeam()
                task.wait(0.05)
            end
        end
    end))
    hcApplySkin = function(tool)
        task.defer(function()
            if not Flags["HCSkinEnabled"] then return end
            if not tool or not tool:IsA("Tool") then return end
            local weaponName = tool.Name:match("^%[(.+)%]$")
            if not weaponName then return end
            local skinName = Flags["HC_" .. weaponName]
            if skinName and skinName ~= "" and skinName ~= "Default" then
                if skinName == "None" then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then handle.Transparency = 1 end
                    return
                end
                local skinModel = hcGetSkinModel(weaponName, skinName)
                if skinModel then
                    hcApplyModelOnHolder(tool, skinModel)
                end
            else
                if tool:FindFirstChild("_OverridePart") then
                    restoreOriginalSkin(tool)
                end
            end
        end)
    end
    hcApplyKnife = function(tool)
        task.defer(function()
            if not Flags["HCSkinEnabled"] then return end
            if not tool or not tool:IsA("Tool") then return end
            local isKnife = tool.Name == "[Knife]" or tool.Name:lower():find("knife")
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
            else
                if tool:FindFirstChild("_OverridePart") then
                    restoreOriginalSkin(tool)
                end
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
                        bulletBeamData[code] = { Name = beamSkin }
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
        local char = lp.Character
        if not char then return end
        if Flags["HCSkinEnabled"] then
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
        else
            for _, obj in ipairs(char:GetDescendants()) do
                if (obj:IsA("Tool") or obj:IsA("Folder") or obj:IsA("Model")) and obj:FindFirstChild("_OverridePart") then
                    pcall(function() restoreOriginalSkin(obj) end)
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
                local skinName = Flags["HC_" .. weaponName]
                local handleFolder = character:FindFirstChild(h) or character:WaitForChild(h, 5)
                if handleFolder and skinName and skinName ~= "" and skinName ~= "Default" and skinName ~= "None" then
                    local skinModel = hcGetSkinModel(weaponName, skinName)
                    if skinModel then hcApplyModelOnHolder(handleFolder, skinModel) end
                elseif handleFolder and (not skinName or skinName == "" or skinName == "Default") then
                    if handleFolder:FindFirstChild("_OverridePart") then
                        restoreOriginalSkin(handleFolder)
                    end
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
    SkinsTab2:Button({ Name = "Reapply Skins", Callback = function()
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
    SkinsTab2:Button({ Name = "Strip All Skins", Callback = function()
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
        SkinsTab2:Toggle({ Name = "Skin Swapper", Flag = "SkinSwap", Default = false })
        SkinsTab2:Dropdown({ Name = "Revolver", Flag = "RevSkin", Items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Devilish","Blue Wave","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, Default = "Default" })
        SkinsTab2:Dropdown({ Name = "Double-Barrel", Flag = "DBSkin", Items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, Default = "Default" })
        SkinsTab2:Dropdown({ Name = "Tactical Shotgun", Flag = "TacSkin", Items = {"Purple","Red","Green","Blue","Grey","Ghost","Rainbow","Cosmic","Sapphire","Valedo","emrald","Angel","Dark Purple","RCB","Myosotis","Axe Red","miku","Ying Yang","Yellow","Devilish","Blue Wave","Purple Galaxy","Blue Nebula ","Blood Flow","Crystalized","Genisis","Darkmatter","Bloodstone","Abyss","Absolute Zero","Default"}, Default = "Default" })
        SkinsTab2:Toggle({ Name = "Animated", Flag = "AnimatedSkins", Default = true })
        SkinsTab2:Slider({ Name = "Neon Amount", Flag = "HCNeonAmount", Min = 0, Max = 100, Default = 0 })
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
applySkinTextures = LPH_NO_VIRTUALIZE(function(tool, texId, color)
    if not texId or texId == "" then return false end
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
            if color then default.Color = color end
            applied = true
        end
    end
    if not applied then
        for _, desc in ipairs(tool:GetDescendants()) do
            if desc:FindFirstAncestor("_OverridePart") or desc.Name == "Handle" or desc.Name == "Neon" then continue end
            if desc:IsA("SpecialMesh") then
                desc.TextureId = texId
                applied = true
                break
            elseif desc:IsA("MeshPart") then
                desc.TextureID = texId
                if color then desc.Color = color end
                applied = true
                break
            end
        end
    end
    return applied
end)
applyScrollTexSkin = LPH_NO_VIRTUALIZE(function(tool, data, wName, neonAmount)
    local stTexId = data.Textures and data.Textures[wName] or ""
    local forcedMeshId = scrollMeshIds[wName]
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:FindFirstAncestor("_OverridePart") then continue end
        if desc:IsA("BasePart") and desc.Name == "Neon" then
            desc.Color = data.Color
            desc.Material = Enum.Material.Neon
            desc.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
        elseif desc:IsA("MeshPart") and desc.Name ~= "Neon" and desc.Name ~= "Handle" then
            if forcedMeshId then desc.MeshId = forcedMeshId end
            if stTexId ~= "" then desc.TextureID = stTexId end
            desc.Color = data.Color
        elseif desc:IsA("SpecialMesh") then
            if forcedMeshId then
                desc.MeshId = forcedMeshId
                desc.MeshType = Enum.MeshType.FileMesh
            end
            if stTexId ~= "" then desc.TextureId = stTexId end
            desc.VertexColor = Vector3.new(data.Color.R, data.Color.G, data.Color.B)
        end
    end
end)
applyDaTrackSkin = LPH_NO_VIRTUALIZE(function(tool, w, data, skinName, neonAmount)
    local h = tool:FindFirstChild("Handle")
    if h and h:IsA("BasePart") then h.Transparency = 1 end
    if data.ScrollTex then
        applyScrollTexSkin(tool, data, w.name, neonAmount)
        return
    end
    local texId = data.Textures and data.Textures[w.name] or ""
    if texId == "" and not data.CosmicCycle and not data.AltMesh then return end
    if data.AltMesh then
        local meshId = data.MeshIds and data.MeshIds[w.name] or ""
        if meshId ~= "" then
            for _, desc in ipairs(tool:GetDescendants()) do
                if not desc:FindFirstAncestor("_OverridePart") and desc.Name ~= "Handle" then
                    if desc:IsA("MeshPart") and desc.Name ~= "Neon" then
                        desc.MeshId = meshId
                        if texId ~= "" then desc.TextureID = texId end
                    elseif desc:IsA("SpecialMesh") then
                        desc.MeshId = meshId
                        desc.MeshType = Enum.MeshType.FileMesh
                        if texId ~= "" then desc.TextureId = texId end
                    end
                end
            end
        end
        if data.NoNeon then
            for _, desc in ipairs(tool:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name == "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                    desc.Transparency = 1
                end
            end
        else
            for _, desc in ipairs(tool:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name == "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                    desc.Color = data.Color
                    desc.Material = Enum.Material.Neon
                    desc.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                end
            end
        end
        return
    end
    for _, desc in ipairs(tool:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name == "Neon" and not desc:FindFirstAncestor("_OverridePart") then
            if data.CosmicCycle then
                local hue = (tick() * 0.3) % 1
                desc.Color = Color3.fromHSV(hue, 0.7, 1)
            else
                desc.Color = data.Color
            end
            desc.Material = Enum.Material.Neon
            desc.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
        end
    end
    applySkinTextures(tool, texId, data.Color)
    if data.Particle then
        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("Default")
        if handle and handle:IsA("BasePart") and not handle:FindFirstChild("_SkinParticle") then
            local pe = Instance.new("ParticleEmitter")
            pe.Name = "_SkinParticle"
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
end)
if not isHoodCustoms then
cosmicIndex = 0
cosmicTimer = 0
_skinFrameCounter = 0
_skinSwapWasOn = false
_lastAppliedSkins = {}
_skinWeps = {{name="[Revolver]",flag="RevSkin"},{name="[Double-Barrel SG]",flag="DBSkin"},{name="[TacticalShotgun]",flag="TacSkin"}}
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
    
    -- Skip if all skins are set to Default
    local revSkin = Flags["RevSkin"] or "Default"
    local dbSkin = Flags["DBSkin"] or "Default"
    local tacSkin = Flags["TacSkin"] or "Default"
    if revSkin == "Default" and dbSkin == "Default" and tacSkin == "Default" then
        return
    end
    
    _skinSwapWasOn = true
    local neonAmount = (Flags["HCNeonAmount"] or 0) / 100
    
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
                local equippedWepName = nil
                for _,w in ipairs(weps) do
                    if equippedTool.Name == w.name then
                        equippedWepName = w.name
                        local sName = Flags[w.flag] or "Default"
                        local sData = SkinData[sName]
                        if sData and (not sData.RevolverOnly or w.name == "[Revolver]") then
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
                                    local strippedName = equippedWepName:gsub("%[",""):gsub("%]","")
                                    for _,c in ipairs(beamChildren) do
                                        if c:IsA("Beam") then
                                            if c.Name == equippedWepName or c.Name:find(strippedName, 1, true) then
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
                                local beamWidthScale = isDaTrack and 0.62 or 1.08
                                c.Width0 = math.max(ow[1] * beamWidthScale, 0.015)
                                c.Width1 = math.max(ow[2] * beamWidthScale, 0.015)
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
                if equippedTool.Name == w.name then
                    matchedWep = w
                    break
                end
            end
            if matchedWep then
                local sName = Flags[matchedWep.flag] or "Default"
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
                                if desc:IsA("BasePart") and desc.Name ~= "Handle" and desc.Name ~= "Neon" and not desc:FindFirstAncestor("_OverridePart") then
                                    if desc:IsA("MeshPart") or desc.Name == "Mesh" or desc.Name == "Default" or desc:FindFirstChildOfClass("SpecialMesh") then
                                        for _, face in ipairs({Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Back}) do
                                            local tex = Instance.new("Texture")
                                            tex.Name = "_ScrollTex"
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
        local skinName = Flags[w.flag] or "Default"
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
                if desc:FindFirstAncestor("_OverridePart") or desc.Name == "Handle" then continue end
                if desc:IsA("BasePart") and desc.Name == "Neon" then
                    cache.neon[#cache.neon + 1] = desc
                elseif desc:IsA("MeshPart") and desc.Name ~= "Neon" then
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
                    p.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                end
                for _, p in ipairs(cache.mesh) do
                    p.Material = Enum.Material.Neon
                    p.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                    if p:IsA("MeshPart") then p.TextureID = "" end
                end
                for _, m in ipairs(cache.special) do
                    m.TextureId = ""
                end
                if default and default:IsA("MeshPart") then
                    default.TextureID = ""
                    default.Material = Enum.Material.Neon
                    default.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                end
                local dm = cache.defaultMesh
                if dm then
                    if dm:IsA("SpecialMesh") then
                        dm.TextureId = ""
                    elseif dm:IsA("MeshPart") then
                        dm.TextureID = ""
                        dm.Material = Enum.Material.Neon
                        dm.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                    end
                end
                local f = cache.fallback
                if f then
                    if f:IsA("SpecialMesh") then
                        f.TextureId = ""
                    elseif f:IsA("MeshPart") then
                        f.TextureID = ""
                        f.Material = Enum.Material.Neon
                        f.Transparency = neonAmount > 0 and math.max(0, 1 - neonAmount) or 0
                    end
                end
            end
            _animSkinCache[w.name] = cache
        end
        local h = tool:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then h.Transparency = 1 end
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
        local neonAmount = (Flags["HCNeonAmount"] or 0) / 100
        local char = lp.Character
        local bp = lp:FindFirstChild("Backpack")
        local weps = _skinWeps
        for _, w in ipairs(weps) do
            pcall(function()
                local skinName = Flags[w.flag] or "Default"
                local tool = (bp and bp:FindFirstChild(w.name)) or (char and char:FindFirstChild(w.name))
                if not tool then
                    _lastAppliedSkins[w.name] = nil
                    return
                end
                if not _originalToolProperties[tool] then
                    cacheOriginalSkin(tool)
                end
                local applyKey = w.name .. ":" .. skinName .. ":" .. tostring(tool)
                local skinChanged = _lastAppliedSkins[w.name] ~= applyKey
                if skinName == "Default" then
                    if skinChanged then
                        restoreOriginalSkin(tool)
                        _lastAppliedSkins[w.name] = applyKey
                    end
                    return
                end
                local data = SkinData[skinName]
                if not data then return end
                if data.RevolverOnly and w.name ~= "[Revolver]" then return end
                if data.Pulsate or data.Rainbow then return end
                if skinChanged then
                    restoreOriginalSkin(tool)
                    _lastAppliedSkins[w.name] = applyKey
                end
                applyDaTrackSkin(tool, w, data, skinName, neonAmount)
            end)
        end
        pcall(function()
            local df = lp:FindFirstChild("DataFolder")
            if not df then return end
            local eq = df:FindFirstChild("Inventory")
            if not eq then return end
            eq = eq:FindFirstChild("Equipped")
            if not eq then return end
            local sk = eq:FindFirstChild("Skins")
            if not sk then return end
            for _, w in ipairs(weps) do
                local sv = sk:FindFirstChild(w.name)
                if sv then sv.Value = "Shadow" end
            end
        end)
    end
end))

end

do
SetPage = Window:Page({ Name = "Settings", Icon = "rbxassetid://7059346373" })
ConfigSection = SetPage:Section({ Name = "Configs", Side = 1 })
_SettingsSection = SetPage:Section({ Name = "Settings", Side = 2 })
_ThemeSection = SetPage:Section({ Name = "Themes", Side = 2 })
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
    -- Only skip config UI controls themselves
    CfgName=true, CfgSelect=true, AutoSaveCfg=true, AutoLoadCfg=true, AutoLoadEnabled=true,
    CreateThemeName=true,
}
_serializeColor3 = function(c)
    return {_type="Color3", R=math.floor(c.R*255+0.5), G=math.floor(c.G*255+0.5), B=math.floor(c.B*255+0.5)}
end

saveConfig = LPH_NO_VIRTUALIZE(function(name)
    if not name or name == "" then return end
    local data = {}
    for flag, value in pairs(Flags) do
        if type(flag) ~= "string" then continue end
        if CFG_SKIP[flag] then continue end
        if flag:match("^_") then continue end
        local t = typeof(value)
        if t == "boolean" or t == "number" or t == "string" then
            data[flag] = value
        elseif t == "Color3" then
            data[flag] = _serializeColor3(value)
        elseif t == "table" then
            if value.Color and typeof(value.Color) == "Color3" then
                data[flag] = {
                    _type = "ColorPicker",
                    Color = _serializeColor3(value.Color),
                    Transparency = value.Transparency or 0,
                }
            elseif value.mode or value.Toggled or value.Key or value.key then
                local keyVal = value.key or value.Key
                local keyStr = keyVal and tostring(keyVal) or "NONE"
                if typeof(keyVal) == "EnumItem" then
                    keyStr = tostring(keyVal)
                end
                data[flag] = {
                    _type = "Keybind",
                    mode = value.mode or value.Mode or "Toggle",
                    key = keyStr,
                    active = value.active or value.Active or false,
                }
            elseif value.Value ~= nil then
                -- Some dropdowns store {Value = "string"}
                local v = value.Value
                if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
                    data[flag] = v
                end
            else
                local safe = true
                local isArray = true
                local count = 0
                for k, v in pairs(value) do
                    count = count + 1
                    if type(k) ~= "number" then isArray = false end
                    if type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean" then safe=false; break end
                end
                if safe and (isArray or count > 0) then data[flag] = value end
            end
        end
    end
    local success, err = pcall(function()
        if not isfolder(ConfigDir) then makefolder(ConfigDir) end
        writefile(ConfigDir .. "/" .. name .. ".cfg", game:GetService("HttpService"):JSONEncode(data))
    end)
    if success then
        Library:Notify("Config saved: " .. name, 3)
    else
        Library:Notify("Failed to save config: " .. tostring(err), 3)
    end
end)
loadConfig = LPH_NO_VIRTUALIZE(function(name)
    if not name or name == "" then return end
    local path = ConfigDir .. "/" .. name .. ".cfg"
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then Library:Notify("Config not found!", 3); return end
    local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then Library:Notify("Config corrupted!", 3); return end

    local function resolveKeybind(value)
        local keyStr = tostring(value.key or value.Key or "NONE")
        local keyEnum = keyStr
        if keyStr ~= "NONE" and keyStr:find("Enum") then
            keyEnum = Library:convert_enum(keyStr) or keyStr
        end
        if keyStr == "NONE" then keyEnum = nil end
        return {
            mode = value.mode or value.Mode or "Toggle",
            key = keyEnum,
            active = value.active or value.Active or false,
        }
    end

    for flag, value in pairs(data) do
        if CFG_SKIP[flag] then continue end
        pcall(function()
            if type(value) == "table" then
                if value._type == "ColorPicker" then
                    local color = Color3.fromRGB(value.Color.R or 0, value.Color.G or 0, value.Color.B or 0)
                    local transp = value.Transparency or 0
                    if Library.SetFlags and Library.SetFlags[flag] then
                        Library.SetFlags[flag](color, transp)
                    else
                        Flags[flag] = {Color = color, Transparency = transp}
                    end
                    return
                elseif value._type == "Keybind" or value._type == "Color3" then
                    -- handled below
                elseif value.key or value.Key then
                    if Library.SetFlags and Library.SetFlags[flag] then
                        Library.SetFlags[flag](resolveKeybind(value))
                    else
                        Flags[flag] = resolveKeybind(value)
                    end
                    return
                end
            end

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
deleteConfig = function(name)
    if not name or name == "" then return end
    pcall(function() delfile(ConfigDir .. "/" .. name .. ".cfg") end)
    Library:Notify("Config deleted: " .. name, 3)
end
_configNameFlag = ""
ConfigSection:Textbox({ Name = "Config Name", Flag = "CfgName", Default = "", Callback = function(v) _configNameFlag = v end })
_cfgDropdown = ConfigSection:Dropdown({ Name = "Configs", Flag = "CfgSelect", Items = getConfigList(), Default = nil })
ConfigSection:Button({ Name = "Save Config", Callback = function()
    local name = Flags["CfgName"] or _configNameFlag
    if name == "" then return end
    saveConfig(name)
    pcall(function() _cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:Button({ Name = "Load Config", Callback = function()
    local name = Flags["CfgSelect"]
    if name and name ~= "" then loadConfig(name) end
end })
ConfigSection:Button({ Name = "Delete Config", Callback = function()
    local name = Flags["CfgSelect"]
    if name and name ~= "" then deleteConfig(name) end
    pcall(function() _cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:Button({ Name = "Refresh List", Callback = function()
    pcall(function() _cfgDropdown:Refresh(getConfigList()) end)
end })
ConfigSection:Toggle({ Name = "Auto-Save", Flag = "AutoSaveCfg", Default = false })
ConfigSection:Toggle({ Name = "Auto-Load on Startup", Flag = "AutoLoadEnabled", Default = false })
_autoLoadDropdown = ConfigSection:Dropdown({ Name = "Auto-Load Config", Flag = "AutoLoadCfg", Items = getConfigList(), Default = nil, Callback = function(v)
    pcall(function()
        if v and v ~= "" then
            writefile("alternate.lol/autoload.cfg", v)
        else
            pcall(function() delfile("alternate.lol/autoload.cfg") end)
        end
    end)
end })
ConfigSection:Button({ Name = "Load Now", Callback = function()
    local name = Flags["AutoLoadCfg"]
    if name and name ~= "" then loadConfig(name) end
end })
task.spawn(function()
    while _scriptRunning and task.wait(60) do
        if Flags["AutoSaveCfg"] then
            local name = Flags["CfgName"] or _configNameFlag
            if name == "" then name = "autosave" end
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
    
    -- Only load if AutoLoad is actually enabled in flags
    if not Flags["AutoLoadEnabled"] then return end
    
    pcall(function()
        if _autoLoadDropdown then _autoLoadDropdown:Set(savedAutoLoad) end
    end)
    pcall(function() loadConfig(savedAutoLoad) end)
end)
_SettingsSection:Toggle({ Name = "Watermark", Flag = "ShowWM", Default = true, Callback = function(v)
    pcall(function() if Library.WatermarkObj then Library.WatermarkObj:SetVisibility(v) end end)
end })
_SettingsSection:Toggle({ Name = "Keybind List", Flag = "ShowKL", Default = true, Callback = function(v)
    pcall(function() if Library.KeyList then Library.KeyList:SetVisibility(v) end end)
end })
_SettingsSection:Label({ Name = "Menu Keybind" }):Keybind({ Flag = "MenuKeybind", Key = Enum.KeyCode.M, Mode = "Toggle", Callback = function(bool)
    Library.MenuKeybind = Flags["MenuKeybind"] and Flags["MenuKeybind"].Key
    window.toggle_menu(bool)
end })
_trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local kbData = Flags["MenuKeybind"]
    if not kbData or type(kbData) ~= "table" then return end
    local bindKey = kbData.key or kbData.Key
    if not bindKey then return end
    local pressedKey = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
    if pressedKey == bindKey then
        local mode = kbData.mode or "toggle"
        if mode == "toggle" then
            window.toggle_menu(not _menuVisible)
            _menuVisible = not _menuVisible
        elseif mode == "hold" then
            window.toggle_menu(true)
            _menuVisible = true
        end
    end
end))
_trackConn(UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local kbData = Flags["MenuKeybind"]
    if not kbData or type(kbData) ~= "table" then return end
    local bindKey = kbData.key or kbData.Key
    if not bindKey then return end
    local releasedKey = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
    if releasedKey == bindKey then
        local mode = kbData.mode or "toggle"
        if mode == "hold" then
            window.toggle_menu(false)
            _menuVisible = false
        end
    end
end))
_SettingsSection:Toggle({ Name = "Notifications", Flag = "NotificationsEnabled", Default = true, Callback = function(v)
    Library.NotificationsEnabled = v
end })
_SettingsSection:Slider({ Name = "Element Size", Flag = "ElementSize", Min = 80, Max = 200, Default = 100, Suffix = "%", Callback = function(v)
    pcall(function() Library:set_element_scale(v / 100) end)
end })
_SettingsSection:Button({ Name = "Reset Element Size", Callback = function()
    if Flags["ElementSize"] then Flags["ElementSize"] = 100 end
    if Library.SetFlags and Library.SetFlags["ElementSize"] then Library.SetFlags["ElementSize"](100) end
    pcall(function() Library:set_element_scale(1) end)
end })

_ThemeSaveDir = "alternate.lol/themes"
pcall(function() if not isfolder("alternate.lol") then makefolder("alternate.lol") end end)
pcall(function() if not isfolder(_ThemeSaveDir) then makefolder(_ThemeSaveDir) end end)

_colorToHex = function(c)
    return string.format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end
_hexToColor = function(h)
    local r, g, b = h:match("#?(%x%x)(%x%x)(%x%x)")
    if r and g and b then return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)) end
    return Color3.fromRGB(255, 255, 255)
end
_saveThemeToFile = function(name, themeData)
    pcall(function()
        if not isfolder(_ThemeSaveDir) then makefolder(_ThemeSaveDir) end
        local data = {}
        for k, v in pairs(themeData) do data[k] = _colorToHex(v) end
        writefile(_ThemeSaveDir .. "/" .. name .. ".json", game:GetService("HttpService"):JSONEncode(data))
    end)
end
_loadThemeFromFile = function(name)
    local ok, data = pcall(readfile, _ThemeSaveDir .. "/" .. name .. ".json")
    if ok and data then
        local parsed = game:GetService("HttpService"):JSONDecode(data)
        if parsed then
            local t = {}
            for k, v in pairs(parsed) do t[k] = _hexToColor(v) end
            return t
        end
    end
    return nil
end
_getThemeFileList = function()
    local list = {}
    pcall(function()
        if isfolder(_ThemeSaveDir) then
            for _, file in ipairs(listfiles(_ThemeSaveDir)) do
                local name = file:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    return list
end

_UIThemes = {}
_UIThemeOrder = {}
do
    local customThemes = _getThemeFileList()
    for _, name in ipairs(customThemes) do
        local loaded = _loadThemeFromFile(name)
        if loaded then
            _UIThemes[name] = loaded
            table.insert(_UIThemeOrder, name)
        end
    end
    table.sort(_UIThemeOrder)
end
_applyUITheme = function(name)
    local t = _UIThemes[name]
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
        if t.TextOutline then Library:ChangeTheme("TextOutline", t.TextOutline) end
        if t.Glow then Library:ChangeTheme("glow", t.Glow) end
    end)
    pcall(function()
        if Library.SetFlags then
            if Library.SetFlags["ThemeAccent"] then Library.SetFlags["ThemeAccent"](t.Accent) end
            if Library.SetFlags["ThemeBG"] then Library.SetFlags["ThemeBG"](t.BG) end
            if Library.SetFlags["ThemeText"] then Library.SetFlags["ThemeText"](t.Text) end
            if Library.SetFlags["ThemeElem"] then Library.SetFlags["ThemeElem"](t.Elem) end
            if Library.SetFlags["ThemeOutline"] then Library.SetFlags["ThemeOutline"](t.Out) end
            if Library.SetFlags["ThemeInline"] then Library.SetFlags["ThemeInline"](t.Inline) end
            if Library.SetFlags["ThemeElem2"] then Library.SetFlags["ThemeElem2"](t.Elem2) end
            if Library.SetFlags["ThemeHover"] then Library.SetFlags["ThemeHover"](t.Hover) end
            if Library.SetFlags["ThemeUnsel"] then Library.SetFlags["ThemeUnsel"](t.Unsel) end
            if Library.SetFlags["ThemeBorder"] then Library.SetFlags["ThemeBorder"](t.Border) end
            if t.TextOutline and Library.SetFlags["ThemeTextOutline"] then Library.SetFlags["ThemeTextOutline"](t.TextOutline) end
            if t.Glow and Library.SetFlags["ThemeGlow"] then Library.SetFlags["ThemeGlow"](t.Glow) end
        end
    end)
end
_themeDropdown = _ThemeSection:Dropdown({ Name = "Theme Preset", Flag = "UIThemePreset", Items = _UIThemeOrder, Default = _UIThemeOrder[1] or nil, Callback = function(v)
    _applyUITheme(v)
end })
_ThemeSection:Label({ Name = "UI Colors" })
_ThemeSection:Colorpicker({ Name = "Accent", Flag = "ThemeAccent", Default = Color3.fromRGB(255,255,255), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Accent", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Background", Flag = "ThemeBG", Default = Color3.fromRGB(0,0,0), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Background", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Text", Flag = "ThemeText", Default = Color3.fromRGB(255,255,255), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Text","Main"}, c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Element", Flag = "ThemeElem", Default = Color3.fromRGB(20,20,20), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Element", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Outline", Flag = "ThemeOutline", Default = Color3.fromRGB(30,30,30), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Borders","Outline"}, c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Inline", Flag = "ThemeInline", Default = Color3.fromRGB(10,10,10), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Inline", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Element 2", Flag = "ThemeElem2", Default = Color3.fromRGB(35,35,35), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Element 2", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Hovered Element", Flag = "ThemeHover", Default = Color3.fromRGB(45,45,45), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("Hovered Element", c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Unselected", Flag = "ThemeUnsel", Default = Color3.fromRGB(120,120,120), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Text","Unselected"}, c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Border", Flag = "ThemeBorder", Default = Color3.fromRGB(0,0,0), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme({"Borders","Inline"}, c) end) end
end })
_ThemeSection:Colorpicker({ Name = "Text Outline", Flag = "ThemeTextOutline", Default = Color3.fromRGB(0,0,0), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("TextOutline", c) end) end
end })
_ThemeSection:Label({ Name = "Glow" })
_ThemeSection:Toggle({ Name = "Enable Glow", Flag = "GlowEnabled", Default = true, Callback = function(v)
    pcall(function()
        if library and library.items then
            for _, desc in ipairs(library.items:GetDescendants()) do
                if desc:IsA("ImageLabel") and (desc.Image == "rbxassetid://18245826428" or desc.Image == "http://www.roblox.com/asset/?id=18245826428") then
                    desc.Visible = v
                end
            end
        end
    end)
end })
_ThemeSection:Colorpicker({ Name = "Glow Color", Flag = "ThemeGlow", Default = Color3.fromRGB(255,255,255), Callback = function(c)
    if typeof(c) == "Color3" then pcall(function() Library:ChangeTheme("glow", c) end) end
end })
_ThemeSection:Slider({ Name = "Glow Amount", Flag = "GlowAmount", Min = 0, Max = 100, Default = 20, Suffix = "%", Callback = function(v)
    pcall(function()
        local trans = 1 - (v / 100)
        if library and library.items then
            for _, desc in ipairs(library.items:GetDescendants()) do
                if desc:IsA("ImageLabel") and (desc.Image == "rbxassetid://18245826428" or desc.Image == "http://www.roblox.com/asset/?id=18245826428") then
                    desc.ImageTransparency = trans
                end
            end
        end
    end)
end })
_createThemeName = ""
_ThemeSection:Textbox({ Name = "Theme Name", Flag = "CreateThemeName", Default = "", Placeholder = "Enter theme name...", Callback = function(v) _createThemeName = v end })
_ThemeSection:Button({ Name = "Create Theme", Callback = function()
    local name = _createThemeName
    if not name or name == "" then Library:Notify("Enter a theme name first!", 3) return end
    pcall(function()
        local function getThemeColor(flagName, default)
            local f = Flags[flagName]
            if typeof(f) == "table" and f.Color then return f.Color end
            if typeof(f) == "Color3" then return f end
            return default
        end
        local themeData = {
            Accent = getThemeColor("ThemeAccent", Color3.fromRGB(255,255,255)),
            BG = getThemeColor("ThemeBG", Color3.fromRGB(0,0,0)),
            Text = getThemeColor("ThemeText", Color3.fromRGB(255,255,255)),
            Out = getThemeColor("ThemeOutline", Color3.fromRGB(30,30,30)),
            Inline = getThemeColor("ThemeInline", Color3.fromRGB(10,10,10)),
            Elem = getThemeColor("ThemeElem", Color3.fromRGB(20,20,20)),
            Elem2 = getThemeColor("ThemeElem2", Color3.fromRGB(35,35,35)),
            Hover = getThemeColor("ThemeHover", Color3.fromRGB(45,45,45)),
            Unsel = getThemeColor("ThemeUnsel", Color3.fromRGB(120,120,120)),
            Border = getThemeColor("ThemeBorder", Color3.fromRGB(0,0,0)),
            TextOutline = getThemeColor("ThemeTextOutline", Color3.fromRGB(0,0,0)),
            Glow = getThemeColor("ThemeGlow", Color3.fromRGB(255,255,255)),
        }
        _UIThemes[name] = themeData
        _saveThemeToFile(name, themeData)
        if not table.find(_UIThemeOrder, name) then table.insert(_UIThemeOrder, name) end
        if _themeDropdown and _themeDropdown.Refresh then _themeDropdown:Refresh(_UIThemeOrder) end
        if Library.SetFlags and Library.SetFlags["UIThemePreset"] then Library.SetFlags["UIThemePreset"](name) end
        Library:Notify("Theme '" .. name .. "' created!", 3)
    end)
end })
_ThemeSection:Button({ Name = "Set Default Theme", Callback = function()
    pcall(function()
        local current = tostring(Flags["UIThemePreset"] or "")
        if current == "" or current == "nil" then Library:Notify("No theme selected!", 3) return end
        writefile("alternate.lol/default_theme.txt", current)
        Library:Notify("Default theme set to " .. current, 3)
    end)
end })
task.spawn(function()
    task.wait(2)
    pcall(function()
        local ok, saved = pcall(readfile, "alternate.lol/default_theme.txt")
        if ok and saved and saved ~= "" then
            saved = saved:gsub("^%s+", ""):gsub("%s+$", "")
            if _UIThemes[saved] then
                _applyUITheme(saved)
                if Library.SetFlags and Library.SetFlags["UIThemePreset"] then Library.SetFlags["UIThemePreset"](saved) end
            end
        end
    end)
end)

_SettingsSection:Slider({ Name = "Notif Duration", Flag = "NotifDuration", Min = 1, Max = 15, Default = 3, Suffix = "s", Callback = function(v)
    Library.NotifSettings.Duration = v
end })
_SettingsSection:Dropdown({ Name = "Notif Type", Flag = "NotifType", Items = {"Full", "Text"}, Default = "Full", Callback = function(v)
    Library.NotifSettings.Type = v
end })
_SettingsSection:Dropdown({ Name = "Notif Animation", Flag = "NotifAnimation", Items = {"Slide", "Fade", "Pop"}, Default = "Slide", Callback = function(v)
    Library.NotifSettings.Animation = v
end })
_SettingsSection:Dropdown({ Name = "Notif Position", Flag = "NotifPosition", Items = {
    "Top Right", "Top Left", "Top Center",
    "Bottom Right", "Bottom Left", "Bottom Center"
}, Default = "Top Right", Callback = function(v)
    Library.NotifSettings.Position = v
end })
_SettingsSection:Button({ Name = "Test Notification", Callback = function()
    Library:Notify("This is a test notification!", Library.NotifSettings.Duration or 3)
end })
_SettingsSection:Toggle({ Name = "Hit Notifications Custom Text", Flag = "NotifCustomText", Default = false })
_SettingsSection:Textbox({ Name = "Hit Text Format", Flag = "NotifHitFormat", Default = "Hit: {player} - DMG: {dmg} - HP: {hp}", Placeholder = "Use {player} {dmg} {hp}" })
_SettingsSection:Toggle({ Name = "Show Damage in Notification", Flag = "NotifShowDmg", Default = true })
_SettingsSection:Toggle({ Name = "Show HP in Notification", Flag = "NotifShowHP", Default = true })
_SettingsSection:Slider({ Name = "Max Notifications", Flag = "NotifMaxShown", Min = 1, Max = 10, Default = 5, Callback = function(v)
    Library.NotifSettings.MaxShown = v
end })

_SettingsSection:Button({ Name = "Rejoin", Callback = function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end)
end })
_SettingsSection:Button({ Name = "Server Hop", Callback = function()
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
_SettingsSection:Button({ Name = "Copy Discord", Callback = function()
    if setclipboard then
        setclipboard("https://discord.gg/alternate")
        Library:Notify("Copied Discord link!", 3)
    end
end })
function restoreMaterials()
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

function restoreLighting()
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

function restoreSkybox()
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

function cleanupChams()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then removeChamsHighlight(p.Character) end
        end
        for _, bot in ipairs(getNPCs()) do
            removeChamsHighlight(bot)
        end
    end)
end

function cleanupConnections()
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

function _cleanupUI()
    pcall(function() fovCircle:Remove(); fovCircleOut:Remove(); fovCircleFill:Remove() end)
    pcall(function() silentFovCircle:Remove(); silentFovCircleOut:Remove(); silentFovCircleFill:Remove() end)
    pcall(function() targetTracer:Remove(); targetTracerOut:Remove() end)
    pcall(function() applyHeadless(false) end)
    pcall(function() applyKorblox("Right", false); applyKorblox("Left", false) end)
    pcall(function()
        if Library.WatermarkObj and Library.WatermarkObj.SetVisibility then
            Library.WatermarkObj:SetVisibility(false)
        end
    end)
    pcall(function()
        if Library.KeyList then
            Library.KeyList.Visible = false
        end
    end)
    pcall(function()
        if Library.TargetHUDObj and Library.TargetHUDObj.SetVisibility then
            Library.TargetHUDObj:SetVisibility(false)
        end
    end)
    pcall(function()
        if EspLibrary then EspLibrary:Unload() end
    end)
    pcall(function()
        if library and library.unloadMenu then library:unloadMenu() end
    end)
    pcall(function()
        getgenv().library = nil
    end)
    pcall(function()
        local guiParent = (function() if gethui then local ok, res = pcall(gethui); if ok and res then return res end end return game:GetService("CoreGui") end)()
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

_SettingsSection:Button({ Name = "Unload", Callback = function()
    pcall(restoreMaterials)
    pcall(restoreLighting)
    pcall(restoreSkybox)
    pcall(cleanupChams)
    pcall(cleanupConnections)
    pcall(_cleanupUI)
end })
end

    fogHue = 0
    fogSpinAngle = 0
    lastFogColor, lastFogStart, lastFogEnd = nil, nil, nil
    lastDensity, lastOffset, lastGlare, lastHaze = nil, nil, nil, nil
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
                    local isAimbotTarget = aimbotTarget and aimbotTarget.Parent == p.Character
                    local isLockedTarget = _lockedTarget == p
                    local shouldTrigger = isSilentTarget or isAimbotTarget or isLockedTarget or true -- trigger for all hit enemies
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
                    end
                end
                previousTargetHealth[p.Name] = currHealth
            end
        end
        
        if Flags["TriggerBotEnabled"] and _bindActive("TriggerBotBind") then
            local tbDelay = (Flags["TriggerBotDelay"] or 0) / 1000
            local reqTarget = Flags["TriggerBotRequireTarget"]
            if reqTarget == nil then reqTarget = true end
            
            local canTrigger = false
            local targetChar = nil
            
            if reqTarget then
                if currentTarget then
                    targetChar = currentTarget.Parent
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
                        if char and char:FindFirstChildOfClass("Humanoid") then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                local plr = Players:GetPlayerFromCharacter(char)
                                local isTarget = false
                                
                                if plr and plr ~= lp then
                                    local isWhitelisted = _plWhitelist and _plWhitelist[plr]
                                    isTarget = not isWhitelisted
                                else
                                    -- Check if it's an NPC
                                    local bots = getNPCs()
                                    for _, b in ipairs(bots) do
                                        if b == char then
                                            isTarget = true
                                            break
                                        end
                                    end
                                end
                                
                                if isTarget then
                                    targetChar = char
                                    canTrigger = true
                                end
                            end
                        end
                    end
                end
            else
                canTrigger = true
            end
            
            if canTrigger then
                -- Check if knife is required and equipped
                local requireKnife = Flags["TriggerBotRequireKnife"]
                if requireKnife then
                    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                    if not tool or (tool.Name ~= "Knife" and not tool.Name:match("[Kk]nife")) then
                        canTrigger = false
                    end
                end
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
            if child:IsA("Texture") and child.Name == "_CustMatTexture" then
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
                        local lowerName = p.Name:lower()
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
                            elseif a == "BaseParts" and p.ClassName == "Part" then ok = true
                            elseif a == "Wedges" and p:IsA("WedgePart") then ok = true
                            elseif a == "Cylinders" and p:IsA("Part") and p.Shape == Enum.PartType.Cylinder then ok = true end
                            if ok then
                                if not originalPartMaterials[p] then
                                    originalPartMaterials[p] = { Material = p.Material, Color = p.Color }
                                end
                                clearCustomTextures(p)
                                p.Material = matE
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

do
local PlayerSec = Window:Page({}):Section({ Name = "All Players", Side = 1 })
local PlayerInfoSec = Window:Page({}):Section({ Name = "Player Info", Side = 2 })

local _selectedPlayer = nil
local _playerButtons = {}
local _playerLabels = {}
local _infoLabels = {}
local _avatarImg = nil

local function clearPlayerInfo()
    for _, lbl in ipairs(_infoLabels) do
        if lbl and lbl.__ui then
            lbl.__ui:Destroy()
        end
    end
    _infoLabels = {}
    if _avatarImg then
        _avatarImg.Visible = false
    end
end

local function showPlayerInfo(p)
    clearPlayerInfo()
    if not p then return end

    local nameLbl = PlayerInfoSec:Label({ Name = "Name: " .. p.Name })
    table.insert(_infoLabels, nameLbl)
    local displayLbl = PlayerInfoSec:Label({ Name = "Display: " .. (p.DisplayName or p.Name) })
    table.insert(_infoLabels, displayLbl)
    local hpLbl = PlayerInfoSec:Label({ Name = "HP: ..." })
    table.insert(_infoLabels, hpLbl)
    local distLbl = PlayerInfoSec:Label({ Name = "Distance: ..." })
    table.insert(_infoLabels, distLbl)
    local statusLbl = PlayerInfoSec:Label({ Name = "Status: ..." })
    table.insert(_infoLabels, statusLbl)

    _infoLabels._player = p
    _infoLabels._hp = hpLbl
    _infoLabels._dist = distLbl
    _infoLabels._status = statusLbl
    _infoLabels._name = nameLbl
    _infoLabels._display = displayLbl

    if _avatarImg then
        _avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48"
        _avatarImg.Visible = true
    end
end

local function refreshPlayerList()
    local cont = PlayerSec.items and (PlayerSec.items["elements"] or PlayerSec.items.Container) or nil
    if not cont then return end

    for _, child in ipairs(cont:GetChildren()) do
        if child.Name:sub(1, 7) == "_PLBtn_" then
            child:Destroy()
        end
    end
    _playerButtons = {}
    _playerLabels = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local isTargeted = (_lockedTarget == p)
            local isWhitelisted = _plWhitelistLocal and _plWhitelistLocal[p]
            local prefix = isTargeted and "[TARGET] " or (isWhitelisted and "[WL] " or "")
            local btn = PlayerSec:Button({ Name = prefix .. p.Name, Callback = function()
                _selectedPlayer = p
                showPlayerInfo(p)
            end })
            if btn and btn.items and btn.items.button then
                btn.items.button.Name = "_PLBtn_" .. p.Name
                local holder = btn.items.button
                local bc = holder:FindFirstChildOfClass("Frame")
                if bc then
                    local btnFrame = bc:FindFirstChildOfClass("Frame")
                    if btnFrame then
                        local inline = btnFrame:FindFirstChildOfClass("Frame")
                        if inline then
                            local bg = inline:FindFirstChildOfClass("Frame")
                            if bg then
                                local textBtn = bg:FindFirstChildOfClass("TextButton")
                                if textBtn then
                                    local avatar = Instance.new("ImageLabel")
                                    avatar.Name = "_Avatar"
                                    avatar.Parent = bg
                                    avatar.BackgroundTransparency = 1
                                    avatar.Position = UDim2.new(0, 2, 0.5, -7)
                                    avatar.Size = UDim2.new(0, 14, 0, 14)
                                    avatar.BorderSizePixel = 0
                                    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=48&h=48"
                                    avatar.ZIndex = 3
                                    local corner = Instance.new("UICorner")
                                    corner.CornerRadius = UDim.new(0, 3)
                                    corner.Parent = avatar
                                    textBtn.Position = UDim2.new(0, 18, 0, 0)
                                    textBtn.Size = UDim2.new(1, -20, 1, 0)
                                    textBtn.TextXAlignment = Enum.TextXAlignment.Left
                                end
                            end
                        end
                    end
                end
            end
            _playerButtons[p] = btn
        end
    end
end

PlayerSec:Button({ Name = "Refresh List", Callback = refreshPlayerList })

PlayerInfoSec:Button({ Name = "Teleport", Callback = function()
    local p = _selectedPlayer
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    end
end })

PlayerInfoSec:Button({ Name = "Spectate", Callback = function()
    local p = _selectedPlayer
    if not p then return end
    if _spectatingPlayer == p then
        _spectatingPlayer = nil
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        workspace.CurrentCamera.CameraSubject = hum or lp.Character
        Library:Notify("Stopped spectating", 2)
    else
        if p.Character then
            _spectatingPlayer = p
            workspace.CurrentCamera.CameraSubject =
                p.Character:FindFirstChildOfClass("Humanoid") or p.Character.PrimaryPart
            Library:Notify("Spectating " .. p.Name, 2)
        end
    end
end })

PlayerInfoSec:Button({ Name = "Target", Callback = function()
    local p = _selectedPlayer
    if not p then return end
    if _lockedTarget == p then
        _lockedTarget = nil
        Library:Notify("Untargeted " .. p.Name, 2)
    else
        _lockedTarget = p
        Library:Notify("Targeting " .. p.Name, 2)
    end
    refreshPlayerList()
end })

PlayerInfoSec:Button({ Name = "Whitelist", Callback = function()
    local p = _selectedPlayer
    if not p then return end
    local tbl = _plWhitelistLocal or {}
    if tbl[p] then tbl[p] = nil else tbl[p] = true end
    if Library.PlayerListObj and Library.PlayerListObj.SetWhitelisted then
        Library.PlayerListObj.SetWhitelisted(p, tbl[p] ~= nil)
    end
    Library:Notify((tbl[p] and "Whitelisted " or "Unwhitelisted ") .. p.Name, 2)
    refreshPlayerList()
end })

PlayerInfoSec:Button({ Name = "Copy Name", Callback = function()
    local p = _selectedPlayer
    if p and setclipboard then
        setclipboard(p.Name)
        Library:Notify("Copied " .. p.Name, 2)
    end
end })

_spectatingPlayer = nil

local _playerInfoLastUpdate = 0
_trackConn(RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
    if _infoLabels._player and _infoLabels._hp then
        local now = tick()
        if now - _playerInfoLastUpdate < 0.2 then return end
        _playerInfoLastUpdate = now
        local p = _infoLabels._player
        if p and p.Parent and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local dist = (hrp and myHRP) and math.floor((hrp.Position - myHRP.Position).Magnitude) or 0
            local hpText = hum and string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth)) or "HP: ?"
            local distText = "Distance: " .. dist .. "m"
            local statusText = "Status: " .. (hum and (hum.Health > 0 and "Alive" or "Dead") or "Unknown")
            if _infoLabels._hp then _infoLabels._hp.set(hpText) end
            if _infoLabels._dist then _infoLabels._dist.set(distText) end
            if _infoLabels._status then _infoLabels._status.set(statusText) end
        end
    end

    if _spectatingPlayer then
        if not _spectatingPlayer.Parent or not _spectatingPlayer.Character then
            _spectatingPlayer = nil
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            workspace.CurrentCamera.CameraSubject = hum or lp.Character
        end
    end
end)))

task.spawn(function()
    task.wait(1)
    pcall(function()
        local infoCont = PlayerInfoSec.items and (PlayerInfoSec.items["elements"] or PlayerInfoSec.items.Container or PlayerInfoSec.items.background) or nil
        if infoCont then
            _avatarImg = Instance.new("ImageLabel")
            _avatarImg.Name = "_PlayerAvatar"
            _avatarImg.Parent = infoCont
            _avatarImg.BackgroundTransparency = 1
            _avatarImg.Size = UDim2.new(0, 48, 0, 48)
            _avatarImg.Position = UDim2.new(0.5, -24, 0, 4)
            _avatarImg.BorderSizePixel = 0
            _avatarImg.Image = ""
            _avatarImg.Visible = false
            _avatarImg.ZIndex = 3
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = _avatarImg
        end
    end)
    pcall(refreshPlayerList)
end)

Players.PlayerAdded:Connect(function(p)
    if p ~= lp then
        task.wait(0.5)
        pcall(refreshPlayerList)
    end
end)
Players.PlayerRemoving:Connect(function(p)
    if p ~= lp then
        if _selectedPlayer == p then
            _selectedPlayer = nil
            clearPlayerInfo()
        end
        pcall(refreshPlayerList)
    end
end)
end


Library:Notify("Loaded alternate.lol", 5)
    


Library:Notify("Loaded alternate.lol", 5)
Library:Notify("Loaded alternate.lol", 5)

do
local function getAimbotTargetLocked()
    if _lockedTarget and _lockedTarget.Character and _lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local hum = _lockedTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local hitPartName = Flags["AimHitPart"] or "Head"
            local part = _lockedTarget.Character:FindFirstChild(hitPartName) or _lockedTarget.Character:FindFirstChild("HumanoidRootPart")
            return part
        end
    end
    return nil
end

local origFindAimbotTarget = findAimbotTarget
findAimbotTarget = LPH_NO_VIRTUALIZE(function(...)
    local locked = getAimbotTargetLocked()
    if locked then return locked end
    return origFindAimbotTarget(...)
end)
end




-- Desync logic removed




-- Macro execution
_macroActive = false
do
    -- Move the camera by (dxPx, dyPx) screen pixels.
    -- Camera mode: rotate camera.CFrame directly (works even when CameraType=Scriptable).
    -- Mouse mode:  use mousemoverel so the game's own mouse-driven camera responds.
    local function moveCamera(dxPx, dyPx)
        local lockMethod = Flags["LockMethod"] or "Camera"
        if lockMethod == "Mouse" then
            if mousemoverel and (dxPx ~= 0 or dyPx ~= 0) then
                pcall(mousemoverel, dxPx, dyPx)
            end
        else
            -- Camera / Hybrid: rotate CFrame in world space
            pcall(function()
                local vp   = camera.ViewportSize
                local hFov = math.rad(camera.FieldOfView)
                local vFov = 2 * math.atan(math.tan(hFov * 0.5) * (vp.Y / vp.X))
                local yawDelta   = -(dxPx / vp.X) * hFov
                local pitchDelta = -(dyPx / vp.Y) * vFov
                local cf = camera.CFrame
                local pitch, yaw, _ = cf:ToOrientation()
                local newPitch = math.clamp(pitch + pitchDelta, -math.pi * 0.49, math.pi * 0.49)
                camera.CFrame = CFrame.new(cf.Position)
                    * CFrame.Angles(0, yaw + yawDelta, 0)
                    * CFrame.Angles(newPitch, 0, 0)
            end)
        end
    end

    -- Time-accurate smooth sweep synced to Heartbeat — no task.wait step overhead.
    local function macroEase(t)
        local style = Flags["MacroEasing"] or "Sine"
        t = math.clamp(t, 0, 1)
        if style == "Linear" then return t
        elseif style == "Sine" then return 1 - math.cos((t * math.pi) / 2)
        elseif style == "Quad" then return t * t
        elseif style == "Cubic" then return t * t * t
        elseif style == "Quart" then return t * t * t * t
        elseif style == "Exponential" then return t <= 0 and 0 or 2 ^ (10 * (t - 1))
        elseif style == "Back" then
            local s = 1.70158
            return (s + 1) * t * t * t - s * t * t
        elseif style == "Bounce" then
            local n1, d1 = 7.5625, 2.75
            if t < 1 / d1 then return n1 * t * t
            elseif t < 2 / d1 then local x = t - 1.5 / d1; return n1 * x * x + 0.75
            elseif t < 2.5 / d1 then local x = t - 2.25 / d1; return n1 * x * x + 0.9375
            else local x = t - 2.625 / d1; return n1 * x * x + 0.984375 end
        elseif style == "Elastic" then
            if t <= 0 then return 0 end
            if t >= 1 then return 1 end
            local pp = 0.3
            local s = pp / 4
            return 1.3 * 2 ^ (-10 * t) * math.sin((t - s) * (2 * math.pi) / pp) + 1
        end
        return 1 - math.cos((t * math.pi) / 2)
    end

    local function smoothMove(totalDX, totalDY, durationMs)
        local duration = durationMs / 1000
        if duration <= 0 or (totalDX == 0 and totalDY == 0) then
            moveCamera(totalDX, totalDY)
            return
        end
        local startTime = tick()
        local movedX, movedY = 0, 0
        repeat
            RunService.Heartbeat:Wait()
            local rawProgress = math.min((tick() - startTime) / duration, 1)
            local progress = macroEase(rawProgress)
            local wantX = totalDX * progress
            local wantY = totalDY * progress
            local dx = wantX - movedX
            local dy = wantY - movedY
            if math.abs(dx) >= 0.3 or math.abs(dy) >= 0.3 then
                moveCamera(dx, dy)
                movedX = wantX
                movedY = wantY
            end
        until tick() >= startTime + duration
        -- Flush any leftover sub-pixel amount
        local remX = totalDX - movedX
        local remY = totalDY - movedY
        if math.abs(remX) >= 0.3 or math.abs(remY) >= 0.3 then
            moveCamera(remX, remY)
        end
    end

    local function resumeAimbot()
        -- Reset only ease/interpolation state so aimbot eases back to target
        -- from the post-macro camera position.  Do NOT touch _aimWasEnabled or
        -- lockedAimTarget — that breaks sticky aim.
        pcall(function()
            _aimEaseProgress = 0
            _aimStartCF      = camera.CFrame  -- ease from current post-macro CF
            _mouseRemainderX = 0
            _mouseRemainderY = 0
            _aimVelPitch     = 0
            _aimVelYaw       = 0
        end)
        _macroActive = false
    end

    local function runMacro()
        if _macroActive then return end
        _macroActive = true
        local macroType = Flags["MacroType"] or "Infuse"
        local speed = Flags["MacroSpeed"] or 100

        if macroType == "Infuse" then
            -- Far up, back down, right then back, left then back
            smoothMove(0, -600, speed)          -- far up
            smoothMove(0, 600, speed)           -- back down
            smoothMove(400, 0, speed * 0.8)     -- right
            smoothMove(-400, 0, speed * 0.8)    -- back center
            smoothMove(-400, 0, speed * 0.8)    -- left
            smoothMove(400, 0, speed * 0.8)     -- back center

        elseif macroType == "360" then
            local dir = Flags["Macro360Dir"] or "Right"
            local totalX = 3600 * ((dir == "Right") and 1 or -1)
            smoothMove(totalX, 0, speed * 2)

        elseif macroType == "Ziggy" then
            -- Far up and right zigzag
            smoothMove(300, -400, speed * 0.7)   -- up-right
            smoothMove(-200, -200, speed * 0.5)  -- up-left
            smoothMove(250, -150, speed * 0.5)   -- up-right again
        end

        resumeAimbot()
    end

    _trackConn(UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(input, gameProcessed)
        if gameProcessed then return end
        if not Flags["MacroEnabled"] then return end
        local kbData = Flags["MacroBind"]
        if not kbData or type(kbData) ~= "table" then return end
        local bindKey = kbData.key or kbData.Key
        if not bindKey then return end
        local pressedKey = input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode or input.UserInputType
        if pressedKey == bindKey then
            task.spawn(runMacro)
        end
    end)))
end

pcall(function() library:configListUpdate() end)
notifications:create_notification({name = "Loaded alternate.lol -> obelus ui"})


