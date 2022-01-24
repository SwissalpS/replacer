-- replacer has default mod as hard dependancy, so no checking
-- helpers for inspection tool
-- some common groups
replacer.group_placeholder['group:water_bucket'] = 'bucket:bucket_river_water'
replacer.group_placeholder['group:coal'] = 'default:coal_lump'
replacer.group_placeholder['group:fence'] = 'default:fence_wood'
replacer.group_placeholder['group:leaves'] = 'default:leaves'
replacer.group_placeholder['group:marble']= 'technic:marble' -- building_blocks:Marble
replacer.group_placeholder['group:sand'] = 'default:sand'
replacer.group_placeholder['group:sapling']= 'default:sapling'
replacer.group_placeholder['group:stick'] = 'default:stick'
-- 'default:stone' point people to the cheaper cobble
replacer.group_placeholder['group:stone'] = 'default:cobble'
replacer.group_placeholder['group:tar_block'] = 'building_blocks:Tar'
replacer.group_placeholder['group:tree'] = 'default:tree'
replacer.group_placeholder['group:vessel'] = 'fireflies:firefly_bottle'
replacer.group_placeholder['group:wood'] = 'default:wood'
replacer.group_placeholder['group:wood_slab'] = 'stairs:slab_wood'
replacer.group_placeholder['group:wool'] = 'wool:white'
-- pickaxes
local picks = { 'diamond', 'bronze', 'mese', 'steel', 'stone', 'wood' }
table.shuffle(picks)
replacer.group_placeholder['group:pickaxe'] = 'default:pick_' .. picks[1]

-- add default game dyes
for _, color in pairs(dye.dyes) do
	replacer.group_placeholder['group:dye,color_' .. color[1] ] = 'dye:' .. color[1]
end

-- add default game flowers
local name, groups
for _, flower in pairs(flowers.datas) do
	name = flower[1]
	groups = flower[4]
	for k, _ in pairs(groups) do
		if 1 == k:find('color_') then
			replacer.group_placeholder['group:flower,' .. k] = 'flowers:' .. name
		end
	end
end

-- handle the standard dye color groups
if replacer.has_basic_dyes then
	for i, color in ipairs(dye.basecolors) do
		local def = minetest.registered_items['dye:' .. color]
		if def and def.groups then
			for k, v in pairs(def.groups) do
				if 'dye' ~= k then
					replacer.group_placeholder['group:dye,' .. k] = 'dye:' .. color
				end
			end
			replacer.group_placeholder['group:flower,color_' .. color] = 'dye:' .. color
		end
	end
end

-- fix dandelion
replacer.image_replacements['flowers:dandelion'] = 'flowers:dandelion_white'
-- fix pink
replacer.group_placeholder['group:dye,unicolor_light_red'] = 'dye:pink'

