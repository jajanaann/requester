
getgenv().Color = "default"
getgenv().TextColor = "default"
getgenv().Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/rndmq/Serverlist/refs/heads/main/source.lua.txt"))()
local UI = getgenv().Lib
local Tab = UI:CreateTab("Main")
local Sec = Tab:CreateSection("Auto Pickup")


local LP = game:GetService("Players").LocalPlayer
local Placed = workspace:WaitForChild("PlacedEmployees", 9e9)
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents", 9e9):WaitForChild("PickupEmployeeEvent", 9e9)


local active = false


task.spawn(function()
	while true do
		local i = 1
		for _, v in ipairs(Placed:GetChildren()) do
			if v:GetAttribute("OwnerUserId") == LP.UserId then
				local expectedName = tostring(i)
				if v.Name ~= expectedName then
					v.Name = expectedName
				end

				if active then
					pcall(function()
						Remote:FireServer(v)
					end)
					task.wait()
				end

				i += 1
			end
		end
		task.wait()
	end
end)


Sec:CreateToggle("Auto Pick Up", function(v)
	active = v
end)