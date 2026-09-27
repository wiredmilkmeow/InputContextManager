# InputContextManager

**A fluent and robust wrapper for Roblox's Input Action System with complete Luau type definitions for exposed objects and methods.**

---

## Purpose

Created to **decouple input logic from the Roblox Explorer hierarchy**, particularly for developers using Rojo, external editors, and structured project layouts.

MilkmeowInputContext provides a **code-based, fluent API** for creating and managing `InputContext`, `InputAction`, and `InputBinding` objects directly through Luau.

---

## Key Features

* **Fluent API:** Configure actions and bindings through method chaining.
* **Typed:** Full Luau type definitions for exposed objects and methods.
* **Automatic Cleanup:** Uses **Trove** for instance and connection lifecycle management.
* **Property Accessors:** Configure underlying Roblox objects through dot syntax.
* **Safe:** Errors when accessing private or unavailable properties.
* **Built-in Presets:** Quick WASD and Arrow Key bindings.
* **Directional Input:** Supports 1D, 2D, and 3D input actions.

---

## Basic Usage

```lua
local MilkmeowInputContext = require(path.to.InputContextManager)

local GameplayContext = MilkmeowInputContext.new("GameplayContext")

GameplayContext.Priority = 1000

local JumpAction = GameplayContext:CreateAction("Jump")
	:AddBinding("Keyboard", Enum.KeyCode.Space)
	:AddBinding("Gamepad", Enum.KeyCode.ButtonA)

JumpAction:OnPressed(function(state)
	print("Jump Pressed!", state)
end):OnReleased(function(state)
	print("Jump Released!", state)
end)
```

### Directional Input

```lua
local MoveAction = GameplayContext:CreateAction(
	"Move",
	Enum.InputActionType.Direction2D
)

MoveAction:AddWASDBinding("Movement")
```

---

## Cleanup

Contexts and their child actions/bindings can be cleaned up through the handler:

```lua
GameplayContext.Enabled = false

GameplayContext:Destroy()
```

---

## Installation

### Wally

```toml
InputContextManager = "milkmeow/input-context-manager"
```

### GitHub

```text
https://github.com/wiredmilkmeow/InputContextManager
```

---

## About

**InputContextManager** is a Luau utility by **Milkmeow**, built to make Roblox's Input Action System easier to configure and integrate into code-driven development workflows. 
