-- Sends the current crating queue as a 
-- mail request to a user in a readable format.


-- Convert the current request to a readable format
local function convertRequest(curReq)
	local pattern = curReq["Pattern"] and curReq["Pattern"][2] or "N/A"
	local level = curReq["Level"] and curReq["Level"][2] or "N/A"
	local style = curReq["Style"] and curReq["Style"][2] or "N/A"
	local trait = curReq["Trait"] and curReq["Trait"][2] or "N/A"
	local quality = curReq["Quality"] and curReq["Quality"][2] or "N/A"

	return pattern.." | "..level.." | "..style.." | "..trait.." | "..quality
end

-- Reads mail. If it contain the right format, give a button to import it.
local function importRequest(request)
	-- Parse each section and add the items.
end


local function mailNext(destination)

end

function DolgubonSetCrafter.MailAsRequest(destinationOverride)

	local destination = destinationOverride or DolgubonSetCrafterWindowRightInputBox:GetText()
	-- Variables
	local DSC = DolgubonSetCrafter
	local mailQueue = DSC.savedvars.queue

	-- Constants
	local SUBJECT = 'Crafting Request'

	local sets = {} -- A list of all items under the current set type.
	local setTypes = {} -- Used to keep the sets list in a certain order.

	for i, request in ipairs(mailQueue) do
		local setName = request["Set"][2]
		if sets[setName] == nil then
			sets[setName] = {}
			table.insert(setTypes, setName) -- Save this index of this set's name
		end
		table.insert(sets[setName], DSC.ConvertRequest(request)) -- Store the readable crafting information
	end

	local bodyText = "" -- Holds the message for the mail

	for i, setName in ipairs(setTypes) do
		local setHeader = "-- "..setName.." --"
		
		-- Each set's header being appended
		if bodyText == "" then
			bodyText = setHeader
		else
			bodyText = bodyText.."\n\n"..setHeader
		end
		
		-- Each item under a specific set name
		for _, item in pairs(sets[setName]) do
			bodyText = bodyText.."\n"..item
		end
	end
	RequestOpenMailbox() 
	SendMail(destination, SUBJECT, bodyText)
	zo_callLater(CloseMailbox, 300)
	-- Prep the mailbox
	-- SCENE_MANAGER:Show('mailSend')
	-- zo_callLater(function()
	-- ZO_MailSendToField:SetText(destination)
	-- ZO_MailSendSubjectField:SetText(SUBJECT)
	-- ZO_MailSendBodyField:SetText(bodyText)
	-- ZO_MailSendBodyField:TakeFocus() end, 200)
end
