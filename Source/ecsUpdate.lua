ecsUpdate = {}

local function getNewFacing(entity, dt)

    -- turn if necessary
    local newheading
    local steeringamount = entity.engine.turnrate
    local currentfacing = entity.facing.value
    local desiredfacing = entity.facing.desiredfacing or love.math.random(0, 359)

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

local function getNewTarget(entity)
    local newtarget
    local x, y = fun.getBodyXY(entity.uid.value)
    local facing = entity.facing.value
    local x1, y1 = cf.AddVectorToPoint(x,y,facing,5)
    local deltax1 = x1 - x
    local deltay1 = y1 - y
    for k, targetentity in pairs(ECS_ENTITIES) do
        if targetentity:has("vessel") then
            if targetentity.chassis.navy ~= entity.chassis.navy then
                local targetx, targety = fun.getBodyXY(targetentity.uid.value)
                local deltatargetx = targetx - x	-- the dot product assumes the same origin so need to translate
                local deltatargety = targety - y

                local dotv = cf.dotVectors(deltax1, deltay1, deltatargetx, deltatargety)

                if dotv > 0 then
                    -- target is in front of entity
                    return targetentity
                else
                end
            end
        end
    end
    return nil      -- no target found
end

local function getNewDesiredFacing(entity, dt)

    if entity:has("coreData") then
        if entity.coreData.currentTarget == nil or entity.coreData.currentTargetTimer <= 0 then
            -- find a new target
            entity.coreData.currentTarget = getNewTarget(entity)
            if entity.coreData.currentTarget ~= nil then
                entity.coreData.currentTargetTimer = 3
            else
                -- no target
            end
        end

        if entity.coreData.currentTarget ~= nil then
            -- turn towards target
            entity.coreData.currentTargetTimer = entity.coreData.currentTargetTimer - dt
            local x1, y1 = fun.getBodyXY(entity.uid.value)            -- box2d coordinates
            local x2, y2 = fun.getBodyXY(entity.coreData.currentTarget.uid.value)
            if x2 ~= nil then
                local newheading = cf.getBearing(x1, y1, x2, y2)
                -- print("Desired heading is " .. newheading)
                return newheading
            else
                return love.math.random(0, 359)
            end
        else
            -- no target. Turn to random bearing
            -- print("Desired heading is random")
            return love.math.random(0, 359)
        end
    else
        error()
    end
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
			if entity.engine.hitpoints > 0 then
				if entity:has("fueltank") then
					if entity.fueltank.value > 0 then
						local facing = entity.facing.value       -- 0 -> 359
						local vectordistance = 5000 * dt
						local x1,y1 = fun.getBodyXY(entity.uid.value)
						local x2, y2 = cf.AddVectorToPoint(x1, y1, facing, vectordistance)
						local xvector = (x2 - x1) * entity.engine.force * dt
						local yvector = (y2 - y1) * entity.engine.force * dt
						local physEntity = fun.getBody(entity.uid.value)
						physEntity.body:applyForce(xvector, yvector)

						local fuelused = entity.engine.force * dt
						entity.fueltank.value = entity.fueltank.value - fuelused
						entity.coreData.currentMass = entity.coreData.currentMass - (fuelused * FUEL_MASS)
						if entity.coreData.currentMass < 0 then entity.coreData.currentMass = 0 end

                        if entity.fueltank.hitpoints <= 0 then
                            -- leak fuel
                            entity.fueltank.value = entity.fueltank.value - FUEL_LEAK * dt
                            entity.coreData.currentMass = entity.coreData.currentMass - ((FUEL_LEAK * dt) * FUEL_MASS)
                            if entity.coreData.currentMass < 0 then entity.coreData.currentMass = 0 end
                        end
					end
				else
					error("Engine with no fuel tank = impossible!")
				end
			end
        end
    end
    ECSWORLD:addSystems(systemEngine)

    systemFacing = concord.system({
        pool = {"facing"}
    })
    function systemFacing:facing(dt)
        for _, entity in ipairs(self.pool) do
            entity.facing.timer = entity.facing.timer - dt
            if entity.facing.timer <= 0  or entity.facing.desiredfacing == nil then
                -- new desired facing
                entity.facing.desiredfacing = getNewDesiredFacing(entity, dt)       -- turns towards target (if there is one)
                entity.facing.timer = 1     -- seconds
            end
            if entity:has("engine") then
                entity.facing.value = getNewFacing(entity, dt)      -- turns to desired facing as fast as rate allows
            end
        end
    end
    ECSWORLD:addSystems(systemFacing)

    systemShooting = concord.system({
        pool = {"gun_projectile"}
    })
    function systemShooting:shooting(dt)
        for _, entity in ipairs(self.pool) do
            if entity.coreData.currentTarget ~= nil then
                local x,y = fun.getBodyXY(entity.uid.value)
                local facing = entity.facing.value
                local x2, y2 = fun.getBodyXY(entity.coreData.currentTarget.uid.value)
                if x2 ~= nil then
                    if cf.isInFront(x, y, facing, x2, y2) then
                        entity.gun_projectile.timer = entity.gun_projectile.timer - dt      --! change this if adding more weapons
                        if entity.gun_projectile.timer <= 0 then
                            if entity.gun_projectile.hitpoints > 0 then
    			                if entity.gun_projectile.ammoRemaining > 0 then
            						entity.gun_projectile.timer = 1

                                    -- create a projectile entity
            						local newEntity = fun.addProjectile(entity)
            						assert(newEntity ~= nil)

            						-- apply an impulse immediately
            						-- add radius + 1 in the direction of facing
            						local facing = entity.facing.value
            						local distance = entity.position.radius + 100     -- 100 is arbitrary value
            						local newx, newy = cf.AddVectorToPoint(x,y,facing,distance)

            						local impulsevectorx, impulsevectory
            						local scale = entity.gun_projectile.force
            						impulsevectorx = (newx - x) * scale
            						impulsevectory = (newy - y) * scale

            						newEntity.body:applyLinearImpulse(impulsevectorx * scale, impulsevectory * scale)
            						-- newEntity.body:setLinearVelocity(10000000, 10000000)
            						-- newEntity.body:applyForce(impulsevectorx * scale, impulsevectory * scale)

            						-- reduce mass through use of ammo
            						local ammoused = 1
            						entity.gun_projectile.ammoRemaining = entity.gun_projectile.ammoRemaining - ammoused
            						entity.coreData.currentMass = entity.coreData.currentMass - (ammoused * entity.gun_projectile.ammoMass)
            						if entity.coreData.currentMass < 0 then entity.coreData.currentMass = 0 end
            					end
            				end
                        end
                    end
                end
            end
        end
    end
    ECSWORLD:addSystems(systemShooting)

	systemcoreData = concord.system({
		pool = {"coreData"}
	})
	function systemcoreData:coreData(dt)
		for _, entity in ipairs(self.pool) do

			-- update physics mass with core data mass
			-- local physEntity = fun.getBody(entity.uid.value)
			-- physEntity.body:setMass(entity.coreData.currentMass)
		end
	end
	ECSWORLD:addSystems(systemcoreData)

