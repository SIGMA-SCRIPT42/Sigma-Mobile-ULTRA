-- Sigma Mobile ULTRA v2.5 (Delta Android - Fixed Buttons)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Лёгкое шифрование ключей (ROT13)
local function SimpleEncrypt(str)
    local encoded = ""
    for i = 1, #str do
        local c = str:sub(i,i)
        local byte = string.byte(c)
        if byte >= 65 and byte <= 90 then
            c = string.char(((byte - 65 + 13) % 26) + 65)
        elseif byte >= 97 and byte <= 122 then
            c = string.char(((byte - 97 + 13) % 26) + 97)
        end
        encoded = encoded .. c
    end
    return encoded
end

-- Ключи системы
local KEY_SYSTEM = {
    ValidKeys = {
        SimpleEncrypt("SIGMA777"), 
        SimpleEncrypt("DELTA777"), 
        SimpleEncrypt("MOBILE777")
    },
    Whitelist = {"gibroshka", "chubakka33"}
}

-- Цветовые темы
local COLOR_THEMES = {
    {
        name = "Чёрный (по умолчанию)",
        backgroundColor = Color3.fromRGB(15, 15, 25),
        buttonColor = Color3.fromRGB(40, 40, 50),
        activeColor = Color3.fromRGB(70, 70, 90),
        accentColor = Color3.fromRGB(100, 100, 255)
    },
    {
        name = "Бордовый",
        backgroundColor = Color3.fromRGB(25, 10, 10),
        buttonColor = Color3.fromRGB(50, 20, 20),
        activeColor = Color3.fromRGB(90, 30, 30),
        accentColor = Color3.fromRGB(180, 50, 50)
    },
    {
        name = "Аметистовый",
        backgroundColor = Color3.fromRGB(20, 10, 25),
        buttonColor = Color3.fromRGB(40, 20, 50),
        activeColor = Color3.fromRGB(70, 30, 90),
        accentColor = Color3.fromRGB(150, 50, 200)
    },
    {
        name = "Тёмно-синий",
        backgroundColor = Color3.fromRGB(10, 10, 25),
        buttonColor = Color3.fromRGB(20, 20, 50),
        activeColor = Color3.fromRGB(30, 30, 90),
        accentColor = Color3.fromRGB(50, 50, 200)
    }
}

local currentTheme = 1
local UI_Settings = COLOR_THEMES[currentTheme]

-- Все функции меню
local functions = {
    FPSBoost = {enabled = false, level = 3},
    RainbowChar = {enabled = false, speed = 0.1},
    ESP = {enabled = false, teamCheck = true, color = Color3.new(1,0.5,0)},
    NoClip = {enabled = false, connection = nil},
    SpeedHack = {enabled = false, speed = 32},
    AntiAFK = {enabled = false, connection = nil},
    Fly = {enabled = false, speed = 25, bodyVelocity = nil, connection = nil},
    FullBright = {enabled = false, original = Lighting.Brightness},
    AutoFarm = {enabled = false, range = 50, connection = nil}
}

-- Создаем интерфейс
local SigmaUI = Instance.new("ScreenGui")
SigmaUI.Name = "SigmaMobileULTRA_"..tostring(math.random(1,10000))
SigmaUI.Parent = CoreGui
SigmaUI.ResetOnSpawn = false

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.6, 0, 0.75, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = UI_Settings.backgroundColor
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = SigmaUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.05, 0)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UI_Settings.accentColor
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0.01, 0)
Title.Text = "Σ SIGMA ULTRA v2.5"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = MainFrame

-- Анимация заголовка
coroutine.wrap(function()
    while Title and Title.Parent do
        local hue = tick() % 5 / 5
        Title.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        task.wait(0.3)
    end
end)()

-- Основное меню
local MainScrollFrame = Instance.new("ScrollingFrame")
MainScrollFrame.Name = "MainScroll"
MainScrollFrame.Size = UDim2.new(1, -10, 0.85, 0)
MainScrollFrame.Position = UDim2.new(0, 5, 0.12, 0)
MainScrollFrame.BackgroundTransparency = 1
MainScrollFrame.ScrollBarThickness = 4
MainScrollFrame.ScrollBarImageColor3 = UI_Settings.accentColor
MainScrollFrame.Visible = true
MainScrollFrame.Parent = MainFrame

