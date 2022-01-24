-- skip if technic isn't loaded at all
if not replacer.has_technic_mod then return end

-- adds exceptions for technic cable plates
local lTiers = { 'lv', 'mv', 'hv' }
local lPlates = { '_digi_cable_plate_', '_cable_plate_' }
local sDropName, sBaseName
for _, sTier in ipairs(lTiers) do
	for _, sPlate in ipairs(lPlates) do
		sBaseName = 'technic:' .. sTier .. sPlate
		sDropName = sBaseName .. '1'
		for i = 2, 6 do
			replacer.register_exception(sBaseName .. tostring(i), sDropName)
		end
	end
end

-- can be frozen, so let it be placed
replacer.register_exception('default:dirt_with_snow', 'default:dirt_with_snow')

-- allow cnc output nodes
replacer.register_set_enabler(function(node)
	return node and node.name and node.name:find('_technic_cnc_') and true or false
end)

------------------------------------------
----------- for inpection tool -----------
------------------------------------------
-- have not tested 'other' technic mod, so just support technic.plus
--if not technic.plus then return end

--[[
--"cooking" is probably not needed as that is a standard method
]]

local function add_recipe_alloy(item_name, _, recipes)
--pd(technic.recipes['alloy'])
	for input_name, def in pairs(technic.recipes['alloy']['recipes']) do
		if def.output and 'string' == type(def.output)
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
			and def.input and 'table' == type(def.input)
		then
			local l = {}
			for k, v in pairs(def.input) do table.insert(l, k) end
			local i1, i2 = l[1], l[2]
			recipes[#recipes + 1] = {
				method = 'alloy',
				type = 'technic:alloy',
				items = { i1 },
				output = item_name,
				item2 = i2
			}
		end
	end
end -- add_recipe_alloy

local function add_formspec_alloy(recipe)
	if not recipe.item2 then return '' end
	return 'item_image_button[3,2;1.0,1.0;'
		.. replacer.image_button_link(recipe.item2) .. ']'
end

replacer.register_craft_method(
	'technic:alloy', 'technic:coal_alloy_furnace', add_recipe_alloy, add_formspec_alloy)


local function add_recipe_cnc(item_name, _, recipes)
	local base_name, program = item_name:match('^(.*)_technic_cnc_(.*)$')
	if not base_name then return end

	recipes[#recipes + 1] = {
		method = 'cnc',
		type = 'technic:cnc',
		items = { base_name },
		output = item_name,
		program = program:gsub('_', ' ')
	}
end -- add_recipe_freeze

local function add_formspec_cnc(recipe)
	if not recipe.program then return '' end
	return 'label[3,1;' .. recipe.program .. ']'
end

replacer.register_craft_method('technic:cnc', 'technic:cnc', add_recipe_cnc, add_formspec_cnc)


local function add_recipe_compress(item_name, _, recipes)
--pd(technic.recipes['compressing'])
	for input_name, def in pairs(technic.recipes['compressing']['recipes']) do
		if def.output and def.output == item_name then
			recipes[#recipes + 1] = {
				method = 'compress',
				type = 'technic:compress',
				items = { input_name },
				output = item_name
			}
		end
	end
end -- add_recipe_compress

replacer.register_craft_method('technic:compress', 'technic:lv_compressor', add_recipe_compress)


local function add_recipe_extract(item_name, _, recipes)
--pd(technic.recipes['extracting'])
	for input_name, def in pairs(technic.recipes['extracting']['recipes']) do
		if def.output and 'string' == type(def.output)
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
		then
			recipes[#recipes + 1] = {
				method = 'extract',
				type = 'technic:extract',
				items = { input_name },
				output = item_name
			}
		end
	end
end -- add_recipe_extract

replacer.register_craft_method('technic:extract', 'technic:lv_extractor', add_recipe_extract)


local function add_recipe_freeze(item_name, _, recipes)
	for input_name, def in pairs(technic.recipes['freezing']['recipes']) do
		if def.output
			and (def.output == item_name
				or ('table' == type(def.output)
					and def.output[1] == item_name))
		then
			recipes[#recipes + 1] = {
				method = 'freeze',
				type = 'technic:freeze',
				items = { input_name },
				output = item_name
			}
		end
	end
end -- add_recipe_freeze

replacer.register_craft_method('technic:freeze', 'technic:mv_freezer', add_recipe_freeze)


local function add_recipe_grind(item_name, _, recipes)
--pd(technic.recipes['grinding'])
	for input_name, def in pairs(technic.recipes['grinding']['recipes']) do
		if def.output and 'string' == type(def.output)
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
		then
			recipes[#recipes + 1] = {
				method = 'grind',
				type = 'technic:grind',
				items = { input_name },
				output = item_name
			}
		end
	end
end -- add_recipe_grind

replacer.register_craft_method('technic:grind', 'technic:lv_grinder', add_recipe_grind)


local function add_recipe_separate(item_name, _, recipes)
--pd(technic.recipes['separating'])
	for input_name, def in pairs(technic.recipes['separating']['recipes']) do
		if def.output and 'table' == type(def.output) then
			local clean, cleaned, found = '', {}, false
			for _, output in ipairs(def.output) do
				clean = output:match('^([^ ]+)')
				if clean == item_name then
					found = true
				else
					table.insert(cleaned, clean)
				end
			end
			if found then
				recipes[#recipes + 1] = {
					method = 'separate',
					type = 'technic:separate',
					items = { input_name },
					output = item_name,
					output_other = cleaned
				}
			end -- if found
		end -- if output is table
	end -- loop
end -- add_recipe_separate

local function add_formspec_separate(recipe)
	if not recipe.output_other or 0 == #recipe.output_other then
		return ''
	end

	local out = 'item_image_button[5,3;1.0,1.0;'
		.. replacer.image_button_link(recipe.output_other[1]) .. ']'
	if recipe.output_other[2] then
		out = out .. 'item_image_button[5,1;1.0,1.0;'
			.. replacer.image_button_link(recipe.output_other[2]) .. ']'
	end
	return out
end -- add_formspec_separate

replacer.register_craft_method(
	'technic:separate', 'technic:mv_centrifuge',
	add_recipe_separate, add_formspec_separate)

