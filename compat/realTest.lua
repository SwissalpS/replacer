-- overrides for replacer:inspect
-- support for RealTest
if minetest.get_modpath('trees')
	and minetest.get_modpath('core')
	and minetest.get_modpath('instruments')
	and minetest.get_modpath('anvil')
	and minetest.get_modpath('scribing_table')
then
	replacer.image_replacements['group:planks'] = 'trees:pine_planks'
	replacer.image_replacements['group:plank'] = 'trees:pine_plank'
	replacer.image_replacements['group:wood'] = 'trees:pine_planks'
	replacer.image_replacements['group:tree'] = 'trees:pine_log'
	replacer.image_replacements['group:sapling'] = 'trees:pine_sapling'
	replacer.image_replacements['group:leaves'] = 'trees:pine_leaves'
	replacer.image_replacements['default:furnace'] = 'oven:oven'
	replacer.image_replacements['default:furnace_active'] = 'oven:oven_active'
end

