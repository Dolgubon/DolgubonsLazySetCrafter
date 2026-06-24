-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.version = 5
DolgubonSetCrafter.name = "DolgubonsLazySetCrafter"
DolgubonSetCrafter.useFakeGameCore = true


local originalGameCoreUI = IsGameCoreUI
local IsGameCoreUI = originalGameCoreUI
if GetDisplayName() == "@Dolgubon" and DolgubonSetCrafter.useFakeGameCore then
	local originalGameCoreUI = IsGameCoreUI
	IsGameCoreUI = function() if IsConsoleUI() then return true else return originalGameCoreUI() end end
end
DolgubonSetCrafter.IsGameCoreUI = IsGameCoreUI
DolgubonSetCrafter.fontSwapper = function(control)
	if DolgubonSetCrafter.IsGameCoreUI() and control and control.SetFont then
		control:SetFont("ZoFontGamepad22")
	end
end
if IsGameCoreUI() then
	InformationTooltip:SetFont("ZoFontGamepad22")
end
-- local o = ZO_TooltipStyledObject.GetFontString
-- ZO_TooltipStyledObject.GetFontString= function(self,...) d(...) o(self, ...) end



local function ScreenResizeHandler(control)
    local maxHeight = GuiRoot:GetHeight() - (ZO_GAMEPAD_PANEL_FLOATING_HEIGHT_DISCOUNT * 2)
    control:SetDimensionConstraints(0, 0, 0, maxHeight)
    control:SetTransformScale(0.75)
    -- control:GetNamedChild("Bg"):SetCenterTexture("/esoui/art/tooltips/ui-tooltipcenter.dds")
    -- control:GetNamedChild("Bg"):SetEdgeTexture("/esoui/art/tooltips/ui-border.dds",2,2,2,2)
    DSC_gamepadTooltips:GetNamedChild("Bg"):SetCenterColor(1,1,1,1)
    DSC_gamepadTooltips:GetNamedChild("Bg"):SetCenterTexture("/esoui/art/tooltips/ui-tooltipcenter.dds",1,1)
    DSC_gamepadTooltips:GetNamedChild("Bg"):SetHidden(false)
	DSC_gamepadTooltips:GetNamedChild("Bg"):SetEdgeTexture("/esoui/art/tooltips/ui-border.dds",2,2,2,2)
end
local DEFAULT_TOOLTIP_STYLES = nil
--ZO_ResizingFloatingScrollTooltip_Gamepad_OnInitialized(testtwoltip, DEFAULT_TOOLTIP_STYLES, ScreenResizeHandler, LEFT)

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name.."_GPTooltip_init",EVENT_PLAYER_ACTIVATED, function()ScreenResizeHandler(DSC_gamepadTooltips)
ZO_Scroll_Gamepad_SetScrollIndicatorSide(DSC_gamepadTooltips.scrollTooltip.scrollIndicator, DSC_gamepadTooltips, RIGHT, 0, nil, true) end)

-- when calling it
function DolgubonSetCrafter.showLinkTooltip(control, anchorpoint, x, y, link)
	DolgubonSetCrafter.clearTooltip()
	if DolgubonSetCrafter.IsGameCoreUI() then
		InitializeTooltip(DSC_gamepadTooltips, control, anchorpoint,x+145, y )
		DSC_gamepadTooltips.tip:LayoutItem(link)
		DSC_gamepadTooltips.tip.icon:SetTexture(GetItemLinkIcon(link))
		DSC_gamepadTooltips:GetNamedChild("Bg"):SetHidden(false)
	else
		InitializeTooltip(ItemTooltip, control , anchorpoint, x, y)
		ItemTooltip:SetLink(link)
	end
end

-- to hide it
function DolgubonSetCrafter.clearTooltip()
	if DolgubonSetCrafter.IsGameCoreUI() then
		ClearTooltipImmediately(DSC_gamepadTooltips)
		ClearTooltip(InformationTooltip)
	else
		ClearTooltip(ItemTooltip)
		ClearTooltip(InformationTooltip)
	end
end

--esoui/art/miscellaneous/gamepad/gp_tooltip_center_semitrans_16.dds
--esoui/art/miscellaneous/gamepad/gp_tooltip_edge_semitrans_16.dds
--/esoui/art/tooltips/ui-tooltipcenter.dds
--/esoui/art/tooltips/ui-border.dds

--[[
/showtooltipfor |H1:item:168649:311:50:0:0:0:0:0:0:0:0:0:0:0:0:145:0:0:0:10000:0|h|h
]]
-- sdoijsdfoijfsdajoi = ZO_Tooltip:Initialize(ItemTooltip, ZO_TOOLTIP_STYLES, "tooltip")
-- ItemTooltip:SetFont("ZoFontGamepad27")


			--[[ InitializeTooltip(ItemTooltip, GuiRoot, RIGHT, 0, -40)
					ItemTooltip:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
					InitializeTooltip(PopupTooltip, GuiRoot, RIGHT, 0, -40)
					PopupTooltip:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h") ]]
					-- sdoijsdfoijfsdajoi:SetLink("|H1:item:145469:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
