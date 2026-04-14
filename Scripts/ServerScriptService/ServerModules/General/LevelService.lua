-- OmniRal

local LevelService = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ServerScriptService = game:GetService("ServerScriptService")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modules
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local LevelInfo = require(ServerScriptService.Source.ServerModules.Info.LevelInfo)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remotes
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Variables
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function LevelService.CheckHaveEnoughTeamResources(BuildCost: {Tree: number, Rock: number, Crystal: number}): boolean
    for Resource, Amount in BuildCost do
        if not LevelInfo.TeamResources[Resource] then return false end
        if LevelInfo.TeamResources[Resource] < Amount then return false end
    end

    return true
end

function LevelService.CheckPlayerHasEnoughResources(Player: Player, BuildCost: {Tree: number, Rock: number, Crystal: number}): boolean
    if not Player then return false end

    local PValues = PlayerValues[Player]
    if not PValues then return false end
    if not PValues.Resources then return false end

    for Resource, Amount in BuildCost do
        if not PValues.Resources[Resource] then return false end
        if PValues.Resources[Resource] < Amount then return false end
    end

    return true
end

-- Add or subtract resources from the team pool
function LevelService.UpdateResourcesCount(By: {Tree: number, Rock: number, Crystal: number})
    for Resource, Amount in By do
        if not LevelInfo.TeamResources[Resource] then continue end
        LevelInfo.TeamResources[Resource] += Amount
    end
end

-- Add or subtract resources from the player pool
function LevelService.UpdatePlayerResourcesCount(Player: Player, By: {Tree: number, Rock: number, Crystal: number})
    if not Player then return end

    local PValues = PlayerValues[Player]
    if not PValues then return end
    if not PValues.Resources then return end

    for Resource, Amount in By do
        if not PValues.Resources[Resource] then continue end
        PValues.Resources[Resource] += Amount
    end
end

function LevelService:Init()

end

return LevelService