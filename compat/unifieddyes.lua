replacer.unifieddyes = {}
local ud = replacer.unifieddyes

if not replacer.has_unifieddyes_mod then
	-- replacer uses this
	function ud.colour_name(param2, node_def) return '' end
	return
end

local make_readable_color = unifieddyes.make_readable_color
local colour_to_name = unifieddyes.color_to_name

-- for inspection tool formspec
local function add_recipe(node_name, param2, recipes)
	if not param2 then return end

	local node_def = minetest.registered_items[node_name]
	if ud.is_airbrushed(node_def) then
		-- find the correct recipe and append it to bottom of list
		local first, last
		local needle = 'u0002' .. tostring(param2)
		for i, t in ipairs(recipes) do
			first, last = t.output:find(needle)
			if nil ~= first then
				recipes[#recipes + 1] = t
				return
			end
		end
	end
end -- add_recipe

replacer.register_craft_method('unifieddyes:airbrush', 'unifieddyes:airbrush', add_recipe)


function replacer.unifieddyes.colour_name(param2, node_def)
	param2 = tonumber(param2)
	if param2 and ud.is_airbrushed(node_def) then
		return make_readable_color(
				colour_to_name(param2, node_def))
	else
		return ''
	end
end -- colour_name


function replacer.unifieddyes.dye_name(param2, node_def)
	param2 = tonumber(param2)
	if param2 and ud.is_airbrushed(node_def) then
		return 'dye:' .. colour_to_name(param2, node_def)
	else
		return ''
	end
end -- dye_name


function replacer.unifieddyes.is_airbrush_compatible(node_def)
	return node_def and node_def.palette
		and node_def.groups and node_def.groups.ud_param2_colorable
		and 0 < node_def.groups.ud_param2_colorable
end -- is_airbrush_compatible


function replacer.unifieddyes.is_airbrushed(node_def)
	if not ud.is_airbrush_compatible(node_def) then
		return false
	end
	if nil ~= node_def.name:find('_tinted$') then
		return true
	end
	--[[ tried to fix scifi_nodes white2 ... _colored
	didn't work this way even though airbrush was used to paint them
	if nil ~= node_def.name:find('_colored$') then
		return true
	end
	--]]
	return not node_def.airbrush_replacement_node
end -- is_airbrushed

