if not minetest.get_modpath('home_workshop_misc') then return end

-- for replacer
local mug = 'home_workshop_misc:beer_mug'
replacer.register_exception(mug, mug)

-- for inspection tool

local function add_recipe(item_name, _, recipes)
	if 'home_workshop_misc:beer_mug' ~= item_name then return end

	recipes[#recipes + 1] = {
		method = replacer.blabla.inspect.filling,
		type = 'home_workshop_misc:beer_tap',
		items = { 'vessels:drinking_glass' },
		output = item_name,
	}
end -- add_recipe

replacer.register_craft_method(
	'home_workshop_misc:beer_tap', 'home_workshop_misc:beer_tap', add_recipe)

