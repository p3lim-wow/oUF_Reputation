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

	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function enable(self, unit)
	local bar = self.Reputation
	if(bar and unit == 'player') then
		if(not bar:GetStatusBarTexture()) then
			bar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		self:RegisterEvent('UPDATE_FACTION', update)

		return true
	end
end

local function disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', update)
	end
end

oUF:AddElement('Reputation', update, enable, disable)