-- Меню настроек
local SettingsScrollFrame = Instance.new("ScrollingFrame")
SettingsScrollFrame.Name = "SettingsScroll"
SettingsScrollFrame.Size = UDim2.new(1, -10, 0.85, 0)
SettingsScrollFrame.Position = UDim2.new(0, 5, 0.12, 0)
SettingsScrollFrame.BackgroundTransparency = 1
SettingsScrollFrame.ScrollBarThickness = 4
SettingsScrollFrame.ScrollBarImageColor3 = UI_Settings.accentColor
SettingsScrollFrame.Visible = false
SettingsScrollFrame.Parent = MainFrame

-- Активатор меню (изначально скрыт)
local activator = Instance.new("TextButton")
activator.Size = UDim2.new(0.12, 0, 0.08, 0)
activator.Position = UDim2.new(0.02, 0, 0.88, 0)
activator.Text = "Σ"
activator.Font = Enum.Font.SourceSansBold
activator.TextSize = 24
activator.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
activator.TextColor3 = Color3.new(1,1,1)
activator.Visible = false
activator.Parent = SigmaUI

local activatorCorner = Instance.new("UICorner")
activatorCorner.CornerRadius = UDim.new(0.3, 0)
activatorCorner.Parent = activator

activator.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 1. Функция FPS Boost
local function ToggleFPSBoost()
    functions.FPSBoost.enabled = not functions.FPSBoost.enabled
    if functions.FPSBoost.enabled then
        settings().Rendering.QualityLevel = functions.FPSBoost.level
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 10000
    else
        settings().Rendering.QualityLevel = 10
        Lighting.GlobalShadows = true
    end
end

-- 2. Функция Rainbow Character
local function ToggleRainbowChar()
    functions.RainbowChar.enabled = not functions.RainbowChar.enabled
    if functions.RainbowChar.enabled then
        coroutine.wrap(function()
            while functions.RainbowChar.enabled and LocalPlayer.Character do
                local hue = tick() * functions.RainbowChar.speed % 1
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        pcall(function() part.Color = Color3.fromHSV(hue, 1, 1) end)
                    end
                end
                task.wait()
            end
        end)()
    end
end

-- 3. Функция ESP
local ESPCache = {}
local function ToggleESP()
    functions.ESP.enabled = not functions.ESP.enabled
    
    local function CreateESP(player)
        if ESPCache[player] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "SigmaESP"
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = functions.ESP.color
        highlight.OutlineTransparency = 0
        
        local function CharacterAdded(char)
            highlight.Adornee = char
            ESPCache[player] = highlight
        end
        
        if player.Character then
            CharacterAdded(player.Character)
        end
        player.CharacterAdded:Connect(CharacterAdded)
    end

    if functions.ESP.enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        Players.PlayerAdded:Connect(CreateESP)
    else
        for _, player in pairs(ESPCache) do
            if player then player:Destroy() end
        end
        table.clear(ESPCache)
    end
end

-- 4. Функция NoClip
local function ToggleNoClip()
    functions.NoClip.enabled = not functions.NoClip.enabled
    if functions.NoClip.enabled then
        functions.NoClip.connection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif functions.NoClip.connection then
        functions.NoClip.connection:Disconnect()
        functions.NoClip.connection = nil
    end
end

-- 5. Функция Speed Hack
local function ToggleSpeedHack()
    functions.SpeedHack.enabled = not functions.SpeedHack.enabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = functions.SpeedHack.enabled and functions.SpeedHack.speed or 16
    end
end

-- 6. Функция Anti-AFK
local function ToggleAntiAFK()
    functions.AntiAFK.enabled = not functions.AntiAFK.enabled
    if functions.AntiAFK.enabled then
        functions.AntiAFK.connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                LocalPlayer:RequestMove()
            end)
        end)
    elseif functions.AntiAFK.connection then
        functions.AntiAFK.connection:Disconnect()
        functions.AntiAFK.connection = nil
    end
end

-- 7. Функция Fly
local function ToggleFly()
    functions.Fly.enabled = not functions.Fly.enabled
    
    if functions.Fly.enabled then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            functions.Fly.bodyVelocity = Instance.new("BodyVelocity")
            functions.Fly.bodyVelocity.Velocity = Vector3.new()
            functions.Fly.bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            functions.Fly.bodyVelocity.P = 1000
            functions.Fly.bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            
            functions.Fly.connection = RunService.Heartbeat:Connect(function()
                if not functions.Fly.enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if functions.Fly.connection then
                        functions.Fly.connection:Disconnect()
                        functions.Fly.connection = nil
                    end
                    return
                end
                
                local velocity = Vector3.new(0, functions.Fly.speed/2, 0)
                functions.Fly.bodyVelocity.Velocity = velocity
                functions.Fly.bodyVelocity.MaxForce = Vector3.new(0, 1, 0) * 10000
            end)
        end
    else
        if functions.Fly.bodyVelocity then
            functions.Fly.bodyVelocity:Destroy()
            functions.Fly.bodyVelocity = nil
        end
        if functions.Fly.connection then
            functions.Fly.connection:Disconnect()
            functions.Fly.connection = nil
        end
    end
