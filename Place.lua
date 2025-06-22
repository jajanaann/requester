
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
local Event = Rep:WaitForChild("RemoteEvents"):WaitForChild("PlaceEmployee")


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


local selectedName = nil
local selectedTier = "Normal"
local nameMap = {}


local function getToolOptions()
	local seen = {}
	local result = {}
	nameMap = {}

	for _, tool in ipairs(Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local name = tool.Name
			seen[name] = (seen[name] or 0) + 1
		end
	end

	for name, count in pairs(seen) do
		local display = count > 1 and (name .. " (x" .. count .. ")") or name
		table.insert(result, display)
		nameMap[display] = name
	end

	return result
end


local dropdown1 = Sec:CreateDropdown("Select Unit", getToolOptions(), 1, function(choice)
	selectedName = nameMap[choice]
end)


Sec:CreateButton("Refresh Units", function()
	local options = getToolOptions()
	dropdown1.Refresh(options, 1, function(choice)
		selectedName = nameMap[choice]
	end)
end)


Sec:CreateDropdown("Select Tier", { "Normal", "Gold", "Rainbow" }, 1, function(choice)
	selectedTier = choice
end)


local placing = false
Sec:CreateToggle("Auto Place Employee", function(v)
	placing = v
	if not myPlot then
		warn("Plot tidak ditemukan.")
		return
	end

	task.spawn(function()
		while placing do
			if selectedName and selectedTier then
				local area = myPlot:FindFirstChild("Placement")
				if not area then warn("Placement area tidak ditemukan.") return end

				local sz, pos = area.Size, area.Position
				local x = math.random(-sz.X/2, sz.X/2)
				local z = math.random(-sz.Z/2, sz.Z/2)
				local y = 6

				local args = {
					[1] = selectedName,
					[2] = selectedTier,
					[3] = CFrame.new(pos.X + x, y, pos.Z + z)
				}

				pcall(function()
					Event:FireServer(unpack(args))
				end)

				task.wait()
			end
			task.wait()
		end
	end)
end)