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
selection = Gamestate.new()
victory = Gamestate.new()
credits = Gamestate.new()
mute = false

function love.load()
    -- love.audio.setVolume(0.1) -- master volume
    love.mouse.setVisible(false) --Esconde o cursor da tela
    love.physics.setMeter(64) -- 1 metro = 64 pixels
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

----------------------------ESTADO MENU-------------------------------------------------
function menu:init()
    self.music = love.audio.newSource("audio/Music/screw_crew_menu.ogg", "stream") -- new audio source
    self.music:setVolume(0.3)
    self.BSound = love.audio.newSource("audio/SFX/other_buttons.ogg", "static") -- Som do botão
    self.BSound:setVolume(0.5)
    self.SBSound = love.audio.newSource("audio/SFX/play_button.ogg", "static")
    self.SBSound:setVolume(0.5)
    self.background = love.graphics.newImage("imagens/Menu/FundoMenu+Monitor+Logo.png")
end

function menu:enter()
    self.selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados
    buttons = { newButton("imagens/Menu/BotaoStartClaro.png","imagens/Menu/BotaoStartEscuro.png", windowWidth/2, windowHeight/2 + 60),
                newButton("imagens/Menu/BotaoCreditsClaro.png","imagens/Menu/BotaoCreditsEscuro.png", windowWidth/2, windowHeight/2 + 60 + 72 + 24),
                newButton("imagens/Menu/BotaoExitClaro.png","imagens/Menu/BotaoExitEscuro.png", windowWidth/2, windowHeight/2 + 60 + 72 + 24 + 9 + 54 + 24)}
    if mute then
        love.audio.setVolume(0) -- master volume
        buttons[4] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
    else
        love.audio.setVolume(1) -- master volume
        buttons[4] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
    end
end

function menu:update(dt) -- runs every frame
    self.music:play() -- play on awake

    -----Joystick
    if (joysticks ~= nil) then --Se tiver joystick conectado
        for i, j in pairs(joysticks) do --Percorre por todos os objetos da Lista
            local direcao = j:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama

            if(direcao ~= 0) then
                if direcao > 0 then
                    self.selcBtn = self.selcBtn + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    self.BSound:stop()  -- interrompe e toca de novo
                    self.BSound:play()
                    love.timer.sleep(0.1666)
                elseif direcao < 0 then
                    self.selcBtn = self.selcBtn - 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                    self.BSound:stop()  -- interrompe e toca de novo
                    self.BSound:play()
                end
            end
        end
    end
    -------

    if self.selcBtn > 4 then
        self.selcBtn = 1
    elseif self.selcBtn < 1 then
        self.selcBtn = 4
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
    if key == "up" or key == "w" then
        self.selcBtn = self.selcBtn - 1
        self.BSound:stop()  -- interrompe e toca de novo
        self.BSound:play()
    elseif key == "down" or key == "s" then
        self.selcBtn = self.selcBtn + 1
        self.BSound:stop()  -- interrompe e toca de novo
        self.BSound:play()
    end
    if key == "return" then
        if self.selcBtn == 1 then
            self.BSound:stop()  -- interrompe e toca de novo
            self.SBSound:play()
            Gamestate.switch(selection)
        elseif self.selcBtn == 2 then

        elseif self.selcBtn == 3 then
            love.event.quit()

        elseif self.selcBtn == 4 then
            mute = not mute
            if mute then
                love.audio.setVolume(0) -- master volume
                buttons[4] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            else
                love.audio.setVolume(1) -- master volume
                buttons[4] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            end
        end
    end
end

function menu:joystickpressed(joystick, button)
    if button == 3 then -- A
        if self.selcBtn == 1 then
            self.BSound:stop()  -- interrompe e toca de novo
            self.SBSound:play()
            Gamestate.switch(selection)
        elseif self.selcBtn == 2 then
            Gamestate.switch(credits)
        elseif self.selcBtn == 3 then
            love.event.quit()

        elseif self.selcBtn == 4 then
            mute = not mute
            if mute then
                love.audio.setVolume(0) -- master volume
                buttons[4] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            else
                love.audio.setVolume(1) -- master volume
                buttons[4] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            end
        end
    end
