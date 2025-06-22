
getgenv().Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/rndmq/Serverlist/refs/heads/main/source.lua.txt"))()
local CHG = getgenv().Lib

local T = CHG:CreateTab("Main")
local S = T:CreateSection("Auto")
local P = game.Players.LocalPlayer
local RS = game.ReplicatedStorage
local E = RS:WaitForChild("Events"):WaitForChild("PlaceCarEvent")
local WSP = workspace.Plots

local tump = false
local mdl = nil
local opt = {}
local lim = {}

local function getPlot()
	for i = 1,6 do
		local p = workspace.Plots:FindFirstChild("Plot"..i)
		local l = p and p:FindFirstChild("OwnershipSignPart") and p.OwnershipSignPart:FindFirstChild("SurfaceGui") and p.OwnershipSignPart.SurfaceGui:FindFirstChild("UsernameLabel")
		if l and l.Text == game.Players.LocalPlayer.Name then return p end
	end
end

local function getUniq()
	local p = getPlot()
	local o, u = {}, {}
	if not p then return o end
	for _,v in ipairs(p:GetChildren()) do
		if v:IsA("Model") then
			local b = v.Name:match("^[^%-]+")
			if not u[b] then table.insert(o, b) u[b] = true end
		end
	end
	return o
end

local function renameAll(p, nama)
	local r = {}
	for _,v in ipairs(p:GetChildren()) do
		if v:IsA("Model") and v.Name:match("^"..nama.."[-%d]*$") then
			table.insert(r, v)
		end
	end
	table.sort(r, function(a,b)
		return a:GetBoundingBox().Position.Y < b:GetBoundingBox().Position.Y
	end)
	for i,v in ipairs(r) do
		v.Name = i == 1 and nama or (nama.."-"..(i-1))
	end
end

local dd = S:CreateDropdown("Pilih Mobil", opt, 1, function(v) mdl = v end)

S:CreateButton("Refresh", function()
	opt = getUniq()
	dd.Refresh(opt, 1, function(v) mdl = v end)
end)

S:CreateTextBox("Limit", 3, "e.g 5", function(v)
	if mdl and tonumber(v) then
		lim[mdl] = tonumber(v)
	end
end)

