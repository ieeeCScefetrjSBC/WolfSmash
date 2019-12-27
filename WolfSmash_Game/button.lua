local anim8 = require 'anim8'
-- Class Player
Button = {}
Button.__index = Button

function newButton(imgPressed, imgNotPressed, posX, posY)
    local btn = {}
    btn.imgPressed = love.graphics.newImage(imgPressed)
    btn.imgNotPressed = love.graphics.newImage(imgNotPressed)
    btn.posX = posX
    btn.posY = posY
    btn.scale = 1
    btn.width = btn.imgNotPressed:getWidth()
    btn.height = btn.imgNotPressed:getHeight()
    btn.imgActive = btn.imgNotPressed
    btn.isSelected = false
    return setmetatable(btn, Button)
end

function Button:update(slctd) --Se slctd for true, quer dizer que o botão está selecionado.
    if (slctd) and (not self.isSelected) then
        self.scale = 1.1
        self.imgActive = self.imgPressed --Muda a cor ativa para a cor definida
        self.isSelected = slctd
    elseif (not slctd) and (self.isSelected) then
        self.scale = 1
        self.imgActive = self.imgNotPressed
        self.isSelected = slctd
    end
end

function Button:drawMe()
    love.graphics.draw(self.imgActive , self.posX, self.posY, nil, self.scale, self.scale, self.width/2, self.height/2)
end

function Button:type()
    return "Button"
end
