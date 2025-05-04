-- GUI bật/tắt Kill Aura bằng phím K
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 30)
button.Text = "Bật Kill Aura"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)

local killAura = false
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        frame.Visible = not frame.Visible
    end
end)

local function isPlayer(char)
    return game.Players:GetPlayerFromCharacter(char) ~= nil
end

local function hasFire(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Fire") then
            return true
        end
    end
    return false
end

local function killNearby()
    while killAura and task.wait(0.25) do
        for _, mob in ipairs(workspace:GetDescendants()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                if not isPlayer(mob) and mob.Humanoid.Health > 0 and not hasFire(mob) then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local dist = (mob.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if dist <= 60 then
                            pcall(function()
                                char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                                game:GetService("ReplicatedStorage"):FindFirstChild("Remotes").Combat.Attack:FireServer(mob)
                            end)
                        end
                    end
                end
            end
        end
    end
end

button.MouseButton1Click:Connect(function()
    killAura = not killAura
    button.Text = killAura and "Tắt Kill Aura" or "Bật Kill Aura"
    button.BackgroundColor3 = killAura and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
    if killAura then
        task.spawn(killNearby)
    end
end)