S:CreateToggle("Tumpuk (Same Car)", function(s)
	tump = s
	if s then
		task.spawn(function()
			while tump do
				local p = getPlot()
				if not p or not mdl then task.wait(1) continue end
				local m = {}
				for _,v in ipairs(p:GetChildren()) do
					if v:IsA("Model") and v.Name:match("^"..mdl.."[-%d]*$") then
						table.insert(m,v)
					end
				end
				if lim[mdl] and #m >= lim[mdl] then task.wait(1) continue end
				table.sort(m, function(a,b)
					return a:GetBoundingBox().Position.Y < b:GetBoundingBox().Position.Y
				end)
			local cf
if #m == 0 then
	cf = CFrame.new(0, 4.5, 0)
else
	local last = m[#m]
	local lastPos = last:GetBoundingBox().Position
	cf = CFrame.new(lastPos.X + 1, 4.5, lastPos.Z)
end
				game.ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("PlaceCarEvent", 9e9):FireServer(mdl, cf, p)
				task.delay(0.5, function()
					renameAll(p, mdl)
				end)
				task.wait(0.1)
			end
		end)
	end
end)
local allTump = false

S:CreateToggle("Tumpuk Semua", function(st)
	allTump = st
	if st then
		task.spawn(function()
			while allTump do
				local p = getPlot()
				if not p then task.wait(1) continue end

				for _, tool in ipairs(P.Backpack:GetChildren()) do
					if tool:IsA("Tool") then
						local base = tool.Name:gsub(" %(%d+%)", "") .. "Model"
						local m = {}
						for _, v in ipairs(p:GetChildren()) do
							if v:IsA("Model") and v.Name:match("^" .. base .. "[-%d]*$") then
								table.insert(m, v)
							end
						end

						table.sort(m, function(a, b)
							return a:GetBoundingBox().Position.Y < b:GetBoundingBox().Position.Y
						end)

						local target = m[1]
						local pos = target and target:GetBoundingBox().Position or Vector3.new(0, 4.5, 0)
						local cf = CFrame.new(pos.X, math.floor(pos.Y + 6), pos.Z)

						game.ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("PlaceCarEvent", 9e9):FireServer(base, cf, p)

						task.delay(0.5, function()
							renameAll(p, base)
						end)

						task.wait(0.1)
					end
				end

				task.wait()
			end
		end)
	end
end)
local G = game:GetService("Players").LocalPlayer
local UI = G.PlayerGui:WaitForChild("MainGameUI", 9e9).Frames.CrateOpeningFrame
local C = UI.DisplayImage:WaitForChild("Chance", 9e9)
local B = UI:WaitForChild("StopButton", 9e9)
local R = game:GetService("RunService")
local s = T:CreateSection("Ttg mobil")
local tt = CHG:CreateTab("Stock Mobil")
local ss = tt:CreateSection("Utama")
local A = false
local warned = false

s:CreateToggle("Get Lowest Car Chance", function(v)
	A = v
	if not v then return end

	task.spawn(function()
		task.wait(9)

		local chances = {}
		for _, x in ipairs(UI.DisplayImage:GetChildren()) do
			if x:IsA("TextLabel") and x.Name == "Chance" then
				local n = tonumber(x.Text:match("([%d%.]+)%%"))
				if n then
					table.insert(chances, n)
				end
			end
		end

		if #chances == 0 then
			if not warned then
				Library:CreateNotification("Info", "Buka crate dulu!", 4)
				warned = true
			end
			return
		end

		table.sort(chances)
		local lowest = chances[1]
		print("[LOWEST] Ditemukan chance terkecil: ", lowest)

		local started = false
		local con
		con = R.RenderStepped:Connect(function()
			if not A then con:Disconnect() return end

			local raw = C.Text
			local current = tonumber(raw:match("([%d%.]+)%%"))
			print("[DEBUG] Nilai C.Text saat ini: ", raw)

			if current then
				if not started and current ~= lowest then
					started = true
					print("[INFO] Animasi mulai deteksi: ", current)
				end

				if started and math.abs(current - lowest) <= 0.01 then
					print("[INFO] Ketemu lowest! Delay sebelum klik...")
				
					task.delay(0.01, function()
						for _, c in ipairs(getconnections(B.MouseButton1Click)) do
							c.Function()
						end
						print("[INFO] Tombol diklik setelah delay.")
					end)

					con:Disconnect()
				end
			end
		end)
	end)
end)

local pick = false

s:CreateToggle("Auto Pick Up Cars", function(st)
	pick = st
	if st then
		task.spawn(function()
			while pick do
				local p = nil
				for i = 1,6 do
					local pl = workspace.Plots:FindFirstChild("Plot"..i)
					local s = pl and pl:FindFirstChild("OwnershipSignPart") and pl.OwnershipSignPart:FindFirstChild("SurfaceGui") and pl.OwnershipSignPart.SurfaceGui:FindFirstChild("UsernameLabel")
					if s and s.Text == game.Players.LocalPlayer.Name then
						p = pl
						break
					end
				end
				if not p then task.wait(2) continue end

				for _,v in ipairs(p:GetChildren()) do
					if v:IsA("Model") and v.Name:match("Model$") or v.Name:match("Model%-%d+$") then
						local args = { p:WaitForChild(v.Name, 9e9) }
						game.ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("PickupCarEvent", 9e9):FireServer(unpack(args))
						task.wait()
					end
				end

				task.wait(1) 
			end
		end)
	end
end, "Beta. Always Failed :D")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local G = RS:WaitForChild("Functions"):WaitForChild("GetShopStateRemoteFunction")
local selected
local img = ss:CreateImage("CarImage", "rbxassetid://113971282607655", {
	X = {0.5, 25},
	Y = {0.5, 25}
})
local drop, itemMap = nil, {}
local function formatCost(c)
	if c >= 1_000_000 then
		return math.floor(c / 1_000_000) .. "M"
	elseif c >= 1_000 then
		return math.floor(c / 1_000) .. "k"
	else
		return tostring(c)
	end
end
local function refreshShop()
	local ok, data = pcall(function() return G:InvokeServer() end)
	if not ok or not data.shopItems then
		warn("Gagal ambil data shop")
		return
	end

	local options = {}
	itemMap = {}

	for _, item in pairs(data.shopItems) do
	if item.currentStock and item.currentStock > 0 then
		local costStr = formatCost(item.cost)
		local label = item.name .. " (" .. item.currentStock .. ") - " .. costStr
		table.insert(options, label)
		itemMap[label] = item
	end
end

	local callback = function(sel)
		local info = itemMap[sel]
		selected = sel
		if info then
			img:Refresh(info.imageId)
			print(info.imageId)
		end
	end

	if drop then
		drop.Refresh(options, 1, callback)
	else
		drop = ss:CreateDropdown("Shop Items", options, 1, callback)
	end
end

ss:CreateButton("Refresh Shop", refreshShop)

refreshShop()
local autobuy = false

ss:CreateToggle("Auto Buy", function(v)
	autobuy = v
	if v then
		task.spawn(function()
			while autobuy do
				if selected and itemMap[selected] then
					local name = itemMap[selected].toolName
					if itemMap[selected].currentStock > 0 then
						game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("BuyCarEvent"):FireServer(name)
					end
				end
				task.wait()
			end
		end)
	end
end)
ss:CreateButton("Beli Mobil Terpilih", function()
	if selected and itemMap[selected] then
		local name = itemMap[selected].toolName
		if itemMap[selected].currentStock > 0 then
			game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("BuyCarEvent"):FireServer(name)
		else
			Library:CreateNotification("Stock Habis", selected .. " sudah habis.", 3)
		end
	else
		Library:CreateNotification("Belum Dipilih", "Pilih mobil dulu di dropdown.", 3)
	end
end)
local craft = false

s:CreateToggle("Auto Craft Emas", function(st)
	craft = st
	if st then
		task.spawn(function()
			while craft do
				local bp = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
				for _, tool in ipairs(bp:GetChildren()) do
					if tool:IsA("Tool") then
						local name, count = tool.Name:match("^(.-) %((x?%d+)%)$")
						if name and count then
							count = tonumber(count:match("%d+"))
							if count and count >= 5 then
								game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TradeForGoldenCarEvent"):FireServer(name)
								task.wait(0.2)
							end
						end
					end
				end
				task.wait(1)
			end
		end)
	end
end)
local autodiamond = false

s:CreateToggle("Auto Craft Diamond", function(st)
	autodiamond = st
	if st then
		task.spawn(function()
			while autodiamond do
				local bp = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
				for _, tool in ipairs(bp:GetChildren()) do
					if tool:IsA("Tool") then
						local name, count = tool.Name:match("^(.-)Gold %((x?%d+)%)$")
						if name and count then
							count = tonumber(count:match("%d+"))
							if count and count >= 5 then
								game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("TradeForDiamondCarEvent"):FireServer(name)
								task.wait(0.3)
							end
						end
					end
				end
				task.wait(1)
			end
		end)
	end
end)