if not minetest.translate then
	function minetest.translate(textdomain, str, ...)
		local arg = { n = select('#', ...), ... }
		return str:gsub('@(.)', function(matched)
			local c = string.byte(matched)
			if string.byte('1') <= c and c <= string.byte('9') then
				return arg[c - string.byte('0')]
			else
				return matched
			end
		end)
	end

	function core.get_translator(textdomain)
		return function(str, ...) return core.translate(textdomain or '', str, ...) end
	end
end -- backward compatibility
local S = minetest.get_translator('replacer')

replacer.blabla = {}
replacer.blabla.inspect = {}
local rb = replacer.blabla
local rbi = replacer.blabla.inspect

rb.log_messages = '[replacer] %s: %s'
rb.choose_history = S('History')
rb.choose_mode = S('Choose mode')
rb.mode_minor1 = S('Both')
rb.mode_minor2 = S('Node')
rb.mode_minor3 = S('Rotation')
rb.mode_minor1_info = S('Replace node and apply orientation.')
rb.mode_minor2_info = S('Replace node without changing orientation.')
rb.mode_minor3_info = S('Apply orientation without changing node type.')
rb.mode_single = S('Single')
rb.mode_field = S('Field')
rb.mode_crust = S('Crust')
rb.mode_single_tooltip = S('Replace single node.')
rb.mode_field_tooltip = S('Left click: Replace field of nodes of a kind where a '
	.. 'translucent node is in front of it.@nRight click: Replace field of air '
	.. 'where no translucent node is behind the air.')
rb.mode_crust_tooltip = S('Left click: Replace nodes which touch another one of '
	.. 'its kind and a translucent node, e.g. air.@nRight click: Replace air nodes '
	.. 'which touch the crust.')
rb.protected_at = S('Protected at %s')
rb.deny_listed = S('Replacing nodes of type "%s" is not allowed on this server. '
	.. 'Replacement failed.')
rb.run_out = S('You have no further "%s". Replacement failed.')
rb.attempt_unknown_replace = S('Unknown node: "%s"')
rb.attempt_unknown_place = S('Unknown node to place: "%s"')
rb.can_not_dig = S('Could not dig "%s" properly.')
rb.can_not_place = S('Could not place "%s".')
rb.not_a_node = S('Error: "%s" is not a node.')
rb.wait_for_load = S('Target node not yet loaded. Please wait a moment for the '
	.. 'server to catch up.')
rb.nothing_to_replace = S('Nothing to replace.')
rb.need_more_charge = S('Not enough charge to use this mode.')
rb.too_many_nodes_detected = S('Aborted, too many nodes detected.')
rb.charge_required = S('Need %s charge to replace %s nodes.')
rb.count_replaced = S('%s nodes replaced.')
rb.mode_changed = S('Mode changed to %s: %s')
rb.none_selected = S('Error: No node selected.')
rb.not_in_creative = S('Item not in creative inventory: "%s".')
rb.not_in_inventory = S('Item not in your inventory: "%s".')
rb.set_to = S('Node replacement tool set to:\n%s.')
rb.description_basic = S('Node replacement tool')
rb.description_technic = S('Node replacement tool (technic)')
rb.log_limit_override = '[replacer] Setting already set node-limit for "%s" was %d.'
rb.log_limit_insert = '[replacer] Setting node-limit for "%s" to %d.'
rb.log_deny_list_insert = '[replacer] Added "%s" to deny list.'
rb.timed_out = S('Time-limit reached.')
rb.tool_short_description = '(%s %s%s) %s'
rb.tool_long_description = '%s\n%s\n%s'
rb.ccm_params = '[ %s | %s ]'
rb.ccm_description = S('Toggles verbosity.\nWhen on, '
	.. 'messages are posted to chat. When off, replacer is silent.')
rb.ccm_player_not_found = 'Player not found'
rb.ccm_player_meta_error = 'Player meta not existant'
rb.ccm_hint = S('Valid parameter is either "%s" or "%s"')
rb.on_yes = S('on')
rb.off_no = S('off')
rb.log_reg_exception_override = '[replacer] register_exception: '
	.. 'exception for "%s" already exists.'
rb.log_reg_exception = '[replacer] registered exception for "%s" to "%s"'
rb.log_reg_exception_callback = '[replacer] registered after on_place callback for "%s"'
rb.log_reg_alias_override = '[replacer] register_non_creative_alias: '
	.. ' alias for "%s" already exists.'
rb.log_reg_alias = '[replacer] registered alias for "%s" to "%s"'
rb.formspec_error = '[replacer] formspec error, user "%s" attempting to change history. Fields: %s'
rb.formspec_hacker = '[replacer] formspec forge? By user "%s" Fields: %s'

----------------- replacer:inspect -----------------
rbi.description = S('Inspection Tool\nUse to inspect target node or entity.\n'
		.. 'Place to inspect the adjacent node.')
rbi.broken_object = S('This is a broken object. We have no further information about it. It is located')
rbi.this_is_player = S('This is your fellow player "%s"')
rbi.this_is_entity = S('This is an entity "%s"')
rbi.dropped_ago = S(', dropped %s minutes ago')
rbi.owned_protected_locked = S('owned, protected and locked')
rbi.owned_protected = S('owned and protected')
rbi.owned_locked = S('owned and locked')
rbi.by_owner = S('by "%s"')
rbi.with_order_to = S('with order to %s')
rbi.has_x_types = S('Has %s different types of items,')
rbi.total_in_inv = S('total of %s items in inventory.')
rbi.this_is_object_type = S('This is an object "%s"')
rbi.this_is_object = S('This is an object')
rbi.at = S('at %s')
rbi.sorry_no_info = S('Sorry, this is an unkown something of type "%s". No information available.')
rbi.is_protected = S('WARNING: You can\'t dig this node. It is protected.')
rbi.you_can_dig = S('INFO: You can dig this node, but others can\'t.')
rbi.no_desc = S('~ no description provided ~')
rbi.no_node_desc = S('~ no node description provided ~')
rbi.no_item_desc = S('~ no item description provided ~')
rbi.located_at = S('Located at %s')
rbi.with_param2 = S('with param2 of %s')
rbi.and_light = S('and receiving %s light')
rbi.prev = S('prev')
rbi.next = S('next')
rbi.no_recipes = S('No recipes.')
rbi.drops_on_dig = S('Drops on dig:')
rbi.nothing = S('nothing')
rbi.may_drop_on_dig = S('May drop on dig:')
rbi.alternate_x_of_y = S('Alternate %s/%s')
rbi.can_be_fuel = S('This can be used as a fuel.')
rbi.unkown_recipe = S('Error: Unkown recipe.')

