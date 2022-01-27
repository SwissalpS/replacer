if not replacer.has_bakedclay then return end

-- add bakedclay items for inspection tool
replacer.group_placeholder['group:bakedclay'] = 'bakedclay:natural'
-- unfortunately bakedclay does not expose anything, so we have to manually
-- maintain the list
local rgp = replacer.group_placeholder
rgp['group:flower,color_cyan'] = 'bakedclay:delphinium'
rgp['group:flower,color_pink'] = 'bakedclay:lazarus'
rgp['group:flower,color_dark_green'] = 'bakedclay:mannagrass'
rgp['group:flower,color_magenta'] = 'bakedclay:thistle'

