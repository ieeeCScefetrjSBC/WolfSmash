-- Class Player
Player = {}
Player.__index = Player 

function newPlayer(tag, world, img, posX, posY, velX ,jumpForce, life)
    local p = {}
    p.tag = tag --Importante para a detecção de Colisões 
    p.posX = posX --Posição X do Corpo (posição inicial)
    p.posY = posY --Posição Y do Corpo (posição inicial)
    p.velX = velX --Velocidade de locomoção pelo eixo X
    p.jumpForce = jumpForce * -1 --Força do Pulo (está negativo por conta do eixo Y crescer para baixo)
    p.width = 50 --Largura do Corpo
    p.height = 60   --Altura do Corpo
    p.life = life --Vida do Player
    p.isAlive = true
    p.isGrounded = false --Está tocando o chão? true = sim 

    p.body = love.physics.newBody(world, p.posX , p.posY, "dynamic") --Cria o corpo dinamico na posição e mundo indicado 
    p.body:setFixedRotation(true) --Faz o corpo não ficar girando 
    p.shape = love.physics.newRectangleShape(0, 0, p.width, p.height)
    p.fixture = love.physics.newFixture(p.body, p.shape, 1)
    p.fixture:setRestitution(0.5) --Faz o objeto quicar
    p.fixture:setUserData(p.tag) --Importante para a detecção de Colisões 
    
    return setmetatable(p, Player) --Retorna uma instância da Classe Player
end

function Player:update()
    if self.life <= 0 then --Se a vida do player for menor ou igual a 0
        self.isAlive = false 
        self.body:setActive(false) --Desativa o Player quando estiver morto
    end
end

function Player:setControls(right, left, up)--Definir os controles a partir do nome do botão indicado
    if love.keyboard.isDown(right) then
        self.body:applyForce(self.velX, 0)
    elseif love.keyboard.isDown(left) then
        self.body:applyForce(-self.velX, 0)
    end
    if love.keyboard.isDown(up) then
        if self.isGrounded then
            self.body:applyLinearImpulse(0, self.jumpForce)
        end
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