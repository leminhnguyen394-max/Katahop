--// KATA HUB BETA (AUTO STEAL BOSS)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

--================ GUI =================--
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KataHubV4"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,220)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.Text = "KATA HUB V4 🔥"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", main)
status.Position = UDim2.new(0,10,0,35)
status.Size = UDim2.new(1,-20,0,20)
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(0,255,0)
status.BackgroundTransparency = 1

local container = Instance.new("Frame", main)
container.Position = UDim2.new(0,0,0,60)
container.Size = UDim2.new(1,0,1,-60)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0,10)

-- toggle UI
function CreateToggle(text, callback)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1,-20,0,40)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6,0,1,0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1

    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.new(0,50,0,25)
    toggle.Position = UDim2.new(1,-60,0.5,-12)
    toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0,23,0,23)
    knob.Position = UDim2.new(0,1,0,1)
    knob.BackgroundColor3 = Color3.fromRGB(255,0,0)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local state = false

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state

            if state then
                knob:TweenPosition(UDim2.new(1,-24,0,1),"Out","Quad",0.2,true)
                knob.BackgroundColor3 = Color3.fromRGB(0,255,0)
            else
                knob:TweenPosition(UDim2.new(0,1,0,1),"Out","Quad",0.2,true)
                knob.BackgroundColor3 = Color3.fromRGB(255,0,0)
            end

            callback(state)
        end
    end)
end

--================ FUNCTIONS =================--

function GetBoss()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if string.find(v.Name,"Dough King") then
            return v
        end
    end
end

function GetIndra()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if string.find(v.Name,"rip_indra") or string.find(v.Name,"Indra") then
            return v
        end
    end
end

function AutoHaki()
    if not player.Character:FindFirstChild("HasBuso") then
        VirtualUser:CaptureController()
        VirtualUser:SetKeyDown("j")
        task.wait(0.1)
        VirtualUser:SetKeyUp("j")
    end
end

function KillBoss(boss)
    repeat task.wait()
        if not boss or not boss:FindFirstChild("HumanoidRootPart") then break end

        AutoHaki()

        player.Character.HumanoidRootPart.CFrame =
            boss.HumanoidRootPart.CFrame * CFrame.new(0,10,0)

        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end

    until not boss or boss.Humanoid.Health <= 0
end

-- detect fight
function IsBossFighting(boss)
    if not boss or not boss:FindFirstChild("Humanoid") then return false end
    local old = boss.Humanoid.Health
    task.wait(0.8)
    return boss.Humanoid.Health < old
end

function PlayersNearBoss(boss)
    local count = 0
    for _,plr in pairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - boss.HumanoidRootPart.Position).Magnitude
            if dist < 50 then
                count = count + 1
            end
        end
    end
    return count >= 2
end

function IsGoodServer()
    local boss = GetBoss() or GetIndra()
    if boss then
        if IsBossFighting(boss) or PlayersNearBoss(boss) then
            return true, boss
        end
    end
    return false
end

function FastHop()
    local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)

    for _,v in pairs(data.data) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            task.wait(1)
        end
    end
end

-- MAIN AUTO
function AutoStealBoss()
    task.spawn(function()
        while true do
            local ok, boss = IsGoodServer()

            if ok and boss then
                status.Text = "Status: Boss đang bị đánh 🔥"

                repeat task.wait()
                    if not boss then break end

                    player.Character.HumanoidRootPart.CFrame =
                        boss.HumanoidRootPart.CFrame * CFrame.new(0,10,0)

                    AutoHaki()

                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end

                until not boss or boss.Humanoid.Health <= 0

                status.Text = "Status: Xong boss 😎"
                break
            else
                status.Text = "Status: Không có → hop..."
                FastHop()
            end

            task.wait(1)
        end
    end)
end

--================ TOGGLE =================--

CreateToggle("Auto Steal Boss 🔥", function(v)
    if v then
        AutoStealBoss()
    else
        status.Text = "Status: Idle"
    end
end)
