
replacer.image_replacements = {}

-- support for RealTest
if minetest.get_modpath('trees')
	and minetest.get_modpath('core')
	and minetest.get_modpath('instruments')
	and minetest.get_modpath('anvil')
	and minetest.get_modpath('scribing_table')
then
	replacer.image_replacements['group:planks'] = 'trees:pine_planks'
	replacer.image_replacements['group:plank'] = 'trees:pine_plank'
	replacer.image_replacements['group:wood'] = 'trees:pine_planks'
	replacer.image_replacements['group:tree'] = 'trees:pine_log'
	replacer.image_replacements['group:sapling'] = 'trees:pine_sapling'
	replacer.image_replacements['group:leaves'] = 'trees:pine_leaves'
	replacer.image_replacements['default:furnace'] = 'oven:oven'
	replacer.image_replacements['default:furnace_active'] = 'oven:oven_active'
end

minetest.register_tool('replacer:inspect', {
	description = 'Node inspection tool',
	groups = {},
	inventory_image = 'replacer_inspect.png',
	wield_image = '',
	wield_scale = { x = 1,y = 1,z = 1 },
	liquids_pointable = true, -- it is ok to request information about liquids

	on_use = function(itemstack, user, pointed_thing)
		return replacer.inspect(itemstack, user, pointed_thing)
	end,

	on_place = function(itemstack, placer, pointed_thing)
		return replacer.inspect(itemstack, placer, pointed_thing)
	end,
})

local nice_pos_string = replacer.nice_pos_string

replacer.inspect = function(_, user, pointed_thing, mode)
	if nil == user or nil == pointed_thing then
		return nil
	end
	local name = user:get_player_name()
	local keys = user:get_player_control()

	if 'object' == pointed_thing.type then
		local inventory_text = nil
		local text = 'This is '
		local ref = pointed_thing.ref
		if not ref then
			text = text .. 'a broken object. We have no further information '
				.. 'about it. It is located'
		elseif ref:is_player() then
			text = text .. 'your fellow player "' .. ref:get_player_name() .. '"'
		else
			local luaob = ref:get_luaentity()
			if luaob and luaob.get_staticdata then
				text = text .. 'an entity "' .. luaob.name .. '"'
				local sdata = luaob:get_staticdata()
				if 0 < #sdata then
					sdata = minetest.deserialize(sdata) or {}
					if sdata.itemstring then
						text = text .. ' [' .. sdata.itemstring .. ']'
						if show_recipe then
							-- the fields part is used here to provide
							-- additional information about the entity
							replacer.inspect_show_crafting(
											name,
											sdata.itemstring,
											{ luaob = luaob })
						end
					end
					if sdata.age then
						text = text .. ', dropped '
							.. tostring(math.floor(sdata.age / 60))
							.. ' minutes ago'
					end
					if sdata.owner then
						text = text .. ' owned'
						if true == sdata.protected then
							if true == sdata.locked then
								text = text .. ', protected and locked'
							else
								text = text .. ' and protected'
							end
						else
							if true == sdata.locked then
								text = text .. ' and locked'
							end
						end
						text = text .. ' by ' .. sdata.owner
					end
					if 'string' == type(sdata.order) then
						text = text .. ' with order to ' .. sdata.order
					end
					if 'table' == type(sdata.inv) then
						local item_count = 0
						local type_count = 0
						for k, v in pairs(sdata.inv) do
							type_count = type_count + 1
							item_count = item_count + v
						end
						if 0 < type_count then
							inventory_text = '\nHas '
							if 1 < type_count then
								inventory_text = inventory_text .. type_count
										.. ' different types of items, '
							end
							inventory_text = inventory_text .. 'total of '
									.. item_count .. ' items in inventory.'
						end
					end
				end
			elseif luaob then
				text = text .. 'an object "' .. luaob.name .. '"'
			else
				text = text .. 'an object'
			end

		end
		if ref then
			text = text .. ' at ' .. nice_pos_string(ref:getpos())
		end
		if inventory_text then text = text .. inventory_text end
		minetest.chat_send_player(name, text)
		return nil
	elseif 'node' ~= pointed_thing.type then
		minetest.chat_send_player(name, 'Sorry, this is an unkown something '
			.. 'of type "' .. pointed_thing.type .. '". '
			.. 'No information available.')
		return nil
	end

	local pos  = minetest.get_pointed_thing_position(pointed_thing, mode)
	local node = minetest.get_node_or_nil(pos)

	if not node then
		minetest.chat_send_player(name, 'Error: Target node not yet loaded. '
			.. 'Please wait a moment for the server to catch up.')
		return nil
	end

	local protected_info = ''
	if minetest.is_protected(pos, name) then
		protected_info = 'WARNING: You can\'t dig this node. It is protected.'
	elseif minetest.is_protected(pos, '_THIS_NAME_DOES_NOT_EXIST_') then
		protected_info = 'INFO: You can dig this node, but others can\'t.'
	end

		-- get light of the node at the current time
	local light = minetest.get_node_light(pos, nil)
	if 0 == light then
		light = minetest.get_node_light({ x = pos.x, y = pos.y + 1, z = pos.z })
	end
	-- the fields part is used here to provide additional
	-- information about the node
	replacer.inspect_show_crafting(name, node.name, {
		pos = pos, param2 = node.param2, light = light,
		protected_info = protected_info })

	return nil -- no item shall be removed from inventory
