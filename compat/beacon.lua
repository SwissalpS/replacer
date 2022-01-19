function replacer.is_beacon_beam_or_base(node_name)
    if 'string' ~= type(node_name) then return nil end
    if node_name:match('^beacon:(.*)beam$') then return true end
    if node_name:match('^beacon:(.*)base$') then return true end
    return false
end -- is_beacon_beam_or_base