end

function menu:draw()
    love.graphics.setColor( 1, 1, 1)-- Branco
    love.graphics.draw(self.background, 0, 0)
    for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
        p:drawMe()
    end
end

----------------------------CREDITOS-------------------------------------------------
function credits:init()
    self.monitor = love.graphics.newImage("imagens/Menu/MolduraMonitorSBrilho.png")
    self.text = love.graphics.newImage("imagens/Menu/Credits.png")
end

function credits:enter(previous)
    previous.music:stop()
end

function credits:keypressed(key)
    if key == 'escape' or key == 'p' then
        Gamestate.switch(menu) -- Vai para o Menu Inicial
    end
end

function credits:joystickpressed(joystick, button)
    if button == 10 or button == 2 then -- Start
        self.joystickPause = joystick
        Gamestate.switch(menu) -- Vai para o Menu Inicial
    end
end

function credits:draw()
    love.graphics.draw(self.text, 85, 85)
    love.graphics.draw(self.monitor, 0, 0)
end

----------------------------ESTADO SELEÇÂO-------------------------------------------------
function selection:init()
    self.background = love.graphics.newImage("imagens/Menu/FundoMenu+Monitor.png")
end
function selection:enter(previous)
    self.previous = previous
    self.players = {nil, nil} --Selva os personagens selecionados pelos jogadores
    self.lock = {false,false}
    self.selcBtn ={1,1} --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    self.joysticks = love.joystick.getJoysticks() -- Pega a lista de Joysticks conectados
    options1 = {    newButton("imagens/Icones/Robo2.png","imagens/Icones/Robo2Escuro.png", windowWidth/2 - 128, windowHeight/2 - 128 - 25),
                    newButton("imagens/Icones/Robo3.png","imagens/Icones/Robo3Escuro.png", windowWidth/2 - 128, windowHeight/2),
                    newButton("imagens/Icones/Robo4.png","imagens/Icones/Robo4Escuro.png", windowWidth/2 - 128, windowHeight/2 + 128 + 25)
                }

    options2 = {    newButton("imagens/Icones/Robo2.png","imagens/Icones/Robo2Escuro.png", windowWidth/2 + 128, windowHeight/2 - 128 - 25), --botoes com os personagens para os dois Players
                    newButton("imagens/Icones/Robo3.png","imagens/Icones/Robo3Escuro.png", windowWidth/2 + 128, windowHeight/2),
                    newButton("imagens/Icones/Robo4.png","imagens/Icones/Robo4Escuro.png", windowWidth/2 + 128, windowHeight/2 + 128 + 25)
                }

    options = {options1, options2}
end

function selection:update(dt) -- runs every frame
    self.previous.music:play() -- play on awake
    if self.players[1] ~= nil and self.players[2] ~= nil then
        Gamestate.switch(game)
    end

    --------------Joystick-------------------
    if (joysticks ~= nil) then --Se tiver joystick conectado
        for i, j in pairs(joysticks) do --Percorre por todos os objetos da Lista
            if not self.lock[i] then
                local direcao = j:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama
                if(direcao ~= 0) then
                    if direcao > 0 then
                        self.selcBtn[i] = self.selcBtn[i] + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        love.timer.sleep(0.1666)
                    elseif direcao < 0 then
                        self.selcBtn[i] = self.selcBtn[i] - 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        love.timer.sleep(0.1666)
                    end
                end
            end
        end
    end
    --------------------------------------------

    -- Limita o os botões entre 1 e 2
    for i = 1, #self.selcBtn do
        if self.selcBtn[i] > 3 then
            self.selcBtn[i] = 1
        elseif self.selcBtn[i] < 1 then
            self.selcBtn[i] = 3
        end
    end

    for i, o in pairs(options) do --Percorre por todas as Opções da Lista
        for j, b in pairs(o) do --Percorre por todos os Botoes das Opções
            if j == self.selcBtn[i] then -- Se o botão de indice j for igual ao botão selecionado da opção
                b:update(true)
            else
                b:update(false)
            end
        end
    end
