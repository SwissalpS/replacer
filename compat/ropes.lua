if not minetest.get_modpath('ropes') then return end

replacer.register_non_creative_alias('ropes:ropeladder', 'ropes:ropeladder_top')
replacer.register_non_creative_alias('ropes:ropeladder_bottom', 'ropes:ropeladder_top')
-- for these there are multiple targets. For now, alias to cheapest one
replacer.register_non_creative_alias('ropes:rope', 'ropes:wood1rope_block')
-- for these there are multiple targets. For now, alias to longest one
replacer.register_non_creative_alias('ropes:rope_bottom', 'ropes:steel9rope_block')

