local WINDOW_ID = 42

-- luassert spies are callable tables; the mod only accepts real functions.
local function fn(s)
	return function(...) return s(...) end
end

describe("dont_auto_pin", function()
	local builtinWindow, original, received, replacement, replacementApi, moved, pinned, now

	local function windowProps(overrides)
		local p = {
			pinnable = true,
			pinned = false,
			onMovedChange = fn(moved),
			onPinned = fn(pinned),
		}
		for k, v in pairs(overrides or {}) do
			p[k] = v
		end
		return p
	end

	local function render(props)
		replacement(props)
		return received[1]
	end

	local function load()
		tf3.require("gui/fenris_dont_auto_pin/dont_auto_pin.script").doReplace(replacementApi)
	end

	before_each(function()
		tf3.reset()
		_G.log = { message = spy.new(function() end), warning = spy.new(function() end) }
		now = 100
		_G.api = { util = { getApplicationTime = function() return now end } }
		moved = spy.new(function() end)
		pinned = spy.new(function() end)
		builtinWindow = function() end
		-- Spies record copies of table arguments, so keep the received ones for identity checks.
		received = nil
		original = spy.new(function(...)
			received = { ... }
			return "node"
		end)
		_G._react = { originalRecipeFn = { [WINDOW_ID] = fn(original) } }
		tf3.fake("::/gui/main/react.lua", {
			GetRecipeId = function(recipe) return recipe == builtinWindow and WINDOW_ID or nil end,
		})
		tf3.fake("::/gui/main/builtin.lua", { Window = builtinWindow })
		replacement = nil
		replacementApi = {
			ReplaceRecipe = spy.new(function(recipe, r)
				assert.equal(builtinWindow, recipe)
				replacement = r
			end),
		}
	end)

	describe("with the game internals present", function()
		before_each(load)

		it("replaces builtin.Window", function()
			assert.is_function(replacement)
			assert.spy(log.message).was_called_with("fenris_dont_auto_pin: builtin.Window replaced")
		end)

		it("unpins an unpinned window after the game's move handler pinned it", function()
			render(windowProps()).onMovedChange("arg")
			assert.spy(moved).was_called_with("arg")
			assert.spy(pinned).was_called_with(false)
		end)

		it("leaves a pinned window pinned when moved", function()
			render(windowProps({ pinned = true })).onMovedChange()
			assert.spy(moved).was_called(1)
			assert.spy(pinned).was_not_called()
		end)

		it("keeps move-to-pin for windows without a pin button", function()
			local props = windowProps({ pinnable = false })
			assert.equal(props, render(props))
		end)

		it("passes props through when a callback is missing", function()
			local props = windowProps({ onPinned = "not a function" })
			assert.equal(props, render(props))
		end)

		it("does not modify the caller's props", function()
			local props = windowProps()
			local onMovedChange = props.onMovedChange
			render(props)
			assert.equal(onMovedChange, props.onMovedChange)
		end)

		describe("dragging a window with an id", function()
			local function drag(props, times)
				local onMovedChange = render(props).onMovedChange
				for _, t in ipairs(times) do
					now = t
					onMovedChange()
				end
			end

			it("runs the game's handler and unpins once at the start of a drag", function()
				drag(windowProps({ id = "w" }), { 100 })
				assert.spy(moved).was_called(1)
				assert.spy(pinned).was_called_with(false)
			end)

			it("skips repeat calls within the same drag", function()
				drag(windowProps({ id = "w" }), { 100, 100.02, 100.2 })
				assert.spy(moved).was_called(1)
				assert.spy(pinned).was_called(1)
			end)

			it("treats a long continuous drag as one drag", function()
				local times = {}
				for i = 0, 50 do
					times[#times + 1] = 100 + i * 0.02
				end
				drag(windowProps({ id = "w" }), times)
				assert.spy(moved).was_called(1)
			end)

			it("starts a new drag after a pause", function()
				drag(windowProps({ id = "w" }), { 100, 101 })
				assert.spy(moved).was_called(2)
				assert.spy(pinned).was_called(2)
			end)

			it("keeps the drag state across re-renders", function()
				drag(windowProps({ id = "w" }), { 100 })
				drag(windowProps({ id = "w" }), { 100.02 })
				assert.spy(moved).was_called(1)
			end)

			it("tracks windows separately", function()
				drag(windowProps({ id = "a" }), { 100 })
				drag(windowProps({ id = "b" }), { 100.02 })
				assert.spy(moved).was_called(2)
			end)

			it("unpins on every call for a window without an id", function()
				drag(windowProps(), { 100, 100.02 })
				assert.spy(pinned).was_called(2)
			end)
		end)

		it("passes every argument through and returns the original's result", function()
			local props = windowProps({ pinnable = false })
			assert.equal("node", replacement(props, nil, "extra"))
			assert.spy(original).was_called_with(props, nil, "extra")
		end)
	end)

	it("leaves auto-pinning unchanged when _react.originalRecipeFn is missing", function()
		_G._react = {}
		load()
		assert.spy(replacementApi.ReplaceRecipe).was_not_called()
		assert.spy(log.warning).was_called_with("fenris_dont_auto_pin: builtin.Window left unchanged: _react.originalRecipeFn not found")
	end)

	it("leaves auto-pinning unchanged when the original builtin.Window is missing", function()
		_G._react = { originalRecipeFn = {} }
		load()
		assert.spy(replacementApi.ReplaceRecipe).was_not_called()
		assert.spy(log.warning).was_called_with("fenris_dont_auto_pin: builtin.Window left unchanged: original recipe not found")
	end)
end)
