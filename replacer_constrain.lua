-- TODO: move all intervention functions in here, rename blacklist
--
local r = replacer
local rb = replacer.blabla

-- function that other mods, especially custom server mods,
-- can override. e.g. restrict usage of replacer in certain
-- areas, privs, throttling etc.
-- This is called before replacing the node/air and expects
-- a boolean return and in the case of fail, an optional message
-- that will be sent to player
function replacer.permit_replace(pos, old_node_def, new_node_def,
        player_ref, player_name, player_inv, creative_or_give)
    -- TODO: move protection check here
    -- TODO: check inhibit_list
    return true
end -- permit_replace