end

function selection:keypressed(key)
    for i, lock in ipairs(self.lock) do --Percorre pela lista lock do Selection
        if joysticks[i] == nil then
            if not lock then
                if i == 2 then
                    if key == "up" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        self.selcBtn[i] = self.selcBtn[i] - 1
                    elseif key == "down" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        self.selcBtn[i] = self.selcBtn[i] + 1
                    end
                elseif i == 1 then
                    if key == "w" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        self.selcBtn[i] = self.selcBtn[i] - 1
                    elseif key == "s" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.BSound:play()
                        self.selcBtn[i] = self.selcBtn[i] + 1
                    end
                end
            end
            for i, b in ipairs(self.selcBtn) do --Percorre pela lista selcBtn do Selection
                if i == 2 then
                  if (not self.lock[i]) then
                    if key == "return" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.SBSound:play()
                        self.players[i] = b
                        self.lock[i] = true
                    end
                  end
              elseif i == 1 then
                  if (not self.lock[i]) then
                    if key == "f" then
                        self.previous.BSound:stop()  -- interrompe e toca de novo
                        self.previous.SBSound:play()
                        self.players[i] = b
                        self.lock[i] = true
                    end
                  end
                end
            end
        end
    end
end

function selection:joystickpressed(joystick, button)
    for i, joy in ipairs(joysticks) do --Percorre pela lista de joysticks conectado
        if joy == joystick then --Verifica qual joystick que apertou o botão
            if button == 3 then
                self.previous.BSound:stop()  -- interrompe e toca de novo
                self.previous.SBSound:play()
                self.players[i] = self.selcBtn[i]
                self.lock[i] = true
            end
        end
    end
end

function selection:draw()
    love.graphics.setColor( 1, 1, 1)-- Branco
    love.graphics.draw(self.background, 0, 0)
    for i, o in ipairs(options) do --Percorre por todas as Opções da Lista
        for j, b in ipairs(o) do --Percorre por todos os Botoes das Opções
            b:drawMe()
        end
    end
end

----------------------------ESTADO GAME-------------------------------------------------
function game:init()
    self.music = love.audio.newSource("audio/Music/screw_crew_theme.ogg", "stream") -- new audio source
    self.music:setVolume(0.3)
    self.background = love.graphics.newImage("imagens/Arena Background.png")
    self.rounds = {
        love.graphics.newImage("imagens/LedsRound0.png"),
        love.graphics.newImage("imagens/LedsRound1.png"),
        love.graphics.newImage("imagens/LedsRound2.png"),
        love.graphics.newImage("imagens/LedsRound3.png"),
        love.graphics.newImage("imagens/LedsRound4.png"),
        love.graphics.newImage("imagens/LedsRound5.png")
    }
end

