cmp = {}

function cmp.init()
    -- establish all the components
    concord.component("uid", function(c)
        c.value = cf.Getuuid()
    end)

    concord.component("drawable")   -- will be drawn during love.draw()
    concord.component("isSelected") -- clicked by the mouse

     concord.component("position", function(c)
        c.radius = 10            -- the size of the entity
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

   concord.component("engine", function(c)
       c.mass = 100
       c.hitpoints = 100
       c.force = 100
       c.fConsumpption = 100
       c.turnrate = 60      -- degrees
   end)
end

return cmp
