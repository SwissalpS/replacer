local r = replacer
local rm = r.materials

if not r.hide_recipe_basic then
	minetest.register_craft({
		output = r.tool_name_basic,
		recipe = {
			{ rm.chest, '', rm.gold_ingot },
			{ '', rm.mese_crystal_fragment, '' },
			{ rm.steel_ingot, '',  '' },
		}
	})
end


-- only if technic mod is installed
if r.has_technic_mod then
	if not r.hide_recipe_technic_upgrade then
		minetest.register_craft({
			output = r.tool_name_technic,
			recipe = {
				{ r.tool_name_basic, 'technic:green_energy_crystal', '' },
				{ '', '', '' },
				{ '', '', '' },
			}
		})
	end
	if not r.hide_recipe_technic_direct then
		-- direct upgrade craft
		minetest.register_craft({
			output = r.tool_name_technic,
			recipe = {
				{ rm.chest, 'technic:green_energy_crystal', rm.gold_ingot },
				{ '', rm.mese_crystal_fragment, '' },
				{ rm.steel_ingot, '', rm.chest },
			}
		})
	end
elseif r.enable_recipe_technic_without_technic then
	minetest.register_craft({
		output = r.tool_name_technic,
		recipe = {
			{ rm.chest, rm.axe_diamond, rm.gold_ingot },
			{ rm.axe_diamond, rm.mese_crystal_fragment, rm.axe_diamond },
			{ rm.steel_ingot, rm.axe_diamond, rm.chest },
		}
	})
end


minetest.register_craft({
  output = 'replacer:inspect',
  recipe = {
		{ rm.torch },
		{ rm.stick },
  }
})

