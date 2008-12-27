--[[

	Elements handled:
	 .Reputation [statusbar]
	 .Reputation.Text [fontstring] (optional)

	Shared:
	 - Colors [table] - will use blizzard colors if not set
	 - Tooltip [boolean]
	 - MouseOver [boolean]

--]]
local function Tooltip(self, min, max, name, id)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 5, -5)
	GameTooltip:AddLine(string.format('%s (%s)', name, _G['FACTION_STANDING_LABEL'..id]))
	GameTooltip:AddLine(string.format('%d/%d (%.1f%%)', min, max, min/max*100))
	GameTooltip:Show()
end

local function Update(self, event, unit)
	local bar = self.Reputation
	
	if(GetWatchedFactionInfo()) then
		local name, id, min, max, value = GetWatchedFactionInfo()
		bar:SetMinMaxValues(min, max)
		bar:SetValue(value)
		bar:EnableMouse()
		bar:SetStatusBarColor(unpack(bar.Colors or {FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b}))

		if(not bar.MouseOver) then
			bar:SetAlpha(1)
		end

		if(bar.Text) then
			bar.Text:SetFormattedText('%d / %d - %s', value - min, max - min, name)
		end

		if(bar.Tooltip and bar.MouseOver) then
			bar:SetScript('OnEnter', function() bar:SetAlpha(1); Tooltip(bar, value - min, max - min, name, id) end)
			bar:SetScript('OnLeave', function() bar:SetAlpha(0); GameTooltip:Hide() end)
		elseif(bar.Tooltip and not bar.MouseOver) then
			bar:SetScript('OnEnter', function() Tooltip(bar, value - min, max - min, name, id) end)
			bar:SetScript('OnLeave', function() GameTooltip:Hide() end)
		elseif(bar.MouseOver and not bar.Tooltip) then
			bar:SetScript('OnEnter', function() bar:SetAlpha(1) end)
			bar:SetScript('OnLeave', function() bar:SetAlpha(0) end)
		end
	end
end

local function Enable(self, unit)
	local reputation = self.Experience
	if(reputation and unit == 'player') then
		self:RegisterEvent('UPDATE_FACTION', Update)

		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		if(reputation.MouseOver) then
			reputation:SetAlpha(0)
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