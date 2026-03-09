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
local webhookURL = "https://discord.com/api/webhooks/1480662208470843473/-QuDvIwsx-npvlQxkpAL4dPHS7xwcM6AMpSoptRYt06oblRWRq_Gla7p0spTCn8P7IIH"

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

-- ScreenGui principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Blur de fondo (efecto glassmorphism)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

-- Contenedor principal moderno
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = ScreenGui
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.Size = UDim2.new(0, 480, 0, 620)
MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainContainer.BackgroundTransparency = 0.1
MainContainer.BorderSizePixel = 0
MainContainer.ZIndex = 2

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 24)
MainCorner.Parent = MainContainer

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 100, 120)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.7
MainStroke.Parent = MainContainer

-- Gradiente sutil de fondo
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
MainGradient.Rotation = 135
MainGradient.Parent = MainContainer

-- Header moderno
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainContainer
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Header.BackgroundTransparency = 0.3
Header.BorderSizePixel = 0
Header.ZIndex = 3

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 24)
HeaderCorner.Parent = Header

-- Logo/Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚔️ BRIDGE DUELS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.8
TitleLabel.ZIndex = 4

-- Versión badge
local VersionBadge = Instance.new("Frame")
VersionBadge.Parent = Header
VersionBadge.Position = UDim2.new(1, -130, 0.5, -15)
VersionBadge.Size = UDim2.new(0, 110, 0, 30)
VersionBadge.BackgroundColor3 = Color3.fromRGB(100, 80, 255)
VersionBadge.BackgroundTransparency = 0.2
VersionBadge.BorderSizePixel = 0
VersionBadge.ZIndex = 4

local VersionCorner = Instance.new("UICorner")
VersionCorner.CornerRadius = UDim.new(0, 15)
VersionCorner.Parent = VersionBadge

local VersionText = Instance.new("TextLabel")
VersionText.Parent = VersionBadge
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Font = Enum.Font.GothamBold
VersionText.Text = "v1.1 BETA"
VersionText.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionText.TextSize = 13
VersionText.ZIndex = 5

-- Stats Container (Cards modernas)
local StatsContainer = Instance.new("Frame")
StatsContainer.Name = "StatsContainer"
StatsContainer.Parent = MainContainer
StatsContainer.Position = UDim2.new(0, 20, 0, 90)
StatsContainer.Size = UDim2.new(1, -40, 0, 100)
StatsContainer.BackgroundTransparency = 1
StatsContainer.ZIndex = 3

-- Card de Wins
local WinsCard = Instance.new("Frame")
WinsCard.Parent = StatsContainer
WinsCard.Position = UDim2.new(0, 0, 0, 0)
WinsCard.Size = UDim2.new(0.48, 0, 1, 0)
WinsCard.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
WinsCard.BackgroundTransparency = 0.3
WinsCard.BorderSizePixel = 0
WinsCard.ZIndex = 4

local WinsCardCorner = Instance.new("UICorner")
WinsCardCorner.CornerRadius = UDim.new(0, 16)
WinsCardCorner.Parent = WinsCard

local WinsCardStroke = Instance.new("UIStroke")
WinsCardStroke.Color = Color3.fromRGB(255, 165, 0)
WinsCardStroke.Thickness = 2
WinsCardStroke.Transparency = 0.6
WinsCardStroke.Parent = WinsCard

local WinsIcon = Instance.new("TextLabel")
WinsIcon.Parent = WinsCard
WinsIcon.Position = UDim2.new(0, 15, 0, 10)
WinsIcon.Size = UDim2.new(0, 30, 0, 30)
WinsIcon.BackgroundTransparency = 1
WinsIcon.Font = Enum.Font.GothamBold
WinsIcon.Text = "🏆"
WinsIcon.TextSize = 24
WinsIcon.ZIndex = 5

local WinsTitle = Instance.new("TextLabel")
WinsTitle.Parent = WinsCard
WinsTitle.Position = UDim2.new(0, 15, 0, 45)
WinsTitle.Size = UDim2.new(1, -30, 0, 20)
WinsTitle.BackgroundTransparency = 1
WinsTitle.Font = Enum.Font.Gotham
WinsTitle.Text = "TOTAL WINS"
WinsTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
WinsTitle.TextSize = 12
WinsTitle.TextXAlignment = Enum.TextXAlignment.Left
WinsTitle.ZIndex = 5

