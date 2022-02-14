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
local concat = table.concat
local insert = table.insert
local chat = minetest.chat_send_player
local mfe = minetest.formspec_escape
local core_log = minetest.log
local deserialize = minetest.deserialize
local parse_json = minetest.parse_json
local get_node_or_nil = minetest.get_node_or_nil
local get_node_light = minetest.get_node_light
local get_pointed_thing_position = minetest.get_pointed_thing_position
local get_all_craft_recipes = minetest.get_all_craft_recipes
local is_protected = minetest.is_protected
local show_formspec = minetest.show_formspec
local registered_abms = minetest.registered_abms
local registered_lbms = minetest.registered_lbms
local registered_aliases = minetest.registered_aliases
local registered_tools = minetest.registered_tools
local registered_nodes = minetest.registered_nodes
local registered_items = minetest.registered_items
local registered_entities = minetest.registered_entities
local registered_craftitems = minetest.registered_craftitems
-- luacheck: push ignore unused pd
local pd = r.print_dump
-- luacheck: pop
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
			or not registered_items[machine_itemstring])
		or 'function' ~= type(func_inspect)
	then
		core_log('warning', rbi.log_reg_craft_method_wrong_arguments)
		return
	end

	if r.recipe_adders[uid] then
		core_log('warning', rbi.log_reg_craft_method_overriding_method .. uid)
	end

	r.recipe_adders[uid] = {
		machine = machine_itemstring,
		add_recipe = func_inspect,
		formspec = ('function' == type(func_formspec) and func_formspec) or nil
	}
	core_log('info', rbi.log_reg_craft_method_added:format(uid, machine_itemstring))
end -- register_craft_method


minetest.register_tool('replacer:inspect', {
	description = rbi.description,
	groups = {},
	inventory_image = 'replacer_inspect.png',
	wield_image = '',
	wield_scale = { x = 1, y = 1, z = 1 },
	liquids_pointable = true, -- it is ok to request information about liquids

	on_use = function(itemstack, player, pointed_thing)
		return r.inspect(itemstack, player, pointed_thing)
	end,

	on_place = function(itemstack, player, pointed_thing)
		return r.inspect(itemstack, player, pointed_thing, true)
	end,
})


function replacer.inspect(_, player, pointed_thing, right_clicked)
	if nil == player or nil == pointed_thing then
		return nil
	end

	local player_name = player:get_player_name()
	if 'object' == pointed_thing.type then
		chat(player_name, r.inspect_entity(pointed_thing.ref, player))
		return nil
	elseif 'node' ~= pointed_thing.type then
		chat(player_name, S('Sorry, this is an unkown something of type "@1". '
			.. 'No information available.', pointed_thing.type))
		return nil
	end

	local pos  = get_pointed_thing_position(pointed_thing, right_clicked)
	local node = get_node_or_nil(pos)
	if not node then
		chat(player_name, rb.wait_for_load)
		return nil
	end

	-- EXPERIMENTAL: attempt to open unified_inventory's crafting guide
	if ui then
		local keys = player:get_player_control()
		-- while testing let's use zoom until we either drop the idea
		-- or get it to work
		if keys.zoom then --aux1 then ---and keys.sneak then
			ui.current_item[player_name] = node.name
			ui.current_craft_direction[player_name] = 'recipe'-- keys.x and 'usage' or 'recipe'
			ui.current_searchbox[player_name] = node.name
			ui.apply_filter(player, node.name, 'recipe')--'usage' --nochange')
			show_formspec(player_name, '', ui.get_formspec(player, 'craftguide'))
			return
		end
	end

--pd(node, registered_nodes[node.name].mod_origin)
	local protected_info = ''
	if is_protected(pos, player_name) then
		protected_info = rbi.is_protected
	elseif is_protected(pos, '_THIS_NAME_DOES_NOT_EXIST_') then
		protected_info = rbi.you_can_dig
	end

		-- get light of the node at the current time
	local light = get_node_light(pos, nil)
	-- the fields part is used here to provide additional
	-- information about the node
	r.inspect_show_crafting(player_name, node.name, {
		pos = pos,
		param2 = node.param2,
		light = light,
		protected_info = protected_info
	})

	return nil -- no item shall be removed from inventory
