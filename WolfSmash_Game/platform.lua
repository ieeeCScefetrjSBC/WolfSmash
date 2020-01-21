-- Class Floor
Platform = {}
Platform.__index = Platform

function newPlatform(tag, world, posX, posY, width, height, friction)
    local plt = {}
    plt.tag = tag
    plt.posX = posX
    plt.posY = posY
    plt.sprite = love.graphics.newImage("imagens/Plataforma/PlataformaFull.png")
    plt.width = plt.sprite:getWidth()
    plt.height = plt.sprite:getHeight()
    plt.body = love.physics.newBody(world, posX, posY)
    plt.shape = love.physics.newRectangleShape(plt.width, plt.height)
    plt.fixture = love.physics.newFixture(plt.body, plt.shape)
    plt.fixture:setUserData(plt)
    if friction ~= nil then
        plt.fixture:setFriction(friction)
    end

    return setmetatable(plt, Platform)
end

function Platform:drawMe()
    love.graphics.setColor(65/255, 105/255, 255/255, 0.5) -- Azul
    love.graphics.polygon("fill",self.body:getWorldPoints(self.shape:getPoints()))
end

function Platform:drawMySprite()
    love.graphics.setColor(1, 1, 1) -- Azul
    love.graphics.draw(self.sprite , self.posX, self.posY, nil, 1, 1, self.width/2, self.height/2)
end

function Platform:type()
    return "Platform"
end
