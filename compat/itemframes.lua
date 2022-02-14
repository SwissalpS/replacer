if not minetest.get_modpath('itemframes') then return end

-- for inspection tool --
local S = replacer.S

local function add_recipe_itemframe(item_name, context, recipes)
    if 'itemframes:frame' ~= item_name then return end

    if not (context and context.pos) then return end

	local held_name = minetest.get_meta(context.pos):get_string('item')
	if '' == held_name then return end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'itemframes:frame',
		items = { held_name },
		output = nil,
	}
end -- add_recipe_itemframe

replacer.register_craft_method(
	'itemframes:frame', 'itemframes:frame', add_recipe_itemframe)


local function add_recipe_pedestal(item_name, context, recipes)
    if 'itemframes:pedestal' ~= item_name then return end

    if not (context and context.pos) then return end

	local held_name = minetest.get_meta(context.pos):get_string('item')
	if '' == held_name then return end

	recipes[#recipes + 1] = {
		method = S('holding'),
		type = 'itemframes:pedestal',
		items = { held_name },
		output = nil,
	}
end -- add_recipe_pedestal

replacer.register_craft_method(
	'itemframes:pedestal', 'itemframes:pedestal', add_recipe_pedestal)