function game:enter(previous)

    self.world = love.physics.newWorld(0, 9.81 * 64 , true) -- (gravidade no eixo X, Graviade no exio Y, se o corpo pode ficar parado "sleep")
    self.world:setCallbacks(beginContact, endContact, preSolve, nil) --Detecta contatos no mundo
    self.joystickPause = nil
    self.joystickWinner = nil
    previous.previous.music:stop()

    self.previous = previous
    self.lostRound = {play0 = 0, play1 = 0}
    self.maxRounds = 5

    players = {}
    players.p0 = newPlayer("player0", self.world, self.previous.joysticks[1], "imagens/Spritsheet_Robots.png", self.previous.players[1], 325, 325, 700 , 400, "w", "a", "d") --cria um "player" definido no aquivo player.lua
    players.p1 = newPlayer("player1", self.world, self.previous.joysticks[2], "imagens/Spritsheet_Robots.png", self.previous.players[2], windowWidth - 325, 325, 700 , 400, "up", "left", "right") --cria um "player" definido no aquivo player.lua
    objetos = {} --Lista de Objetos
    objetos.ch1 = newFloor("Floor", self.world, windowWidth/2, 0, windowWidth, 50, nil)
    objetos.ch2 = newFloor("Floor", self.world, windowWidth/2, windowHeight-25, windowWidth, 50, nil)
    objetos.plt1 = newPlatform("Platform", self.world, windowWidth/2, windowHeight/2 - windowHeight*0.15, 150, 20, nil)
    objetos.plt2 = newPlatform("Platform", self.world, windowWidth/2 + 400, windowHeight/2 + windowHeight*0.2, 150, 20, nil)
    objetos.plt3 = newPlatform("Platform", self.world, windowWidth/2 - 400, windowHeight/2 + windowHeight*0.2, 150, 20, nil)
    objetos.wl1 = newWall("Wall", self.world, windowWidth, windowHeight/2-25, 50, windowHeight)
    objetos.wl2 = newWall("Wall", self.world, 0, windowHeight/2-50, 50, windowHeight)
    text = " "
end

function game:update(dt)
    self.music:play() -- play on awake
    self.world:update(dt)
    for i, p in pairs(players) do --Percorre por todos os Players da Lista
        p:update(dt)
        if (not p.isAlive) then
            if p.tag == "player0" then
                self.lostRound.play0 = self.lostRound.play0 + 1
                p:resetPlayer(500, 350)
            else
                self.lostRound.play1 = self.lostRound.play1 + 1
                p:resetPlayer(500, 350)
            end
        end
    end

    if string.len(text) > 800 then    -- Limpa o Texto caso esteja muito grande
        text = " "
    end

    ---------------- ROUNDS --------------------
      if self.lostRound.play1 == self.maxRounds then
        winner = "P1"
        if self.previous.joysticks[1] ~= nil then
            self.joystickWinner = self.previous.joysticks[1]
        end
        Gamestate.switch(victory)
      elseif self.lostRound.play0 == self.maxRounds then
        winner = "P2"
        if self.previous.joysticks[2] ~= nil then
            self.joystickWinner = self.previous.joysticks[2]
        end
        Gamestate.switch(victory)
      end
    ------------------------------------------------
end

function game:keypressed(key)
    if key == 'escape' or key == 'p' then
        Gamestate.push(pause)
    end
end

function game:joystickpressed(joystick, button)
    if button == 10 then -- Start
        self.joystickPause = joystick
        Gamestate.push(pause)
    end
end

function game:draw()
    love.graphics.setColor( 1, 1, 1)-- Branco
    love.graphics.draw(self.background, 0, 0)

    for i, p in pairs(objetos) do --Percorre por todos os objetos da Lista
        if p.tag == "Platform" then
            p:drawMySprite() --desenha o objeto na tela
        end
    end

    for i,p in pairs(players) do --Desenha os Players da lista Player
       p:drawMySprite()
       -- p:drawMe()
    end
    ------------Desenhar Contador de Round------------------------
    love.graphics.draw(self.rounds[self.lostRound.play1 + 1], 35, 70, nil, 2, -2)
    love.graphics.draw(self.rounds[self.lostRound.play0 + 1], windowWidth - 35, 70, nil, -2, -2)
    ----------------------------------------------------------------
    -- self.textoTemporario()
end

function game:textoTemporario()
    love.graphics.setColor( 0, 0, 0)  --PRETO
    love.graphics.print(text, 10, 10)

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

----------------------------ESTADO PAUSE-------------------------------------------------
function pause:init()
    self.background = love.graphics.newImage("imagens/Menu/MolduraMonitor.png")
    self.music = love.audio.newSource("audio/Music/screw_crew_menu.ogg", "stream") -- new audio source
    self.music:setVolume(0.3)
    self.BSound = love.audio.newSource("audio/SFX/other_buttons.ogg", "static") -- Som do botão
    self.BSound:setVolume(0.5)
    self.SBSound = love.audio.newSource("audio/SFX/play_button.ogg", "static")
    self.SBSound:setVolume(0.5)
