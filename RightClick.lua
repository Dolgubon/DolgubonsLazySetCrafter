



DolgubonSetCrafter = DolgubonSetCrafter or {}


function DolgubonSetCrafter.InventorySlot_ShowContextMenu(rowControl)
    local bag, slot = ZO_Inventory_GetBagAndIndex(rowControl)

    local link = GetItemLink(bag, slot) 

    if link then
        zo_callLater(function ()
            AddCustomMenuItem("Improve Item", function ()
                CHAT_SYSTEM:AddMessage(GetItemLink(bag, slot) .. " is located at bag #"..bag.." and slot #"..slot)

            end, MENU_ADD_OPTION_LABEL)
            ShowMenu(self)
        end, 50)
    end
end

function DolgubonSetCrafter.InitializeRightClick()
    ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function (rowControl) DolgubonSetCrafter.InventorySlot_ShowContextMenu(rowControl) end)
end












