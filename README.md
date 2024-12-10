# 🦺 Glow Logging Module

## Overview

Glow is a powerful, feature-rich logging and debugging utility for Roblox Luau projects. Glow offers comprehensive logging, error tracking, and diagnostics with beautifully formatted output.

## Features

- 🖨️ Enhanced Print Functionality
- ⚠️ Advanced Warning System
- 🚨 Detailed Error Reporting
- ✅ Smart Assertion Tracking
- 📍 Checkpoint Logging
- 🔍 Intelligent Value Formatting

## Installation

### Rojo Setup

1. Ensure Rojo is installed in your project
2. Place the `Glow.lua` file in your `src/` directory
3. Sync your project

### Manual Installation

Simply copy the `Glow.lua` script into your Roblox project's appropriate module location.

## Usage Examples

### Basic Logging

```lua
local Glow = require(path.to.Glow)

-- Print with enhanced formatting
Glow.Print("Hello, World!")

-- Log a complex value
Glow.Print({ name = "Player", score = 100 })
```

### Warnings and Errors

```lua
-- Generate a warning
Glow.Warn("Potential performance issue detected")

-- Throw a formatted error
Glow.Error("Critical system failure")
```

### Assertions

```lua
-- Simple assertion
Glow.Assert(player.Health > 0, "Player must be alive")

-- Complex condition checking
Glow.Assert(
    #inventory.items > 0, 
    "Inventory cannot be empty"
)
```

### Checkpoints

```lua
-- Log progress through complex processes
Glow.Checkpoint("Initialization Started")
-- ... some code ...
Glow.Checkpoint("Loading Assets")
-- ... more code ...
Glow.Checkpoint("Ready to Play")
```

## Output Formatting

Glow provides richly formatted output with:
- Decorative borders
- Automatic value stringification
- Detailed stack trace information
- Color-coded message types

## Type Support

Supports logging of various types:
- Strings
- Numbers
- Tables
- Instances
- And more!

## Performance Considerations

- Minimal overhead
- Strict mode compatible
- Optimized for Roblox Lua/Luau

## License

Distributed under the MIT License. See `LICENSE` for more information.


---

**Created with ❤️ by [Pcoi94]**
