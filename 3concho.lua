--// KATA HUB BETA GUI (DELTA STEALTH - FULL)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local Http = game:GetService("HttpService")
local TP = game:GetService("TeleportService")
local lp = Players.LocalPlayer

-- CONFIG
_G.AutoFarm = false
_G.AutoHop = false
_G.MinPlayers = 2
_G.MaxPlayers = 12
_G.ServerList = _G.ServerList or {}
_G.OffsetHeight = 14
_G.OffsetForward = 8

--================ GUI =================--
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KataHubGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,200,0,150)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "KATA HUB BETA"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local function createBtn(text, posY)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0.9,0,0,30)
    b.Position = UDim2.new(0.05,0,0,posY)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local FarmBtn = createBtn("Auto Farm: OFF",40)
local HopBtn = createBtn("Auto Hop: OFF",75)
local CloseBtn = createBtn("Close GUI",110)

--================ BUTTON =================--
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = "Auto Farm: "..(_G.AutoFarm and "ON" or "OFF")
end)

HopBtn.MouseButton1Click:Connect(function()
    _G.AutoHop = not _G.AutoHop
    HopBtn.Text = "Auto Hop: "..(_G.AutoHop and "ON" or "OFF")
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--================ ANTI KICK =================--
pcall(function()
    local mt = getrawmetatable(game)
    if mt and not getgenv()._BetaHook then
        local old = mt.__namecall
        setreadonly(mt,false)
        mt.__namecall = newcclosure(function(self,...)
            if tostring(getnamecallmethod()) == "Kick" and not checkcaller() then
                return nil
            end
            return old(self,...)
        end)
        setreadonly(mt,true)
        getgenv()._BetaHook = true
    end
end)

--================ HOP =================--
local function FastHop()
    if not _G.AutoHop then return end
    
    pcall(function()
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local list = Http:JSONDecode(game:HttpGet(Api))

        for _,s in ipairs(list.data) do
            if s.playing >= _G.MinPlayers and s.playing <= _G.MaxPlayers
            and s.id ~= game.JobId
            and not table.find(_G.ServerList,s.id) then
                
                table.insert(_G.ServerList,s.id)
                TP:TeleportToPlaceInstance(game.PlaceId,s.id,lp)
                task.wait(10)
                return
            end
        end
    end)
end

--================ FIND BOSS =================--
local function GetBoss()
    for _,folder in ipairs({workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs"), workspace}) do
        if folder then
            for _,v in ipairs(folder:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local name = v.Name:lower()
                    if name:find("dough king") or name:find("rip_indra") then
                        return v
                    end
                end
            end
        end
    end
end

--================ COMBAT (M1 ONLY) =================--
local function AttackBoss(boss)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero

    repeat
        if not boss or boss.Humanoid.Health <= 0 then break end

        local targetCF = boss.HumanoidRootPart.CFrame * CFrame.new(0,_G.OffsetHeight,_G.OffsetForward)
        hrp.CFrame = hrp.CFrame:Lerp(targetCF,0.2)

        local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            lp.Character.Humanoid:EquipTool(tool)
            tool:Activate() -- M1 ONLY
        end

        VIM:SendKeyEvent(true,"J",false,game) -- Haki
        
        task.wait(math.random(10,16)/100)
    until not boss or boss.Humanoid.Health <= 0

    bv:Destroy()
end

--================ MAIN LOOP =================--
task.spawn(function()
    while true do
        if _G.AutoFarm then
            local boss = GetBoss()
            if boss then
                AttackBoss(boss)
            else
                if _G.AutoHop then
                    FastHop()
                end
            end
        end
        task.wait(1)
    end
end)

--================ NOCLIP =================--
RS.Stepped:Connect(function()
    if lp.Character then
        for _,v in ipairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)