local WinsValue = Instance.new("TextLabel")
WinsValue.Parent = WinsCard
WinsValue.Position = UDim2.new(0, 15, 0, 65)
WinsValue.Size = UDim2.new(1, -30, 0, 25)
WinsValue.BackgroundTransparency = 1
WinsValue.Font = Enum.Font.GothamBold
WinsValue.Text = tostring(totalWins)
WinsValue.TextColor3 = Color3.fromRGB(255, 165, 0)
WinsValue.TextSize = 28
WinsValue.TextXAlignment = Enum.TextXAlignment.Left
WinsValue.ZIndex = 5

-- Card de Time
local TimeCard = Instance.new("Frame")
TimeCard.Parent = StatsContainer
TimeCard.Position = UDim2.new(0.52, 0, 0, 0)
TimeCard.Size = UDim2.new(0.48, 0, 1, 0)
TimeCard.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TimeCard.BackgroundTransparency = 0.3
TimeCard.BorderSizePixel = 0
TimeCard.ZIndex = 4

local TimeCardCorner = Instance.new("UICorner")
TimeCardCorner.CornerRadius = UDim.new(0, 16)
TimeCardCorner.Parent = TimeCard

local TimeCardStroke = Instance.new("UIStroke")
TimeCardStroke.Color = Color3.fromRGB(100, 180, 255)
TimeCardStroke.Thickness = 2
TimeCardStroke.Transparency = 0.6
TimeCardStroke.Parent = TimeCard

local TimeIcon = Instance.new("TextLabel")
TimeIcon.Parent = TimeCard
TimeIcon.Position = UDim2.new(0, 15, 0, 10)
TimeIcon.Size = UDim2.new(0, 30, 0, 30)
TimeIcon.BackgroundTransparency = 1
TimeIcon.Font = Enum.Font.GothamBold
TimeIcon.Text = "⏱️"
TimeIcon.TextSize = 24
TimeIcon.ZIndex = 5

local TimeTitle = Instance.new("TextLabel")
TimeTitle.Parent = TimeCard
TimeTitle.Position = UDim2.new(0, 15, 0, 45)
TimeTitle.Size = UDim2.new(1, -30, 0, 20)
TimeTitle.BackgroundTransparency = 1
TimeTitle.Font = Enum.Font.Gotham
TimeTitle.Text = "RUNTIME"
TimeTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
TimeTitle.TextSize = 12
TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
TimeTitle.ZIndex = 5

local TimeValue = Instance.new("TextLabel")
TimeValue.Parent = TimeCard
TimeValue.Position = UDim2.new(0, 15, 0, 65)
TimeValue.Size = UDim2.new(1, -30, 0, 25)
TimeValue.BackgroundTransparency = 1
TimeValue.Font = Enum.Font.GothamBold
TimeValue.Text = "0s"
TimeValue.TextColor3 = Color3.fromRGB(100, 180, 255)
TimeValue.TextSize = 28
TimeValue.TextXAlignment = Enum.TextXAlignment.Left
TimeValue.ZIndex = 5

-- Avatar Container moderno
local AvatarContainer = Instance.new("Frame")
AvatarContainer.Parent = MainContainer
AvatarContainer.Position = UDim2.new(0, 20, 0, 210)
AvatarContainer.Size = UDim2.new(1, -40, 0, 200)
AvatarContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AvatarContainer.BackgroundTransparency = 0.3
AvatarContainer.BorderSizePixel = 0
AvatarContainer.ZIndex = 3

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 16)
AvatarCorner.Parent = AvatarContainer

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(100, 100, 120)
AvatarStroke.Thickness = 1
AvatarStroke.Transparency = 0.7
AvatarStroke.Parent = AvatarContainer

-- Avatar Image
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Parent = AvatarContainer
AvatarImage.Position = UDim2.new(0, 15, 0, 15)
AvatarImage.Size = UDim2.new(0, 170, 0, 170)
AvatarImage.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
AvatarImage.BorderSizePixel = 0
AvatarImage.ScaleType = Enum.ScaleType.Crop
AvatarImage.ZIndex = 4

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(0, 12)
AvatarImageCorner.Parent = AvatarImage

