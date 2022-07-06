ecsUpdate = {}



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
            local xvector = (x2 - x1) * entity.engine.force * dt     --! can adjust the force and the energy used
            local yvector = (y2 - y1) * entity.engine.force * dt
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
            if entity:has("engine") then
                entity.facing.value = getNewFacing(entity, dt)
            end
        end
    end
    ECSWORLD:addSystems(systemFacing)

    systemShooting = concord.system({
        pool = {"gun_projectile"}
    })
    function systemShooting:shooting(dt)
        for _, entity in ipairs(self.pool) do
            entity.gun_projectile.timer = entity.gun_projectile.timer - dt
            if entity.gun_projectile.timer <= 0 then
                entity.gun_projectile.timer = 4

                -- create a projectile entity
                local newEntity = fun.addProjectile(entity)
                assert(newEntity ~= nil)

                -- apply an impulse immediately

                local x,y = fun.getBodyXY(entity.uid.value)
                -- add radius + 1 in the direction of facing
                local facing = entity.facing.value
                local distance = entity.position.radius + 100
                local newx, newy = cf.AddVectorToPoint(x,y,facing,distance)

                local impulsevectorx, impulsevectory
                local scale = entity.gun_projectile.force
                impulsevectorx = (newx - x) * scale
                impulsevectory = (newy - y) * scale

                newEntity.body:applyLinearImpulse(impulsevectorx * scale, impulsevectory * scale)
                -- newEntity.body:setLinearVelocity(10000000, 10000000)
                -- newEntity.body:applyForce(impulsevectorx * scale, impulsevectory * scale)
            end
        end
    end
    ECSWORLD:addSystems(systemShooting)
end
return ecsUpdate
