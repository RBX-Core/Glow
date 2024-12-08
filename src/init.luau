--!strict

--[[
    Glow (Logging Module)
    Provides enhanced logging and debugging utilities for Roblox
    
    Features:
    - Formatted print, warn, and error messages
    - Detailed stack trace tracking
    - Assertion and checkpoint functionality
    
    Rojo Compatibility:
    - Can be placed in src/ directory
    - Exports Glow module for use across project
]]

local TestService = game:GetService("TestService")

-- Constants
local DECORATION = `• {string.rep("—", 25)} •`

-- Glow Module Definition
local Glow = {}
export type Glow = typeof(Glow)

--[[
    Formats a decoration line with centered text
    @param text The text to center in the decoration
    @return Formatted decoration string
]]
function Glow.FormatDecoration(text: string): string
	local textLength = #text
	local leftDashes = math.floor((25 - textLength - 2) / 2)
	local rightDashes = 25 - textLength - leftDashes - 2
	
	return `• {string.rep("—", leftDashes)} {text} {string.rep("—", rightDashes)} •`
end

--[[
    Parses and formats debug trace lines
    @param lines Raw stack trace lines
    @return Formatted stack trace
]]
function Glow.FormatDebugTrace(lines: string): string
	local result: string = ""

	for _, line in lines:split("\n") do
		local modulePath, lineNum, funcName = 
			line:match("^(.+):(%d+)%s*(.*)$")

		result ..= "\n"

		if not (modulePath and lineNum) then
			result ..= line
			continue
		end

		local formattedFunc = ""
		if funcName and funcName ~= "" then
			local name = funcName:match("function%s+([^%s]+)") 
				or funcName:match("function%s+'([^']+)'")
			if name then
				formattedFunc = `: function '{name}'`
			end
		end

		result ..= `→ {modulePath} (line {lineNum}){formattedFunc}`
	end

	return result:sub(2)
end

--[[
    Converts a table to a formatted string representation
    @param tbl Table to format
    @return Formatted table string
]]
function Glow.FormatTable(tbl: { [any]: any }, indent: number?): string
	local result: { string } = {}
	local indent = indent or 0
	
	for key, value in tbl do
		local stringifiedKey = typeof(key) == "string" 
			and `"{tostring(key)}"` 
			or tostring(key)

		table.insert(result, `\t{("	"):rep(indent)}[{stringifiedKey}] = {Glow.FormatValue(value, indent + 1)}`)
	end

	return "{\n" .. table.concat(result, ",\n") .. `\n{("	"):rep(indent)}}`
end

--[[
    Formats different value types for logging
    @param value Value to format
    @return Formatted string representation of the value
]]
function Glow.FormatValue(value: any, ...): string
	local valueType = type(value)

	if valueType == "string" then
		return `"{value}"`
	elseif valueType == "number" then
		return tostring(value)
	elseif valueType == "boolean" then
		return tostring(value)
	elseif valueType == "table" then
		return Glow.FormatTable(value, ...)
	elseif typeof(value) == "Instance" then
		return `game.{value:GetFullName()}`
	end

	return typeof(value)
end

--[[
    Formats a complete log message with decoration and stack trace
    @param type Message type (PRINT, WARNING, ERROR, etc.)
    @param messageParts Array of message components
    @return Fully formatted log message
]]
function Glow.FormatMessage(type: string, messageParts: { string }): string
	local concatenatedMessage = table.concat(messageParts, "\n• ")
	local stackTrace = debug.traceback(concatenatedMessage)

	local lines = {}
	for line in stackTrace:gmatch("([^\n]+)") do
		table.insert(lines, line)
	end

	local scriptLine = table.concat(lines, "\n", 3 + #concatenatedMessage:split("\n"))

	local prefix = `\n\n{Glow.FormatDecoration(type)}\n\n`
	local suffix = `{Glow.FormatDebugTrace(scriptLine)}\n\n{DECORATION}\n\n`

	return `{prefix}• {concatenatedMessage}\n{#messageParts < 2 and "" or "\n"}{suffix}`
end

--[[
    Enhanced print function with formatting
    @param ... Variable number of arguments to print
]]
function Glow.Print(...: any)
	local messageParts: { string } = {}
	
	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end
	
	print(Glow.FormatMessage("PRINT", messageParts))
end

--[[
    Enhanced warn function with formatting
    @param ... Variable number of arguments to warn about
]]
function Glow.Warn(...: any)
	local messageParts: { string } = {}
	
	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end
	
	TestService:Warn(false, Glow.FormatMessage("WARNING", messageParts))
end

--[[
    Enhanced error function with formatting and coroutine yield
    @param ... Variable number of arguments describing the error
]]
function Glow.Error(...: any)
	local messageParts: { string } = {}
	
	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end
	
	TestService:Error(Glow.FormatMessage("ERROR", messageParts))
	return coroutine.yield()
end

--[[
    Assertion function with enhanced error reporting
    @param condition Boolean condition to test
    @param message Optional custom error message
]]
function Glow.Assert(condition: boolean, message: string?)
	if condition then
		return
	end
	
	return TestService:Error(Glow.FormatMessage(
		"ASSERTION", { message or "Assertion Failed!" }
		)
	)
end

--[[
    Checkpoint logging function
    @param checkpointName Identifier for the checkpoint
]]
function Glow.Checkpoint(checkpointName: any)
	TestService:Message(Glow.FormatMessage("CHECKPOINT", {
		Glow.FormatValue(checkpointName)
	}))
end

return Glow
