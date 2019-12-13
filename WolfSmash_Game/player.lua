local anim8 = require 'anim8'
-- Class Player
Player = {}
Player.__index = Player

function newPlayer(tag, world, joystick, pathImage, posX, posY, velX ,jumpForce, life, keyUp, keyLeft, keyRight)
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
    local g = anim8.newGrid(64, 64, p.image:getWidth(), p.image:getHeight())
    p.animation = {
        idle = anim8.newAnimation(g('1-4',1), 0.1),
        jump = anim8.newAnimation(g('1-4',2), 0.1)
    }

    p.status = {
        walk = false,
        jump = false,
    }
    p.velX = velX --Velocidade de locomoção pelo eixo X
    p.jumpForce = jumpForce * -1 --Força do Pulo (está negativo por conta do eixo Y crescer para baixo)
    p.life = life --Vida do Player
    p.isAlive = true
    p.touchingTheFloor = false --Está tocando o chão? true = sim
    p.touchingTheWall = false  --Está tocando a parede? true = sim
    p.wallJumpVector = {x = 1, y = 0} --Vetor normal da colisão com a parede

    p.body = love.physics.newBody(p.world, posX , posY, "dynamic") --Cria o corpo dinamico na posição e mundo indicado
    p.body:setFixedRotation(true) --Faz o corpo não ficar girando
    p.shape = love.physics.newRectangleShape(0, 0, 64,64)
    p.fixture = love.physics.newFixture(p.body, p.shape, 1)
    p.fixture:setUserData(p) -- Salva a lista com os atributos do Player.
    p.contacts = p.body:getContacts() -- pega a lista dos contatos do corpo

    p.animation.current = p.animation.idle

    return setmetatable(p, Player) --Retorna uma instância da Classe Player
end
function Player:setMaxSpeedX(maxSpeed) --Limita a velocidade do player ao valor especificado
    local linVelX, linVelY = self.body:getLinearVelocity()
    if linVelX > maxSpeed then
        self.body:setLinearVelocity(maxSpeed, linVelY)
    elseif linVelX < -maxSpeed then
        self.body:setLinearVelocity(-maxSpeed, linVelY)
    end
end

function Player:update(dt)
    self.animation.current:update(dt)--Realiza a animação do Player
    self:setMaxSpeedX(500) --Define a velocidade máxima do player
    self.contacts = self.body:getContacts() -- Pega a lista dos contatos do Player

    ----------------------Fricção do Player com o Chão---------------
    if (self.touchingTheFloor) then -- Se o Player estiver no chão
        local colisionFloor = nil
        for i, c in pairs(self.contacts) do --percorre a lista de contatos

            local obj1, obj2 = c:getFixtures() --pega as fixtures envolvidas no contato
            obj2 = obj2:getUserData()
            local typeObj2 = obj2:type() --Pega o tipo do Objeto2

            if typeObj2 == "Floor"then --Se o Objeto2 for do tipo Floor
                colisionFloor =  c
            end
        end
        if (not self.status.walk) then --Se o Player tiver sem tentar andar
            colisionFloor:setFriction(2.5)
        else
            colisionFloor:setFriction(0)
        end
    end
    ---------------------------------------------------------------------

    --------Verifica se está morto----------
    if self.life <= 0 then --Se a vida do player for menor ou igual a 0
        self.isAlive = false
        self.body:setActive(false) --Desativa o Player quando estiver morto
    end
    ----------------------------------------

    ---------------Animação-----------------
    if self.touchingTheFloor then
        self.animation.current = self.animation.idle
    else
        if self.status.jump then
            self.animation.current = self.animation.jump
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

        local botaoA = self.joystick:isDown(2)
        if botaoA then
            local linVelX, linVelY = self.body:getLinearVelocity()
            if self.touchingTheFloor then
                self.body:applyLinearImpulse(0, self.jumpForce)
                self.status.jump = true
            elseif ((self.touchingTheWall) and (not self.touchingTheFloor)) then
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
            local linVelX, linVelY = self.body:getLinearVelocity()
            if self.touchingTheFloor then
                self.body:applyLinearImpulse(0, self.jumpForce)
                self.status.jump = true
            elseif ((self.touchingTheWall) and (not self.touchingTheFloor)) then
                self.body:setLinearVelocity(linVelX,-125) --A velocidade linear do player é setada pra -125 para que o impulso não fique muito forte.
                self.body:applyLinearImpulse(150 * (self.wallJumpVector.x), self.jumpForce) --aplica o impulso no eixo X de 150 pro lado inverso do contato
                self.status.jump = true
            end
        end
        -------------------------------------------------
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

function Player:type()
    return "Player"
end
