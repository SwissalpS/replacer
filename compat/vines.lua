if not minetest.get_modpath('vines') then return end

local S = replacer.S

-- for replacer, so player can set to any part of vine and then replacer
-- uses the '_end' part to place
local cutables = {}
local vines = { 'jungle', 'root', 'side', 'vine', 'willow' }
local name_base, name_end, name_middle
for _, name in ipairs(vines) do
	name_base = 'vines:' .. name
	name_end = name_base .. '_end'
	name_middle = name_base .. '_middle'
	cutables[name_end] = name_end
	cutables[name_middle] = name_end
	replacer.register_exception(name_end, name_end)
	replacer.register_non_creative_alias(name_middle, name_end)
end


-- for inspection tool
replacer.group_placeholder['group:vines'] = 'vines:vines'


local function add_recipe(item_name, _, recipes)
	local output = cutables[item_name]
	if not output then return end

	recipes[#recipes + 1] = {
		method = 'cutting',
		type = 'vines:cut',
		items = { output }, -- not 'correct' but should do the job
		output = item_name,
	}
end -- add_recipe

local function add_formspec(recipe)
	return 'label[0.5,3.5;' .. S('Cut with shears.') .. ']'
end

replacer.register_craft_method('vines:cut', 'vines:shears', add_recipe, add_formspec)

