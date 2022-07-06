cmp = {}

function cmp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)

    concord.component("drawable")   -- will be drawn during love.draw()
    concord.component("isSelected") -- clicked by the mouse
    concord.component("vessel")
    concord.component("projectile", function(c)
        c.mindamage = 1
        c.maxdamage = 200
    end)
    concord.component("missile")

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

   concord.component("chassis", function(c)
       c.mass = 100
       c.hitpoints = 100
       c.massCapacity = 100
       c.eConsumption = 100
       c.navy = love.math.random(1,2)
   end)

   concord.component("engine", function(c, force)
       c.mass = 100
       c.hitpoints = 100
       c.fConsumpption = 100
       c.turnrate = 60      -- degrees
        if force == nil then
            c.force = 100
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
   end)

end

return cmp
