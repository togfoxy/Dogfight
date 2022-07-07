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
		local drawx = SCREEN_WIDTH - SIDEBAR_WIDTH + 10
		local drawy = 10

		love.graphics.setColor(1,1,1,1)
		love.graphics.print("Chasis hitpoint: " .. SELECTED_VESSEL.chassis.hitpoints)
		drawy = drawy + 15

		love.graphics.print("Fuel remaining: " .. SELECTED_VESSEL.fueltank.value)
		drawy = drawy + 15

		love.graphics.print("Fuel remaining: " .. SELECTED_VESSEL.coreData.currentMass)
		drawy = drawy + 15






	end
end


return draw
