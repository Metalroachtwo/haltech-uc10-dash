

Config = {
    ADU1 = {},
    ADU2 = {
        -- config options for ADU2
        ShiftWarn = 80 -- % of RPM (of Limiter) when RPM Bar should turn Red
    },
    ADU3 = {
        -- config options for ADU3
        ShiftWarn = 85 -- % of RPM (of Limiter) when RPM Bar should turn Red
    }
}

sim = ac.getSim()
SmoothedAccel = {x = 0, z = 0} -- global default value definition for x and z axis of vec() car.acceleration.
SmoothedRPM = SmoothedRPM or 0
SmoothedBoost = SmoothedBoost or 0

function modeA(dt) -- first screem of the ADU, part of the switching function at the very bottom
    display.image {
        image = "assets/triplehero.dds",
        pos = vec2(0, 632), -- coordinates of top left corner
        size = vec2(2059,769)
    }
    -- gear display
    local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
    if car.gear == -1 then
        gearText = "R"
    end
    if car.gear == 0 then
        gearText = "N"
    end
    display.text {
        text = gearText,
        pos = vec2(1140, 1085),
		letter = vec2(140, 140),
		font = "mg",
		width = 46,
		alignment = 0.5,
		spacing = 0,
		color = rgbm(0, 0, 0, 1)
    }
  ---------------------------------------------------------------------------
  --  RPM NEEDLE -------------------------------------------------------------
  ---------------------------------------------------------------------------
	do
		local RPM_LIMIT      = (car.rpmLimiter > 0) and car.rpmLimiter or 7500
		SmoothedRPM = math.applyLag(SmoothedRPM, car.rpm, 0.75, dt)
		local SWEEP_DEGREES  = -270                    -- clockwise sweep
		local START_ANGLE    = -235                    -- 0 rpm position
		local NEEDLE_SIZE    = vec2(560, 560)
		local PIVOT          = vec2(1024, 1024)        -- dial centre
		local NEEDLE_POS     = PIVOT - NEEDLE_SIZE/2
		local NEEDLE_TEXTURE = "assets/RPMNeedle.dds"

		local rpmRatio = math.saturate(SmoothedRPM / RPM_LIMIT)
		local angle    = START_ANGLE + rpmRatio * SWEEP_DEGREES

		ui.beginRotation()
		display.image { image = NEEDLE_TEXTURE, pos = NEEDLE_POS, size = NEEDLE_SIZE }
		ui.endPivotRotation(angle, PIVOT)
	end

  ---------------------------------------------------------------------------
  --  SPEEDO NEEDLE (MPH) ----------------------------------------------------
  ---------------------------------------------------------------------------
	do
  local SPEED_LIMIT     = 180
  local SWEEP_DEGREES   = -270
  local START_ANGLE     = -270
  local NEEDLE_SIZE     = vec2(484, 484)
  local PIVOT           = vec2(1740, 954)
  local NEEDLE_POS      = PIVOT - NEEDLE_SIZE / 2
  local NEEDLE_TEXTURE  = "assets/RPMNeedle.dds"

  local speedMPH   = car.speedKmh * 0.621371
  local speedRatio = math.saturate(speedMPH / SPEED_LIMIT)
  local angle      = START_ANGLE + speedRatio * SWEEP_DEGREES

  ui.beginRotation()
  display.image {
    image = NEEDLE_TEXTURE,
    pos   = NEEDLE_POS,
    size  = NEEDLE_SIZE
  }
  ui.endPivotRotation(angle, PIVOT)

  -- pivot marker
  display.rect {
    pos = PIVOT - vec2(6, 6),
    size = vec2(12, 12),
    color = rgbm(1, 0, 0, 1)
  }
