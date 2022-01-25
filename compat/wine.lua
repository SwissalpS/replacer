if not minetest.get_modpath('wine') then return end

local S = replacer.S

-- for inspection tool
-- order preserved from wines mod
local in_out = {}
in_out['wine:glass_wine'] = 'farming:grapes'
in_out['wine:glass_beer'] = 'farming:barley'
in_out['wine:glass_mead'] = 'mobs:honey'
in_out['wine:glass_mead'] = 'xdecor:honey'
in_out['wine:glass_cider'] = 'default:apple'
in_out['wine:glass_rum'] = 'default:papyrus'
in_out['wine:glass_tequila'] = 'wine:blue_agave'
in_out['wine:glass_wheat_beer'] = 'farming:wheat'
in_out['wine:glass_sake'] = 'farming:rice'
in_out['wine:glass_bourbon'] = 'farming:corn'
in_out['wine:glass_vodka'] = 'farming:baked_potato'
in_out['wine:glass_coffee_liquor'] = 'farming:coffee_beans'
in_out['wine:glass_champagne'] = 'wine:glass_champagne_raw'

local function add_recipe(item_name, _, recipes)
	if not 'string' == type(item_name)
		or not item_name:find('^wine:glass_') then return end

	-- this one is an exception
	if 'wine:glass_champagne_raw' == item_name then return end

	-- allow new items to show up using air as icon
	local input = in_out[item_name] or 'air'
	recipes[#recipes + 1] = {
		method = 'fermenting',
		type = 'wine:ferment',
		items = { input },
		output = item_name,
	}
end -- add_recipe

local function add_formspec(recipe)
	return 'label[0.5,3.5;' .. S('Ferment in barrel.') .. ']'
end

replacer.register_craft_method('wine:ferment', 'wine:wine_barrel', add_recipe, add_formspec)

