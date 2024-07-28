local r = replacer
r.materials = {}
r.machines = {}
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
	rm.chest = 'default:chest'
	rm.dirt = 'default:dirt'
	rm.gold_ingot = 'default:gold_ingot'
	rm.mese_crystal_fragment = 'default:mese_crystal_fragment'
	rm.steel_ingot = 'default:steel_ingot'
	rm.stick = 'default:stick'
	rm.torch = 'default:torch'

	r.sounds.fail.name = 'default_break_glass'
	r.sounds.success.name = 'default_item_smoke'
end

if r.has_technic_mod then
	r.sounds.fail.name = 'technic_prospector_miss'
	r.sounds.fail.gain = 0.1
	--r.sounds.success.name = 'technic_prospector_hit'
	--r.sounds.success.gain = 0.1
end


-- machines are not yet covered by xcompat
local gameid = xcompat.gameid
if 'farlands_reloaded' == gameid then
	r.machines.furnace = 'fl_workshop:furnace'
	r.machines.furnace_active = 'fl_workshop:furnace_active'
elseif 'hades_revisited' == gameid then
	r.machines.furnace = 'hades_furnaces:furnace'
	r.machines.furnace_active = 'hades_furnaces:furnace_active'
elseif 'mineclonia' == gameid then
	r.machines.furnace = 'mcl_furnaces:furnace'
	r.machines.furnace_active = 'mcl_furnaces:furnace_active'
else
	-- fallback to default game
	r.machines.furnace = 'default:furnace'
	r.machines.furnace_active = 'default:furnace_active'
end

