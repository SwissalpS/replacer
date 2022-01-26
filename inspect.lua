-- a crafting guide wanabe. Better than nothing for servers without
-- unified_inventory installed.
-- most useful feature is probably light measuring.
-- when using (lc), info about the node that was punched is presented
-- when placing (rc), info about the adjacent node that was clicked is
-- presented. Mostly air.

local r = replacer
local rb = replacer.blabla
local rbi = replacer.blabla.inspect
local ui = r.has_unified_inventory_mod and unified_inventory or false
local nice_pos_string = replacer.nice_pos_string
local S = replacer.S
local floor = math.floor
local max, min = math.max, math.min
local chat = minetest.chat_send_player
local mfe = minetest.formspec_escape

-- use r.register_craft_method() to populate
replacer.recipe_adders = {}

-- uid: unique identifier e.g. 'saw', 'compress', 'freeze'
-- machine_itemstring: the itemstring that has registered icon texture,
--     generally the machine used.
-- func_inspect: function that manipulates recipes list with signature:
--     f(node_name, param2, recipes)
--     returns nothing, just adds recipes to recipes list
-- func_formspec: optional function that returns extra formspec elements
--     f(recipe)
--     where recipe is the recipe table func_inspect added.
--     returns a string, even if empty.
function replacer.register_craft_method(uid, machine_itemstring, func_inspect,
	func_formspec)
	if ('string' ~= type(uid) or '' == uid)
		or ('string' ~= type(machine_itemstring)
			or not minetest.registered_items[machine_itemstring])
		or 'function' ~= type(func_inspect)
	then
		minetest.log('warning', rbi.log_reg_craft_method_wrong_arguments)
		return
	end

	if r.recipe_adders[uid] then
		minetest.log('warning', rbi.log_reg_craft_method_overriding_method .. uid)
	end

	r.recipe_adders[uid] = {
		machine = machine_itemstring,
		add_recipe = func_inspect,
		formspec = ('function' == type(func_formspec) and func_formspec) or nil
	}
	minetest.log('info', rbi.log_reg_craft_method_added:format(uid, machine_itemstring))
end -- register_craft_method


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

	-- EXPERIMENTAL: attempt to open unified_inventory's crafting guide
	if ui then
		local keys = user:get_player_control()
		-- while testing let's use zoom until we either drop the idea
		-- or get it to work
		if keys.zoom then --aux1 then ---and keys.sneak then
			ui.current_item[name] = node.name
			ui.current_craft_direction[name] = 'recipe'
			ui.current_searchbox[name] = node.name
			ui.apply_filter(user, node.name, 'recipe')--'usage' --nochange')
			minetest.show_formspec(name, '', ui.get_formspec(user, 'craftguide'))
			return
		end
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

	-- fetch recipes from core
	local res = minetest.get_all_craft_recipes(node_name)
	if not res then
		res = {}
	end
