if not minetest.get_modpath('canned_food') then return end

local S = replacer.S

-- for inspection tool
local function add_recipe(item_name, _, recipes)
	local base_name = item_name:match('^(canned_food:.+)_plus$')
	if not base_name then return end

	recipes[#recipes + 1] = {
		method = S('fermenting/pickling'),
		type = 'canned_food',
		items = { base_name },
		output = item_name,
	}
end -- add_recipe

--luacheck: no unused args
local function add_formspec(recipe)
	return 'label[0.5,3.5;' .. S('Store near group:wood, light < 12.') .. ']'
end

replacer.register_craft_method('canned_food', 'default:wood', add_recipe, add_formspec)


-- for replacer
replacer.register_set_enabler(function(node)
	return node and 'string' == type(node.name)
		and node.name:find('^(canned_food:.+)_plus$') and true or false
end)

