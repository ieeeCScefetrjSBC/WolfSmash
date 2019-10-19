local anim8 = require 'anim8'
-- Class Player
Player = {}
Player.__index = Player 

function newPlayer(tag, world, joystick, pathImage, posX, posY, velX ,jumpForce, life)
    local p = {}
    p.tag = tag --Importante para a detecção de Colisões
    p.world = world 
    p.joystick = joystick
    p.image = love.graphics.newImage(pathImage)
    local g = anim8.newGrid(64, 64, p.image:getWidth(), p.image:getHeight())
    p.animation = {
        idle = anim8.newAnimation(g('1-4',1), 0.1),
        jumping = false,
        jump = anim8.newAnimation(g('1-4',2), 0.1)
    }
    p.animation.idle = anim8.newAnimation(g('1-4',1), 0.1)
    p.animation.jump = anim8.newAnimation(g('1-4',2), 0.1)
    p.velX = velX --Velocidade de locomoção pelo eixo X
    p.jumpForce = jumpForce * -1 --Força do Pulo (está negativo por conta do eixo Y crescer para baixo)
    p.life = life --Vida do Player
    p.isAlive = true
    p.isGrounded = false --Está tocando o chão? true = sim 

    p.body = love.physics.newBody(p.world, posX , posY, "dynamic") --Cria o corpo dinamico na posição e mundo indicado 
    p.body:setFixedRotation(true) --Faz o corpo não ficar girando 
    p.shape = love.physics.newRectangleShape(0, 0, 64,64)
    p.fixture = love.physics.newFixture(p.body, p.shape, 1)
    --p.fixture:setRestitution(0.5) --Faz o objeto quicar
    p.fixture:setUserData(p.tag) --Importante para a detecção de Colisões 

    p.animation.current = p.animation.idle
    
    return setmetatable(p, Player) --Retorna uma instância da Classe Player
end

function Player:update(dt)
    self.animation.current:update(dt)
    
    --------Verifica se está morto----------
    if self.life <= 0 then --Se a vida do player for menor ou igual a 0
        self.isAlive = false 
        self.body:setActive(false) --Desativa o Player quando estiver morto
    end
    ----------------------------------------

    ---------------Animação-----------------
    if self.isGrounded then
        self.animation.current = self.animation.idle
    else
        if self.animation.jumping then
            self.animation.current = self.animation.jump
        end
    end
    ----------------------------------------

    -------Joystick------------
    if self.joystick ~= nil then -- Se tiver um joystick atrelado ao player
        local direcaoX = self.joystick:getAxis(1)
        if direcaoX ~= 0 then
                self.body:applyForce(self.velX * direcaoX, 0)
        end

        local botaoA = self.joystick:isDown(1)
        if botaoA then
            if self.isGrounded then
                self.body:applyLinearImpulse(0, self.jumpForce)
                self.animation.jumping = true
            end
        end
    end
    -----------------------------
end

function Player:setKeyboardControls(right, left, up)--Definir os controles a partir do nome do botão indicado
    if love.keyboard.isDown(right) then
        self.body:applyForce(self.velX, 0)
    elseif love.keyboard.isDown(left) then
        self.body:applyForce(-self.velX, 0)
    end
    if love.keyboard.isDown(up) then
        if self.isGrounded then
            self.body:applyLinearImpulse(0, self.jumpForce)
            self.animation.jumping = true
        end
    end
end

function Player:drawMySprite()
    if  self.isAlive then --Se o Player estiver vivo ele será desenhando na tela
        self.animation.current:draw(self.image, self.body:getX() - 32, self.body:getY()-32)
    end
end

function Player:drawMe(r, g, b)
    if  self.isAlive then --Se o Player estiver vivo ele será desenhando na tela
        love.graphics.setColor( r, g, b) -- Vermelho
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints() ))
    end
end

function Player:applyDamage(damage) --Aplica o dano indicado ao player 
        self.life = self.life - damage
end

function Player:setIsGrounded(collisionTag1, collisionTag2, tagGround, value) --Função especifica para mudar o estado "isGround" do player.
    if(collisionTag1 == self.tag or collisionTag2 == self.tag) then
        if (collisionTag1 == tagGround or collisionTag2 == tagGround) then
            self.isGrounded = value
        end
    end
end

function Player:touchingOver(collisionTag1, collisionTag2, normalY) --Função verifica se o player está tocando o objeto por cima
    if (collisionTag1 == self.tag) then        
        if(normalY < 0) then
            return false
        elseif(normalY > 0) then
            return true
        end    
    elseif (collisionTag2 == self.tag) then
        if(normalY < 0) then
            return  true 
        elseif(normalY > 0) then
             return false 
        end
    end
    return nil
end