-- AUTO-EXECUTE SETUP
if not getgenv().BridgeDuelsAutoFarmLoaded then
    getgenv().BridgeDuelsAutoFarmLoaded = true
    
    print("🔄 First time setup - Saving to autoexec...")
    
    -- Guardar este script para auto-execute
    if writefile and isfolder then
        task.spawn(function()
            pcall(function()
                -- Verificar si existe carpeta autoexec
                if not isfolder("autoexec") then
                    makefolder("autoexec")
                end
                
                -- Descargar el script desde GitHub
                local scriptURL = "https://raw.githubusercontent.com/altgrinder999/AutoFarm/main/script.lua"
                local scriptContent = game:HttpGet(scriptURL)
                
                -- Guardarlo en autoexec
                writefile("autoexec/bridge_duels_autofarm.lua", scriptContent)
                print("✅ Script saved to autoexec! Will auto-run on next game load.")
            end)
        end)
    else
        warn("⚠️ Your executor doesn't support file functions. Auto-execute won't work.")
    end
end

-- ESPERAR A QUE TODO CARGUE COMPLETAMENTE
repeat task.wait() until game:IsLoaded()
task.wait(3)

-- Servicios
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Esperar a que el jugador cargue completamente
repeat task.wait() until player.Character
task.wait(2)

-- WEBHOOK DE DISCORD
local webhookURL = "https://discord.com/api/webhooks/1472828293513220187/VwrS5wzxn_RzjPaL6t531-CIxlX-RUBGVXMgFem0Fad8nX7DBzhURj9wv5PJXNTcy98X"

-- Variable para tiempo de inicio
local startTime = os.time()

-- Variable para contar victorias (cargar desde archivo)
local totalWins = 0
local saveFileName = "autofarm_wins.txt"

-- Cargar victorias guardadas
if isfile and readfile then
    local success, savedWins = pcall(function()
        return readfile(saveFileName)
    end)
    
    if success and savedWins then
        totalWins = tonumber(savedWins) or 0
        print("✅ Wins loaded:", totalWins)
    else
        print("⚠️ No saved wins, starting from 0")
    end
else
    warn("⚠️ Your executor doesn't support writefile/readfile. Wins won't be saved.")
end

-- Función para guardar victorias
local function saveWins()
    if writefile then
        local success = pcall(function()
            writefile(saveFileName, tostring(totalWins))
        end)
        
        if success then
            print("💾 Wins saved:", totalWins)
        end
    end
end

-- Función para calcular tiempo transcurrido
local function getElapsedTime()
    local elapsed = os.time() - startTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = elapsed % 60
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds)
    else
        return string.format("%ds", seconds)
    end
end

-- Función para obtener nombre del lugar
local function getPlaceStatus(placeId)
    if placeId == 6872265039 then
        return "Lobby"
    elseif placeId == 8560631822 then
        return "In-Game"
    else
        return "Unknown"
    end
end