end

-- 8. Функция FullBright
local function ToggleFullBright()
    functions.FullBright.enabled = not functions.FullBright.enabled
    if functions.FullBright.enabled then
        functions.FullBright.original = Lighting.Brightness
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = functions.FullBright.original
        Lighting.FogEnd = 10000
    end
end

-- 9. Функция AutoFarm
local function ToggleAutoFarm()
    functions.AutoFarm.enabled = not functions.AutoFarm.enabled
    
    if functions.AutoFarm.enabled then
        functions.AutoFarm.connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not LocalPlayer.Character then return end
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:FindFirstChild("ClickDetector") and (root.Position - obj.Position).Magnitude <= functions.AutoFarm.range then
                        fireclickdetector(obj.ClickDetector)
                    end
                end
            end)
        end)
    elseif functions.AutoFarm.connection then
        functions.AutoFarm.connection:Disconnect()
        functions.AutoFarm.connection = nil
    end
end

-- Создание кнопок
local buttonY = 0.01
local buttonHeight = 0.08
local buttonMargin = 0.01

local function CreateToggleButton(text, icon, toggleFunc, parentFrame)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.95, 0, buttonHeight, 0)
    button.Position = UDim2.new(0.025, 0, buttonY, 0)
    button.Text = icon .. " " .. text
    button.TextSize = 16
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = UI_Settings.buttonColor
    button.Parent = parentFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.2, 0)
    UICorner.Parent = button
    
    local status = Instance.new("TextLabel")
    status.Text = functions[text].enabled and "ON" or "OFF"
    status.TextColor3 = functions[text].enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
    status.Size = UDim2.new(0.3, 0, 1, 0)
    status.Position = UDim2.new(0.65, 0, 0, 0)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.SourceSansBold
    status.TextSize = 14
    status.Parent = button
    
    button.MouseButton1Click:Connect(function()
        toggleFunc()
        status.Text = functions[text].enabled and "ON" or "OFF"
        status.TextColor3 = functions[text].enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
        button.BackgroundColor3 = functions[text].enabled and UI_Settings.activeColor or UI_Settings.buttonColor
    end)
    
    buttonY = buttonY + buttonHeight + buttonMargin
    return button
end

-- Создаем кнопки в главном меню
buttonY = 0.01
CreateToggleButton("FPSBoost", "⚡", ToggleFPSBoost, MainScrollFrame)
CreateToggleButton("RainbowChar", "🌈", ToggleRainbowChar, MainScrollFrame)
CreateToggleButton("ESP", "👁️", ToggleESP, MainScrollFrame)
CreateToggleButton("NoClip", "👻", ToggleNoClip, MainScrollFrame)
CreateToggleButton("SpeedHack", "🏃", ToggleSpeedHack, MainScrollFrame)
CreateToggleButton("AntiAFK", "🛡️", ToggleAntiAFK, MainScrollFrame)
CreateToggleButton("Fly", "✈️", ToggleFly, MainScrollFrame)
CreateToggleButton("FullBright", "💡", ToggleFullBright, MainScrollFrame)
CreateToggleButton("AutoFarm", "🤖", ToggleAutoFarm, MainScrollFrame)

-- Кнопка телепорта
local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(0.95, 0, buttonHeight, 0)
tpFrame.Position = UDim2.new(0.025, 0, buttonY, 0)
tpFrame.BackgroundColor3 = UI_Settings.buttonColor
tpFrame.Parent = MainScrollFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.2, 0)
UICorner.Parent = tpFrame

local tpInput = Instance.new("TextBox")
tpInput.PlaceholderText = "Ник игрока"
tpInput.Size = UDim2.new(0.6, 0, 0.8, 0)
tpInput.Position = UDim2.new(0.05, 0, 0.1, 0)
tpInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tpInput.TextColor3 = Color3.new(1,1,1)
tpInput.Parent = tpFrame