end -- replacer.inspect


-- bug work around to prevent using inspection tool as a weapon
local function is_endangered(luaob)
	if not luaob._cmi_is_mob then return false end
	if not registered_entities[luaob.name] then return false end

	return '' == luaob.owner
end -- is_endangered


-- helper for inspect_entity()/inspect_mob()
local function is_registered(item_name_or_group)
	if 'string' ~= type(item_name_or_group) then return false end
	if item_name_or_group:find('^:?group:') then return true end
	return registered_items[item_name_or_group] and true or false
end

function replacer.inspect_mob(luaob)

	local index, list
	local entity_def = registered_entities[luaob.name]
	local text = '\n'
	if 'string' == type(entity_def.type) then
		text = text .. rbi.mobs_of_type .. ' "' .. entity_def.type .. '". '
	end
	if entity_def.owner_loyal then
		text = text .. rbi.mobs_loyal .. ' '
	end
--[[ these are too inacurate.
	if entity_def.attack_players then
		text = text .. 'Can attack players. '
	end
	if entity_def.attack_animals then
		text = text .. 'Can attack animals. '
	end
	if entity_def.attack_monsters then
		text = text .. 'Can attack monsters. '
	end
	if entity_def.attack_npcs then
		text = text .. 'Can attack NPCs. '
	end
--]]
	if 'table' == type(entity_def.specific_attack) then
		list, index = {}, #entity_def.specific_attack
		if 0 < index then repeat
			if is_registered(entity_def.specific_attack[index]) then
				list[#list + 1] = entity_def.specific_attack[index]
			end
			index = index - 1
		until 0 == index
		if 0 < #list then
			text = text .. rbi.mobs_attacks .. ' ' .. concat(list, ', ') .. '\n'
		end end
	end
	if 'table' == type(entity_def.follow) then
		list, index = {}, #entity_def.follow
		if 0 < index then repeat
			if is_registered(entity_def.follow[index]) then
				list[#list + 1] = entity_def.follow[index]
			end
			index = index - 1
		until 0 >= index
		if 0 < #list then
			text = text .. rbi.mobs_follows .. ' ' .. concat(list, ', ') .. '\n'
		end end
	end
	if 'table' == type(entity_def.drops) then
		list, index = {}, #entity_def.drops
		if 0 < index then repeat
			if 'table' == type(entity_def.drops[index])
				and is_registered(entity_def.drops[index].name)
			then
				list[#list + 1] = entity_def.drops[index].name
			end
			index = index - 1
		until 0 >= index
		if 0 < #list then
			text = text .. rbi.mobs_drops .. ' ' .. concat(list, ', ') .. '\n'
		end end
	end
	if 'number' == type(entity_def.damage) and 0 < entity_def.damage then
		text = text .. S('Can deal @1 damage.', entity_def.damage) .. ' '
	end
	if 'number' == type(entity_def.armor) and 0 < entity_def.armor then
		text = text .. S('Has @1 armour.', entity_def.armor) .. ' '
	end
	if entity_def.arrow then
		text = text .. rbi.mobs_shoots .. ' '
	end
	-- some mobs could still be breedable without these two fields
	if 'function' == type(entity_def.on_breed) or entity_def.child_texture then
		text = text .. rbi.mobs_breed .. ' '
	end
--[[ some of these might be of interest too
reach
immune_to
light_damage
light_damage_min
light_damage_max
water_damage
lava_damage
fire_damage
air_damage
suffocation
stay_near
hp_min
hp_max
jump
jump_height
fear_height
fly
fly_in
floats
glow
passive
attack_type
docile_by_day
group_attack
group_helper
runaway
runaway_from
view_range
--]]
	-- investigate spawning conditions (nodes and neighours)
	local found, entry, j
	local search_string = luaob.name .. ' spawning'
	index = #registered_abms
	if 0 < index then repeat
		entry = registered_abms[index]
		if entry.label and search_string == entry.label then
			found = true
			list, j = {}, #entry.nodenames
			if 0 < j then repeat
				if is_registered(entry.nodenames[j]) then
					list[#list + 1] = entry.nodenames[j]
				end
				j = j - 1
			until 0 == j
			if 0 < #list then
				text = text .. '\n' .. rbi.mobs_spawns_on .. ' ' .. concat(list, ', ')
			end end
			list, j = {}, #entry.neighbors
			if 0 < j then repeat
				if is_registered(entry.neighbors[j]) then
					list[#list + 1] = entry.neighbors[j]
				end
				j = j - 1
			until 0 == j
			if 0 < #list then
				text = text .. ' ' .. rbi.mobs_spawns_neighbours .. ' '
					.. concat(list, ', ')
			end end
		end
		index = index - 1
	until (0 == index) or found end
	if not found then
		search_string = luaob.name .. '_spawning'
		index = #registered_lbms
		if 0 < index then repeat
			entry = registered_lbms[index]
			if entry.name and search_string == entry.name then
				found = true
				list, j = {}, #entry.nodenames
				if 0 < j then repeat
					if is_registered(entry.nodenames[j]) then
						list[#list + 1] = entry.nodenames[j]
					end
					j = j - 1
				until 0 == j
				if 0 < #list then
					text = text .. '\n' .. rbi.mobs_spawns_on .. ' ' .. concat(list, ', ')
				end end
			end
			index = index - 1
		until (0 == index) or found end
	end
	return text
end -- inspect_mob


function replacer.inspect_player(object_ref, player)
	local lines = { S('This is your fellow player "@1"', object_ref:get_player_name()) }
	local meta = object_ref:get_meta()
	local xp_hud_on = 'off' ~= meta:get_string('hud_state')
	local placed = xp_hud_on and meta:get_int('placed_nodes')
	local digs = xp_hud_on and meta:get_int('digged_nodes')
	local punches = xp_hud_on and meta:get_int('punch_count')
	local inflicted = xp_hud_on and meta:get_int('inflicted_damage')
	local xp = xp_hud_on and meta:get_int('xp')
	local play_seconds = meta:get_int('played_time')
	local deaths = meta:get_int('died')
	-- TODO: not accurate if either player has never joined any channel, then #main is not yet in list
	local channels = nil --parse_json(meta:get_string('beerchat:channels'))
	local has_active_mission = deserialize(meta:get_string('currentmission')) and true or false
	local wearing = deserialize(meta:get_string('3d_armor_inventory'))
	-- other possible interesting points:
	--	["stamina:poisoned"] = "no",
	--	["stamina:exhaustion"] = "0"

	-- short_data_points
	local shorts = {}
	if placed and 0 < placed then
		insert(shorts, rbi.player_placed .. ' ' .. r.nice_number(placed))
	end
	if digs and 0 < digs then
		insert(shorts, rbi.player_digs .. ' ' .. r.nice_number(digs))
	end
	if punches and 0 < punches then
		insert(shorts, rbi.player_punches .. ' ' .. r.nice_number(punches))
	end
	if inflicted and 0 < inflicted then
		insert(shorts, rbi.player_inflicted .. ' ' .. r.nice_number(inflicted))
	end
	if xp and 0 < xp then
		insert(shorts, rbi.player_xp .. ' ' .. r.nice_number(xp))
	end
	if 0 < deaths then
		insert(shorts, rbi.player_deaths .. ' ' .. r.nice_number(deaths))
	end
	if 0 < #shorts then
		insert(lines, concat(shorts, '\t'))
	end
	if 0 < play_seconds then
		insert(lines, rbi.player_duration .. ' ' .. r.nice_duration(play_seconds))
	end
	if has_active_mission then
		insert(lines, rbi.player_has_active_mission)
	end
	if channels then
		local common = r.common_list_items(channels,
			parse_json(player:get_meta():get_string('beerchat:channels')))
		if 0 == #common then
			insert(lines, rbi.player_no_common_channels)
		else
			insert(lines, rbi.player_common_channels .. ' ' .. concat(common, ', '))
		end
	end
	if wearing and 0 < #wearing then
		local index, parts = #wearing, {}
		repeat
			if '' ~= wearing[index] then
				insert(parts, wearing[index])
			end
			index = index - 1
		until 0 == index
		if 0 < #parts then
			insert(lines, rbi.player_is_wearing .. ' ' .. concat(parts, ', '))
		end
	end

	return concat(lines, '\n')
end -- inspect_player


function replacer.inspect_entity(object_ref, player)
	if not object_ref then return rbi.broken_object end

	local pos_string = S('at @1', nice_pos_string(object_ref:getpos()))
	if object_ref:is_player() then
		return r.inspect_player(object_ref, player) --.. ' ' .. pos_string
	end

	local luaob = object_ref:get_luaentity()
	if not luaob then return rbi.this_is_object .. ' ' .. pos_string end

	if (not luaob.get_staticdata) and (not registered_entities[luaob.name]) then
		return S('This is an object "@1"', luaob.name) .. ' ' .. pos_string
	end

	local text = (luaob._cmi_is_mob and rbi.mobs_disclaimer .. '\n' or '')
		.. S('This is an entity "@1"', luaob.name)
	if luaob.get_staticdata and not is_endangered(luaob) then
		text = text .. r.inspect_staticdata(luaob:get_staticdata())
	end
	if not registered_entities[luaob.name] then return text end

	if luaob._cmi_is_mob then return text .. r.inspect_mob(luaob) end

	return text
end -- inspect_entity


function replacer.inspect_staticdata(staticdata)
	if (not staticdata) or (0 == #staticdata) then return '' end

	local text = ''
	local sdata = deserialize(staticdata) or {}
	if sdata.itemstring then
		text = text .. ' [' .. sdata.itemstring .. ']'
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
	if 'table' == type(sdata.follow) and 0 < #sdata.follow then
		text = text .. ' is tamable'
	end
	if 'string' == type(sdata.order) then
		text = text .. ' ' .. S('with order to @1', sdata.order)
	end
	if 'table' == type(sdata.inv) then
		local item_count = 0
		local type_count = 0
		for _, v in pairs(sdata.inv) do
			type_count = type_count + 1
			item_count = item_count + v
		end
		if 0 < type_count then
			text = text .. '\n'
			if 1 < type_count then
				text = text .. S('Has @1 different types of items,',
					tostring(type_count)) .. ' '
			end
			text = text .. S('total of @1 items in inventory.',
				tostring(item_count))
		end
	end
	return text
end -- inspect_staticdata


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
--pd(stack_string .. ';' .. new_node_name .. ';' .. group)
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
				and registered_items[k]
				or registered_nodes[k]
				or registered_craftitems[k]
				or registered_tools[k]
			then
				node_name = k
				recipe_nr = 1
			end
		end
	end

	-- fetch recipes from core
	local recipes = get_all_craft_recipes(node_name) or {}
	if 0 == #recipes then
		-- some items have aliases that are set with force, and thus
		-- don't show up in core.get_all_craft_recipes()
		-- e.g. https://github.com/mt-mods/basic_materials/blob/d9e06980d33ec02c2321269f47ab9ec32b36551f/aliases.lua#L32
		-- https://github.com/mt-mods/basic_materials/blob/d9e06980d33ec02c2321269f47ab9ec32b36551f/crafts.lua#L256
		-- we try to reverse lookup here
		for k, v in pairs(registered_aliases) do
			if v == node_name then
				recipes = get_all_craft_recipes(k)
				if recipes then break end
			end
		end
		recipes = recipes or {}
	end
--pd(recipes)
	-- TODO: filter out invalid recipes with no items
	--	   such as "group:flower,color_dark_grey"

	-- add special recipes for nodes created by machines
	for _, adder in pairs(r.recipe_adders) do
		adder.add_recipe(node_name, fields, recipes)
	end

	-- offer all alternate crafting recipes through prev/next buttons
	if fields and fields.prev_recipe then
		recipe_nr = recipe_nr - 1
	elseif fields and fields.next_recipe then
		recipe_nr = recipe_nr + 1
	end
	-- wrap around
	if #recipes < recipe_nr then
		recipe_nr = 1
	elseif 1 > recipe_nr then
		recipe_nr = #recipes
	end

	-- fetch description
	-- when clicking unknown nodes
	local description = ' ' .. rbi.no_description .. ' '
	if registered_nodes[node_name] then
		if registered_nodes[node_name].description
			and '' ~= registered_nodes[node_name].description
		then
			description = registered_nodes[node_name].description
		elseif registered_nodes[node_name].name then
			description = registered_nodes[node_name].name
		else
			description = ' ' .. rbi.no_node_description .. ' '
		end
	elseif registered_items[node_name] then
		if registered_items[node_name].description
			and '' ~= registered_items[node_name].description
		then
			description = registered_items[node_name].description
		elseif registered_items[node_name].name then
			description = registered_items[node_name].name
		else
			description = ' ' .. rbi.no_item_description .. ' '
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
	if 1 < #recipes then
		formspec = formspec
			.. 'button[4.1,5;1,0.75;prev_recipe;<-]'
			.. 'tooltip[prev_recipe;'.. mfe(rbi.prev) .. ']'
			.. 'button[5.0,5;1,0.75;next_recipe;->]'
			.. 'tooltip[next_recipe;'.. mfe(rbi.next) .. ']'
	end

	formspec = formspec
		-- description at bottom
		.. 'label[0,5.7;' .. mfe(rbi.this_is) .. ' ' .. mfe(description) .. ']'
		.. 'tooltip[-1,5.7;7,2;' .. mfe(rbi.this_is) .. ' ' .. mfe(description) .. ']'
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
		formspec = formspec .. 'label[0.0,4.7;'
			.. mfe(fields.protected_info) .. ']'
			.. 'tooltip[-1,4.7;5,1;' .. mfe(fields.protected_info) .. ']'
	end

	-- if no recipes, collect drops else show current recipe
	if 1 > #recipes then
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
		for i, drop_name in ipairs(drops) do
			formspec = formspec .. 'item_image_button['
				.. (((i - 1) % 3) + 1) .. ','
				.. tostring(floor(((i - 1) / 3) + 2))
				.. ';1.0,1.0;' .. r.image_button_link(drop_name) .. ']'
		end
		-- output item on the right
		formspec = formspec
			.. 'item_image_button[5,2;1.0,1.0;' .. node_name .. ';normal;]'

	else
		if 1 < #recipes then
			formspec = formspec .. 'label[1,5;'
				.. mfe(S('Alternate @1/@2', tostring(recipe_nr), tostring(#recipes))) .. ']'
		end
		-- reverse order; default recipes (and thus the most intresting ones)
		-- are usually the oldest
		local recipe = recipes[#recipes + 1 - recipe_nr]
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
				.. 'label[0.1,4.3;' .. mfe(recipe.method) .. ']'
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
--pd('unhandled recipe encountered', recipe)
--r.play_sound(player_name, true)
			formspec = formspec .. 'label[3,1;' .. mfe(rbi.unkown_recipe) .. ']'
		end
		-- output item on the right
		formspec = formspec
			.. 'item_image_button[5,2;1.0,1.0;' .. recipe.output .. ';normal;]'
	end
	show_formspec(player_name, 'replacer:crafting', formspec)
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

