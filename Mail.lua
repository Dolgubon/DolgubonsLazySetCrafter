-- Sends the current crating queue as a 
-- mail request to a user in a readable format.

-- Format is {  {subject1, body1 } , {subject2, body2 } } 
local mailOutputTexts = {}

local out = DolgubonSetCrafter.out

local function MailNextLine(eventCode)
	local receiver = DolgubonSetCrafterWindowRightInputBox:GetText()
	local subject = mailOutputTexts[#mailOutputTexts][1]
	local body = mailOutputTexts[#mailOutputTexts][2]
	zo_callLater(function()d("Sending "..subject.." to "..receiver) SendMail(receiver, subject, body) end , 100)

	table.remove(mailOutputTexts)
	if #mailOutputTexts==0 then
		EVENT_MANAGER:UnregisterForEvent(DolgubonSetCrafter.name,EVENT_MAIL_SEND_SUCCESS)
		zo_callLater(CloseMailbox, 300)
		d("Mailing complete")
	end
end

local continueNext = "(continued in next mail)"
local continuedFrom = "(Continued from previous mail)"


local function compileMailText(subject, mailStarter, data, dataTransform)
	mailOutputTexts = {}
	local text
	if type(mailStarter ) == "function" then
		-- text = mailStarter()
		text = ""..mailStarter(data[1])
	else
		text = ""..mailStarter
	end
	local nextAddition = ""	
	for i = 1, #data do
		
		nextAddition = dataTransform(data[i]).."\n"
		text =text.. dataTransform(data[i]).."\n"
		if (#text + #nextAddition + #continueNext) > 690 and i<#data then
			if #mailOutputTexts == 0 then
				mailOutputTexts[1] = {subject ,text..continueNext}
			else
				mailOutputTexts[#mailOutputTexts][2] = text
			end
			mailOutputTexts[#mailOutputTexts + 1] = {}
			mailOutputTexts[#mailOutputTexts][1] = subject.." #".. (#mailOutputTexts )
			if type(mailStarter ) == "function" then
				text = continuedFrom..mailStarter(data[i+1])
			else
				text = continuedFrom..mailStarter
			end
			--{text.."(continued in next mail)", "Material Requirements ".. numMails}
		else
		end
	end
	if #mailOutputTexts == 0 then
		mailOutputTexts[1] = {subject ,text}
	end
	mailOutputTexts[#mailOutputTexts][2] = text
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

local reqStarter = "Your request will require:\n"
local reqSubject = "Material Requirements"

function DolgubonSetCrafter.mailAllMats(destinationOverride)
	local destination = destinationOverride or DolgubonSetCrafterWindowRightInputBox:GetText()
	if #destination < 4 then 
		out("Invalid name")
		return 
	end
	if next(DolgubonSetCrafter.materialList) == nil then 
		d("Dolgubon's Lazy Set Crafter: No items are in the queue! No mails sent")
		return 
	end
	DolgubonSetCrafter.updateList()
	local tempMatHolder = {}
	for k, v in pairs(DolgubonSetCrafter.materialList) do
		tempMatHolder[#tempMatHolder + 1] = v
	end

	table.sort(tempMatHolder, function(a, b) return a["Amount"]>b["Amount"]end)


	compileMailText(reqSubject, reqStarter, tempMatHolder, function(data) return tostring(data["Amount"]).." "..data["Name"] end)
	
	beginMailing(destination)
end

-- Convert the current request to a readable format
function DolgubonSetCrafter.convertRequestToText(curReq)
	local pattern = curReq["Pattern"] and curReq["Pattern"][2] or "N/A"

	local level = curReq["Level"] and curReq["Level"][2] or "N/A"
	if not curReq.CraftRequestTable[2] then
		level = "lvl "..level
	end
	local style = curReq["Style"] and curReq["Style"][2] or ""
	local trait = curReq["Trait"] and curReq["Trait"][2] or "N/A"
	local quality = curReq["Quality"] and curReq["Quality"][2] or "N/A"
	local itemLink = curReq.Link
	local enchantQuality =curReq["EnchantQuality"] and DolgubonSetCrafter.quality[ curReq["EnchantQuality"]][3] or ""
	local enchant = curReq["Enchant"] and curReq["Enchant"][2] or ""
	local text
	if style == "" then
		text= itemLink..", "..level..", "..trait..", "..quality
	else
		text= itemLink..", "..level..", "..style..", "..trait..", "..quality
	end
	if enchant and enchant ~= "" then
		text = text.." with "..enchantQuality.." "..enchant.." enchant"
	end
	return text
end

-- Reads mail. If it contain the right format, give a button to import it.
local function importRequestFromMail()
	local mailText = ZO_MailInboxMessageBody:GetText()
	-- "|H1:item:56042:25:4:26580:21:5:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"
	for link in string.gmatch(mailText, "(|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h|h)") do
		if DolgubonSetCrafter.verifyLinkIsValid(link) then
			DolgubonSetCrafter.addByItemLinkToQueue(link)
			d("Added "..link.." to the Set Crafter queue")
		end
	end
end
DolgubonSetCrafter.importRequestFromMail = importRequestFromMail
local function isThereAValidLinkInText(text)
	for link in string.gmatch(text, "(|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+|h|h)") do
		if DolgubonSetCrafter.verifyLinkIsValid(link) then
			return true
		end
	end
	return false
end
DolgubonSetCrafter.isThereAValidLinkInText = isThereAValidLinkInText

local function mailNext(destination)

end

local requestSubject = "Crafting Request"
local requestStarter = ""

local function transformSetData(setInfo)
	return setInfo
end

function DolgubonSetCrafter.MailAsRequest(destinationOverride)
	local destination = destinationOverride or DolgubonSetCrafterWindowRightInputBox:GetText()
	if #destination < 4 then 
		out("Invalid name")
		return 
	end
	if next(DolgubonSetCrafter.materialList) == nil then 
		d("Dolgubon's Lazy Set Crafter: No items are in the queue! No mails sent")
		return 
	end

	local sets = {} -- A list of all items under the current set type.
	local setTypes = {} -- Used to keep the sets list in a certain order.
	local mailInfo = {}

	local mailQueue = DolgubonSetCrafter.savedvars.queue

	for i, request in ipairs(mailQueue) do
		if request.typeId == 1 then
			local setName = request["Set"][2]
			if sets[setName] == nil then
				sets[setName] = {}
				table.insert(setTypes, setName) -- Save this index of this set's name
			end
			table.insert(sets[setName], DolgubonSetCrafter.convertRequestToText(request)) -- Store the readable crafting information
		end
	end
	for setName, requestInfos in pairs(sets) do
		table.insert(mailInfo, {text="-- "..setName.." --"})
		for i = 1, #requestInfos do
			table.insert(mailInfo, {text=requestInfos[i], set=setName})
		end
	end
	local addedProvisioningGreeting = false
	for i, request in pairs(mailQueue) do
		if request.typeId == 2 then
			if not addedProvisioningGreeting then
				addedProvisioningGreeting = true
				table.insert(mailInfo, {text="Furniture/Provisioning Items"})
				-- mailInfo[#mailInfo + 1] = "Please create these provisioning/furniture items:"
			end
			table.insert(mailInfo, {text=request.Quantity[1].."x "..request.Link, set="Furniture/Provisioning Items"})
		end
	end
	compileMailText(requestSubject, function(data) if data.set then return "\n".."-- "..data.set.." --\n"else return "\n" end end, mailInfo, function(s) return s.text end)

	beginMailing(destination)
	if true then 
		return
	end
end


function DolgubonSetCrafter.initializeMailButtons()

	local inbox = ZO_MailInboxMessage
	local subjectControl = ZO_MailInboxMessageSubject
	local controls = {}
	local button_name = inbox:GetName() .. "SetCrafterMailAdd"
	local control = inbox:CreateControl(button_name, CT_BUTTON)
	control:SetAnchor(BELOW, subjectControl, BOTTOMLEFT, 0, 5+#controls*25)
	control:SetFont('ZoFontWinH4')
	-- control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
	ApplyTemplateToControl(control, "ZO_DefaultButton")
	control:SetText("Add to Set Crafter")
	control:SetMouseEnabled(true)
	control:SetHandler("OnClicked", importRequestFromMail)
	control:SetDimensions(150, 28)
	table.insert(controls, control)
	local original = ZO_MailInboxMessageBody.SetText

	ZO_MailInboxMessageBody.SetText = function (...)
		original( ...)

		local shouldHide
		if isThereAValidLinkInText(ZO_MailInboxMessageBody:GetText()) then
			shouldHide = false
		else
			shouldHide = true
			-- shouldHide = false
		end
		control:SetHidden(shouldHide)
	end
end
