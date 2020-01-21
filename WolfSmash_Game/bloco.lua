-- Class Bloco 
Bloco = {}
Bloco.__index = Bloco

function newBloco(tag, world, posX, posY, width, height)
    local b = {}
    b.tag = tag
    b.posX = posX
    b.posY = posY
    b.body = love.physics.newBody(world, posX, posY, "dynamic")
    b.shape = love.physics.newRectangleShape(width, height)
    b.fixture = love.physics.newFixture(b.body, b.shape, 3)
    b.fixture:setUserData(b)

    return setmetatable(b, Bloco)
end

function Bloco:drawMe()
    love.graphics.setColor(119/255, 69/255, 22/255) -- Verde
    love.graphics.polygon("fill",self.body:getWorldPoints(self.shape:getPoints()))
end

function Bloco:type()
    return "Bloco" --- MUDAR !!!
end