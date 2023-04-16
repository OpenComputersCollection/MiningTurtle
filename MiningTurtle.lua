local robot = require("robot")
local term = require("term")
term.write("x: ")
xDimension = term.read()
term.write("y: ")
yDimension = term.read()
term.write("z: ")
zDimension = term.read()

turnIterator = 0

for iz = zDimension, 1, -1 do
    for iy = yDimension, 1, -1 do
        for ix = xDimension-1, 1, -1 do
            robot.swing()
            robot.forward()
        end
        if iy ~= 1 then
            if turnIterator % 2 == 0 then
                robot.turnRight()
                robot.swing()
                robot.forward()
                robot.turnRight()
            else
                robot.turnLeft()
                robot.swing()
                robot.forward()
                robot.turnLeft()
            end
        end
        turnIterator = turnIterator + 1
    end
    if iz % 2 == 0 then
        turnIterator = 1
    else
        turnIterator = 0
    end
    if iz ~= 1 then
        robot.swingDown()
        robot.down()
        robot.turnAround()
    end
end
