local anim8 = require 'anim8'
local Timer = require "hump.timer"
-- Class Player
Player = {}
Player.__index = Player

function newPlayer(tag, world, joystick, pathImage, playerNumber, posX, posY, velX ,jumpForce, keyUp, keyLeft, keyRight)
    local animBool = false
    local p = {}
    p.tag = tag --Importante para a detecção de Colisões
    p.world = world
    p.joystick = joystick
    p.keyboard = {
        up = keyUp,
        left = keyLeft,
        right = keyRight
    }
    p.image = love.graphics.newImage(pathImage)
    p.playerNumber = playerNumber
    local g = anim8.newGrid(64, 64, p.image:getWidth(), p.image:getHeight())
    p.sounds = {
      jump1 = love.audio.newSource("audio/SFX/jump1.ogg", "static"),
      jump2 = love.audio.newSource("audio/SFX/jump2.ogg", "static"),
      death = love.audio.newSource("audio/SFX/death.ogg", "static"),
      impact1 = love.audio.newSource("audio/SFX/impact1.ogg", "static"),
      impact2 = love.audio.newSource("audio/SFX/impact2.ogg", "static"),
      explosion = love.audio.newSource("audio/SFX/explosion.ogg", "static")
    }
    p.animation = {
        idle  = anim8.newAnimation(g('1-4',playerNumber), 0.1),
        jump  = anim8.newAnimation(g('5-8',playerNumber), 0.1),
        wjump = anim8.newAnimation(g('9-12',playerNumber), 0.1),
        swalk = anim8.newAnimation(g('13-16',playerNumber), 0.1, 1),
        walk  = anim8.newAnimation(g('17-20',playerNumber), 0.1),

        lidle  = anim8.newAnimation(g('1-4',playerNumber), 0.1):flipH(),
        ljump  = anim8.newAnimation(g('5-8',playerNumber), 0.1):flipH(),
        lwjump = anim8.newAnimation(g('9-12',playerNumber), 0.1):flipH(),
        lswalk = anim8.newAnimation(g('13-16',playerNumber), 0.1, 1):flipH(),
        lwalk  = anim8.newAnimation(g('17-20',playerNumber), 0.1):flipH()
    }

    p.status = {
        walk = false,
        jump = false,
        right = true,
    }
    p.maxSpeed = 500
    p.velX = velX --Velocidade de locomoção pelo eixo X
    p.jumpForce = jumpForce * -1 --Força do Pulo (está negativo por conta do eixo Y crescer para baixo)
    p.life = 1 --Vida do Player
    p.isAlive = true
    p.touchingTheFloor = false --Está tocando o chão? true = sim
    p.setvectorBelowGround = {x = 0, y = -1}
    p.crossedThePlatform = false -- Se passou por dentro da plataforma = true
    p.touchingTheWall = false  --Está tocando a parede? true = sim
    p.wallJumpVector = {x = 1, y = 0} --Vetor normal da colisão com a parede

    p.body = love.physics.newBody(p.world, posX , posY, "dynamic") --Cria o corpo dinamico na posição e mundo indicado
    p.body:setFixedRotation(true) --Faz o corpo não ficar girando

    if playerNumber == 1 then
        p.shape = love.physics.newRectangleShape(0, 0, 22,64)
        p.fixture = love.physics.newFixture(p.body, p.shape, 2.5)
    elseif playerNumber == 2 then
        p.body:setGravityScale(2)
        p.jumpForce = p.jumpForce*1.55
        p.shape = love.physics.newRectangleShape(0, 5, 35,55)
        p.fixture = love.physics.newFixture(p.body, p.shape, 2)
    else
        p.shape = love.physics.newRectangleShape(0, 5, 32,50)
        p.fixture = love.physics.newFixture(p.body, p.shape, 2.4)
    end

    p.fixture:setUserData(p) -- Salva a lista com os atributos do Player.
    p.contacts = p.body:getContacts() -- pega a lista dos contatos do corpo
    p.animation.current = p.animation.idle

    if playerNumber == 1 then --Stark
        p.velX = 760
        p.maxSpeed = 600
    elseif playerNumber == 2 then -- Ultra-T

    elseif playerNumber == 3 then --Personagem de água
        p.jumpForce = -380
    end

    return setmetatable(p, Player) --Retorna uma instância da Classe Player
