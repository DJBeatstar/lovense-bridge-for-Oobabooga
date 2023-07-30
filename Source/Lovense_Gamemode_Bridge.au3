;Lovense_Gamemode_Bridge.au3 by DJBeatstar
;Erstellt mit ISN AutoIt Studio v. 1.15
;*****************************************

;Make this script high DPI aware
;AutoIt3Wrapper directive for exe files, DllCall for au3/a3x files
#AutoIt3Wrapper_Res_HiDpi=y
If not @Compiled then DllCall("User32.dll", "bool", "SetProcessDPIAware")

; Inclusions
#include "Forms\Main.isf"

; Global Variables
Global $sToyNameGlobal = "" ; Toy Name
Global $sFunction1 = "" ; Toy Function 1
Global $sFunction2 = "" ; Toy Function 2
Global $iBattery = 0
Global $iIntensityAGlobal = 0 ; Intensitysetting 1
Global $iIntensityBGlobal = 0 ; Intensitysetting 2
Global $iActCount =  0 ; Count of Actuators on the Toy
Global $sIpGlobal =  "127.0.0.1" ; IP of the Lovense Gamemode Device
Global $iPortGlobal = "20010" ; Port of the Lovense Gamemode Device
Global $sAI_Data_Path = ""

; Global Constants
Global Const $HTTP_STATUS_OK = 200

; UI Initialisation
if FileExists("config.ini") Then 
	$sIpGlobal = IniRead ( "config.ini", "connection", "ip", "127.0.0.1" )
	$iPortGlobal = IniRead ( "config.ini", "connection", "port", "20010" )
	$sAI_Data_Path = IniRead ( "config.ini", "datapath", "path", "" )
	GUICtrlSetData($sIP, $sIpGlobal )
	GUICtrlSetData($iPort, $iPortGlobal )
	GUICtrlSetData($swAI_Data_Path, $sAI_Data_Path)
EndIf
_ActuatorA_Show(False) ; Hide Slider 1
_ActuatorB_Show (False) ; Hide Slider 2
GUISetState(@SW_SHOW, $wMain) ; Show UI

; Main Program
While 1
	
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE ; Exit Program
			IniWrite ( "config.ini", "connection", "ip", GUICtrlRead($sIP) )
			IniWrite ( "config.ini", "connection", "port", GUICtrlRead($iPort) )
			IniWrite ( "config.ini", "datapath", "path", $sAI_Data_Path )
			Exit
			
		Case $botton_scan ; Scan for Toys
			$sIpGlobal = GUICtrlRead($sIP)
			$iPortGlobal =  GUICtrlRead($iPort)
			$jsonToys = _gettoys ($sIpGlobal, $iPortGlobal)
			_config_window (_json_parse($jsonToys))
			
		Case $bBrowse ; Set the path to the AI Outputfile
			$sPath = FileOpenDialog ( "File with outputdata from the AI", @ScriptDir, "Text files (*.txt)", 2, "data.txt" )
			GUICtrlSetData($swAI_Data_Path, $sPath)
			$sAI_Data_Path =  $sPath

	EndSwitch
	
	; If AI Controll is active, reading the outputfile and sending the data to the parser to serch for instruction
	If $sToyNameGlobal <> "" Then 
		If GUICtrlRead($bActive) =  1 Then
			if FileExists($sAI_Data_Path) Then 
				$sAIOutput = FileReadLine($sAI_Data_Path)
				FileDelete($sAI_Data_Path)
				_keywordfinder($sAIOutput)
			EndIf
		EndIf		
	EndIf
	
	; Check for found Toys
	if GUICtrlRead($eToyFound) <> "" Then 
		
		; Read intensity setting
		$iSetIntensityA = GUICtrlRead($iIntensityA)
		$iSetIntensityB = GUICtrlRead($iIntensityB)
		
		If $iActCount = 1 Then ; Action when only one acuator is present on the Toy
			if $iSetIntensityA <> $iIntensityAGlobal Then 
				_toy_actuate ($sIpGlobal, $iPortGlobal, $sToyNameGlobal, $iSetIntensityA)
				$iIntensityAGlobal = $iSetIntensityA
			EndIf
		Else   ; Action when two acuators are present on the Toy
			if $iSetIntensityB <> $iIntensityBGlobal Or $iSetIntensityA <> $iIntensityAGlobal Then 
				_toy_actuate ($sIpGlobal, $iPortGlobal, $sToyNameGlobal, $iSetIntensityA, $iSetIntensityB)
				$iIntensityAGlobal = $iSetIntensityA
				$iIntensityBGlobal = $iSetIntensityB
			EndIf
		EndIf 
			
	EndIf 
			
