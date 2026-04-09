-- OmniRal

local TowerService = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modules
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local New = require(ReplicatedStorage.Source.Pronghorn.New)
local ResourceService = require(ServerScriptService.Source.ServerModules.General.ResourceService)

local TowerInfo = require(ReplicatedStorage.Source.SharedModules.Info.TowerInfo)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remotes
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Variables
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunHeartbeat: RBXScriptConnection? = nil

local AllTowers: {
    [Model]: {
        Cooldown: number,
    }
} = {}

local SharedAssets = ReplicatedStorage.Assets

local TowerFolder: Folder
local RNG = Random.new()

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function SpawnRandomTestTower()
    task.delay(3, function()
        local Trees = {}
        for _, Tree in Workspace.Resources:GetChildren() do
            if not string.find(Tree.Name, "Tree") then continue end
            table.insert(Trees, Tree)
        end

        TowerService.SpawnNew("TestTower", Trees[RNG:NextInteger(1, #Trees)])
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function TowerService.SpawnNew(TowerName: string, ThisResource: Model?, OverrideCFrame: CFrame?)
    local Model, Info = SharedAssets.Towers:FindFirstChild(TowerName) :: Model, TowerInfo[TowerName]
    warn(Model, Info)
    if not Model or not Info or (not OverrideCFrame and not ThisResource) then return end
    warn(2)

    local PlaceHere = if ThisResource then ThisResource:GetPivot() else OverrideCFrame

    if ThisResource then
        local CostReduction = ResourceService.PlaceTowerOnResource(ThisResource)
        if not CostReduction then return end

        warn(3)
    end

    local NewModel = Model:Clone()
    NewModel:PivotTo(PlaceHere)
    NewModel.Parent = TowerFolder

    return NewModel
end

function TowerService.Stop()
    if not RunHeartbeat then return end
    RunHeartbeat:Disconnect()
    RunHeartbeat = nil
end

function TowerService.Run()
    TowerService.Stop()

    RunHeartbeat = RunService.Heartbeat:Connect(function() 
        
    end)
end

function TowerService:Init()
end

function TowerService:Deferred()
    TowerFolder = New.Instance("Folder", Workspace, "Towers")

    SpawnRandomTestTower()
end

return TowerService