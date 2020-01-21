-- Class Floor
Wall = {}
Wall.__index = Wall

function newWall(tag, world, posX, posY, width, height)
    local wl = {}
    wl.tag = tag
    wl.posX = posX
    wl.posY = posY
    wl.body = love.physics.newBody(world, posX, posY)
    wl.shape = love.physics.newRectangleShape(width, height)
    wl.fixture = love.physics.newFixture(wl.body, wl.shape)
    wl.fixture:setUserData(wl)

    return setmetatable(wl, Wall)
end

function Wall:drawMe()
    love.graphics.setColor( 0 , 0 , 0, 0.3)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints() ))
    love.graphics.setColor(1,1,1,1)
end

function Wall:type()
    return "Wall" --- MUDAR !!!
end
