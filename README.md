# Reiniciar Plex

Script para Windows que verifica se o **Plex Media Server** está respondendo e,
se ele estiver travado, encerra o processo e abre o Plex de novo.

Útil quando o Plex continua aberto no Gerenciador de Tarefas, mas para de
responder (os apps não conectam e a interface web não carrega).

## Como usar

Baixe o arquivo [`Reiniciar Plex.cmd`](Reiniciar%20Plex.cmd) e dê dois cliques nele.

O script:

1. Verifica se o Plex responde em `http://127.0.0.1:32400/identity`. Tenta 3
   vezes, com 5 segundos entre as tentativas, para não reiniciar um Plex que só
   está ocupado.
2. Se ele não responder, encerra o `Plex Media Server.exe`.
3. Abre o Plex de novo.
4. Espera até 2 minutos e avisa se ele voltou a responder.

Se o Plex estiver funcionando, o script pergunta se você quer reiniciar mesmo
assim.

### Opções

| Opção     | O que faz |
|-----------|-----------|
| `/forcar` | Reinicia mesmo que o Plex esteja respondendo. |
| `/auto`   | Não faz perguntas e não pausa no final. Serve para rodar pelo Agendador de Tarefas. |

```bat
"Reiniciar Plex.cmd" /auto
"Reiniciar Plex.cmd" /forcar
```

### Registro

Cada execução fica anotada, com data e hora, em
`%LOCALAPPDATA%\Reiniciar Plex.log`.

## Rodar automaticamente

Para o Plex se recuperar sozinho, crie uma tarefa no Agendador de Tarefas do
Windows que rode o script com `/auto` a cada 15 minutos, por exemplo. Se o Plex
estiver respondendo, o script não faz nada.

## Requisitos

- Windows 10 ou 11, que já vêm com o `curl.exe`.
- Plex Media Server instalado no local padrão,
  `C:\Program Files\Plex\Plex Media Server\`, e rodando como aplicativo (não
  como serviço do Windows). Se o seu estiver em outro lugar, mude a variável
  `PLEX_EXE` no começo do script.

## Atenção

Reiniciar o Plex interrompe quem estiver assistindo naquele momento.
