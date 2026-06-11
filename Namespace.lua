-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
DolgubonSetCrafter = DolgubonSetCrafter or {}
local originalGameCoreUI = IsGameCoreUI
local IsGameCoreUI = originalGameCoreUI
if GetDisplayName() == "@Dolgubon" then
	local originalGameCoreUI = IsGameCoreUI
	IsGameCoreUI = function() if IsConsoleUI() then return true else return originalGameCoreUI() end end
end
DolgubonSetCrafter.IsGameCoreUI = IsGameCoreUI
DolgubonSetCrafter.fontSwapper = function(control)
	if DolgubonSetCrafter.IsGameCoreUI() and control and control.SetFont then
		control:SetFont("ZoFontGamepad27")
	end
end
InformationTooltip:SetFont("ZoFontGamepad27")
-- sdoijsdfoijfsdajoi = ZO_Tooltip:Initialize(ItemTooltip, ZO_TOOLTIP_STYLES, "tooltip")
-- ItemTooltip:SetFont("ZoFontGamepad27")


			--[[ InitializeTooltip(ItemTooltip, GuiRoot, RIGHT, 0, -40)
					ItemTooltip:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
					InitializeTooltip(PopupTooltip, GuiRoot, RIGHT, 0, -40)
					PopupTooltip:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h") ]]
					-- sdoijsdfoijfsdajoi:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
