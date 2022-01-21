-- a crafting guide wanabe. Better than nothing for servers without
-- unified_inventory installed.
-- most useful feature is probably light measuring.
-- when using (lc), info about the node that was punched is presented
-- when placing (rc), info about the adjacent node that was clicked is
-- presented. Mostly air.

local r = replacer
local rb = replacer.blabla
local rbi = replacer.blabla.inspect
local nice_pos_string = replacer.nice_pos_string
local S = replacer.S
local floor = math.floor
local chat = minetest.chat_send_player
local mfe = minetest.formspec_escape

minetest.register_tool('replacer:inspect', {
	description = rbi.description,
	groups = {},
	inventory_image = 'replacer_inspect.png',
	wield_image = '',
	wield_scale = { x = 1, y = 1, z = 1 },
	liquids_pointable = true, -- it is ok to request information about liquids

	on_use = function(itemstack, user, pointed_thing)
		return replacer.inspect(itemstack, user, pointed_thing)
	end,

	on_place = function(itemstack, placer, pointed_thing)
		return replacer.inspect(itemstack, placer, pointed_thing, true)
	end,
})


function replacer.inspect(_, user, pointed_thing, right_clicked)
	if nil == user or nil == pointed_thing then
		return nil
	end
	local name = user:get_player_name()
	local keys = user:get_player_control()

	if 'object' == pointed_thing.type then
		local inventory_text = nil
		local text = ''
		local ref = pointed_thing.ref
		if not ref then
			text = rbi.broken_object
		elseif ref:is_player() then
			text = S('This is your fellow player "@1"', ref:get_player_name())
		else
			local luaob = ref:get_luaentity()
			if luaob and luaob.get_staticdata then
				text = S('This is an entity "@1"', luaob.name)
				local sdata = luaob:get_staticdata()
				if 0 < #sdata then
					sdata = minetest.deserialize(sdata) or {}
					if sdata.itemstring then
						text = text .. ' [' .. sdata.itemstring .. ']'
						if show_recipe then
							-- the fields part is used here to provide
							-- additional information about the entity
							r.inspect_show_crafting(
											name,
											sdata.itemstring,
											{ luaob = luaob })
						end
					end
					if sdata.age then
						text = text .. S(', dropped @1 minutes ago',
							tostring(floor((sdata.age / 60) + .5)))
					end
					if sdata.owner then
						if true == sdata.protected then
							if true == sdata.locked then
								text = text .. ' ' .. rbi.owned_protected_locked
							else
								text = text .. ' ' .. rbi.owned_protected
							end
						else
							if true == sdata.locked then
								text = text .. ' ' .. rbi.owned_locked
							end
						end
						text = text .. ' ' .. S('by "@1"', sdata.owner)
					end
					if 'string' == type(sdata.order) then
						text = text .. ' ' .. S('with order to @1', sdata.order)
					end
					if 'table' == type(sdata.inv) then
						local item_count = 0
						local type_count = 0
						for k, v in pairs(sdata.inv) do
							type_count = type_count + 1
							item_count = item_count + v
						end
						if 0 < type_count then
							inventory_text = '\n'
							if 1 < type_count then
								inventory_text = inventory_text
									.. S('Has @1 different types of items,',
										tostring(type_count)) .. ' '
							end
							inventory_text = inventory_text
								.. S('total of @1 items in inventory.',
									tostring(item_count))
						end
					end
				end
			elseif luaob then
				text = S('This is an object "@1"', luaob.name)
			else
				text = rbi.this_is_object
			end

		end
		if ref then
			text = text .. ' ' .. S('at @1', nice_pos_string(ref:getpos()))
		end
		if inventory_text then text = text .. inventory_text end
		chat(name, text)
		return nil
	elseif 'node' ~= pointed_thing.type then
		chat(name, S('Sorry, this is an unkown something of type "@1". '
			.. 'No information available.', pointed_thing.type))
		return nil
	end

	local pos  = minetest.get_pointed_thing_position(pointed_thing, right_clicked)
	local node = minetest.get_node_or_nil(pos)

	if not node then
		chat(name, rb.wait_for_load)
		return nil
	end

	local protected_info = ''
	if minetest.is_protected(pos, name) then
		protected_info = rbi.is_protected
	elseif minetest.is_protected(pos, '_THIS_NAME_DOES_NOT_EXIST_') then
		protected_info = rbi.you_can_dig
	end

		-- get light of the node at the current time
	local light = minetest.get_node_light(pos, nil)
	-- the fields part is used here to provide additional
	-- information about the node
	r.inspect_show_crafting(name, node.name, {
		pos = pos, param2 = node.param2, light = light,
		protected_info = protected_info })

	return nil -- no item shall be removed from inventory
