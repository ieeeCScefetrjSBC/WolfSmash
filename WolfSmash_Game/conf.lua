function love.conf( t )
    t.identity = nil                -- define o local do save do jogo
    t.version = "11.2"              -- A versão do love2d para qual o jogo foi feito.
    t.console = false               -- Funciona só no windows, permite mostrar ou esconder o console quanddo o jogo é aberto
    t.extenalstorage = true         -- Salvar e ler arquivos externos em dispositivo android

    t.window.title = "Smash da Byte" -- título que aparece na janela do jogo
    t.window.icon = nil             -- Definir o Icone do jogo através de um caminho.
    t.window.widht = 800            -- Define a largura da janela do jogo
    t.window.height = 600           -- Define a Altura da janela do jogo
    t.window.borderless = false     -- Desabilita a borda da janela caso seja true
    t.window.resizeble = false      -- Habilita o redimencionamento da tela caso seja true
    t.window.minwidht = 400         -- Estabelece o valor minimo da largura da janela se o resizeble for true.
    t.window.minheight = 300        -- Estabelece o valor minimo da altura da janela se o resizeble for true.
    t.window.fullscreen = false     -- deixa em tela cheia se for true
    t.window.fullscreentype = "desktop"
    t.window.vsync = false         -- Sincronização vertical
    t.window.msaa = 0              -- Anti-aliasing
    t.window.display = 1           --
    t.window.x = nil               -- posição x da janela do jogo
    t.window.y = nil               -- posição y da janela do jogo


    --todos os módulos a baixo, vem por padrão com o valor True
    t.modules.audio = true          -- Ativa ou desativa recursos de audio
    t.modules.event = true          -- desativa eventos como teclas precionadas, toques e etc.
    t.modules.graphics = true       -- habilita a renderização de gráficos na tela do software
    t.modules.image = true          -- 
    t.modules.joystick = true       -- Permite a utilização de controle
    t.modules.kayboard = true       -- Permite a utilização do teclado
    t.modules.math = true           -- Permite a utilização de calculos matemáticos
    t.modules.mouse = true          -- Permite a utilização de mouse
    t.modules.physics = true        -- Permite a utilização da simulação de fisica
    t.modules.sound = true          -- habilita a decodificação de arquivos de som 
    t.modules.system = true 
    t.modules.time = true
    t.modules.touch = false         -- reconhece o toque na tela
    t.modules.video = true          -- permite a decodificação e controle dos aquivos de video
    t.modules.window = true 
    t.modules.thread = true         -- habilita processos paralelos em multiprocessadores 

end