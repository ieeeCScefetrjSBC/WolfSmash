require("player")
require("floor")
require("bloco")
require("button")
windowWidth, windowHeight = love.window.getMode()
menuActive = true

function love.load()
    selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    joysticks = nil
    joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados

    print(joysticks)

    if(not menuActive) then
        initialSetting()
    else
        menu()
    end
end

function menu()
    menu = love.physics.newWorld(0, 0, true)
    buttons = { newButton("imagens/Sprite-0001.png","imagens/Sprite-0002.png", windowWidth/2, windowHeight/2),
                newButton("imagens/Exit-0001.png","imagens/Exit-0002.png", windowWidth/2, 70 + windowHeight/2)}
end

function initialSetting()
    love.mouse.setVisible(false) --Deixa o cursos do mouse invisível
    love.physics.setMeter( 64 ) -- 1 metro = 64 pixels
    world = love.physics.newWorld(0, 9.81 * 64 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")
    world:setCallbacks(beginContact, endContact, preSolve, nil) --Detecta contatos no mundo
    forca = 500
    players= {
        p0 = newPlayer("player0", world, joysticks[1], "imagens/Spritesheet.png", 325, 325, 500 ,forca, 3), --cria um "player" definido no aquivo player.lua
        p1 = newPlayer("player1", world, joysticks[2], "imagens/Spritesheet.png", 425, 325, 500 ,forca, 3) --cria um "player" definido no aquivo player.lua
    }
    objetos = {} --Lista de Objetos
    objetos.ch1 = newFloor("Floor", world, 450, 600, 1500, 50)
    objetos.ch2 = newFloor("Floor", world, 900, 400, 50, 400)
    objetos.bl1 = newBloco("bloco", world, 200, 550, 50, 150) -- TESTE
    love.graphics.setBackgroundColor(5/255, 155/255, 1)  --Azul - rgb(RED, GREEN, BLUE, ALPHA) só aceita valores entre 0 e 1 para cada campo ex: (255/255, 20/255, 60/255, 1)

    text = " "
    vida = "Vida Player0: ".. players.p0.life .."\nVida Player1: " .. players.p1.life
end

function love.update( dt )
    if(not menuActive) then
        world:update(dt)


        players.p0:setKeyboardControls("right", "left", "up")
        players.p1:setKeyboardControls("d", "a", "w")

        for i, p in pairs(players) do --Percorre por todos os Players da Lista
            p:update(dt)
        end

        if string.len(text) > 800 then    -- Limpa o Texto caso esteja muito grande
            text = " "
        end

        vida = "Vida Player0: ".. players.p0.life .."\nVida Player1: " .. players.p1.life --Temporário
    else
        -----Caso o Menu esteja Ativo------
        -----Joystick
        if (joysticks[1] ~= nil) then --Se tiver joystick conectado
            local direcao = joysticks[1]:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama
            local botao = joysticks[1]:isDown(3) -- Recebe o valor do botão A do fliperama

            if(direcao ~= 0) then
                selcBtn = selcBtn - direcao --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                love.timer.sleep(0.1666)
            end

            if selcBtn > 2 then
                  selcBtn = 1
            elseif selcBtn < 1 then
                  selcBtn = 2
            end

            if(botao) then
                if selcBtn == 1 then
                    menuActive = false
                    love.load()
                elseif selcBtn == 2 then
                    love.event.quit()
                end
            end
        end
        -------

        ----- Teclado
        if love.keyboard.isDown("up") then
            selcBtn = selcBtn - 1
            love.timer.sleep(0.1666)
        elseif love.keyboard.isDown("down") then
            selcBtn = selcBtn + 1
            love.timer.sleep(0.1666)
        end
        ------

        if selcBtn > 2 then
            selcBtn = 1
        elseif selcBtn < 1 then
            selcBtn = 2
        end

        if love.keyboard.isDown("return") then
            if selcBtn == 1 then
                menuActive = false
                love.load()
            elseif selcBtn == 2 then
                love.event.quit()
            end
        end

        for i, p in ipairs(buttons) do --Percorre por todos os Botoes da Lista
            if i == selcBtn then
                p:update(true)
            else
                p:update(false)
            end
        end
    end
end

function love.draw()
    if(not menuActive) then
        for i, p in pairs(objetos) do --Percorre por todos os objetos da Lista
            p:drawMe() --desenha o objeto na tela
        end

        love.graphics.setColor( 1, 1, 1)-- Branco

        for i,p in pairs(players) do --Desenha os Players da lista Player
            p:drawMySprite()
        end

        textoTemporario()
    else
        for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
            p:drawMe()
        end
    end
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

function isUnderneath(normalY, object1, object2) --Retorna o objeto que ficou por baixo durante a colisão (normalY é valor Y do vetor Normal da colisão)
    if (normalY >= 0.5) then
        return object2
    elseif (normalY <= -0.5) then
        return object1
    end
    return nil -- Caso nenhum dos objetos tenha ficado por baixo, retornará "nil"
end

function beginContact(fxtrA, fxtrB, coll) --Inicio do contato (fxtr representa Fixture, coll representa Collision)
    local normX, normY = coll:getNormal()
    local objA = fxtrA:getUserData()
    local objB = fxtrB:getUserData()
    local tagA = objA.tag
    local tagB = objB.tag

    local under = isUnderneath(normY, objA, objB) --Retorna o objeto que ficou por baixo na Colisão

    --Dano por Pisão na cabeça
    if under ~= nil then
        for i, p in pairs(players) do --Percorre por todos os Players da Lista
            if under.tag == p.tag then --Verifica se é o player que ficou por baixo, na colisão
                under:applyDamage(1) -- Aplica o dano de -1 na vida do player
            end
        end
    end
    ----

    text = text.."\n"..tagA.." colidindo com "..tagB.." / Vetor normal: (" ..normX.." , "..normY.." )" --Temporário
end

function preSolve (fxtrA, fxtrB, coll) --Durante a Colisão
    local normX, normY = coll:getNormal()
    local objA = fxtrA:getUserData()
    local objB = fxtrB:getUserData()
    local tagA = objA.tag
    local tagB = objB.tag

    if (objA:type() == "Player") and (objB:type() == "Player") then

    elseif (objA:type() == "Player") or (objB:type() == "Player") then
        for i, p in pairs(players) do --Percorre por todos os Players da lista players
            if (tagA == p.tag) or (tagB == p.tag) then --Verifica se a tag do player é igual a tag do objeto da colisão
                p:setIsGrounded(true)
            end
        end
    end
end

function endContact(fxtrA, fxtrB, coll) -- Após o contato terminar
    local normX, normY = coll:getNormal() --Pega o vetor normal da colisão
    local objA = fxtrA:getUserData() --Pega o Objeto que possui a fixture envolvida na colisão
    local objB = fxtrB:getUserData()
    local tagA = objA.tag --Pega a tag do Objeto
    local tagB = objB.tag

    if (objA:type() == "Player") or (objB:type() == "Player") then --Verifica se a colisão ocorreu com algum objeto do tipo Player
        for i, p in pairs(players) do --Percorre por todos os Players da lista players
            if (tagA == p.tag) or (tagB == p.tag) then --Verifica se a tag do player é igual a tag do objeto da colisão
                p:setIsGrounded(false)
            end
        end
    end
    text = text.."\n"..tagA.." parou de colidir com "..tagB --Temporário
end