local tpButton = Instance.new("TextButton")
tpButton.Text = "📌 Телепорт"
tpButton.TextSize = 14
tpButton.TextColor3 = Color3.new(1,1,1)
tpButton.Size = UDim2.new(0.3, 0, 0.8, 0)
tpButton.Position = UDim2.new(0.65, 0, 0.1, 0)
tpButton.BackgroundColor3 = UI_Settings.activeColor
tpButton.Parent = tpFrame

tpButton.MouseButton1Click:Connect(function()
    local target = Players:FindFirstChild(tpInput.Text)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

buttonY = buttonY + buttonHeight + buttonMargin

-- Кнопка настроек
local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(0.95, 0, buttonHeight, 0)
settingsButton.Position = UDim2.new(0.025, 0, buttonY, 0)
settingsButton.Text = "⚙️ Настройки"
settingsButton.TextSize = 16
settingsButton.TextColor3 = Color3.new(1,1,1)
settingsButton.BackgroundColor3 = UI_Settings.buttonColor
settingsButton.Parent = MainScrollFrame

settingsButton.MouseButton1Click:Connect(function()
    MainScrollFrame.Visible = false
    SettingsScrollFrame.Visible = true
    Title.Text = "Σ НАСТРОЙКИ"
end)

buttonY = buttonY + buttonHeight + buttonMargin
MainScrollFrame.CanvasSize = UDim2.new(0, 0, 0, buttonY * 1000)

-- Меню настроек
buttonY = 0.01

-- Кнопка смены темы
local themeButton = Instance.new("TextButton")
themeButton.Size = UDim2.new(0.95, 0, buttonHeight, 0)
themeButton.Position = UDim2.new(0.025, 0, buttonY, 0)
themeButton.Text = "🎨 Тема: "..COLOR_THEMES[currentTheme].name
themeButton.TextSize = 16
themeButton.TextColor3 = Color3.new(1,1,1)
themeButton.BackgroundColor3 = UI_Settings.buttonColor
themeButton.Parent = SettingsScrollFrame

local themePreview = Instance.new("Frame")
themePreview.Size = UDim2.new(0.1, 0, 0.8, 0)
themePreview.Position = UDim2.new(0.8, 0, 0.1, 0)
themePreview.BackgroundColor3 = UI_Settings.backgroundColor
themePreview.Parent = themeButton

local themeCorner = Instance.new("UICorner")
themeCorner.Parent = themePreview

themeButton.MouseButton1Click:Connect(function()
    currentTheme = currentTheme % #COLOR_THEMES + 1
    UI_Settings = COLOR_THEMES[currentTheme]
    
    -- Обновляем тему интерфейса
    MainFrame.BackgroundColor3 = UI_Settings.backgroundColor
    MainFrame.UIStroke.Color = UI_Settings.accentColor
    MainScrollFrame.ScrollBarImageColor3 = UI_Settings.accentColor
    SettingsScrollFrame.ScrollBarImageColor3 = UI_Settings.accentColor
    themeButton.Text = "🎨 Тема: "..COLOR_THEMES[currentTheme].name
    themePreview.BackgroundColor3 = UI_Settings.backgroundColor
    
    -- Обновляем все кнопки
    for _, button in ipairs(MainScrollFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = UI_Settings.buttonColor
            button.TextColor3 = Color3.new(1,1,1)
        end
    end
    
    for _, button in ipairs(SettingsScrollFrame:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = UI_Settings.buttonColor
            button.TextColor3 = Color3.new(1,1,1)
        end
    end
    
    -- Обновляем кнопку телепорта
    tpFrame.BackgroundColor3 = UI_Settings.buttonColor
    tpButton.BackgroundColor3 = UI_Settings.activeColor
end)

buttonY = buttonY + buttonHeight + buttonMargin

-- Кнопка Telegram
local tgButton = Instance.new("TextButton")
tgButton.Size = UDim2.new(0.95, 0, buttonHeight, 0)
tgButton.Position = UDim2.new(0.025, 0, buttonY, 0)
tgButton.Text = "📢 Получить ключ (Telegram)"
tgButton.TextSize = 14
tgButton.TextColor3 = Color3.new(1,1,1)
tgButton.BackgroundColor3 = UI_Settings.buttonColor
tgButton.Parent = SettingsScrollFrame

tgButton.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard("https://t.me/gibroshka_sigma")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Ссылка скопирована",
            Text = "Перейдите в Telegram для получения ключа",
            Duration = 3
        })
    end)
