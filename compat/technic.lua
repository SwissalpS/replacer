-- skip if technic isn't loaded at all
if not replacer.has_technic_mod then return end

local rbi = replacer.blabla.inspect

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
local S = replacer.S

local function add_recipe_alloy(item_name, _, recipes)
--pd(technic.recipes['alloy'])
	for _, def in pairs(technic.recipes['alloy']['recipes']) do
		if def.output and 'string' == type(def.output)
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
			and def.input and 'table' == type(def.input)
		then
			local l = {}
			for k, v in pairs(def.input) do
				table.insert(l, k .. ' ' .. tostring(v))
			end
			local i1, i2 = l[1], l[2]
			recipes[#recipes + 1] = {
				method = S('alloying'),
				type = 'technic:alloy',
				items = { i1, i2 },
				output = def.output
			}
		end
	end
end -- add_recipe_alloy

replacer.register_craft_method(
	'technic:alloy', 'technic:coal_alloy_furnace', add_recipe_alloy)


local function add_recipe_cnc(item_name, _, recipes)
	local base_name, program = item_name:match('^(.*)_technic_cnc_(.*)$')
	if not base_name then return end

	recipes[#recipes + 1] = {
		method = S('CNC machining'),
		type = 'technic:cnc',
		items = { base_name },
		output = item_name,
		program = program --:gsub('_', ' ')
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
				method = S('compressing'),
				type = 'technic:compress',
				items = { input_name .. ' ' .. tostring(def.input[input_name]) },
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
				method = S('extracting'),
				type = 'technic:extract',
				items = { input_name .. ' ' .. tostring(def.input[input_name]) },
				output = def.output
			}
		end
	end
end -- add_recipe_extract

replacer.register_craft_method('technic:extract', 'technic:lv_extractor', add_recipe_extract)


local function add_recipe_freeze(item_name, _, recipes)
--pd(technic.recipes['freezing'])
	local def_out_type, outputs, main_output
	for input_name, def in pairs(technic.recipes['freezing']['recipes']) do
		def_out_type = type(def.output)
		if 'string' == def_out_type
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
		then
			recipes[#recipes + 1] = {
				method = S('freezing'),
				type = 'technic:freeze',
				items = { input_name },
				output = def.output,
			}

		elseif 'table' == def_out_type then
			outputs, main_output = {}, nil
			for _, output_string in ipairs(def.output) do
				if output_string:find('^' .. item_name .. ' ?[0-9]*$') then
					main_output = output_string
				else
					table.insert(outputs, output_string)
				end
			end
			if main_output then
				recipes[#recipes + 1] = {
					method = 'freezing',
					type = 'technic:freeze',
					items = { input_name .. ' '.. tostring(def.input[input_name]) },
					output = main_output,
					output_other = outputs,
				}
			end
		end
	end
end -- add_recipe_freeze

local function add_formspec_freeze(recipe)
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
end -- add_formspec_freeze

replacer.register_craft_method(
	'technic:freeze', 'technic:mv_freezer', add_recipe_freeze, add_formspec_freeze)


local function add_recipe_grind(item_name, _, recipes)
--pd(technic.recipes['grinding'])
	local inputs, input_type
	for _, def in pairs(technic.recipes['grinding']['recipes']) do
		if 'string' == type(def.output)
			and def.output:find('^' .. item_name .. ' ?[0-9]*$')
		then
			input_type = type(def.input)
			if 'string' == input_type then
				inputs = { def.input }
			elseif 'table' == input_type then
				inputs = {}
				-- there is only one, but that's how lua works so we need to loop
				for k, v in pairs(def.input) do
					table.insert(inputs, k .. ' ' .. tostring(v))
				end
			else
				inputs = {}
			end
			recipes[#recipes + 1] = {
				method = S('grinding'),
				type = 'technic:grind',
				items = inputs,
				output = def.output
			}
		end
	end
end -- add_recipe_grind

replacer.register_craft_method('technic:grind', 'technic:lv_grinder', add_recipe_grind)


local function add_recipe_separate(item_name, _, recipes)
--pd(technic.recipes['separating'])
	local outputs, main_output, inputs
	for _, def in pairs(technic.recipes['separating']['recipes']) do
		if def.output and 'table' == type(def.output)
			and def.input and 'table' == type(def.input)
		then
			outputs, main_output = {}, nil
			for _, output_string in ipairs(def.output) do
				if output_string:find('^' .. item_name .. ' ?[0-9]*$') then
					main_output = output_string
				else
					table.insert(outputs, output_string)
				end
			end
			if main_output then
				inputs = {}
				-- there is only one, but that's how lua works so we need to loop
				for k, v in pairs(def.input) do
					table.insert(inputs, k .. ' ' .. tostring(v))
				end
				recipes[#recipes + 1] = {
					method = S('separating'),
					type = 'technic:separate',
					items = inputs,
					output = main_output,
					output_other = outputs,
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


local function add_recipe_can_lava(item_name, _, recipes)
	local item, method
	if 'technic:lava_can' == item_name then
		item = 'default:lava_source'
		method = rbi.scoop
	elseif 'default:lava_source' == item_name then
		item = 'technic:lava_can'
		method = rbi.pour
	else
		return
	end

	recipes[#recipes + 1] = {
		method = method,
		type = 'technic:lava_can',
		items = { item },
		output = item_name,
	}
end -- add_recipe_can_lava

replacer.register_craft_method(
	'technic:lava_can', 'technic:lava_can', add_recipe_can_lava)


local function add_recipe_can_river(item_name, _, recipes)
	local item, method
	if 'technic:river_water_can' == item_name then
		item = 'default:river_water_source'
		method = rbi.scoop
	elseif 'default:river_water_source' == item_name then
		item = 'technic:river_water_can'
		method = rbi.pour
	else
		return
	end

	recipes[#recipes + 1] = {
		method = method,
		type = 'technic:river_water_can',
		items = { item },
		output = item_name,
	}
end -- add_recipe_can_river

replacer.register_craft_method(
	'technic:river_water_can', 'technic:river_water_can', add_recipe_can_river)


local function add_recipe_can_water(item_name, _, recipes)
	local item, method
	if 'technic:water_can' == item_name then
		item = 'default:water_source'
		method = rbi.scoop
	elseif 'default:water_source' == item_name then
		item = 'technic:water_can'
		method = rbi.pour
	else
		return
	end

	recipes[#recipes + 1] = {
		method = method,
		type = 'technic:water_can',
		items = { item },
		output = item_name,
	}
end -- add_recipe_can_water

replacer.register_craft_method(
	'technic:water_can', 'technic:water_can', add_recipe_can_water)