end
  ---------------------------------------------------------------------------
  --  MANIFOLD PRESSURE NEEDLE (BAR) ----------------------------------------
  ---------------------------------------------------------------------------
	do
		local BOOST_MIN       = 0
		local BOOST_MAX       = 22
		local SWEEP_DEGREES   = -260
		local START_ANGLE     = -270
		local NEEDLE_SIZE     = vec2(484, 484)
		local PIVOT           = vec2(325, 954)
		local NEEDLE_POS      = PIVOT - NEEDLE_SIZE / 2
		local NEEDLE_TEXTURE  = "assets/RPMNeedle.dds"
		SmoothedBoost = math.applyLag(SmoothedBoost, car.turboBoost, 1.25, dt)
		
		local rawBoost   = car.turboBoost * (BOOST_MAX - BOOST_MIN) + BOOST_MIN
		local boostRatio = math.saturate((rawBoost - BOOST_MIN) / (BOOST_MAX - BOOST_MIN))
		local angle      = START_ANGLE + boostRatio * SWEEP_DEGREES

	ui.beginRotation()
	display.image {
		image = NEEDLE_TEXTURE,
		pos   = NEEDLE_POS,
		size  = NEEDLE_SIZE
  }
  ui.endPivotRotation(angle, PIVOT)

  -- Debug dot
  display.rect {
    pos = PIVOT - vec2(6, 6),
    size = vec2(12, 12),
    color = rgbm(1, 0, 0, 1)
  }
  end
	-- numeric fuel gauge
    display.text {
        text = string.format("%.1f", car.fuel),
        pos = vec2(380,1130),
        letter = vec2(20, 60),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -2,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
    -- numeric oil pressure gauge
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(525,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
	-- numeric boost pressure gauge
    display.text {
        text = string.format("%.1f", car.turboBoost),
        pos = vec2(400,1010),
        letter = vec2(40, 90),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
  ---------------------------------------------------------------------------
  --  ODOMETER (MPH-based using speedKmh, miles, custom font and position) --
  ---------------------------------------------------------------------------
  do
    odoDistance = odoDistance or 0

    if car.speedKmh ~= nil then
      -- speedKmh * dt = distance in km
      local distanceKm = car.speedKmh * (dt / 3600)  -- dt in seconds, so divide by 3600
      odoDistance = odoDistance + distanceKm
    end

    -- convert total km to miles
    local odoMi = odoDistance * 0.621371

    display.text {
      text = string.format("%.1f", odoMi or 0),
      pos = vec2(1095, 1260),
      letter = vec2(25, 50),
      font = "mg",                     -- custom font
      width = 1,
      alignment = 1,
      spacing = -4,
      color = rgbm(0, 0, 0, 1)
    }
  end
    --numeric gforce gauges
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x, 0))), -- SmoothedAccel.xyz replaces car.acceleration.xyz, math.max() calculates the biggest value from a list of numbers, "0" prevents the displayed value from going <0
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x, 0))), -- SmoothedAccel.xyz replaces car.acceleration.xyz, math.max() calculates the biggest value from a list of numbers, "0" prevents the displayed value from going <0
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 1, 1, 1)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z * -1, 0))), -- z axis is actually forward/backward, y is up/down
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 0.5, 0, 1)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z, 0))),
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
	display.text {
		text = string.format("%.0f", car.waterTemperature),
		pos = vec2(1425,1295),
		letter = vec2(50, 100),
		font = "mg",
		width = .5,
		alignment = 0.5,
		spacing = -2.5,
		color = rgbm(0, 0, 0, 1)
	}
    -- numeric battery gauge
    display.text {
        text = string.format("%.1f", car.batteryVoltage), -- %.1f = 1 digit after comma, %.2f = 2 digits etc
        pos = vec2(1790, 1142),
        letter = vec2(20, 40),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = 0,
		color = rgbm(0, 0, 0, 1)
    }
    -- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(1760, 994), -- the leftmost digit
        vec2(1820, 994), -- the center digit
        vec2(1880, 994),
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(75,125),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    end
    -- oil pressure warning light
    if (car.oilPressure <= 1) then -- if oil pressure equals or drops below 1bar image gets displayed at defined position
        display.image {
            image = "assets/OILW.dds",
            pos = vec2(1740, 864), -- coordinates of top left corner
            size = vec2(115, 45)
        }
    end
    -- check engine light
    if (car.engineLifeLeft <= 600) then -- if engine life equals or drops below 600 life points image gets displayed, engine life is 0-1000
        display.image {
            image = "assets/ENG.dds",
            pos = vec2(1625, 854), -- coordinates of top left corner
            size = vec2(95, 55)
        }
    end
