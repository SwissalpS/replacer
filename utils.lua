local r = replacer
local rb = replacer.blabla
local chat_send_player = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name
local get_node_drops = minetest.get_node_drops
local core_log = minetest.log
local floor = math.floor
local absolute = math.abs
local concat = table.concat
local insert = table.insert
local gmatch = string.gmatch
local registered_nodes = minetest.registered_nodes
local pos_to_string = minetest.pos_to_string
local sound_play = minetest.sound_play
local sound_fail = 'default_break_glass'
local sound_success = 'default_item_smoke'
local sound_gain = 0.5
if r.has_technic_mod then
	sound_fail = 'technic_prospector_miss'
	--sound_success = 'technic_prospector_hit'
	sound_gain = 0.1
end


function replacer.common_list_items(list1, list2)
	if 'table' ~= type(list1) or 'table' ~= type(list2) then return {} end
	if 0 == #list1 or 0 == #list2 then return {} end

	local common, index1, total2, j = {}, #list1, #list2
	repeat
		j = total2
		repeat
			if list1[index] == list2[j] then
				insert(common, list2[j])
				break
			end
			j = j - 1
		until 0 == j
		index = index - 1
	until 0 == index

	return common
end -- common_list_items


function replacer.inform(name, message)
	if (not message) or ('' == message) then return end

	core_log('info', rb.log_messages:format(name, message))
	local player = get_player_by_name(name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_mute') then return end

	chat_send_player(name, message)
end -- inform


function replacer.nice_duration(seconds)
	if 'number' ~= type(seconds) then return '' end

	seconds = absolute(seconds)
	local days = floor(seconds / 86400)
	seconds = seconds % 86400
	local text = (0 == days and '') or (tostring(days) .. ' ' .. rb.days .. ' ')
	return text .. os.date('! %H:%M:%S', seconds)
end -- nice_duration


function replacer.nice_number(number, seperator)
	if 'number' ~= type(number) then return '' end

	local sign = 0 > number and '-' or ''
	-- TODO: use default depending on locale, won't work as not all 'de' use same
	-- and not all 'en' use same, hindi has it's own format: 12'34'567
	seperator = seperator or "'"
	local reversed = tostring(absolute(number)):reverse()
	local list = {}
	for s in gmatch(reversed, '...') do insert(list, s) end
	local rest = #reversed % 3
	if 0 ~= rest then insert(list, reversed:sub(-rest, -1)) end
	return sign .. concat(list, seperator):reverse()
end -- nice_number


function replacer.nice_pos_string(pos)
	local no_info = '<no positional information>'
	if 'table' ~= type(pos) then return no_info end
	if not (pos.x and pos.y and pos.z) then return no_info end

	pos = { x = floor(pos.x + .5), y = floor(pos.y + .5), z = floor(pos.z + .5) }
	return pos_to_string(pos)
end -- nice_pos_string


function replacer.play_sound(player_name, fail)
	local player = get_player_by_name(player_name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_muteS') then return end

	sound_play(fail and sound_fail or sound_success, {
		to_player = player_name,
		max_hear_distance = 2,
		gain = sound_gain }, true)
end -- play_sound


function replacer.possible_node_drops(node_name, return_names_only)
	if not registered_nodes[node_name] then return {} end

	local droplist = {}
	local drop = registered_nodes[node_name].drop or ''
	if 'string' == type(drop) then
		if '' == drop then
			-- this returns value with randomness applied :/
			drop = get_node_drops(node_name)
			if 0 == #drop then return {} end

			if not return_names_only then return drop end

			for _, item in ipairs(drop) do
				insert(droplist, item:match('^([^ ]+)'))
			end
			return droplist
		end

		if not return_names_only then return { drop } end

		return { drop:match('^([^ ]+)') }
	end -- if string

	if 'table' ~= type(drop) or not drop.items then return {} end

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
				insert(droplist, item)
			end
		end
	end
	return droplist
end -- possible_node_drops


function replacer.print_dump(...)
	if not r.dev_mode then return end

	for _, m in ipairs({ ... }) do
		print(dump(m))
	end
end -- print_dump


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

