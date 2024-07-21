std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'614', -- trailing whitespace in comment (we use this for docs)
	'631', -- line is too long
}

globals = {
	'oUF',
}

read_globals = {

	-- FrameXML objects
	'GameTooltip',

	-- FrameXML functions
	'ToggleCharacter',

	-- FrameXML constants
	'MAX_REPUTATION_REACTION',

	-- namespaces
	'C_GossipInfo',
	'C_Reputation',

	-- API
	'BreakUpLargeNumbers',
	'GetFactionInfoByID',
	'GetLocale',
	'GetText',
	'GetWatchedFactionInfo',
	'UnitSex',
	'hooksecurefunc',
}