-- Username display
local UsernameContainer = Instance.new("Frame")
UsernameContainer.Parent = AvatarContainer
UsernameContainer.Position = UDim2.new(0, 200, 0, 15)
UsernameContainer.Size = UDim2.new(1, -215, 0, 170)
UsernameContainer.BackgroundTransparency = 1
UsernameContainer.ZIndex = 4

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = UsernameContainer
UsernameLabel.Size = UDim2.new(1, 0, 0, 30)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.Text = "USERNAME"
UsernameLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
UsernameLabel.TextSize = 12
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.ZIndex = 5

local UsernameValue = Instance.new("TextLabel")
UsernameValue.Parent = UsernameContainer
UsernameValue.Position = UDim2.new(0, 0, 0, 35)
UsernameValue.Size = UDim2.new(1, 0, 0, 50)
UsernameValue.BackgroundTransparency = 1
UsernameValue.Font = Enum.Font.GothamBold
UsernameValue.Text = "[HIDDEN]"
UsernameValue.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameValue.TextSize = 20
UsernameValue.TextXAlignment = Enum.TextXAlignment.Left
UsernameValue.TextWrapped = true
UsernameValue.ZIndex = 5

-- Show/Hide Username Button moderno
local ShowUsernameBtn = Instance.new("TextButton")
ShowUsernameBtn.Parent = UsernameContainer
ShowUsernameBtn.Position = UDim2.new(0, 0, 1, -50)
ShowUsernameBtn.Size = UDim2.new(1, 0, 0, 45)
ShowUsernameBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
ShowUsernameBtn.BackgroundTransparency = 0.2
ShowUsernameBtn.BorderSizePixel = 0
ShowUsernameBtn.Font = Enum.Font.GothamBold
ShowUsernameBtn.Text = "🔒 SHOW"
ShowUsernameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowUsernameBtn.TextSize = 14
ShowUsernameBtn.AutoButtonColor = false
ShowUsernameBtn.ZIndex = 5

local ShowBtnCorner = Instance.new("UICorner")
ShowBtnCorner.CornerRadius = UDim.new(0, 10)
ShowBtnCorner.Parent = ShowUsernameBtn

-- Timer Container moderno
local TimerContainer = Instance.new("Frame")
TimerContainer.Parent = MainContainer
TimerContainer.Position = UDim2.new(0, 20, 0, 430)
TimerContainer.Size = UDim2.new(1, -40, 0, 80)
TimerContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TimerContainer.BackgroundTransparency = 0.3
TimerContainer.BorderSizePixel = 0
TimerContainer.ZIndex = 3

local TimerCorner = Instance.new("UICorner")
TimerCorner.CornerRadius = UDim.new(0, 16)
TimerCorner.Parent = TimerContainer

local TimerStroke = Instance.new("UIStroke")
TimerStroke.Color = Color3.fromRGB(255, 215, 0)
TimerStroke.Thickness = 2
TimerStroke.Transparency = 0.5
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
TimerLabel.TextSize = 24
TimerLabel.ZIndex = 4

-- Botones de control modernos
local ControlsContainer = Instance.new("Frame")
ControlsContainer.Parent = MainContainer
ControlsContainer.Position = UDim2.new(0, 20, 0, 530)
ControlsContainer.Size = UDim2.new(1, -40, 0, 70)
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
CloseBtn.Text = "✖ CLOSE"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 12)
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
ResetBtn.Text = "🔄 RESET"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 16
ResetBtn.AutoButtonColor = false
ResetBtn.ZIndex = 4

local ResetBtnCorner = Instance.new("UICorner")
ResetBtnCorner.CornerRadius = UDim.new(0, 12)
ResetBtnCorner.Parent = ResetBtn

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Parent = MainContainer
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.BackgroundTransparency = 1
Footer.Font = Enum.Font.Gotham
Footer.Text = "made by generacyan"
Footer.TextColor3 = Color3.fromRGB(100, 100, 110)
Footer.TextSize = 11
Footer.ZIndex = 4

-- Botón para reabrir (minimizado)
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Parent = ScreenGui
ReopenBtn.Position = UDim2.new(0.02, 0, 0.5, -30)
ReopenBtn.Size = UDim2.new(0, 60, 0, 60)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
ReopenBtn.BackgroundTransparency = 0.1
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.Text = "⚔️"
ReopenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ReopenBtn.TextSize = 28
ReopenBtn.AutoButtonColor = false
ReopenBtn.Visible = false
ReopenBtn.ZIndex = 10

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(1, 0)
ReopenCorner.Parent = ReopenBtn

