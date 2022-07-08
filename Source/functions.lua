functions = {}

function functions.addEntity(navy)
    -- adds one ENTITIES to the AGENTS arrary

    local entity = concord.entity(ECSWORLD)
    :give("uid")
	:give("coreData")
    :give("vessel")
    :give("drawable")
    :give("position", 2)
    :give("facing", love.math.random(0,359))
    :give("engine")
	:give("fueltank")
    :give("chassis", navy)
    :give("gun_projectile")
    -- :give("target")     -- can select targets (enemy vessels)

	entity.coreData.currentMass = entity.engine.currentmass + entity.fueltank.currentmass + entity.chassis.currentmass + entity.gun_projectile.currentmass

    table.insert(ECS_ENTITIES, entity)

    local rndx = love.math.random(50, WORLD_WIDTH - 50)
    local rndy = love.math.random(50, SCREEN_HEIGHT - 50)
    local rndx = rndx / BOX2D_SCALE
    local rndy = rndy / BOX2D_SCALE
    local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, rndx, rndy,"dynamic")
	physicsEntity.body:setLinearDamping(0)
	physicsEntity.body:setMass(RADIUSMASSRATIO * entity.position.radius)
	--! physicsEntity.body:setMass(entity.coreData.currentMass)
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
    physicsEntity.shape = love.physics.newCircleShape(1)		-- don't use entity.position.radius for projectiles
    physicsEntity.fixture = love.physics.newFixture(physicsEntity.body, physicsEntity.shape, 1)		-- the 1 is the density
    physicsEntity.fixture:setRestitution(0)
    physicsEntity.fixture:setSensor(false)
    physicsEntity.fixture:setUserData(entity.uid.value)

    table.insert(PHYSICS_ENTITIES, physicsEntity)
    return physicsEntity        -- return this one entity so it can be manipulated on return
end

function functions.addMissile(parentEntity)
    -- parent entity is the shooter creating this entity
    local entity = concord.entity(ECSWORLD)
	:give("coreData")		-- core data tracks things like fuel, electricty and oxygen that changes over time
    :give("projectile")
    :give("drawable")
    :give("position", 0.75)		-- radius
    :give("uid")
	:give("engine")
	:give("fueltank")
    :give("missile")
	:give("facing", parentEntity.facing.value)

	table.insert(ECS_ENTITIES, entity)

	-- parent x/y
    local x,y = fun.getBodyXY(parentEntity.uid.value)
    -- add radius + 1 in the direction of facing
    local facing = parentEntity.facing.value
    local distance = parentEntity.position.radius + 3
    local newx, newy = cf.AddVectorToPoint(x,y,facing,distance)

	local physicsEntity = {}
    physicsEntity.body = love.physics.newBody(PHYSICSWORLD, newx, newy, "dynamic")
    physicsEntity.body:setLinearDamping(0)
    physicsEntity.body:setMass(3)		--! tweak
    physicsEntity.shape = love.physics.newCircleShape(entity.position.radius)
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
    -- print("Entity removed.")

    -- unit test
    assert(#ECS_ENTITIES < ecsOrigsize)
    assert(#PHYSICS_ENTITIES < physicsOrigsize)
end

function functions.getBody(uid)
	-- returns physical body
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
    -- returns BOX2d coordinates
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
    local potentialtargets = {}
    local comp = {}
    local totalmass = 0
    if victim:has("chassis") then
        comp = {}
		comp.name = "chassis"
        comp.mass = victim.chassis.currentmass
		comp.hitpoints = victim.chassis.hitpoints
		table.insert(potentialtargets, comp)
		totalmass = totalmass + victim.chassis.currentmass
    end
    if victim:has("engine") then
        comp = {}
		comp.name = "engine"
        comp.mass = victim.engine.currentmass
		comp.hitpoints = victim.engine.hitpoints
		table.insert(potentialtargets, comp)
		totalmass = totalmass + victim.chassis.currentmass
    end
    if victim:has("gun_projectile") then
        comp = {}
		comp.name = "gun_projectile"
        comp.mass = victim.gun_projectile.currentmass
		comp.hitpoints = victim.gun_projectile.hitpoints
		table.insert(potentialtargets, comp)
		totalmass = totalmass + victim.gun_projectile.currentmass
    end
    if victim:has("fueltank") then
        comp = {}
        comp.name = "fueltank"
        comp.mass = victim.fueltank.currentmass
        comp.hitpoints = victim.fueltank.hitpoints
        table.insert(potentialtargets, comp)
        totalmass = totalmass + victim.fueltank.currentmass
    end

	local rndnum = love.math.random(1, totalmass)
	for k, comp in pairs(potentialtargets) do
		if rndnum <= comp.mass then
			-- found a target component
			--! apply damage
			compname = comp.name

			--victim[compname]["hitpoints"] = victim.[compname]["hitpoints"] - damageinflicted
			-- if victim[compname].hitpoints <= 0 then victim.[compname].hitpoints = 0 end

            if compname == "chassis" then
                victim.chassis.hitpoints = victim.chassis.hitpoints - damageinflicted
                if victim.chassis.hitpoints <= 0 then victim.chassis.hitpoints = 0 end
            end
            if compname == "engine" then
                victim.engine.hitpoints = victim.engine.hitpoints - damageinflicted
                if victim.engine.hitpoints <= 0 then victim.engine.hitpoints end
            end
            if compname == "gun_projectile" then
                victim.gun_projectile.hitpoints = victim.gun_projectile.hitpoints - damageinflicted
                if victim.gun_projectile.hitpoints <= 0 then victim.gun_projectile.hitpoints = 0 end
            end
            if compname == "fueltank" then
                victim.fueltank.hitpoints = victim.fueltank.hitpoints - damageinflicted
                if victim.fueltank.hitpoints <= 0 then  victim.fueltank.hitpoints = 0 end
            end
			break
		else
			rndnum = rndnum - comp.mass
		end
	end

end

function functions.updateCurrentMass()
	-- cycle through the entities and recalculate mass
    --!
end

function functions.checkForKills()
    for k, entity in pairs(ECS_ENTITIES) do
        if entity:has("vessel") then
            if entity.chassis.hitpoints <= 0 then
                -- boom
                fun.killEntity(entity)
                print("Entity explodes")

				--! add animation to queue

            end
        end
    end
end

function functions.determineCombatOutcome(entity1, entity2)

	local combatoutcomes = {}
	-- row = enitity1; col = entity2
	-- 0 means no damage; 1 means the entity1 takes damage; 2 means entity2 takes damage

	--     v   p
	-- v   0   1
	-- p   2   0
	combatoutcomes[1] = {0, 1}		-- row 1 = vessel
	combatoutcomes[2] = {2, 0}		-- row 2 = projectile

	local row, col
	if entity1:has("vessel") then
		row = 1
	elseif entity1:has("projectile") then
		row = 2
	else
		error()
	end
	if entity2:has("vessel") then
		col = 1
	elseif entity2:has("projectile") then
		col = 2
	else
		print(entity1isborder, entity2isborder)
		error()
	end
	local combatresult = combatoutcomes[row][col]

	if combatresult == 0 then
		-- do nothing
	elseif combatresult == 1 then
		-- entity1 takes damage
		fun.damageEntity(entity1, entity2)		-- entity1 is damaged by entity2
		-- destroy the ordinance
		fun.killEntity(entity2)
	elseif combatresult == 2 then
		-- entity2 takes damage
		fun.damageEntity(entity2, entity1)		-- entity2 is damaged by entity1
		-- destroy the ordinance
		fun.killEntity(entity1)
	else
		error()
	end
end

return functions
