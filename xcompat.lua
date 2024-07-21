local r = replacer
r.materials = {}
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

	r.sounds = {
		fail = {
			name = xcompat.sounds.node_sound_glass_defaults().dug.name
		},
		-- TODO: PR xcompat to have 'default_item_smoke' and similar
		success = {
			name = xcompat.sounds.node_sound_sand_defaults().dug.name
		}
	}
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

	r.sounds = {
		fail = {
			name = 'default_break_glass'
		},
		success = {
			name = 'default_item_smoke'
		}
	}
end

if r.has_technic_mod then
	r.sounds.fail.name = 'technic_prospector_miss'
	r.sounds.fail.gain = 0.1
	--r.sounds.success.name = 'technic_prospector_hit'
	--r.sounds.success.gain = 0.1
end

