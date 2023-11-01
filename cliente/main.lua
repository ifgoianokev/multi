PLAYER_WIDTH = 100
PLAYER_HEIGHT = 100
SPEED = 25

game = {}


SCREEN_WIDTH, SCREEN_HEIGHT = love.window.getMode()

Gamestate = require 'gamestate'
sock = require 'sock'
bitser = require 'bitser'

font_google = love.graphics.newFont("PlaypenSans.ttf", 30)
require 'insert_name'




player = nil
jogadores = {}

cliente = sock.newClient("10.2.129.107", 22122)
cliente:setSerialization(bitser.dumps, bitser.loads)

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(insertName)
end


cliente:setSchema("novoJogador", {
    "idx",
    "x",
    "y",
    "nome"
})

cliente:on("novoJogador", function (dados)
    jogadores[dados.idx] = {
        x = dados.x,
        y = dados.y,
        nome = dados.nome
    }
end)




cliente:setSchema("estado", {
    "idx",
    "x",
    "y",
    "nome"
})

cliente:on("estado", function (dados)
    local jogador = jogadores[dados.idx]
    if jogador == nil then
        jogador = {
            x = dados.x,
            y = dados.y,
            nome = dados.nome
        }
        jogadores[dados.idx] = jogador
    else
        jogador.x = dados.x
        jogador.y = dados.y
        jogador.nome = dados.nome
    end
end)



cliente:setSchema("spawn", {
    "idx",
    "x",
    "y"
})

cliente:on("spawn", function (dados)
    player = {
        x = dados.x,
        y = dados.y,
        nome = nomeDoJogador
    }
    jogadores[dados.idx] = player
end)


cliente:on("desconectado", function (idx)
    jogadores[idx] = nil
end)

cliente:connect()
function game:enter()
    cliente:send("name", nomeDoJogador)
    love.graphics.setFont(love.graphics.newFont(
        "PlaypenSans.ttf", 16
    ))
end


function love.update()
    cliente:update()
end

function game:update()
    if player == nil then
        return
    end
    local direcaox = 0
    local direcaoy = 0
    local dir, esq, cima, baixo
    dir = love.keyboard.isDown("d", "right")
    esq = love.keyboard.isDown("a", "left")
    cima = love.keyboard.isDown("w", "up")
    baixo = love.keyboard.isDown("s", "down")
    moveu = dir or esq or cima or baixo

    if dir then direcaox = direcaox + 1 end
    if esq then direcaox = direcaox - 1 end
    if cima then direcaoy = direcaoy - 1 end
    if baixo then direcaoy = direcaoy + 1 end

    if moveu then
        player.x = player.x + direcaox*SPEED
        player.y = player.y + direcaoy*SPEED
        cliente:send("move", {player.x, player.y})
    end
end


function game:draw()
    if player == nil then
        return
    end
    for idx, jogador in pairs(jogadores) do
        local cor = {1,1,1}
        if jogador == player then
            cor = {1,0,0}
        end
        love.graphics.setColor(cor)
        love.graphics.rectangle(
            "fill",
            jogador.x,
            jogador.y,
            PLAYER_WIDTH,
            PLAYER_HEIGHT
        )
        love.graphics.setColor(0,1,0)
        love.graphics.print(jogador.nome, jogador.x, jogador.y)
    end
end

