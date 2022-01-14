--[[
    Replacement tool for creative building (Mod for MineTest)
    Copyright (C) 2013 Sokomine

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

-- Version 3.2 (20220112)

-- Changelog:
-- 12.01.2022 * SwissalpS improved field mode: when replacing also check for same param2
--              improved crust mode: when placing also allow vacuum instead of only air
-- 02.12.2021 * SwissalpS added /replacer_mute command
-- 30.09.2021 * SwissalpS merged patch provided by S-S-X to prevent a rare but possible crash with
--              Unknown Items in hotbar
--            * Also cleaned up tool change messages to blabla.lua
-- 15.10.2020 * SwissalpS cleaned up inspector code and made inspector better readable on smaller screens
--            * SwissalpS added backward compatibility for non technic servers, restored
--              creative/give behaviour and fixed the 'too many nodes detected' issue
--            * S-S-X and some players from pandorabox.io requested and inspired ideas to
--              implement which SwissalpS tried to satisfy.
--            * SwissalpS added method to change mode via formspec
--            * BuckarooBanzay added server-setting max_nodes, moved crafts and replacer to
--              separate files, added .luacheckrc and cleaned up inspection tool, fixing
--              some issues on the way and updated readme to look nice
--            * coil0 made modes available as technic tool and added limits
--            * OgelGames fixed digging to be simulated properly
--            * SwissalpS merged Sokomine's and HybridDog's versions
--            * HybridDog added modes for creative mode
--            * coil0 fixed issue by using buildable_to
-- 09.12.2017 * Got rid of outdated minetest.env
--            * Fixed error in protection function.
--            * Fixed minor bugs.
--            * Added blacklist
-- 02.10.2014 * Some more improvements for inspect-tool. Added craft-guide.
-- 01.10.2014 * Added inspect-tool.
-- 12.01.2013 * If digging the node was unsuccessful, then the replacement will now fail
--				(instead of destroying the old node with its metadata; i.e. chests with content)
-- 20.11.2013 * if the server version is new enough, minetest.is_protected is used
--				in order to check if the replacement is allowed
-- 24.04.2013 * param1 and param2 are now stored
--			* hold sneak + right click to store new pattern
--			* right click: place one of the itmes
--			* receipe changed
--			* inventory image added

local path = minetest.get_modpath("replacer")

replacer = {}

replacer.version = 20220112

-- limit by node, use replacer.register_limit(sName, iMax)
replacer.limit_list = {}

-- some nodes don't rotate using param2. They can be added
-- using replacer.register_exception(node_name, inv_node_name[, callback_function])
-- where: node_name is the itemstring of node when placed in world
--        inv_node_name the itemstring of item in inventory to consume
--        callback_function is optional and will be called after node is placed.
--          It must return true on success and false, error_message on fail.
--          In order to register only a callback, pass two identical itemstrings.
--          Generally the callback is not needed as on_place() is called on the placed node
--          callback signature is: (pos, old_node_def, new_node_def, player_ref)
replacer.exception_map = {}
replacer.exception_callbacks = {}

-- don't allow these at all
replacer.blacklist = {}

-- playing with tnt and creative building are usually contradictory
-- (except when doing large-scale landscaping in singleplayer)
replacer.blacklist["tnt:boom"] = true
replacer.blacklist["tnt:gunpowder"] = true
replacer.blacklist["tnt:gunpowder_burning"] = true
replacer.blacklist["tnt:tnt"] = true

-- prevent accidental replacement of your protector
replacer.blacklist["protector:protect"] = true
replacer.blacklist["protector:protect2"] = true

-- charge limits
replacer.max_charge = 30000
replacer.charge_per_node = 15
-- node count limit
replacer.max_nodes = tonumber(minetest.settings:get("replacer.max_nodes") or 3168)
-- Time limit when placing the nodes, in seconds
replacer.max_time = tonumber(minetest.settings:get("replacer.max_time") or 1.0)

-- select which recipes to hide (not all combinations make sense)
replacer.hide_recipe_basic =
	minetest.settings:get_bool('replacer.hide_recipe_basic') or false
replacer.hide_recipe_technic_upgrade =
	minetest.settings:get_bool('replacer.hide_recipe_technic_upgrade') or false
replacer.hide_recipe_technic_direct =
	minetest.settings:get_bool('replacer.hide_recipe_technic_direct')
if nil == replacer.hide_recipe_technic_direct then
	replacer.hide_recipe_technic_direct = true
end

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

-- utilities
dofile(path .. '/utils.lua')
-- unifiedddyes support functions
dofile(path .. '/unifieddyes.lua')
-- adds a tool for inspecting nodes and entities
dofile(path .. '/inspect.lua')
dofile(path .. '/replacer_blabla.lua')
dofile(path .. '/replacer_patterns.lua')
dofile(path .. '/replacer.lua')
dofile(path .. '/crafts.lua')
dofile(path .. '/chat_commands.lua')
-- add cable plate exceptions
if replacer.has_technic_mod then
	dofile(path .. '/compat_technic.lua')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
print('[replacer] loaded')

