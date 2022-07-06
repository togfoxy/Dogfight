functions = {}

function functions.addEntity()
    -- adds one ENTITIES to the AGENTS arrary

    local entity = concord.entity(ECSWORLD)
    :give("vessel")
    :give("drawable")
    :give("position", 2)
    :give("uid")
    :give("facing", love.math.random(0,359))
    :give("engine")
    :give("chassis")
    :give("gun_projectile")

    table.insert(ECS_ENTITIES, entity)

    local rndx = love.math.random(50, WORLD_WIDTH - 50)
    local rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    local rndx = rndx / BOX2D_SCALE
    local rndy = rndy / BOX2D_SCALE
    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy,"dynamic")
	physicsEntity.body:setLinearDamping(0)
	physicsEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
	physicsEntity.shape = love.physics.newCircleShape(entity.position.radius)
	physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
	physicsEntity.fixture:setRestitution(0)
	physicsEntity.fixture:setSensor(false)
	physicsEntity.fixture:setUserData(entity.uid.value)

    table.insert(PHYSICS_ENTITIES, physicsEntity)
end

function functions.addProjectile(parentEntity)
    -- parent entity is the shooter creating this entity
    local entity = concord.entity(ECSWORLD)
    :give("projectile")
    :give("drawable")
    :give("position", 0.25)
    :give("uid")
    :give("projectile")

    table.insert(ECS_ENTITIES, entity)

    assert(entity.uid.value ~= nil)

    -- add the physical object
    -- get the spawn point

    -- parent x/y
    local x,y = fun.getBodyXY(parentEntity.uid.value)
    -- add radius + 1 in the direction of facing
    local facing = parentEntity.facing.value
    local distance = parentEntity.position.radius + 2
    local newx, newy = cf.AddVectorToPoint(x,y,facing,distance)

    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, newx, newy, "dynamic")
    physicsEntity.body:setLinearDamping(0)
    physicsEntity.body:setMass(1)
    physicsEntity.shape = love.physics.newCircleShape(1)
    physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
    physicsEntity.fixture:setRestitution(0)
    physicsEntity.fixture:setSensor(false)
    physicsEntity.fixture:setUserData(entity.uid.value)

    table.insert(PHYSICS_ENTITIES, physicsEntity)
    return physicsEntity        -- return this one entity so it can be manipulated on return
end

function functions.killEntity(entity)
    -- unit test
    local ecsOrigsize = #ECS_ENTITIES
    local physicsOrigsize = #PHYSICS_ENTITIES
    --

    -- destroy the body then remove empty body from the array
    for i = 1, #PHYSICS_ENTITIES do
        if PHYSICS_ENTITIES[i].fixture:getUserData() == entity.uid.value then     --!
            PHYSICS_ENTITIES[i].body:destroy()
            table.remove(PHYSICS_ENTITIES, i)
            break
        end
    end

    -- remove the entity from the arrary
    for i = 1, #ECS_ENTITIES do
        if ECS_ENTITIES[i] == entity then
            table.remove(ECS_ENTITIES, i)
            break
        end
    end

    -- destroy the entity
    entity:destroy()
    print("Entity removed.")

    -- unit test
    assert(#ECS_ENTITIES < ecsOrigsize)
    assert(#PHYSICS_ENTITIES < physicsOrigsize)
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
    -- retuns the x and y of the body with the provided uid
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

function functions.damageEntity(victim, ordinance)
    -- the victime (ecs entity) is damaged by ordinance (ecs entity)

    local damageinflicted
    if ordinance:has("projectile") then
        damageinflicted = love.math.random(ordinance.projectile.mindamage, ordinance.projectile.maxdamage)
    elseif ordinance:has("missile") then
        damageinflicted = love.math.random(ordinance.missile.mindamage, ordinance.missile.maxdamage)
    end

    -- choose a random component
    local allcomponents = victim:getComponents()
    --print(inspect(allcomponents))
    --print("``````````````````")
    for k, v in pairs(victim:getComponents()) do
        print("Name: " .. v.__name)
        if v.hitpoints ~= nil then
            print("Hitpoints: " .. v.hitpoints)
        end
        -- print(inspect(v))
        print("------------")
    end

    error()

end

return functions