end

function modeB(dt)
    display.image {
        image = "assets/doublehero.dds",
        pos = vec2(0, 632), -- coordinates of top left corner
        size = vec2(2059,769)
    }
    -- gear display
    local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
    if car.gear == -1 then
        gearText = "R"
    end
    if car.gear == 0 then
        gearText = "N"
    end
    display.text {
        text = gearText,
        pos = vec2(1485, 1230),
		letter = vec2(80, 80),
		font = "mg",
		width = 46,
		alignment = 0.5,
		spacing = 0,
		color = rgbm(0, 0, 0, 2)
    }
  ---------------------------------------------------------------------------
  --  RPM NEEDLE -------------------------------------------------------------
  ---------------------------------------------------------------------------
	do
		local RPM_LIMIT      = (car.rpmLimiter > 0) and car.rpmLimiter or 7500
		SmoothedRPM = math.applyLag(SmoothedRPM, car.rpm, 0.75, dt)
		local SWEEP_DEGREES  = -270                    -- clockwise sweep
		local START_ANGLE    = -264                   -- 0 rpm position
		local NEEDLE_SIZE    = vec2(600, 600)
		local PIVOT          = vec2(640, 1024)        -- dial centre
		local NEEDLE_POS     = PIVOT - NEEDLE_SIZE/2
		local NEEDLE_TEXTURE = "assets/RPMNeedle.dds"

		local rpmRatio = math.saturate(SmoothedRPM / RPM_LIMIT)
		local angle    = START_ANGLE + rpmRatio * SWEEP_DEGREES

		ui.beginRotation()
		display.image { image = NEEDLE_TEXTURE, pos = NEEDLE_POS, size = NEEDLE_SIZE }
		ui.endPivotRotation(angle, PIVOT)
	end

  ---------------------------------------------------------------------------
  --  SPEEDO NEEDLE (MPH) ----------------------------------------------------
  ---------------------------------------------------------------------------
	do
  local SPEED_LIMIT     = 180
  local SWEEP_DEGREES   = -270
  local START_ANGLE     = -270
  local NEEDLE_SIZE     = vec2(600, 600)
  local PIVOT           = vec2(1420, 1024)
  local NEEDLE_POS      = PIVOT - NEEDLE_SIZE / 2
  local NEEDLE_TEXTURE  = "assets/RPMNeedle.dds"

  local speedMPH   = car.speedKmh * 0.621371
  local speedRatio = math.saturate(speedMPH / SPEED_LIMIT)
  local angle      = START_ANGLE + speedRatio * SWEEP_DEGREES

  ui.beginRotation()
  display.image {
    image = NEEDLE_TEXTURE,
    pos   = NEEDLE_POS,
    size  = NEEDLE_SIZE
  }
  ui.endPivotRotation(angle, PIVOT)

  -- pivot marker
  display.rect {
    pos = PIVOT - vec2(6, 6),
    size = vec2(12, 12),
    color = rgbm(1, 0, 0, 1)
  }
