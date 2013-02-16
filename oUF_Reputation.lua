local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Reputation was unable to locate oUF install')

for tag, func in pairs({
	['currep'] = function()
		local _, _, min, _, value, id = GetWatchedFactionInfo()
		local _, friendRep, _, _, _, _, _, friendThreshold = GetFriendshipReputation(id)
		if(not friendRep) then
			return value - min
		else
			return friendRep - friendThreshold
		end
	end,
	['maxrep'] = function()
		local _, _, min, max, _, id = GetWatchedFactionInfo()
		local _, _, friendMaxRep, _, _, _, _, friendThreshold = GetFriendshipReputation(id)
		if(not friendMaxRep) then
			return max - min
		else
			return math.min(friendMaxRep - friendThreshold, 8400)
		end
	end,
	['perrep'] = function()
		local _, _, min, max, value_ id = GetWatchedFactionInfo()
		local _, friendRep, friendMaxRep, _, _, _, _, friendThreshold = GetFriendshipReputation(id)
		if(not friendRep) then
			return math.floor((value - min) / (max - min) * 100 + 0.5)
		else
			return math.floor((friendRep - friendThreshold) / math.min(friendMaxRep - friendThreshold) * 100 + 0.5)
		end
	end,
	['standing'] = function()
		local _, standing, _, _, _, id = GetWatchedFactionInfo()
		local _, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(id)
		if(not friendTextLevel) then
			return GetText('FACTION_STANDING_LABEL' .. standing, UnitSex('player'))
		else
			return friendTextLevel
		end
	end,
	['reputation'] = function()
		return GetWatchedFactionInfo()
	end,
}) do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'UPDATE_FACTION'
end

oUF.Tags.SharedEvents.UPDATE_FACTION = true

local function Update(self, event, unit)
	local reputation = self.Reputation

	local name, standing, min, max, value, id = GetWatchedFactionInfo()
	local _, friendRep, friendMaxRep, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(id)
	if(not name) then
		return reputation:Hide()
	else
		reputation:Show()
	end

	if(not friendRep) then
		reputation:SetMinMaxValues(0, max - min)
		reputation:SetValue(value - min)
	else
		reputation:SetMinMaxValues(0, math.min(friendMaxRep - friendThreshold, 8400))
		reputation:SetValue(friendRep - friendThreshold)
	end

	if(reputation.colorStanding) then
		local color = FACTION_BAR_COLORS[standing]
		reputation:SetStatusBarColor(color.r, color.g, color.b)
	end

	if(reputation.PostUpdate) then
		if(not friendRep) then
			return reputation:PostUpdate(unit, name, standing, min, max, value, id)
		else
			return reputation:PostUpdate(unit, name, friendTextLevel, friendThreshold, nextFriendThreshold and nextFriendThreshold or friendMaxRep, friendRep, id)
		end
	end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local reputation = self.Reputation
	if(reputation) then
		reputation.__owner = self
		reputation.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_FACTION', Path)

		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
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
