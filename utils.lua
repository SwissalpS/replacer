local rb = replacer.blabla
local chat_send_player = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name
local log = minetest.log
local floor = math.floor
local pos_to_string = minetest.pos_to_string

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