WEnd

; UDF Section

; Getting json data from the connected toy.
Func _gettoys($sIPlib, $iPortlib)
	
	$sPost = HttpPost('http://' & $sIPlib & ':' & $iPortlib & '/command', '{"command":"GetToys"}')
	Return $sPost
	
EndFunc

; Toy controll
Func _toy_actuate ($sIpFunc, $iPortFunc, $sToyName, $iActuator1, $iActuator2 = 0) 
	
	$jsonToys = _gettoys ($sIpGlobal, $iPortGlobal)
	$aBattery = _json_parse($jsonToys)
	GUICtrlSetData($iwBattery, $aBattery[2])
	ConsoleWrite($aBattery[2] & @CRLF)
	if $sToyname = "hush" Then 
		$sPost = HttpPost('http://' & $sIpFunc & ':' & $iPortFunc & '/command', '{"command":"Function","action":"Vibrate:' & $iActuator1 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
	Else
		If $iActuator1 <> $iIntensityAGlobal Then 
			$sPost = HttpPost('http://' & $sIpFunc & ':' & $iPortFunc & '/command', '{"command":"Function","action":"' & $sFunction1 & ':' & $iActuator1 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
				ConsoleWrite('{"command":"Function","action":"' & $sFunction1 & ':' & $iActuator1 & '","timeSec":0,"stopPrevious":0,"apiVer":1}' & @CRLF)
		EndIf 
		If $iActuator2 <> $iIntensityBGlobal Then
			$sPost = HttpPost('http://' & $sIpFunc & ':' & $iPortFunc & '/command', '{"command":"Function","action":"' & $sFunction2 & ':' & $iActuator2 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
				ConsoleWrite('{"command":"Function","action":"' & $sFunction2 & ':' & $iActuator2 & '","timeSec":0,"stopPrevious":0,"apiVer":1}' & @CRLF)
		EndIf
	EndIf 

EndFunc 

; Quick and dirty json parsing to extract usefull data from the json data recived from the toy.
Func _json_parse($sDataIn)
	
	$aDatasplit1 =  StringSplit($sDataIn, ",")
	$aDatasplit1[3] =  StringReplace(StringReplace($aDatasplit1[3], "\", ""),  '"', "")
	$aDatasplit1[4] =  StringReplace(StringReplace($aDatasplit1[4], "\", ""),  '"', "")
	$aDatasplit1[5] =  StringReplace(StringReplace($aDatasplit1[5], "\", ""),  '"', "")
	$aDatasplit1[6] =  StringReplace(StringReplace($aDatasplit1[6], "\", ""),  '"', "")
	$aDatasplit1[7] =  StringReplace(StringReplace(StringReplace($aDatasplit1[7], "\", ""),  '"', ""), "}", "")
	$sDataout = StringReplace ($aDatasplit1[3], "name:",  "") & "|" & StringReplace ($aDatasplit1[5], "battery:",  "") & "|" & StringReplace ($aDatasplit1[4], "id:",  "")
	$aDataout = StringSplit($sDataout,  "|")
	
	; returns data of the toy
	; Array slos are:
	; 1 = Name of the Toy
	; 2 = Battery in percent
	; 3 = Toy ID
	Return $aDataout
	
EndFunc

; Configuring mainwindow acording to the needs of the Toy.
Func _config_window ($aToyData)
	
	GUICtrlSetData($iwBattery, $aToyData[2])
	ConsoleWrite($aToyData[2] & @CRLF)
	; Hush
	if $aToyData[1] = "hush" Then 
		$sToyNameGlobal = "hush"
		$sFunction1 = "Vibrate"
		$iActCount = 1
		GUICtrlSetData($eToyFound, "Hush")
		GUICtrlSetData( $sLabelActuatorA, "Vibration intensity")
		_ActuatorA_Show(True)
		_ActuatorB_Show (False)
		_GUICtrlSlider_SetRange ( $iIntensityA, 0, 20 )
	
	; Edge
	ElseIf $aToyData[1] = "edge" Then
		$sToyNameGlobal = "edge"
		$sFunction1 = "Vibrate1"
		$sFunction2 = "Vibrate2"
		$iActCount = 2
		GUICtrlSetData($eToyFound, "Edge")
		GUICtrlSetData( $sLabelActuatorA, "Vibration intensity inside")
		GUICtrlSetData( $sLabelActuatorB, "Vibration intensity outside")
		_ActuatorA_Show(True)
		_ActuatorB_Show (True)
		_GUICtrlSlider_SetRange ( $iIntensityA, 0, 20 )
		_GUICtrlSlider_SetRange ( $iIntensityB, 0, 20 )
	
	; Flexer (Buggy)
	ElseIf $aToyData[1] = "flexer" Then
		$sToyNameGlobal = "flexer"
		$sFunction1 = "Vibrate"
		$sFunction2 = "Fingering"
		$iActCount = 2
		GUICtrlSetData($eToyFound, "Flexer")
		GUICtrlSetData( $sLabelActuatorA, "Vibration intensity inside")
		GUICtrlSetData( $sLabelActuatorB, "Fingering speed")
		_ActuatorA_Show(True)
		_ActuatorB_Show (True)
		_GUICtrlSlider_SetRange ( $iIntensityA, 0, 20 )
		_GUICtrlSlider_SetRange ( $iIntensityB, 0, 20 )
	Else 
		MsgBox(0, "Error",  "Unknown Toy. Try to update.")
	EndIf 
	
EndFunc

; Combining visibility of label and slider for Acruators in one command per actuator.
Func _ActuatorA_Show($bState)
	
	if $bState = True Then 
		GUICtrlSetState($sLabelActuatorA ,$GUI_SHOW)
		GUICtrlSetState($iIntensityA ,$GUI_SHOW)
	Else 
		GUICtrlSetState($sLabelActuatorA ,$GUI_HIDE)
		GUICtrlSetState($iIntensityA ,$GUI_HIDE)	
	EndIf
	
EndFunc

Func _ActuatorB_Show($bState)
	
	if $bState = True Then 
		GUICtrlSetState($sLabelActuatorB ,$GUI_SHOW)
		GUICtrlSetState($iIntensityB ,$GUI_SHOW)
	Else 
		GUICtrlSetState($sLabelActuatorB ,$GUI_HIDE)
		GUICtrlSetState($iIntensityB ,$GUI_HIDE)	
	EndIf
	
EndFunc

; HTTP Functionalaty for API Calls
Func HttpPost($sURL, $sData = "") ; HTTP Post Request

	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
	$oHTTP.Open("POST", $sURL, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.SetRequestHeader("Content-Type", "application/json")
	$oHTTP.Send($sData)
	If (@error) Then Return SetError(2, 0, 0)
	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
	Return SetError(0, 0, $oHTTP.ResponseText)
	
EndFunc

Func HttpGet($sURL, $sData = ""); HTTP Get Request

	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
	$oHTTP.Open("GET", $sURL & "?" & $sData, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.Send()
	If (@error) Then Return SetError(2, 0, 0)
	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
	Return SetError(0, 0, $oHTTP.ResponseText)
	
EndFunc

; Serching for Vibrationrequests
Func _keywordfinder($string)
	
	For $i = 0 To 20 Step 1
		if StringInStr($string, "vibe " & $i) Then 
			GUICtrlSetData($iIntensityA, $i)
		EndIf
	Next
	
EndFunc