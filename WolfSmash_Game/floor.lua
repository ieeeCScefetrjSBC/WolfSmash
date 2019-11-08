-- Class Floor 
Floor = {}
Floor.__index = Floor

function newFloor(tag, world, posX, posY, width, height)
    local ch = {}
    ch.tag = tag
    ch.posX = posX
    ch.posY = posY
    ch.body = love.physics.newBody(world, posX, posY)
    ch.shape = love.physics.newRectangleShape(width, height)
    ch.fixture = love.physics.newFixture(ch.body, ch.shape)
    ch.fixture:setUserData(ch)

    return setmetatable(ch, Floor)
end

function Floor:drawMe()
    love.graphics.setColor( 72/255, 160/255, 16/255) -- Verde
    love.graphics.polygon("fill",self.body:getWorldPoints(self.shape:getPoints()))
end

function Floor:type()
    return "Floor" --- MUDAR !!!
end