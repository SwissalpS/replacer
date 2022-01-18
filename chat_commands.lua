
local rb = replacer.blabla

replacer.chatcommand_mute = {

	params = rb.ccm_params,
	description = rb.ccm_description,
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then -- TODO: seems unlikely to happen
			return false, rb.ccm_player_not_found
		end
		local meta = player:get_meta()
		if not meta then -- TODO: seems unlikely to happen
			return false, rb.ccm_player_meta_error
		end

		local lower = string.lower(param)
		if 'on' == lower then
			meta:set_int('replacer_mute', 1)
		elseif 'off' == lower then
			meta:set_int('replacer_mute', 0)
		else
			return false, rb.ccm_hint
		end

		return true, ''

	end
}

minetest.register_chatcommand('replacer_mute', replacer.chatcommand_mute)

