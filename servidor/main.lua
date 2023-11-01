bitser = require 'bitser'
sock = require 'sock'

jogadores = {}

function spawnPlayer()
    return {
        x = 0,
        y = 0,
        nome = "jogador"
    }
end

server = sock.newServer('0.0.0.0', 22122, 10)
server:setSerialization(bitser.dumps, bitser.loads)


server:on("connect", function (data, cliente)
    local idx = cliente:getIndex()
    local novoJogador = spawnPlayer()
    print(data)
    jogadores[idx] = novoJogador
    server:sendToAllBut(cliente, "novoJogador", {
        idx,
        novoJogador.x,
        novoJogador.y,
        novoJogador.nome
    })
    cliente:send("spawn", {
        idx,
        novoJogador.x,
        novoJogador.y
    })
    for indice, jogador in pairs(jogadores) do
        if jogador ~= novoJogador then
            cliente:send("estado", {
                indice,
                jogador.x,
                jogador.y,
                jogador.nome
            })
        end
    end
end)


server:on("disconnect", function (data, client)
    local idx = client:getIndex()
    jogadores[idx] = nil
    server:sendToAll("desconectado", idx)
end)


server:setSchema("move",{
    "x",
    "y"
})

server:on("move", function (dados, cliente)
    local idx = cliente:getIndex()
    jogadores[idx].x = dados.x
    jogadores[idx].y = dados.y
end)

server:on("name", function (nome, cliente)
    local idx = cliente:getIndex()
    jogadores[idx].nome = nome
end)

tempo = 0
refresh_rate = 1/30
function love.update(dt)
    server:update()
    tempo = tempo + dt
    if tempo > refresh_rate then
        tempo = 0
        for indice, jogador in pairs(jogadores) do
            local client = server:getClientByIndex(indice)
            server:sendToAllBut(client, "estado", {
                indice,
                jogador.x,
                jogador.y,
                jogador.nome
            })
        end
    end
end
