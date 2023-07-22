;Lovense_Gamemode_Bridge.au3 by DJBeatstar
;Erstellt mit ISN AutoIt Studio v. 1.15
;*****************************************

;Make this script high DPI aware
;AutoIt3Wrapper directive for exe files, DllCall for au3/a3x files
#AutoIt3Wrapper_Res_HiDpi=y
If not @Compiled then DllCall("User32.dll", "bool", "SetProcessDPIAware")

#include "WinHttp.au3"
#include "APILib.au3"

Global $sIP =  "192.168.178.104"
Global $iPort =  20010

$jsonToys = _gettoys ($sIP, $iPort)
ConsoleWrite($jsonToys & @CRLF)

_hushvibe ($sIP, $iPort, 5)
sleep (1000)
_hushvibe ($sIP, $iPort, 10)
sleep (1000)
_hushvibe ($sIP, $iPort, 15)
sleep (1000)
_hushvibe ($sIP, $iPort, 20)
sleep (1000)
_hushvibe ($sIP, $iPort, 0)
sleep (1000)