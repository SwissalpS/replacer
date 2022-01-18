local r = replacer
local rb = replacer.blabla
local is_protected = minetest.is_protected
local pos_to_string = minetest.pos_to_string

-- limit by node, use replacer.register_limit(sName, iMax)
replacer.limit_list = {}

-- some nodes don't rotate using param2. They can be added
-- using replacer.register_exception(node_name, inv_node_name[, callback_function])
-- where: node_name is the itemstring of node when placed in world
--		inv_node_name the itemstring of item in inventory to consume
--		callback_function is optional and will be called after node is placed.
--		  It must return true on success and false, error_message on fail.
--		  In order to register only a callback, pass two identical itemstrings.
--		  Generally the callback is not needed as on_place() is called on the placed node
--		  callback signature is: (pos, old_node_def, new_node_def, player_ref)
replacer.exception_map = {}
replacer.exception_callbacks = {}

-- don't allow these at all
replacer.deny_list = {}

-- playing with tnt and creative building are usually contradictory
-- (except when doing large-scale landscaping in singleplayer)
replacer.deny_list['tnt:boom'] = true
replacer.deny_list['tnt:gunpowder'] = true
replacer.deny_list['tnt:gunpowder_burning'] = true
replacer.deny_list['tnt:tnt'] = true

-- prevent accidental replacement of your protector
replacer.deny_list['protector:protect'] = true
replacer.deny_list['protector:protect2'] = true

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

-- priv to allow using history
replacer.history_priv = minetest.settings:get('replacer.history_priv') or 'creative'
-- disable saving history over sessions/reboots. IOW: don't use player meta e.g. if using old MT
replacer.history_disable_persistancy =
	minetest.settings:get_bool('replacer.history_disable_persistancy') or false
-- ignored when persistancy is disabled. Interval in minutes to
replacer.history_save_interval =
	tonumber(minetest.settings:get('replacer.history_save_interval') or 7)
-- include mode when changing from history
replacer.history_include_mode =
	minetest.settings:get_bool('replacer.history_include_mode') or false
-- amount of items in history
replacer.history_max = tonumber(minetest.settings:get('replacer.history_max') or 7)

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

	if r.deny_list[old_node_def.name] then
		return false, rb.deny_listed:format(old_node_def.name)
	end

	if is_protected(pos, player_name) then
		return false, rb.protected_at:format(pos_to_string(pos))
	end

	return true
end -- permit_replace

function replacer.register_exception(node_name, drop_name, callback)
	if r.exception_map[node_name] then
		minetest.log('info', rb.log_reg_exception_override:format(node_name))
	end
	r.exception_map[node_name] = drop_name
	minetest.log('info', rb.log_reg_exception:format(node_name, drop_name))

	if 'function' ~= type(callback) then return end

	r.exception_callbacks[node_name] = callback
	minetest.log('info', rb.log_reg_exception_callback:format(node_name))
end -- register_exception

local function is_positive_int(value)
	return (type(value) == 'number') and (math.floor(value) == value) and (0 <= value)
end
function replacer.register_limit(node_name, node_max)
	-- ignore nil, negative numbers and non-integers
	if not is_positive_int(node_max) then
		return
	end

	-- add to deny_list if limit is zero
	if 0 == node_max then
		r.deny_list[node_name] = true
		minetest.log('info', rb.log_deny_list_insert:format(node_name))
		return
	end

	-- log info if already limited
	if nil ~= r.limit_list[node_name] then
		minetest.log('info', rb.log_limit_override:format(node_name, r.limit_list[node_name]))
	end
	r.limit_list[node_name] = node_max
	minetest.log('info', rb.log_limit_insert:format(node_name, node_max))
end -- register_limit

