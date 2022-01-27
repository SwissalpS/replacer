local r = replacer
local rb = replacer.blabla
local chat_send_player = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name
local log = minetest.log
local floor = math.floor
local pos_to_string = minetest.pos_to_string
local sound_fail = 'default_break_glass'
local sound_success = 'default_item_smoke'
local sound_gain = 0.5
if r.has_technic_mod then
	sound_fail = 'technic_prospector_miss'
	--sound_success = 'technic_prospector_hit'
	sound_gain = 0.1
end


function replacer.play_sound(player_name, fail)
	local player = get_player_by_name(player_name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_muteS') then return end

	minetest.sound_play(fail and sound_fail or sound_success, {
		to_player = player_name,
		max_hear_distance = 2,
		gain = sound_gain }, true)
end -- play_sound


function replacer.possible_node_drops(node_name, return_names_only)
	if not minetest.registered_nodes[node_name]
		or not minetest.registered_nodes[node_name].drop then return {} end

	local drop = minetest.registered_nodes[node_name].drop
	if 'string' == type(drop) then
		if '' == drop then return {} end
		if return_names_only then
			return { drop:match('^([^ ]+)') }
		end
		return { drop }
	end

	if 'table' ~= type(drop) or not drop.items then return {} end

	local droplist = {}
	local checks = {}
	for _, drops in ipairs(drop.items) do
		for _, item in ipairs(drops.items) do
			-- avoid duplicates; but include the item itself
			-- these are itemstrings so same item can appear multiple times with
			-- different amounts and/or rarity
			if return_names_only then
				item = item:match('^([^ ]+)')
			end
			if not checks[item] then
				checks[item] = 1
				table.insert(droplist, item)
			end
		end
	end
	return droplist
end -- possible_node_drops


function replacer.inform(name, message)
	if (not message) or ('' == message) then return end

	log('info', rb.log_messages:format(name, message))
	local player = get_player_by_name(name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_mute') then return end

	chat_send_player(name, message)
end -- inform


function replacer.nice_pos_string(pos)
	local no_info = '<no positional information>'
	if 'table' ~= type(pos) then return no_info end
	if not (pos.x and pos.y and pos.z) then return no_info end

	pos = { x = floor(pos.x + .5), y = floor(pos.y + .5), z = floor(pos.z + .5) }
	return pos_to_string(pos)
end -- nice_pos_string


-- from: http://lua-users.org/wiki/StringRecipes
function replacer.titleCase(str)
	local function titleCaseHelper(first, rest)
		return first:upper() .. rest:lower()
	end
	-- Add extra characters to the pattern if you need to. _ and ' are
	--  found in the middle of identifiers and English words.
	-- We must also put %w_' into [%w_'] to make it handle normal stuff
	-- and extra stuff the same.
	-- This also turns hex numbers into, eg. 0Xa7d4
	str = str:gsub("(%a)([%w_']*)", titleCaseHelper)
	return str
end -- titleCase

