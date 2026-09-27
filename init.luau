-- Authors: MILKMEOW
--[[
    Wrapper for Roblox InputContext objects.

    Responsibilities:
    - Manages the full lifecycle of an InputContext and its associated InputActionHandlers.
    - Provides methods to configure properties but also exposes them via index and newindex.
    - Simplifies InputActionHandler creation, retrieval, and removal.
    - Handles cleanup automatically via Trove.

    For advanced scenarios, you can access the underlying InputContext instance with GetInstance().
--]]

--// Imports //--
local Trove = require("@self/Trove")
local InputActionHandler = require("@self/InputActionHandler")
local TypesDefinition = require("@self/Types.d")

--// Types //--
type InputContextHandler = TypesDefinition.InputContextHandler

--// Constants //--
-- Whitelisted properties from the underlying InputContext instance that can be safely accessed or modified.
local PROPERTY_WHITELIST = {
	Enabled = true,
	Priority = true,
	Sink = true,
	Parent = true,
}

-- Explicitly whitelisted custom properties
local CUSTOM_PROPERTIES = {
	_actions = true,
}

--// Class //--

local InputContextHandler = {}
InputContextHandler.__index = function(self, key)
	local classValue = rawget(InputContextHandler, key)
	if classValue ~= nil then
		return classValue
	end

	local context = rawget(self, "_context")
	if context and PROPERTY_WHITELIST[key] then
		return context[key]
	end

	if CUSTOM_PROPERTIES[key] then
		return rawget(self, key)
	end

	error(`Unknown or private property '{key}'`, 2)
end

InputContextHandler.__newindex = function(self, key, value)
	local context = rawget(self, "_context")
	if context and PROPERTY_WHITELIST[key] then
		context[key] = value
		return
	end

	if CUSTOM_PROPERTIES[key] then
		rawset(self, key, value)
		return
	end

	error(`Cannot set unknown property '{key}'`, 2)
end

--[[
	Creates a new InputContextHandler.
	@param name - Name for the InputContext
	@param parent - Optional parent (defaults to nil, set via SetParent if needed)
]]
function InputContextHandler.new(name: string, parent: Instance?): InputContextHandler
	local context = Instance.new("InputContext")
	context.Name = name

	local self = {
		_trove = Trove.new(),
		_context = context,
		_actions = {},
	}

	self = setmetatable(self, InputContextHandler)

	if parent then
		self._context.Parent = parent
	end

	self:_cacheActions()

	return self
end

--// Configuration Methods //--

function InputContextHandler:SetEnabled(enabled: boolean)
	self._context.Enabled = enabled
	return self
end

function InputContextHandler:SetPriority(priority: number)
	self._context.Priority = priority
	return self
end

function InputContextHandler:SetSink(sink: boolean)
	self._context.Sink = sink
	return self
end

function InputContextHandler:SetParent(parent: Instance)
	self._context.Parent = parent
	return self
end

--// Action Management Methods //--

--[[
	Creates a new InputAction and returns its handler. Deletes any existing action with the same name.
	@param name - Name for the InputAction
	@param actionType - Optional Enum.InputActionType (defaults to Bool)
	@return InputActionHandler
]]
function InputContextHandler:CreateAction(name: string, actionType: Enum.InputActionType?)
	local existingHandler = self._actions[name]
	if existingHandler then
		existingHandler:Destroy()
	end

	local action = Instance.new("InputAction")
	action.Name = name
	action.Type = actionType or Enum.InputActionType.Bool
	action.Parent = self._context

	local handler = InputActionHandler.new(action)
	self._actions[name] = handler
	self._trove:Add(handler)

	return handler
end

--[[
	Wraps an existing InputAction in a handler. Deletes any existing action with the same name.
	@param inputAction - Existing InputAction instance
	@return InputActionHandler
]]
function InputContextHandler:WrapAction(inputAction: InputAction)
	if inputAction.Parent ~= self._context then
		inputAction.Parent = self._context
	end
	local existingHandler = self._actions[inputAction.Name]
	if existingHandler then
		existingHandler:Destroy()
	end

	local handler = InputActionHandler.new(inputAction)
	self._actions[inputAction.Name] = handler
	self._trove:Add(handler)

	return handler
end

--[[
	Gets an action handler by name.
	@param name - Name of the action
	@return InputActionHandler?
]]
function InputContextHandler:GetAction(name: string)
	return self._actions[name]
end

--[[
	Gets all action handlers.
	@return Dictionary of action handlers
]]
function InputContextHandler:GetAllActions()
	return self._actions
end

--[[
	Removes an action by name.
	@param name - Name of the action to remove
]]
function InputContextHandler:RemoveAction(name: string)
	local handler = self._actions[name]
	if handler then
		handler:Destroy()
		self._actions[name] = nil
	end
	return self
end

--// Utility Methods //--

function InputContextHandler:GetInstance()
	return self._context
end

function InputContextHandler:Destroy()
	if self._context then
		self._context:Destroy()
	end
	self._trove:Destroy()
	table.clear(self._actions)
end

--// Private Methods //--

function InputContextHandler:_cacheActions()
	for _, child in self._context:GetChildren() do
		if child:IsA("InputAction") then
			local handler = InputActionHandler.new(child)
			self._actions[child.Name] = handler
			self._trove:Add(handler)
		end
	end
end

return InputContextHandler
