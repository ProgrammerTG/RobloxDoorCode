--Variáveis
local portas = nil
local chave = nil
local player = game.Players.LocalPlayer
local attachment = nil
local beam = nil
local portaatual = nil
local vinculado = false
local gui = player.PlayerGui:WaitForChild("PressE")
local backpack = player.Backpack
local character = nil
local input = game:GetService("UserInputService")
local receiver = game.ReplicatedStorage.PortaS:WaitForChild("Receive")
local segu = game.ReplicatedStorage.PortaS:WaitForChild("Segu")
local trigger = game.ReplicatedStorage.PortaS:WaitForChild("Trigger")
local tween = game:GetService("TweenService")
local info = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local tweenrodando = nil
local promptantigo = nil
local mobile = false
local cooldown = false
----
--Verificação Mobile|PC
if input.TouchEnabled and not input.MouseEnabled and not input.KeyboardEnabled then
	print("É mobile")
	mobile = true
	gui.Frame.ImageLabel.ImageTransparency = 1
	gui.Frame.TextLabel.Text = "Aperte o botão"
end
--
--Eventos
receiver.OnClientEvent:Connect(function(arg1)
	portas = arg1
end)

input.InputBegan:Connect(function(inp, process)
	if not process and not cooldown then
		if inp.KeyCode == Enum.KeyCode.E and vinculado then
			trigger:FireServer(chave, portaatual)
			cooldown = true
			wait(0.05, 0.1)
			cooldown = false
		end
	end
end)

segu.OnClientEvent:Connect(function(seckey)
	chave = seckey
end)

player.CharacterAdded:Connect(function(char)
	character = char
	char:WaitForChild("Humanoid").Died:Connect(function()
		deletar()		
	end)
end)

trigger.OnClientEvent:Connect(function(module, valor)
	local modulo = require(module)
	modulo.Status = valor
end)

--
--Função
function beamcreate(v)
	local module = require(v.ModuleScript)["Permissões"]
	local liberado = false
	for e, v in pairs(module) do
		if backpack:FindFirstChild(e) and v or character:FindFirstChild(e) and v then
			liberado = true
		end
	end
	promptantigo = v.ProximityPrompt
	beam = script.Beam:Clone()
	beam.Attachment0 = player.Character.HumanoidRootPart.RootAttachment
	attachment = Instance.new("Attachment", v)
	attachment.WorldPosition = player.Character.HumanoidRootPart.Position
	beam.Attachment1 = attachment
	tweenrodando = tween:Create(attachment,info, {["WorldPosition"] = v.Position})
	tweenrodando:Play()
	if not liberado then 
		beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
		gui.Frame.ImageLabel.ImageColor3 = Color3.new(255,0,0)
	else
		beam.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
		gui.Frame.ImageLabel.ImageColor3 = Color3.new(0,255,0)
	end
	beam.Parent = player.Character.HumanoidRootPart
	gui.Enabled = true
	if mobile then
		promptantigo.Enabled = true
	end
end

function deletar()
	if attachment then
		attachment:Destroy()
	end
	if beam then
		beam:Destroy()
	end
	if tweenrodando then
		if tweenrodando.PlaybackState == Enum.PlaybackState.Playing then
			tweenrodando:Cancel()
			tweenrodando = nil
		end
	end
	if promptantigo then
		promptantigo.Enabled = false
		promptantigo = nil
	end
	vinculado = false
	portaatual = nil
	gui.Enabled = false
end

--Desbugar
while not portas do
	wait(math.random(1, 3))
	receiver:FireServer()
end
--
if mobile then
	for e, v in pairs(portas) do
		v.ProximityPrompt.Triggered:Connect(function(pessoa)
			if pessoa.Name == player.Name then
				trigger:FireServer(chave, portaatual)
			end
		end)
	end
end


while true do
	wait(0.2)
	local encontrou = false
	if portas then
		for e, v in pairs(portas) do
			if player.Character:FindFirstChild("Humanoid") then
				if player.Character["Humanoid"].Health > 0 then
					local distancia = (player.Character.HumanoidRootPart.Position - v.Position).Magnitude
					local statusporta =  require(v["ModuleScript"]).Status
					if distancia <= 8 and statusporta then
						if not character then
							character = player.Character
						end
						if vinculado and portaatual ~= v then							
							deletar()
							vinculado = true
							portaatual = v
							beamcreate(v)
						elseif not vinculado then
							vinculado = true
							portaatual = v
							beamcreate(v)
						end
						encontrou = true
						break
					end
				end
			end
		end
	end
	if not encontrou then
		deletar()
	end
end