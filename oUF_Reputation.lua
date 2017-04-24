local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Reputation was unable to locate oUF install')

local function GetReputation()
	local pendingReward
	local name, standingID, max, _, cur, factionID = GetWatchedFactionInfo()
	local friendID, _, _, _, _, _, standingText, _, friendMax = GetFriendshipReputation(factionID)
	if(friendID) then
		max = friendMax or 1
		cur = friendMax and math.fmod(cur, max) or 1
		standingID = 5 -- force friends' color
	else
		if(C_Reputation.IsFactionParagon(factionID)) then
			cur, max, _, pendingReward = C_Reputation.GetFactionParagonInfo(factionID)
			standingText = PARAGON
		else
			standingText = GetText('FACTION_STANDING_LABEL' .. standingID, UnitSex('player'))
		end

		cur = math.fmod(cur, max)
	end

	return cur, max, name, factionID, standingID, standingText, pendingReward
end

for tag, func in next, {
	['reputation:cur'] = function()
		return (GetReputation())
	end,
	['reputation:max'] = function(unit, runit)
		local _, max = GetReputation()
		return max
	end,
	['reputation:per'] = function()
		local cur, max = GetReputation()
		return math.floor(cur / max * 100 + 1/2)
	end,
	['reputation:standing'] = function()
		local _, _, _, _, _, standingText = GetReputation()
		return standingText
	end,
	['reputation:faction'] = function()
		local _, _, name = GetReputation()
		return name
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'UPDATE_FACTION'
end

oUF.Tags.SharedEvents.UPDATE_FACTION = true

local function Update(self, event, unit)
	local element = self.Reputation
	if(element.PreUpdate) then element:PreUpdate(unit) end

	local cur, max, name, factionID, standingID, standingText, pendingReward = GetReputation()
	if(name) then
		element:SetMinMaxValues(0, max)
		element:SetValue(cur)

		if(element.colorStanding) then
			local colors = self.colors.reaction[standingID]
			element:SetStatusBarColor(colors[1], colors[2], colors[3])
		end
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max, name, factionID, standingID, standingText, pendingReward)
	end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ElementEnable(self)
	self:RegisterEvent('UPDATE_FACTION', Path, true)

	self.Reputation:Show()

	Path(self, 'ElementEnable', 'player')
end

local function ElementDisable(self)
	self:UnregisterEvent('UPDATE_FACTION', Path)

	self.Reputation:Hide()

	Path(self, 'ElementDisable', 'player')
end

local function Visibility(self, event, unit, selectedFactionIndex)
	local shouldEnable
	if(selectedFactionIndex ~= nil) then
		if(selectedFactionIndex > 0) then
			shouldEnable = true
		end
	elseif(not not (GetWatchedFactionInfo())) then
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

		hooksecurefunc('SetWatchedFactionIndex', function(selectedFactionIndex)
			if(self:IsElementEnabled('Reputation')) then
				VisibilityPath(self, 'SetWatchedFactionIndex', 'player', selectedFactionIndex or 0)
			end
		end)

		if(not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		ElementDisable(self)
	end
end

oUF:AddElement('Reputation', VisibilityPath, Enable, Disable)
