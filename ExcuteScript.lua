-- Anti AFK để tránh bị kick
game:GetService("Players").LocalPlayer.Idled:Connect(function()
   game:GetService("VirtualUser"):Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
   wait(1)
   game:GetService("VirtualUser"):Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

-- Kiểm tra xem mob có phải là người chơi không
local function isPlayer(mob)
   return game.Players:GetPlayerFromCharacter(mob) ~= nil
end

-- Biến điều khiển Kill Aura
local killAuraEnabled = false -- Mặc định Kill Aura là tắt

-- Tạo GUI trong màn hình
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)  -- Kích thước của frame
frame.Position = UDim2.new(0, 10, 0, 10)  -- Vị trí của frame
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Màu nền của frame
frame.BackgroundTransparency = 0.5  -- Độ trong suốt của frame
frame.Visible = false  -- Frame mặc định tắt
frame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 50)  -- Kích thước của button
toggleButton.Position = UDim2.new(0, 10, 0, 25)  -- Vị trí của button trong frame
toggleButton.Text = "Bật Kill Aura"  -- Văn bản của button
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Màu chữ
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Màu nền của button
toggleButton.Parent = frame

-- Hàm Kill Aura: Giết tất cả các mob khi chúng spawn (trừ người chơi)
local function killAllMobs()
   while killAuraEnabled do
      -- Kiểm tra chỉ các mob gần người chơi
      local character = game.Players.LocalPlayer.Character
      if character then
         local playerPosition = character.HumanoidRootPart.Position
         for _, mob in ipairs(workspace:FindFirstChild("Enemies", true):GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
               local h = mob.Humanoid
               local mobPosition = mob.HumanoidRootPart.Position
               -- Tính khoảng cách giữa người chơi và mob, nếu mob gần, thì tấn công
               if h.Health > 0 and not isPlayer(mob) and (mobPosition - playerPosition).Magnitude < 50 then
                  -- Dịch đến vị trí spawn của mob
                  local head = mob:FindFirstChild("Head") or mob.HumanoidRootPart
                  if head then
                     -- Dịch chuyển đến vị trí mob spawn
                     game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = head.CFrame * CFrame.new(0, 0, 2)
                  end

                  -- Tấn công mob ngay khi chúng spawn
                  spawn(function()
                     while h and h.Health > 0 and mob.Parent and killAuraEnabled do
                        task.wait(0.1)  -- Kiểm tra mỗi 0.1 giây để giảm tải
                        pcall(function()
                           -- Tấn công mob liên tục
                           game:GetService("ReplicatedStorage").Remotes.Combat.Attack:FireServer(mob)
                        end)
                     end
                  end)
               end
            end
         end
      end
      task.wait(1) -- Giảm tần suất kiểm tra các mob
   end
end

-- Hàm để bật và tắt Kill Aura khi nhấn button
toggleButton.MouseButton1Click:Connect(function()
   if killAuraEnabled then
      killAuraEnabled = false
      toggleButton.Text = "Bật Kill Aura"
      frame.Visible = false  -- Tắt GUI khi Kill Aura bị tắt
   else
      killAuraEnabled = true
      toggleButton.Text = "Tắt Kill Aura"
      frame.Visible = true  -- Hiển thị GUI khi Kill Aura được bật
      killAllMobs()  -- Khi bật lại, chạy lại hàm killAllMobs
   end
end)

-- Hiển thị frame khi game bắt đầu và frame là "nút" bật tắt Kill Aura
frame.Visible = true
