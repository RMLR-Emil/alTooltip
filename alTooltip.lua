--[[
Original author/forked download location: https://github.com/Allez/alTooltip
Original sourcecode: MonoUI bundled version downloaded from https://www.wowinterface.com/downloads/info18071-MonoUI.html
This sourcecode is modified to make it compatible/errorfree with the 9.0 version of World of Warcraft.

100002 tooltip changes:
https://us.forums.blizzard.com/en/wow/t/tooltip-addon-help/1404301/10
https://wowpedia.fandom.com/wiki/Patch_10.0.2/API_changes

]]


local gcol = {.35, 1, .6}										-- Guild Color
local pgcol = {.7, 0.5, .8} 									-- Player's Guild Color
local position = { "BOTTOMRIGHT", UIParent, "RIGHT", -100, -275 }	-- Static Tooltip position
local scale = 1													-- Tooltip scale
local anchorcursor = false



local tooltips = {
	GameTooltip, 
	ItemRefTooltip, 
	ShoppingTooltip1, 
	ShoppingTooltip2, 
	ShoppingTooltip3, 
	WorldMapTooltip, 
	DropDownList1MenuBackdrop, 
	DropDownList2MenuBackdrop, 
	
--[[ 	PetBattlePrimaryAbilityTooltip, 
	PetBattlePrimaryUnitTooltip, 
	FloatingBattlePetTooltip, 
	BattlePetTooltip, ]]
}

local types = {
	rare = " R ",
	elite = " + ",
	worldboss = " B ",
	rareelite = " R+ ",
}

for _, v in pairs(tooltips) do
--	v:DisableDrawLayer("BACKGROUND")
	local bg = CreateFrame("Frame", nil, v, "BackdropTemplate")
--	local bg = CreateFrame("Frame", nil, v, BackdropTemplateMixin and "BackdropTemplate")
	if not bg.SetBackdrop then
--		Mixin(bg, BackdropTemplateMixin)
	end
--	Mixin(bg, BackdropTemplateMixin)
	bg:SetAllPoints(v)
	bg:SetFrameLevel(0)
	
	v:SetScale(scale)
	v:SetScript("OnShow", function(self)
--		self:SetBackdropColor(0, 0, 0, 0.6)
		local item
		if self.GetItem then
			item = select(2, self:GetItem())
		end		
		if item then
			local quality = select(3, GetItemInfo(item))
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
--				self:SetBackdropBorderColor(r, g, b)
			end
		else
--[[  		--if tostring(item):sub(1,10) == "battlepet:" then
		if strmatch(link, "|Hbattlepet:") then
			local _,species,_,quality = strsplit(":", link)
			local itemName = C_PetJournal.GetPetInfoBySpeciesID(species)
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				self:SetBackdropBorderColor(r, g, b)
			end
		end   ]]
--			self:SetBackdropBorderColor(0, 0, 0)
		end
	end)
	v:HookScript("OnHide", function(self)
--		self:SetBackdropBorderColor(0, 0, 0, 1)
	end)
end

--[[local pettooltips = {PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip, FloatingBattlePetTooltip, BattlePetTooltip}
for _, v in pairs(pettooltips) do
	v:DisableDrawLayer("BACKGROUND")
	local bg = CreateFrame("Frame", nil, v, "BackdropTemplate")
	bg:SetAllPoints(v)
	bg:SetFrameLevel(0)
	
	bg:SetBackdrop(backdrop)
	bg:SetBackdropColor(0, 0, 0, 0.6)
	bg:SetBackdropBorderColor(0, 0, 0, 1)

end ]]

local hex = function(r, g, b)
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

local truncate = function(value)
	if value >= 1e6 then
		return string.format('%.2fm', value / 1e6)
	elseif value >= 1e4 then
		return string.format('%.1fk', value / 1e3)
	else
		return string.format('%.0f', value)
	end
end

function GameTooltip_UnitColor(unit)
	local r, g, b = 1, 1, 1
	if UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			if UnitCanAttack("player", unit) then
				r = FACTION_BAR_COLORS[2].r
				g = FACTION_BAR_COLORS[2].g
				b = FACTION_BAR_COLORS[2].b
			end
		elseif UnitCanAttack("player", unit) then
			r = FACTION_BAR_COLORS[4].r
			g = FACTION_BAR_COLORS[4].g
			b = FACTION_BAR_COLORS[4].b
		elseif UnitIsPVP(unit) then
			r = FACTION_BAR_COLORS[6].r
			g = FACTION_BAR_COLORS[6].g
			b = FACTION_BAR_COLORS[6].b
		end
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			r = FACTION_BAR_COLORS[reaction].r
			g = FACTION_BAR_COLORS[reaction].g
			b = FACTION_BAR_COLORS[reaction].b
		end
	end
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
	end
	return r, g, b
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit,function(self, data)
	local unit = select(2, self:GetUnit())
	if unit then
		local unitClassification = types[UnitClassification(unit)] or " "
		local diffColor = GetQuestDifficultyColor(UnitLevel(unit))
		local creatureType = UnitCreatureType(unit) or ""
		local unitName = UnitName(unit)
		local unitLevel = UnitLevel(unit)
		if unitLevel < 0 then unitLevel = '??' end
		if UnitIsPlayer(unit) then
			local unitRace = UnitRace(unit)
			local unitClass = UnitClass(unit)
			local guild, rank = GetGuildInfo(unit)
			local playerGuild = GetGuildInfo("player")
			if guild then
				GameTooltipTextLeft2:SetFormattedText("%s"..hex(1, 1, 1).." (%s)|r", guild, rank)
				if IsInGuild() and guild == playerGuild then
					GameTooltipTextLeft2:SetTextColor(pgcol[1], pgcol[2], pgcol[3])
				else
					GameTooltipTextLeft2:SetTextColor(gcol[1], gcol[2], gcol[3])
				end
			end
			for i=2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft" .. i]:GetText():find(PLAYER) then
					_G["GameTooltipTextLeft" .. i]:SetText(string.format(hex(diffColor.r, diffColor.g, diffColor.b).."%s|r ", unitLevel) .. unitRace)
					break
				end
			end
		else
			for i=2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft" .. i]:GetText():find(LEVEL) or _G["GameTooltipTextLeft" .. i]:GetText():find(creatureType) then
					_G["GameTooltipTextLeft" .. i]:SetText(string.format(hex(diffColor.r, diffColor.g, diffColor.b).."%s|r", unitLevel) .. unitClassification .. creatureType)
					break
				end
			end
		end
		if UnitIsPVP(unit) then
			for i = 2, GameTooltip:NumLines() do
				if _G["GameTooltipTextLeft"..i]:GetText():find(PVP) then
					_G["GameTooltipTextLeft"..i]:SetText(nil)
					break
				end
			end
		end
		if UnitExists(unit.."target") then
			local r, g, b = GameTooltip_UnitColor(unit.."target")
			if UnitName(unit.."target") == UnitName("player") then
				text = hex(1, 0, 0).."<You>|r"
			else
				text = hex(r, g, b)..UnitName(unit.."target").."|r"
			end
			self:AddLine(TARGET..": "..text)
		end
	end