end
	-- numeric fuel gauge
    display.text {
        text = string.format("%.1f", car.fuel),
        pos = vec2(730,1230),
        letter = vec2(20, 60),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -2,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
	--numeric rpm
	display.text {
		text = string.format("%.0f", car.rpm),
		pos = vec2(760,1115),
		letter = vec2(40,60),
		font = "mg",
		width = 46,
		alignment = 1,
		spacing = 0,
		color = rgbm(0, 0, 0, 1)
	}
    -- numeric oil pressure gauge
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(1825,1215),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
	-- numeric boost pressure gauge
    display.text {
        text = string.format("%.1f", car.turboBoost),
        pos = vec2(140,730),
        letter = vec2(40, 90),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1) -- rgbm is 0-1
    }
  ---------------------------------------------------------------------------
  --  ODOMETER (MPH-based using speedKmh, miles, custom font and position) --
  ---------------------------------------------------------------------------
  do
    odoDistance = odoDistance or 0

    if car.speedKmh ~= nil then
      -- speedKmh * dt = distance in km
      local distanceKm = car.speedKmh * (dt / 3600)  -- dt in seconds, so divide by 3600
      odoDistance = odoDistance + distanceKm
    end

    -- convert total km to miles
    local odoMi = odoDistance * 0.621371

    display.text {
      text = string.format("%.1f", odoMi or 0),
      pos = vec2(1095, 1260),
      letter = vec2(25, 50),
      font = "mg",                     -- custom font
      width = 1,
      alignment = 1,
      spacing = -4,
      color = rgbm(0, 0, 0, 0)
    }
  end
    --numeric gforce gauges
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x, 0))), -- SmoothedAccel.xyz replaces car.acceleration.xyz, math.max() calculates the biggest value from a list of numbers, "0" prevents the displayed value from going <0
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 0) -- rgbm is 0-1
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.x, 0))), -- SmoothedAccel.xyz replaces car.acceleration.xyz, math.max() calculates the biggest value from a list of numbers, "0" prevents the displayed value from going <0
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 1, 1, 0)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z * -1, 0))), -- z axis is actually forward/backward, y is up/down
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(1, 0.5, 0, 0)
    }
    display.text {
        text = string.format("%.1f", (math.max(SmoothedAccel.z, 0))),
        pos = vec2(205,1285),
        letter = vec2(50, 110),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 0)
    }
	display.text {
		text = string.format("%.0f", car.waterTemperature),
		pos = vec2(1425,1295),
		letter = vec2(50, 100),
		font = "mg",
		width = .5,
		alignment = 0.5,
		spacing = -2.5,
		color = rgbm(0, 0, 0, 0)
	}
    -- numeric battery gauge
    display.text {
        text = string.format("%.1f", car.batteryVoltage), -- %.1f = 1 digit after comma, %.2f = 2 digits etc
        pos = vec2(1828, 1082),
        letter = vec2(48, 48),
        font = "mg",
        width = 46,
        alignment = 1,
        spacing = -16,
		color = rgbm(0, 0, 0, 1)
    }
    -- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(1500, 1094), -- the leftmost digit
        vec2(1540, 1094), -- the center digit
        vec2(1580, 1094),
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(78,98),
            font = "mg",
            width = 14,
            spacing = 2,
            alignment = -1.0,
			color = rgbm(0, 0, 0, 1)
        }
    end
    -- oil pressure warning light
    if (car.oilPressure <= 1) then -- if oil pressure equals or drops below 1bar image gets displayed at defined position
        display.image {
            image = "assets/OILW.dds",
            pos = vec2(1040, 1315), -- coordinates of top left corner
            size = vec2(115, 45)
        }
    end
    -- check engine light
    if (car.engineLifeLeft <= 600) then -- if engine life equals or drops below 600 life points image gets displayed, engine life is 0-1000
        display.image {
            image = "assets/ENG.dds",
            pos = vec2(925, 1310), -- coordinates of top left corner
            size = vec2(95, 55)
        }
    end
