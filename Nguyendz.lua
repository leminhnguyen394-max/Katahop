--// Nguyendeptrainhucnach HUB BETA V12 GOD FINAL

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- CONFIG
local Config = {
    AutoFarm = false,
    AutoBoss = false,
    AutoChest = false,
    AutoFruit = false,
    AutoSkill = true,
    ESP = false,
    Humanize = true
}

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,420,0,360)
main.Position = UDim2.new(0,100,0,100)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Nguyendeptrainhucnach HUB BETA V12 GOD"
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.TextColor3 = Color3.new(1,1,1)

local tabNames = {"Farm","Boss","ESP","Settings"}
local tabs = {}

for i,name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.25,0,0,30)
    btn.Position = UDim2.new((i-1)*0.25,0,0,40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    local frame = Instance.new("Frame", main)
    frame.Size = UDim2.new(1,0,1,-70)
    frame.Position = UDim2.new(0,0,0,70)
    frame.Visible = false
    frame.BackgroundTransparency = 1

    tabs[name] = frame

    btn.MouseButton1Click:Connect(function()
        for _,f in pairs(tabs) do f.Visible = false end
        frame.Visible = true
    end)
end
tabs["Farm"].Visible = true

-- ================= BUTTON PRO =================
local function ToggleBtn(parent,text,y,flag)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9,0,0,40)
    b.Position = UDim2.new(0.05,0,0,y)
    b.TextColor3 = Color3.new(1,1,1)

    local function update()
        if Config[flag] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0)
            b.Text = text.." [ON]"
        else
            b.BackgroundColor3 = Color3.fromRGB(170,0,0)
            b.Text = text.." [OFF]"
        end
    end

    update()

    b.MouseButton1Click:Connect(function()
        Config[flag] = not Config[flag]
        update()
    end)

    -- HOVER ANIMATION
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            Size = UDim2.new(0.95,0,0,42)
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            Size = UDim2.new(0.9,0,0,40)
        }):Play()
    end)
end

-- BUTTONS
ToggleBtn(tabs["Farm"],"Auto Farm",0,"AutoFarm")
ToggleBtn(tabs["Farm"],"Auto Skill",50,"AutoSkill")
ToggleBtn(tabs["Farm"],"Auto Chest",100,"AutoChest")
ToggleBtn(tabs["Farm"],"Auto Fruit",150,"AutoFruit")

ToggleBtn(tabs["Boss"],"Auto Boss",0,"AutoBoss")

ToggleBtn(tabs["ESP"],"ESP",0,"ESP")

ToggleBtn(tabs["Settings"],"Humanize",0,"Humanize")

-- ================= SYSTEM =================

local function Delay()
    if Config.Humanize then
        task.wait(math.random(10,40)/100)
    end
end

local function FakeIdle()
    if Config.Humanize and math.random(1,10) == 1 then
        task.wait(math.random(1,2))
    end
end

local function TweenTo(cf)
    local root = player.Character.HumanoidRootPart
    local dist = (root.Position - cf.Position).Magnitude
    local speed = math.random(20,30)
    local time = dist / speed

    local tween = TweenService:Create(root, TweenInfo.new(time), {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- 🔥 M1 PRO
local combo = 0

local function M1Attack(target)
    if not target then return end

    local root = player.Character.HumanoidRootPart
    local dist = (root.Position - target.HumanoidRootPart.Position).Magnitude

    if dist <= 8 then
        combo += 1
        VirtualUser:ClickButton1(Vector2.new(0,0))

        if combo >= 4 then
            combo = 0
            task.wait(math.random(2,4)/10)
        else
            task.wait(math.random(8,12)/100)
        end
    end
end

local function UseSkill()
    if Config.AutoSkill then
        local keys = {"Z","X","C","V"}
        for _,k in pairs(keys) do
            game:GetService("VirtualInputManager"):SendKeyEvent(true,k,false,game)
            task.wait(0.05)
            game:GetService("VirtualInputManager"):SendKeyEvent(false,k,false,game)
        end
    end
end

-- 🎯 AUTO QUEST (REMOTE + FALLBACK)
local function AutoQuest()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest","BanditQuest1",1)
    end)

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
        end
    end
end

local function GetTarget()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name:lower():find("boss") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end

    local dist = math.huge
    local target = nil

    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local mag = (player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                dist = mag
                target = v
            end
        end
    end

    return target
end

local function BringMob(target)
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v ~= target and v:FindFirstChild("HumanoidRootPart") then
            if (v.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude < 60 then
                v.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
            end
        end
    end
end

local function AutoFarm()
    local mob = GetTarget()
    if not mob then return end

    repeat
        if not mob or mob.Humanoid.Health <= 0 then break end

        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0,0,5))
        BringMob(mob)
        M1Attack(mob)
        UseSkill()
        Delay()
        FakeIdle()

    until not Config.AutoFarm and not Config.AutoBoss
end

local function ESP()
    if not Config.ESP then
        for _,v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Head") and v.Head:FindFirstChild("ESP") then
                v.Head.ESP:Destroy()
            end
        end
        return
    end

    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Head") and not v.Head:FindFirstChild("ESP") then
            local g = Instance.new("BillboardGui", v.Head)
            g.Name = "ESP"
            g.Size = UDim2.new(0,100,0,40)
            g.AlwaysOnTop = true

            local t = Instance.new("TextLabel", g)
            t.Size = UDim2.new(1,0,1,0)
            t.Text = v.Name
            t.BackgroundTransparency = 1
            t.TextColor3 = Color3.fromRGB(0,255,255)
        end
    end
end

-- LOOP
task.spawn(function()
    while task.wait() do
        if Config.AutoFarm or Config.AutoBoss then
            AutoFarm()
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if Config.AutoFarm then
            AutoQuest()
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        ESP()
    end
end)

-- Anti AFK
task.spawn(function()
    while task.wait(60) do
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
