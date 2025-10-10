--[[
	Replacement tool for creative building (Mod for Luanti aka MineTest)
	Copyright (C) 2013 Sokomine
	Copyright (C) 2019 coil0
	Copyright (C) 2019 HybridDog
	Copyright (C) 2019-2025 SwissalpS

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

-- Version 4.94 (20251010)

-- Changelog: see CHANGELOG file

replacer = {}
replacer.version = 20251010

replacer.has_bakedclay = core.get_modpath('bakedclay')
replacer.has_basic_dyes = core.get_modpath('dye')
								and core.global_exists('dye')
								and dye.basecolors and true or false
replacer.has_circular_saw = core.get_modpath('moreblocks')
								and core.global_exists('moreblocks')
								and core.global_exists('circular_saw')
								and circular_saw.names and true or false
replacer.has_colormachine_mod = core.get_modpath('colormachine')
								and core.global_exists('colormachine')
replacer.has_technic_mod = core.get_modpath('technic')
								and core.global_exists('technic')
replacer.has_unifieddyes_mod = core.get_modpath('unifieddyes')
								and core.global_exists('unifieddyes')
replacer.has_unified_inventory_mod = core.get_modpath('unified_inventory')
								and true or false
replacer.has_xcompat_mod = core.get_modpath('xcompat')
								and core.global_exists('xcompat')

-- image mapping tables for replacer:inspect
replacer.group_placeholder = {}
replacer.image_replacements = {}

local path = core.get_modpath('replacer') .. '/'
-- for developers
dofile(path .. 'test.lua')
-- strings for translation (inspect & replacer)
dofile(path .. 'blabla.lua')
-- utilities (inspect & replacer)
-- material and sound compatibility for various games
dofile(path .. 'xcompat.lua')
dofile(path .. 'utils.lua')
-- more settings and functions
dofile(path .. 'replacer/constrain.lua')
-- register set enable functions
dofile(path .. 'replacer/enable.lua')
-- adds a tool for inspecting nodes and entities
dofile(path .. 'inspect.lua')

-- loop through compat dir
local path_compat = path .. 'compat/'
for _, file in ipairs(core.get_dir_list(path_compat, false)) do
	if file:find('^[^._].+[.]lua$') then
		dofile(path_compat .. file)
	end
end

replacer.datastructures = dofile(path .. 'replacer/datastructures.lua')
dofile(path .. 'replacer/formspecs.lua')
dofile(path .. 'replacer/history.lua')
dofile(path .. 'replacer/patterns.lua')
dofile(path .. 'replacer/replacer.lua')
dofile(path .. 'crafts.lua')
dofile(path .. 'chat_commands.lua')
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
print('[replacer] loaded')

