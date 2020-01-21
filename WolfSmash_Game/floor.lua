-- Class Floor
Floor = {}
Floor.__index = Floor

function newFloor(tag, world, posX, posY, width, height, friction)
    local ch = {}
    ch.tag = tag
    ch.posX = posX
    ch.posY = posY
    ch.body = love.physics.newBody(world, posX, posY)
    ch.shape = love.physics.newRectangleShape(width, height)
    ch.fixture = love.physics.newFixture(ch.body, ch.shape)
    ch.fixture:setUserData(ch)
    if friction ~= nil then
        ch.fixture:setFriction(friction)
    end

    return setmetatable(ch, Floor)
end

function Floor:drawMe()
    love.graphics.setColor( 0 , 0 , 0, 0.3)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints() ))
    love.graphics.setColor(1,1,1,1)
end

function Floor:type()
    return "Floor" --- MUDAR !!!
end