--print(dump(res))
	-- TODO: filter out invalid recipes with no items
	--	   such as "group:flower,color_dark_grey"
	--	also 'normal' recipe.type uranium*_dust recipes

	-- add special recipes for nodes created by machines
	for _, adder in pairs(r.recipe_adders) do
		adder.add_recipe(node_name, fields.param2, res)
	end

	-- offer all alternate crafting recipes through prev/next buttons
	if fields and fields.prev_recipe then
		recipe_nr = recipe_nr - 1
	elseif fields and fields.next_recipe then
		recipe_nr = recipe_nr + 1
	end
	-- wrap around
	if #res < recipe_nr then
		recipe_nr = 1
	elseif 1 > recipe_nr then
		recipe_nr = #res
	end

	-- fetch description
	-- when clicking unknown nodes
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

	-- base info
	local formspec = 'size[6,6]'
		-- label on top
		--.. 'textarea[-9,-18,6,1;;' .. mfe(rbi.name) .. ' ' .. node_name .. ';]'
		.. 'label[0,0;' .. mfe(rbi.name) .. ' ' .. node_name .. ']'
		.. 'tooltip[-1,-1;7,2;' .. mfe(rbi.name) .. ' ' .. node_name .. ']'
		.. 'button_exit[5.0,4.3;1,0.5;quit;X]'
		.. 'tooltip[quit;'.. mfe(rbi.exit) .. ']'

	-- prev. and next buttons
	if 1 < #res then
		formspec = formspec
			.. 'button[4.1,5;1,0.75;prev_recipe;<-]'
			.. 'tooltip[prev_recipe;'.. mfe(rbi.prev) .. ']'
			.. 'button[5.0,5;1,0.75;next_recipe;->]'
			.. 'tooltip[next_recipe;'.. mfe(rbi.next) .. ']'
	end

	formspec = formspec
		-- description at bottom
		.. 'label[0,5.7;' .. mfe(rbi.this_is) .. ' ' .. mfe(desc) .. ']'
		.. 'tooltip[-1,5.7;7,2;' .. mfe(rbi.this_is) .. ' ' .. mfe(desc) .. ']'
		 -- invisible field for passing on information
		.. 'field[20,20;0.1,0.1;node_name;node_name;' .. node_name .. ']'
		-- another invisible field
		.. 'field[21,21;0.1,0.1;recipe_nr;recipe_nr;' .. tostring(recipe_nr) .. ']'

	-- location and param2
	formspec = formspec .. 'label[0.0,0.3;'
	if fields.pos then
		formspec = formspec .. mfe(S('Located at @1', nice_pos_string(fields.pos)))
	end
	if fields.param2 then
		formspec = formspec .. ' '
			.. mfe(S('with param2 of @1', tostring(fields.param2)))
	end

	-- light
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

	-- if no recipes, collect drops else show current recipe
	if 1 > #res then
		formspec = formspec .. 'label[3,1;' .. mfe(rbi.no_recipes) .. ']'
		-- always returns a table
		local drops = r.possible_node_drops(node_name)
		formspec = formspec .. 'label[0,1.5;'
		if 0 == #drops then
			formspec = formspec .. mfe(rbi.drops_on_dig) .. ' ' .. mfe(rbi.nothing) .. ']'
		elseif 1 == #drops then
			formspec = formspec .. mfe(rbi.drops_on_dig) .. ']'
		else
			formspec = formspec .. mfe(rbi.may_drop_on_dig) .. ']'
		end
		for i, n in ipairs(drops) do
			formspec = formspec .. 'item_image_button['
				.. (((i - 1) % 3) + 1) .. ','
				.. tostring(floor(((i - 1) / 3) + 2))
				.. ';1.0,1.0;' .. r.image_button_link(n) .. ']'
			i = i + 1
		end
		-- output item on the right
		formspec = formspec
			.. 'item_image_button[5,2;1.0,1.0;' .. node_name .. ';normal;]'

	else
		if 1 < #res then
			formspec = formspec .. 'label[1,5;'
				.. mfe(S('Alternate @1/@2', tostring(recipe_nr), tostring(#res))) .. ']'
		end
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
		elseif ('cooking' == recipe.type or 'fuel' == recipe.type)
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
				.. 'item_image_button[2.2,2.2;1.0,1.0;'
				.. r.image_button_link(recipe.items[1]) .. ']'
		elseif recipe.items
			and 0 < #recipe.items
			and r.recipe_adders[recipe.type]
		then
			local handler = r.recipe_adders[recipe.type]
			formspec = formspec .. 'item_image_button[1,1;3.4,3.4;'
				.. r.image_button_link(handler.machine) .. ']'
				.. 'label[0.1,4.3;' .. mfe(S(recipe.method)) .. ']'
			local width = recipe.width or #recipe.items
			width = max(1, min(3, width))
			local offsets = { 2.2, 1.7, 1.2 }
			local offset = offsets[width]
			for i = 1, 9 do
				if not recipe.items[i] then break end
				formspec = formspec .. 'item_image_button['
					.. (((i - 1) % width) + offset) .. ','
					.. tostring(floor((i - 1) / width) + offset)
					.. ';1.0,1.0;'
					.. r.image_button_link(recipe.items[i]) .. ']'
			end
			formspec = formspec
				.. (handler.formspec and handler.formspec(recipe) or '')
		else
			formspec = formspec .. 'label[3,1;' .. mfe(rbi.unkown_recipe) .. ']'
		end
		-- output item on the right
		formspec = formspec
			.. 'item_image_button[5,2;1.0,1.0;' .. recipe.output .. ';normal;]'
	end
	minetest.show_formspec(player_name, 'replacer:crafting', formspec)
end -- inspect_show_crafting


-- translate general formspec calls back to specific calls
function replacer.form_input_handler(player, formname, fields)
	if formname and 'replacer:crafting' == formname
		and player and not fields.quit
	then
		-- too bad keys are all false :/ could have implemented easy
		-- switch to unified_inventory formspec
		--local keys = player:get_player_control()
		r.inspect_show_crafting(player:get_player_name(), nil, fields)
		return
	end
end

-- establish a callback so that input from the player-specific
-- formspec gets handled
minetest.register_on_player_receive_fields(replacer.form_input_handler)

