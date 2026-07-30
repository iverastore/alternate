-- Variables 
    local uis = game:GetService("UserInputService") 
    local players = game:GetService("Players") 
    local ws = game:GetService("Workspace")
    local rs = game:GetService("ReplicatedStorage")
    local http_service = game:GetService("HttpService")
    local gui_service = game:GetService("GuiService")
    local lighting = game:GetService("Lighting")
    local run = game:GetService("RunService")
    local stats = game:GetService("Stats")
    local coregui = (function()
        if gethui then
            local ok, res = pcall(gethui)
            if ok and res and not res:IsA("ScreenGui") then
                return res
            end
        end
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok and cg then
            return cg
        end
        return game.Players.LocalPlayer.PlayerGui
    end)()
    local debris = game:GetService("Debris")
    local tween_service = game:GetService("TweenService")
    local sound_service = game:GetService("SoundService")

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new 
    local rect = Rect.new
    local cfr = CFrame.new
    local empty_cfr = cfr()
    local point_object_space = empty_cfr.PointToObjectSpace
    local angle = CFrame.Angles
    local dim_offset = UDim2.fromOffset

    local color = Color3.new
    local rgb = Color3.fromRGB
    local hex = Color3.fromHex
    local hsv = Color3.fromHSV
    local rgbseq = ColorSequence.new
    local rgbkey = ColorSequenceKeypoint.new
    local numseq = NumberSequence.new
    local numkey = NumberSequenceKeypoint.new

    local camera = ws.CurrentCamera
    local lp = players.LocalPlayer 
    local mouse = lp:GetMouse() 
    local gui_offset = gui_service:GetGuiInset().Y

    local max = math.max 
    local floor = math.floor 
    local min = math.min 
    local abs = math.abs 
    local noise = math.noise
    local rad = math.rad 
    local random = math.random 
    local pow = math.pow 
    local sin = math.sin 
    local pi = math.pi 
    local tan = math.tan 
    local atan2 = math.atan2 
    local clamp = math.clamp 

    local insert = table.insert 
    local find = table.find 
    local remove = table.remove
    local concat = table.concat
-- 

-- Library init
    if getgenv().library then 
        pcall(function() getgenv().library:unloadMenu() end)
    end 

    getgenv().library = {
        directory = "alternate.lol",
        folders = {
            "/fonts",
            "/configs",
        },
        flags = {},
        config_flags = {},

        connections = {},   
        notifications = {notifs = {}, offset = 0},
        playerlist_data = {
            players = {},
            player = {}, 
        },
        colorpicker_open = false; 
        gui; 
    }

    local themes = {
        preset = {
            ["accent"] = hex("#FFFFFF"),
            ["text_outline"] = rgb(0, 0, 0),
            ["background"] = rgb(0, 0, 0),
            ["text"] = rgb(255, 255, 255),
            ["element"] = rgb(20, 20, 20),
            ["element2"] = rgb(35, 35, 35),
            ["outline"] = rgb(30, 30, 30),
            ["inline"] = rgb(10, 10, 10),
            ["hover"] = rgb(45, 45, 45),
            ["unselected"] = rgb(120, 120, 120),
            ["border"] = rgb(0, 0, 0),
            ["glow"] = rgb(255, 255, 255),
        }, 	

        utility = {
            ["accent"] = {
                ["BackgroundColor3"] = {}, 	
                ["TextColor3"] = {}, 
                ["ImageColor3"] = {}, 
                ["ScrollBarImageColor3"] = {},
                ["Color"] = {}
            },
            ["text_outline"] = {
                ["Color"] = {},
                ["BackgroundColor3"] = {},
                ["BorderColor3"] = {},
            },
            ["background"] = {
                ["BackgroundColor3"] = {},
            },
            ["text"] = {
                ["TextColor3"] = {},
            },
            ["element"] = {
                ["BackgroundColor3"] = {},
            },
            ["element2"] = {
                ["BackgroundColor3"] = {},
            },
            ["outline"] = {
                ["BackgroundColor3"] = {},
            },
            ["inline"] = {
                ["BackgroundColor3"] = {},
            },
            ["hover"] = {
                ["BackgroundColor3"] = {},
            },
            ["unselected"] = {
                ["TextColor3"] = {},
                ["BackgroundColor3"] = {},
            },
            ["border"] = {
                ["BackgroundColor3"] = {},
                ["BorderColor3"] = {},
            },
            ["glow"] = {
                ["ImageColor3"] = {},
            },
        }, 
    }

    local keys = {
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.RightParenthesis] = ")",
        [Enum.KeyCode.LeftParenthesis] = "(",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }
    
    library.__index = library

    function library:visible(bool)
        if self.__ui then
            self.__ui.Visible = bool
        end
    end

    pcall(function() if not isfolder(library.directory) then makefolder(library.directory) end end)
    for _, path in next, library.folders do 
        pcall(function() if not isfolder(library.directory .. path) then makefolder(library.directory .. path) end end)
    end

    local flags = library.flags 
    local config_flags = library.config_flags

    if not LPH_NO_VIRTUALIZE then
        getfenv().LPH_NO_VIRTUALIZE = function(...) return (...) end
    end

    -- -- Font importing system 
        -- Hello skids, i dont know why you are overwriting a table and using setreadonly this is so unneccessary and removes solara support.. ;(

        local _fontOk = pcall(function()
            if not isfile(library.directory .. "/fonts/main.ttf") then 
                writefile(library.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf"))
            end
            
            local tahoma = {
                name = "SmallestPixel7",
                faces = {
                    {
                        name = "Regular",
                        weight = 400,
                        style = "normal",
                        assetId = getcustomasset(library.directory .. "/fonts/main.ttf")
                    }
                }
            }
            
            if not isfile(library.directory .. "/fonts/main_encoded.ttf") then 
                writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(tahoma))
            end 
            
            library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)
        end)
        if not _fontOk then
            library.font = Font.fromEnum(Enum.Font.Code)
        end
    -- -- 

    --library.font = Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
-- 