-- Función para enviar embed a Discord
local function sendDiscordEmbed(wins)
    local currentPlaceId = game.PlaceId
    local placeStatus = getPlaceStatus(currentPlaceId)
    
    local success, err = pcall(function()
        local embed = {
            ["embeds"] = {{
                ["title"] = "🔥 Victory Registered!",
                ["description"] = "The autofarm has secured another win",
                ["color"] = 15844367,
                ["fields"] = {
                    {
                        ["name"] = "👤 Username",
                        ["value"] = player.Name,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🏆 Total Wins",
                        ["value"] = tostring(wins),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⏱️ Running Time",
                        ["value"] = getElapsedTime(),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "📍 Place Status",
                        ["value"] = placeStatus,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🎮 Game",
                        ["value"] = "Bridge Duels",
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "AutoFarm by generacyan"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        
        local response = request({
            Url = webhookURL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(embed)
        })
        
        if response.StatusCode == 204 then
            print("✅ Embed sent to Discord")
        end
    end)
end

-- Función de animación smooth
local function smoothTween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- ScreenGui principal (PANTALLA COMPLETA)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Blur de fondo (efecto glassmorphism)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

-- Contenedor principal FULLSCREEN
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = ScreenGui
MainContainer.Position = UDim2.new(0, 0, 0, 0)
MainContainer.Size = UDim2.new(1, 0, 1, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainContainer.BackgroundTransparency = 0.05
MainContainer.BorderSizePixel = 0
MainContainer.ZIndex = 1

-- Gradiente de fondo fullscreen
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
}
MainGradient.Rotation = 135
MainGradient.Parent = MainContainer

-- Header fullscreen
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainContainer
Header.Size = UDim2.new(1, 0, 0, 80)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.ZIndex = 2

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Color3.fromRGB(80, 80, 100)
HeaderStroke.Thickness = 1
HeaderStroke.Transparency = 0.8
HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
HeaderStroke.Parent = Header

-- Logo/Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.Position = UDim2.new(0, 30, 0, 0)
TitleLabel.Size = UDim2.new(0, 400, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚔️ BRIDGE DUELS AUTOFARM"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 28
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.8
TitleLabel.ZIndex = 3

-- Versión badge
local VersionBadge = Instance.new("Frame")
VersionBadge.Parent = Header
VersionBadge.Position = UDim2.new(1, -150, 0.5, -18)
VersionBadge.Size = UDim2.new(0, 130, 0, 36)
VersionBadge.BackgroundColor3 = Color3.fromRGB(100, 80, 255)
VersionBadge.BackgroundTransparency = 0.2
VersionBadge.BorderSizePixel = 0
VersionBadge.ZIndex = 3

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 18)
VersionCorner.Parent = VersionBadge

local VersionText = Instance.new("TextLabel")
VersionText.Parent = VersionBadge
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Font = Enum.Font.GothamBold
VersionText.Text = "v1.1 BETA"
VersionText.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionText.TextSize = 16
VersionText.ZIndex = 4

-- Content Container (centrado)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainContainer
ContentContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ContentContainer.Position = UDim2.new(0.5, 0, 0.5, 20)
ContentContainer.Size = UDim2.new(0, 900, 0, 700)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 2

-- Stats Container (Cards modernas)
local StatsContainer = Instance.new("Frame")
StatsContainer.Name = "StatsContainer"
StatsContainer.Parent = ContentContainer
StatsContainer.Position = UDim2.new(0, 0, 0, 0)
StatsContainer.Size = UDim2.new(1, 0, 0, 140)
StatsContainer.BackgroundTransparency = 1
StatsContainer.ZIndex = 3

-- Card de Wins
local WinsCard = Instance.new("Frame")
WinsCard.Parent = StatsContainer
WinsCard.Position = UDim2.new(0, 0, 0, 0)
WinsCard.Size = UDim2.new(0.48, 0, 1, 0)
WinsCard.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
WinsCard.BackgroundTransparency = 0.2
WinsCard.BorderSizePixel = 0
WinsCard.ZIndex = 4

local WinsCardCorner = Instance.new("UICorner")
WinsCardCorner.CornerRadius = UDim.new(0, 20)
WinsCardCorner.Parent = WinsCard

local WinsCardStroke = Instance.new("UIStroke")
WinsCardStroke.Color = Color3.fromRGB(255, 165, 0)
WinsCardStroke.Thickness = 3
WinsCardStroke.Transparency = 0.5
WinsCardStroke.Parent = WinsCard

local WinsIcon = Instance.new("TextLabel")
WinsIcon.Parent = WinsCard
WinsIcon.Position = UDim2.new(0, 20, 0, 15)
WinsIcon.Size = UDim2.new(0, 40, 0, 40)
WinsIcon.BackgroundTransparency = 1
WinsIcon.Font = Enum.Font.GothamBold
WinsIcon.Text = "🏆"
WinsIcon.TextSize = 32
WinsIcon.ZIndex = 5

local WinsTitle = Instance.new("TextLabel")
WinsTitle.Parent = WinsCard
WinsTitle.Position = UDim2.new(0, 20, 0, 60)
WinsTitle.Size = UDim2.new(1, -40, 0, 25)
WinsTitle.BackgroundTransparency = 1
WinsTitle.Font = Enum.Font.Gotham
WinsTitle.Text = "TOTAL WINS"
WinsTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
WinsTitle.TextSize = 14
WinsTitle.TextXAlignment = Enum.TextXAlignment.Left
WinsTitle.ZIndex = 5

local WinsValue = Instance.new("TextLabel")
WinsValue.Parent = WinsCard
WinsValue.Position = UDim2.new(0, 20, 0, 85)
WinsValue.Size = UDim2.new(1, -40, 0, 40)
WinsValue.BackgroundTransparency = 1
WinsValue.Font = Enum.Font.GothamBold
WinsValue.Text = tostring(totalWins)
WinsValue.TextColor3 = Color3.fromRGB(255, 165, 0)
WinsValue.TextSize = 36
WinsValue.TextXAlignment = Enum.TextXAlignment.Left
WinsValue.ZIndex = 5

-- Card de Time
local TimeCard = Instance.new("Frame")
TimeCard.Parent = StatsContainer
TimeCard.Position = UDim2.new(0.52, 0, 0, 0)
TimeCard.Size = UDim2.new(0.48, 0, 1, 0)
TimeCard.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TimeCard.BackgroundTransparency = 0.2
TimeCard.BorderSizePixel = 0
TimeCard.ZIndex = 4

local TimeCardCorner = Instance.new("UICorner")
TimeCardCorner.CornerRadius = UDim.new(0, 20)
TimeCardCorner.Parent = TimeCard

local TimeCardStroke = Instance.new("UIStroke")
TimeCardStroke.Color = Color3.fromRGB(100, 180, 255)
TimeCardStroke.Thickness = 3
TimeCardStroke.Transparency = 0.5
TimeCardStroke.Parent = TimeCard

local TimeIcon = Instance.new("TextLabel")
TimeIcon.Parent = TimeCard
TimeIcon.Position = UDim2.new(0, 20, 0, 15)
TimeIcon.Size = UDim2.new(0, 40, 0, 40)
TimeIcon.BackgroundTransparency = 1
TimeIcon.Font = Enum.Font.GothamBold
TimeIcon.Text = "⏱️"
TimeIcon.TextSize = 32
TimeIcon.ZIndex = 5

local TimeTitle = Instance.new("TextLabel")
TimeTitle.Parent = TimeCard
TimeTitle.Position = UDim2.new(0, 20, 0, 60)
TimeTitle.Size = UDim2.new(1, -40, 0, 25)
TimeTitle.BackgroundTransparency = 1
TimeTitle.Font = Enum.Font.Gotham
TimeTitle.Text = "RUNTIME"
TimeTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
TimeTitle.TextSize = 14
TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
TimeTitle.ZIndex = 5

local TimeValue = Instance.new("TextLabel")
TimeValue.Parent = TimeCard
TimeValue.Position = UDim2.new(0, 20, 0, 85)
TimeValue.Size = UDim2.new(1, -40, 0, 40)
TimeValue.BackgroundTransparency = 1
TimeValue.Font = Enum.Font.GothamBold
TimeValue.Text = "0s"
TimeValue.TextColor3 = Color3.fromRGB(100, 180, 255)
TimeValue.TextSize = 36
TimeValue.TextXAlignment = Enum.TextXAlignment.Left
TimeValue.ZIndex = 5

-- Avatar Container moderno
local AvatarContainer = Instance.new("Frame")
AvatarContainer.Parent = ContentContainer
AvatarContainer.Position = UDim2.new(0, 0, 0, 160)
AvatarContainer.Size = UDim2.new(1, 0, 0, 280)
AvatarContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
AvatarContainer.BackgroundTransparency = 0.2
AvatarContainer.BorderSizePixel = 0
AvatarContainer.ZIndex = 3

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 20)
AvatarCorner.Parent = AvatarContainer

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(100, 100, 120)
AvatarStroke.Thickness = 2
AvatarStroke.Transparency = 0.6
AvatarStroke.Parent = AvatarContainer

-- Avatar Image
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AvatarContainer
AvatarImage.Position = UDim2.new(0, 25, 0, 25)
AvatarImage.Size = UDim2.new(0, 230, 0, 230)
AvatarImage.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AvatarImage.BorderSizePixel = 0
AvatarImage.ScaleType = Enum.ScaleType.Crop
AvatarImage.ZIndex = 4

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(0, 16)
AvatarImageCorner.Parent = AvatarImage

-- Username display
local UsernameContainer = Instance.new("Frame")
UsernameContainer.Parent = AvatarContainer
UsernameContainer.Position = UDim2.new(0, 280, 0, 25)
UsernameContainer.Size = UDim2.new(1, -305, 0, 230)
UsernameContainer.BackgroundTransparency = 1
UsernameContainer.ZIndex = 4

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = UsernameContainer
UsernameLabel.Size = UDim2.new(1, 0, 0, 35)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.Text = "USERNAME"
UsernameLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
UsernameLabel.TextSize = 16
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.ZIndex = 5

local UsernameValue = Instance.new("TextLabel")
UsernameValue.Parent = UsernameContainer
UsernameValue.Position = UDim2.new(0, 0, 0, 45)
UsernameValue.Size = UDim2.new(1, 0, 0, 70)
UsernameValue.BackgroundTransparency = 1
UsernameValue.Font = Enum.Font.GothamBold
UsernameValue.Text = "[HIDDEN]"
UsernameValue.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameValue.TextSize = 28
UsernameValue.TextXAlignment = Enum.TextXAlignment.Left
UsernameValue.TextWrapped = true
UsernameValue.ZIndex = 5

-- Show/Hide Username Button moderno
local ShowUsernameBtn = Instance.new("TextButton")
ShowUsernameBtn.Parent = UsernameContainer
ShowUsernameBtn.Position = UDim2.new(0, 0, 1, -65)
ShowUsernameBtn.Size = UDim2.new(1, 0, 0, 60)
ShowUsernameBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
ShowUsernameBtn.BackgroundTransparency = 0.2
ShowUsernameBtn.BorderSizePixel = 0
ShowUsernameBtn.Font = Enum.Font.GothamBold
ShowUsernameBtn.Text = "🔒 SHOW USERNAME"
ShowUsernameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowUsernameBtn.TextSize = 18
ShowUsernameBtn.AutoButtonColor = false
ShowUsernameBtn.ZIndex = 5

local ShowBtnCorner = Instance.new("UICorner")
ShowBtnCorner.CornerRadius = UDim.new(0, 12)
ShowBtnCorner.Parent = ShowUsernameBtn

-- Timer Container moderno
local TimerContainer = Instance.new("Frame")
TimerContainer.Parent = ContentContainer
TimerContainer.Position = UDim2.new(0, 0, 0, 460)
TimerContainer.Size = UDim2.new(1, 0, 0, 110)
TimerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TimerContainer.BackgroundTransparency = 0.2
TimerContainer.BorderSizePixel = 0
TimerContainer.ZIndex = 3

local TimerCorner = Instance.new("UICorner")
TimerCorner.CornerRadius = UDim.new(0, 20)
TimerCorner.Parent = TimerContainer

local TimerStroke = Instance.new("UIStroke")
TimerStroke.Color = Color3.fromRGB(255, 215, 0)
TimerStroke.Thickness = 3
TimerStroke.Transparency = 0.4
TimerStroke.Parent = TimerContainer

local TimerGradient = Instance.new("UIGradient")
TimerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 0))
}
TimerGradient.Rotation = 45
TimerGradient.Transparency = NumberSequence.new(0.9)
TimerGradient.Parent = TimerContainer

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Parent = TimerContainer
TimerLabel.Size = UDim2.new(1, 0, 1, 0)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Font = Enum.Font.GothamBold
TimerLabel.Text = "⏳ Winning In: 20s"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.TextSize = 32
TimerLabel.ZIndex = 4

-- Botones de control modernos
local ControlsContainer = Instance.new("Frame")
ControlsContainer.Parent = ContentContainer
ControlsContainer.Position = UDim2.new(0, 0, 0, 590)
ControlsContainer.Size = UDim2.new(1, 0, 0, 90)
ControlsContainer.BackgroundTransparency = 1
ControlsContainer.ZIndex = 3

-- Botón Close moderno
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = ControlsContainer
CloseBtn.Position = UDim2.new(0, 0, 0, 0)
CloseBtn.Size = UDim2.new(0.48, 0, 1, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✖ MINIMIZE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 16)
CloseBtnCorner.Parent = CloseBtn

-- Botón Reset moderno
local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = ControlsContainer
ResetBtn.Position = UDim2.new(0.52, 0, 0, 0)
ResetBtn.Size = UDim2.new(0.48, 0, 1, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ResetBtn.BackgroundTransparency = 0.2
ResetBtn.BorderSizePixel = 0
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Text = "🔄 RESET WINS"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 20
ResetBtn.AutoButtonColor = false
ResetBtn.ZIndex = 4

local ResetBtnCorner = Instance.new("UICorner")
ResetBtnCorner.CornerRadius = UDim.new(0, 16)
ResetBtnCorner.Parent = ResetBtn

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Parent = MainContainer
Footer.Position = UDim2.new(0, 0, 1, -35)
Footer.Size = UDim2.new(1, 0, 0, 35)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.Gotham
Footer.Text = "made by generacyan"
Footer.TextColor3 = Color3.fromRGB(100, 100, 110)
Footer.TextSize = 14
Footer.ZIndex = 4

-- Botón para reabrir (minimizado)
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Parent = ScreenGui
ReopenBtn.Position = UDim2.new(0.02, 0, 0.5, -35)
ReopenBtn.Size = UDim2.new(0, 70, 0, 70)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
ReopenBtn.BackgroundTransparency = 0.1
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.Text = "⚔️"
ReopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ReopenBtn.TextSize = 32
ReopenBtn.AutoButtonColor = false
ReopenBtn.Visible = false
ReopenBtn.ZIndex = 10

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(1, 0)
ReopenCorner.Parent = ReopenBtn

local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = Color3.fromRGB(100, 100, 255)
ReopenStroke.Thickness = 4
ReopenStroke.Parent = ReopenBtn

-- Cargar avatar
task.spawn(function()
    local success, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    
    if success then
        AvatarImage.Image = thumbnail
    end
end)

-- Actualizar tiempo en loop
task.spawn(function()
    while true do
        TimeValue.Text = getElapsedTime()
        task.wait(1)
    end
end)

-- Funcionalidad de botones con animaciones
local showing = false
ShowUsernameBtn.MouseButton1Click:Connect(function()
    showing = not showing
    smoothTween(ShowUsernameBtn, {BackgroundColor3 = Color3.fromRGB(90, 90, 255)}, 0.2)
    task.wait(0.1)
    smoothTween(ShowUsernameBtn, {BackgroundColor3 = Color3.fromRGB(70, 70, 255)}, 0.2)
    
    if showing then
        UsernameValue.Text = player.Name
        ShowUsernameBtn.Text = "🔓 HIDE USERNAME"
    else
        UsernameValue.Text = "[HIDDEN]"
        ShowUsernameBtn.Text = "🔒 SHOW USERNAME"
    end
end)

CloseBtn.MouseEnter:Connect(function()
    smoothTween(CloseBtn, {BackgroundTransparency = 0}, 0.2)
end)

CloseBtn.MouseLeave:Connect(function()
    smoothTween(CloseBtn, {BackgroundTransparency = 0.2}, 0.2)
end)

CloseBtn.MouseButton1Click:Connect(function()
    smoothTween(MainContainer, {BackgroundTransparency = 1}, 0.3)
    smoothTween(BlurEffect, {Size = 0}, 0.3)
    for _, child in pairs(MainContainer:GetDescendants()) do
        if child:IsA("GuiObject") then
            smoothTween(child, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        end
    end
    task.wait(0.3)
    MainContainer.Visible = false
    ReopenBtn.Visible = true
    ReopenBtn.Size = UDim2.new(0, 0, 0, 0)
    smoothTween(ReopenBtn, {Size = UDim2.new(0, 70, 0, 70)}, 0.3)
end)

ResetBtn.MouseEnter:Connect(function()
    smoothTween(ResetBtn, {BackgroundTransparency = 0
