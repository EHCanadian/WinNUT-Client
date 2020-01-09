Global $socket = 0

Func ProcessData($data)
	
	Local $strs
	
	$strs = StringSplit($data, '"')
	If UBound($strs) < 2 Then ;ERROR string returned or other unexpected condition
		Return -1 ;return -1 which means the something bad happened and value
	EndIf ;returned from NUT is unusable
	If StringLeft($strs[2], 1) == "0" Then
		Return StringTrimLeft($strs[2], 1)
	Else
		Return $strs[2]
	EndIf
	
EndFunc   ;==>ProcessData

Func CheckErr($upsresp)
	Local $strs
	If StringLeft($upsresp, 3) == "ERR" Then
		$strs = StringSplit($upsresp, " ")
		If UBound($strs) < 2 Then
			Return "Uknown Error"
		EndIf
		Return $strs[2]
	Else
		Return "OK"
	EndIf
	
EndFunc   ;==>CheckErr

Func ListUPSVars($upsId, ByRef $upsVar)
	
	Local $sendstring, $sent, $data
	If $socket == 0 Then
		$upsVar = "0"
		Return -1
	EndIf
	$sendstring = "LIST VAR " & $upsId & @CRLF
	$sent = TCPSend($socket, $sendstring)
	If $sent == 0 Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	Sleep(500)
	$data = TCPRecv($socket, 4096)
	If $data == "" Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	$err = CheckErr($data)
	If $err <> "OK" Then
		$errorstring = $err
		If StringInStr($errorstring, "UNKNOWN-UPS") <> 0 Then
			WriteLog(StringFormat(__("UPS %s doesn't exist"), $upsId))
		EndIf
		$upsVar = "0"
		Return -1
	EndIf
	$upsVar = $data
	Return 0
EndFunc   ;==>ListUPSVars

Func GetUPSDescVar($upsId, $varName, ByRef $upsVar)
	
	Local $sendstring, $sent, $data
	If $socket == 0 Then
		$upsVar = "0"
		Return -1
	EndIf
	$sendstring = "GET DESC " & $upsId & " " & $varName & @CRLF
	$sent = TCPSend($socket, $sendstring)
	If $sent == 0 Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	$data = TCPRecv($socket, 4096)
	If $data == "" Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	$err = CheckErr($data)
	If $err <> "OK" Then
		$errorstring = $err
		If StringInStr($errorstring, "UNKNOWN-UPS") <> 0 Then
			WriteLog(StringFormat(__("UPS %s doesn't exist"), $upsId))
		EndIf
		$upsVar = "0"
		Return -1
	EndIf
	$upsVar = ProcessData($data)
	Return 0
	
EndFunc   ;==>GetUPSDescVar

Func GetUPSVar($upsId, $varName, ByRef $upsVar)
	
	Local $sendstring, $sent, $data
	If $socket == 0 Then
		$upsVar = "0"
		Return -1
	EndIf
	$sendstring = "GET VAR " & $upsId & " " & $varName & @CRLF
	$sent = TCPSend($socket, $sendstring)
	If $sent == 0 Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	$data = TCPRecv($socket, 4096)
	If $data == "" Then ;connection lost
		$errorstring = __("Connection lost")
		WriteLog($errorstring)
		$socket = 0
		$upsVar = "0"
		Return -1
	EndIf
	$err = CheckErr($data)
	If $err <> "OK" Then
		$errorstring = $err
		If StringInStr($errorstring, "UNKNOWN-UPS") <> 0 Then
			WriteLog(StringFormat(__("UPS %s doesn't exist"), $upsId))
		EndIf
		$upsVar = "0"
		Return -1
	EndIf
	$upsVar = ProcessData($data)
	Return 0
EndFunc   ;==>GetUPSVar

Func ConnectServer()
	If $socket <> 0 Then ;already connected
		WriteLog(__("Disconnecting from server"))
		TCPSend($socket, "LOGOUT")
		TCPCloseSocket($socket) ;disconnect first
		$socket = 0
	EndIf
	Opt("TCPTimeout", 10)
	WriteLog(__("Connecting to NUT Server"))
	$ipaddr = TCPNameToIP(GetOption("ipaddr"))
	$socket = TCPConnect($ipaddr, GetOption("port"))
	If $socket == -1 Then ;connection failed
		$haserror = 1
		$errorstring = __("Connection failed")
		WriteLog($errorstring)
		Return -1
	Else
		WriteLog(__("Connection Established"))
		Return 0
	EndIf
EndFunc   ;==>ConnectServer

