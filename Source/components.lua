cmp = {}

function cmp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)

    concord.component("drawable")   -- will be drawn during love.draw()
    concord.component("isSelected") -- clicked by the mouse

	-- types of entity
    concord.component("vessel")
    concord.component("projectile", function(c)
        c.mindamage = 1
        c.maxdamage = 50
    end)
    concord.component("missile", function(d)
        c.mindamage = 50
        c.maxdamage = 200
	end)

    concord.component("position", function(c, rad)
        if rad == nil then
            c.radius = 2            -- the size of the entity
        else
            c.radius = rad
        end
    end)

    concord.component("facing", function(c, deg)
        if deg ~= nil then
            c.value = deg
            c.timer = 0         -- hold facing for this long
        else
            c.value = nil
        end
        c.desiredfacing = c.value
   end)

   concord.component("chassis", function(c, navy)
       c.mass = 100
	   c.currentmass = c.mass
       c.hitpoints = 100
       c.massCapacity = 100
       c.eConsumption = 100
       c.navy = navy or love.math.random(1,2)
   end)

   concord.component("engine", function(c, force)
       c.mass = 100
	   c.currentmass = c.mass
       c.hitpoints = 100
       c.fConsumpption = 100
       c.turnrate = 60      -- degrees
        if force == nil then
            c.force = 0     --!
        else
            c.force = force
        end
   end)

   concord.component("gun_projectile", function(c)
       c.mass = 100
       c.hitpoints = 100
       c.force = 100        -- speed of bullet
       c.ammoRemaining = 100
       c.ammoMass = 1          -- each
       c.active = true         -- set to TRUE to make it shoot
       c.timer = 0              -- frequency of shot
	   c.currentmass = c.mass + (c.ammoRemaining * c.ammoMass)
   end)

   concord.component("fueltank", function(c)
	   c.value = 5000
	   c.mass = 100
	   c.hitpoints = 100
	   c.capacity = 1000
	   c.currentmass = c.mass + (c.capacity * FUEL_MASS)
   end)

   concord.component("coreData", function(c)
	   c.currentMass = 0
       c.currentTarget = nil            -- an entity
       c.currentTargetTimer = 0
   end)

end

return cmp
