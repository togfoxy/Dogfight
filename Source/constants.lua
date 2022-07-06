constants = {}

function constants.load()
    -- constants and globals


    INITAL_NUMBER_OF_ENTITIES = 20
    BOX2D_SCALE = 5
    ECS_ENTITIES = {}
    ECS_ENTITIES_PROJECTILES = {}
    PHYSICS_ENTITIES = {}

    RADIUSMASSRATIO = 5

    SIDEBAR_WIDTH = 250
    WORLD_WIDTH = SCREEN_WIDTH - SIDEBAR_WIDTH

    ZOOMFACTOR = 0.9
    TRANSLATEX = 0
    TRANSLATEY = 0

end
return constants
