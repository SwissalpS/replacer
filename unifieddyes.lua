replacer.unifieddyes = {}
local ud = replacer.unifieddyes

if not replacer.has_unifieddyes_mod then
	function ud.colourName(param2, nodeDef) return '' end
	function ud.addRecipe(nodeName, recipes) return recipes end
	return
end


-- for inspector formspec
function replacer.unifieddyes.addRecipe(param2, nodeName, recipes)
	if not param2 then
		return recipes
	end

	local nodeDef = minetest.registered_items[nodeName]
	if ud.isAirbrushed(nodeDef) then
		-- find the correct recipe and append it to bottom of list
		local first, last
		local needle = 'u0002' .. tostring(param2)
		for i, t in ipairs(recipes) do
			first, last = t.output:find(needle)
			if nil ~= first then
				recipes[#recipes + 1] = t
				return recipes
			end
		end
	end

	return recipes
end -- add_recipe


function replacer.unifieddyes.colourName(param2, nodeDef)
	param2 = tonumber(param2)
	if param2 and ud.isAirbrushed(nodeDef) then
		return unifieddyes.make_readable_color(
				unifieddyes.color_to_name(param2, nodeDef))
	else
		return ''
	end
end -- colour_name


function replacer.unifieddyes.dyeName(param2, nodeDef)
	param2 = tonumber(param2)
	if param2 and ud.isAirbrushed(nodeDef) then
		return 'dye:' .. unifieddyes.color_to_name(param2, nodeDef)
	else
		return ''
	end
end -- dye_name


function replacer.unifieddyes.isAirbrushCompatible(nodeDef)
	return nodeDef and nodeDef.palette
		and nodeDef.groups and nodeDef.groups.ud_param2_colorable
		and 0 < nodeDef.groups.ud_param2_colorable
end -- is_airbrush_compatible


function replacer.unifieddyes.isAirbrushed(nodeDef)
	if not replacer.unifieddyes.isAirbrushCompatible(nodeDef) then
		return false
	end
	if nil ~= nodeDef.name:find('_tinted$') then
		return true
	end
	return not nodeDef.airbrush_replacement_node
end -- is_airbrushed

