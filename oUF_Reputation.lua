--[[

	Elements handled:
	 .Reputation [statusbar]
	 .Reputation.Text [fontstring] (optional)

	Booleans:
	 - Tooltip

	Functions that can be overridden from within a layout:
	 - PostUpdate(self, event, unit, bar, min, max, value, name, id)
	 - OverrideText(bar, min, max, value, name, id)

--]]

local function tooltip(self, min, max, name, id)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 5, -5)
	GameTooltip:AddLine(string.format('%s (%s)', name, _G['FACTION_STANDING_LABEL'..id]))
	GameTooltip:AddLine(string.format('%d / %d (%d%%)', min, max, min / max * 100))
	GameTooltip:Show()
end

local function update(self, event, unit)
	local bar = self.Reputation
	if(not GetWatchedFactionInfo()) then return bar:Hide() end

	local name, id, min, max, value = GetWatchedFactionInfo()
	bar:SetMinMaxValues(min, max)
	bar:SetValue(value)
	bar:Show()

	if(bar.Text) then
		if(bar.OverrideText) then
			bar:OverrideText(min, max, value, name, id)
		else
			bar.Text:SetFormattedText('%d / %d - %s', value - min, max - min, name)
		end
	end

	if(bar.Tooltip) then
		bar:SetScript('OnEnter', function()
			tooltip(bar, value - min, max - min, name, id)
		end)
	end

	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function enable(self, unit)
	local reputation = self.Reputation
	if(reputation and unit == 'player') then
		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		self:RegisterEvent('UPDATE_FACTION', update)

		if(reputation.Tooltip) then
			reputation:EnableMouse()
			reputation:SetScript('OnLeave', GameTooltip_OnLeave)
		end

		return true
	end
end

local function disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', update)
	end
end

oUF:AddElement('Reputation', update, enable, disable)