end
function modeC(dt)
	-- grey background for second screen, draws on top of mesh texture so pay attention to transparency, might need layering depending on what youre doing
    display.rect {
        pos = vec2(9, 405), 
        size = vec2(1800, 990),
        color = rgbm(0.55, 0.55, 0.55, 1)
    }
    -- rpm gauge
    local rpmPercentage = (car.rpm / 8000 * 100) -- conversion to %


    local amountOfSquares = math.ceil(rpmPercentage/6.25) -- only render the squares the user will actually see, for performance.

    local color = rgbm(1, 0.8, 0, 1) -- normal colour of the displayed rectangle
    if Config.ADU2.ShiftWarn < (car.rpm / car.rpmLimiter * 100) then -- if rpms exceed Configured Value colour switches
        color = rgbm(255, 0, 0, 255)
    end
    local rpmPos = vec2(610, 1216)
    local rpmSize = vec2(200, 200)
    local rpmPivot = vec2(1028, 1028)

    for i = 1, amountOfSquares do
        local thisRotation = (-rpmPercentage) * 2.7 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = rpmPos,
            size = rpmSize,
            color = color
        }
        ui.endRotation(28)
        if rpmPercentage > (100 / 16 * i) then
            thisRotation = -(100 / 16 * i) * 2.7
        end
        ui.endPivotRotation(thisRotation + 107, rpmPivot)
    end


    -- actual background for second screen, last in line since script runs top to bottom and transparency layer needs to be at the very top of the stack
    display.image {
        pos = vec2(0, 632), -- coordinates of top left corner
        size = vec2(2048, 786)   
	}	
	local value = math.saturate((car.oilTemperature / 140) - 0.32)
    display.rect {
        pos = vec2(1575, 526),
        size = vec2(value * 411, 71),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilTemperature),
        pos = vec2(1585, 520),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate((car.waterTemperature / 120) - 0.16)
    display.rect {
        pos = vec2(56, 527),
        size = vec2(value * 408, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.waterTemperature),
        pos = vec2(65, 522),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
    local value = math.saturate(car.oilPressure / 8)
    display.rect {
        pos = vec2(1684, 828),
        size = vec2(value * 311, 70),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
    display.text {
        text = string.format("%.1f", car.oilPressure),
        pos = vec2(1690, 822),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -10,
        color = rgbm(0, 0, 0, 1)
    }
	local value = math.saturate(car.fuel / car.maxFuel) -- in %
    display.rect {
        pos = vec2(56, 828),
        size = vec2(value * 306, 69),
        color = rgbm(1, 0.8, 0, 1),
        uvStart = vec2(0, 0),
        uvEnd = vec2(value, 1)
    }
	display.text {
        text = string.format("%.0f", car.fuel/car.maxFuel*100), -- in %
        pos = vec2(65, 822),
        letter = vec2(45, 90),
        font = "c7_new",
        width = 1,
        alignment = 1,
        spacing = -6,
        color = rgbm(0, 0, 0, 1)
    }
	 -- gear display
    local gearText = tostring(car.gear) -- needs to be converted so that neutral and reverse display correctly (-1 = R, 0 = N)
    if car.gear == -1 then
        gearText = "R"
    end
    if car.gear == 0 then
        gearText = "N"
    end
    display.text {
        text = gearText,
        pos = vec2(820, 670),
        letter = vec2(400, 730),
        font = "c7_new",
        width = 46,
        alignment = 0.5,
        spacing = 0
    }

	-- speed gauge (with formatting for correct digit positions with additional digits appearing)
    digitCoords = {
        -- define your coords here
        vec2(1530, 1470), -- the leftmost digit
        vec2(1610, 1470), -- the center digit
        vec2(1700, 1470) -- the rightmost digit
    }
    -- preparing our table of speed digits
    local displayspeed = tostring(math.floor(car.poweredWheelsSpeed)) -- math.floor rounds to the next full number
    local speedTable = {}
    for i = 1, string.len(displayspeed) do
        speedTable[i] = displayspeed:sub(i, i)
    end
    if string.len(displayspeed) == 1 then
        display.text {
            -- rightmost digit
            text = speedTable[1],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 2 then
        display.text {
            -- rightmost digit
            text = speedTable[2],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[1],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    elseif string.len(displayspeed) == 3 then
        display.text {
            -- rightmost digit
            text = speedTable[3],
            pos = digitCoords[3],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- center digit
            text = speedTable[2],
            pos = digitCoords[2],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
        display.text {
            -- leftmost digit
            text = speedTable[1],
            pos = digitCoords[1],
            letter = vec2(100, 200),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = -1.0,
            color = rgbm(0, 0, 0, 1)
        }
    end
		digitCoords = {
        -- define your coords here
        vec2(755, 1260), --left quad
        vec2(815, 1260), --left triple
        vec2(875, 1260), --left dual
        vec2(935, 1260), --center
        vec2(995, 1260), --right dual
        vec2(1055, 1260),--right triple    
        vec2(1115, 1260) --right quad
    }
    -- preparing our table of rpm digits
    local displayrpm = tostring(math.floor(car.rpm))
    local rpmTable = {}
    for i = 1, string.len(displayrpm) do
        rpmTable[i] = displayrpm:sub(i, i)
    end
    if string.len(displayrpm) == 1 then
        display.text {
            -- rightmost digit
            text = rpmTable[1],
            pos = digitCoords[4],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 2 then
        display.text {
            -- rightmost digit
            text = rpmTable[2],
            pos = digitCoords[5],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[3],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 3 then
        display.text {
            -- rightmost digit
            text = rpmTable[3],
            pos = digitCoords[6],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- center digit
            text = rpmTable[2],
            pos = digitCoords[4],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[2],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    elseif string.len(displayrpm) == 4 then
        display.text {
            -- rightmost digit
            text = rpmTable[4],
            pos = digitCoords[7],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- center digit
            text = rpmTable[3],
            pos = digitCoords[5],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[2],
            pos = digitCoords[3],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
        display.text {
            -- leftmost digit
            text = rpmTable[1],
            pos = digitCoords[1],
            letter = vec2(145, 240),
            font = "c7_new",
            width = 16,
            spacing = 0,
            alignment = 1.0
        }
    end
		display.text {
			text = string.format("%02d:%02d:%02d", sim.timeHours, sim.timeMinutes, sim.timeSeconds),
			pos = vec2(95, 1494),
			letter = vec2(65, 160),
			font = "c7_new",
			width = 1,
			alignment = 0.5,
			spacing = -10,
			color = rgbm(0,0,0,1)
    }
	 -- check engine light
    if (car.engineLifeLeft <= 600) then -- if engine life equals or drops below 600 life points image gets displayed, engine life is 0-1000
        display.image {
            image = "assets/ENG.dds",
            pos = vec2(57, 1320), -- coordinates of top left corner
            size = vec2(180, 125)
        }
    end
	
	 if (car.batteryVoltage <= 9) then
        display.image {
            image = "assets/BATTERYW.dds",
            pos = vec2(1817, 1324), -- coordinates of top left corner
            size = vec2(150, 113)
        }
    end
end	

-- didplay switch
local listOfModes = {modeA, modeB, modeC} -- you can add infinite displays, their elements need to be inside function modeN(dt)
local currentMode = tonumber(ac.loadDisplayValue("displayMode", 1))
local lastExtraJState = false


refreshRate = 0.02222 -- 45 fps
curDelta = 0

function update(dt)
    ac.debug("Update Delta", dt)
    curDelta = curDelta+dt
	if (curDelta <= refreshRate) then
		return false
	elseif (curDelta >= refreshRate) then
		curDelta = 0
	end

    if car.extraJ ~= lastExtraJState then -- switching is bound to extraC key, this tracks the state of extraC
        currentMode = currentMode + 1 -- you start at mode 1 and each extraC press adds +1 to the mode count
        if currentMode > #listOfModes then -- as soon as your mode counter exceeds the number of modes inside listOfModes it defaults back to mode 1
            currentMode = 1 -- should be the same as local currentMode =
        end
        ac.saveDisplayValue("displayMode", currentMode)
    end
    ac.debug("Current Page", currentMode)
    lastExtraJState = car.extraJ
    listOfModes[currentMode](dt)
end
