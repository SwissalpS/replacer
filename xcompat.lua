local r = replacer
r.materials = {}
r.sounds = {
	fail = { name = '' },
	success = { name = '' },
}
local rm = r.materials

if r.has_xcompat_mod then
	-- let xcompat decide what is available
	do
		local material_keys = {
			'chest',
			'dirt',
			'gold_ingot',
			'mese_crystal_fragment',
			'steel_ingot',
			'stick',
			'torch',
		}
		local i = #material_keys
		repeat
			rm[material_keys[i]] = xcompat.materials[material_keys[i]] or ''
			i = i - 1
		until 0 == i
	end

	local sound = xcompat.sounds.node_sound_glass_defaults()
	if sound and sound.dug and sound.dug.name then
		r.sounds.fail.name = sound.dug.name
	else
		r.sounds.fail.gain = 0.0
	end
	-- TODO: PR xcompat to have 'default_item_smoke' and similar
	sound = xcompat.sounds.node_sound_sand_defaults()
	if sound and sound.dug and sound.dug.name then
		r.sounds.success.name = sound.dug.name
	else
		r.sounds.success.gain = 0.0
	end
else
	-- assume default game
	r.materials = {
		chest = 'default:chest',
		dirt = 'default:dirt',
		gold_ingot = 'default:gold_ingot',
		mese_crystal_fragment = 'default:mese_crystal_fragment',
		steel_ingot = 'default:steel_ingot',
		stick = 'default:stick',
		torch = 'default:torch',
	}

	r.sounds.fail.name = 'default_break_glass'
	r.sounds.success.name = 'default_item_smoke'
end

if r.has_technic_mod then
	r.sounds.fail.name = 'technic_prospector_miss'
	r.sounds.fail.gain = 0.1
	--r.sounds.success.name = 'technic_prospector_hit'
	--r.sounds.success.gain = 0.1
end

