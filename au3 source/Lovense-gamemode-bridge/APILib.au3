;APILib.au3

Func _gettoys($sIPlib, $iPortlib)
	$sPost = HttpPost('http://' & $sIPlib & ':' & $iPortlib & '/command', '{"command":"GetToys"}')
	Return $sPost
EndFunc

Func _hushvibe($sIPlib, $iPortlib ,$iIntensitylib)
	$sPost = HttpPost('http://' & $sIPlib & ':' & $iPortlib & '/command', '{"command":"Function","action":"Vibrate:' & $iIntensitylib & '","timeSec":0,"stopPrevious":1,"apiVer":1}')
	Return $sPost
EndFunc