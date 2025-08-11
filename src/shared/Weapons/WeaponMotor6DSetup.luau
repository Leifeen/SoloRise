
WeaponSetup = {}


-- NOTE: MAKE SURE THEY'RE LISTED ALPHABETICALLY

-- Services
local ServerStorage = game:GetService("ServerStorage")

-- References

-- Variables

-- Types

-- Folders
local Weapons = ServerStorage:WaitForChild("JADX_CombatFramework").Weapons
local DaggerFolder = Weapons.Dagger
local DualWieldFolder = Weapons["Dual Wield"]
local GreatSwordFolder = Weapons["Great Sword"]
local SwordFolder = Weapons.Sword

-- Modules

-- Functions
function WeaponSetup.Dagger(Character: Model): true?

	local characterWeapon = Character:FindFirstChild("Handle")
	if not characterWeapon then
		local newDagger = DaggerFolder.Handle:Clone()
		newDagger.Parent = Character
		
		
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Parent = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part0 = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part1 = newDagger
		Motor6D.C0 = CFrame.new(-0.022, -0.988, -0.043) * CFrame.fromOrientation(math.rad(90), math.rad(-0), math.rad(0))
		Motor6D.C1 = CFrame.new(0, -0.5, -0)
		
			return newDagger

	else
		
	end
	return true
end

function WeaponSetup.DualWield(Character: Model): true?
	local leftHandle = Character:FindFirstChild("Left Handle") :: any
	local rightHandle = Character:FindFirstChild("Right Handle") :: BasePart
	
	if not leftHandle and not rightHandle then
		local newLeftHandle = DualWieldFolder["Left Handle"]:Clone()
		newLeftHandle.Parent = Character
		
		local leftMotor6D = Instance.new("Motor6D")
		leftMotor6D.Parent = Character:WaitForChild("Left Arm") :: BasePart
		leftMotor6D.Name = "Left Handle"
		leftMotor6D.Part0 = Character:WaitForChild("Left Arm") :: BasePart
		leftMotor6D.Part1 = newLeftHandle
		leftMotor6D.C0 = CFrame.new(-0.076, -0.959, -0.013) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
		leftMotor6D.C1 = CFrame.new(0, 0, 0) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
		
		local newRightHandle = DualWieldFolder["Right Handle"]:Clone()
		newRightHandle.Parent = Character
		
		local rightMotor6D = Instance.new("Motor6D")
		rightMotor6D.Parent = Character:WaitForChild("Right Arm") :: BasePart
		rightMotor6D.Name = "Right Handle"
		rightMotor6D.Part0 = Character:WaitForChild("Right Arm") :: BasePart
		rightMotor6D.Part1 = newRightHandle
		rightMotor6D.C0 = CFrame.new(0.003, -1.004, -0.013) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
		rightMotor6D.C1 = CFrame.new(0, 0, 0) * CFrame.fromOrientation(math.rad(0), math.rad(90), math.rad(0))
		
		local weaponValue = Instance.new("BoolValue")
		weaponValue.Parent = Character
		weaponValue.Name = "Weapon"
	else
		leftHandle:Destroy()
		rightHandle:Destroy()
		local weaponValue = Character:FindFirstChild("Weapon")
		if not weaponValue then
			return
		end
		weaponValue:Destroy()
	end
	return true
end

function WeaponSetup.GreatSword(Character: Model): true?
	local characterWeapon = Character:FindFirstChild("Darksteel Greatsword")
	if not characterWeapon then
		local newGreatSword = GreatSwordFolder["Darksteel Greatsword"]:Clone()
		newGreatSword.Parent = Character
		
		
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Parent = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part0 = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part1 = newGreatSword
		Motor6D.C0 = CFrame.new(-.101, -.965, 0) * CFrame.fromOrientation(math.rad(0), math.rad(180), math.rad(90))
		Motor6D.C1 = CFrame.new(0, 0, -2.189)
		Motor6D.Name = "Darksteel Greatsword"

		return newGreatSword

	else
		
	end
	return true
end

function WeaponSetup.Sword(Character: Model): true?	
	local characterWeapon = Character:FindFirstChild("MainHandle")
	if not characterWeapon then
		local newSword = SwordFolder.MainHandle:Clone()
		newSword.Parent = Character
		
	
		local Motor6D = Instance.new("Motor6D")
		Motor6D.Name = "MainHandle"
		Motor6D.Parent = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part0 = Character:WaitForChild("Right Arm") :: BasePart
		Motor6D.Part1 = newSword
		Motor6D.C0 = CFrame.new(-0.014, -1.069, 0.014) * CFrame.fromOrientation(math.rad(-90), math.rad(0), math.rad(0))
		Motor6D.C1 = CFrame.new(-0.12, 0, 0)
	
		return newSword
	else
	
	
	end
	
	return true
	
end

-- Event Listeners

-- Game Loop

-- Initialization
return WeaponSetup


