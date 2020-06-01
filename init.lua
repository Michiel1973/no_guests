-- No guests mod.
-- By VanessaE, sfan5, and kaeza.

local disallowed = {
	["guest"]				=	"Guest accounts are disallowed on this server.  "..
								"Please choose a proper username and try again.",
	["[4a]dm[1il]n"]		=	"False, misleading, or otherwise disallowed username. "..
								"Please choose a unique username and try again.",
	["[s5][e3]rv[e3]r[4a]dm[1il]n"]		=	"False, misleading, or otherwise disallowed username. "..
								"Please choose a unique username and try again.",
	["^[0-9]"]			=	"d) All-numeric usernames are disallowed on this server. "..
								"Please choose a proper username and try again.",
	["^[0-9]+$"]			=	"e) All-numeric usernames are disallowed on this server. "..
								"Please choose a proper username and try again.",
	["[0-9].-[0-9].-[0-9].-[0-9].-[0-9]"]	=	"Please choose a username without digits.",
	["^[A-Za-z]+[0-9][0-9][0-9]+$"]		=	"Please choose a username without digits.",
	["^[A-Za-z]+[0-9][0-9][0-9]+[A-Za-z]+$"]=	"Please choose a username without digits.",
	["^[A-Za-z]+[0-9][0-9]+$"]		=	"Please choose a username without digits.",
	["^[A-Za-z]+[0-9][0-9]+[A-Za-z]+$"]	=	"Please choose a username without digits.",
	["^[A-Za-z]+[0-9]+$"]			=	"Please choose a username without digits.",
}

-- Original implementation (in Python) by sfan5
local function judge(msg)
	local numspeakable = 0
	local numnotspeakable = 0
	local cn = 0
	local lastc = '____'
	for c in msg:gmatch(".") do
		c = c:lower()
		if c:find("[aeiou0-9_-]") then
			if cn > 2 and not c:find("[0-9]") then
				numnotspeakable = numnotspeakable + 1
			elseif not c:find("[0-9]") then
				numspeakable = numspeakable + 1
			end
			cn = 0
		else
			if (cn == 1) and (lastc == c) and (lastc ~= 's') then
				numnotspeakable = numnotspeakable + 1
				cn = 0
			end
			if cn > 2 then
				numnotspeakable = numnotspeakable + 1
				cn = 0
			end
			if lastc:find("[aeiou]") then
				numspeakable = numspeakable + 1
				cn = 0
			end
			if not ((lastc:find("[aipfom]") and c == "r") or (lastc == "c" and c == "h")) then
				cn = cn + 1
			end
		end
		lastc = c
	end
	if cn > 0 then
		numnotspeakable = numnotspeakable + 1
	end
	return (numspeakable >= numnotspeakable)
end

minetest.register_on_prejoinplayer(function(name, ip)
	if not minetest.player_exists(name) then
		local lname = name:lower()
		for re, reason in pairs(disallowed) do
			if lname:find(re) then
				return reason
			end
		end

		if #name < 4 then
			return "Username too short. "..
					"Please pick a name with at least four letters and try again."
		end

		if not judge(name) and #name > 5 then
			return "Your username looks like gibberish. "..
					"Please pick something readable and try again."
		end
	end
end)
