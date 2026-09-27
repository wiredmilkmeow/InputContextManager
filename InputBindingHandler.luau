-- Author: MILKMEOW
--[[
    Wrapper for Roblox InputBinding objects.

    Responsibilities:
    - Manages the lifecycle of an InputBinding instance.
    - Provides methods to configure properties but also exposes them via index and newindex.
    - Supports directional setups and presets such as WASD, Arrow Keys, and Thumbsticks.
    - Handles cleanup automatically via Trove.

    For advanced scenarios, you can access the underlying InputBinding instance with GetInstance().
--]]

--// Imports //--
local Trove = require("./Trove")
local TypesDefinition = require("./Types.d")

--// Types //--
type InputBindingHandler = TypesDefinition.InputBindingHandler

--// Constants //--
-- Whitelisted properties from the underlying InputBinding instance
local PROPERTY_WHITELIST = {
	KeyCode = true,
	UIButton = true,
	PressedThreshold = true,
	ReleasedThreshold = true,
	Scale = true,
	Vector2Scale = true,
	-- Directional KeyCodes
	Forward = true,
	Backward = true,
	Up = true,
	Down = true,
	Left = true,
	Right = true,
}

-- Explicitly whitelisted custom properties
local CUSTOM_PROPERTIES = {}

--// Class //--

local InputBindingHandler = {}
InputBindingHandler.__index = function(self, key)
	local classValue = rawget(InputBindingHandler, key)
	if classValue ~= nil then
		return classValue
	end

	local binding = rawget(self, "_binding")
	if binding and PROPERTY_WHITELIST[key] then
		return binding[key]
	end

	if CUSTOM_PROPERTIES[key] then
		return rawget(self, key)
	end

	error(`Unknown or private property '{key}'`, 2)
end

InputBindingHandler.__newindex = function(self, key, value)
	local binding = rawget(self, "_binding")
	if binding and PROPERTY_WHITELIST[key] then
		binding[key] = value
		return
	end

	if CUSTOM_PROPERTIES[key] then
		rawset(self, key, value)
		return
	end

	error(`Cannot set unknown property '{key}'`, 2)
end

function InputBindingHandler.new(inputBinding: InputBinding): InputBindingHandler
	local self = {
		_trove = Trove.new(),
		_binding = inputBinding,
	}

	self = setmetatable(self, InputBindingHandler)

	return self
end

--// Basic Configuration Methods //--

function InputBindingHandler:SetKeyCode(keyCode: Enum.KeyCode)
	self._binding.KeyCode = keyCode
	return self
end

function InputBindingHandler:SetUIButton(uiButton: GuiButton)
	self._binding.UIButton = uiButton
	return self
end

function InputBindingHandler:SetPressedThreshold(threshold: number)
	self._binding.PressedThreshold = threshold
	return self
end

function InputBindingHandler:SetReleasedThreshold(threshold: number)
	self._binding.ReleasedThreshold = threshold
	return self
end

function InputBindingHandler:SetScale(scale: number)
	self._binding.Scale = scale
	return self
end

function InputBindingHandler:SetVector2Scale(scale: Vector2)
	self._binding.Vector2Scale = scale
	return self
end

--// Directional Configuration Methods //--

--[[
	Sets directional KeyCodes for the binding.
	@param directions - Table with optional keys: Forward, Backward, Up, Down, Left, Right
	Each value should be an Enum.KeyCode
]]
function InputBindingHandler:SetDirections(directions: {
	Forward: Enum.KeyCode?,
	Backward: Enum.KeyCode?,
	Up: Enum.KeyCode?,
	Down: Enum.KeyCode?,
	Left: Enum.KeyCode?,
	Right: Enum.KeyCode?,
})
	if directions.Forward then
		self._binding.Forward = directions.Forward
	end
	if directions.Backward then
		self._binding.Backward = directions.Backward
	end
	if directions.Up then
		self._binding.Up = directions.Up
	end
	if directions.Down then
		self._binding.Down = directions.Down
	end
	if directions.Left then
		self._binding.Left = directions.Left
	end
	if directions.Right then
		self._binding.Right = directions.Right
	end
	return self
end

function InputBindingHandler:SetForward(keyCode: Enum.KeyCode)
	self._binding.Forward = keyCode
	return self
end

function InputBindingHandler:SetBackward(keyCode: Enum.KeyCode)
	self._binding.Backward = keyCode
	return self
end

function InputBindingHandler:SetUp(keyCode: Enum.KeyCode)
	self._binding.Up = keyCode
	return self
end

function InputBindingHandler:SetDown(keyCode: Enum.KeyCode)
	self._binding.Down = keyCode
	return self
end

function InputBindingHandler:SetLeft(keyCode: Enum.KeyCode)
	self._binding.Left = keyCode
	return self
end

function InputBindingHandler:SetRight(keyCode: Enum.KeyCode)
	self._binding.Right = keyCode
	return self
end

--// Preset Configurations //--

--[[
	Configures WASD keys for 2D directional movement.
]]
function InputBindingHandler:SetWASD()
	self._binding.Up = Enum.KeyCode.W
	self._binding.Down = Enum.KeyCode.S
	self._binding.Left = Enum.KeyCode.A
	self._binding.Right = Enum.KeyCode.D
	return self
end

--[[
	Configures arrow keys for 2D directional movement.
]]
function InputBindingHandler:SetArrowKeys()
	self._binding.Up = Enum.KeyCode.Up
	self._binding.Down = Enum.KeyCode.Down
	self._binding.Left = Enum.KeyCode.Left
	self._binding.Right = Enum.KeyCode.Right
	return self
end

--// Utility Methods //--

function InputBindingHandler:GetInstance(): InputBinding
	return self._binding
end

function InputBindingHandler:Destroy()
	if self._binding then
		self._binding:Destroy()
	end
	self._trove:Destroy()
end

return InputBindingHandler
