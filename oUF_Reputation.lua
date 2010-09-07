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

	if(bar.PostUpdate) then bar.PostUpdate(self, event, unit, bar, min, max, value, name, id) end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local bar = self.Reputation
	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_FACTION', Path)

		if(not bar:GetStatusBarTexture()) then
			bar:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', Path)
	end
end

oUF:AddElement('Reputation', Path, Enable, Disable)
