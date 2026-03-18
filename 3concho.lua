--// KATA FARM FULL SYSTEM (STABLE)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

local runningHop = false
local runningFarm = false
local visited = {}

-- SAFE CHARACTER
function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
local hopBtn = Instance.new("TextButton", frame)
local farmBtn = Instance.new("TextButton", frame)
local status = Instance.new("TextLabel", frame)

frame.Size = UDim2.new(0,240,0,170)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

hopBtn.Size = UDim2.new(1,0,0.3,0)
hopBtn.Text = "HOP: OFF"

farmBtn.Size = UDim2.new(1,0,0.3,0)
farmBtn.Position = UDim2.new(0,0,0.3,0)
farmBtn.Text = "FARM: OFF"

status.Size = UDim2.new(1,0,0.4,0)
status.Position = UDim2.new(0,0,0.6,0)
status.Text = "Status: Idle"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1

-- AUTO HAKI
function AutoHaki()
    pcall(function()
        local char = GetChar()
        if not char:FindFirstChild("HasBuso") then
            VirtualUser:CaptureController()
            VirtualUser:SetKeyDown("j")
            task.wait(0.1)
            VirtualUser:SetKeyUp("j")
        end
    end)
end

-- AUTO ATTACK
function AutoAttack()
    task.spawn(function()
        while runningFarm do
            pcall(function()
                local char = GetChar()
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- EVADE
function AttackBoss(boss)
    while runningFarm and boss and boss:FindFirstChild("HumanoidRootPart") do
        local char = GetChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            hrp.CFrame = boss.HumanoidRootPart.CFrame *
                CFrame.new(math.random(-10,10), 5, math.random(-10,10))
        end
        
        task.wait(0.3)
    end
end

-- FIND BOSS
function GetBoss()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if string.find(v.Name,"Dough King") then
            return v
        end
    end
end

-- CHECK SUMMON
function CheckSummon()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and string.find(v.Name,"Sweet Chalice") then
            return true
        end
    end
end

-- HOP SERVER
function Hop()
    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)

    for _,v in pairs(data.data) do
        if v.playing < v.maxPlayers and not visited[v.id] then
            visited[v.id] = true
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            task.wait(2)
        end
    end
end

-- HOP TOGGLE
hopBtn.MouseButton1Click:Connect(function()
    runningHop = not runningHop
    hopBtn.Text = runningHop and "HOP: ON" or "HOP: OFF"

    while runningHop do
        if GetBoss() or CheckSummon() then
            status.Text = "Boss Found"
            break
        else
            status.Text = "Hopping..."
            Hop()
        end
        task.wait(5)
    end
end)

-- FARM TOGGLE
farmBtn.MouseButton1Click:Connect(function()
    runningFarm = not runningFarm
    farmBtn.Text = runningFarm and "FARM: ON" or "FARM: OFF"

    if runningFarm then
        AutoAttack()
    end

    while runningFarm do
        local boss = GetBoss()

        if boss then
            status.Text = "Fighting"
            AutoHaki()
            AttackBoss(boss)
        else
            status.Text = "Waiting..."
        end

        task.wait(2)
    end
end)
