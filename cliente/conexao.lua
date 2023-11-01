cliente = sock:newClient(
    "10.2.129.107", 22122
)
cliente:setSerialization(bitser.dumps, bitser.loads)

cliente:setSchema("novoJogador", {
    "idx",
    "x",
    "y"
})

cliente:on("novoJogador", function (dados)
    jogadores[dados.idx] = {
        x = dados.x,
        y = dados.y
    }
end)




cliente:setSchema("estado", {
    "idx",
    "x",
    "y"
})

cliente:on("estado", function (dados)
    local jogador = jogadores[dados.idx]
    jogador.x = dados.x
    jogador.y = dados.y
end)



cliente:setSchema("spawn", {
    "idx",
    "x",
    "y"
})

cliente:on("spawn", function (dados)
    player = {
        x = dados.x,
        y = dados.y
    }
    jogadores[dados.idx] = player
end)


cliente:on("desconectado", function (idx)
    jogadores[idx] = nil
end)