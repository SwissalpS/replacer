local r = replacer
local rm = r.materials

if not replacer.hide_recipe_basic then
	minetest.register_craft({
		output = replacer.tool_name_basic,
		recipe = {
			{ rm.chest, '', rm.gold_ingot },
			{ '', rm.mese_crystal_fragment, '' },
			{ rm.steel_ingot, '',  '' },
		}
	})
end


-- only if technic mod is installed
if replacer.has_technic_mod then
	if not replacer.hide_recipe_technic_upgrade then
		minetest.register_craft({
			output = replacer.tool_name_technic,
			recipe = {
				{ replacer.tool_name_basic, 'technic:green_energy_crystal', '' },
				{ '', '', '' },
				{ '', '', '' },
			}
		})
	end
	if not replacer.hide_recipe_technic_direct then
		-- direct upgrade craft
		minetest.register_craft({
			output = replacer.tool_name_technic,
			recipe = {
				{ rm.chest, 'technic:green_energy_crystal', rm.gold_ingot },
				{ '', rm.mese_crystal_fragment, '' },
				{ rm.steel_ingot, '', rm.chest },
			}
		})
	end
end


minetest.register_craft({
  output = 'replacer:inspect',
  recipe = {
		{ rm.torch },
		{ rm.stick },
  }
})

