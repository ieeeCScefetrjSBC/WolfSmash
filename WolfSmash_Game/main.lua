require("player")

--local world = love.physics.newWorld(0, 650 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")

function love.load()
    love.physics.setMeter( 64 ) -- 1 metro = 64 pixels
    world = love.physics.newWorld(0, 9.81 * 64 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")
    world:setCallbacks(beginContact, endContact, nil, nil)

    player0 = newPlayer("player0", world, nil, 325, 325, 400 ,200, 2) --cria um "player" definido no aquivo player.lua

    player1 = newPlayer("player1", world, nil, 425, 325, 400 ,200, 10) --cria um "player" definido no aquivo player.lua


    objetos = {} --Lista de Objetos
    objetos.chao = {} --Lista de Objetos chão
    objetos.chao.body = love.physics.newBody(world, 650/2+9, 650 - 50/2) 
    objetos.chao.shape = love.physics.newRectangleShape(650, 50)
    objetos.chao.fixture = love.physics.newFixture(objetos.chao.body, objetos.chao.shape)
    objetos.chao.fixture:setUserData("chao")

    objetos.bloco = {}
    objetos.bloco.body = love.physics.newBody(world, 200 , 550 , "dynamic")
    objetos.bloco.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    objetos.bloco.fixture = love.physics.newFixture(objetos.bloco.body, objetos.bloco.shape, 2)
    objetos.bloco.fixture:setUserData("bloco")

    love.graphics.setBackgroundColor(5/255, 155/255, 1)  --Azul - rgb(RED, GREEN, BLUE, ALPHA) só aceita valores entre 0 e 1 para cada campo ex: (255/255, 20/255, 60/255, 1)    
    love.window.setMode(750, 650) -- Deixa a janela com o tamanho indicado

    text = " "
    vida = "Vida Player0: ".. player0.life .."\nVida Player1: " .. player1.life
end

function love.update( dt )
    world:update( dt )
    
    player0:setControls("right", "left", "up")
    player1:setControls("d", "a", "w")

    player0:update()
    player1:update()
    
    if string.len(text) > 500 then    -- cleanup when 'text' gets too long
        text = " "
    end

    vida = "Vida Player0: ".. player0.life .."\nVida Player1: " .. player1.life --Temporário 
end

function love.draw()
    love.graphics.setColor( 72/255, 160/255, 16/255) -- Verde
    love.graphics.polygon("fill",objetos.chao.body:getWorldPoints(objetos.chao.shape:getPoints()))

    love.graphics.setColor( 119/255, 69/255, 22/255) -- Marrom
    love.graphics.polygon("fill", objetos.bloco.body:getWorldPoints( objetos.bloco.shape:getPoints()))

    player0:drawMe(1, 0, 0) --Desenha o player com a cor indicada  --Temporário
    player1:drawMe(1, 0.5, 1)

    textoTemporario()
    
end

function textoTemporario()
    love.graphics.setColor( 0, 0, 0)  --PRETO
    love.graphics.print(text, 10, 10)

    love.graphics.setColor( 0, 0, 0)  --PRETO
    love.graphics.print(vida, 500, 10)
end

function isUnderneath(normalY, tag1, tag2, objeto1, objeto2) --Retorna o objeto que estava por baixo na hora da colisão (normalY é valor Y do vetor Normal da colisão)
    if (tag1 == objeto1.tag and tag2 == objeto2.tag) then        
        if(normalY < 0) then
            return objeto1  
        elseif(normalY > 0) then
            return objeto2
        end
    end

    if (tag1 == objeto2.tag and tag2 == objeto1.tag) then
        if(normalY < 0) then
            return  objeto2  
        elseif(normalY > 0) then
             return objeto1 
        end
    end
    return nil
end

function beginContact(a, b, coll) --Inicio do contato 
    local x, y = coll:getNormal()
    local tagA = a:getUserData()
    local tagB = b:getUserData()
    local under = isUnderneath(y, tagA, tagB, player0, player1) --under recebe o objeto que ficou por baixo na colisão (entre Player0 e Player1)

    --Dano por Pisão na cabeça 
    if under ~= nil then
        under:applyDamage(1)
    end

    --condição de pulo Player0
    player0:setIsGrounded(tagA, tagB, "chao", true)
    
    --condição de pulo Player1
    player1:setIsGrounded(tagA, tagB, "chao", true)

    text = text.."\n"..tagA.." colidindo com "..tagB.." / Vetor normal: (" ..x.." , "..y.." )" --Temporário
end

function endContact(a, b, coll) -- após o contato terminar
    local tagA = a:getUserData()
    local tagB = b:getUserData()

    --Colisão com Player0
    player0:setIsGrounded(tagA, tagB, "chao", false)

    --Colisão com Player1
    player1:setIsGrounded(tagA, tagB, "chao", false)


    text = text.."\n"..tagA.." parou de colidir com "..tagB --Temporário
end