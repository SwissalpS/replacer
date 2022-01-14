local r = replacer
local rb = replacer.blabla

-- limit by node, use replacer.register_limit(sName, iMax)
replacer.limit_list = {}

-- some nodes don't rotate using param2. They can be added
-- using replacer.register_exception(node_name, inv_node_name[, callback_function])
-- where: node_name is the itemstring of node when placed in world
--        inv_node_name the itemstring of item in inventory to consume
--        callback_function is optional and will be called after node is placed.
--          It must return true on success and false, error_message on fail.
--          In order to register only a callback, pass two identical itemstrings.
--          Generally the callback is not needed as on_place() is called on the placed node
--          callback signature is: (pos, old_node_def, new_node_def, player_ref)
replacer.exception_map = {}
replacer.exception_callbacks = {}

-- don't allow these at all
replacer.blacklist = {}

-- playing with tnt and creative building are usually contradictory
-- (except when doing large-scale landscaping in singleplayer)
replacer.blacklist['tnt:boom'] = true
replacer.blacklist['tnt:gunpowder'] = true
replacer.blacklist['tnt:gunpowder_burning'] = true
replacer.blacklist['tnt:tnt'] = true

-- prevent accidental replacement of your protector
replacer.blacklist['protector:protect'] = true
replacer.blacklist['protector:protect2'] = true

-- charge limits
replacer.max_charge = 30000
replacer.charge_per_node = 15
-- node count limit
replacer.max_nodes = tonumber(minetest.settings:get('replacer.max_nodes') or 3168)
-- Time limit when placing the nodes, in seconds (not including search time)
replacer.max_time = tonumber(minetest.settings:get('replacer.max_time') or 1.0)
-- Radius limit factor when more possible positions are found than either max_nodes or charge
-- Set to 0 or less for behaviour of before version 3.3
-- [see replacer_patterns.lua>replacer.patterns.search_positions()]
replacer.radius_factor = tonumber(minetest.settings:get('replacer.radius_factor') or 0.4)

-- select which recipes to hide (not all combinations make sense)
replacer.hide_recipe_basic =
	minetest.settings:get_bool('replacer.hide_recipe_basic') or false
replacer.hide_recipe_technic_upgrade =
	minetest.settings:get_bool('replacer.hide_recipe_technic_upgrade') or false
replacer.hide_recipe_technic_direct =
	minetest.settings:get_bool('replacer.hide_recipe_technic_direct')
if nil == replacer.hide_recipe_technic_direct then
	replacer.hide_recipe_technic_direct = true
end

-- function that other mods, especially custom server mods,
-- can override. e.g. restrict usage of replacer in certain
-- areas, privs, throttling etc.
-- This is called before replacing the node/air and expects
-- a boolean return and in the case of fail, an optional message
-- that will be sent to player
function replacer.permit_replace(pos, old_node_def, new_node_def,
        player_ref, player_name, player_inv, creative_or_give)

	if minetest.is_protected(pos, player_name) then
		return false, rb.protected_at:format(minetest.pos_to_string(pos))
	end

	if replacer.blacklist[old_node_def.name] then
		return false, rb.blacklisted:format(old_node_def.name)
	end

    return true
end -- permit_replace

