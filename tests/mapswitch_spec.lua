local testMap = { "n", " abc", ":lua print('edited')" }

local functionMap = { "n", " abc", function() return true end }

local initialMap = {
	mode = "n",
	lhs = " abc",
	rhs = ":lua print('abc')"
}

local getCommandByLhs = function(lhs)
	local maps = vim.api.nvim_get_keymap("n")

	for _, map in ipairs(maps) do
		if map.lhs == lhs then
			return map
		end
	end
end

local clear = function()
	require('mapswitch')._stack = {}
	require('mapswitch')._keymaps = {}
end

local setDefaultMapping = function()
	vim.keymap.set("n", " abc", initialMap.rhs)
end

local setupPlugin = function(config)
	require('mapswitch').setup(config)
end

describe("mapswitch", function()
	it("can be required", function()
		require("mapswitch")
	end)
end)

describe("mapswitch.setup", function()
	before_each(function()
		clear()
	end)

	it("can be setup", function()
		require("mapswitch").setup({
			name = { testMap }
		})
	end)

	it("stores mappings name", function()
		require("mapswitch").setup({
			name = { testMap }
		})
		assert(require("mapswitch")._keymaps)
		assert(require("mapswitch")._keymaps.name[1] == testMap)
	end)
end)

describe("mapswitch.add", function()
	before_each(function()
		clear()
		setDefaultMapping()
		setupPlugin({ name = { testMap }, func = { functionMap } })
	end)

	it("replaces keymap", function()
		require("mapswitch").enable('name')

		local cmd = getCommandByLhs(" abc")

		assert(cmd.rhs == testMap.rhs)
	end)

	it("replaces keymap if function", function()
		require("mapswitch").enable('func')

		local cmd = getCommandByLhs(" abc")

		assert(cmd.callback() == true)
	end)

	it("adds to the stack", function()
		require("mapswitch").enable('name')

		assert(#require("mapswitch")._stack == 1)
	end)
end)

describe("mapswitch.unswitch", function()
	before_each(function()
		clear()
		setDefaultMapping()
		setupPlugin({ name = { testMap }, func = { functionMap } })
	end)

	it("resets mapping", function()
		require("mapswitch").enable('name')
		require("mapswitch").disable("name")

		local cmd = getCommandByLhs(" abc")

		assert(cmd.rhs == initialMap.rhs)
	end)

	it("resets mapping if function", function()
		require("mapswitch").enable('func')
		require("mapswitch").disable("func")

		local cmd = getCommandByLhs(" abc")

		assert(cmd.rhs == initialMap.rhs)
	end)

	it("remove from the stack", function()
		require("mapswitch").enable('name')
		require("mapswitch").disable("name")

		assert(#require("mapswitch")._stack == 0)
	end)
end)