--     systemtargetEntity = concord.system({
--         pool = {"target"}
--     })
--     function systemtargetEntity:target(dt)
--         -- assign a target if no target is assigned
--         for _, entity in ipairs(self.pool) do
--             if entity.target.timer <= 0 or not entity:has("target") then
--                 -- find a new target
--                 local newtarget
--                 local x1, y1 = fun.getBodyXY(entity.uid.value)
--                 for k, targetentity in pairs(ECS_ENTITIES) do
--                     if targetentity:has("vessel") then
--                         if targetentity.chassis.navy ~= entity.chassis.navy then
--                 			local targetx, targety = fun.getBodyXY(targetentity.uid.value)
--                 			local deltatargetx = targetx - x	-- the dot product assumes the same origin so need to translate
--                 			local deltatargety = targety - y
--                 			local dotv = cf.dotVectors(x1,x2, deltatargetx, deltatargety)
--                 			if dotv > 0 then
--                 				-- target is in front of entity
--                                 entity.target.targetEntity = targetentity
--                                 entity.target.timer = 5
-- print("target aquired")
--                                 return
--                             end
--                         end
--                     end
--                 end
--
--                 -- reaching this point means no forward target was discovered. Execute a random turn
--                 entity:remove("target")
--                 if entity:has("facing") then
--                     local rndnum = 180 + love.math.random(0,180)        -- this is a delta, not absolute
--                     entity.facing.desiredfacing = cf.adjustHeading(entity.facing.value, rndnum)
--                     entity.facing.timer = 5     -- seconds
--                 end
--             else
--                 entity.target.timer = entity.target.timer - dt
--             end
--         end
--     end
--     ECSWORLD:addSystems(systemtargetEntity)

end
return ecsUpdate
