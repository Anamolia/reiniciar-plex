@echo off
rem ==========================================================================
rem  Reiniciar Plex
rem  Verifica se o Plex Media Server esta respondendo e, se nao estiver,
rem  encerra o processo travado e abre o Plex de novo.
rem
rem  Uso:
rem    Duplo clique ............ verifica e reinicia so se estiver travado
rem    Reiniciar Plex.cmd /forcar  reinicia mesmo que esteja respondendo
rem    Reiniciar Plex.cmd /auto    sem perguntas nem pausa (para o
rem                                Agendador de Tarefas)
rem  Registro: %LOCALAPPDATA%\Reiniciar Plex.log
rem ==========================================================================
setlocal EnableDelayedExpansion
title Reiniciar Plex

set "PLEX_EXE=C:\Program Files\Plex\Plex Media Server\Plex Media Server.exe"
set "PLEX_URL=http://127.0.0.1:32400/identity"
set "LOG=%LOCALAPPDATA%\Reiniciar Plex.log"

set "FORCAR=0"
set "AUTO=0"
for %%a in (%*) do (
    if /i "%%a"=="/forcar" set "FORCAR=1"
    if /i "%%a"=="/auto"   set "AUTO=1"
)

if not exist "%PLEX_EXE%" (
    call :msg ERRO: Plex nao encontrado em "%PLEX_EXE%".
    goto :fim
)

rem --- 1. O Plex esta respondendo? (3 tentativas, para nao reiniciar a toa
rem        quando ele so esta ocupado por alguns segundos)
call :msg Verificando o Plex...
call :responde 3
if "!OK!"=="1" (
    if "%FORCAR%"=="1" (
        call :msg Plex respondendo, mas /forcar foi usado. Reiniciando.
    ) else if "%AUTO%"=="1" (
        call :msg Plex respondendo normalmente. Nada a fazer.
        goto :fim
    ) else (
        echo.
        echo O Plex esta respondendo normalmente.
        choice /c SN /n /m "Reiniciar mesmo assim? [S/N] "
        if errorlevel 2 goto :fim
        call :msg Reinicio pedido manualmente com o Plex respondendo.
    )
) else (
    call :msg O Plex NAO esta respondendo.
)

rem --- 2. Encerrar o processo, se existir
tasklist /fi "imagename eq Plex Media Server.exe" 2>nul | find /i "Plex Media Server.exe" >nul
if not errorlevel 1 (
    call :msg Encerrando o Plex Media Server...
    taskkill /f /im "Plex Media Server.exe" >nul 2>&1
    rem espera ate 20 s o processo sumir
    for /l %%i in (1,1,20) do (
        tasklist /fi "imagename eq Plex Media Server.exe" 2>nul | find /i "Plex Media Server.exe" >nul
        if errorlevel 1 goto :encerrado
        call :espera 1
    )
    call :msg AVISO: o processo ainda parece estar aberto. Tentando abrir mesmo assim.
) else (
    call :msg O Plex Media Server nao estava aberto.
)
:encerrado

rem --- 3. Abrir de novo
call :espera 3
call :msg Abrindo o Plex Media Server...
start "" "%PLEX_EXE%"

rem --- 4. Esperar ele responder (ate ~2 minutos)
call :responde 24
if "!OK!"=="1" (
    call :msg Pronto: o Plex voltou a responder.
) else (
    call :msg ERRO: o Plex foi aberto, mas ainda nao responde depois de 2 minutos.
    call :msg Veja o log em "%LOCALAPPDATA%\Plex Media Server\Logs".
)
goto :fim


rem ==========================================================================
rem :responde N  -> tenta N vezes (5 s entre tentativas); define OK=1 ou OK=0
:responde
set "OK=0"
for /l %%t in (1,1,%1) do (
    set "CODE=000"
    for /f %%c in ('curl.exe -s -m 10 -o nul -w "%%{http_code}" "%PLEX_URL%" 2^>nul') do set "CODE=%%c"
    if "!CODE!"=="200" (
        set "OK=1"
        exit /b
    )
    if %%t lss %1 call :espera 5
)
exit /b

rem :espera N -> pausa N segundos (funciona tambem sem janela, ao contrario
rem              do comando timeout)
:espera
set /a "_n=%1+1"
ping -n %_n% 127.0.0.1 >nul
exit /b

rem :msg texto -> mostra na tela e grava no registro com data e hora
:msg
echo %*
>>"%LOG%" echo [%date% %time:~0,8%] %*
exit /b

:fim
if "%AUTO%"=="0" (
    echo.
    pause
)
endlocal
