-- OmniRal

local ResourceService = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modules
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ResourceModules = {
    Tree = {},
    Rock = {},
    Crystal = {},
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SPAWN_TEST_RESOURCES = true

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remotes
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Variables
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunConnection: thread? = nil

local Resources: {
    [Model]: {Chopped: boolean, RespawnAt: number}
} = {}

local Assets = ServerStorage.Assets
local RNG = Random.new()

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function CheckForTestMap()
    if not SPAWN_TEST_RESOURCES then return end

    local Folder = Workspace:FindFirstChild("ResourceSpawns")
    if not Folder then return end

    ResourceService.SpawnResources("TestMap", Folder)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Spawn the resources for one specific map
function ResourceService.SpawnResources(MapName: string, Folder: Folder)
    assert(Assets.Maps:FindFirstChild(MapName), MapName .. " doesn't exist!")

    for _, Spawn in Folder:GetChildren() do
        local TypeName = string.gsub(Spawn.Name, "Spawn", "")
        if TypeName ~= "Tree" and TypeName ~= "Rock" and TypeName ~= "Crystal" then continue end
        if not Assets.Maps[MapName]:FindFirstChild(TypeName .. "s") then continue end

        local AllModels = Assets.Maps[MapName][TypeName .. "s"]:GetChildren()

        local ThisModule = ResourceModules[TypeName][MapName .. TypeName]
        local ThisModel = AllModels[RNG:NextInteger(1, #AllModels)]
        if not ThisModule or not ThisModel then continue end

        local NewModel = ThisModel:Clone() :: Model
        NewModel:PivotTo(Spawn.CFrame * CFrame.new(0, -0.5, 0))
        NewModel.Parent = Workspace

        ThisModule.Set(NewModel)
        Spawn:Destroy()
    end
end

function ResourceService.Stop()
    if not RunConnection then return end
    task.cancel(RunConnection)
    RunConnection = nil
end

-- Handles respawning of resources
function ResourceService.Run()
    ResourceService.Stop()

    RunConnection = task.spawn(function()
        while true do
            task.wait(1)
            
            for Model, Info in Resources do
                if not Model or not Info then continue end
            end
        end
    end)
end

function ResourceService:Init()
    -- Get all the individual resource modules

    for _, Folder in script:GetChildren() do
        if not Folder:IsA("Folder") or not string.find(Folder.Name, "Modules") then continue end
        
        for _, Module in Folder:GetChildren() do
            local TypeName = string.gsub(Folder.Name, "Modules", "")
            if not ResourceModules[TypeName] then continue end

            ResourceModules[TypeName][Module.Name] = require(Module)
        end
    end
end

function ResourceService.Deferred()
    CheckForTestMap()
end

return ResourceService