if not minetest.get_modpath('ehlphabet') then return end

-- for inspection tool
replacer.group_placeholder['group:ehlphabet_block'] = 'ehlphabet:208164'

local exceptions = { '231140', '229140', '228184',
	'230157', '229141', '232165', '231171' }
local skip = {}
for _, n in ipairs(exceptions) do skip[n] = true end

local function ehlphabet_number_sticker(item_name)
	if not item_name or not 'string' == type(item_name) then return end

	return item_name:match('^ehlphabet:([0-9]+)'),
		item_name:find('_sticker$') and true
end

local function add_recipe(item_name, _, recipes)
	local number, sticker = ehlphabet_number_sticker(item_name)
	if not number or skip[number] then return end

	local input = sticker and 'default:paper' or 'ehlphabet:block'
	recipes[#recipes + 1] = {
		method = 'printing',
		type = 'ehlphabet',
		items = { input },
		output = item_name,
	}
end -- add_recipe

replacer.register_craft_method('ehlphabet', 'ehlphabet:machine', add_recipe)


-- for replacer
replacer.register_set_enabler(function(node)
	return node and node.name and ehlphabet_number_sticker(node.name)
end)

