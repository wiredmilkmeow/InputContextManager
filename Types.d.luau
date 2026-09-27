--!strict

export type InputContextHandler = {
	GetInstance: (self: InputContextHandler) -> InputContext,
	Destroy: (self: InputContextHandler) -> (),

	-- Config
	SetEnabled: (self: InputContextHandler, enabled: boolean) -> InputContextHandler,
	SetPriority: (self: InputContextHandler, priority: number) -> InputContextHandler,
	SetSink: (self: InputContextHandler, sink: boolean) -> InputContextHandler,
	SetParent: (self: InputContextHandler, parent: Instance) -> InputContextHandler,

	-- Dynamic properties
	Enabled: boolean?,
	Priority: number?,
	Sink: boolean?,
	Parent: Instance?,

	-- Custom properties
	_actions: { [string]: InputActionHandler },

	-- Action management
	CreateAction: (self: InputContextHandler, name: string, actionType: Enum.InputActionType?) -> InputActionHandler,
	WrapAction: (self: InputContextHandler, inputAction: InputAction) -> InputActionHandler,
	GetAction: (self: InputContextHandler, name: string) -> InputActionHandler?,
	GetAllActions: (self: InputContextHandler) -> { [string]: InputActionHandler },
	RemoveAction: (self: InputContextHandler, name: string) -> InputContextHandler,
}

export type InputActionHandler = {
	GetInstance: (self: InputActionHandler) -> InputAction,
	Destroy: (self: InputActionHandler) -> (),

	-- Config
	SetType: (self: InputActionHandler, actionType: Enum.InputActionType) -> InputActionHandler,
	SetEnabled: (self: InputActionHandler, enabled: boolean) -> InputActionHandler,

	-- Dynamic properties
	Type: Enum.InputActionType?,
	Enabled: boolean?,

	-- Custom properties
	_bindings: { [string]: InputBindingHandler },

	-- Action Methods
	Fire: (self: InputActionHandler, state: any) -> (),
	GetState: (self: InputActionHandler) -> any,

	-- Binding management
	CreateBinding: (self: InputActionHandler, name: string) -> InputBindingHandler,
	WrapBinding: (self: InputActionHandler, inputBinding: InputBinding) -> InputBindingHandler,
	GetBinding: (self: InputActionHandler, name: string) -> InputBindingHandler?,
	GetAllBindings: (self: InputActionHandler) -> { [string]: InputBindingHandler },
	RemoveBinding: (self: InputActionHandler, name: string) -> InputActionHandler,

	-- Convenience Binding Methods
	AddBinding: (self: InputActionHandler, name: string, keyCode: Enum.KeyCode) -> InputActionHandler,
	AddTouchBinding: (self: InputActionHandler, name: string, uiButton: GuiButton) -> InputActionHandler,
	AddWASDBinding: (self: InputActionHandler, name: string) -> InputActionHandler,
	AddArrowKeysBinding: (self: InputActionHandler, name: string) -> InputActionHandler,

	-- Events
	OnPressed: (self: InputActionHandler, callback: (state: any) -> ()) -> InputActionHandler,
	OnReleased: (self: InputActionHandler, callback: (state: any) -> ()) -> InputActionHandler,
	OnStateChanged: (self: InputActionHandler, callback: (state: any) -> ()) -> InputActionHandler,
}

export type InputBindingHandler = {
	GetInstance: (self: InputBindingHandler) -> InputBinding,
	Destroy: (self: InputBindingHandler) -> (),

	-- Dynamic properties
	KeyCode: Enum.KeyCode?,
	UIButton: GuiButton?,
	PressedThreshold: number?,
	ReleasedThreshold: number?,
	Scale: number?,
	Vector2Scale: Vector2?,
	Forward: Enum.KeyCode?,
	Backward: Enum.KeyCode?,
	Up: Enum.KeyCode?,
	Down: Enum.KeyCode?,
	Left: Enum.KeyCode?,
	Right: Enum.KeyCode?,

	-- Configuration methods
	SetKeyCode: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetUIButton: (self: InputBindingHandler, uiButton: GuiButton) -> InputBindingHandler,
	SetPressedThreshold: (self: InputBindingHandler, threshold: number) -> InputBindingHandler,
	SetReleasedThreshold: (self: InputBindingHandler, threshold: number) -> InputBindingHandler,
	SetScale: (self: InputBindingHandler, scale: number) -> InputBindingHandler,
	SetVector2Scale: (self: InputBindingHandler, scale: Vector2) -> InputBindingHandler,

	-- Directional
	SetDirections: (
		self: InputBindingHandler,
		directions: {
			Forward: Enum.KeyCode?,
			Backward: Enum.KeyCode?,
			Up: Enum.KeyCode?,
			Down: Enum.KeyCode?,
			Left: Enum.KeyCode?,
			Right: Enum.KeyCode?,
		}
	) -> InputBindingHandler,
	SetForward: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetBackward: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetUp: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetDown: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetLeft: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,
	SetRight: (self: InputBindingHandler, keyCode: Enum.KeyCode) -> InputBindingHandler,

	-- Presets
	SetWASD: (self: InputBindingHandler) -> InputBindingHandler,
	SetArrowKeys: (self: InputBindingHandler) -> InputBindingHandler,
}

return nil