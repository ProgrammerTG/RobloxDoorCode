--Variables
local tween = game:GetService("TweenService")
local doors = {}
local senderdoorsconfigs = game.ReplicatedStorage.PortaS.Receive
--Generate Random Code to prevent exploiters to bypass
local GUIDGen = game:GetService("HttpService")
--
local trigger = game.ReplicatedStorage.PortaS.Trigger
local receiver = game.ReplicatedStorage.PortaS.Receive
-------------------

--Big Door settings for tween
local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In,0,false,0)
--Small door settings for twen
local info2 = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
-------------------


--Door Security
local codesecurity = {}
local devices = {}
local UIDSender = game.ReplicatedStorage.PortaS.Segu
-------------------

--Map Ports
for e, v in pairs(workspace:GetDescendants()) do
	if v.Name == "Porta" and v:FindFirstChild("ModuleScript") then
		table.insert(doors, v)
		local prompt = script.ProximityPrompt:Clone()
		prompt.Parent = v
	end
end
---

--Events
--user code generated and sended to user
game.Players.PlayerAdded:Connect(function(player)
	local personalcode = GUIDGen:GenerateGUID(true)
	codesecurity[player.Name] = personalcode
	UIDSender:FireClient(player, personalcode)
end)

--user code removed from list after player exit from server
game.Players.PlayerRemoving:Connect(function(player)
	codesecurity[player.Name] = ""
end)



--Remove Event receive user trigger to open the door, and the code send to function "verify" sending the who door triggered, what door, and UID security cod from person
trigger.OnServerEvent:Connect(function(person,cod,door)
	wait(math.random(0.05,0.1))
	verify(person,cod,door)
end)



receiver.OnServerEvent:Connect(function(player)
	game.ReplicatedStorage.PortaS.Receive:FireClient(player, doors)
end)
-------------------

-------------------Funções

--Verify if user code is correcty, and if user has permissions to open the door, and others security measures
function verify(person, cod, door)
	if door and codesecurity[person.Name] == cod and codesecurity[person.Name] ~= "" then
		if door.Name == "Porta" and door:FindFirstChild("ModuleScript") then
			if person.Character:FindFirstChild("Humanoid") then
				if (person.Character.HumanoidRootPart.Position - door.Position).Magnitude <= 8 then
					local configs = require(door["ModuleScript"])
					local status = configs["Status"]
					local allowed = false
					configspam(door["ModuleScript"], false)
					for e, v in pairs(configs["Permissions"]) do
						if person.Backpack:FindFirstChild(e) and v or person.Character:FindFirstChild(e) and v then
							allowed = true
							if door:FindFirstChild("Allowed") then return end
							local somperm = script.Allowed:Clone()
							somperm.Parent = door
							somperm:Play()
							wait(1.381)
							somperm:Destroy()
						end
					end
					if status and allowed then
						if door.Parent.Name == "DOOR" and door.Parent:FindFirstChild("frame") then
							smalldor(door, door["ModuleScript"])
						else
							bigdoor(door, door["ModuleScript"])
						end
					end
					if not allowed then
						if door:FindFirstChild("Denied") then return end
						local somperm = script.Denied:Clone()
						somperm.Parent = door
						somperm:Play()
						wait(1.384)
						somperm:Destroy()
					end
					configspam(door["ModuleScript"], true)
				end
			end
		end
	end
end

--Check that there is no opening spawn, so the door doesn't bug.
function configspam(configs, value)
	local modulo = require(configs)
	modulo.Status = value
	trigger:FireAllClients(configs, value)
end


--Use the specific tween to open the smaller doors
function smalldor(door, configs)
	local soundallowed, sounddenied = script.allowedsound:Clone(), script.deniedsound:Clone()
	local move, move2 = nil, nil
	move = tween:Create(door.Parent["DOOR1"].PrimaryPart, info2, {["CFrame"] = (door.Parent["DOOR1"].PrimaryPart.CFrame * CFrame.new(-4.7,0,0))})
	move2 = tween:Create(door.Parent["DOOR2"].PrimaryPart, info2, {["CFrame"] = (door.Parent["DOOR2"].PrimaryPart.CFrame * CFrame.new(4.7,0,0))})
	soundallowed.Parent = door
	soundallowed:Play()
	move:Play()
	move2:Play()
	move2.Completed:Wait()
	soundallowed:Destroy()
	wait(5)
	move = tween:Create(door.Parent["DOOR1"].PrimaryPart, info2, {["CFrame"] = (door.Parent["DOOR1"].PrimaryPart.CFrame * CFrame.new(4.7,0,0))})
	move2 = tween:Create(door.Parent["DOOR2"].PrimaryPart, info2, {["CFrame"] = (door.Parent["DOOR2"].PrimaryPart.CFrame * CFrame.new(-4.7,0,0))})
	sounddenied.Parent = door
	sounddenied:Play()
	move:Play()
	move2:Play()
	move2.Completed:Wait()
	sounddenied:Destroy()
end
--Use the specific tween to open the big doors
function bigdoor(door,configs)
	local move = nil
	local soundallowed, sounddenied = script.allowedsoundG:Clone(), script.deniedsoundG:Clone()
	move = tween:Create(door, info, {["Position"] = (door.Position + Vector3.new(0,12,0))})
	soundallowed.Parent = door
	soundallowed:Play()
	move:Play()
	move.Completed:Wait()
	soundallowed:Destroy()
	wait(7)
	move = tween:Create(door, info, {["Position"] = (door.Position + Vector3.new(0,-12,0))})
	sounddenied.Parent = door
	sounddenied:Play()
	move:Play()
	move.Completed:Wait()
	sounddenied:Destroy()
end


