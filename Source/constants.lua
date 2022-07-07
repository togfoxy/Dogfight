constants = {}

function constants.load()
    -- constants and globals


    INITAL_NUMBER_OF_ENTITIES = 20
    BOX2D_SCALE = 5
    ECS_ENTITIES = {}
    ECS_ENTITIES_PROJECTILES = {}
    PHYSICS_ENTITIES = {}

    RADIUSMASSRATIO = 5
	VESSELS_SELECTED = 0
	FUEL_MASS = 1				-- how much mass does one unit of fuel weigh
    FUEL_LEAK = 100             -- fuel loss per second

	SELECTED_VESSEL = {}

    SIDEBAR_WIDTH = 250
    WORLD_WIDTH = SCREEN_WIDTH - SIDEBAR_WIDTH

    ZOOMFACTOR = 0.9
    TRANSLATEX = 0
    TRANSLATEY = 0

end
return constants
