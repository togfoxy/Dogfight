ecsUpdate = {}

local function killEntity(entity)
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

local function getNewFacing(entity, dt)

    -- turn if necessary
    local newheading
    local steeringamount = entity.engine.turnrate
    local currentfacing = entity.facing.value
    local desiredfacing = entity.facing.desiredfacing

    local angledelta
    local adjustment


    -- determine if cheaper to turn left or right
    local leftdistance = currentfacing - desiredfacing
    if leftdistance < 0 then leftdistance = 360 + leftdistance end      -- this is '+' because leftdistance is a negative value

    local rightdistance = desiredfacing - currentfacing
    if rightdistance < 0 then rightdistance = 360 + rightdistance end   -- this is '+' because leftdistance is a negative value

    if leftdistance < rightdistance then
        -- turning left/anti-clockwise
        angledelta = leftdistance
        adjustment = math.min(math.abs(angledelta), steeringamount)
        adjustment = adjustment * dt
        newheading = currentfacing - (adjustment)
    else
        -- turn right/clockwise
        angledelta = rightdistance
        adjustment = math.min(math.abs(angledelta), steeringamount)
        adjustment = adjustment * dt
        newheading = currentfacing + (adjustment)
    end

    if newheading < 0 then newheading = 360 + newheading end
    if newheading > 359 then newheading = newheading - 360 end

    return newheading
end


function ecsUpdate.init()

    systemPosition = concord.system({
        pool = {"position"}
    })
    function systemPosition:update(dt)
        for _, entity in ipairs(self.pool) do

            -- update the physics mass to whatever the radius is now
            -- local newmass = (RADIUSMASSRATIO * entity.position.radius)
            -- local physEntity = fun.getBody(entity.uid.value)
            -- physEntity.body:setMass(newmass)

            -- NOTE: ensure this happens last to avoid operations on a nil value
            -- kill things
        end
    end
    ECSWORLD:addSystems(systemPosition)

    systemEngine = concord.system({
        pool = {"engine"}
    })
    function systemEngine:engines(dt)
        for _, entity in ipairs(self.pool) do
            local facing = entity.facing.value       -- 0 -> 359
            local vectordistance = 5000 * dt
            local x1,y1 = fun.getBodyXY(entity.uid.value)
            local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
            local xvector = (x2 - x1) * 100000 * dt     --! can adjust the force and the energy used
            local yvector = (y2 - y1) * 100000 * dt
            local physEntity = fun.getBody(entity.uid.value)
            physEntity.body:applyForce(xvector, yvector)
        end
    end
    ECSWORLD:addSystems(systemEngine)

    systemFacing = concord.system({
        pool = {"facing"}
    })
    function systemFacing:facing(dt)
        for _, entity in ipairs(self.pool) do
            entity.facing.timer = entity.facing.timer - dt
            if entity.facing.timer <= 0 then
                -- new desired facing
                entity.facing.desiredfacing = love.math.random(0,359)
                entity.facing.timer = 5     -- seconds
            end
            entity.facing.value = getNewFacing(entity, dt)
        end
    end
    ECSWORLD:addSystems(systemFacing)
end
return ecsUpdate
