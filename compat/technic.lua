-- skip if technic isn't loaded at all
if not replacer.has_technic_mod then return end

-- adds exceptions for technic cable plates
local lTiers = { 'lv', 'mv', 'hv' }
local lPlates = { '_digi_cable_plate_', '_cable_plate_' }
local sDropName, sBaseName
for _, sTier in ipairs(lTiers) do
	for _, sPlate in ipairs(lPlates) do
		sBaseName = 'technic:' .. sTier .. sPlate
		sDropName = sBaseName .. '1'
		for i = 2, 6 do
			replacer.register_exception(sBaseName .. tostring(i), sDropName)
		end
	end
end

