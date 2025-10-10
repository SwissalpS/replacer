-- overrides for replacer:inspect
-- support for RealTest
if core.get_modpath('trees')
	and core.get_modpath('core')
	and core.get_modpath('instruments')
	and core.get_modpath('anvil')
	and core.get_modpath('scribing_table')
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

