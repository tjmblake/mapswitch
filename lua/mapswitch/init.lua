local M                             = {}
M._keymaps                          = {}
M._stack                            = {}

M._get_current_keymap_by_new_keymap = function(keymap)
	local currentMappings = vim.api.nvim_get_keymap(keymap.mode)

	for _, currentMap in ipairs(currentMappings) do
		if currentMap.lhs == keymap.lhs then
			return currentMap
		end
	end

	return {
		mode = keymap.mode,
		lhs = keymap.lhs,
		rhs = "<Nop>"
	}
end

M._get_current_keymaps              = function(keymaps)
	local filtered = {}

	for _, keymap in pairs(keymaps) do
		local match = M._get_current_keymap_by_new_keymap(keymap)
		table.insert(filtered, match)
	end

	return filtered
end

M.check_keymap_exists               = function(name)
	if M._keymaps[name] == nil then
		error("Cannot find keymaps for " .. name)
	end
end

M.set_from_keymaps                  = function(keymaps)
	for _, keymap in ipairs(keymaps) do
		vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs)
	end
end

M.setup                             = function(config)
	for name, keymaps in pairs(config) do
		for _, keymap in pairs(keymaps) do
			keymap.mode = keymap[1]
			keymap.lhs = keymap[2]
			keymap.rhs = keymap[3]
		end
		M._keymaps[name] = keymaps
	end
end

M.enable = function(name)
	M.check_keymap_exists(name)

	local mapLayer = {
		name = name,
		old = M._get_current_keymaps(M._keymaps[name]),
	}

	M.set_from_keymaps(M._keymaps[name])

	mapLayer.new = M._get_current_keymaps(M._keymaps[name])

	M._stack[#M._stack + 1] = mapLayer
end

M.disable = function(name)
	M.check_keymap_exists(name)

	if M._stack[#M._stack].name ~= name then
		error(name .. " not at top of stack")
	end

	M.set_from_keymaps(M._stack[#M._stack].old)
	table.remove(M._stack, #M._stack)
end

M.setup({
	debug = {
		{
			mode = "n",
			lhs = " gs",
			rhs = ":lua print('gs')",
		}
	},
	test = {
		{
			mode = "n",
			lhs = " hi",
			rhs = ":lua print('hi!')",
		},
		{
			mode = "n",
			lhs = " hi2",
			rhs = ":lua print('hi2!')",
		}
	}
})

return M
