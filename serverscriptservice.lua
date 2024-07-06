--Váriaveis
local tween = game:GetService("TweenService")
local portas = {}
local distribuirporta = game.ReplicatedStorage.PortaS.Receive
local GUIDGen = game:GetService("HttpService")
local trigger = game.ReplicatedStorage.PortaS.Trigger
local receiver = game.ReplicatedStorage.PortaS.Receive
-------------------

--Porta Grande Info
local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In,0,false,0)
--Porta Pequena Info
local info2 = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
-------------------


--Segurança
local codigosegu = {}
local dispositivos = {}
local distribuidor = game.ReplicatedStorage.PortaS.Segu
-------------------

--Mapear todas portas
for e, v in pairs(workspace:GetDescendants()) do
	if v.Name == "Porta" and v:FindFirstChild("ModuleScript") then
		table.insert(portas, v)
		local prompt = script.ProximityPrompt:Clone()
		prompt.Parent = v
	end
end
---

--Eventos
game.Players.PlayerAdded:Connect(function(player)
	local codigopessoal = GUIDGen:GenerateGUID(true)
	codigosegu[player.Name] = codigopessoal
	distribuidor:FireClient(player, codigopessoal)
end)

game.Players.PlayerRemoving:Connect(function(player)
	codigosegu[player.Name] = ""
end)



trigger.OnServerEvent:Connect(function(pessoa,cod,porta)
	wait(math.random(0.05,0.1))
	verificacao(pessoa,cod,porta)
end)



receiver.OnServerEvent:Connect(function(player)
	game.ReplicatedStorage.PortaS.Receive:FireClient(player, portas)
end)
-------------------

-------------------Funções

function verificacao(pessoa, cod, porta)
	if porta and codigosegu[pessoa.Name] == cod and codigosegu[pessoa.Name] ~= "" then
		if porta.Name == "Porta" and porta:FindFirstChild("ModuleScript") then
			if pessoa.Character:FindFirstChild("Humanoid") then
				if (pessoa.Character.HumanoidRootPart.Position - porta.Position).Magnitude <= 8 then
					local configs = require(porta["ModuleScript"])
					local status = configs["Status"]
					local permitido = false
					configspam(porta["ModuleScript"], false)
					for e, v in pairs(configs["Permissões"]) do
						if pessoa.Backpack:FindFirstChild(e) and v or pessoa.Character:FindFirstChild(e) and v then
							permitido = true
							if porta:FindFirstChild("Aprovado") then return end
							local somperm = script.Aprovado:Clone()
							somperm.Parent = porta
							somperm:Play()
							wait(1.381)
							somperm:Destroy()
						end
					end
					if status and permitido then
						if porta.Parent.Name == "DOOR" and porta.Parent:FindFirstChild("frame") then
							portapequena(porta, porta["ModuleScript"])
						else
							portagrande(porta, porta["ModuleScript"])
						end
					end
					if not permitido then
						if porta:FindFirstChild("Negado") then return end
						local somperm = script.Negado:Clone()
						somperm.Parent = porta
						somperm:Play()
						wait(1.384)
						somperm:Destroy()
					end
					configspam(porta["ModuleScript"], true)
				end
			end
		end
	end
end

function configspam(configs, valor)
	local modulo = require(configs)
	modulo.Status = valor
	trigger:FireAllClients(configs, valor)
end

function portapequena(porta, configs)
	local somabrir, somfechar = script.SomAbrir:Clone(), script.SomFechar:Clone()
	local mover, mover2 = nil, nil
	mover = tween:Create(porta.Parent["DOOR1"].PrimaryPart, info2, {["CFrame"] = (porta.Parent["DOOR1"].PrimaryPart.CFrame * CFrame.new(-4.7,0,0))})
	mover2 = tween:Create(porta.Parent["DOOR2"].PrimaryPart, info2, {["CFrame"] = (porta.Parent["DOOR2"].PrimaryPart.CFrame * CFrame.new(4.7,0,0))})
	somabrir.Parent = porta
	somabrir:Play()
	mover:Play()
	mover2:Play()
	mover2.Completed:Wait()
	somabrir:Destroy()
	wait(5)
	mover = tween:Create(porta.Parent["DOOR1"].PrimaryPart, info2, {["CFrame"] = (porta.Parent["DOOR1"].PrimaryPart.CFrame * CFrame.new(4.7,0,0))})
	mover2 = tween:Create(porta.Parent["DOOR2"].PrimaryPart, info2, {["CFrame"] = (porta.Parent["DOOR2"].PrimaryPart.CFrame * CFrame.new(-4.7,0,0))})
	somfechar.Parent = porta
	somfechar:Play()
	mover:Play()
	mover2:Play()
	mover2.Completed:Wait()
	somfechar:Destroy()
end

function portagrande(porta,configs)
	local mover = nil
	local somabrir, somfechar = script.SomAbrirG:Clone(), script.SomFecharG:Clone()
	mover = tween:Create(porta, info, {["Position"] = (porta.Position + Vector3.new(0,12,0))})
	somabrir.Parent = porta
	somabrir:Play()
	mover:Play()
	mover.Completed:Wait()
	somabrir:Destroy()
	wait(7)
	mover = tween:Create(porta, info, {["Position"] = (porta.Position + Vector3.new(0,-12,0))})
	somfechar.Parent = porta
	somfechar:Play()
	mover:Play()
	mover.Completed:Wait()
	somfechar:Destroy()
end