local ReopenStroke = Instance.new("UIStroke")
ReopenStroke.Color = Color3.fromRGB(100, 100, 255)
ReopenStroke.Thickness = 3
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
        ShowUsernameBtn.Text = "🔓 HIDE"
    else
        UsernameValue.Text = "[HIDDEN]"
        ShowUsernameBtn.Text = "🔒 SHOW"
    end
end)

CloseBtn.MouseEnter:Connect(function()
    smoothTween(CloseBtn, {BackgroundTransparency = 0}, 0.2)
end)

CloseBtn.MouseLeave:Connect(function()
    smoothTween(CloseBtn, {BackgroundTransparency = 0.2}, 0.2)
end)

CloseBtn.MouseButton1Click:Connect(function()
    smoothTween(MainContainer, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    smoothTween(BlurEffect, {Size = 0}, 0.3)
    task.wait(0.3)
    MainContainer.Visible = false
    ReopenBtn.Visible = true
    smoothTween(ReopenBtn, {Size = UDim2.new(0, 60, 0, 60)}, 0.3)
end)

ResetBtn.MouseEnter:Connect(function()
    smoothTween(ResetBtn, {BackgroundTransparency = 0}, 0.2)
end)

ResetBtn.MouseLeave:Connect(function()
    smoothTween(ResetBtn, {BackgroundTransparency = 0.2}, 0.2)
end)

ResetBtn.MouseButton1Click:Connect(function()
    smoothTween(WinsCard, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}, 0.2)
    task.wait(0.1)
    totalWins = 0
    WinsValue.Text = "0"
    saveWins()
    task.wait(0.1)
    smoothTween(WinsCard, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.2)
end)

ReopenBtn.MouseButton1Click:Connect(function()
    smoothTween(ReopenBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
    task.wait(0.2)
    ReopenBtn.Visible = false
    MainContainer.Visible = true
    MainContainer.Size = UDim2.new(0, 0, 0, 0)
    smoothTween(MainContainer, {Size = UDim2.new(0, 480, 0, 620)}, 0.4)
    smoothTween(BlurEffect, {Size = 10}, 0.4)
end)

-- Animación de entrada
MainContainer.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.5)
smoothTween(MainContainer, {Size = UDim2.new(0, 480, 0, 620)}, 0.5)
smoothTween(BlurEffect, {Size = 10}, 0.5)

-- Loop principal
while true do
    for i = 20, 1, -1 do
        TimerLabel.Text = "⏳ Winning In: " .. i .. "s"
        smoothTween(TimerStroke, {Color = Color3.fromRGB(255, 215, 0)}, 0.3)
        task.wait(1)
    end
    
    TimerLabel.Text = "⚡ Running Script..."
    smoothTween(TimerStroke, {Color = Color3.fromRGB(80, 255, 80)}, 0.3)
    
    local touchdownSuccess = false
    pcall(function()
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name == "BridgeDuelTouchdownZone" then
                local char = player.Character
                if char and v:GetAttribute("TouchdownZoneTeamID") ~= char:GetAttribute("Team") then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        firetouchinterest(hrp, v, 1)
                        task.wait(0.1)
                        firetouchinterest(hrp, v, 0)
                        touchdownSuccess = true
                    end
                end
            end
        end
    end)
    
    if touchdownSuccess then
        totalWins = totalWins + 1
        WinsValue.Text = tostring(totalWins)
        
        -- Animación de win
        smoothTween(WinsCard, {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}, 0.3)
        task.wait(0.2)
        smoothTween(WinsCard, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.3)
        
        saveWins()
        sendDiscordEmbed(totalWins)
    end
    
    for i = 2, 1, -1 do
        TimerLabel.Text = "⏳ Winning In: " .. i .. "s"
        task.wait(1)
    end
    
    TimerLabel.Text = "🚀 TELEPORTING..."
    smoothTween(TimerStroke, {Color = Color3.fromRGB(255, 80, 80)}, 0.3)
    
    task.wait(0.5)
    
    player:Kick()
    task.wait(1.23)
    local data = TeleportService:GetLocalPlayerTeleportData()
    TeleportService:Teleport(game.PlaceId, player, data)
    
    task.wait(5)
end
