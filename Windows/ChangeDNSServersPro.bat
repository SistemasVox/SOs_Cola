@echo off
SETLOCAL EnableDelayedExpansion

echo.
echo Interfaces de Rede:
echo.

set i=0
for /f "tokens=1,4*" %%a in ('netsh interface ipv4 show interfaces ^| findstr /R /C:"^[ ]*[0-9]"') do (
    set /a i+=1
    echo !i!. %%c
    set "interface!i!=%%c"
)

echo.
set /p "selection=Selecione o numero da interface que voce deseja alterar: "
set "interfaceName=!interface%selection%!"

set dnsServers=8.8.8.8,8.8.4.4,1.1.1.1,1.0.0.1,208.67.222.222,208.67.220.220,216.146.35.35,216.146.36.36,8.26.56.26,8.20.247.20,156.154.70.22,156.154.71.22,76.76.19.19,76.223.122.150
set dnsServers=!dnsServers:,= !

set j=1
for %%a in (!dnsServers!) do (
    if !j! equ 1 (
        echo netsh interface ipv4 set dnsservers "!interfaceName!" static %%a primary
        netsh interface ipv4 set dnsservers "!interfaceName!" static %%a primary
    ) else (
        echo netsh interface ipv4 add dnsservers "!interfaceName!" %%a index=!j!
        netsh interface ipv4 add dnsservers "!interfaceName!" %%a index=!j!
    )
    set /a j+=1
)

echo.
echo Servidores DNS alterados para a interface !interfaceName!
pause
