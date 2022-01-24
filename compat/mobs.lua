if not minetest.get_modpath('mobs') then return end

local rgp = replacer.group_placeholder
if not rgp['group:food_cheese'] then rgp['group:food_cheese'] = 'mobs:cheese' end
if not rgp['group:food_meat'] then rgp['group:food_meat'] = 'mobs:meat' end


if not minetest.get_modpath('mobs_animal') then return end
if not minetest.get_modpath('mobs_animal') then return end

local S = replacer.S

local colours = { 'black', 'blue', 'brown', 'cyan', 'dark_green', 'dark_grey', 'green',
	'grey', 'magenta', 'orange', 'pink', 'red', 'violet', 'white', 'yellow' }
local map = {}
for _, colour in ipairs(colours) do
	map['wool:' .. colour] = 'mobs_animal:sheep_' .. colour
end
local function add_recipe(item_name, _, recipes)
	local output = map[item_name]
	if not output then return end

	recipes[#recipes + 1] = {
		method = 'cutting',
		type = 'sheep:cut',
		items = { output }, -- tecnically input, but hey
		output = item_name,
	}
end -- add_recipe

local function add_formspec(recipe)
	return 'label[0.5,3.5;' .. S('Cut with shears.') .. ']'
end

replacer.register_craft_method('sheep:cut', 'mobs:shears', add_recipe, add_formspec)

