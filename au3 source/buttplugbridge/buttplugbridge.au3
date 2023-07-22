;buttplugbridge.au3 by DJBeatstar
;Erstellt mit ISN AutoIt Studio v. 1.14
;*****************************************

;Make this script high DPI aware
;AutoIt3Wrapper directive for exe files, DllCall for au3/a3x files
#AutoIt3Wrapper_Res_HiDpi=y
If not @Compiled then DllCall("User32.dll", "bool", "SetProcessDPIAware")

#include <websockets.au3>

Local $oWS =  Websocket_Connect('ws://127.0.0.1:12345')
