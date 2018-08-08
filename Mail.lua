-- Sends the current crating queue as a 
-- mail request to a user in a readable format.

-- Format is {  {subject1, body1 } , {subject2, body2 } } 
local mailOutputTexts = {}


local function MailNextLine(eventCode)
	local receiver = DolgubonSetCrafterWindowRightInputBox:GetText()
	local subject = mailOutputTexts[#mailOutputTexts][2]
	local body = mailOutputTexts[#mailOutputTexts][1]

	zo_callLater(function()d("Sending "..subject.." to "..receiver) SendMail(receiver, subject, body) end , 100)

	table.remove(mailOutputTexts)
	if #mailOutputTexts>0 then
		
	else
		EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_MAIL_SEND_SUCCESS)
		zo_callLater(CloseMailbox, 300)
	end
end

local continueNext = "(continued in next mail)"
local continuedFrom = "(Continued from previous mail)"
local reqStarter = "Your request will require:\n"
local reqSubject = "Material Requirements "

local function compileMatText()

	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end

	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)

	local text = reqStarter

	local numMails = 0

	local nextAddition = ""	

	for i = 1, #tempMatHolder do
		
		nextAddition = tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"].."\n"


		text =text.. tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"].."\n"
		if (#text + #nextAddition + #continueNext) > 690 then
			mailOutputTexts[#mailOutputTexts][2] = text..continueNext
			mailOutputTexts[#mailOutputTexts + 1] = {}
			mailOutputTexts[#mailOutputTexts][1] = reqSubject.. (#mailOutputTexts + 1)
			numMails = numMails + 1
			--{text.."(continued in next mail)", "Material Requirements ".. numMails}
			text = continuedFrom..reqStarter
		end
	end

end

local function beginMailing(destination)
	for i = 1, #mailOutputTexts do
		-- If a mail doesn't have a destination give it one. 
		-- Basically, only the new mails will get a destination
		if not mailOutputTexts[i][3] then
			mailOutputTexts[i][3] = destination
		end
	end
	
	RequestOpenMailbox() -- required
	EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name,EVENT_MAIL_SEND_SUCCESS, MailNextLine)
	MailNextLine()

end


function DolgubonSetCrafter.mailAllMats(destinationOverride)
	local destination = destinationOverride or DolgubonSetCrafterWindowRightInputBox:GetText()
	if #destination < 3 then 
		out("Invalid name")
		return 
	end
	if #DolgubonSetCrafter.materialList == 0 then 
		d("No items required, so no mail has been sent")
		return 
	end

	compileMatText() 
	
	beginMailing(destination)
end

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

local function compileRequestMail()


	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end

	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)

	local text = reqStarter

	local numMails = 0

	local nextAddition = ""	

	for i = 1, #tempMatHolder do
		
		nextAddition = tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"].."\n"


		text =text.. tostring(tempMatHolder[i]["Amount"]).." "..tempMatHolder[i]["Name"].."\n"
		if (#text + #nextAddition + #continueNext) > 690 then
			mailOutputTexts[#mailOutputTexts][2] = text..continueNext
			mailOutputTexts[#mailOutputTexts + 1] = {}
			mailOutputTexts[#mailOutputTexts][1] = reqSubject.. (#mailOutputTexts + 1)
			numMails = numMails + 1
			--{text.."(continued in next mail)", "Material Requirements ".. numMails}
			text = continuedFrom..reqStarter
		end
	end
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
	local mails = {}


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
			if #body + 1 + #item >700 then end
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
