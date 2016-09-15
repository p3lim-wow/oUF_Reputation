local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Reputation was unable to locate oUF install')

local function GetReputation()
	local name, standingID, min, max, value, factionID = GetWatchedFactionInfo()
	local _, friendMin, friendMax, _, _, _, friendStanding, friendThreshold = GetFriendshipReputation(factionID)

	if(not friendMin) then
		return value - min, max - min, name, factionID, standingID, GetText('FACTION_STANDING_LABEL' .. standingID, UnitSex('player'))
	else
		return friendMin - friendThreshold, math.min(friendMax - friendThreshold, 8400), name, factionID, standingID, friendStanding
	end
end

for tag, func in next, {
	['currep'] = function()
		local min = GetReputation()
		return min
	end,
	['maxrep'] = function()
		local _, max = GetReputation()
		return max
	end,
	['perrep'] = function()
		local min, max = GetReputation()
		return math.floor(min / max * 100 + 1/2)
	end,
	['standing'] = function()
		local _, _, standing = GetReputation()
		return standing
	end,
	['reputation'] = function()
		return GetWatchedFactionInfo()
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'UPDATE_FACTION'
end

oUF.Tags.SharedEvents.UPDATE_FACTION = true

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Reputation
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur, max, name, factionID, standingID, standingText = GetReputation()
	if(name) then
		element:SetMinMaxValues(0, max)
		element:SetValue(cur)

		if(element.colorStanding) then
			local color = FACTION_BAR_COLORS[standingID]
			element:SetStatusBarColor(color.r, color.g, color.b)
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, name, factionID, standingID, standingText)
	end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self.Reputation:Show()

	Path(self, 'ElementEnable', 'player')
end

local function ElementDisable(self)
	self.Reputation:Hide()

	Path(self, 'ElementDisable', 'player')
end

local function Visibility(self, event, unit, selectedFactionIndex)
	local shouldEnable
	if(GetWatchedFactionInfo()) then
		shouldEnable = true
	end

	if(shouldEnable) then
		ElementEnable(self)
	else
		ElementDisable(self)
	end
end

local function VisibilityPath(self, ...)
	return (self.Reputation.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Reputation
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_FACTION', Path, true)

		if(not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', Path)
	end
end

oUF:AddElement('Reputation', VisibilityPath, Enable, Disable)
