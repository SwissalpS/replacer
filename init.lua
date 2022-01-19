--[[
	Replacement tool for creative building (Mod for MineTest)
	Copyright (C) 2013 Sokomine
	Copyright (C) 2019 coil0
	Copyright (C) 2019 HybridDog
	Copyright (C) 2019-2022 SwissalpS

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Version 3.7 (20220119)

-- Changelog: see CHANGELOG file

replacer = {}
replacer.version = 20220119

replacer.has_bakedclay = minetest.get_modpath('bakedclay')
replacer.has_basic_dyes = minetest.get_modpath('dye')
								and minetest.global_exists('dye')
								and dye.basecolors
replacer.has_circular_saw = minetest.get_modpath('moreblocks')
								and minetest.global_exists('moreblocks')
								and minetest.global_exists('circular_saw')
								and circular_saw.names
replacer.has_colormachine_mod = minetest.get_modpath('colormachine')
								and minetest.global_exists('colormachine')
replacer.has_technic_mod = minetest.get_modpath('technic')
								and minetest.global_exists('technic')
replacer.has_unifieddyes_mod = minetest.get_modpath('unifieddyes')
								and minetest.global_exists('unifieddyes')

local path = minetest.get_modpath('replacer') .. '/'
-- strings for translation
dofile(path .. 'replacer/blabla.lua')
-- utilities
dofile(path .. 'utils.lua')
-- beacon beam support
dofile(path .. 'compat/beacon.lua')
-- circular saw support
dofile(path .. 'compat/moreblocks.lua')
-- unifiedddyes support functions
dofile(path .. 'compat/unifieddyes.lua')
-- adds a tool for inspecting nodes and entities
dofile(path .. 'inspect.lua')
replacer.datastructures = dofile(path .. 'replacer/datastructures.lua')
dofile(path .. 'replacer/constrain.lua')
dofile(path .. 'replacer/formspecs.lua')
dofile(path .. 'replacer/history.lua')
dofile(path .. 'replacer/patterns.lua')
dofile(path .. 'replacer/replacer.lua')
dofile(path .. 'crafts.lua')
dofile(path .. 'chat_commands.lua')
-- add cable plate exceptions (uses replacer/constrain.lua)
dofile(path .. 'compat/technic.lua')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
print('[replacer] loaded')

