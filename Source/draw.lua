draw = {}

function draw.HUD()

	-- draw sidebar
    local drawx = SCREEN_WIDTH - SIDEBAR_WIDTH
    local drawy = 0
    local drawwidth = SIDEBAR_WIDTH
    local drawheight = SCREEN_HEIGHT

    love.graphics.setColor(174/255, 174/255, 174/255, 0.8)
    love.graphics.rectangle("fill", drawx, drawy, drawwidth, drawheight)

	-- draw sidebar contents
	if VESSELS_SELECTED == 1 then
		local drawx = WORLD_WIDTH + 10
		local drawy = 10

		love.graphics.setColor(1,1,1,1)

        love.graphics.print("Vessel mass: " .. SELECTED_VESSEL.coreData.currentMass, drawx, drawy)
		drawy = drawy + 15

        love.graphics.print("Fuel remaining: " .. cf.round(SELECTED_VESSEL.fueltank.value), drawx, drawy)
		drawy = drawy + 15

        love.graphics.print("Bullets remaining: " .. cf.round(SELECTED_VESSEL.gun_projectile.ammoRemaining), drawx, drawy)
		drawy = drawy + 15

        if SELECTED_VESSEL.coreData.distanceToTarget ~= nil then
            love.graphics.print("Distance to target: " .. cf.round(SELECTED_VESSEL.coreData.distanceToTarget), drawx, drawy)
            drawy = drawy + 15
        end


        love.graphics.print("=====", drawx, drawy)
        drawy = drawy + 15

		love.graphics.print("Chasis hitpoints: " .. SELECTED_VESSEL.chassis.hitpoints, drawx, drawy)
		drawy = drawy + 15

        love.graphics.print("Engine hitpoints: " .. SELECTED_VESSEL.engine.hitpoints, drawx, drawy)
		drawy = drawy + 15

        love.graphics.print("Gun hitpoints: " .. SELECTED_VESSEL.gun_projectile.hitpoints, drawx, drawy)
		drawy = drawy + 15

        love.graphics.print("Fuel tank hitpoints: " .. SELECTED_VESSEL.fueltank.hitpoints, drawx, drawy)
		drawy = drawy + 15





	end
end


return draw
