
---------------------------
-- UI Helper functions

-- The idea behind this is it can be 'inherited' to give a button a toggle, on or off.
-- Passing a control, along with two textures (one for the 'ON' state, and one for the 'OFF' state) will allow it to be toggled.
function DolgubonSetCrafter.createToggle(control, onTexture, offTexture, onOverTexture, offOverTexture , initialToggleValue)
	-- add a value to the control. If no initial value is specified, set it to false.
	-- DO NOT SET! 
	control.toggleValue = initialToggleValue or false
	-- Sets the textures to the passed values; if no value is passed, set to the current texture; if none, then no texture
	control.onTexture = onTexture or (control.GetNormalTexture and control:GetNormalTexture()) or ""
	control.offTexture = offTexture or (control.GetNormalTexture and control:GetNormalTexture()) or ""
	control.onOverTexture = onOverTexture or nil
	control.offOverTexture = offOverTexture or nil

	-- Set the initial texture; this can be done in the xml, but a bit of redundancy doesn't hurt
	if control.toggleValue then 
		control:SetNormalTexture(onTexture) 
		if onOverTexture then control:SetMouseOverTexture(onOverTexture) end
	else 
		if offOverTexture then control:SetMouseOverTexture(offOverTexture) end
		control:SetNormalTexture(offTexture) 
	end

	-- Toggle to a set value
	-- Changes the textures and mouse over texture if needed
	function control:toggleOn()
		self.toggleValue = true
		self:SetNormalTexture(self.onTexture)
		if onOverTexture then self:SetMouseOverTexture(self.onOverTexture) end
		control:onToggleOn()
		control:onToggle(true)
	end

	function control:toggleOff()
		self.toggleValue = false
		self:SetNormalTexture(self.offTexture)
		if offOverTexture then self:SetMouseOverTexture(self.offOverTexture) end
		control:onToggleOff()
		control:onToggle(false)
	end

	function control:setState(newState)
		if newState == self.toggleValue then
			return 
		elseif newState then
			control:toggleOn()
		else
			control:toggleOff()
		end
	end


	-- Meant to be overwritten, if needed
	function control:onToggleOn()
	end

	-- Meant to be overwritten, if needed
	function control:onToggleOff()
	end

	function control:onToggle(newToggleState)
	end

	-- The actual toggle function. The idea is to place it in the OnClicked in the XML, but it could be called elsewhere
	function control:toggle()
		-- Sets the toggle value to the other value
		if self.toggleValue then
			control:toggleOff()
		else
			control:toggleOn()
			
		end
	end

end