-- Library functions 
    -- Misc functions
        function library:tween(obj, properties) 
            local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
                
            return tween
        end 

        function library:closeCurrentElement(cfg) 
            local path = library.current_element_open 

            if path and path ~= cfg then 
                path.setVisible(false)
                path.open = false 
            end
        end 

        function library:makeResizable(frame) 
            local Frame = Instance.new("TextButton")
            Frame.Position = dim2(1, -10, 1, -10)
            Frame.BorderColor3 = rgb(0, 0, 0)
            Frame.Size = dim2(0, 10, 0, 10)
            Frame.BorderSizePixel = 0
            Frame.BackgroundColor3 = rgb(255, 255, 255)
            Frame.Parent = frame
            Frame.BackgroundTransparency = 1 
            Frame.Text = ""

            local resizing = false 
            local start_size 
            local start 
            local og_size = frame.Size  

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = true
                    start = input.Position
                    start_size = frame.Size
                end
            end)

            Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                end
            end)

            library:connection(uis.InputChanged, LPH_NO_VIRTUALIZE(function(input, game_event) 
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_size = dim2(
                        start_size.X.Scale,
                        math.clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            og_size.X.Offset,
                            viewport_x
                        ),
                        start_size.Y.Scale,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            og_size.Y.Offset,
                            viewport_y
                        )
                    )
                    frame.Size = current_size
                end
            end))
        end

        function library:mouseInFrame(uiobject)
            local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
            local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

            return (y_cond and x_cond)
        end

        library.lerp = LPH_NO_VIRTUALIZE(function(start, finish, t)
            t = t or 1 / 8

            return start * (1 - t) + finish * t
        end)

        function library:draggify(frame, delay)
            delay = delay or 0.15
            local dragging = false 
            local drag_ready = false
            local start_size = frame.Position
            local start 
            local press_time = 0

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    start = input.Position
                    start_size = frame.Position
                    drag_ready = false
                    pressing = true
                    press_time = tick()
                    task.delay(delay, function()
                        if pressing then
                            drag_ready = true
                            dragging = true
                        end
                    end)
                end
            end)

            frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    drag_ready = false
                    pressing = false
                end
            end)

            library:connection(uis.InputChanged, LPH_NO_VIRTUALIZE(function(input, game_event) 
                if dragging and drag_ready and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera.ViewportSize.X
                    local viewport_y = camera.ViewportSize.Y

                    local current_position = dim2(
                        0,
                        clamp(
                            start_size.X.Offset + (input.Position.X - start.X),
                            0,
                            viewport_x - frame.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            start_size.Y.Offset + (input.Position.Y - start.Y),
                            0,
                            viewport_y - frame.Size.Y.Offset
                        )
                    )

                    frame.Position = current_position
                end
            end))
        end 

        function library:convertEnum(enum)
            local enum_parts = {}
        
            for part in string.gmatch(enum, "[%w_]+") do
                insert(enum_parts, part)
            end
        
            local enum_table = Enum
            for i = 2, #enum_parts do
                local enum_item = enum_table[enum_parts[i]]
        
                enum_table = enum_item
            end
        
            return enum_table
        end

        local config_holder;
        function library:configListUpdate() 
            if not config_holder then return end 
        
            local list = {}
        
            pcall(function()
                for idx, file in next, listfiles(library.directory .. "/configs") do
                    local name = file:gsub(library.directory .. "\\configs\\", ""):gsub(".cfg", "")
                    list[#list + 1] = name
                end
            end)
            
            config_holder.refresh_options(list)
        end 

        function library:getConfig()
            local Config = {}
        
            for _, v in flags do
                if type(v) == "table" and v.key then
                    Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
                elseif type(v) == "table" and v["Transparency"] and v["Color"] then
                    Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
                else
                    Config[_] = v
                end
            end 
            
            return http_service:JSONEncode(Config)
        end

        function library:loadConfig(config_json) 
            local config = http_service:JSONDecode(config_json)
        
            for _, v in next, config do 
                local function_set = library.config_flags[_]
                
                if function_set then 
                    if type(v) == "table" and v["key"] and v["mode"] then
                        function_set(v)
                    elseif type(v) == "table" and v["Transparency"] and v["Color"] then
                        function_set(hex(v["Color"]), v["Transparency"])
                    elseif type(v) == "table" and v["active"] then 
                        function_set(v)
                    else 
                        function_set(v)
                    end
                end 
            end 
        end 
        
        function library:round(number, float) 
            local multiplier = 1 / (float or 1)

            return floor(number * multiplier + 0.5) / multiplier
        end 

        function library:applyTheme(instance, theme, property) 
            if not themes.utility[theme] then
                themes.utility[theme] = {}
            end
            if not themes.utility[theme][property] then
                themes.utility[theme][property] = {}
            end
            insert(themes.utility[theme][property], instance)
        end

        function library:updateTheme(theme, color)
            for property_name, property in next, themes.utility[theme] do 

                for m, object in next, property do 
                    if object.ClassName == "UIGradient" and (property_name == "Color" or property_name == "ImageColor3") then
                        local grad = object
                        local keypoints = {}
                        for _, kp in ipairs(grad.Color.Keypoints) do
                            table.insert(keypoints, ColorSequenceKeypoint.new(kp.Time, color))
                        end
                        grad.Color = ColorSequence.new(keypoints)
                    else
                        object[property_name] = color 
                    end
                end 
            end 

            themes.preset[theme] = color 
        end 

        function library:connection(signal, callback)
            local connection = signal:Connect(callback)
            
            insert(library.connections, connection)

            return connection 
        end

        function library:applyStroke(parent) 
            local STROKE = library:create("UIStroke", {
                Parent = parent,
                Color = themes.preset.text_outline, 
                LineJoinMode = Enum.LineJoinMode.Miter
            }) 

            library:applyTheme(STROKE, "text_outline", "Color")
        end

        function library:create(instance, options)
            local ins = Instance.new(instance) 
            
            for prop, value in next, options do 
                ins[prop] = value
            end
            
            -- if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
            --     library:apply_theme(ins, "text", "TextColor3")
            --     library:applyStroke(ins)
            -- end 
            
            return ins 
        end

        function library:unloadMenu() 
            library.unloaded = true
            pcall(function()
                if library.gui then 
                    library.gui:Destroy()
                end
            end)
            
            for index, connection in next, library.connections do 
                pcall(function() connection:Disconnect() end)
                connection = nil 
            end     
            
            getgenv().library = nil 
        end 

        function library:initializeColorPicker(options) 
            local cfg = {
                name = options.name or "Color", 
                flag = options.flag or tostring(2^789),

                color = options.color or color(1, 1, 1), -- Default to white color if not provided
                alpha = options.alpha or 1,

                callback = options.callback or function() end,
                open = false 
            }

            flags[cfg.flag] = {
                ["animation"] = "None",
                ["animationSpeed"] = 0.2,
                ["color1"] = {
                    Color3.fromRGB(255, 255, 255), 
                    0  
                },
                ["color2"] = {
                    Color3.fromRGB(255, 0, 255), 
                    0
                }
            } 

            local flagDirectory = flags[cfg.flag]

            local draggingSaturation = false
            local draggingHue = false
            local draggingAlpha = false

            local OUTLINE = library:create("Frame", {
                Parent = library.gui,
                Name = "",
                Visible = false, 
                Position = dim2(0, 120, 0, 228),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 150, 0, 150),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(1, 1, 1),
                ZIndex = 999, 
            })

            library:draggify(OUTLINE)
            library:makeResizable(OUTLINE)

            cfg.outline = OUTLINE
            
            local inline = library:create("Frame", {
                Parent = OUTLINE,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(25, 25, 25)
            })  
            
            local INSTANCE_HOLDERS = library:create("Frame", {
                Parent = inline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(0, 0, 0)
            })

            local h, s, v = color(1, 1, 1):ToHSV() 
            local a = 0

            -- Color Selections
                local colorpicker_picker = library:create("Frame", {
                    Parent = INSTANCE_HOLDERS,
                    Name = "",
                    Visible = true,
                    BorderColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = dim2(0, 0, 0, 20),
                    Size = dim2(1, 0, 1, -26),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local outline = library:create("Frame", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Position = dim2(0, 6, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -62, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local inline = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local background = library:create("Frame", {
                    Parent = inline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })

                local dragging_sat_val = library:create("Frame", {
                    Parent = background,
                    Name = "",
                    Size = dim2(0, 2, 0, 2),
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255),
                    ZIndex = 3, 
                })
                
                library:create("UIStroke", {
                    Parent = dragging_sat_val,
                    Name = "",
                    LineJoinMode = Enum.LineJoinMode.Miter
                })                
                
                local sat = library:create("TextButton", {
                    Parent = background,
                    Name = "",
                    Size = dim2(1, 0, 1, 0),
                    Text = "", 
                    AutoButtonColor = false, 
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = sat,
                    Name = "",
                    Rotation = 270,
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)},
                    Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                })
                
                local val = library:create("TextButton", {
                    Parent = background,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    Rotation = 180,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = val,
                    Name = "",
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                })
                
                local hue = library:create("TextButton", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    AnchorPoint = vec2(1, 0),
                    Position = dim2(1, -32, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 16, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local outline = library:create("Frame", {
                    Parent = hue,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local Frame = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = Frame,
                    Name = "",
                    Rotation = 270,
                    Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
                })
                
                local hue_picker = library:create("Frame", {
                    Parent = Frame,
                    Name = "",
                    BorderMode = Enum.BorderMode.Inset,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 0, 4),
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local alpha = library:create("TextButton", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    AnchorPoint = vec2(1, 0),
                    Position = dim2(1, -8, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 16, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local outline = library:create("Frame", {
                    Parent = alpha,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local alpha_drag = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local alpha_picker = library:create("Frame", {
                    Parent = alpha_drag,
                    Name = "",
                    BorderMode = Enum.BorderMode.Inset,
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    Size = dim2(1, 0, 0, 4),
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local alphaind = library:create("ImageLabel", {
                    Parent = alpha_drag,
                    Name = "",
                    ScaleType = Enum.ScaleType.Tile,
                    BorderColor3 = rgb(0, 0, 0),
                    Image = "rbxassetid://18274452449",
                    BackgroundTransparency = 1,
                    Size = dim2(1, 0, 1, 0),
                    TileSize = dim2(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = alphaind,
                    Name = "",
                    Rotation = 90,
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                })
            -- 

            -- Animations Tab 
                cfg["animations"] = library:create("Frame", {
                    Parent = INSTANCE_HOLDERS,
                    Name = "",
                    Visible = false, 
                    BackgroundTransparency = 1,
                    Position = dim2(0, 0, 0, 20),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 1, -32),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                cfg["colorpickerElements"] = library:create("Frame", {
                    Parent = cfg["animations"],
                    Name = "",
                    Position = dim2(0, 8, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -16, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                library:create("UIListLayout", {
                    Parent = cfg["colorpickerElements"],
                    Name = "",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = dim(0, 3)
                })

                local elements = setmetatable(cfg, library)

                local dropdown = elements:addDropdown({
                    name = "animation", 
                    items = {"None", "Fade", "Rainbow"},
                    ignore = true,
                    multi = false, 
                    callback = function(option)
                        flagDirectory["animation"] = option

                        if color2 then 
                            color1.setVisible(false)
                            color2.setVisible(false)
                        end 
                    end 
                })

                local color1 = dropdown:addColorPicker({
                    color = rgb(255, 255, 255), 
                    alpha = 1, 
                    animation = "single",
                    ignore = true, 
                    callback = function(color, alpha)
                        flagDirectory["color1"] = {color, alpha}
                    end
                }) 

                local color2 = dropdown:addColorPicker({
                    color = rgb(255, 255, 255), 
                    alpha = 1, 
                    animation = "single",
                    ignore = true, 
                    callback = function(color, alpha)
                        flagDirectory["color2"] = {color, alpha}
                    end
                })  

                elements:addSlider({
                    name = "animation speed",
                    min = 0, 
                    max = 100, 
                    default = 0.2, 
                    interval = 0.01, 
                    suffix = "%", 
                    callback = function(int)
                        flagDirectory["animationSpeed"] = int
                    end
                })
            -- 
            
            -- Tab Button Holders
                local text_holder = library:create("Frame", {
                    Parent = INSTANCE_HOLDERS,
                    Name = "",
                    BackgroundTransparency = 1,
                    --AnchorPoint = vec2(0, 1),
                    Position = dim2(0, 0, 0, 5),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local UIListLayout = library:create("UIListLayout", {
                    Parent = text_holder,
                    Name = "",
                    Padding = dim(0, 10),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local colorpicker_tab = library:create("TextButton", {
                    Parent = text_holder,
                    Name = "",
                    FontFace = library.font,
                    TextColor3 = themes.preset.accent,
                    BorderColor3 = rgb(0, 0, 0),
                    Text = "color",
                    AnchorPoint = vec2(1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 12,
                    BackgroundColor3 = rgb(255, 255, 255)
                })library:applyTheme(colorpicker_tab, "accent", "TextColor3")
                
                cfg["animations_tab"] = library:create("TextButton", {
                    Parent = text_holder,
                    Name = "",
                    FontFace = library.font,
                    TextColor3 = themes.preset.unselected,
                    BorderColor3 = themes.preset.border,
                    Text = "animations",
                    AnchorPoint = vec2(1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 12,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local UIPadding = library:create("UIPadding", {
                    Parent = text_holder,
                    Name = "",
                    PaddingLeft = dim(0, 10)
                })
            -- 

            -- Functions 
                function cfg.updateColor() 
                    local mouse = uis:GetMouseLocation() 
                    
                    if draggingSaturation then	
                        s = clamp((vec2(mouse.X, mouse.Y - gui_offset) - val.AbsolutePosition).X / val.AbsoluteSize.X, 0, 1)
                        v = 1 - clamp((vec2(mouse.X, mouse.Y - gui_offset) - sat.AbsolutePosition).Y / sat.AbsoluteSize.Y, 0, 1)
                    elseif draggingHue then 
                        h = clamp(1 - (vec2(mouse.X, mouse.Y - gui_offset) - hue.AbsolutePosition).Y / hue.AbsoluteSize.Y, 0, 1)
                    elseif draggingAlpha then 
                        a = clamp((vec2(mouse.X, mouse.Y - gui_offset) - alpha.AbsolutePosition).Y / alpha.AbsoluteSize.Y, 0, 1)
                    end

                    cfg.set(nil, nil)
                end  

                function cfg.setVisible(bool)
                    cfg.outline.Visible = bool

                    if bool then 
                        library:closeCurrentElement(cfg)
                        library.current_element_open = cfg 
                    end
                end 

                function cfg.set(color, alpha)                    
                    if color then 
                        h, s, v = color:ToHSV()
                    end 
                    
                    if alpha then 
                        a = alpha
                    end 
                    
                    local Color = hsv(h, s, v)
                    
                    -- Editing the window colorpicker
                        -- Hue
                        local value = 1 - h
                        local offset = (value < 1) and 0 or -4
                        hue_picker.Position = dim2(0, 0, value, offset)

                        -- Alpha
                        local offset = (a < 1) and 0 or -4
                        alpha_picker.Position = dim2(0, 0, a, offset)
                        alpha_drag.BackgroundColor3 = hsv(h, s, v)

                        -- Sat / Val
                        local s_offset = (s < 1) and 0 or -3
                        local v_offset = (1 - v < 1) and 0 or -3
                        dragging_sat_val.Position = dim2(s, s_offset, 1 - v, v_offset)

                        val.BackgroundColor3 = hsv(h, 1, 1)
                        sat.BackgroundColor3 = hsv(h, 1, 1)
                    -- 

                    -- For the origin colorpicker
                        options.alphaPath.ImageTransparency = a 
                        options.colorPath.BackgroundColor3 = Color
                    -- 

                    if cfg.callback then 
                        cfg.callback(Color, a)
                    end 

                    flags[cfg.flag] = {
                        Color = Color, 
                        Transparency = a,
                    }
                    flags[cfg.flag .. "_color"] = Color
                end 

                cfg.set(cfg.color, cfg.alpha)
            -- 

            -- Connections
                colorpicker_tab.MouseButton1Click:Connect(function()
                    cfg["animations"].Visible = false 
                    colorpicker_picker.Visible = true 

                    colorpicker_tab.TextColor3 = themes.preset.accent
                    cfg["animations_tab"].TextColor3 = themes.preset.unselected
                end)

                cfg["animations_tab"].MouseButton1Click:Connect(function()
                    cfg["animations"].Visible = true 
                    colorpicker_picker.Visible = false 

                    colorpicker_tab.TextColor3 = themes.preset.unselected
                    cfg["animations_tab"].TextColor3 = themes.preset.accent
                end)

                -- Colorpicker Init 
                    alpha.MouseButton1Down:Connect(function()
                        draggingAlpha = true 
                    end)    
        
                    hue.MouseButton1Down:Connect(function()
                        draggingHue = true 
                    end)
        
                    sat.MouseButton1Down:Connect(function()
                        draggingSaturation = true  
                    end)
        
                    uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSaturation = false
                            draggingHue = false
                            draggingAlpha = false 
                        end
                    end)
                    
                    uis.InputChanged:Connect(LPH_NO_VIRTUALIZE(function(input)
                        if (draggingSaturation or draggingHue or draggingAlpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                            cfg.updateColor() 
                        end
                    end))	
                -- 

                task.spawn(LPH_NO_VIRTUALIZE(function()
                    while not library.unloaded do 
                        local anim = flagDirectory["animation"] 

                        if anim ~= "None" then 
                            local color; 
                            local alpha; 
                            local sin = abs(sin(tick() * flagDirectory["animationSpeed"]))

                            color = anim == "Rainbow" and hsv(sin, 1, 1) or flagDirectory["color2"][1]:Lerp(flagDirectory["color1"][1], sin)
                            alpha = anim == "Rainbow" and a or library.lerp(flagDirectory["color2"][2], flagDirectory["color1"][2], sin) 

                            cfg.set(color, alpha)
                        end 

                        task.wait() 
                    end 
                end))
            -- 
                
            return setmetatable(cfg, library)
        end 

        function library:keyPicker(options) 
            local cfg = {
                name = options.name or "Color", 
                flag = options.flag or tostring(2^789),

                color = options.color or color(1, 1, 1), -- Default to white color if not provided
                alpha = options.alpha or 1,

                ignore = options.ignore or false, 

                callback = options.callback or function() end,
                open = false 
            }

            local draggingSaturation = false
            local draggingHue = false
            local draggingAlpha = false

            local OUTLINE = library:create("Frame", {
                Parent = library.gui,
                Name = "",
                Visible = false, 
                Position = dim2(0, 120, 0, 228),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 261, 0, 236),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(1, 1, 1),
                ZIndex = 999, 
            })

            library:draggify(OUTLINE)
            library:makeResizable(OUTLINE)

            cfg.outline = OUTLINE
            
            local inline = library:create("Frame", {
                Parent = OUTLINE,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(25, 25, 25)
            })  
            
            local INSTANCE_HOLDERS = library:create("Frame", {
                Parent = inline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(0, 0, 0)
            })

            local h, s, v = color(1, 1, 1):ToHSV() 
            local a = 0

            -- Color Selections
                local colorpicker_picker = library:create("Frame", {
                    Parent = INSTANCE_HOLDERS,
                    Name = "",
                    Visible = true,
                    BorderColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = dim2(0, 0, 0, 20),
                    Size = dim2(1, 0, 1, -26),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local outline = library:create("Frame", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Position = dim2(0, 6, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -62, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local inline = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local background = library:create("Frame", {
                    Parent = inline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })

                local dragging_sat_val = library:create("Frame", {
                    Parent = background,
                    Name = "",
                    Size = dim2(0, 2, 0, 2),
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255),
                    ZIndex = 3, 
                })
                
                library:create("UIStroke", {
                    Parent = dragging_sat_val,
                    Name = "",
                    LineJoinMode = Enum.LineJoinMode.Miter
                })                
                
                local sat = library:create("TextButton", {
                    Parent = background,
                    Name = "",
                    Size = dim2(1, 0, 1, 0),
                    Text = "", 
                    AutoButtonColor = false, 
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = sat,
                    Name = "",
                    Rotation = 270,
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)},
                    Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                })
                
                local val = library:create("TextButton", {
                    Parent = background,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    Rotation = 180,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = val,
                    Name = "",
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                })
                
                local hue = library:create("TextButton", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    AnchorPoint = vec2(1, 0),
                    Position = dim2(1, -32, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 16, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local outline = library:create("Frame", {
                    Parent = hue,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local Frame = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = Frame,
                    Name = "",
                    Rotation = 270,
                    Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
                })
                
                local hue_picker = library:create("Frame", {
                    Parent = Frame,
                    Name = "",
                    BorderMode = Enum.BorderMode.Inset,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 0, 4),
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local alpha = library:create("TextButton", {
                    Parent = colorpicker_picker,
                    Name = "",
                    Text = "", 
                    AutoButtonColor = false, 
                    AnchorPoint = vec2(1, 0),
                    Position = dim2(1, -8, 0, 6),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 16, 1, -5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(1, 1, 1)
                })
                
                local outline = library:create("Frame", {
                    Parent = alpha,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(25, 25, 25)
                })
                
                local alpha_drag = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local alpha_picker = library:create("Frame", {
                    Parent = alpha_drag,
                    Name = "",
                    BorderMode = Enum.BorderMode.Inset,
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 2,
                    Size = dim2(1, 0, 0, 4),
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local alphaind = library:create("ImageLabel", {
                    Parent = alpha_drag,
                    Name = "",
                    ScaleType = Enum.ScaleType.Tile,
                    BorderColor3 = rgb(0, 0, 0),
                    Image = "rbxassetid://18274452449",
                    BackgroundTransparency = 1,
                    Size = dim2(1, 0, 1, 0),
                    TileSize = dim2(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 183, 0)
                })
                
                local UIGradient = library:create("UIGradient", {
                    Parent = alphaind,
                    Name = "",
                    Rotation = 90,
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                })
            -- 
            
            -- Tab Button Holders
                local text_holder = library:create("Frame", {
                    Parent = INSTANCE_HOLDERS,
                    Name = "",
                    BackgroundTransparency = 1,
                    --AnchorPoint = vec2(0, 1),
                    Position = dim2(0, 0, 0, 5),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, 0, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local UIListLayout = library:create("UIListLayout", {
                    Parent = text_holder,
                    Name = "",
                    Padding = dim(0, 10),
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local colorpicker_tab = library:create("TextButton", {
                    Parent = text_holder,
                    Name = "",
                    FontFace = library.font,
                    TextColor3 = themes.preset.accent,
                    BorderColor3 = rgb(0, 0, 0),
                    Text = "color",
                    AnchorPoint = vec2(1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextSize = 12,
                    BackgroundColor3 = rgb(255, 255, 255)
                })library:applyTheme(colorpicker_tab, "accent", "TextColor3")
                
                local UIPadding = library:create("UIPadding", {
                    Parent = text_holder,
                    Name = "",
                    PaddingLeft = dim(0, 10)
                })
            -- 

            -- Functions 
                function cfg.updateColor() 
                    local mouse = uis:GetMouseLocation() 
                    
                    if draggingSaturation then	
                        s = clamp((vec2(mouse.X, mouse.Y - gui_offset) - val.AbsolutePosition).X / val.AbsoluteSize.X, 0, 1)
                        v = 1 - clamp((vec2(mouse.X, mouse.Y - gui_offset) - sat.AbsolutePosition).Y / sat.AbsoluteSize.Y, 0, 1)
                    elseif draggingHue then 
                        h = clamp(1 - (vec2(mouse.X, mouse.Y - gui_offset) - hue.AbsolutePosition).Y / hue.AbsoluteSize.Y, 0, 1)
                    elseif draggingAlpha then 
                        a = clamp((vec2(mouse.X, mouse.Y - gui_offset) - alpha.AbsolutePosition).Y / alpha.AbsoluteSize.Y, 0, 1)
                    end

                    cfg.set(nil, nil)
                end  

                function cfg.setVisible(bool)
                    cfg.outline.Visible = bool

                    if bool then 
                        library:closeCurrentElement(cfg)
                        library.current_element_open = cfg 
                    end
                end 

                function cfg.set(color, alpha) 
                    if color then 
                        h, s, v = color:ToHSV()
                    end 
                
                    if alpha then 
                        a = alpha
                    end 
                    
                    local Color = hsv(h, s, v)
                    
                    -- Editing the window colorpicker
                        -- Hue
                        local value = 1 - h
                        local offset = (value < 1) and 0 or -4
                        hue_picker.Position = dim2(0, 0, value, offset)

                        -- Alpha
                        local offset = (a < 1) and 0 or -4
                        alpha_picker.Position = dim2(0, 0, a, offset)
                        alpha_drag.BackgroundColor3 = hsv(h, s, v)

                        -- Sat / Val
                        local s_offset = (s < 1) and 0 or -3
                        local v_offset = (1 - v < 1) and 0 or -3
                        dragging_sat_val.Position = dim2(s, s_offset, 1 - v, v_offset)

                        val.BackgroundColor3 = hsv(h, 1, 1)
                        sat.BackgroundColor3 = hsv(h, 1, 1)
                    -- 

                    -- For the origin colorpicker
                        options.alphaPath.ImageTransparency = a 
                        options.colorPath.BackgroundColor3 = Color
                    -- 

                    if cfg.callback then 
                        cfg.callback(Color, a)
                    end 
                    flags[cfg.flag] = {
                        Color = Color;
                        Transparency = a 
                    }
                    flags[cfg.flag .. "_color"] = Color
                end 
                
                cfg.set(cfg.color, cfg.alpha)
                
                library.config_flags[cfg.flag] = cfg.set
            -- 

            -- Connections
                -- Colorpicker Init 
                    alpha.MouseButton1Down:Connect(function()
                        draggingAlpha = true 
                    end)    
        
                    hue.MouseButton1Down:Connect(function()
                        draggingHue = true 
                    end)
        
                    sat.MouseButton1Down:Connect(function()
                        draggingSaturation = true  
                    end)
        
                    uis.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            draggingSaturation = false
                            draggingHue = false
                            draggingAlpha = false 
                        end
                    end)
                    
                    uis.InputChanged:Connect(LPH_NO_VIRTUALIZE(function(input)
                        if (draggingSaturation or draggingHue or draggingAlpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
                            cfg.updateColor() 
                        end
                    end))	
                -- 
            -- 

            return setmetatable(cfg, library)
        end 
    --
        
    -- Library element functions
        function library:window(properties)
            local cfg = {
                name = properties.name or properties.Name or os.date('<font color="rgb(170,85,235)">obelus</font> | %b %d %Y | %H:%M'),
                size = properties.size or properties.Size or dim2(0, 516, 0, 563),
                logo = properties.logo or properties.Logo or "rbxassetid://132488048637620",
                selected_tab,
                is_closing_menu = false,
            }

            library.gui = library:create("ScreenGui", {
                Parent = coregui,
                Name = "",
                Enabled = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                IgnoreGuiInset = true,
                DisplayOrder = 999,
            })

            local outline = library:create("Frame", {
                Parent = library.gui,
                Name = "",
                Position = dim2(0.5, 0 - (cfg.size.X.Offset / 2), 0.5, 0 - (cfg.size.Y.Offset / 2)),
                BorderColor3 = rgb(0, 0, 0),
                Size = cfg.size,
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.outline
            }); outline.Position = dim_offset(outline.AbsolutePosition.X, outline.AbsolutePosition.Y)
            library:applyTheme(outline, "outline", "BackgroundColor3")

            local glow = library:create("ImageLabel", {
                Parent = outline,
                Name = "",
                ImageColor3 = themes.preset.glow or themes.preset.accent,
                ScaleType = Enum.ScaleType.Slice,
                BorderColor3 = rgb(0, 0, 0),
                BackgroundColor3 = rgb(255, 255, 255),
                Visible = true,
                Image = "rbxassetid://18245826428",
                BackgroundTransparency = 1,
                ImageTransparency = 0.8,
                Position = dim2(0, -20, 0, -20),
                Size = dim2(1, 40, 1, 40),
                ZIndex = 0,
                BorderSizePixel = 0,
                SliceCenter = rect(vec2(21, 21), vec2(79, 79))
            }); library:applyTheme(glow, "glow", "ImageColor3")
            cfg.glow = glow

            library:draggify(outline)
            library:makeResizable(outline)

            local inline = library:create("Frame", {
                Parent = outline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.inline
            })
            library:applyTheme(inline, "inline", "BackgroundColor3")

            local background = library:create("Frame", {
                Parent = inline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.background
            })
            library:applyTheme(background, "background", "BackgroundColor3")

            local sidebar = library:create("Frame", {
                Parent = background,
                Name = "",
                Position = dim2(0, 0, 0, 0),
                Size = dim2(0, 64, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.inline
            })
            library:applyTheme(sidebar, "inline", "BackgroundColor3")

            local sidebar_inline = library:create("Frame", {
                Parent = sidebar,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.background
            })
            library:applyTheme(sidebar_inline, "background", "BackgroundColor3")

            local logo = library:create("ImageLabel", {
                Parent = sidebar_inline,
                Name = "",
                Image = cfg.logo,
                BackgroundTransparency = 1,
                Position = dim2(0.5, -16, 0, 12),
                Size = dim2(0, 32, 0, 32),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255,255,255)
            })

            cfg["tab_holder"] = library:create("Frame", {
                Parent = sidebar_inline,
                Name = "",
                BackgroundTransparency = 1,
                Position = dim2(0, 0, 0, 58),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 1, -70),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            library:create("UIListLayout", {
                Parent = cfg["tab_holder"],
                Name = "",
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = dim(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local content = library:create("Frame", {
                Parent = background,
                Name = "",
                Position = dim2(0, 64, 0, 0),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -64, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.background
            })
            library:applyTheme(content, "background", "BackgroundColor3")

            local title_holder = library:create("Frame", {
                Parent = content,
                Name = "",
                BackgroundTransparency = 1,
                BorderColor3 = rgb(0, 0, 0),
                Position = dim2(0, 14, 0, 10),
                Size = dim2(1, -28, 0, 32),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255, 255, 255)
            })

            local ui_title = library:create("TextLabel", {
                Parent = title_holder,
                Name = "",
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = cfg.name,
                Size = dim2(1, 0, 1, -8),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                RichText = true,
                TextSize = 12,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            library:applyTheme(ui_title, "text", "TextColor3")

            local accent_line = library:create("Frame", {
                Parent = content,
                Name = "",
                Position = dim2(0, 14, 0, 42),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -28, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.accent
            }); library:applyTheme(accent_line, "accent", "BackgroundColor3")

            local page_holder = library:create("Frame", {
                Parent = content,
                Name = "",
                Position = dim2(0, 12, 0, 50),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -24, 1, -62),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.element
            })
            library:applyTheme(page_holder, "element", "BackgroundColor3")

            cfg["page_holder"] = library:create("Frame", {
                Parent = page_holder,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.background
            }); library:applyTheme(cfg["page_holder"], "background", "BackgroundColor3")

            function cfg.toggle_menu(bool)
                outline.Visible = bool and true or false
                if cfg.glow then cfg.glow.Visible = bool and true or false end
            end

            return setmetatable(cfg, library)
        end 

        function library:tab(properties)
            local cfg = {
                name = properties.name or properties.Name or "visuals",
                icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6034767608",
            } 

            local tab_button = library:create("TextButton", {
                Parent = self.tab_holder,
                Name = "",
                Text = "",
                AutoButtonColor = false,
                Size = dim2(0, 44, 0, 44),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3 = rgb(255,255,255)
            })

            local icon_bg = library:create("Frame", {
                Parent = tab_button,
                Name = "",
                Size = dim2(0, 40, 0, 40),
                Position = dim2(0.5, -20, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.element
            })
            library:applyTheme(icon_bg, "element", "BackgroundColor3")

            local icon_stroke = library:create("UIStroke", {
                Parent = icon_bg,
                Thickness = 1,
                Color = themes.preset.outline
            })
            library:applyTheme(icon_stroke, "outline", "Color")

            local icon = library:create("ImageLabel", {
                Parent = icon_bg,
                Name = "",
                BackgroundTransparency = 1,
                Image = cfg.icon,
                ImageColor3 = themes.preset.unselected,
                Size = dim2(0, 18, 0, 18),
                Position = dim2(0.5, -9, 0.5, -9),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(255,255,255)
            })
            library:applyTheme(icon, "unselected", "ImageColor3")

            local indicator = library:create("Frame", {
                Parent = tab_button,
                Name = "",
                Visible = false,
                Size = dim2(0, 3, 0, 28),
                Position = dim2(0, 0, 0.5, -14),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.accent
            })
            library:applyTheme(indicator, "accent", "BackgroundColor3")

            local page_container = library:create("Frame", {
                Parent = self.page_holder,
                Name = "",
                Visible = false,
                Position = dim2(0, 0, 0, 0),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3 = rgb(255,255,255)
            })

            local tab_title = library:create("TextLabel", {
                Parent = page_container,
                Name = "",
                FontFace = library.font,
                TextColor3 = themes.preset.text,
                BorderColor3 = rgb(0, 0, 0),
                Text = cfg.name,
                BackgroundTransparency = 1,
                Position = dim2(0, 14, 0, 10),
                Size = dim2(1, -28, 0, 18),
                BorderSizePixel = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 12,
                BackgroundColor3 = rgb(255, 255, 255)
            })
            library:applyTheme(tab_title, "text", "TextColor3")

            cfg["page"] = library:create("Frame", {
                Parent = page_container,
                Name = "",
                Visible = true,
                Position = dim2(0, 0, 0, 32),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 1, -32),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3 = themes.preset.background
            }); library:applyTheme(cfg["page"], "background", "BackgroundColor3")

            library:create("UIListLayout", {
                Parent = cfg["page"],
                Name = "",
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = dim(0, 11),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            library:create("UIPadding", {
                Parent = cfg["page"],
                Name = "",
                PaddingTop = dim(0, 8),
                PaddingBottom = dim(0, 11),
                PaddingRight = dim(0, 11),
                PaddingLeft = dim(0, 11)
            })

            function cfg.open_tab()
                library:closeCurrentElement()

                if self.selected_tab then
                    self.selected_tab[1].ImageColor3 = themes.preset.unselected
                    self.selected_tab[2].BackgroundColor3 = themes.preset.element
                    self.selected_tab[3].Visible = false
                    self.selected_tab[4].Visible = false
                    self.selected_tab = nil
                end

                icon.ImageColor3 = themes.preset.accent
                icon_bg.BackgroundColor3 = themes.preset.element2
                indicator.Visible = true
                page_container.Visible = true
                self.selected_tab = {icon, icon_bg, indicator, page_container}
            end

            -- Add column method to tab for direct section support
            function cfg:column(properties)
                local col_cfg = {
                    fill = properties.fill or properties.Fill or false,
                }

                col_cfg["column"] = library:create("Frame", {
                    Parent = cfg["page"],
                    Name = "",
                    BackgroundTransparency = 1,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 100, 0, 100),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(0, 0, 0)
                })

                library:create("UIListLayout", {
                    Parent = col_cfg["column"],
                    Name = "",
                    Padding = dim(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = col_cfg.fill and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None
                })

                return setmetatable(col_cfg, library)
            end

            outline.MouseButton1Down:Connect(function()
                cfg.open_tab()
            end)

            if not self.selected_tab then
                cfg.open_tab(true)
            end

            return setmetatable(cfg, library)
        end

        function library:Page(properties)
            local cfg = {
                name = properties.name or properties.Name or "Page",
            }

            -- Create a separate page holder (independent of tabs)
            cfg.page_holder = library:create("Frame", {
                Parent = library.gui,
                Name = cfg.name,
                Visible = false,
                Position = dim2(0, 0, 0, 0),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(0, 0, 0)
            })

            local outline = library:create("Frame", {
                Parent = cfg.page_holder,
                Name = "",
                Position = dim2(0.5, -258, 0.5, -281),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 516, 0, 563),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.outline
            }); library:applyTheme(outline, "outline", "BackgroundColor3")

            local inline = library:create("Frame", {
                Parent = outline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.inline
            }); library:applyTheme(inline, "inline", "BackgroundColor3")

            local background = library:create("Frame", {
                Parent = inline,
                Name = "",
                Position = dim2(0, 1, 0, 1),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3 = themes.preset.background
            }); library:applyTheme(background, "background", "BackgroundColor3")

            library:draggify(outline)
            library:makeResizable(outline)

            -- Page content area
            cfg.content = library:create("Frame", {
                Parent = background,
                Name = "",
                Position = dim2(0, 0, 0, 30),
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(1, 0, 1, -30),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(0, 0, 0)
            })

            library:create("UIListLayout", {
                Parent = cfg.content,
                Name = "",
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = dim(0, 11),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            library:create("UIPadding", {
                Parent = cfg.content,
                Name = "",
                PaddingTop = dim(0, 11),
                PaddingBottom = dim(0, 11),
                PaddingRight = dim(0, 11),
                PaddingLeft = dim(0, 11)
            })

            -- Add column method to page
            function cfg:column(properties)
                local col_cfg = {
                    fill = properties.fill or properties.Fill or false,
                }

                col_cfg["column"] = library:create("Frame", {
                    Parent = cfg.content,
                    Name = "",
                    BackgroundTransparency = 1,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 100, 0, 100),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(0, 0, 0)
                })

                library:create("UIListLayout", {
                    Parent = col_cfg["column"],
                    Name = "",
                    Padding = dim(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = col_cfg.fill and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None
                })

                return setmetatable(col_cfg, library)
            end

            -- Add section method to page
            function cfg:Section(properties)
                local col = self:column({fill = true})
                return col:section(properties)
            end

            -- Add MultiSection method to page
            function cfg:MultiSection(properties)
                local wrapper = {}
                local side = properties.Side or 1
                local col = self:column({fill = true})

                function wrapper:Add(name)
                    return col:section({name = name})
                end

                function wrapper:Select(name)
                    -- Selection logic if needed
                end

                return wrapper
            end

            function cfg:show()
                cfg.page_holder.Visible = true
            end

            function cfg:hide()
                cfg.page_holder.Visible = false
            end

            return setmetatable(cfg, library)
        end

        function library:column(properties)
            local cfg = {
                fill = properties.fill or properties.Fill or false, 
            }

            cfg["column"] = library:create("Frame", {
                Parent = self.page,
                Name = "",
                BackgroundTransparency = 1,
                BorderColor3 = rgb(0, 0, 0),
                Size = dim2(0, 100, 0, 100),
                BorderSizePixel = 0,
                BackgroundColor3 = rgb(0, 0, 0)
            })
            
            library:create("UIListLayout", {
                Parent = cfg["column"],
                Name = "",
                Padding = dim(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder, 
                VerticalFlex = cfg.fill and Enum.UIFlexAlignment.Fill or Enum.UIFlexAlignment.None
            })

            return setmetatable(cfg, library)
        end 

        function library:section(properties)
            local cfg = {
                name = properties.name or properties.Name or "section", 
                size = properties.size or properties.Size or dim2(1, 0, 1, -12)
            }   

            -- Instances
                local outline = library:create("Frame", {
                    Parent = self.column,
                    Name = "",
                    BorderColor3 = rgb(0, 0, 0),
                    Size = self.fill and dim2(1, 0, 0, 0) or cfg.size,
                    BorderSizePixel = 0,
                    BackgroundColor3 = themes.preset.outline
                }); library:applyTheme(outline, "outline", "BackgroundColor3")
                
                local inline = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = themes.preset.inline
                }); library:applyTheme(inline, "inline", "BackgroundColor3")
                
                local background = library:create("Frame", {
                    Parent = inline,
                    Name = "",
                    Position = dim2(0, 1, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = themes.preset.background
                }); library:applyTheme(background, "background", "BackgroundColor3")
                
                local scrollbar_fill = library:create("Frame", {
                    Parent = background,
                    Name = "",
                    Visible = false, 
                    Size = dim2(0, 5, 1, 0),
                    Position = dim2(1, -5, 0, 0),
                    BorderColor3 = rgb(0, 0, 0),
                    ZIndex = 4,
                    BorderSizePixel = 0,
                    BackgroundColor3 = themes.preset.element2
                }); library:applyTheme(scrollbar_fill, "element2", "BackgroundColor3")
                
                local shadow = library:create("Frame", {
                    Parent = background,
                    Name = "",
                    Size = dim2(1, -5, 0, 21),
                    Position = dim2(0, 0, 1, -21),
                    BorderColor3 = themes.preset.border,
                    ZIndex = 999,
                    BorderSizePixel = 0,
                    BackgroundColor3 = themes.preset.background
                }); library:applyTheme(shadow, "background", "BackgroundColor3")
                
                local UIGradient = library:create("UIGradient", {
                    Parent = shadow,
                    Name = "",
                    Rotation = -90,
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)}
                })
                
                local elements_scroll = library:create("ScrollingFrame", {
                    Parent = background,
                    Name = "",
                    ScrollBarImageColor3 = rgb(25, 25, 25),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 4,
                    BorderColor3 = rgb(0, 0, 0),
                    BackgroundTransparency = 1,
                    Size = dim2(1, 0, 1, 0),
                    BackgroundColor3 = rgb(255, 255, 255),
                    ZIndex = 5,
                    BorderSizePixel = 0,
                    CanvasSize = dim2(0, 0, 0, 0)
                })
                
                cfg["elements"] = library:create("Frame", {
                    Parent = elements_scroll,
                    Name = "",
                    Position = dim2(0, 8, 0, 16),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(1, -16, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                library:create("UIListLayout", {
                    Parent = cfg["elements"],
                    Name = "",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = dim(0, 3)
                })
                
                local empty_space = library:create("Frame", {
                    Parent = cfg["elements"],
                    Name = "",
                    LayoutOrder = 9999999,
                    BackgroundTransparency = 1,
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, 0, 0, 50),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(255, 255, 255)
                })
                
                local section_title = library:create("TextLabel", {
                    Parent = outline,
                    Name = "",
                    FontFace = library.font,
                    TextColor3 = themes.preset.text,
                    BorderColor3 = rgb(0, 0, 0),
                    Text = cfg.name,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    AnchorPoint = vec2(0, 0.5),
                    Position = dim2(0, 14, 0, 3),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 12,
                    BackgroundColor3 = rgb(0, 0, 0)
                }); library:applyTheme(section_title, "text", "TextColor3")

                local section_filler = library:create("Frame", {
                    Parent = outline,
                    Name = "",
                    AnchorPoint = vec2(0, 0.5),
                    Position = dim2(0, 13, 0, 1),
                    BorderColor3 = rgb(0, 0, 0),
                    Size = dim2(0, section_title.TextBounds.X, 0, 3),
                    BorderSizePixel = 0,
                    BackgroundColor3 = rgb(0, 0, 0)
                })
            -- 

            -- Connections 
                elements_scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
                    scrollbar_fill.Visible = elements_scroll.AbsoluteCanvasSize.Y > background.AbsoluteSize.Y and true or false 
                end)
            -- 

            return setmetatable(cfg, library)
        end 

        -- Elements     
            function library:addToggle(options) 
                local cfg = {
                    enabled = options.enabled or nil,
                    name = options.name or "Toggle",
                    flag = options.flag or tostring(random(1,9999999)),
                    
                    default = options.default or false,
                    folding = options.folding or false, 
                    callback = options.callback or function() end,
                }

                -- Instances 
                    local toggle = library:create("TextLabel", {
                        Parent = self.background or self.elements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(toggle, "text", "TextColor3")
                    
                    cfg["right_components"] = library:create("Frame", {
                        Parent = toggle,
                        Name = "",
                        Position = dim2(1, 0, 0, -1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIListLayout", {
                        Parent = cfg["right_components"],
                        Name = "",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = dim(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    library:create("UIPadding", {
                        Parent = toggle,
                        Name = ""
                    })
                    
                    local left_components = library:create("Frame", {
                        Parent = toggle,
                        Name = "",
                        BackgroundTransparency = 1,
                        Position = dim2(0, 3, 0, 1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIListLayout", {
                        Parent = left_components,
                        Name = "",
                        Padding = dim(0, 5),
                        FillDirection = Enum.FillDirection.Horizontal
                    })
                    
                    library:create("UIPadding", {
                        Parent = left_components,
                        Name = "",
                        PaddingBottom = dim(0, 5)
                    })
                    
                    local toggle_button = library:create("TextButton", {
                        Parent = left_components,
                        Name = "",
                        Text = "",
                        Position = dim2(0, 0, 0, 2),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(0, 8, 0, 8),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline,
                        LayoutOrder = -1,
                        AutoButtonColor = false
                    }); library:applyTheme(toggle_button, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = toggle_button,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element2
                    }); library:applyTheme(inline, "element2", "BackgroundColor3")
                    
                    library:create("UIGradient", {
                        Parent = inline,
                        Name = "",
                        Rotation = 90,
                        Color = rgbseq{rgbkey(0, rgb(232, 232, 232)), rgbkey(1, rgb(162, 162, 162))}
                    })
                    
                    local accent = library:create("Frame", {
                        Parent = inline,
                        Name = "",
                        Visible = false,
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.accent
                    }); library:applyTheme(accent, "accent", "BackgroundColor3")
                    
                    library:create("UIGradient", {
                        Parent = accent,
                        Name = "",
                        Rotation = 90,
                        Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(109, 109, 109))}
                    })
                    
                    local text = library:create("TextButton", {
                        Parent = left_components,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = rgb(0, 0, 0),
                        Text = cfg.name,
                        BackgroundTransparency = 1,
                        Size = dim2(0, 0, 1, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextSize = 12,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(text, "text", "TextColor3")

                    cfg.background = library:create("Frame", {
                        Parent = toggle,
                        Name = "",
                        Visible = false,
                        BorderColor3 = rgb(0, 0, 0),
                        LayoutOrder = 99,
                        Position = dim2(0, 0, 0, 15),
                        Size = dim2(1, self.background and 2 or -6, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })

                    library:create("UIListLayout", {
                        Parent = cfg.background,
                        Name = "",
                        Padding = dim(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Vertical
                    })
                -- 

                -- Functions 
                    function cfg.set(bool) 
                        accent.Visible = bool 

                        flags[cfg.flag] = bool

                        cfg.callback(bool)

                        if cfg.folding then 
                            cfg.background.Visible = bool
                        end 
                    end 

                    cfg.set(cfg.default)

                    library.config_flags[cfg.flag] = cfg.set
                -- 

                -- Connections
                    toggle_button.MouseButton1Click:Connect(function()
                        cfg.enabled = not cfg.enabled 
                        cfg.set(cfg.enabled)
                    end)

                    text.MouseButton1Click:Connect(function()
                        cfg.enabled = not cfg.enabled 
                        cfg.set(cfg.enabled)
                    end)
                -- 

                cfg.__ui = toggle

                return setmetatable(cfg, library)
            end
            
            function library:addSlider(options) 
                local cfg = {
                    name = options.name or nil,
                    suffix = options.suffix or "",
                    flag = options.flag or tostring(2^789),
                    callback = options.callback or function() end, 
    
                    min = options.min or options.minimum or 0,
                    max = options.max or options.maximum or 100,
                    intervals = options.interval or options.decimal or 1,
                    default = options.default or 10,
                    value = options.default or 10, 

                    ignore = options.ignore or false, 
                    dragging = false,
                } 

                -- Instances 
                    local slider = library:create("TextLabel", {
                        Parent = self.elements or self.background or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(slider, "text", "TextColor3")
                    
                    local bottom_components = library:create("Frame", {
                        Parent = slider,
                        Name = "",
                        Position = dim2(0, 15, 0, cfg.name and 13 or 0),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, self.background and 2 or -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local slider_dragger = library:create("TextButton", {
                        Parent = bottom_components,
                        Name = "",
                        AutoButtonColor = false, 
                        Text = "", 
                        Position = dim2(0, 0, 0, 2),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -27, 1, 8),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(slider_dragger, "outline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = slider_dragger,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element2
                    }); library:applyTheme(background, "element2", "BackgroundColor3")
                    
                    local fill = library:create("Frame", {
                        Parent = background,
                        Name = "",
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.accent
                    }); library:applyTheme(fill, "accent", "BackgroundColor3")
                    
                    library:create("UIGradient", {
                        Parent = fill,
                        Name = "",
                        Rotation = 90,
                        Color = rgbseq{rgbkey(0, rgb(232, 232, 232)), rgbkey(1, rgb(162, 162, 162))}
                    })
                    
                    local text_slider = library:create("TextLabel", {
                        Parent = fill,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "0%",
                        AnchorPoint = vec2(0.5, 0),
                        BackgroundTransparency = 1,
                        Position = dim2(1, 0, 0, 0),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.XY,
                        TextSize = 12,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIGradient", {
                        Parent = background,
                        Name = "",
                        Rotation = 90,
                        Color = rgbseq{rgbkey(0, rgb(63, 63, 63)), rgbkey(1, rgb(42, 42, 42))}
                    })
                    
                    library:create("UIListLayout", {
                        Parent = bottom_components,
                        Name = "",
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = dim(0, 3),
                        FillDirection = Enum.FillDirection.Vertical
                    })
            
                    library:create("UIPadding", {
                        Parent = slider,
                        Name = "",
                        PaddingLeft = dim(0, 1)
                    })
                    
                    if cfg.name then 
                        local left_components = library:create("Frame", {
                            Parent = slider,
                            Name = "",
                            BackgroundTransparency = 1,
                            Position = dim2(0, 16, 0, 1),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 14),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })
                        
                        local text = library:create("TextLabel", {
                            Parent = left_components,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = rgb(0, 0, 0),
                            Text = cfg.name,
                            BackgroundTransparency = 1,
                            Size = dim2(0, 0, 1, -1),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 12,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(text, "text", "TextColor3")
                        
                        library:create("UIListLayout", {
                            Parent = left_components,
                            Name = "",
                            Padding = dim(0, 5),
                            FillDirection = Enum.FillDirection.Horizontal
                        })
                        
                        library:create("UIPadding", {
                            Parent = left_components,
                            Name = "",
                            PaddingBottom = dim(0, 6)
                        })
                    end 

                    if not self.background then 
                        local seperator = library:create("Frame", {
                            Parent = slider,
                            Name = "",
                            Position = dim2(0, 0, 1, 0),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 5),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })
                    end 
                -- 

                -- Functions 
                    function cfg.set(value) 
                        cfg.value = clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)

                        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
                        text_slider.Text = tostring(cfg.value) .. cfg.suffix

                        flags[cfg.flag] = cfg.value
                        cfg.callback(flags[cfg.flag])
                    end 

                    cfg.set(cfg.default)
                -- 

                -- Connections
                    slider_dragger.MouseButton1Down:Connect(function()
                        cfg.dragging = true 
                    end)

                    library:connection(uis.InputChanged, LPH_NO_VIRTUALIZE(function(input)
                        if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                            local size_x = (input.Position.X - slider_dragger.AbsolutePosition.X) / slider_dragger.AbsoluteSize.X
                            local value = ((cfg.max - cfg.min) * size_x) + cfg.min

                            cfg.set(value)
                        end
                    end))

                    library:connection(uis.InputEnded, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            cfg.dragging = false 
                        end 
                    end)
                -- 

                cfg.set(cfg.default)

                cfg.__ui = slider

                config_flags[cfg.flag] = cfg.set

                return setmetatable(cfg, library)
            end 

            function library:addDropdown(options) 
                local cfg = {
                    name = options.name or nil,
                    flag = options.flag or tostring(random(1,9999999)),

                    items = options.items or {"1", "2", "3"},
                    callback = options.callback or function() end,
                    multi = options.multi or false, 
                    scrolling = options.scrolling or false, 

                    -- Ignore these 
                    open = false, 
                    option_instances = {}, 
                    multi_items = {}, 
                    ignore = options.ignore or false, 
                }   

                cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1]

                flags[cfg.flag] = {} 

                -- Instances
                    local dropdown_path = library:create("TextLabel", {
                        Parent = self.background or self.elements or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })

                    cfg["right_components"] = library:create("Frame", {
                        Parent = dropdown_path,
                        Name = "",
                        Position = dim2(1, 0, 0, -1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIListLayout", {
                        Parent = cfg["right_components"],
                        Name = "",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = dim(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    local bottom_components = library:create("Frame", {
                        Parent = dropdown_path,
                        Name = "",
                        Position = dim2(0, 15, 0, cfg.name and 11 or 0),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, self.background and 2 or -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local dropdown = library:create("TextButton", {
                        Parent = bottom_components,
                        Name = "",
                        AutoButtonColor = false, 
                        Text = "",
                        Position = dim2(0, 0, 0, 2),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, -27, 1, 20),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(dropdown, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = dropdown,
                        Name = "",
                        Position = dim2(0, 0, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -1, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.inline
                    }); library:applyTheme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element
                    }); library:applyTheme(background, "element", "BackgroundColor3")
                    
                    local arrow = library:create("ImageLabel", {
                        Parent = background,
                        Name = "",
                        Image = "rbxassetid://116204929609664",
                        Position = dim2(1, -13, 0, 7),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 5, 0, 3),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })  

                    local text = library:create("TextLabel", {
                        Parent = background,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "players",
                        Size = dim2(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = dim2(0, 7, 0, -1),
                        BorderSizePixel = 0,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left, 
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })                    
                    
                    if cfg.name then 
                        local left_components = library:create("Frame", {
                            Parent = dropdown_path,
                            Name = "",
                            BackgroundTransparency = 1,
                            Position = dim2(0, 16, 0, 1),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 14),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })
                        
                        local text = library:create("TextLabel", {
                            Parent = left_components,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = rgb(0, 0, 0),
                            Text = cfg.name,
                            BackgroundTransparency = 1,
                            Size = dim2(0, 0, 1, -1),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 12,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(text, "text", "TextColor3")
                        
                        library:create("UIListLayout", {
                            Parent = left_components,
                            Name = "",
                            Padding = dim(0, 5),
                            FillDirection = Enum.FillDirection.Horizontal
                        })
                        
                        library:create("UIPadding", {
                            Parent = left_components,
                            Name = "",
                            PaddingBottom = dim(0, 6)
                        })
                    end 

                    -- local UIStroke = library:create("UIStroke", {
                    --     Parent = dropdown,
                    --     Name = ""
                    -- })
                    
                    local UIPadding = library:create("UIPadding", {
                        Parent = dropdown,
                        Name = "",
                        PaddingLeft = dim(0, 1)
                    })

                    -- Dropdown holder 
                        local dropdown_holder = library:create("Frame", {
                            Parent = library.gui,
                            Name = "",
                            Size = dim2(0, 161, 0, 0),
                            Position = dim2(0, 100, 0, 200),
                            BorderColor3 = themes.preset.border,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = themes.preset.outline,
                            Visible = false, 
                            ZIndex = 999
                        }); library:applyTheme(dropdown_holder, "outline", "BackgroundColor3")
                        
                        local inline = library:create("Frame", {
                            Parent = dropdown_holder,
                            Name = "",
                            Position = dim2(0, 1, 0, 1),
                            BorderColor3 = themes.preset.border,
                            Size = dim2(1, -2, 1, -2),
                            BorderSizePixel = 0,
                            BackgroundColor3 = themes.preset.inline
                        }); library:applyTheme(inline, "inline", "BackgroundColor3")
                        
                        local text_holder = library:create("Frame", {
                            Parent = inline,
                            Name = "",
                            Position = dim2(0, 1, 0, 1),
                            BorderColor3 = themes.preset.border,
                            Size = dim2(1, -2, 1, -2),
                            BorderSizePixel = 0,
                            BackgroundColor3 = themes.preset.element
                        }); library:applyTheme(text_holder, "element", "BackgroundColor3")
                        
                        library:create("UIPadding", {
                            Parent = text_holder,
                            Name = "",
                            PaddingTop = dim(0, 2),
                            PaddingBottom = dim(0, 7),
                            PaddingLeft = dim(0, 7)
                        })
                        
                        library:create("UIListLayout", {
                            Parent = text_holder,
                            Name = "",
                            Padding = dim(0, 5),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })
                    -- 
                -- 

                -- Functions 
                    function cfg.renderOption(text) 
                        local OPTION = library:create("TextButton", {
                            Parent = text_holder,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = themes.preset.border,
                            Text = text,
                            Size = dim2(0, 0, 0, -1),
                            BackgroundTransparency = 1,
                            Position = dim2(0, 6, 0, -1),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            TextSize = 12,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(OPTION, "accent", "TextColor3")

                        return OPTION
                    end 
                    
                    function cfg.setVisible(bool) 
                        dropdown_holder.Visible = bool

                        arrow.Rotation = bool and 180 or 0 

                        if bool then 
                            library:closeCurrentElement(cfg)
                            library.current_element_open = cfg 
                        end
                    end
                    
                    function cfg.set(value) 
                        local selected = {}
                        local isTable = type(value) == "table"

                        for _, option in next, cfg.option_instances do 
                            if option.Text == value or (isTable and find(value, option.Text)) then 
                                insert(selected, option.Text)
                                cfg.multi_items = selected
                                option.TextColor3 = themes.preset.accent
                            else 
                                option.TextColor3 = rgb(160, 160, 160)
                            end
                        end

                        text.Text = isTable and concat(selected, ", ") or selected[1] or ""
                        flags[cfg.flag] = isTable and selected or selected[1]
                            
                        cfg.callback(flags[cfg.flag]) 
                    end
                    
                    function cfg.refreshOptions(list) 
                        for _, option in next, cfg.option_instances do 
                            option:Destroy() 
                        end
                        
                        cfg.option_instances = {} 

                        for _, option in next, list do 
                            local OPTION_INSTANCE = cfg.renderOption(option)
                            insert(cfg.option_instances, OPTION_INSTANCE)
                            
                            OPTION_INSTANCE.MouseButton1Down:Connect(function()
                                if cfg.multi then 
                                    local selected_index = find(cfg.multi_items, OPTION_INSTANCE.Text)
        
                                    if selected_index then 
                                        remove(cfg.multi_items, selected_index)
                                    else
                                        insert(cfg.multi_items, OPTION_INSTANCE.Text)
                                    end
        
                                    cfg.set(cfg.multi_items) 				
                                else 
                                    cfg.setVisible(false)
                                    cfg.open = false 
                                    
                                    cfg.set(OPTION_INSTANCE.Text)
                                end
                            end)
                        end
                    end

                    cfg.refreshOptions(cfg.items)
                    cfg.set(cfg.default)
                -- 

                -- Connections 
                    dropdown.MouseButton1Click:Connect(function()
                        cfg.open = not cfg.open 
                        
                        cfg.setVisible(cfg.open)
                    end)

                    dropdown:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                        dropdown_holder.Size = dim2(0, dropdown.AbsoluteSize.X, 0, dropdown_holder.Size.Y.Offset)
                    end)
    
                    dropdown:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                        dropdown_holder.Position = dim2(0, dropdown.AbsolutePosition.X, 0, dropdown.AbsolutePosition.Y + 80)
                    end)
                -- 

                cfg.__ui = dropdown_path

                return setmetatable(cfg, library)
            end 
            
            function library:addColorPicker(options) 
                local cfg = {
                    name = options.name or "Color", 
                    flag = options.flag or tostring(2^789),

                    color = options.color or color(1, 1, 1), -- Default to white color if not provided
                    alpha = options.alpha or 1,

                    open = false, 
                    type = options.animation or "animation",

                    ignore = options.ignore or false, 

                    callback = options.callback or function() end,
                }

                flags[cfg.flag] = {} 

                -- Standalone color picker (called on a section, not a toggle/label)
                    if not self.right_components then
                        local row = library:create("TextLabel", {
                            Parent = self.elements or self.background,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = themes.preset.border,
                            Text = "",
                            ZIndex = 2,
                            Size = dim2(1, -8, 0, 12),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            TextSize = 11,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })

                        local right_components = library:create("Frame", {
                            Parent = row,
                            Name = "",
                            Position = dim2(1, 0, 0, -1),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 12),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })

                        library:create("UIListLayout", {
                            Parent = right_components,
                            Name = "",
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            Padding = dim(0, 4),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        })

                        local left_components = library:create("Frame", {
                            Parent = row,
                            Name = "",
                            BackgroundTransparency = 1,
                            Position = dim2(0, 3, 0, 1),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 14),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })

                        library:create("UIListLayout", {
                            Parent = left_components,
                            Name = "",
                            Padding = dim(0, 5),
                            FillDirection = Enum.FillDirection.Horizontal
                        })

                        local text = library:create("TextButton", {
                            Parent = left_components,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = rgb(0, 0, 0),
                            Text = cfg.name,
                            BackgroundTransparency = 1,
                            Size = dim2(0, 0, 1, -1),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 12,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(text, "text", "TextColor3")

                        cfg.__ui = row
                        self = setmetatable({right_components = right_components}, library)
                    end

                -- Instances
                    local outline = library:create("Frame", {
                        Parent = self.right_components,
                        Name = "",
                        BorderColor3 = themes.preset.border,
                        Size = dim2(0, 18, 0, 9),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(outline, "outline", "BackgroundColor3")
                    
                    cfg.colorPath = library:create("Frame", {
                        Parent = outline,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(162, 57, 209)
                    })

                    cfg.alphaPath = library:create("ImageLabel", {
                        Parent = cfg.colorPath,
                        Name = "",
                        ScaleType = Enum.ScaleType.Tile,
                        ImageTransparency = 0.28999999165534973,
                        BorderColor3 = rgb(0, 0, 0),
                        Image = "rbxassetid://18274452449",
                        BackgroundTransparency = 1,
                        Size = dim2(1, 0, 1, 0),
                        TileSize = dim2(0, 2, 0, 2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIGradient", {
                        Parent = cfg.colorPath,
                        Name = "",
                        Rotation = 90,
                        Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(152, 152, 152))}
                    })

                    local button = library:create("TextButton", {
                        Parent = outline,
                        Name = "",
                        Text = "",
                        AutoButtonColor = false, 
                        BackgroundTransparency = 1, 
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 2, 
                        BackgroundColor3 = rgb(2, 2, 2)
                    })
                -- 
                
                local colorpicker = library:keyPicker(cfg)
                
                -- Connections 
                    button.MouseButton1Click:Connect(function()
                        colorpicker.open = not colorpicker.open 
                        colorpicker.setVisible(colorpicker.open)              
                    end)

                    button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
                        colorpicker.outline.Position = dim_offset(button.AbsolutePosition.X + 1, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 63)
                    end)

                    colorpicker.outline.Position = dim_offset(button.AbsolutePosition.X + 1, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 63)
                -- 

                if not cfg.__ui then
                    cfg.__ui = outline
                end

                return setmetatable(cfg, library)
            end 

            function library:addLabel(options)
                local cfg = {
                    name = options.name or "Label!",
                }

                -- Instances 
                    local label = library:create("TextLabel", {
                        Parent = self.elements or self.background or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    cfg["right_components"] = library:create("Frame", {
                        Parent = label,
                        Name = "",
                        Position = dim2(1, 0, 0, -1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIListLayout", {
                        Parent = cfg["right_components"],
                        Name = "",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Padding = dim(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    library:create("UIPadding", {
                        Parent = label,
                        Name = ""
                    })
                    
                    local left_components = library:create("Frame", {
                        Parent = label,
                        Name = "",
                        BackgroundTransparency = 1,
                        Position = dim2(0, 3, 0, 1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    library:create("UIListLayout", {
                        Parent = left_components,
                        Name = "",
                        Padding = dim(0, 5),
                        FillDirection = Enum.FillDirection.Horizontal
                    })
                    
                    library:create("UIPadding", {
                        Parent = left_components,
                        Name = "",
                        PaddingBottom = dim(0, 5)
                    })
                    
                    local text = library:create("TextButton", {
                        Parent = left_components,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = rgb(0, 0, 0),
                        Text = cfg.name,
                        BackgroundTransparency = 1,
                        Size = dim2(0, 0, 1, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextSize = 12,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(text, "text", "TextColor3")

                    library:create("UIListLayout", {
                        Parent = cfg.background,
                        Name = "",
                        Padding = dim(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Vertical
                    })
                -- 

                cfg.__ui = label

                return setmetatable(cfg, library)
            end 
            
            function library:addTextBox(options) 
                local cfg = {
                    name = options.name or "TextBox",
                    placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
                    default = options.default,
                    flag = options.flag or "flag",
                    callback = options.callback or function() end,
                    visible = options.visible or true,
                }
                
                -- Instances 
                    local textbox_holder = library:create("TextLabel", {
                        Parent = self.background or self.elements or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(textbox_holder, "text", "TextColor3")
                    
                    local bottom_components = library:create("Frame", {
                        Parent = textbox_holder,
                        Name = "",
                        Position = dim2(0, 14, 0, 13),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local textbox = library:create("Frame", {
                        Parent = bottom_components,
                        Name = "",
                        Position = dim2(0, -1, 0, 2),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -27, 1, 20),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(textbox, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = textbox,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.inline
                    }); library:applyTheme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element
                    }); library:applyTheme(background, "element", "BackgroundColor3")
                    
                    local textbox = library:create("TextBox", {
                        Parent = background,
                        Name = "",
                        FontFace = library.font,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextSize = 12,
                        Size = dim2(1, -6, 1, 0),
                        RichText = true,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        CursorPosition = -1,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Position = dim2(0, 6, 0, 0),
                        BorderSizePixel = 0,
                        PlaceholderText = cfg.placeholder,
                        PlaceholderColor3 = themes.preset.unselected,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(textbox, "text", "TextColor3")
                    
                    library:create("UIListLayout", {
                        Parent = bottom_components,
                        Name = "",
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    local UIStroke = library:create("UIStroke", {
                        Parent = textbox_holder,
                        Name = ""
                    })
                    
                    local UIPadding = library:create("UIPadding", {
                        Parent = textbox_holder,
                        Name = "",
                        PaddingLeft = dim(0, 1)
                    })
                    
                    local left_components = library:create("Frame", {
                        Parent = textbox_holder,
                        Name = "",
                        BackgroundTransparency = 1,
                        Position = dim2(0, 16, 0, 1),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(0, 0, 0, 14),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local text = library:create("TextLabel", {
                        Parent = left_components,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = rgb(0, 0, 0),
                        Text = cfg.name,
                        BackgroundTransparency = 1,
                        Size = dim2(0, 0, 1, -1),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextSize = 12,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(text, "text", "TextColor3")
                    
                    library:create("UIListLayout", {
                        Parent = left_components,
                        Name = "",
                        Padding = dim(0, 5),
                        FillDirection = Enum.FillDirection.Horizontal
                    })
                    
                    library:create("UIPadding", {
                        Parent = left_components,
                        Name = "",
                        PaddingBottom = dim(0, 6)
                    })
                -- 
                
                -- Functions
                    function cfg.set(text) 
                        flags[cfg.flag] = text
                        textbox.Text = text
                        cfg.callback(text)
                    end 

                    if cfg.default then 
                        cfg.set(cfg.default) 
                    end 
                -- 

                -- Connections 
                    textbox:GetPropertyChangedSignal("Text"):Connect(function()
                        cfg.set(textbox.Text) 
                    end)
                -- 
                
                cfg.__ui = textbox_holder

                return setmetatable(cfg, library)
            end 
            
            function library:addKeyBind(options) 
                local parent_set = nil
                if self and self.set and type(self.set) == "function" and self ~= library then
                    parent_set = self.set
                end

                local cfg = {
                    flag = options.flag or "SET ME A FLAG NOWWW!!!!",
                    callback = options.callback or (parent_set and function(bool)
                        if self then
                            self.enabled = bool
                        end
                        parent_set(bool)
                    end) or function() end,
                    open = false,
                    binding = nil, 
                    name = options.name or nil, 
                    ignore_key = options.ignore or false, 
    
                    key = options.key or (typeof(options.default) == "EnumItem" and options.default) or nil, 
                    mode = (options.mode and string.lower(options.mode)) or "toggle",
                    active = (type(options.default) == "boolean") and options.default or false, 
    
                    hold_instances = {},
                }

                flags[cfg.flag] = {} 

                -- Instances
                    local outline = library:create("TextButton", {
                        Parent = self.right_components,
                        Name = "",
                        Text = "", 
                        AutoButtonColor = false, 
                        BorderColor3 = rgb(0, 0, 0),
                        BackgroundTransparency = 1,
                        SelectionOrder = -1,
                        Size = dim2(0, 0, 0, 9),
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local text_label = library:create("TextLabel", {
                        Parent = outline,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.unselected,
                        BorderColor3 = themes.preset.border,
                        Text = "[ ... ]",
                        Size = dim2(1, 0, 1, 0),
                        Position = dim2(0, 0, 0, -1),
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextSize = 12,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                
                -- 

                -- Functions 
                    function cfg.set_mode(mode) 
                        cfg.mode = mode 

                        if mode == "always" then
                            cfg.set(true)
                        elseif mode == "hold" then
                            cfg.set(false)
                        end

                        flags[cfg.flag]["mode"] = mode
                    end 

                    function cfg.set(input)
                        if type(input) == "boolean" then 
                            local __cached = input 

                            if cfg.mode == "always" then 
                                __cached = true 
                            end 

                            cfg.active = __cached 
                            cfg.callback(__cached)
                        elseif tostring(input):find("Enum") then 
                            input = input.Name == "Escape" and "..." or input

                            cfg.key = input or "..."	

                            cfg.callback(cfg.active or false)
                        elseif type(input) == "string" and find({"toggle", "hold", "always"}, string.lower(input)) then 
                            cfg.set_mode(string.lower(input))

                            if input == "always" then 
                                cfg.active = true 
                            end 

                            cfg.callback(cfg.active or false)
                        elseif type(input) == "table" then 
                            input.key = type(input.key) == "string" and input.key ~= "..." and library:convertEnum(input.key) or input.key

                            input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
                            cfg.key = input.key or "..."
                            
                            cfg.mode = (input.mode and string.lower(input.mode)) or "toggle"

                            cfg.active = input.active == true
                        end 

                        local flag_key = cfg.key
                        if flag_key == "..." or flag_key == nil then
                            flag_key = nil
                        end
                        flags[cfg.flag] = {
                            mode = cfg.mode,
                            key = cfg.key, 
                            Key = flag_key,
                            active = cfg.active,
                            Toggled = cfg.active == true,
                            name = cfg.name or (self and self.name) or cfg.flag,
                        }

                        local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                        local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", "")) or "..."
                        
                        text_label.Text = "[" .. string.lower(__text) .. "]"

                        -- KEYBIND LIST
                        -- if cfg.name then 
                        --     KEYBIND_ELEMENT.Visible = cfg.active
                        -- end 

                        -- local text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
                        -- local __text = text and (tostring(text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

                        -- if cfg.name then 
                        --     KEYBIND_ELEMENT.Text = "[ " .. string.upper(string.sub(cfg.mode, 1, 1)) .. string.sub(cfg.mode, 2) .. " ] " .. cfg.name .. " - " .. __text
                        -- end 
                    end
                -- 
                
                -- Connections 
                    local mode_menu = nil

                    local function close_mode_menu()
                        if mode_menu then
                            mode_menu:Destroy()
                            mode_menu = nil
                        end
                    end

                    local function open_mode_menu()
                        close_mode_menu()

                        local menu = library:create("Frame", {
                            Parent = library.gui,
                            Name = "",
                            ZIndex = 9999,
                            BorderSizePixel = 0,
                            Size = dim2(0, 70, 0, 0),
                            BackgroundColor3 = rgb(15, 15, 15),
                            BorderColor3 = rgb(0, 0, 0),
                        })

                        library:create("UIStroke", {
                            Parent = menu,
                            Color = rgb(0, 0, 0),
                            Thickness = 1,
                            LineJoinMode = Enum.LineJoinMode.Miter,
                        })

                        local layout = library:create("UIListLayout", {
                            Parent = menu,
                            Padding = dim(0, 0),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            FillDirection = Enum.FillDirection.Vertical,
                        })

                        local modes_list = {"toggle", "hold", "always"}

                        for _, mode_name in ipairs(modes_list) do
                            local is_current = cfg.mode == mode_name
                            local btn = library:create("TextButton", {
                                Parent = menu,
                                Name = "",
                                Text = string.upper(string.sub(mode_name, 1, 1)) .. string.sub(mode_name, 2),
                                FontFace = library.font,
                                TextColor3 = is_current and themes.preset.accent or themes.preset.unselected,
                                TextSize = 11,
                                Size = dim2(1, 0, 0, 16),
                                BackgroundColor3 = is_current and themes.preset.element2 or themes.preset.element,
                                BorderSizePixel = 0,
                                AutoButtonColor = false,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                ZIndex = 9999,
                            })

                            if is_current then
                                library:applyTheme(btn, "accent", "TextColor3")
                            end

                            btn.MouseButton1Click:Connect(function()
                                cfg.set_mode(mode_name)
                                cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
                                close_mode_menu()
                            end)

                            btn.MouseEnter:Connect(function()
                                btn.BackgroundColor3 = rgb(30, 30, 30)
                            end)
                            btn.MouseLeave:Connect(function()
                                btn.BackgroundColor3 = is_current and rgb(25, 25, 25) or rgb(15, 15, 15)
                            end)
                        end

                        local abs_pos = outline.AbsolutePosition
                        local abs_size = outline.AbsoluteSize
                        menu.Position = dim2(0, abs_pos.X, 0, abs_pos.Y + abs_size.Y + 2)
                        menu.Size = dim2(0, 70, 0, #modes_list * 16)

                        mode_menu = menu

                        library:connection(uis.InputBegan, function(input, game_event)
                            if game_event then return end
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                                local mp = uis:GetMouseLocation()
                                local mp_x, mp_y = mp.X, mp.Y - gui_offset
                                local menu_pos = menu.AbsolutePosition
                                local menu_size = menu.AbsoluteSize
                                if mp_x < menu_pos.X or mp_x > menu_pos.X + menu_size.X or mp_y < menu_pos.Y or mp_y > menu_pos.Y + menu_size.Y then
                                    close_mode_menu()
                                end
                            end
                        end)
                    end

                    outline.MouseButton2Down:Connect(function()
                        open_mode_menu()
                    end)
                    
                    outline.MouseButton1Down:Connect(function()
                        task.wait()
                        text_label.Text = "[ ... ]"	

                        cfg.binding = library:connection(uis.InputBegan, function(input, game_event)  
                            if game_event then return end
                            local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
                            cfg.set(selected_key)

                            cfg.binding:Disconnect() 
                            cfg.binding = nil
                        end)
                    end)

                    library:connection(uis.InputBegan, function(input, game_event) 
                        if not game_event and not cfg.binding then 
                            local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
                            if selected_key == cfg.key then 
                                if cfg.mode == "toggle" then 
                                    cfg.active = not cfg.active
                                    cfg.set(cfg.active)
                                elseif cfg.mode == "hold" then 
                                    cfg.set(true)
                                end
                            end
                        end
                    end)

                    library:connection(uis.InputEnded, function(input, game_event) 
                        if game_event then 
                            return 
                        end 

                        local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
            
                        if selected_key == cfg.key then
                            if cfg.mode == "hold" then 
                                cfg.set(false)
                            end
                        end
                    end)
            
                    cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
                --      

                cfg.__ui = outline
                    
                config_flags[cfg.flag] = cfg.set

                return setmetatable(cfg, library)
            end

            function library:addList(options)
                local cfg = {
                    callback = options and options.callback or function() end, 
                    name = options.name or nil, 

                    scale = options.size or 232, 
                    items = options.items or {"1", "2", "3"}, 
                    -- order = options.order or 1, 
                    visible = options.visible or true,
            
                    option_instances = {}, 
                    current_instance = nil, 
                    flag = options.flag or "flag", 
            
                }
            
                -- Instances
                    local list_path = library:create("TextLabel", {
                        Parent = self.background or self.elements or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(list_path, "text", "TextColor3")
                    
                    local bottom_components = library:create("Frame", {
                        Parent = list_path,
                        Name = "",
                        Position = dim2(0, 15, 0, cfg.name and 11 or 0),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, self.background and 2 or -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local list = library:create("TextButton", {
                        Parent = bottom_components,
                        Name = "",
                        AutoButtonColor = false, 
                        Text = "",
                        Position = dim2(0, 0, 0, 2),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -27, 0, cfg.scale),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(list, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = list,
                        Name = "",
                        Position = dim2(0, 0, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -1, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.inline
                    }); library:applyTheme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element
                    }); library:applyTheme(background, "element", "BackgroundColor3")         

                    local scrollbar_fill = library:create("Frame", {
                        Parent = background,
                        Name = "",
                        Visible = false, 
                        Size = dim2(0, 5, 1, 0),
                        Position = dim2(1, -5, 0, 0),
                        BorderColor3 = rgb(0, 0, 0),
                        ZIndex = 4,
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element2
                    }); library:applyTheme(scrollbar_fill, "element2", "BackgroundColor3")

                    local ScrollingFrame = library:create("ScrollingFrame", {
                        Parent = background,
                        Name = "",
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 4,
                        BackgroundTransparency = 1,
                        ScrollBarImageColor3 = themes.preset.element2,
                        Size = dim2(1, 0, 1, 0),
                        BackgroundColor3 = rgb(255, 255, 255),
                        BorderColor3 = themes.preset.border,
                        BorderSizePixel = 0,
                        CanvasSize = dim2(0, 0, 0, 0),
                        ZIndex = 999,
                    })

                    local UIPadding = library:create("UIPadding", {
                        Parent = ScrollingFrame,
                        Name = "",
                        PaddingLeft = dim(0, 5),
                        PaddingBottom  = dim(0, 5),
                        PaddingTop  = dim(0, 5),
                        PaddingRight = dim(0, 5)
                    })

                    library:create("UIListLayout", {
                        Parent = ScrollingFrame,
                        Name = "",
                        Padding = dim(0, 5),
                        FillDirection = Enum.FillDirection.Vertical
                    })
                    
                    if cfg.name then 
                        local left_components = library:create("Frame", {
                            Parent = list_path,
                            Name = "",
                            BackgroundTransparency = 1,
                            Position = dim2(0, 16, 0, 1),
                            BorderColor3 = rgb(0, 0, 0),
                            Size = dim2(0, 0, 0, 14),
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        })
                        
                        local text = library:create("TextLabel", {
                            Parent = left_components,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.text,
                            BorderColor3 = rgb(0, 0, 0),
                            Text = cfg.name,
                            BackgroundTransparency = 1,
                            Size = dim2(0, 0, 1, -1),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 12,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(text, "text", "TextColor3")
                        
                        library:create("UIListLayout", {
                            Parent = left_components,
                            Name = "",
                            Padding = dim(0, 5),
                            FillDirection = Enum.FillDirection.Horizontal
                        })
                        
                        library:create("UIPadding", {
                            Parent = left_components,
                            Name = "",
                            PaddingBottom = dim(0, 6)
                        })
                    end 
            
                    -- local UIStroke = library:create("UIStroke", {
                    --     Parent = list,
                    --     Name = ""
                    -- })
                    
                    local UIPadding = library:create("UIPadding", {
                        Parent = list,
                        Name = "",
                        PaddingLeft = dim(0, 1)
                    })
                --      
            
                -- Functions
                    function cfg.render_option(text) 
                        local text = library:create("TextButton", {
                            Parent = ScrollingFrame,
                            Name = "",
                            FontFace = library.font,
                            TextColor3 = themes.preset.unselected,
                            BorderColor3 = themes.preset.border,
                            Text = text,
                            Size = dim2(1, 0, 0, 0),
                            BackgroundTransparency = 1,
                            Position = dim2(0, 7, 0, -1),
                            BorderSizePixel = 0,
                            TextSize = 12,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextXAlignment = Enum.TextXAlignment.Left, 
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }); library:applyTheme(text, "unselected", "TextColor3")       
                
                        return text 
                    end 
                
                    function cfg.refresh_options(options)
                        for _, v in next, cfg.option_instances do 
                            v:Destroy() 
                        end 
                
                        for _, option in next, options do 
                            local button = cfg.render_option(option) 
                
                            insert(cfg.option_instances, button)
                
                            button.MouseButton1Click:Connect(function()
                                if cfg.current_instance and cfg.current_instance ~= button then 
                                    cfg.current_instance.TextColor3 = themes.preset.unselected 
                                end 
                
                                cfg.current_instance = button 
                                button.TextColor3 = themes.preset.accent 
                
                                flags[cfg.flag] = button.text
                                
                                cfg.callback(button.text)
                            end)
                        end 
                    end
                    
                    function cfg.filter_options(text)
                        for _, v in next, cfg.option_instances do 
                            if string.find(v.Text, text) then 
                                v.Visible = true 
                            else 
                                v.Visible = false
                            end
                        end
                    end
            
                    function cfg.set(value)
                        for _, buttons in next, cfg.option_instances do 
                            if buttons.Text == value then 
                                buttons.TextColor3 = themes.preset.accent 
                            else 
                                buttons.TextColor3 = themes.preset.unselected 
                            end 
                        end 
            
                        flags[cfg.flag] = value
                        cfg.callback(value)
                    end 
            
                    cfg.refresh_options(cfg.items) 
                -- 
                    
                -- Connections 
                    ScrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
                        scrollbar_fill.Visible = ScrollingFrame.AbsoluteCanvasSize.Y > background.AbsoluteSize.Y and true or false 
                    end)
                -- 

                library.config_flags[cfg.flag] = cfg.set

                return setmetatable(cfg, library)
            end

            function library:addButton(options)
                local cfg = {
                    callback = options.callback or function() end, 
                    name = options.text or options.name or "Button",
                }

                -- Instances 
                    local button_holder = library:create("TextLabel", {
                        Parent = self.background or self.elements or self.colorpickerElements,
                        Name = "",
                        FontFace = library.font,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = "",
                        ZIndex = 2,
                        Size = dim2(1, -8, 0, 12),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local bottom_components = library:create("Frame", {
                        Parent = button_holder, 
                        Name = "",
                        Position = dim2(0, 14, 0, 0),
                        BorderColor3 = rgb(0, 0, 0),
                        Size = dim2(1, -6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    })
                    
                    local button = library:create("Frame", {
                        Parent = bottom_components,
                        Name = "",
                        Position = dim2(0, -1, 0, 2),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -27, 1, 20),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.outline
                    }); library:applyTheme(button, "outline", "BackgroundColor3")
                    
                    local inline = library:create("Frame", {
                        Parent = button,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.inline
                    }); library:applyTheme(inline, "inline", "BackgroundColor3")
                    
                    local background = library:create("Frame", {
                        Parent = inline,
                        Name = "",
                        Position = dim2(0, 1, 0, 1),
                        BorderColor3 = themes.preset.border,
                        Size = dim2(1, -2, 1, -2),
                        BorderSizePixel = 0,
                        BackgroundColor3 = themes.preset.element
                    }); library:applyTheme(background, "element", "BackgroundColor3")
                    
                    local button = library:create("TextButton", {
                        Parent = background,
                        Name = "",
                        FontFace = library.font,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextSize = 12,
                        Size = dim2(1, -6, 1, 0),
                        RichText = true,
                        TextColor3 = themes.preset.text,
                        BorderColor3 = themes.preset.border,
                        Text = cfg.name,
                        BackgroundTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Position = dim2(0, 6, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(button, "text", "TextColor3")

                    button.MouseButton1Click:Connect(function()
                        cfg.callback() 
                    end)
                    
                    library:create("UIListLayout", {
                        Parent = bottom_components,
                        Name = "",
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    local UIStroke = library:create("UIStroke", {
                        Parent = button_holder,
                        Name = ""
                    })
                    
                    local UIPadding = library:create("UIPadding", {
                        Parent = button_holder,
                        Name = "",
                        PaddingLeft = dim(0, 1)
                    })
                    
                cfg.__ui = button_holder

                return setmetatable(cfg, library)
            end
        -- 
    -- 
-- 

-- Notification Library
    local notifications = library.notifications

    function notifications:refresh_notifs() 
        local settings = library.NotifSettings or {}
        local pos = settings.Position or "Top Right"
        local maxShown = settings.MaxShown or 5
        local viewport = camera.ViewportSize
        local padding = 20
        local yOffset = padding
        local reverse = pos:find("Bottom") ~= nil
        local visibleNotifs = {}
        for i, v in ipairs(notifications.notifs) do
            if v.Parent then
                table.insert(visibleNotifs, v)
            end
        end
        if #visibleNotifs > maxShown then
            for i = maxShown + 1, #visibleNotifs do
                local old = visibleNotifs[i]
                notifications:fade(old, true)
                task.delay(1, function() if old then old:Destroy() end end)
                for idx, n in ipairs(notifications.notifs) do
                    if n == old then table.remove(notifications.notifs, idx) break end
                end
            end
            visibleNotifs = {}
            for i, v in ipairs(notifications.notifs) do
                if v.Parent then table.insert(visibleNotifs, v) end
            end
        end
        if reverse then
            yOffset = viewport.Y - padding
        end
        for i, v in ipairs(visibleNotifs) do
            local xPos = padding
            if pos:find("Right") then
                xPos = viewport.X - v.AbsoluteSize.X - padding
            elseif pos:find("Center") then
                xPos = (viewport.X - v.AbsoluteSize.X) * 0.5
            end
            local yPos = yOffset
            if reverse then
                yPos = yOffset - v.AbsoluteSize.Y
                yOffset = yPos - 10
            else
                yOffset = yOffset + v.AbsoluteSize.Y + 10
            end
            tween_service:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(xPos, yPos)}):Play()
        end
    end
    
    function notifications:fade(path, is_fading)
        local fading = is_fading and 1 or 0 
        
        tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()

        for _, instance in path:GetDescendants() do 
            if instance:IsA("UIStroke") then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = fading}):Play()
            elseif instance:IsA("TextLabel") then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = fading}):Play()
            elseif instance:IsA("Frame") then
                tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()
            end
        end
    end 
    
    function notifications:create_notification(options)
        local settings = library.NotifSettings or {}
        local duration = options.duration or settings.Duration or 3
        local notifType = settings.Type or "Full"
        local animation = settings.Animation or "Slide"
        local cfg = {
            name = options.name or "Hit: q3sm (finobe) in the Head for 100 Damage!",
            outline; 
        }
        
        -- Instances
            local outline = library:create("Frame", {
                Parent = library.gui;
                Size = dim2(0, 0, 0, 0);
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = themes.preset.outline;
                ZIndex = 999;
            }); library:applyTheme(outline, "outline", "BackgroundColor3")

            local inline = library:create("Frame", {
                Parent = outline;
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = themes.preset.inline
            }); library:applyTheme(inline, "inline", "BackgroundColor3")
            
            local background = library:create("Frame", {
                Parent = inline;
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AutomaticSize = Enum.AutomaticSize.XY;
                BackgroundColor3 = themes.preset.background
            }); library:applyTheme(background, "background", "BackgroundColor3")
            
            library:create("UIPadding", {
                PaddingTop = dim(0, 7);
                PaddingBottom = dim(0, 6);
                Parent = background;
                PaddingRight = dim(0, 8);
                PaddingLeft = dim(0, 4)
            });
            
            local notifText = notifType == "Text" and cfg.name or string.format("[ alternate.lol ] %s", cfg.name)
            local misc_text = library:create("TextLabel", {
                FontFace = library.font;
                Parent = background;
                LineHeight = 1.75;
                TextColor3 = themes.preset.text;
                BorderColor3 = rgb(0, 0, 0);
                Text = notifText;
                AutomaticSize = Enum.AutomaticSize.XY;
                Size = dim2(1, -4, 1, 0);
                Position = dim2(0, 4, 0, -2);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                ZIndex = 2;
                TextSize = 12;
                BackgroundColor3 = rgb(255, 255, 255)
            }); library:applyTheme(misc_text, "text", "TextColor3")
            
            library:create("UIPadding", {
                PaddingBottom = dim(0, 1);
                PaddingRight = dim(0, 1);
                Parent = outline
            });

            local line = library:create( "Frame" , {
                Parent = outline;
                Name = "\0";
                Position = dim2(0, 1, 1, -1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 0, 0, 1);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            }); library:applyTheme(line, "accent", "BackgroundColor3")
            
            local accent = library:create( "Frame" , {
                Parent = outline;
                Name = "\0";
                Position = dim2(0, 1, 0, 1);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 1, 1, -1);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            }); library:applyTheme(accent, "accent", "BackgroundColor3")
        -- 
        
        local index = #notifications.notifs + 1
        notifications.notifs[index] = outline
        
        local pos = (library.NotifSettings or {}).Position or "Top Right"
        local viewport = camera.ViewportSize
        local startX, startY = 20, 20
        if pos:find("Right") then
            startX = viewport.X + 300
        elseif pos:find("Center") then
            startX = viewport.X * 0.5
        end
        if pos:find("Bottom") then
            startY = viewport.Y
        end
        outline.Position = dim_offset(startX, startY)

        if animation == "Fade" then
            outline.BackgroundTransparency = 1
            for _, inst in outline:GetDescendants() do
                if inst:IsA("TextLabel") then inst.TextTransparency = 1
                elseif inst:IsA("Frame") then inst.BackgroundTransparency = 1
                elseif inst:IsA("UIStroke") then inst.Transparency = 1 end
            end
        elseif animation == "Pop" then
            outline.Size = dim2(0, 0, 0, 0)
            outline.AnchorPoint = vec2(0.5, 0.5)
        end

        notifications:refresh_notifs()

        if animation == "Slide" then
            notifications:fade(outline, false)
        elseif animation == "Fade" then
            notifications:fade(outline, false)
        elseif animation == "Pop" then
            tween_service:Create(outline, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = dim2(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY}):Play()
            notifications:fade(outline, false)
        end

        task.spawn(function()
            tween_service:Create(line, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = dim2(1, -1, 0, 1)}):Play()
            task.wait(duration)
            notifications.notifs[index] = nil
            notifications:fade(outline, true)
            task.wait(1)
            outline:Destroy() 
            notifications:refresh_notifs()
        end)
    end
-- 

function library:watermark(options)
    local wm = library:create("Frame", {
        Parent = library.gui,
        Size = dim2(0, 200, 0, 25),
        Position = dim2(0, 20, 0, 20),
        BackgroundColor3 = themes.preset.outline,
        BorderSizePixel = 0,
        ZIndex = 999
    }); library:applyTheme(wm, "outline", "BackgroundColor3")
    local wm_glow = library:create("ImageLabel", {
        Parent = wm,
        Name = "",
        ImageColor3 = themes.preset.glow or themes.preset.accent,
        ScaleType = Enum.ScaleType.Slice,
        BackgroundColor3 = rgb(255, 255, 255),
        Visible = true,
        Image = "rbxassetid://110204605000367",
        BackgroundTransparency = 1,
        ImageTransparency = 0.8,
        Position = dim2(0, -15, 0, -15),
        Size = dim2(1, 30, 1, 30),
        ZIndex = 998,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79)),
        ResampleMode = Enum.ResamplerMode.Pixelated
    }); library:applyTheme(wm_glow, "glow", "ImageColor3")
    local wm_inline = library:create("Frame", {
        Parent = wm,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.inline,
        BorderSizePixel = 0
    }); library:applyTheme(wm_inline, "inline", "BackgroundColor3")
    local wm_bg = library:create("Frame", {
        Parent = wm_inline,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.background,
        BorderSizePixel = 0
    }); library:applyTheme(wm_bg, "background", "BackgroundColor3")
    local wm_text = library:create("TextLabel", {
        Parent = wm_bg,
        Text = " " .. (options.name or "alternate.lol"),
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        BorderSizePixel = 0
    }); library:applyTheme(wm_text, "text", "TextColor3")
    local accentLine = library:create("Frame", {
        Parent = wm,
        Size = dim2(1, 0, 0, 2),
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0
    })
    library:applyTheme(accentLine, "accent", "BackgroundColor3")
    library:draggify(wm)

    task.spawn(function()
        local fpsCount = 0
        local fpsTime = tick()
        local lastFps = 60
        local rsConn
        rsConn = run.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            fpsCount = fpsCount + 1
        end))
        insert(library.connections, rsConn)
        while wm and wm.Parent do
            local now = tick()
            if now - fpsTime >= 1 then
                lastFps = math.round(fpsCount / (now - fpsTime))
                fpsCount = 0
                fpsTime = now
            end
            task.wait(0.5)
            if wm_text and wm_text.Parent then
                local players = #game:GetService("Players"):GetPlayers()
                local time = os.date("%H:%M:%S")
                wm_text.Text = string.format(" %s | FPS: %d | Players: %d | %s", options.name or "alternate.lol", lastFps, players, time)
                local bounds = wm_text.TextBounds
                wm.Size = dim2(0, math.max(bounds.X + 8, 120), 0, 25)
            end
        end
        if rsConn then rsConn:Disconnect() end
    end)

    return wm
end

function library:targetHud(options)
    local hud = library:create("Frame", {
        Parent = library.gui,
        Size = dim2(0, 280, 0, 100),
        Position = dim2(0.5, 100, 0.5, 0),
        BackgroundColor3 = themes.preset.outline,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 999
    }); library:applyTheme(hud, "outline", "BackgroundColor3")
    local hud_glow = library:create("ImageLabel", {
        Parent = hud,
        Name = "",
        ImageColor3 = themes.preset.glow or themes.preset.accent,
        ScaleType = Enum.ScaleType.Slice,
        BackgroundColor3 = rgb(255, 255, 255),
        Visible = true,
        Image = "rbxassetid://110204605000367",
        BackgroundTransparency = 1,
        ImageTransparency = 0.8,
        Position = dim2(0, -15, 0, -15),
        Size = dim2(1, 30, 1, 30),
        ZIndex = 998,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79)),
        ResampleMode = Enum.ResamplerMode.Pixelated
    }); library:applyTheme(hud_glow, "glow", "ImageColor3")
    local hud_inline = library:create("Frame", {
        Parent = hud,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.inline,
        BorderSizePixel = 0
    }); library:applyTheme(hud_inline, "inline", "BackgroundColor3")
    local hud_bg = library:create("Frame", {
        Parent = hud_inline,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.background,
        BorderSizePixel = 0
    }); library:applyTheme(hud_bg, "background", "BackgroundColor3")
    local accentBar = library:create("Frame", {
        Parent = hud,
        Size = dim2(0, 3, 1, 0),
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        ZIndex = 3
    })
    library:applyTheme(accentBar, "accent", "BackgroundColor3")

    local avatar = library:create("ImageLabel", {
        Parent = hud_bg,
        Size = dim2(0, 56, 0, 56),
        Position = dim2(0, 10, 0, 10),
        BackgroundColor3 = rgb(20, 20, 20),
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = 2
    })
    local avatar_stroke = library:create("UIStroke", {
        Parent = avatar,
        Color = themes.preset.accent,
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    library:applyTheme(avatar_stroke, "accent", "Color")
    library:create("UICorner", {
        Parent = avatar,
        CornerRadius = dim(0, 6)
    })

    local display_name = library:create("TextLabel", {
        Parent = hud_bg,
        Text = "",
        Size = dim2(1, -84, 0, 18),
        Position = dim2(0, 74, 0, 10),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2
    }); library:applyTheme(display_name, "text", "TextColor3")
    local username = library:create("TextLabel", {
        Parent = hud_bg,
        Text = "",
        Size = dim2(1, -84, 0, 14),
        Position = dim2(0, 74, 0, 28),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.unselected,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2
    }); library:applyTheme(username, "unselected", "TextColor3")

    local info_row = library:create("Frame", {
        Parent = hud_bg,
        Size = dim2(1, -84, 0, 14),
        Position = dim2(0, 74, 0, 44),
        BackgroundTransparency = 1,
        ZIndex = 2
    })
    local dist_label = library:create("TextLabel", {
        Parent = info_row,
        Text = "Dist:",
        Size = dim2(0, 30, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.unselected,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        TextSize = 11,
        ZIndex = 2
    }); library:applyTheme(dist_label, "unselected", "TextColor3")
    local dist_text = library:create("TextLabel", {
        Parent = info_row,
        Text = "0",
        Size = dim2(0, 50, 1, 0),
        Position = dim2(0, 28, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = library.font,
        TextSize = 11,
        ZIndex = 2
    }); library:applyTheme(dist_text, "text", "TextColor3")

    local hp_bar_bg = library:create("Frame", {
        Parent = hud_bg,
        Size = dim2(1, -20, 0, 6),
        Position = dim2(0, 10, 1, -24),
        BackgroundColor3 = rgb(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    library:create("UIStroke", {
        Parent = hp_bar_bg,
        Color = rgb(40, 40, 40),
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Miter
    })
    local hp_bar_fill = library:create("Frame", {
        Parent = hp_bar_bg,
        Size = dim2(1, 0, 1, 0),
        BackgroundColor3 = rgb(0, 255, 0),
        BorderSizePixel = 0,
        ZIndex = 3
    })

    local hp_text = library:create("TextLabel", {
        Parent = hud_bg,
        Text = "100/100",
        Size = dim2(0, 80, 0, 14),
        Position = dim2(1, -90, 1, -42),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.text,
        TextXAlignment = Enum.TextXAlignment.Right,
        FontFace = library.font,
        TextSize = 11,
        ZIndex = 2
    }); library:applyTheme(hp_text, "text", "TextColor3")

    library:draggify(hud)

    local currentTarget = nil
    local hudObj = {
        Items = { Container = hud },
        SetVisibility = function(self, v)
            hud.Visible = v
        end,
        SetTarget = function(self, target)
            currentTarget = target
            if not target then
                hud.Visible = false
                return
            end
            hud.Visible = true
            local isPlayer = target:IsA("Player")
            local char = isPlayer and target.Character or target
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            local avatarEnabled = library.flags["TargetHUDAvatar"] ~= false
            avatar.Visible = avatarEnabled
            local offset = avatarEnabled and 74 or 14
            display_name.Position = dim2(0, offset, 0, 10)
            display_name.Size = dim2(1, -offset - 10, 0, 18)
            username.Position = dim2(0, offset, 0, 28)
            username.Size = dim2(1, -offset - 10, 0, 14)
            info_row.Position = dim2(0, offset, 0, 44)
            info_row.Size = dim2(1, -offset - 10, 0, 14)

            if isPlayer then
                display_name.Text = target.DisplayName
                username.Text = "@" .. target.Name
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. target.UserId .. "&w=48&h=48"
            else
                display_name.Text = target.Name
                username.Text = "Model"
                avatar.Image = ""
            end

            if humanoid then
                local hp = math.floor(humanoid.Health)
                local maxHp = math.floor(humanoid.MaxHealth)
                hp_text.Text = tostring(hp) .. "/" .. tostring(maxHp)
                local ratio = math.clamp(hp, 0, maxHp) / math.max(maxHp, 1)
                hp_bar_fill.Size = dim2(ratio, 0, 1, 0)
                if ratio > 0.5 then
                    hp_bar_fill.BackgroundColor3 = rgb(0, 255, 0)
                elseif ratio > 0.25 then
                    hp_bar_fill.BackgroundColor3 = rgb(255, 170, 0)
                else
                    hp_bar_fill.BackgroundColor3 = rgb(255, 0, 0)
                end
            else
                hp_text.Text = "N/A"
                hp_bar_fill.Size = dim2(0, 0, 1, 0)
            end

            if root then
                local dist = math.floor((workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude)
                dist_text.Text = tostring(dist) .. " studs"
            else
                dist_text.Text = "N/A"
            end
        end,
        Update = function(self)
            if currentTarget and hud.Visible then
                self:SetTarget(currentTarget)
            end
        end
    }

    library:connection(run.RenderStepped, LPH_NO_VIRTUALIZE(function()
        hudObj:Update()
    end))

    return hudObj
end

function library:keybindList(options)
    local kl = library:create("Frame", {
        Parent = library.gui,
        Size = dim2(0, 180, 0, 25),
        Position = dim2(0, 20, 0, 200),
        BackgroundColor3 = themes.preset.outline,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 999
    }); library:applyTheme(kl, "outline", "BackgroundColor3")
    local kl_glow = library:create("ImageLabel", {
        Parent = kl,
        Name = "",
        ImageColor3 = themes.preset.glow or themes.preset.accent,
        ScaleType = Enum.ScaleType.Slice,
        BackgroundColor3 = rgb(255, 255, 255),
        Visible = true,
        Image = "rbxassetid://110204605000367",
        BackgroundTransparency = 1,
        ImageTransparency = 0.8,
        Position = dim2(0, -15, 0, -15),
        Size = dim2(1, 30, 1, 30),
        ZIndex = 998,
        BorderSizePixel = 0,
        SliceCenter = rect(vec2(21, 21), vec2(79, 79)),
        ResampleMode = Enum.ResamplerMode.Pixelated
    }); library:applyTheme(kl_glow, "glow", "ImageColor3")
    local kl_inline = library:create("Frame", {
        Parent = kl,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.inline,
        BorderSizePixel = 0
    }); library:applyTheme(kl_inline, "inline", "BackgroundColor3")
    local kl_bg = library:create("Frame", {
        Parent = kl_inline,
        Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2),
        BackgroundColor3 = themes.preset.background,
        BorderSizePixel = 0
    }); library:applyTheme(kl_bg, "background", "BackgroundColor3")
    local title = library:create("TextLabel", {
        Parent = kl_bg,
        Text = "Keybinds",
        Size = dim2(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        FontFace = library.font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = false
    })
    library:applyTheme(title, "accent", "TextColor3")

    local accentLine = library:create("Frame", {
        Parent = kl,
        Size = dim2(1, 0, 0, 2),
        Position = dim2(0, 0, 0, 0),
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0
    })
    library:applyTheme(accentLine, "accent", "BackgroundColor3")

    local list_holder = library:create("Frame", {
        Parent = kl_bg,
        Name = "",
        BackgroundTransparency = 1,
        Position = dim2(0, 4, 0, 22),
        Size = dim2(1, -4, 0, 0),
        BorderSizePixel = 0,
        BackgroundColor3 = rgb(255, 255, 255)
    })
    library:create("UIListLayout", {
        Parent = list_holder,
        Padding = dim(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical
    })

    library:draggify(kl)

    task.spawn(LPH_NO_VIRTUALIZE(function()
        while not library.unloaded and task.wait(0.2) do
            for _, child in ipairs(list_holder:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            local active_count = 0
            for flag, data in pairs(flags) do
                if type(data) == "table" and data.Key and data.Toggled and not tostring(flag):find("^_") then
                    active_count = active_count + 1
                    local key_display = keys[data.Key] or tostring(data.Key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
                    local mode_display = data.mode and string.upper(string.sub(data.mode, 1, 1)) .. string.sub(data.mode, 2) or "Toggle"
                    local entry = library:create("TextLabel", {
                        Parent = list_holder,
                        Text = string.format("%s [%s] [%s]", tostring(data.name or flag), key_display, mode_display),
                        FontFace = library.font,
                        TextColor3 = themes.preset.unselected,
                        BackgroundTransparency = 1,
                        Size = dim2(1, 0, 0, 14),
                        Position = dim2(0, 0, 0, 0),
                        BorderSizePixel = 0,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 11,
                        BackgroundColor3 = rgb(255, 255, 255)
                    }); library:applyTheme(entry, "unselected", "TextColor3")
                end
            end
            kl.Size = dim2(0, 180, 0, 25 + (active_count * 16))
        end
    end))

    return kl
end

function library:subtab(properties)
    local cfg = {
        name = properties.name or properties.Name or "subtab",
        icon = properties.icon or properties.Icon,
    }
    
    local parent_tab = self
    if properties.parent then
        parent_tab = properties.parent
    end
    
    if not parent_tab.subtab_shell then
        local layout = parent_tab.page:FindFirstChildWhichIsA("UIListLayout")
        if layout then
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.Padding = dim(0, 8)
            layout.HorizontalFlex = Enum.UIFlexAlignment.None
            layout.VerticalFlex = Enum.UIFlexAlignment.None
        end

        parent_tab.subtab_shell = library:create("Frame", {
            Parent = parent_tab.page,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 0, 34)
        })

        local subtab_bg = library:create("Frame", {
            Parent = parent_tab.subtab_shell,
            BorderSizePixel = 0,
            Size = dim2(1, 0, 1, 0),
            BackgroundColor3 = themes.preset.element
        })
        library:applyTheme(subtab_bg, "element", "BackgroundColor3")

        local subtab_inline = library:create("Frame", {
            Parent = subtab_bg,
            Position = dim2(0, 1, 0, 1),
            Size = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = themes.preset.background
        })
        library:applyTheme(subtab_inline, "background", "BackgroundColor3")

        parent_tab.subtab_holder = library:create("Frame", {
            Parent = subtab_inline,
            BackgroundTransparency = 1,
            Position = dim2(0, 8, 0, 0),
            Size = dim2(1, -16, 1, 0)
        })
        library:create("UIListLayout", {
            Parent = parent_tab.subtab_holder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = dim(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        parent_tab.subpage_holder = library:create("Frame", {
            Parent = parent_tab.page,
            BackgroundTransparency = 1,
            Size = dim2(1, 0, 1, -42)
        })
        library:create("UIPadding", {
            Parent = parent_tab.subpage_holder,
            PaddingTop = dim(0, 0)
        })
    end
    
    local btn = library:create("TextButton", {
        Parent = parent_tab.subtab_holder,
        Text = "",
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = dim2(0, 0, 1, 0),
        BorderSizePixel = 0
    })

    local label = library:create("TextLabel", {
        Parent = btn,
        Text = cfg.name,
        FontFace = library.font,
        TextSize = 12,
        TextColor3 = themes.preset.unselected,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = dim2(0, 0, 1, 0),
        BorderSizePixel = 0
    }); library:applyTheme(label, "unselected", "TextColor3")

    local underline = library:create("Frame", {
        Parent = btn,
        BackgroundColor3 = themes.preset.accent,
        BorderSizePixel = 0,
        Size = dim2(1, 0, 0, 2),
        Position = dim2(0, 0, 1, -2),
        Visible = false
    })
    library:applyTheme(underline, "accent", "BackgroundColor3")
    
    cfg.page = library:create("Frame", {
        Parent = parent_tab.subpage_holder,
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        Visible = false
    })
    library:create("UIListLayout", {
        Parent = cfg.page,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
        Padding = dim(0, 11),
        VerticalFlex = Enum.UIFlexAlignment.Fill
    })
    
    function cfg.open_subtab()
        if parent_tab.selected_subtab then
            parent_tab.selected_subtab.label.TextColor3 = themes.preset.unselected
            parent_tab.selected_subtab.underline.Visible = false
            parent_tab.selected_subtab.page.Visible = false
        end
        label.TextColor3 = themes.preset.accent
        underline.Visible = true
        cfg.page.Visible = true
        parent_tab.selected_subtab = {label = label, underline = underline, page = cfg.page}
    end
    
    btn.MouseButton1Down:Connect(cfg.open_subtab)
    if not parent_tab.selected_subtab then
        cfg.open_subtab()
    end
    
    return setmetatable(cfg, library)
end

return library, notifications, themes
