-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--

-----------------------------------
--Addon Namespace creation
DolgubonSetCrafter = DolgubonSetCrafter or {}

------------------------------------
-- TRAIT DECLARATION
DolgubonSetCrafter.weaponTraits = {}
for i = 0, 8 do --create the weapon trait table
	--Takes the strings starting at SI_ITEMTRAITTYPE0 == no trait, # 897 to SI_ITEMTRAITTYPE8 === Divines, #905
	--Then saves the proper trait index used for crafting to it. The offset of 1 is due to ZOS; the offset of STURDY is so they start at 12
	DolgubonSetCrafter.weaponTraits[i + 1] = {[1]  = i + 1, [2] = GetString(SI_ITEMTRAITTYPE0 + i),}
end

DolgubonSetCrafter.armourTraits = {}
DolgubonSetCrafter.armourTraits[#DolgubonSetCrafter.armourTraits + 1] = {[1] = ITEM_TRAIT_TYPE_NONE + 1, [2] = GetString(SI_ITEMTRAITTYPE0)} -- No Trait to armour traits
for i = 0, 7 do --create the armour trait table
	--Takes the strings starting at SI_ITEMTRAITTYPE11 == Sturdy, # 908 to SI_ITEMTRAITTYPE18 === Divines, #915
	--Then saves the proper trait index used for crafting to it. The offset of 1 is due to ZOS; the offset of STURDY is so they start at 12
	DolgubonSetCrafter.armourTraits[#DolgubonSetCrafter.armourTraits + 1] = {[1] = i + 1 + ITEM_TRAIT_TYPE_ARMOR_STURDY, [2] = GetString(SI_ITEMTRAITTYPE11 + i)}
end
--Add a few missing traits to the tables - i.e., nirnhoned, and no trait

DolgubonSetCrafter.armourTraits[#DolgubonSetCrafter.armourTraits + 1] = {[1] = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED + 1, [2] = GetString(SI_ITEMTRAITTYPE26)} -- Nirnhoned
DolgubonSetCrafter.weaponTraits[#DolgubonSetCrafter.weaponTraits + 1] = {[1] = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED + 1, [2] = GetString(SI_ITEMTRAITTYPE25)}  -- Nirnhoned

DolgubonSetCrafter.jewelryTraits = 
{
	{ITEM_TRAIT_TYPE_NONE + 1 , GetString( SI_ITEMTRAITTYPE0 )},
	{ITEM_TRAIT_TYPE_JEWELRY_HEALTHY + 1 , GetString(SI_ITEMTRAITTYPE21)},
	{ITEM_TRAIT_TYPE_JEWELRY_ARCANE + 1 , GetString(SI_ITEMTRAITTYPE22)},
	{ITEM_TRAIT_TYPE_JEWELRY_ROBUST + 1 ,  GetString(SI_ITEMTRAITTYPE23)},
	{ITEM_TRAIT_TYPE_JEWELRY_SWIFT + 1 , GetString(SI_ITEMTRAITTYPE28)},
	{ITEM_TRAIT_TYPE_JEWELRY_HARMONY + 1 , GetString(SI_ITEMTRAITTYPE29)},
	{ITEM_TRAIT_TYPE_JEWELRY_TRIUNE + 1 , GetString(SI_ITEMTRAITTYPE30)},
	{ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY + 1 , GetString(SI_ITEMTRAITTYPE31)},
	{ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE + 1 , GetString(SI_ITEMTRAITTYPE32)},
	{ITEM_TRAIT_TYPE_JEWELRY_INFUSED + 1 , GetString(SI_ITEMTRAITTYPE33)},	
}


--------------------------------------
--- STYLES
	




local styles = {}
for i = 1, GetNumValidItemStyles() do
	local styleItemIndex = GetValidItemStyleId(i)
	local styleName = GetItemStyleName(styleItemIndex)
	local styleItem = GetSmithingStyleItemInfo(styleItemIndex)
	if styleItemIndex ~= 36 then
		table.insert(styles,{styleItemIndex,styleName, styleItem, GetItemStyleMaterialLink(styleItemIndex, 0 )})
	end

end
table.sort(styles, function (a,b) return a[2]<b[2] end)--GetItemStyleMaterialLink(number itemStyleId, number LinkStyle linkStyle)
-- Add Colours based on knowledge 
for i = 1, #styles do
	local colour = "|cFFFFFF"
	if not IsSmithingStyleKnown(styles[i][1]) then colour = "|c808080"  end
	styles[i][2] = colour..styles[i][2].."|r"

end
DolgubonSetCrafter.styleNames = styles

------------------------------------
-------- QUALITY

--Setup quality table
DolgubonSetCrafter.quality = {}

for i = 1, 5 do
	local qualityColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, i))
    
    DolgubonSetCrafter.quality[i] = {[1] = i, [2] = qualityColor:Colorize(GetString(SI_ITEMQUALITY0 + i)),  [3] = GetString(SI_ITEMQUALITY0 + i)} 
	
end

--------------------------------------
--------- CRAFTING REQUIREMENTS

-- This is a bit more esoteric, in how it's set up. Basically, crafting requirements mainly follow a few patterns
-- About 75% of them follow the pattern. Greaves are odd just because, but the other 8 follow a second pattern.
-- The second pattern only changes at the highest levels. The following reduces the pattern.

local requirementJumps = { -- At these material indexes, the material required changes, and the amount required jumps down
	[1] = 1,
	[2] = 8,
	[3] = 13,
	[4] = 18,
	[5] = 23,
	[6] = 26,
	[7] = 29,
	[8] = 32,
	[9] = 34,
	[10] = 40,
}

local additionalRequirements = -- Seperated by station. The additional amount of mats added to the base amount.
{
	[CRAFTING_TYPE_BLACKSMITHING] = 
	{ 2, 2, 2, 4, 4, 4, 1, 6, 4, 4, 4, 5, 4, 4,
	},
	[CRAFTING_TYPE_WOODWORKING] = 
	{ 2, 5, 2, 2, 2, 2,
	},
	[CRAFTING_TYPE_CLOTHIER] = 
	{ 6, 6, 4, 4, 4, 5, 4, 4, 6, 4, 4, 4, 5, 4, 4,

	},
}

local currentStep = 1
local baseRequirements = {}
for i = 1, 41 do
	if requirementJumps[currentStep] == i then
		currentStep = currentStep + 1
		baseRequirements[i] = currentStep
	else
		baseRequirements[i] = baseRequirements[i-1] + 1
	end
end

DolgubonSetCrafter.setIndexes = {}
local LibLazyCrafting =  LibLazyCrafting
local t = LibLazyCrafting.GetSetIndexes()
for i, value in pairs(t) do
	if i ~=LibLazyCrafting.INDEX_NO_SET then -- don't want to sort the no set table in
		DolgubonSetCrafter.setIndexes[#DolgubonSetCrafter.setIndexes + 1] = {}
		DolgubonSetCrafter.setIndexes[#DolgubonSetCrafter.setIndexes][2] = t[i][1]
		DolgubonSetCrafter.setIndexes[#DolgubonSetCrafter.setIndexes][1] = i
	end
end

table.sort(DolgubonSetCrafter.setIndexes, function(a,b) return a[2]<b[2] end)
table.insert(DolgubonSetCrafter.setIndexes,1, {[1] = LibLazyCrafting.INDEX_NO_SET, [2] = DolgubonSetCrafter.localizedStrings.UIStrings.noSet})

DolgubonSetCrafter.weaponEnchantments = {{0, "No Enchantment"}}
DolgubonSetCrafter.jewelryEnchantments = {{0, "No Enchantment"}}
DolgubonSetCrafter.armourEnchantments  = {{0, "No Enchantment"}}

local function addGlyphInfo(enchantId, glyphResultId, enchantName, typeOfEnchant)
	local tableToAddTo 
	if ITEMTYPE_GLYPH_WEAPON == typeOfEnchant then
		tableToAddTo = DolgubonSetCrafter.weaponEnchantments
	elseif ITEMTYPE_GLYPH_JEWELRY == typeOfEnchant then
		tableToAddTo = DolgubonSetCrafter.jewelryEnchantments
	elseif ITEMTYPE_GLYPH_ARMOR == typeOfEnchant then
		tableToAddTo = DolgubonSetCrafter.armourEnchantments 
	end
	table.insert(tableToAddTo, {enchantId, enchantName, glyphResultId})
end


local glyphInfo = LibLazyCrafting.getGlyphInfo()
for _,v in pairs(glyphInfo) do
	addGlyphInfo(v[1], v[3], v[5], v[7])
	addGlyphInfo(v[2], v[4], v[6], v[8])
end






-- }|H1:item:45839:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
-- DolgubonSetCrafter.armourEnchants = {GetString(SI_ENCHANTMENTSEARCHCATEGORYTYPE11), GetString(SI_ENCHANTMENTSEARCHCATEGORYTYPE13), GetString(SI_ENCHANTMENTSEARCHCATEGORYTYPE17)}
-- "Befouled", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE1
-- "Shock", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE3
-- "Crushing", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE4
-- "Flame", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE6
-- "Frost", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE9
-- "Hardening", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE10
-- "Poison", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE16
-- "Weakening", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE19
-- "Absorb Health", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE20
-- "Absorb Stamina", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE22
-- "Absorb Magicka", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE23
-- "Decrease Health", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE24
-- "Prismatic Onslaught", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE35

-- |H1:item:54484:310:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h


-- "Rage", -- SI_ENCHANTMENTSEARCHCATEGORYTYPE2













--[[ TODO: 
1 make the toggle button moveable - Check
2. make a control container for the left side of stuff - Check
3. Add craft now button - Check
4. Add crown mimic stone toggle - Check
5. Reticle colouring - Check
6. Add new amount of item to the valuable reward text - Check
7. Resizing - Check	
8. Save Window Size - Check
9. Add pricing - Check
10. Look into requirements weirdness - Fixed I think?
11. Send Queue button (even if hidden)
--WTS |H1:item:139405:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h(Swift) |H1:item:139407:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h(Bloodthirsty) , WTB |H1:item:139411:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h PST
 --]]