end

-- some common groups
replacer.group_placeholder = {}
replacer.group_placeholder['group:coal'] = 'default:coal_lump'
replacer.group_placeholder['group:leaves'] = 'default:leaves'
replacer.group_placeholder['group:sand'] = 'default:sand'
replacer.group_placeholder['group:sapling']= 'default:sapling'
replacer.group_placeholder['group:stick'] = 'default:stick'
-- 'default:stone' point people to the cheaper cobble
replacer.group_placeholder['group:stone'] = 'default:cobble'
replacer.group_placeholder['group:tree'] = 'default:tree'
replacer.group_placeholder['group:vines'] = 'vines:vines'
replacer.group_placeholder['group:wood'] = 'default:wood'
replacer.group_placeholder['group:wood_slab'] = 'stairs:slab_wood'
replacer.group_placeholder['group:wool'] = 'wool:white'

-- add default game dyes
for _, color in pairs(dye.dyes) do
	replacer.group_placeholder['group:dye,color_' .. color[1] ] = 'dye:' .. color[1]
end

-- add default game flowers
do
	local name, groups
	for _, flower in pairs(flowers.datas) do
		name = flower[1]
		groups = flower[4]
		for k, _ in pairs(groups) do
			if 1 == k:find('color_') then
				replacer.group_placeholder['group:flower,' .. k] = 'flowers:' .. name
			end
		end
	end
end

-- add bakedclay items
if replacer.has_bakedclay then
	replacer.group_placeholder['group:bakedclay'] = 'bakedclay:natural'
	-- unfortunately bakedclay does not expose anything, so we have to manually
	-- maintain the list
	local rgp = replacer.group_placeholder
	rgp['group:flower,color_cyan'] = 'bakedclay:delphinium'
	rgp['group:flower,color_pink'] = 'bakedclay:lazarus'
	rgp['group:flower,color_dark_green'] = 'bakedclay:mannagrass'
	rgp['group:flower,color_magenta'] = 'bakedclay:thistle'
end

-- handle the standard dye color groups
if replacer.has_basic_dyes then
	for i, color in ipairs(dye.basecolors) do
		local def = minetest.registered_items['dye:' .. color]
		if def and def.groups then
			for k, v in pairs(def.groups) do
				if 'dye' ~= k then
					replacer.group_placeholder['group:dye,' .. k] = 'dye:' .. color
				end
			end
			replacer.group_placeholder['group:flower,color_' .. color] = 'dye:' .. color
		end
	end
end

replacer.image_button_link = function(stack_string)
	local group = ''
	if replacer.image_replacements[stack_string] then
		stack_string = replacer.image_replacements[stack_string]
	end
	if replacer.group_placeholder[stack_string] then
		stack_string = replacer.group_placeholder[stack_string]
		group = 'G'
	end
-- TODO: show information about other groups not handled above
	local stack = ItemStack(stack_string)
	local new_node_name = stack:get_name()
	return stack_string .. ';' .. new_node_name .. ';' .. group
end

replacer.add_circular_saw_recipe = function(node_name, recipes)
	local basic_node_name = replacer.is_saw_output(node_name)
	if not basic_node_name then return end

	-- node found that fits into the saw
	recipes[#recipes + 1] = {
		method = 'saw',
		type = 'saw',
		items = { basic_node_name },
		output = node_name
	}
	return recipes