end

function Player:resetPlayer(posX, posY)
    self.life = 1 --Vida do Player
    self.isAlive = true

    self.status = {
        walk = false,
        jump = false,
        right = true,
    }
    self.touchingTheFloor = false --Está tocando o chão? true = sim
    self.crossedThePlatform = false -- Se passou por dentro da plataforma = true
    self.touchingTheWall = false  --Está tocando a parede? true = sim
    self.alx = love.math.random( 64, windowWidth -64)
    self.aly = love.math.random( 64, windowHeight -64)
    self.body:setPosition(self.alx , self.aly) --Define a nova posição do player
end


function Player:setMaxSpeedX() --Delimita a velocidade do player (eixoX) ao valor especificado
    local linVelX, linVelY = self.body:getLinearVelocity()
    if linVelX > self.maxSpeed then
        self.body:setLinearVelocity(self.maxSpeed, linVelY)
    elseif linVelX < -self.maxSpeed then
        self.body:setLinearVelocity(-self.maxSpeed, linVelY)
    end
end

function Player:update(dt)
    self.animation.current:update(dt)--Realiza a animação do Player
    Timer.update(dt)
    self:setMaxSpeedX() --Define a velocidade máxima do player
    self.contacts = self.body:getContacts() -- Pega a lista dos contatos do Player
    local linVelX, linVelY = self.body:getLinearVelocity()

    ----------------------Fricção do Player com o Chão---------------
    if (self.touchingTheFloor) then -- Se o Player estiver no chão
        local colisionFP = nil
        for i, c in pairs(self.contacts) do --percorre a lista de contatos

            local obj1, obj2 = c:getFixtures() --pega as fixtures envolvidas no contato
            obj1 = obj1:getUserData()
            obj2 = obj2:getUserData()
            local typeObj1 = obj1:type()
            local typeObj2 = obj2:type() --Pega o tipo do Objeto2

            if (typeObj1 == "Floor") or (typeObj2 == "Floor") or (typeObj1 == "Platform") or (typeObj2 == "Platform") then --Se o Objeto2 for do tipo Floor ou Platform
                colisionFP = c
            end
        end
        if (not self.status.walk) then --Se o Player tiver sem tentar andar
            colisionFP:setFriction(2.5)
        else
            colisionFP:setFriction(0)
        end
    end
    ---------------------------------------------------------------------

    --------Verifica se está morto----------
    if self.life <= 0 then --Se a vida do player for menor ou igual a 0
        self.isAlive = false
        for i, p in pairs(self.sounds) do
                p:stop()
        end
        self.sounds.death:play()
    end
    ----------------------------------------

    ---------------Animação-----------------

    if (linVelX > 0) and (not self.status.right) then
        self.status.right = true
    elseif (linVelX < 0) and (self.status.right)then
        self.status.right = false
    end

    if self.status.right == true then
        if self.touchingTheFloor then
            self.animBool = false
            if self.status.walk == true then
                self.animation.current = self.animation.swalk
                self.animation.current = self.animation.walk
            else
                self.animation.current = self.animation.idle
            end
        else
            if self.status.jump then
                Timer.during(1.2, function(dt) if self.animBool == false then
                    self.animation.current = self.animation.jump
                    self.animation.current:gotoFrame(1)
                    self.animation.current:resume()
                    self.animBool = true
                    end
                    end, function(dt) self.animation.current = self.animation.wjump
                    Timer.after(1.2, function() self.animation.current:gotoFrame(4) end)
                    end)
            end
        end
    else
        if self.touchingTheFloor then
            self.animBool = false
            if self.status.walk == true then
                self.animation.current = self.animation.lswalk
                self.animation.current = self.animation.lwalk
            else
                self.animation.current = self.animation.lidle
            end
        else
            if self.status.jump then
                Timer.during(1.2, function(dt) if self.animBool == false then
                    self.animation.current = self.animation.ljump
                    self.animation.current:gotoFrame(1)
                    self.animation.current:resume()
                    self.animBool = true
                    end
                    end, function(dt) self.animation.current = self.animation.lwjump
                    Timer.after(1.2, function() self.animation.current:gotoFrame(4) end)
                    end)
            end
        end
    end
    ----------------------------------------

    -------Joystick------------
    if self.joystick ~= nil then -- Se tiver um joystick atrelado ao player
        local direcaoX = self.joystick:getAxis(1)
        if direcaoX ~= 0 then
            self.body:applyForce(self.velX * direcaoX, 0)
            self.status.walk = true
        else
            self.status.walk = false
        end

        local botaoB = self.joystick:isDown(2)
        if botaoB then
            if self.touchingTheFloor then
                for i, p in pairs(self.sounds) do
                   p:stop()
                end
                self.sounds.jump1:play()
                self.body:applyLinearImpulse(0, self.jumpForce)
                self.status.jump = true
            elseif ((self.touchingTheWall) and (not self.touchingTheFloor)) then
                for i, p in pairs(self.sounds) do
                    p:stop()
                end
                self.sounds.jump2:play()
                self.body:setLinearVelocity(linVelX,-125) --A velocidade linear do player é setada pra -125 para que o impulso não fique muito forte.
                self.body:applyLinearImpulse(150 * (self.wallJumpVector.x), self.jumpForce) --aplica o impulso no eixo X de 150 pro lado inverso do contato
                self.status.jump = true
            end
        end
    else
        -----------Keyboard------------------
        if love.keyboard.isDown(self.keyboard.right) then
            self.body:applyForce(self.velX, 0)
            self.status.walk = true
        elseif love.keyboard.isDown(self.keyboard.left) then
            self.body:applyForce(-self.velX, 0)
            self.status.walk = true
        else
            self.status.walk = false
        end

        if love.keyboard.isDown(self.keyboard.up) then
            if self.touchingTheFloor then
                for i, p in pairs(self.sounds) do
                    p:stop()
                end
                self.sounds.jump1:play()
                self.body:applyLinearImpulse(0, self.jumpForce)
                self.status.jump = true
            elseif ((self.touchingTheWall) and (not self.touchingTheFloor)) then
                for i, p in pairs(self.sounds) do
                    p:stop()
                end
                self.sounds.jump2:play()
                self.body:setLinearVelocity(linVelX,-125) --A velocidade linear do player é setada pra -125 para que o impulso não fique muito forte.
                self.body:applyLinearImpulse(400 * (self.wallJumpVector.x), self.jumpForce) --aplica o impulso no eixo X de 400 pro lado inverso do contato
                self.status.jump = true
            end
        end
        -------------------------------------------------
    end