end)

buttonY = buttonY + buttonHeight + buttonMargin

-- Кнопка назад
local backButton = Instance.new("TextButton")
backButton.Size = UDim2.new(0.95, 0, buttonHeight, 0)
backButton.Position = UDim2.new(0.025, 0, buttonY, 0)
backButton.Text = "⬅️ Назад"
backButton.TextSize = 16
backButton.TextColor3 = Color3.new(1,1,1)
backButton.BackgroundColor3 = UI_Settings.buttonColor
backButton.Parent = SettingsScrollFrame

backButton.MouseButton1Click:Connect(function()
    MainScrollFrame.Visible = true
    SettingsScrollFrame.Visible = false
    Title.Text = "Σ SIGMA ULTRA v2.5"
end)

buttonY = buttonY + buttonHeight + buttonMargin
SettingsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, buttonY * 1000)

-- Проверка доступа
local function CheckAccess()
    -- Проверка вайтлиста
    for _, name in ipairs(KEY_SYSTEM.Whitelist) do
        if LocalPlayer.Name:lower() == name:lower() then
            MainFrame.Visible = true
            activator.Visible = true
            return true
        end
    end
    
    -- Окно активации
    local activationUI = Instance.new("Frame")
    activationUI.Size = UDim2.new(0.5, 0, 0.4, 0)
    activationUI.Position = UDim2.new(0.25, 0, 0.3, 0)
    activationUI.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    activationUI.Parent = SigmaUI
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.05, 0)
    UICorner.Parent = activationUI
    
    local title = Instance.new("TextLabel")
    title.Text = "АКТИВАЦИЯ SIGMA"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = activationUI
    
    local inputBox = Instance.new("TextBox")
    inputBox.PlaceholderText = "Введите ключ доступа"
    inputBox.Size = UDim2.new(0.8, 0, 0.15, 0)
    inputBox.Position = UDim2.new(0.1, 0, 0.25, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    inputBox.TextColor3 = Color3.new(1,1,1)
    inputBox.Parent = activationUI
    
    local activateBtn = Instance.new("TextButton")
    activateBtn.Text = "АКТИВИРОВАТЬ"
    activateBtn.Size = UDim2.new(0.6, 0, 0.15, 0)
    activateBtn.Position = UDim2.new(0.2, 0, 0.45, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    activateBtn.Parent = activationUI
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Text = "ПОЛУЧИТЬ КЛЮЧ"
    getKeyBtn.Size = UDim2.new(0.6, 0, 0.15, 0)
    getKeyBtn.Position = UDim2.new(0.2, 0, 0.65, 0)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    getKeyBtn.Parent = activationUI
    
    activateBtn.MouseButton1Click:Connect(function()
        local enteredKey = inputBox.Text
        local valid = false
        
        for _, key in ipairs(KEY_SYSTEM.ValidKeys) do
            if SimpleEncrypt(enteredKey) == key or enteredKey == SimpleEncrypt(key) then
                valid = true
                break
            end
        end
        
        if valid then
            activationUI:Destroy()
            MainFrame.Visible = true
            activator.Visible = true
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Успешно",
                Text = "Добро пожаловать в Sigma ULTRA!",
                Duration = 3
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Ошибка",
                Text = "Неверный ключ доступа",
                Duration = 3
            })
        end
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://t.me/gibroshka_sigma")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Ссылка скопирована",
                Text = "Перейдите в Telegram для получения ключа",
                Duration = 3
            })
        end)
    end)
    
    return false
end

-- Восстановление функций после смерти
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    
    -- Восстановление SpeedHack
    if functions.SpeedHack.enabled then
        task.wait(0.5)
        if character and character:FindFirstChildOfClass("Humanoid") then
            character.Humanoid.WalkSpeed = functions.SpeedHack.speed
        end
    end
    
    -- Восстановление Fly
    if functions.Fly.enabled then
        ToggleFly()
        task.wait(0.1)
        ToggleFly()
    end
    
    -- Восстановление RainbowChar
    if functions.RainbowChar.enabled then
        ToggleRainbowChar()
        task.wait(0.1)
        ToggleRainbowChar()
    end
end)

-- Запуск проверки доступа
coroutine.wrap(CheckAccess)()

-- Уведомление о загрузке
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Sigma ULTRA v2.5",
    Text = "Введите ключ для активации",
    Duration = 3
})
