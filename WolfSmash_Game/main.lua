require("player")

function love.load()
    love.physics.setMeter( 64 ) -- 1 metro = 64 pixels
    world = love.physics.newWorld(0, 9.81 * 64 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")
    world:setCallbacks(beginContact, endContact, nil, nil) --Detecta contatos no mundo

    joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados

    player0 = newPlayer("player0", world, joysticks[1], "imagens/Spritesheet.png", 325, 325, 400 ,200, 3) --cria um "player" definido no aquivo player.lua

    player1 = newPlayer("player1", world, joysticks[2], "imagens/Spritesheet.png", 425, 325, 400 ,200, 3) --cria um "player" definido no aquivo player.lua


    objetos = {} --Lista de Objetos
    objetos.chao = {} --Lista de Objetos chão
    objetos.chao.tag = "chao"
    objetos.chao.body = love.physics.newBody(world, 650/2+9, 650 - 50/2) 
    objetos.chao.shape = love.physics.newRectangleShape(1500, 50)
    objetos.chao.fixture = love.physics.newFixture(objetos.chao.body, objetos.chao.shape)
    objetos.chao.fixture:setUserData(objetos.chao.tag)

    objetos.bloco = {}
    objetos.bloco.tag = "bloco"
    objetos.bloco.body = love.physics.newBody(world, 200 , 550 , "dynamic")
    objetos.bloco.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    objetos.bloco.fixture = love.physics.newFixture(objetos.bloco.body, objetos.bloco.shape, 2)
    objetos.bloco.fixture:setUserData(objetos.bloco.tag)

    love.graphics.setBackgroundColor(5/255, 155/255, 1)  --Azul - rgb(RED, GREEN, BLUE, ALPHA) só aceita valores entre 0 e 1 para cada campo ex: (255/255, 20/255, 60/255, 1)    
    love.window.setMode(750, 650) -- Deixa a janela com o tamanho indicado

    text = " "
    vida = "Vida Player0: ".. player0.life .."\nVida Player1: " .. player1.life
end

function love.update( dt )
    world:update( dt )
    
    player0:setKeyboardControls("right", "left", "up")
    player1:setKeyboardControls("d", "a", "w")

    player0:update(dt)
    player1:update(dt)
    
    if string.len(text) > 800 then    -- cleanup when 'text' gets too long
        text = " "
    end

    vida = "Vida Player0: ".. player0.life .."\nVida Player1: " .. player1.life --Temporário 
end

function love.draw()
    love.graphics.setColor( 72/255, 160/255, 16/255) -- Verde
    love.graphics.polygon("fill",objetos.chao.body:getWorldPoints(objetos.chao.shape:getPoints()))

    love.graphics.setColor( 119/255, 69/255, 22/255) -- Marrom
    love.graphics.polygon("fill", objetos.bloco.body:getWorldPoints( objetos.bloco.shape:getPoints()))

    love.graphics.setColor( 1, 1, 1)
    player0:drawMySprite()
    player1:drawMySprite()

    textoTemporario()

end

function textoTemporario()
    love.graphics.setColor( 0, 0, 0)  --PRETO
    love.graphics.print(text, 10, 10)

    love.graphics.setColor( 0, 0, 0)  --PRETO
    love.graphics.print(vida, 500, 10)

    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)

    -------------TESTE JOYSTICK-----------------------
    joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        
        love.graphics.print("-->Joysticks detectados: ", 500, 55)
        love.graphics.print("\t"..joystick:getName(), 500, i * 10 + 60)
    end

    if (joysticks[1] ~= nil) then --Se tiver joystick conectado
        local direcao = joysticks[1]:getAxis(1)
        if( direcao ~= 0) then
            love.graphics.print("Analogico esquerdo, Direção do eixo x : "..direcao, 400,  160)
        end
        direcao = joysticks[1]:getAxis(2)
        if( direcao ~= 0) then
            love.graphics.print("Analogico esquerdo, Direção do eixo y: "..direcao, 400,  175)
        end
        direcao = joysticks[1]:getAxis(3)
        if( direcao ~= -1) then
            love.graphics.print("LT: "..direcao, 400,  220)
        end
        direcao = joysticks[1]:getAxis(4)
        if( direcao ~= 0) then
            love.graphics.print("Analogico direito, Direção do eixo x :"..direcao, 400,  190)
        end
        direcao = joysticks[1]:getAxis(5)
        if( direcao ~= 0) then
            love.graphics.print("Analogico direito, Direção do eixo y :"..direcao, 400,  205)
        end
        direcao = joysticks[1]:getAxis(6)
        if( direcao ~= -1) then
            love.graphics.print("RT: "..direcao, 450,  220)
        end
        local botao = joysticks[1]:isDown(1)
        if(botao) then
            love.graphics.print("Y", 400,  280)
        end
        botao = joysticks[1]:isDown(2)
        if(botao) then
            love.graphics.print("B", 410,  280)
        end
        
        botao = joysticks[1]:isDown(3)
        if(botao) then
            love.graphics.print("A", 420,  280)
        end
        
        botao = joysticks[1]:isDown(4)
        if(botao) then
            love.graphics.print("X", 430,  280)
        end
        
        botao = joysticks[1]:isDown(5)
        if(botao) then
            love.graphics.print("R1", 440,  280)
        end
        
        botao = joysticks[1]:isDown(6)
        if(botao) then
            love.graphics.print("R2", 460,  280)
        end
        
        botao = joysticks[1]:isDown(7)
        if(botao) then
            love.graphics.print("L1", 480,  280)
        end

        botao = joysticks[1]:isDown(8)
        if(botao) then
            love.graphics.print("L2", 530,  280)
        end
        botao = joysticks[1]:isDown(9)
        if(botao) then
            love.graphics.print("Select", 530,  280)
        end
        botao = joysticks[1]:isDown(10)
        if(botao) then
            love.graphics.print("Start", 530,  280)
            love.event.quit()
        end
    end
    ------------------------------------------

end

function isUnderneath(normalY, tag1, tag2, objeto1, objeto2) --Retorna o objeto que estava por baixo na hora da colisão (normalY é valor Y do vetor Normal da colisão)
    if (tag1 == objeto1.tag and tag2 == objeto2.tag) then        
        if(normalY < 0) then
            return objeto1  
        elseif(normalY > 0) then
            return objeto2
        end    
    elseif (tag1 == objeto2.tag and tag2 == objeto1.tag) then
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
    player0:setIsGrounded(tagA, tagB, "bloco", true)
    
    --condição de pulo Player1
    player1:setIsGrounded(tagA, tagB, "chao", true)
    player1:setIsGrounded(tagA, tagB, "bloco", true)

    text = text.."\n"..tagA.." colidindo com "..tagB.." / Vetor normal: (" ..x.." , "..y.." )" --Temporário
end

function endContact(a, b, coll) -- após o contato terminar
    local x, y = coll:getNormal()
    local tagA = a:getUserData()
    local tagB = b:getUserData()

    --Colisão com Player0
    player0:setIsGrounded(tagA, tagB, "chao", false)
    player0:setIsGrounded(tagA, tagB, "bloco", false)

    --Colisão com Player1
    player1:setIsGrounded(tagA, tagB, "chao", false)
    player1:setIsGrounded(tagA, tagB, "bloco", false)

    text = text.."\n"..tagA.." parou de colidir com "..tagB --Temporário
end