local react = ug_require "::/gui/main/react.lua" as React
local builtin = ug_require "::/gui/main/builtin.lua" as Builtin

global _react : table

local dont_auto_pin = {}

local function withUnpinAfterMove(value : any) : any
	if type(value) ~= "table" then
		return value
	end
	local props = value as {string : any}
	if props.pinnable ~= true or type(props.onMovedChange) ~= "function" or type(props.onPinned) ~= "function" then
		return value
	end
	local onMovedChange = props.onMovedChange as function()
	local onPinned = props.onPinned as function(boolean)

	local copy : {string : any} = {}
	for k, v in pairs(props) do
		copy[k] = v
	end
	copy.onMovedChange = function()
		local wasPinned = props.pinned == true
		onMovedChange()
		if not wasPinned then
			onPinned(false)
		end
	end
	return copy
end

function dont_auto_pin.doReplace(replacementApi : ReactReplacementApi)
	local originalRecipeFns = type(_react) == "table" and _react.originalRecipeFn or nil
	if type(originalRecipeFns) ~= "table" then
		log.warning("fenris_dont_auto_pin: _react.originalRecipeFn not found, auto-pinning left unchanged")
		return
	end
	local originalWindow = (originalRecipeFns as {number : any})[react.GetRecipeId(builtin.Window as IRecipe)]
	if type(originalWindow) ~= "function" then
		log.warning("fenris_dont_auto_pin: original builtin.Window not found, auto-pinning left unchanged")
		return
	end
	local callOriginal = originalWindow as function(...: any) : TreeNodeId

	local function window(...: any) : TreeNodeId
		local args = table.pack(...)
		for i = 1, args.n do
			args[i] = withUnpinAfterMove(args[i])
		end
		return callOriginal(table.unpack(args, 1, args.n))
	end

	replacementApi.ReplaceRecipe(builtin.Window as any, window as any)
	log.message("fenris_dont_auto_pin: builtin.Window replaced")
end

return dont_auto_pin
