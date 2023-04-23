local robot = require("robot")
local term = require("term")
term.write("x: ")
xDimension = term.read()
term.write("y: ")
yDimension = term.read()
term.write("z: ")
zDimension = term.read()

currentX = 0
currentY = 0
currentZ = 0

directions = { "N", "E", "S", "W" }
currentDirectionIndex = 0

function turn(isLeftTurn)
    if isLeftTurn then
        currentDirectionIndex = currentDirectionIndex - 1
        robot.turnLeft()
    else
        currentDirectionIndex = currentDirectionIndex + 1
        robot.turnRight()
    end
end

function move()
    if (directions[currentDirectionIndex % 4] == "N") then
        currentX = currentX + 1
    elseif (directions[currentDirectionIndex % 4] == "E") then
        currentY = currentY - 1
    elseif (directions[currentDirectionIndex % 4] == "S") then
        currentX = currentX - 1
    elseif (directions[currentDirectionIndex % 4] == "W") then
        currentY = currentY + 1
    end
end

turnIterator = 0

for iz = zDimension, 1, -1 do
    xTurnIterator = 0
    for iy = yDimension, 1, -1 do
        for ix = xDimension - 1, 1, -1 do
            while robot.detect() do
                robot.swing()
            end
            robot.forward()
            move()
        end

        if iy ~= 1 then
            if turnIterator % 2 == 0 then
                turn(false)
                while robot.detect() do
                    robot.swing()
                end
                robot.forward()
                move()
                turn(false)
            else
                turn(true)
                while robot.detect() do
                    robot.swing()
                end
                robot.forward()
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
end