end)

GameTooltipStatusBar.bg = CreateFrame("Frame", nil, GameTooltipStatusBar, "BackdropTemplate")
--Mixin(GameTooltipStatusBar, BackdropTemplateMixin)
GameTooltipStatusBar.bg:SetPoint("TOPLEFT", GameTooltipStatusBar, "TOPLEFT", -1, 1)
GameTooltipStatusBar.bg:SetPoint("BOTTOMRIGHT", GameTooltipStatusBar, "BOTTOMRIGHT", 1, -1)
GameTooltipStatusBar.bg:SetFrameStrata("LOW")
GameTooltipStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 1, 0)
GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -1, 0)
GameTooltipStatusBar:HookScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	if value < min or value > max then
		return
	end
	local unit  = select(2, GameTooltip:GetUnit())
	if unit then
		min, max = UnitHealth(unit), UnitHealthMax(unit)
		if not self.text then
			self.text = self:CreateFontString(nil, "OVERLAY")
			self.text:SetPoint("CENTER", GameTooltipStatusBar)
			self.text:SetFont(GameFontNormal:GetFont(), 11, "THINOUTLINE")
		end
		self.text:Show()
		local hp = truncate(min).." / "..truncate(max)
		self.text:SetText(hp)
	else
		if self.text then
			self.text:Hide()
		end
	end
end)


local iconFrame = CreateFrame("Frame", nil, ItemRefTooltip, "BackdropTemplate")
iconFrame:SetWidth(30)
iconFrame:SetHeight(30)
iconFrame:SetPoint("TOPRIGHT", ItemRefTooltip, "TOPLEFT", -3, 0)
iconFrame2 = CreateFrame("Frame", nil, iconFrame, "BackdropTemplate")
iconFrame2:SetAllPoints(iconFrame)
iconFrame2:SetFrameLevel(iconFrame:GetFrameLevel()+1)
iconFrame.icon = iconFrame2:CreateTexture(nil, "BACKGROUND")
iconFrame.icon:SetPoint("TOPLEFT", 1, -1)
iconFrame.icon:SetPoint("BOTTOMRIGHT", -1, 1)
iconFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

hooksecurefunc("SetItemRef", function(link, text, button)
	if iconFrame:IsShown() then
		iconFrame:Hide()
	end
	local type, id = string.match(link, "(%l+):(%d+)") 
	if type == "item" then
		iconFrame.icon:SetTexture(select(10, GetItemInfo(id)))
		iconFrame:Show()
	elseif type == "spell" then
		iconFrame.icon:SetTexture(select(3, GetSpellInfo(id)))
		iconFrame:Show()
	elseif type == "achievement" then
		iconFrame.icon:SetTexture(select(10, GetAchievementInfo(id)))
		iconFrame:Show()
	end
end)
--[[
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:SetOwner(parent, "ANCHOR_NONE")
	tooltip:SetPoint(unpack(position))
	tooltip.default = 1
	
 	tooltip:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.02 then
			local x, y = GetCursorPosition()
			tooltip:SetPoint("BOTTOMLEFT", x, y)
			self.elapsed = 0
		end
	end) 
end)]]

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if not anchorcursor then
		tooltip:SetOwner(parent, "ANCHOR_NONE")
		tooltip:SetPoint(unpack(position))
	else
		tooltip:SetOwner(parent, "ANCHOR_CURSOR")
	end
	tooltip.default = 1
end)



--[[ PetBattlePrimaryUnitTooltip.Delimiter:SetTexture(0, 0, 0)
PetBattlePrimaryUnitTooltip.Delimiter:SetHeight(1)
PetBattlePrimaryAbilityTooltip.Delimiter1:SetHeight(1)
PetBattlePrimaryAbilityTooltip.Delimiter1:SetTexture(0, 0, 0)
PetBattlePrimaryAbilityTooltip.Delimiter2:SetHeight(1)
PetBattlePrimaryAbilityTooltip.Delimiter2:SetTexture(0, 0, 0)
FloatingBattlePetTooltip.Delimiter:SetTexture(0, 0, 0)
FloatingBattlePetTooltip.Delimiter:SetHeight(1) ]]