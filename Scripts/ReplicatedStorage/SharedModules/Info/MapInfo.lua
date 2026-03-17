-- OmniRal

local MapInfo: {
    [string]: {
        DisplayName: string,
        Description: string,
        Icon: number,

        TreeHealth: NumberRange?,
        RockHealth: NumberRange?,
        CrystalHealth: NumberRange?,
    }
} = {}

MapInfo["TestMap"] = {
    DisplayName = "TestMap",
    Description = "This is the test map",
    Icon = 0,

    TreeHealth = NumberRange.new(70, 80),
    RockHealth = NumberRange.new(90, 100),
    CrystalHealth = NumberRange.new(120, 130)
}

return MapInfo