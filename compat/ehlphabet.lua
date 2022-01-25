if not minetest.get_modpath('ehlphabet') then return end

-- for inspection tool
replacer.group_placeholder['group:ehlphabet_block'] = 'ehlphabet:208164'

local exceptions = { '231140', '229140', '228184',
	'230157', '229141', '232165', '231171' }
local skip = {}
for _, n in ipairs(exceptions) do skip[n] = true end

local function add_recipe(item_name, _, recipes)
	if not item_name or not 'string' == type(item_name) then return end

	local number = item_name:match('^ehlphabet:([0-9]+)')
	if not number or skip[number] then return end

	local sticker = item_name:find('_sticker$') and true
	local input = sticker and 'default:paper' or 'ehlphabet:block'

	recipes[#recipes + 1] = {
		method = 'printing',
		type = 'ehlphabet',
		items = { input },
		output = item_name,
	}
end -- add_recipe

replacer.register_craft_method('ehlphabet', 'ehlphabet:machine', add_recipe)

