if not minetest.get_modpath('letters') then return end

-- for inspection tool
local S = replacer.S
local function add_recipe_u(item_name, _, recipes)
	if not item_name or not 'string' == type(item_name) then return end

	local input, letter = item_name:match('^(.+)_letter_(.)u$')
	if not input then return end

	recipes[#recipes + 1] = {
		method = S('cutting'),
		type = 'letters:upper',
		items = { input },
		output = item_name,
		letter = letter
	}
end -- add_recipe_u

replacer.register_craft_method('letters:upper', 'letters:letter_cutter_upper', add_recipe_u)


local function add_recipe_l(item_name, _, recipes)
	if not item_name or not 'string' == type(item_name) then return end

	local input, letter = item_name:match('^(.+)_letter_(.)l$')
	if not input then return end

	recipes[#recipes + 1] = {
		method = S('cutting'),
		type = 'letters:lower',
		items = { input },
		output = item_name,
		letter = letter
	}
end -- add_recipe_l

replacer.register_craft_method('letters:lower', 'letters:letter_cutter_lower', add_recipe_l)


-- for replacer
replacer.register_set_enabler(function(node)
	return node and node.name and node.name:find('^.+_letter_(.)[lu]$')
end)

