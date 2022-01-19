
local rb = replacer.blabla

-- let's hope there isn't a yes that means no in another language :/
-- TODO: better option would be to simply toggle (see postool)
local lOn = { '1', 'on', 'yes', 'an', 'ja', 'si', 'sí', 'да', 'oui', 'joo', 'juu', 'kyllä', 'sim', 'em' }
local lOff = { '0', 'off', 'no', 'aus', 'nein', 'non', 'нет', 'ei', 'fora', 'não', 'desligado' }
local tOn, tOff = {}, {}
for _, s in ipairs(lOn) do tOn[s] = true end
for _, s in ipairs(lOff) do tOff[s] = true end

replacer.chatcommand_mute = {

	params = rb.ccm_params:format(rb.on_yes, rb.off_no),
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
		if tOff[lower] then
			meta:set_int('replacer_mute', 1)
		elseif tOn[lower] then
			meta:set_int('replacer_mute', 0)
		else
			return false, rb.ccm_hint:format(rb.on_yes, rb.off_no)
		end

		return true, ''

	end
}

minetest.register_chatcommand('replacer_mute', replacer.chatcommand_mute)

