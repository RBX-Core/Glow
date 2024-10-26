--!strict
local TestService = game:GetService("TestService")
local DECORATION = `• {string.rep("—", 25)} •`

local Glow = {}
export type Glow = typeof(Glow)

local function FormatCenter(text: string): string
	local textLength = string.len(text)
	local leftDashes = math.floor((25 - textLength - 2) / 2)
	local rightDashes = 25 - textLength - leftDashes - 2

	return `• {string.rep("—", leftDashes)} {text} {string.rep("—", rightDashes)} •`
end

local function FormatTrace(line: string): string
	local modulePath: string?, lineNum: string?, funcName: string? = 
		line:match("^(.+):(%d+)%s*(.*)$")

	if not (modulePath and lineNum) then
		return line
	end

	local formattedFunc = ""
	if funcName and funcName ~= "" then
		local name = funcName:match("function%s+([^%s]+)") 
			or funcName:match("function%s+'([^']+)'")

		if name then
			formattedFunc = `: function '{name}'`
		end
	end

	return `→ {modulePath} (line {lineNum}){formattedFunc}`
end

function Glow.FormatTable(tbl: { [any]: any }, indent: string, isLast: boolean, isRoot: boolean?): string
	local result: { string } = {}
	local current = 0
	local size = 0

	for _ in tbl do
		size += 1
	end

	for key, value in tbl do
		current += 1
		local isLastItem = current == size
		local connector = isLastItem and "└─ " or "├─ "

		if type(value) == "table" then
			table.insert(
				result, 
				indent .. connector .. `[{Glow.FormatValue(key)}]:`
			)

			local childIndent = indent .. (isLastItem and "   " or "│  ")
			local nestedResult = Glow.FormatTable(value, childIndent, isLastItem)
			table.insert(result, nestedResult)
		else
			local formattedValue = Glow.FormatValue(value)
			table.insert(
				result, 
				indent .. connector .. `[{key}]: {formattedValue}`
			)
		end
	end

	return table.concat(result, "\n")
end

function Glow.FormatValue(value: any): string
	if type(value) == "string" then
		return `"{value}"`
	end

	if type(value) == "number" then
		return tostring(value)
	end

	if type(value) == "table" then
		return `\n{Glow.FormatTable(value, "", false, true)}`
	end

	if typeof(value) == "Instance" then
		return tostring(value:GetFullName())
	end

	return typeof(value)
end

function Glow.FormatMessage(type: string, messageParts: { string }): string
	local concatenatedMessage = table.concat(messageParts, "\n• ")
	local stackTrace = debug.traceback(concatenatedMessage)
	local scriptLine = stackTrace:match("ServerScriptService[^\n]+") :: string

	local prefix = `\n\n{FormatCenter(type)}\n\n`
	local suffix = `{FormatTrace(scriptLine)}\n\n{DECORATION}\n\n`
	
	return `{prefix}• {concatenatedMessage}\n{#messageParts < 2 and "" or "\n"}{suffix}`
end

function Glow.Print(...: any)
	local messageParts: { string } = {}

	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end

	print(Glow.FormatMessage("PRINT", messageParts))
end

function Glow.Warn(...: any)
	local messageParts: { string } = {}

	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end

	TestService:Warn(false, Glow.FormatMessage("WARNING", messageParts))
end

function Glow.Error(...: any)
	local messageParts: { string } = {}

	for _, message in { ... } do
		table.insert(messageParts, Glow.FormatValue(message))
	end

	TestService:Error(Glow.FormatMessage("ERROR", messageParts))
	return coroutine.yield()
end

function Glow.Assert(condition: boolean, message: string?)
	if not condition then
		TestService:Error(Glow.FormatMessage(
			"ASSERTION", { message or "Assertion Failed!" }
		))
	end
	
	return coroutine.yield()
end

function Glow.Checkpoint(checkpointName: any)
	print(Glow.FormatMessage("CHECKPOINT", {
		Glow.FormatValue(checkpointName)
	}))
end

return Glow
