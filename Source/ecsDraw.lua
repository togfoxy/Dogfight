ecsDraw = {}

function ecsDraw.init()

    -- profiler.start()

    systemDraw = concord.system({
        pool = {"position", "drawable"}
    })
    -- define same systems
    function systemDraw:draw()
        love.graphics.setColor(1,1,0,1)
        for _, entity in ipairs(self.pool) do

            local uid = entity.uid.value
            local physEntity = fun.getBody(uid)

            local drawx = physEntity.body:getX()
            local drawy = physEntity.body:getY()
            drawx = drawx * BOX2D_SCALE
            drawy = drawy * BOX2D_SCALE

            local radius = (entity.position.radius) * BOX2D_SCALE

            local red, green, blue
            if entity:has("chassis") then
                if entity.chassis.navy == 1 then
                    red, green, blue = 1,0,0
                else
                    red, green, blue = 0,1,0
                end
            else
                if entity:has("projectile") then
                    red, green, blue = 1,1,1
                else
                    -- border
                    red, green, blue = 0,0,1
                end
            end

            love.graphics.setColor(red, green, blue, 1)
            love.graphics.circle("fill", drawx, drawy, radius)

            -- facing
            if entity:has("facing") then
                local x2, y2 = cf.AddVectorToPoint(drawx, drawy, entity.facing.value, radius)

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.line(drawx, drawy, x2, y2)
            end
            -- debug

        end
    end

    ECSWORLD:addSystems(systemDraw)
end


return ecsDraw
