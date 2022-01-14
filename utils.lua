local rb = replacer.blabla

function replacer.inform(name, message)
	if (not message) or ('' == message) then return end

	minetest.log('info', rb.log:format(name, message))
	local player = minetest.get_player_by_name(name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_mute') then return end
	minetest.chat_send_player(name, message)

end -- inform

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