end -- add_circular_saw_recipe


replacer.add_colormachine_recipe = function(node_name, recipes)
	if not replacer.has_colormachine_mod then
		return
	end
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
	return recipes
end


replacer.inspect_show_crafting = function(player_name, node_name, fields)
	if not player_name then
		return
	end

	local recipe_nr = 1
	if not node_name then
		node_name  = fields.node_name
		recipe_nr = tonumber(fields.recipe_nr)
	end
	-- turn it into an item stack so that we can handle dropped stacks etc
	local stack = ItemStack(node_name)
	node_name = stack:get_name()

	-- the player may ask for recipes of indigrents to the current recipe
	if fields then
		for k, v in pairs(fields) do
			if v and '' == v
				and minetest.registered_items[k]
				or minetest.registered_nodes[k]
				or minetest.registered_craftitems[k]
				or minetest.registered_tools[k]
			then
				node_name = k
				recipe_nr = 1
			end
		end
	end

	local res = minetest.get_all_craft_recipes(node_name)
	if not res then
		res = {}
	end
--print(dump(res))
	-- TODO: filter out invalid recipes with no items
	--	   such as "group:flower,color_dark_grey"
	--

	-- add special recipes for nodes created by machines
	replacer.add_circular_saw_recipe(node_name, res)
	replacer.add_colormachine_recipe(node_name, res)
	replacer.unifieddyes.add_recipe(fields.param2, node_name, res)

	-- offer all alternate creafting recipes thrugh prev/next buttons
	if fields and fields.prev_recipe and 1 < recipe_nr then
		recipe_nr = recipe_nr - 1
	elseif fields and fields.next_recipe and recipe_nr < #res then
		recipe_nr = recipe_nr + 1
	end

	local desc = ' - no description provided - '
	if minetest.registered_nodes[node_name] then
		if minetest.registered_nodes[node_name].description
			and '' ~= minetest.registered_nodes[node_name].description
		then
			desc = minetest.registered_nodes[node_name].description
		elseif minetest.registered_nodes[node_name].name then
			desc = minetest.registered_nodes[node_name].name
		else
			desc = ' - no node description provided - '
		end
	elseif minetest.registered_items[node_name] then
		if minetest.registered_items[node_name].description
			and '' ~= minetest.registered_items[node_name].description
		then
			desc = minetest.registered_items[node_name].description
		elseif minetest.registered_items[node_name].name then
			desc = minetest.registered_items[node_name].name
		else
			desc = ' - no item description provided - '
		end
	end

	local formspec = 'size[6,6]'
		.. 'label[0,0;Name: ' .. node_name .. ']'
		.. 'item_image_button[5,2;1.0,1.0;' .. node_name .. ';normal;]'
		.. 'button_exit[5.0,4.3;1,0.5;quit;Exit]'
		.. 'label[0,5.5;This is: ' .. minetest.formspec_escape(desc) .. ']'
		 -- invisible field for passing on information
		.. 'field[20,20;0.1,0.1;node_name;node_name;' .. node_name .. ']'
		-- another invisible field
		.. 'field[21,21;0.1,0.1;recipe_nr;recipe_nr;' .. tostring(recipe_nr) .. ']'

	-- provide additional information regarding the node in particular
	-- that has been inspected
	formspec = formspec .. 'label[0.0,0.3;'
	if fields.pos then
		formspec = formspec .. 'Located at '
			.. minetest.formspec_escape(minetest.pos_to_string(fields.pos))
	end
	if fields.param2 then
		formspec = formspec .. ' with param2 of ' .. tostring(fields.param2)
	end
	formspec = formspec .. ']'
	if fields.light then
		formspec = formspec .. 'label[0.0,0.6;and receiving '
			.. tostring(fields.light) .. ' light]'
	end

	-- show information about protection
	if fields.protected_info and '' ~= fields.protected_info then
		formspec = formspec .. 'label[0.0,4.5;'
			.. minetest.formspec_escape(fields.protected_info) .. ']'
	end

	if #res < recipe_nr or 1 > recipe_nr then
		recipe_nr = 1
	end
	if 1 < recipe_nr then
		formspec = formspec .. 'button[3.8,5;1,0.5;prev_recipe;prev]'
	end
	if #res > recipe_nr then
		formspec = formspec .. 'button[5.0,5.0;1,0.5;next_recipe;next]'
	end
	if 1 > #res then
		formspec = formspec .. 'label[3,1;No recipes.]'
		if minetest.registered_nodes[node_name]
			and minetest.registered_nodes[node_name].drop
		then
			local drop = minetest.registered_nodes[node_name].drop
			if 'string' == type(drop) and drop ~= node_name then
				formspec = formspec .. 'label[2,1.6;Drops on dig:]'
					.. 'item_image_button[2,2;1.0,1.0;'
					.. replacer.image_button_link(drop) .. ']'
			elseif 'table' == type(drop) and drop.items then
				local droplist = {}
				for _, drops in ipairs(drop.items) do
					for _,item in ipairs(drops.items) do
						-- avoid duplicates; but include the item itshelf
						droplist[item] = 1
					end
				end
				local i = 1
				formspec = formspec .. 'label[2,1.6;May drop on dig:]'
				for k, v in pairs(droplist) do
					formspec = formspec .. 'item_image_button['
						.. (((i - 1) % 3) + 1) .. ','
						.. tostring(math.floor(((i - 1) / 3) + 2))
						.. ';1.0,1.0;' .. replacer.image_button_link(k) .. ']'
					i = i + 1
				end
			end
		end
	else
		formspec = formspec .. 'label[1,5;Alternate ' .. tostring(recipe_nr)
			.. '/' .. tostring(#res) .. ']'
		-- reverse order; default recipes (and thus the most intresting ones)
		-- are usually the oldest
		local recipe = res[#res + 1 - recipe_nr]
--print(dump(recipe))
		if 'normal' == recipe.type and recipe.items then
			local width = recipe.width
			if not width or 0 == width then
				width = 3
			end
			for i = 1, 9 do
				if recipe.items[i] then
					formspec = formspec .. 'item_image_button['
						.. (((i - 1) % width) + 1) .. ','
						.. tostring(math.floor((i - 1) / width) + 1)
						.. ';1.0,1.0;'
						.. replacer.image_button_link(recipe.items[i]) .. ']'
				end
			end
		elseif 'cooking' == recipe.type
			and recipe.items
			and 1 == #recipe.items
			and '' == recipe.output
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. replacer.image_button_link('default:furnace_active') .. ']'
				.. 'item_image_button[2.9,2.7;1.0,1.0;'
				.. replacer.image_button_link(recipe.items[1]) .. ']'
				.. 'label[1.0,0;' .. tostring(recipe.items[1]) .. ']'
				.. 'label[0,0.5;This can be used as a fuel.' .. ']'
		elseif 'cooking' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. replacer.image_button_link('default:furnace') .. ']'
				.. 'item_image_button[2.9,2.7;1.0,1.0;'
				.. replacer.image_button_link(recipe.items[1]) .. ']'
		elseif 'colormachine' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. replacer.image_button_link('colormachine:colormachine') .. ']'
				.. 'item_image_button[2,2;1.0,1.0;'
				.. replacer.image_button_link(recipe.items[1]) .. ']'
		elseif 'saw' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. replacer.image_button_link('moreblocks:circular_saw') .. ']'
				.. 'item_image_button[2,0.6;1.0,1.0;'
				.. replacer.image_button_link(recipe.items[1]) .. ']'
		else
			formspec = formspec .. 'label[3,1;Error: Unkown recipe.]'
		end
		-- show how many of the items the recipe will yield
		local outstack = ItemStack(recipe.output)
		local out_count = outstack:get_count()
		if 1 < out_count then
			formspec = formspec .. 'label[5.5,2.5;' .. tostring(out_count) .. ']'
		end
	end
	minetest.show_formspec(player_name, 'replacer:crafting', formspec)
end

-- translate general formspec calls back to specific calls
replacer.form_input_handler = function(player, formname, fields)
	if formname and 'replacer:crafting' == formname
		and player and not fields.quit
	then
		replacer.inspect_show_crafting(player:get_player_name(), nil, fields)
		return
	end
end

-- establish a callback so that input from the player-specific
-- formspec gets handled
minetest.register_on_player_receive_fields(replacer.form_input_handler)

