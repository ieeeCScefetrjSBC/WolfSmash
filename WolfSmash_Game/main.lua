require("player")
require("floor")
require("platform")
require("wall")
require("bloco")
require("button")
Gamestate = require ("hump.gamestate")
Timer = require ("hump.timer")
windowWidth, windowHeight = love.window.getMode()

menu = Gamestate.new()
pause = Gamestate.new()
game = Gamestate.new()

function love.load()
    love.mouse.setVisible(false) --Esconde o cursor da tela
    Gamestate.switch(menu)
end

function love.update(dt)
    Timer.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    Gamestate.draw()
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.joystickpressed(joystick, button)
     Gamestate.joystickpressed(joystick, button)
end
function game:init()
    self.background = love.graphics.newImage("imagens/Arena Background.png")
end

function game:enter()
    love.physics.setMeter(64) -- 1 metro = 64 pixels
    world = love.physics.newWorld(0, 9.81 * 64 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")
    world:setCallbacks(beginContact, endContact, preSolve, nil) --Detecta contatos no mundo
    local forca = 300
    players= {
        p0 = newPlayer("player0", world, joysticks[1], "imagens/Spritsheet_Robots.png", 1, 325, 325, 700 ,forca, 1, "up", "left", "right"), --cria um "player" definido no aquivo player.lua
        p1 = newPlayer("player1", world, joysticks[2], "imagens/Spritsheet_Robots.png", 2, 425, 325, 700 ,forca, 1, "w", "a", "d") --cria um "player" definido no aquivo player.lua
    }
    objetos = {} --Lista de Objetos
    objetos.ch1 = newFloor("Floor", world, windowWidth/2, 25, windowWidth, 50, nil)
    objetos.ch2 = newFloor("Floor", world, windowWidth/2, windowHeight-25, windowWidth, 50, nil)
    objetos.plt1 = newPlatform("Platform", world, windowWidth/2, windowHeight/2 - windowHeight*0.15, 150, 20, nil)
    objetos.plt2 = newPlatform("Platform", world, windowWidth/2 + 200, windowHeight/2 + windowHeight*0.2, 150, 20, nil)
    objetos.plt3 = newPlatform("Platform", world, windowWidth/2 - 200, windowHeight/2 + windowHeight*0.2, 150, 20, nil)
    objetos.wl1 = newWall("Wall", world, windowWidth-25, windowHeight/2-25, 50, windowHeight)
    objetos.wl2 = newWall("Wall", world, 25, windowHeight/2-50, 50, windowHeight)
    -- self.background = love.graphics.setBackgroundColor(5/255, 155/255, 1)  --Azul - rgb(RED, GREEN, BLUE, ALPHA) só aceita valores entre 0 e 1 para cada campo ex: (255/255, 20/255, 60/255, 1)

    text = " "
    vida = "Vida Player0: ".. players.p0.life .."\nVida Player1: " .. players.p1.life
end

function game:update(dt)
    world:update(dt)
    for i, p in pairs(players) do --Percorre por todos os Players da Lista
        p:update(dt)
    end

    if string.len(text) > 800 then    -- Limpa o Texto caso esteja muito grande
        text = " "
    end

    vida = "Vida Player0: ".. players.p0.life .."\nVida Player1: " .. players.p1.life --Temporário
end

function game:keypressed(key)
    if key == 'escape' or key == 'p' then
        Gamestate.push(pause)
    end
end

function game:joystickpressed(joystick, button)
    if button == 10 then -- Start
        self.joystickPauser = joystick
        Gamestate.push(pause)
    end
end

function game:getJoystickPauser()
    return self.joystickPauser
end

function game:draw()
    love.graphics.setColor( 1, 1, 1)-- Branco
    love.graphics.draw(self.background, 0, 0)
    for i,p in pairs(players) do --Desenha os Players da lista Player
       p:drawMySprite()
    end

    self.textoTemporario()

    for i, p in pairs(objetos) do --Percorre por todos os objetos da Lista
       p:drawMe() --desenha o objeto na tela
    end
end

function game:textoTemporario()
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
    local typeObj2 = objB:type()


    text = text.."\n"..tagA.." colidindo com "..tagB.." / Vetor normal: (" ..normX.." , "..normY.." )" --Temporário
end

function preSolve (fxtrA, fxtrB, coll) --Durante a Colisão
    local normX, normY = coll:getNormal()
    local objA = fxtrA:getUserData()
    local objB = fxtrB:getUserData()
    local tagA = objA.tag
    local tagB = objB.tag

    local under = isUnderneath(normY, objA, objB) --Retorna o objeto que ficou por baixo na Colisão

    if ((objA:type() == "Player") and (objB:type() == "Player")) then --Se o contato foir de Player com Player
        --Dano por Pisão na cabeça
        if under ~= nil then
            for i, p in pairs(players) do --Percorre por todos os Players da Lista
                if under.tag == p.tag then --Verifica se é o player que ficou por baixo, na colisão
                    under:applyDamage(1) -- Aplica o dano de -1 na vida do player
                end
            end
        end
        ----
    elseif ((objA:type() == "Player") or (objB:type() == "Player"))then -- Se tiver Player envolvido na colisão
        ----------------------Chão------------------------
        if((objA:type() == "Floor") or (objB:type() == "Floor"))then --Se tiver Player e Floor envolvido na colisão
            if (normX == 0) and (normY == 1) then --Vê se o player está acima
                for i, p in pairs(players) do --Percorre por todos os Players da lista players
                    if (tagA == p.tag) or (tagB == p.tag) then --Verifica qual dos Players estava na colisão através da Tag
                        p:setTouchingTheFloor(true)
                    end
                end
            end
        end

        -----------------Plataforma-------------------
        if((objA:type() == "Platform") or (objB:type() == "Platform")) then --Se tiver Player e Platform envolvido na colisão

            if (normX == 0) and (normY == 1) then -- Vê se o player está acima
                coll:setEnabled(true) -- Habilita o contato entre o player e a plataforma
                for i, p in pairs(players) do --Percorre por todos os Players da lista players
                    if (tagA == p.tag) or (tagB == p.tag) then --Verifica qual dos Players estava na colisão através da Tag
                        if (not p:getCrossedThePlatform()) then
                            p:setTouchingTheFloor(true)
                        else
                            local linVelX = p.body:getLinearVelocity()
                            p.body:setLinearVelocity(linVelX, 0) --Zera a velocidade linear Y do Player antes que seja somado ao próximo pulo
                            p:setCrossedThePlatform(false)
                        end
                    end
                end
            else -- se o player não estiver por cima da plataforma
                coll:setEnabled(false) -- desabilita o contato entre o player e a plataforma
                if (objA:type() == "Player") then
                    objA:setCrossedThePlatform(true) -- Ativa a Flag de verificação se passou por dentro da plataforma
                else
                    objB:setCrossedThePlatform(true)
                end
            end
        end
        -------------------Parede---------------------
        if((objA:type() == "Wall") or (objB:type() == "Wall"))then --Se tiver Player e Wall envolvido na colisão
            for i, p in pairs(players) do --Percorre por todos os Players da lista players
                if (tagA == p.tag) or (tagB == p.tag) then --Verifica qual dos Players estava na colisão através da Tag
                    p:setWallJumpVector(normX,normY, objA, objB)
                    p:setTouchingTheWall(true)
                end
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

    if ((objA:type() == "Player") or (objB:type() == "Player")) then --Verifica se a colisão ocorreu com algum objeto do tipo
        ----------------------Chão------------------------
        if((objA:type() == "Floor") or (objB:type() == "Floor"))then --Se tiver Player e Floor envolvido na colisão
            for i, p in pairs(players) do --Percorre por todos os Players da lista players
                if (tagA == p.tag) or (tagB == p.tag) then --Verifica se a tag do player é igual a tag do objeto da colisão
                    p:setTouchingTheFloor(false)
                end
            end
        end
        -----------------Plataforma-------------------
        if((objA:type() == "Platform") or (objB:type() == "Platform"))then --Se tiver Player e Platform envolvido na colisão
            for i, p in pairs(players) do --Percorre por todos os Players da lista players
                if (tagA == p.tag) or (tagB == p.tag) then --Verifica se a tag do player é igual a tag do objeto da colisão
                    p:setTouchingTheFloor(false)
                end
            end
        end
        -------------------Parede---------------------
        if((objA:type() == "Wall") or (objB:type() == "Wall"))then --Se tiver Player e Wall envolvido na colisão
            for i, p in pairs(players) do --Percorre por todos os Players da lista players
                if (tagA == p.tag) or (tagB == p.tag) then --Verifica se a tag do player é igual a tag do objeto da colisão
                    p:setTouchingTheWall(false)
                end
            end
        end
    end
    text = text.."\n"..tagA.." parou de colidir com "..tagB --Temporário
end

function menu:enter()
    self.selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados
    buttons = { newButton("imagens/Sprite-0001.png","imagens/Sprite-0002.png", windowWidth/2, windowHeight/2),
                newButton("imagens/Exit-0001.png","imagens/Exit-0002.png", windowWidth/2, 70 + windowHeight/2)}
end

function menu:update(dt) -- runs every frame
    -----Joystick
    if (joysticks ~= nil) then --Se tiver joystick conectado
        for i, j in pairs(joysticks) do --Percorre por todos os objetos da Lista
            local direcao = j:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama

            if(direcao ~= 0) then
                if direcao > 0 then
                    self.selcBtn = self.selcBtn + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                elseif direcao < 0 then
                    self.selcBtn = self.selcBtn - 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                end
            end
        end
    end
    -------

    if self.selcBtn > 2 then
        self.selcBtn = 1
    elseif self.selcBtn < 1 then
        self.selcBtn = 2
    end

    for i, p in ipairs(buttons) do --Percorre por todos os Botoes da Lista
        if i == self.selcBtn then
            p:update(true)
        else
            p:update(false)
        end
    end
end

function menu:keypressed(key)
    print (self.selcBtn)
    if key == "up" then
        self.selcBtn = self.selcBtn - 1
    elseif key == "down" then
        self.selcBtn = self.selcBtn + 1
    end
    if key == "return" then
        if self.selcBtn == 1 then
            Gamestate.switch(game)
        elseif self.selcBtn == 2 then
            love.event.quit()
        end
    end
end

function menu:joystickpressed(joystick, button)
    if button == 3 then -- A
        if self.selcBtn == 1 then
            Gamestate.switch(game)
        elseif self.selcBtn == 2 then
            love.event.quit()
        end
    end
end

function menu:draw()
    for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
        p:drawMe()
    end
end

function pause:enter(from)
    self.from = from -- salva o estado anterior
    self.selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados
    buttons = { newButton("imagens/Continue1.png","imagens/Continue2.png", windowWidth/2, windowHeight/2),
                newButton("imagens/Menu Inicia1.png","imagens/Menu Inicia2.png", windowWidth/2, 70 + windowHeight/2)}
end

function pause:update(dt) -- runs every frame
        -----Joystick
        if (joysticks[1] ~= nil) then --Se tiver joystick conectado
            local direcao = joysticks[1]:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama

            if(direcao ~= 0) then
                if direcao > 0 then
                    self.selcBtn = self.selcBtn + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                elseif direcao < 0 then
                    self.selcBtn = self.selcBtn - 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                end
            end
        end
        -------

        if self.selcBtn > 2 then
            self.selcBtn = 1
        elseif self.selcBtn < 1 then
            self.selcBtn = 2
        end

        for i, p in ipairs(buttons) do --Percorre por todos os Botoes da Lista
            if i == self.selcBtn then
                p:update(true)
            else
                p:update(false)
            end
        end
end

function pause:keypressed(key)
    if key == "up" then
        self.selcBtn = self.selcBtn - 1
    elseif key == "down" then
        self.selcBtn = self.selcBtn + 1
    end
    if key == "return" then
        if self.selcBtn == 1 then
            --self.background = love.graphics.setBackgroundColor(5/255, 155/255, 1)  --Azul - rgb(RED, GREEN, BLUE, ALPHA) só aceita valores entre 0 e 1 para cada campo ex: (255/255, 20/255, 60/255, 1)
            Gamestate.pop()
        elseif self.selcBtn == 2 then
            Gamestate.switch(menu)
        end
    end
end

function pause:joystickpressed(joystick, button)
    if joystick == self.from:getJoystickPauser() then
        if button == 3 then -- A
            if self.selcBtn == 1 then
                Gamestate.pop() --Retorna de onde parou
            elseif self.selcBtn == 2 then
                Gamestate.switch(menu) -- Vai para o Menu Inicial
            end
        end
        if button == 10 then
            Gamestate.pop() --Retorna de onde parou
        end
    end
end

function pause:draw()
    self.from:draw() -- Desenha o frame do estado anterior
    love.graphics.setColor(1, 1, 1)
    for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
        p:drawMe()
    end
end