end

function pause:enter(previous)
    self.previous = previous -- salva o estado anterior
    previous.music:pause()
    self.selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado no Menu Inicial
    joystickPause = self.previous.joystickPause
    buttons = { newButton("imagens/Pause Botoes/ContinuePauseClaro.png","imagens/Pause Botoes/ContinuePauseEscuro.png", windowWidth/2, windowHeight/2),
                newButton("imagens/Pause Botoes/MenuPauseClaro.png","imagens/Pause Botoes/MenuPauseEscuro.png", windowWidth/2, 72 + windowHeight/2 + 24)
            }
    if mute then
        love.audio.setVolume(0) -- master volume
        buttons[3] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
    else
        love.audio.setVolume(1) -- master volume
        buttons[3] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
    end
end

function pause:update(dt) -- runs every frame
    self.music:play()
    -----Joystick
    if (joystickPause ~= nil) then --Se tiver joystick conectado
            local direcao = joystickPause:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama

            if(direcao ~= 0) then
                if direcao > 0 then
                    self.BSound:stop()  -- interrompe e toca de novo
                    self.BSound:play()
                    self.selcBtn = self.selcBtn + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                elseif direcao < 0 then
                    self.BSound:stop()  -- interrompe e toca de novo
                    self.BSound:play()
                    self.selcBtn = self.selcBtn - 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                    love.timer.sleep(0.1666)
                end
        end
    end
    -------

    if self.selcBtn > 3 then
        self.selcBtn = 1
    elseif self.selcBtn < 1 then
        self.selcBtn = 3
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
        self.BSound:stop()  -- interrompe e toca de novo
        self.BSound:play()
        self.selcBtn = self.selcBtn - 1
    elseif key == "down" then
        self.BSound:stop()  -- interrompe e toca de novo
        self.BSound:play()
        self.selcBtn = self.selcBtn + 1
    end
    if key == "return" then
        if self.selcBtn == 1 then
            self.BSound:stop()  -- interrompe e toca de novo
            self.SBSound:play()
            self.music:stop()
            Gamestate.pop()
        elseif self.selcBtn == 2 then
            self.BSound:stop()  -- interrompe e toca de novo
            self.SBSound:play()
            self.music:stop()
            Gamestate.switch(menu)
        elseif self.selcBtn == 3 then
            mute = not mute
            if mute then
                love.audio.setVolume(0) -- master volume
                buttons[3] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            else
                love.audio.setVolume(1) -- master volume
                buttons[3] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
            end
        end
    end
end