end -- replacer.inspect

function replacer.image_button_link(stack_string)
	local group = ''
	if r.image_replacements[stack_string] then
		stack_string = r.image_replacements[stack_string]
	end
	if r.group_placeholder[stack_string] then
		stack_string = r.group_placeholder[stack_string]
		group = 'G'
	end
-- TODO: show information about other groups not handled above
	local stack = ItemStack(stack_string)
	local new_node_name = stack:get_name()
	return stack_string .. ';' .. new_node_name .. ';' .. group
end -- image_button_link


function replacer.add_circular_saw_recipe(node_name, recipes)
	local basic_node_name = r.is_saw_output(node_name)
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


function replacer.add_colormachine_recipe(node_name, recipes)
	if not r.has_colormachine_mod then
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
end -- add_colormachine_recipe


function replacer.inspect_show_crafting(player_name, node_name, fields)
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
	r.add_circular_saw_recipe(node_name, res)
	r.add_colormachine_recipe(node_name, res)
	r.unifieddyes.add_recipe(fields.param2, node_name, res)

	-- offer all alternate creafting recipes thrugh prev/next buttons
	if fields and fields.prev_recipe and 1 < recipe_nr then
		recipe_nr = recipe_nr - 1
	elseif fields and fields.next_recipe and recipe_nr < #res then
		recipe_nr = recipe_nr + 1
	end

	local desc = ' ' .. rbi.no_desc .. ' '
	if minetest.registered_nodes[node_name] then
		if minetest.registered_nodes[node_name].description
			and '' ~= minetest.registered_nodes[node_name].description
		then
			desc = minetest.registered_nodes[node_name].description
		elseif minetest.registered_nodes[node_name].name then
			desc = minetest.registered_nodes[node_name].name
		else
			desc = ' ' .. rbi.no_node_desc .. ' '
		end
	elseif minetest.registered_items[node_name] then
		if minetest.registered_items[node_name].description
			and '' ~= minetest.registered_items[node_name].description
		then
			desc = minetest.registered_items[node_name].description
		elseif minetest.registered_items[node_name].name then
			desc = minetest.registered_items[node_name].name
		else
			desc = ' ' .. rbi.no_item_desc .. ' '
		end
	end

	local formspec = 'size[6,6]'
		.. 'label[0,0;' .. mfe(rbi.name) .. ' ' .. node_name .. ']'
		.. 'item_image_button[5,2;1.0,1.0;' .. node_name .. ';normal;]'
		.. 'button_exit[5.0,4.3;1,0.5;quit;' .. mfe(rbi.exit) .. ']'
		.. 'label[0,5.5;' .. mfe(rbi.this_is) .. ' ' .. mfe(desc) .. ']'
		 -- invisible field for passing on information
		.. 'field[20,20;0.1,0.1;node_name;node_name;' .. node_name .. ']'
		-- another invisible field
		.. 'field[21,21;0.1,0.1;recipe_nr;recipe_nr;' .. tostring(recipe_nr) .. ']'

	-- provide additional information regarding the node in particular
	-- that has been inspected
	formspec = formspec .. 'label[0.0,0.3;'
	if fields.pos then
		formspec = formspec .. mfe(S('Located at @1', nice_pos_string(fields.pos)))
	end
	if fields.param2 then
		formspec = formspec .. ' '
			.. mfe(S('with param2 of @1', tostring(fields.param2)))
	end
	formspec = formspec .. ']'
	if fields.light then
		formspec = formspec .. 'label[0.0,0.6;'
			.. mfe(S('and receiving @1 light', tostring(fields.light))) .. ']'
	end

	-- show information about protection
	if fields.protected_info and '' ~= fields.protected_info then
		formspec = formspec .. 'label[0.0,4.5;'
			.. mfe(fields.protected_info) .. ']'
	end

	if #res < recipe_nr or 1 > recipe_nr then
		recipe_nr = 1
	end
	if 1 < recipe_nr then
		formspec = formspec .. 'button[3.8,5;1,0.75;prev_recipe;'
			.. mfe(rbi.prev) .. ']'
	end
	if #res > recipe_nr then
		formspec = formspec .. 'button[5.0,5.0;1,0.75;next_recipe;'
			.. mfe(rbi.next) .. ']'
	end
	if 1 > #res then
		formspec = formspec .. 'label[3,1;' .. mfe(rbi.no_recipes) .. ']'
		if minetest.registered_nodes[node_name]
			and minetest.registered_nodes[node_name].drop
		then
			local drop = minetest.registered_nodes[node_name].drop
			if 'string' == type(drop) and drop ~= node_name then
				formspec = formspec .. 'label[2,1.6;' .. mfe(rbi.drops_on_dig) .. ' '
				if '' == drop then
					formspec = formspec .. mfe(rbi.nothing) .. ']'
				else
					formspec = formspec
						.. ']item_image_button[2,2;1.0,1.0;'
						.. r.image_button_link(drop) .. ']'
				end
			elseif 'table' == type(drop) and drop.items then
				local droplist = {}
				for _, drops in ipairs(drop.items) do
					for _, item in ipairs(drops.items) do
						-- avoid duplicates; but include the item itself
						droplist[item] = 1
					end
				end
				local i = 1
				formspec = formspec .. 'label[2,1.6;' .. mfe(rbi.may_drop_on_dig) .. ']'
				for k, v in pairs(droplist) do
					formspec = formspec .. 'item_image_button['
						.. (((i - 1) % 3) + 1) .. ','
						.. tostring(floor(((i - 1) / 3) + 2))
						.. ';1.0,1.0;' .. r.image_button_link(k) .. ']'
					i = i + 1
				end
			end
		end
	else
		formspec = formspec .. 'label[1,5;'
			.. mfe(S('Alternate @1/@2', tostring(recipe_nr), tostring(#res))) .. ']'
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
						.. tostring(floor((i - 1) / width) + 1)
						.. ';1.0,1.0;'
						.. r.image_button_link(recipe.items[i]) .. ']'
				end
			end
		elseif 'cooking' == recipe.type
			and recipe.items
			and 1 == #recipe.items
			and '' == recipe.output
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. r.image_button_link('default:furnace_active') .. ']'
				.. 'item_image_button[2.9,2.7;1.0,1.0;'
				.. r.image_button_link(recipe.items[1]) .. ']'
				.. 'label[1.0,0;' .. tostring(recipe.items[1]) .. ']'
				.. 'label[0,0.5;' .. mfe(rbi.can_be_fuel) .. ']'
		elseif 'cooking' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. r.image_button_link('default:furnace') .. ']'
				.. 'item_image_button[2.9,2.7;1.0,1.0;'
				.. r.image_button_link(recipe.items[1]) .. ']'
		elseif 'colormachine' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. r.image_button_link('colormachine:colormachine') .. ']'
				.. 'item_image_button[2,2;1.0,1.0;'
				.. r.image_button_link(recipe.items[1]) .. ']'
		elseif 'saw' == recipe.type
			and recipe.items
			and 1 == #recipe.items
		then
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. r.image_button_link('moreblocks:circular_saw') .. ']'
				.. 'item_image_button[2,0.6;1.0,1.0;'
				.. r.image_button_link(recipe.items[1]) .. ']'
		else
			formspec = formspec .. 'label[3,1;' .. mfe(rbi.unkown_recipe) .. ']'
		end
		-- show how many of the items the recipe will yield
		local outstack = ItemStack(recipe.output)
		local out_count = outstack:get_count()
		if 1 < out_count then
			formspec = formspec .. 'label[5.5,2.5;' .. tostring(out_count) .. ']'
		end
	end
	minetest.show_formspec(player_name, 'replacer:crafting', formspec)
end -- inspect_show_crafting


-- translate general formspec calls back to specific calls
function replacer.form_input_handler(player, formname, fields)
	if formname and 'replacer:crafting' == formname
		and player and not fields.quit
	then
		r.inspect_show_crafting(player:get_player_name(), nil, fields)
		return
	end
end

-- establish a callback so that input from the player-specific
-- formspec gets handled
minetest.register_on_player_receive_fields(replacer.form_input_handler)

