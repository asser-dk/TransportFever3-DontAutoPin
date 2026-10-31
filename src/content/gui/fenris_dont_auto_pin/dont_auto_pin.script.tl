local react = ug_require "::/gui/main/react.lua" as React
local builtin = ug_require "::/gui/main/builtin.lua" as Builtin

global _react : table

local dont_auto_pin = {}

-- The game calls onMovedChange about once per frame while a window is dragged (~27 ms apart), so a
-- longer gap means a new drag. In seconds, like api.util.getApplicationTime.
local DRAG_GAP = 0.25

local lastMoveTime : {string : number} = {}

-- From tf3_lib/recipe_wrap.tl
local type Transform = function(any) : any
local type RecipeFn = function(...: any) : TreeNodeId

local recipe_wrap = {}

-- The game's recipe function behind a builtin, or nil and why not.
function recipe_wrap.original(recipe : any) : RecipeFn, string
	local originals = type(_react) == "table" and _react.originalRecipeFn or nil
	if type(originals) ~= "table" then
		return nil, "_react.originalRecipeFn not found"
	end
	local fn = (originals as {number : any})[react.GetRecipeId(recipe as IRecipe)]
	if type(fn) ~= "function" then
		return nil, "original recipe not found"
	end
	return fn as RecipeFn, nil
end

-- Replaces the builtin; false (and a warning "<prefix>: <name> left unchanged: <reason>") when the
-- original can't be found.
function recipe_wrap.wrapBuiltin(replacementApi : ReactReplacementApi, recipe : any, name : string, transform : Transform, prefix : string, warn? : function(string)) : boolean
	local callOriginal, reason = recipe_wrap.original(recipe)
	if callOriginal == nil then
		(warn or log.warning)(prefix .. ": " .. name .. " left unchanged: " .. reason)
		return false
	end
	local function wrapped(...: any) : TreeNodeId
		local args = table.pack(...)
		for i = 1, args.n do
			args[i] = transform(args[i])
		end
		return callOriginal(table.unpack(args, 1, args.n))
	end
	replacementApi.ReplaceRecipe(recipe, wrapped as any)
	return true
end

-- A shallow copy of a props table with the given keys replaced; the game's own table stays as it is.
function recipe_wrap.withProps(props : {string : any}, changes : {string : any}) : {string : any}
	local copy : {string : any} = {}
	for k, v in pairs(props) do
		copy[k] = v
	end
	for k, v in pairs(changes) do
		copy[k] = v
	end
	return copy
end

local function withUnpinAfterMove(value : any) : any
	if type(value) ~= "table" then
		return value
	end
	local props = value as {string : any}
	if props.pinnable ~= true or type(props.onMovedChange) ~= "function" or type(props.onPinned) ~= "function" then
		return value
	end
	local onMovedChange = props.onMovedChange as function(...: any)
	local onPinned = props.onPinned as function(boolean)

	local wasPinned = props.pinned == true
	local id = type(props.id) == "string" and props.id as string or nil
	return recipe_wrap.withProps(props, {
		onMovedChange = function(...: any)
			if wasPinned then
				onMovedChange(...)
				return
			end
			if id then
				local now = api.util.getApplicationTime()
				local last = lastMoveTime[id]
				lastMoveTime[id] = now
				-- Same drag: pinning and unpinning again on every frame re-renders the window each time and
				-- makes dragging choppy. The game's handler already ran once when this drag started.
				if last and now - last < DRAG_GAP then
					return
				end
			end
			onMovedChange(...)
			onPinned(false)
		end,
	})
end

function dont_auto_pin.doReplace(replacementApi : ReactReplacementApi)
	if not recipe_wrap.wrapBuiltin(replacementApi, builtin.Window, "builtin.Window", withUnpinAfterMove, "fenris_dont_auto_pin") then
		return
	end
	log.message("fenris_dont_auto_pin: builtin.Window replaced")
end

return dont_auto_pin
