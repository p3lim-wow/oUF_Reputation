--[[

	Elements handled:
	 .Reputation [statusbar]
	 .Reputation.Text [fontstring] (optional)

	Shared:
	 - MouseOver [boolean]
	 - Tooltip [boolean]

	Functions that can be overridden from within a layout:
	 - :PostUpdate(event, unit, bar, min, max, value, name, id)
	 - :OverrideText(min, max, value, name, id)

--]]
local function Tooltip(self, min, max, name, id)
	if(self.MouseOver) then self:SetAlpha(1) end

	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 5, -5)
	GameTooltip:AddLine(string.format('%s (%s)', name, _G['FACTION_STANDING_LABEL'..id]))
	GameTooltip:AddLine(string.format('%d/%d (%.1f%%)', min, max, min/max*100))
	GameTooltip:Show()
end

local function Update(self, event, unit)
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
			Tooltip(bar, value - min, max - min, name, id)
		end)
	end

	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function Enable(self, unit)
	local reputation = self.Reputation
	if(reputation and unit == 'player') then
		self:RegisterEvent('UPDATE_FACTION', Update)

		if(reputation.Tooltip or reputation.MouseOver) then
			reputation:EnableMouse()
		end

		if(reputation.Tooltip and reputation.MouseOver) then
			reputation:SetAlpha(0)
			reputation:SetScript('OnLeave', function(self) self:SetAlpha(0); GameTooltip:Hide() end)
		elseif(reputation.MouseOver and not reputation.Tooltip) then
			reputation:SetAlpha(0)
			reputation:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
			reputation:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
		elseif(reputation.Tooltip and not reputation.MouseOver) then
			reputation:SetScript('OnLeave', function() GameTooltip:Hide() end)
		end

		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end


		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', Update)
	end
end

oUF:AddElement('Reputation', Update, Enable, Disable)