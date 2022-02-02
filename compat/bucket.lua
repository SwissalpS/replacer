if not minetest.get_modpath('bucket') then return end

local rbi = replacer.blabla.inspect

local pours = {
	['default:water_source'] =	   'bucket:bucket_water',
	['default:river_water_source'] = 'bucket:bucket_river_water',
	['default:lava_source'] =		'bucket:bucket_lava',
	['technic:corium_source'] =	  'technic:bucket_corium',
}
local scoops = {}
for k, v in pairs(pours) do scoops[v] = k end

local function add_recipe(item_name, _, recipes)
	local item, method, empty_bucket
	if scoops[item_name] then
		item = scoops[item_name]
		method = rbi.scoop
	elseif pours[item_name] then
		item = pours[item_name]
		method = rbi.pour
		empty_bucket = true
	else
		return
	end

	recipes[#recipes + 1] = {
		method = method,
		type = 'bucket:bucket',
		items = { item },
		output = item_name,
		empty_bucket = empty_bucket,
	}
end -- add_recipe

local function add_formspec(recipe)
	if not recipe.empty_bucket then
		return ''
	end

	return 'item_image_button[5,3;1.0,1.0;'
		.. replacer.image_button_link('bucket:bucket_empty') .. ']'
end -- add_formspec

replacer.register_craft_method(
	'bucket:bucket', 'bucket:bucket_empty', add_recipe, add_formspec)

