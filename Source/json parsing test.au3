;json parsing test.au3

$sData =  '{"code":200,"data":{"toys":"{\"c71aca1c61d7\":{\"nickName\":\"M\",\"name\":\"hush\",\"id\":\"c71aca1c61d7\",\"battery\":100,\"version\":\"2\",\"status\":\"1\"}}","appType":"remote","gameAppId":"2d606d11c1b244629d2727c5b65aa0a4","platform":"android"},"type":"OK"}'

Global $sIP =  "192.168.178.104"
Global $iPort =  20010
; Global Constants
Global Const $HTTP_STATUS_OK = 200



#include <StringConstants.au3>
#include <Array.au3>

$jsonToys = _gettoys ($sIP, $iPort)
ConsoleWrite($jsonToys & @CRLF)

$aData =  _json_parse($jsonToys)
;_ArrayDisplay($aData)

$iActuator1 =  0
$iActuator2 =  0

; Edge
$sPost = HttpPost('http://' & $sIP & ':' & $iPort & '/command', '{"command":"Function","action":"Vibrate1:' & $iActuator1 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
ConsoleWrite($sPost & @CRLF)
$sPost = HttpPost('http://' & $sIP & ':' & $iPort & '/command', '{"command":"Function","action":"Vibrate2:' & $iActuator2 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
ConsoleWrite($sPost & @CRLF)

; Flexer
;$sPost = HttpPost('http://' & $sIP & ':' & $iPort & '/command', '{"command":"Function","action":"Vibrate:' & $iActuator1 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
;ConsoleWrite($sPost & @CRLF)
;$sPost = HttpPost('http://' & $sIP & ':' & $iPort & '/command', '{"command":"Function","action":"Fingering:' & $iActuator2 & '","timeSec":0,"stopPrevious":0,"apiVer":1}')
;ConsoleWrite($sPost & @CRLF)


Func _gettoys($sIPlib, $iPortlib)
	$sPost = HttpPost('http://' & $sIPlib & ':' & $iPortlib & '/command', '{"command":"GetToys"}')
	Return $sPost
EndFunc

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