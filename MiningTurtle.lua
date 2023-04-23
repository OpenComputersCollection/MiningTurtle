local robot = require("robot")
local term = require("term")
local computer = require("computer")
term.write("x: ")
xDimension = term.read()
term.write("y: ")
yDimension = term.read()
term.write("z: ")
zDimension = term.read()

currentX = 0
currentY = 0
currentZ = 0
currentlyReturning = false

directions = { "N", "E", "S", "W" }
currentDirectionIndex = 0

function deepCopy(x)
    return x
end

function turn(isLeftTurn)
    if isLeftTurn then
        currentDirectionIndex = currentDirectionIndex - 1
        robot.turnLeft()
    else
        currentDirectionIndex = currentDirectionIndex + 1
        robot.turnRight()
    end
end

function shouldReturn()
    local totalEnergy = computer.maxEnergy()
    local currentEnergy = computer.energy()
    local energyPercentage = (currentEnergy / totalEnergy) * 100

    if energyPercentage < 10 then
        return true
    end

    local isInventoryFull = true
    for i = 1, robot.inventorySize() do
        if robot.count(i) == 0 then
            isInventoryFull = false
            break
        end
    end

    return isInventoryFull
end

function move()
    robot.forward()
    if (directions[(currentDirectionIndex % 4)+1] == "N") then
        currentX = currentX + 1
    elseif (directions[(currentDirectionIndex % 4)+1] == "E") then
        currentY = currentY + 1
    elseif (directions[(currentDirectionIndex % 4)+1] == "S") then
        currentX = currentX - 1
    elseif (directions[(currentDirectionIndex % 4)+1] == "W") then
        currentY = currentY - 1
    end

    if (not currentlyReturning) and shouldReturn() then
        currentlyReturning = true
        local lastMiningX = deepCopy(currentX)
        local lastMiningY = deepCopy(currentY)
        local lastMiningZ = deepCopy(currentZ)
        local lastDirection = deepCopy(currentDirectionIndex)
        returnToOrigin()
        returnToLastMiningPosition(lastMiningX, lastMiningY, lastMiningZ, lastDirection)
        currentlyReturning = false
    end
end

function dropItems()
    for i = 1, robot.inventorySize() do
        robot.select(i)
        robot.drop()
    end
end

function returnToOrigin()

    while currentZ ~= 0 do
        while robot.detectUp() do
            robot.swingUp()
        end
        robot.up()
        currentZ = currentZ - 1
    end

    while directions[(currentDirectionIndex % 4)+1] ~= "W" do
        turn(false)
    end

    while currentY ~= 0 do
        while robot.detect() do
            robot.swing()
        end
        move()
    end

    turn(true)

    while currentX ~= 0 do
        while robot.detect() do
            robot.swing()
        end
        move()
    end

    dropItems()

    turn(false)
    turn(false)
end

function returnToLastMiningPosition(lastMiningX, lastMiningY, lastMiningZ, lastDirection)
    while currentX ~= lastMiningX do
        while robot.detect() do
            robot.swing()
        end
        move()
    end

    turn(false)

    while currentY ~= lastMiningY do
        while robot.detect() do
            robot.swing()
        end
        move()
    end

    while currentZ ~= lastMiningZ do
        while robot.detectDown() do
            robot.swingDown()
        end
        robot.down()
        currentZ = currentZ + 1
    end

    while currentDirectionIndex % 4 ~= lastDirection % 4 do
        turn(false)
    end
end

turnIterator = 0

for iz = zDimension, 1, -1 do
    for iy = yDimension, 1, -1 do
        for ix = xDimension - 1, 1, -1 do
            while robot.detect() do
                robot.swing()
            end
            move()
        end

        if iy ~= 1 then
            if turnIterator % 2 == 0 then
                turn(false)
                while robot.detect() do
                    robot.swing()
                end
                move()
                turn(false)
            else
                turn(true)
                while robot.detect() do
                    robot.swing()
                end
                move()
                turn(true)
            end
        end
        turnIterator = turnIterator + 1
    end

    if iz ~= 1 then
        while robot.detectDown() do
            robot.swingDown()
        end
        robot.down()
        currentZ = currentZ + 1
        turn(true)
        turn(true)
    end

    if currentY == 0 and currentX == 0 then
        turnIterator = 0
    elseif currentY ~= 0 and currentX == 0 then
        turnIterator = 1
    elseif currentY == 0 and currentX ~= 0 then
        turnIterator = 1
    else
        turnIterator = 0
    end
end

returnToOrigin()