function pause:joystickpressed(joystick, button)
    if joystick == joystickPause then
        if button == 3 then -- A
            if self.selcBtn == 1 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.pop() --Retorna de onde parou
            elseif self.selcBtn == 2 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(menu) -- Vai para o Menu Inicial
            elseif self.selcBtn == 3 then
                mute = not mute
                if mute then
                    love.audio.setVolume(0) -- master volume
                    buttons[3] = newButton("imagens/Menu/BotaoSomOffClaro.png","imagens/Menu/BotaoSomOffEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
                else
                    love.audio.setVolume(1) -- master volume
                    buttons[3] = newButton("imagens/Menu/BotaoSomOnClaro.png","imagens/Menu/BotaoSomOnEscuro.png", windowWidth - 180, windowHeight/2 + 60 + 72 + 24 + 3 + 54 + 24)
                end
            end
        end
        if button == 10 then
            Gamestate.pop() --Retorna de onde parou
        end
    end
end

function pause:draw()
    self.previous:draw() -- Desenha o frame do estado anterior
    love.graphics.setColor(1, 1, 1)
    for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
        p:drawMe()
    end
    love.graphics.draw(self.background, 0, 0)
end

---------------VICTORY--------------------------------

function victory:init()
  self.music = love.audio.newSource("audio/Music/screw_crew_menu.ogg", "stream") -- new audio source
  self.music:setVolume(0.3)
  self.BSound = love.audio.newSource("audio/SFX/other_buttons.ogg", "static") -- Som do botão
  self.BSound:setVolume(0.5)
  self.SBSound = love.audio.newSource("audio/SFX/play_button.ogg", "static")
  self.SBSound:setVolume(0.5)
end

function victory:enter(previous)
    self.previous = previous -- salva o estado anterior
    previous.music:pause()
    self.selcBtn = 1 --selcBtn armazena o valor do botão que está selecionado
    joystickWinner = self.previous.joystickWinner
    buttons = { newButton("imagens/Pause Botoes/ContinuePauseClaro.png","imagens/Pause Botoes/ContinuePauseEscuro.png", windowWidth/2, 108 + windowHeight/2),
                newButton("imagens/Pause Botoes/MenuPauseClaro.png","imagens/Pause Botoes/MenuPauseEscuro.png", windowWidth/2, 108 + 72 + windowHeight/2 + 24)}
end

function victory:update(dt) -- runs every frame
        self.music:play()
        -----Joystick
        if (joystickWinner ~= nil) then --Se tiver joystick conectado
                local direcao = joystickWinner:getAxis(2) --Recebe o valor do eixo y do Analogico do fliperama

                if(direcao ~= 0) then
                    if direcao > 0 then
                        self.BSound:stop()  -- interrompe e toca de novo
                        self.BSound:play()
                        self.selcBtn = self.selcBtn + 1 --A direção dos eixos do fliperama só recebem o valor de 1 ou -1
                        love.timer.sleep(0.1666)
                    elseif direcao < 0 then
                        self.BSound:stop()  -- interrompe e toca de novo
                        self.BSound:play()
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

function victory:keypressed(key)
    if winner == "P1" then
        if key == "w" then
            self.BSound:stop()  -- interrompe e toca de novo
            self.BSound:play()
            self.selcBtn = self.selcBtn - 1
        elseif key == "s" then
            self.BSound:stop()  -- interrompe e toca de novo
            self.BSound:play()
            self.selcBtn = self.selcBtn + 1
        end
        if key == "f" then
            if self.selcBtn == 1 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(selection)
            elseif self.selcBtn == 2 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(menu)
            end
        end
    elseif winner == "P2" then
        if key == "up" then
            self.BSound:stop()  -- interrompe e toca de novo
            self.BSound:play()
            self.selcBtn = self.selcBtn - 1
        elseif key == "down" then
            self.BSound:stop()  -- interrompe e toca de novo
            self.BSound:play()
            self.selcBtn = self.selcBtn + 1
        end
        if key == "return" then
            if self.selcBtn == 1 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(selection)
            elseif self.selcBtn == 2 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(menu)
            end
        end
    end
end

function victory:joystickpressed(joystick, button)
    if joystick == joystickWinner then
        if button == 3 then -- A
            if self.selcBtn == 1 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(selection)
            elseif self.selcBtn == 2 then
                self.BSound:stop()  -- interrompe e toca de novo
                self.SBSound:play()
                self.music:stop()
                Gamestate.switch(menu) -- Vai para o Menu Inicial
            end
        end
    end
end

function victory:draw()
    self.previous:draw() -- Desenha o frame do estado anterior
    love.graphics.setColor(1, 1, 1)
    for i, p in pairs(buttons) do --Percorre por todos os Botoes da Lista
        p:drawMe()
    end
      love.graphics.setColor(1,1,1)
      if winner == "P1" then
        love.graphics.draw(love.graphics.newImage("imagens/VictoryP1.png"), windowWidth/2-264,windowHeight/2 - 250)
      elseif winner == "P2" then
        love.graphics.draw(love.graphics.newImage("imagens/VictoryP2.png"), windowWidth/2-264,windowHeight/2 - 250)
      end
end
