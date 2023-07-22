;websockets.au3

Func Websocket_Connect($Ws_URL, $protocol = '', $binaryType = False, $timeout = 20000)
    _IE_Emulation(True)
    If @error Then Exit MsgBox(0x40000, 'Fatal Error', 'You must install Internet Explorer 11')
    Local Static $oEvent = ObjEvent('AutoIt.Error', '')
    Local $oWS = ObjCreate("HTMLFILE")
    $Ws_URL = '"' & $Ws_URL & '"'
    If $protocol Then $Ws_URL &= ', [' & StringRegExpReplace(StringRegExpReplace($protocol, '(?i)Sec-WebSocket-Protocol:\s+', '', 1), '(\w+)', '"${1}"') & ']'
    If $binaryType = Default Then $binaryType = False
    
    With $oWS.parentwindow
        .execScript( _
                'Array.prototype.item = function(i,parseJson) {if(typeof parseJson==''undefined''){return this[i]}else{return JSON.parse(this[i])}};' & _ ;Ma thuật giúp autoit thương tác JS Array
                'Array.prototype.index = Array.prototype.item;' & _
                'var recv_data=[], event_close = [], event_error ;' & _
                'let socket = new WebSocket(' & $Ws_URL & ');' & _
                'socket.binaryType = "' & ($binaryType ? 'arraybuffer' : 'blob') & '";' & _
                'socket.onopen = function(event) {};' & _
                'socket.onmessage = function(event) {recv_data.push(event.data)};' & _
                'socket.onclose = function(event) {event_close = event};' & _
                'socket.onerror = function(error) {event_error= error.message};')
        If @error Then Return SetError(1, ConsoleWrite(@CRLF & '! [Websocket_Connect] Your IE don''t support websocket. Please update to IE11' & @CRLF & @CRLF), 0)
        
        Local $ti = TimerInit()
        Do
            Sleep(25)
            If TimerDiff($ti) > $timeout Then Return SetError(2, ConsoleWrite(@CRLF & '! [Websocket_Connect] Connect timeout' & @CRLF & @CRLF))
        Until .eval('socket.readyState') = 1
    EndWith
    
    ConsoleWrite(@CRLF & '> [Websocket_Connect] Connection established' & @CRLF & @CRLF)
    Return $oWS
EndFunc

Func Websocket_Send(ByRef $oWS, $Data = '', $timeout = 60000)
    If $Data Then $oWS.parentwindow.eval('socket').send($Data)
    Local $recv_data = $oWS.parentwindow.eval('recv_data')
    
    Local $ti = TimerInit()
    Do
        Sleep(25)
        If TimerDiff($ti) > $timeout Then Return SetError(1, ConsoleWrite('! [Websocket_Send] Receive timeout' & @CRLF & @CRLF))
    Until $recv_data.length > 0
    
    Return $recv_data
EndFunc

Func Websocket_ResetRecvData(ByRef $oWS)
    $oWS.parentwindow.eval('recv_data.splice(0, recv_data.length);')
EndFunc

Func Websocket_Close(ByRef $oWS, $Code = 1000, $Reason = '', $wait_ms = 0)
    With $oWS.parentwindow.eval('socket')
        .close()
        If .readyState >= 2 Then ConsoleWrite('> [Websocket_Close] The connection is in the process of closing...')
        
        If IsKeyword($wait_ms) Then $wait_ms = 0
        If $wait_ms > 0 Then
            If $wait_ms < 10000 Then $wait_ms = 10000
            Local $ti = TimerInit()
            Do
                Sleep(25)
                If TimerDiff($ti) > $wait_ms Then ExitLoop
            Until .readyState = 3
            If .readyState = 3 Then
                Local $event_close = $oWS.parentwindow.eval('event_close')
                ConsoleWrite('The connection is closed with Code=' & $event_close.code & ($event_close.reason ? ' and Reason=' & $event_close.reason : ''))
            EndIf
        EndIf
        
        $oWS = Null
        ConsoleWrite(@CRLF & @CRLF)
    EndWith
EndFunc




Func _IE_Emulation($vTurnOn = True) ;By Huân Hoàng
    ;https://blogs.msdn.microsoft.com/patricka/2015/01/12/controlling-webbrowser-control-compatibility/
    Local Static $isOn = False
    If $vTurnOn = True And $isOn = True Then Return
    Local Static $_Reg_BROWSER_EMULATION = '\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION'
    Local Static $_Reg_HKCU_BROWSER_EMULATION = 'HKCU\SOFTWARE' & $_Reg_BROWSER_EMULATION
    Local Static $_Reg_HKLM_BROWSER_EMULATION = 'HKLM\SOFTWARE' & $_Reg_BROWSER_EMULATION
    Local Static $_Reg_HKLMx64_BROWSER_EMULATION = 'HKLM\SOFTWARE\WOW6432Node' & $_Reg_BROWSER_EMULATION
    Local $_IE_Mode, $_AutoItExe = StringRegExp(@AutoItExe, '(?i)\\([^\\]+.exe)$', 1)[0]
    Local $_IE_Version = StringRegExp(FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe"), '^\d+', 1)
    If @error Then
        $isOn = False
        Return SetError(1, ConsoleWrite('! [_IE_Emulation]: Cannot get IE Version' & @CRLF & @CRLF), False)
    EndIf
    $_IE_Version = Number($_IE_Version[0])
    Switch $_IE_Version
        Case 10, 11
            $_IE_Mode = $_IE_Version * 1000 + 1
        Case Else
            Return SetError(2, ConsoleWrite('! [_IE_Emulation]: You must install Internet Explorer 10 and Internet Explorer 11' & @CRLF & @CRLF), False)
    EndSwitch
    If $vTurnOn Then
        If RegRead($_Reg_HKCU_BROWSER_EMULATION, $_AutoItExe) <> $_IE_Mode Then RegWrite($_Reg_HKCU_BROWSER_EMULATION, $_AutoItExe, 'REG_DWORD', $_IE_Mode)
        If RegRead($_Reg_HKLM_BROWSER_EMULATION, $_AutoItExe) <> $_IE_Mode Then RegWrite($_Reg_HKLM_BROWSER_EMULATION, $_AutoItExe, 'REG_DWORD', $_IE_Mode)
        If @AutoItX64 And RegRead($_Reg_HKLMx64_BROWSER_EMULATION, $_AutoItExe) <> $_IE_Mode Then RegWrite($_Reg_HKLMx64_BROWSER_EMULATION, $_AutoItExe, 'REG_DWORD', $_IE_Mode)
        $isOn = True
    Else
        RegDelete($_Reg_HKCU_BROWSER_EMULATION, $_AutoItExe)
        RegDelete($_Reg_HKLM_BROWSER_EMULATION, $_AutoItExe)
        If @AutoItX64 Then RegDelete($_Reg_HKLMx64_BROWSER_EMULATION, $_AutoItExe)
        $isOn = False
    EndIf
    Return True
EndFunc