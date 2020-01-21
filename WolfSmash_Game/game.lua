
-- Game class
Game = {}
-- Game constructor
function Game.new(keymaps, allPlayers)
    local o = {}
    o.background = love.graphics.newImage("images/bg2.png")
    o.playerSectionScreen = allPlayers
    o.mainMenu = nil
    o.players = {nil, nil}
    o.statusBars = {nil, nil}
    o.keymap = keymaps
    o.fight = nil
    o.font = love.graphics.newFont("fonts/visitor1.ttf", 35)
    o.smallfont = love.graphics.newFont("fonts/visitor1.ttf", 18)
    o.fighting = false
    o.menuSelected = {1,1}
    setmetatable(o, { __index = Game })
    return o
end
-- handle key events
function Game:keypressed(key)
    -- if at the character select menu
    if self.fighting == false then
        for i=1,2 do
            if self.players[i] == nil then
                -- change selected character
                if self.keymap[i]["left"] == key then
                    self.menuSelected[i] = (((self.menuSelected[i] - 1) - 1) % #self.playerSectionScreen) + 1
                elseif self.keymap[i]["right"] == key then
                    self.menuSelected[i] = (((self.menuSelected[i] - 1) + 1) % #self.playerSectionScreen) + 1
                -- executes character selection
                elseif (self.keymap[i]["punch"] == key) or (self.keymap[i]["kick"] == key) then
                    self.players[i] = self.playerSectionScreen[self.menuSelected[i]]
                end
            end
        end
        -- if both players have chosen characters, start the fight
        if self.players[1] ~= nil and self.players[2] ~= nil then
            self:startFight()
        end
    end
end
