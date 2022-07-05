functions = {}

function functions.addEntity(dna, x, y)
    -- adds one ENTITIES to the AGENTS arrary
    -- this is not an ECS thing

    if dna == nil then dna = {} end

    local entity = concord.entity(ECSWORLD)
    :give("drawable")
    :give("position")
    :give("uid")
    :give("facing", love.math.random(0,359))
    :give("engine")
    :give("chassis")

    table.insert(ECS_ENTITIES, entity)

    local rndx = love.math.random(50, WORLD_WIDTH - 50)
    local rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy,"dynamic")
	physicsEntity.body:setLinearDamping(0.5)
	physicsEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
	physicsEntity.shape = love.physics.newCircleShape(entity.position.radius)
	physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
	physicsEntity.fixture:setRestitution(1.5)
	physicsEntity.fixture:setSensor(false)
	physicsEntity.fixture:setUserData(entity.uid.value)

    table.insert(PHYSICS_ENTITIES, physicsEntity)
end

function functions.getBody(uid)
    assert(uid ~= nil)
    for i = 1, #PHYSICS_ENTITIES do
        if PHYSICS_ENTITIES[i].fixture:getUserData() == uid then
            return PHYSICS_ENTITIES[i]
        end
    end
    return nil
end

function functions.getBodyXY(uid)
    assert(uid ~= nil)
    local physEntity = fun.getBody(uid)
    assert(physEntity ~= nil)
    return physEntity.body:getX(), physEntity.body:getY()
end

function functions.getEntity(uid)
    assert(uid ~= nil)
    for k,v in pairs(ECS_ENTITIES) do
        if v.uid.value == uid then
            return v
        end
    end
    return nil
end

return functions
