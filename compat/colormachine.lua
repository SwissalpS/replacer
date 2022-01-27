if not replacer.has_colormachine_mod then return end

local function add_colormachine_recipe(node_name, _, recipes)

	local res = colormachine.get_node_name_painted(node_name, '')
	if not res or not res.possible  or 1 > #res.possible then
		return
	end

	-- paintable node found
	recipes[#recipes + 1] = {
		method = 'colormachine',
		type = 'colormachine',
		items = { res.possible[1] },
		output = node_name
	}
end -- add_colormachine_recipe

replacer.register_craft_method(
	'colormachine', 'colormachine:colormachine', add_colormachine_recipe)

