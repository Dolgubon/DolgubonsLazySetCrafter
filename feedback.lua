local owningWindow = DolgubonSetCrafterWindow
local destination = "@Dolgubon"
local destinationServer = "NA Megaserver"
local parentAddonName = "Dolgubon's Lazy Set Crafter"
local windowName = "DolgubonSetCrafterFeedback"
local parentAddonNameSpace = DolgubonSetCrafter

local mailButtonPosition = {TOPLEFT , owningWindow , TOPLEFT , 25, 25}

local amounts = {0,1000,10000,100000}

local function SendNote(self)
	owningWindow:SetHidden(true)
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function()
	ZO_MailSendToField:SetText(destination)
	ZO_MailSendSubjectField:SetText(parentAddonName)
	QueueMoneyAttachment(self.amount)
	ZO_MailSendBodyField:TakeFocus() end, 200)
end

local function initializeFeedbackWindow()
	local feedbackWindow = WINDOW_MANAGER:CreateControlFromVirtual("feedbackWindowL", owningWindow, "FeedbackTemplate")
	parentAddonNameSpace.feedbackWindow = feedbackWindow
	local showButton = WINDOW_MANAGER:CreateControlFromVirtual("ShowFeedbackWindowButton", owningWindow, "ShowFeedbackButtonTemplate")
	showButton.feedbackWindow = feedbackWindow
	showButton:SetAnchor(unpack(mailButtonPosition))
	showButton:SetDimensions(40,40)
	feedbackWindow:SetAnchor(TOPRIGHT,owningWindow, TOPLEFT, -40,0)
	feedbackWindow:SetHidden(true)

	feedbackWindow:SetDimensions(#amounts*150 , 150)
	local buttons = {}
	for i = 1, #amounts do
		if amounts[i]== 0 or GetWorldName() == destinationServer then
			buttons[#buttons+1] =  WINDOW_MANAGER:CreateControlFromVirtual("DolgubonFeedbackButton"..i, feedbackWindow, "FeedbackButton")
			buttons[i]:SetAnchor(BOTTOM,feedbackWindow, BOTTOMLEFT, (i-1)*150+70,-10)
			buttons[i].amount = amounts[i]
			buttons[i].SendNote = SendNote
			if amounts[i] == 0 then
				buttons[i]:SetText("Send Note")
			else
				buttons[i]:SetText("Send "..tostring(amounts[i]).." gold")
			end
		end
	end
end

DolgubonSetCrafter.initializeFeedbackWindow = initializeFeedbackWindow