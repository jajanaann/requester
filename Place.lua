
getgenv().Color = "default"
getgenv().TextColor = "default"
getgenv().Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/rndmq/Serverlist/refs/heads/main/source.lua.txt"))()
local UI = getgenv().Lib
local Tab = UI:CreateTab("Main")
local Sec = Tab:CreateSection("Auto Place")
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Backpack = LP:WaitForChild("Backpack")
local PlaceRemote = Rep:WaitForChild("RemoteEvents"):WaitForChild("PlaceEmployee")
local myPlot = nil
for i = 1, 6 do
	local plot = Workspace:WaitForChild("BasePlots"):FindFirstChild("BasePlot" .. i)
	if plot then
		local txt = plot:FindFirstChild("Sign") and plot.Sign:FindFirstChild("BasePlayer") and plot.Sign.BasePlayer:FindFirstChild("PlayerText")
		if txt and txt:IsA("TextLabel") and txt.Text == LP.Name then
			myPlot = plot
			break
		end
	end
end
local running = false

Sec:CreateToggle("Auto Place All", function(v)
	running = v
	if not myPlot then
		warn("Plot tidak ditemukan.")
		return
	end

	local area = myPlot:FindFirstChild("Placement")
	if not area then
		warn("Placement area tidak ditemukan.")
		return
	end

	local size = area.Size
	local center = area.Position

	task.spawn(function()
		while running do
			for _, tool in ipairs(Backpack:GetChildren()) do
				if not running then break end
				if tool:IsA("Tool") then
					local name = tool.Name
					local variant = tool:GetAttribute("Variant") or "Normal"

					local x = math.random(-size.X/2, size.X/2)
					local z = math.random(-size.Z/2, size.Z/2)
					local y = 6
					local cf = CFrame.new(center.X + x, y, center.Z + z)

					local args = {
						[1] = name,
						[2] = variant,
						[3] = cf,
					}

					pcall(function()
						PlaceRemote:FireServer(unpack(args))
					end)
					task.wait()
				end
			end
			task.wait()
		end
	end)
end)