end

function Player:drawMySprite()
    if  self.isAlive then --Se o Player estiver vivo ele será desenhando na tela
        self.animation.current:draw(self.image, self.body:getX() - 32, self.body:getY()-32)
        if self.tag == "player0" then
          love.graphics.print("P1",self.body:getX()-16,self.body:getY() - 60,0,2,2)
        else
          love.graphics.print("P2",self.body:getX()-16,self.body:getY() - 60,0,2,2)
        end
    end
end

function Player:drawMe()
    if  self.isAlive then --Se o Player estiver vivo ele será desenhando na tela
        love.graphics.setColor( 0 , 0 , 0, 0.3)
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints() ))
        love.graphics.setColor(1,1,1,1)
    end
end

function Player:applyDamage(damage) --Aplica o dano indicado ao player
        self.life = self.life - damage
end

function Player:setTouchingTheFloor(value) --Função especifica para mudar o estado "touchingTheFloor" do player.
    self.touchingTheFloor = value
end

function Player:setTouchingTheWall(value) --Função especifica para mudar o estado "touchingTheWall" do player.
    self.touchingTheWall = value
end

function Player:setWallJumpVector(normalX, normalY, object1, object2)
    if object1:type() == "Player" then
        self.wallJumpVector.x = -normalX
    elseif object2:type() == "Player" then
        self.wallJumpVector.x = normalX
    end
    self.wallJumpVector.y = normalY
end

function Player:setCrossedThePlatform(value)
    self.crossedThePlatform = value
end

function Player:getCrossedThePlatform()
    return self.crossedThePlatform
end

function Player:type()
    return "Player"
end
