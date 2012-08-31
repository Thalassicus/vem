-- CiVUP_Core
-- Author: Thalassicus
-- DateCreated: 12/21/2010 10:00:43 AM
--------------------------------------------------------------

include("YieldLibrary.lua")

--print("INFO   Loading CiVUP_Core.lua")

if Game == nil then
	return
end

local log = Events.LuaLogger:New()
log:SetLevel("INFO")

if GameInfo.Units[1].PopCostMod == nil then
	log:Fatal("'Civup - General.sql' did not load!")
end

---------------------------------------------------------------------
-- LuaEvents.PrintDebug()
--
function LuaEvents.PrintDebug()
	local text			= ""
	local turnTime		= Game.GetGameTurn() - MapModData.VEM.StartTurn
	local avgPlayers	= 0
	local avgCities		= 0
	local avgUnits		= 0
	if turnTime > 0 then
		avgPlayers = MapModData.VEM.TotalPlayers / turnTime
		avgCities = MapModData.VEM.TotalCities / turnTime
		avgUnits = MapModData.VEM.TotalUnits / turnTime
	else
		for playerID, player in pairs(Players) do
			if player:IsAliveCiv() then
				avgPlayers = avgPlayers + 1
				for city in player:Cities() do
					avgCities = avgCities + 1
				end
				for unit in player:Units() do
					avgUnits = avgUnits + 1
				end
			end
		end
	end
	
	text = string.format("%s\n\n============= Game Info =============\n\n", text)
	text = string.format("%s%14s %-s\n", text, "Map:", PreGame.GetMapScript())
	text = string.format("%s%14s %-s\n", text, "Leader:", GameInfo.Leaders[Players[Game.GetActivePlayer()]:GetLeaderType()].Type)
	text = string.format("%s%14s %-s\n", text, "Difficulty:", GameInfo.HandicapInfos[Game:GetHandicapType()].Type)
	text = string.format("%s%14s %-s\n", text, "Size:", GameInfo.Worlds[Map.GetWorldSize()].Type)	
	text = string.format("%s%14s %-s%%%%\n", text, "Speed:", GameInfo.GameSpeeds[Game.GetGameSpeedType()].VictoryDelayPercent)
	text = string.format("%s%14s %-s\n", text, "Animations:", tostring(Civup.PLAY_COMBAT_ANIMATIONS == 1))
	text = string.format("%s%14s %-i\n", text, "Players:", avgPlayers)
	text = string.format("%s%14s %-i\n", text, "Cities:", avgCities)
	text = string.format("%s%14s %-i\n", text, "Units:", avgUnits)
	text = string.format("%s%14s %-i\n", text, "Plots:", Map.GetNumPlots())
	text = string.format("%s%14s %-i\n", text, "Start turn:", MapModData.VEM.StartTurn)
	text = string.format("%s%14s %-i\n", text, "End turn:", Game.GetGameTurn())

	text = string.format("%s\n\n==== Average Processing per Turn ====\n", text)
	if turnTime > 0 then		
		text = string.format("%s\n%14s %10s\n", text, "VanillaStuff", "seconds")
		text = string.format("%s%14s %10.3f seconds\n", text, "Total", MapModData.VEM.VanillaTurnTimes / turnTime)
		
		text = string.format("%s\n%14s %10s\n", text, "ModTurnStart", "seconds")
		text = string.format("%s%14s %10.3f\n", text, "Turn", MapModData.VEM.StartTurnTimes.Turn / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Players", MapModData.VEM.StartTurnTimes.Players / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Policies", MapModData.VEM.StartTurnTimes.Policies / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Cities", MapModData.VEM.StartTurnTimes.Cities / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Units", MapModData.VEM.StartTurnTimes.Units / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Plots", MapModData.VEM.StartTurnTimes.Plots / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Total", MapModData.VEM.StartTurnTimes.Total / turnTime)

		text = string.format("%s\n%14s %10s\n", text, "ModTurnEnd", "seconds")
		text = string.format("%s%14s %10.3f\n", text, "Turn", MapModData.VEM.EndTurnTimes.Turn / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Players", MapModData.VEM.EndTurnTimes.Players / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Policies", MapModData.VEM.EndTurnTimes.Policies / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Cities", MapModData.VEM.EndTurnTimes.Cities / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Units", MapModData.VEM.EndTurnTimes.Units / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Plots", MapModData.VEM.EndTurnTimes.Plots / turnTime)
		text = string.format("%s%14s %10.3f\n", text, "Total", MapModData.VEM.EndTurnTimes.Total / turnTime)
	end

	text = string.format("%s\n\n========== City Yield Rates ==========\n\n", text)
	local header = string.format(
		"%5s %5s %5s %5s %5s %5s %5s %-20s %-1s\n",
		"Food",
		"Prod",
		"Gold",
		"Sci",
		"Cul",
		"AI",
		"Pop",
		"Player",
		"City"
	)
	text = text .. header
	local cityText = ""
	for playerID = 0, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		local player = Players[playerID];
		if player:IsEverAlive() and player:GetNumCities() > 0 then
			local totalYield = {}
			local totalAIBonus = 0
			local totalCount = 0
			for city in player:Cities() do
				totalCount = totalCount + 1
				for yieldInfo in GameInfo.Yields() do
					totalYield[yieldInfo.ID] = (totalYield[yieldInfo.ID] or 0) + City_GetYieldRate(city, yieldInfo.ID)
				end
				totalYield[YieldTypes.YIELD_POPULATION] = (totalYield[YieldTypes.YIELD_POPULATION] or 0) + city:GetPopulation()
				totalAIBonus = totalAIBonus + City_GetNumBuilding(city, GameInfo.Buildings.BUILDING_AI_PRODUCTION.ID)
				cityText = string.format(
					"%s%5s %5s %5s %5s %5s %5s %5s %-20s %-1s\n",
					cityText,
					Game.Round(City_GetYieldRate(city, YieldTypes.YIELD_FOOD)),
					Game.Round(City_GetYieldRate(city, YieldTypes.YIELD_PRODUCTION)),
					Game.Round(City_GetYieldRate(city, YieldTypes.YIELD_GOLD)),
					Game.Round(City_GetYieldRate(city, YieldTypes.YIELD_SCIENCE)),
					Game.Round(City_GetYieldRate(city, YieldTypes.YIELD_CULTURE)),
					City_GetNumBuilding(city, GameInfo.Buildings.BUILDING_AI_PRODUCTION.ID),
					city:GetPopulation(),
					player:GetName(),
					city:GetName()
				)
			end
			
			if totalCount ~= 0 then
				text = string.format(
					"%s%5s %5s %5s %5s %5s %5s %5s %-20s %-1s\n",
					text,
					Game.Round(totalYield[YieldTypes.YIELD_FOOD] / totalCount),
					Game.Round(totalYield[YieldTypes.YIELD_PRODUCTION] / totalCount),
					Game.Round(totalYield[YieldTypes.YIELD_GOLD] / totalCount),
					Game.Round(totalYield[YieldTypes.YIELD_SCIENCE] / totalCount),
					Game.Round(totalYield[YieldTypes.YIELD_CULTURE] / totalCount),
					Game.Round(totalAIBonus / totalCount),
					Game.Round(totalYield[YieldTypes.YIELD_POPULATION] / totalCount),
					player:GetName(),
					"Average"
				)
			end
		end
	end

	text = string.format("%s\n%s%s", text, header, cityText)
	log:Info(text)
end