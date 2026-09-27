-- Authors: MILKMEOW
--[[
    Wrapper for Roblox InputAction objects.

    Responsibilities:
    - Manages the full lifecycle of an InputAction and its associated InputBindingHandlers.
    - Provides methods to configure properties but also exposes them via index and newindex.
    - Simplifies InputBindingHandler creation, retrieval, and removal.
    - Handles cleanup automatically via Trove.

    For advanced scenarios, you can access the underlying InputAction instance with GetInstance().
--]]

--// Imports //--
local Trove = require("./Trove")
local InputBindingHandler = require("./InputBindingHandler")
local TypesDefinition = require("./Types.d")

--// Types //--
type InputActionHandler = TypesDefinition.InputActionHandler

--// Constants //--
-- Whitelisted properties from the underlying InputAction instance that can be safely accessed or modified.
local PROPERTY_WHITELIST = {
	Type = true,
	Enabled = true,
}

-- Explicitly whitelisted custom properties
local CUSTOM_PROPERTIES = {
	_bindings = true,
}

--// Class //--

local InputActionHandler = {}
InputActionHandler.__index = function(self, key)
	local classValue = rawget(InputActionHandler, key)
	if classValue ~= nil then
		return classValue
	end

	local action = rawget(self, "_action")
	if action and PROPERTY_WHITELIST[key] then
		return action[key]
	end

	if CUSTOM_PROPERTIES[key] then
		return rawget(self, key)
	end

	error(`Unknown or private property '{key}'`, 2)
end

InputActionHandler.__newindex = function(self, key, value)
	local action = rawget(self, "_action")
	if action and PROPERTY_WHITELIST[key] then
		action[key] = value
		return
	end

	if CUSTOM_PROPERTIES[key] then
		rawset(self, key, value)
		return
	end

	error(`Cannot set unknown property '{key}'`, 2)
end

--[[
	Creates a new InputActionHandler.
	@param inputAction - The InputAction instance to track
]]
function InputActionHandler.new(inputAction: InputAction): InputActionHandler
	local self = {
		_trove = Trove.new(),
		_action = inputAction,
		_bindings = {},
	}

	self = setmetatable(self, InputActionHandler)
	self:_cacheBindings()

	return self
end

--// Configuration Methods //--

function InputActionHandler:SetType(actionType: Enum.InputActionType)
	self._action.Type = actionType
	return self
end

function InputActionHandler:SetEnabled(enabled: boolean)
	self._action.Enabled = enabled
	return self
end

--// Binding Management Methods //--

--[[
	Creates and adds a new binding, returns its handler for further configuration. Deletes any existing binding with the same name.
	@param name - Unique name for this binding
	@return InputBindingHandler
]]
function InputActionHandler:CreateBinding(name: string)
	local existingHandler = self._bindings[name]
	if existingHandler then
		existingHandler:Destroy()
	end

	local binding = Instance.new("InputBinding")
	binding.Name = name
	binding.Parent = self._action

	local handler = InputBindingHandler.new(binding)
	self._bindings[name] = handler
	self._trove:Add(handler)

	return handler
end

--[[
	Wraps an existing InputBinding in a handler. Deletes any existing binding with the same name.
	@param inputBinding - Existing InputBinding instance
	@return InputBindingHandler
]]
function InputActionHandler:WrapBinding(inputBinding: InputBinding)
	if inputBinding.Parent ~= self._action then
		inputBinding.Parent = self._action
	end
	local existingHandler = self._bindings[inputBinding.Name]
	if existingHandler then
		existingHandler:Destroy()
	end

	local handler = InputBindingHandler.new(inputBinding)
	self._bindings[inputBinding.Name] = handler
	self._trove:Add(handler)

	return handler
end

--[[
	Adds a keyboard binding with the specified KeyCode.
	@param name - Unique name for this binding
	@param keyCode - Enum.KeyCode for the key
]]
function InputActionHandler:AddBinding(name: string, keyCode: Enum.KeyCode)
	self:CreateBinding(name):SetKeyCode(keyCode)
	return self
end

--[[
	Adds a touch binding linked to a GuiButton.
	@param name - Unique name for this binding
	@param uiButton - GuiButton instance that triggers this binding
]]
function InputActionHandler:AddTouchBinding(name: string, uiButton: GuiButton)
	self:CreateBinding(name):SetUIButton(uiButton)
	return self
end

--[[
	Adds a WASD directional binding (requires Direction2D or Direction3D action type).
	@param name - Unique name for this binding
]]
function InputActionHandler:AddWASDBinding(name: string)
	self:CreateBinding(name):SetWASD()
	return self
end

--[[
	Adds an arrow keys directional binding (requires Direction2D or Direction3D action type).
	@param name - Unique name for this binding
]]
function InputActionHandler:AddArrowKeysBinding(name: string)
	self:CreateBinding(name):SetArrowKeys()
	return self
end

--[[
	Removes a binding by name.
	@param name - Name of the binding to remove
]]
function InputActionHandler:RemoveBinding(name: string)
	local handler = self._bindings[name]
	if handler then
		handler:Destroy()
		self._bindings[name] = nil
	end
	return self
end

--[[
	Gets a binding handler by name.
	@param name - Name of the binding
	@return InputBindingHandler?
]]
function InputActionHandler:GetBinding(name: string)
	return self._bindings[name]
end

--[[
	Gets all binding handlers.
	@return Dictionary of binding handlers
]]
function InputActionHandler:GetAllBindings()
	return self._bindings
end

--// Event Connection Methods //--

function InputActionHandler:OnPressed(callback: (state: any) -> ())
	self._trove:Connect(self._action.Pressed, callback)
	return self
end

function InputActionHandler:OnReleased(callback: (state: any) -> ())
	self._trove:Connect(self._action.Released, callback)
	return self
end

function InputActionHandler:OnStateChanged(callback: (state: any) -> ())
	self._trove:Connect(self._action.StateChanged, callback)
	return self
end

--// Utility Methods //--

--[[
	Updates the underlying InputAction to the given state and fires the appropriate signals.
	@param state - The new state to fire (must match the action's Type).
]]
function InputActionHandler:Fire(state: any)
	self._action:Fire(state)
end

--[[
	Returns the current state of the underlying InputAction.
	@return The current state.
]]
function InputActionHandler:GetState(): any
	return self._action:GetState()
end

function InputActionHandler:GetInstance(): InputAction
	return self._action
end

function InputActionHandler:Destroy()
	if self._action then
		self._action:Destroy()
	end
	self._trove:Destroy()
	table.clear(self._bindings)
end

function InputActionHandler:_cacheBindings()
	for _, child in self._action:GetChildren() do
		if child:IsA("InputBinding") then
			local handler = InputBindingHandler.new(child)
			self._bindings[child.Name] = handler
			self._trove:Add(handler)
		end
	end
end

return InputActionHandler
