$optionList = "int port;int delay;char ipaddr[64];char upsname[64];int autoreconnect;int staticfrequencyhertz;"
$optionList = $optionList & "int mininputv;int maxinputv;"
$optionList = $optionList & "int minoutputv;int maxoutputv;"
$optionList = $optionList & "int mininputf;int maxinputf;"
$optionList = $optionList & "int minupsl;int maxupsl;"
$optionList = $optionList & "int minbattv;int maxbattv;"
$optionList = $optionList & "int minimizetray;int startwithwindows;"
$optionList = $optionList & "char defaultlang[64];char language[64];"
$optionList = $optionList & "int minimizeonstart;int closetotray;"
$optionList = $optionList & "int shutdownpcbatt;int shutdownpctime;"
$optionList = $optionList & "int InstantShutdown;int AllowGrace;"
$optionList = $optionList & "int ShutdownDelay;int GraceDelay;"

; #FUNCTION# ;===================================================================================================
;
; Name...........: _ListFileInstallFolder
; Description ...: List Install file(s) from a folder into au3
; Syntax.........: _ListFileInstallFolder($sSource, $sDest, $nFlag = 0, $sMask = '*', $sName = 'include', $sOverWrite = False, $sCompiled = False)
; Parameters ....:	$sSource = Source folder to get file(s) from
;					$sDest   = Destination to install file(s) to
;					$nFlag   = According to the flag of FileInstall [Optional]
;					$sMask  = Extensions of file(s) to List         [Optional]
;					$sName  = Out au3 script name     [Optional]
; Return values .: Success - Returns 1
;                  Failure - Returns 0
; Author ........: MrCreator, FireFox
; Modified.......: FireFox, Gawindx
; Remarks .......: this function is faster with _WinAPI_FileFind :
;                  [url="http://www.autoitscript.com/forum/index.php?showtopic=90545"]http://www.autoitscript.com/forum/index.php?showtopic=90545[/url]
; Related .......:
; Link ..........;
; Example .......;
;
;===================================================================================================

Func _ListFileInstallFolder($sSource, $sDest, $nFlag = 0, $sMask = '*', $sName = 'include', $sOverWrite = False)
	Local $hSearch, $sNext_File, $sRet_FI_Lines = ''

	If (Not @Compiled) Then
		$hSearch = FileFindFirstFile($sSource & '\' & $sMask)
		If $hSearch = -1 Then Return SetError(1, 0, 'FileFindFirstFile')
		While 1
			$sNext_File = FileFindNextFile($hSearch)
			If @error Then ExitLoop ;No more files
			$sRet_FI_Lines &= @CRLF & _
					'FileInstall("' & $sSource & '\' & $sNext_File & '", @ScriptDir & "' & $sDest & '\' & $sNext_File & '", ' & $nFlag & ')'
		WEnd
		FileClose($hSearch)
	EndIf
	If $sRet_FI_Lines = '' Then Return SetError(2, 0, '')
	If $sOverWrite Then FileDelete(@ScriptDir & '\' & $sName & '.au3')
	Return FileWrite(@ScriptDir & '\' & $sName & '.au3', StringStripWS($sRet_FI_Lines, 3))
EndFunc   ;==>_ListFileInstallFolder

Func TimeToStr($TimeValue = 0)
	Local $hourrtime, $minrtime, $secrtime, $TimeStr

	$hourrtime = Floor($TimeValue / 3600)
	$minrtime = Floor(($TimeValue - ($hourrtime * 3600)) / 60)
	$secrtime = $TimeValue - ($hourrtime * 3600) - ($minrtime * 60)
	If ($hourrtime > 23) Then
		$dayrtime = Floor($hourrtime / 24)
		$hourrtime = $hourrtime - ($dayrtime * 24)
		$TimeStr = StringFormat("%02dd%02dh:%02dm:%02ds", $dayrtime, $hourrtime, $minrtime, $secrtime)
	ElseIf ($hourrtime = 0) Then
		$TimeStr = StringFormat("%02dm:%02ds", $minrtime, $secrtime)
	Else
		$TimeStr = StringFormat("%02dh:%02dm:%02ds", $hourrtime, $minrtime, $secrtime)
	EndIf
	Return $TimeStr
EndFunc   ;==>TimeToStr

Func _GetScriptVersion()
	If @Compiled Then
		Return FileGetVersion(@ScriptFullPath)
	Else
		Local $sText = FileRead(@ScriptFullPath)
		If @error Then Return SetError(1, 0, "0.0.0.0")
		$pattern = "(?si)(?:\A|\n)\#pragma compile\(FileVersion, (.*?)(?:\)|\z|\n)"
		Local $asRet = StringRegExp($sText, $pattern, 3)
		If @error Then Return SetError(2, 0, "0.0.0.0")
		Return $asRet[0]
	EndIf
EndFunc   ;==>_GetScriptVersion

Func Reset_Shutdown_Timer()
	$Active_Countdown = 0
	Update_label()
EndFunc   ;==>Reset_Shutdown_Timer

Func Init_Shutdown_Timer()
	If Not $Active_Countdown Then
		$Active_Countdown = 1
		$en_cours = $ShutdownDelay
		Update_label($en_cours)
		AdlibRegister("Update_compteur", 1000)
	EndIf
EndFunc   ;==>Init_Shutdown_Timer

Func Update_label($param_string = 0)
	Local $nMin = Floor($param_string / 60)
	Local $nSec = $param_string - $nMin * 60
	GUICtrlSetData($lbl_countdown, StringFormat("%02d:%02d", $nMin, $nSec))
	GUICtrlSetData($lbl_ups_status, StringFormat("Battery Charge : %02d\r\nRemaining Time : %s", $battCh, $battrtimeStr))
EndFunc   ;==>Update_label

Func _Restart_Compteur($hWnd, $iMsg, $iIDTimer, $iTime)
	AdlibRegister("Update_compteur", 1000)
	$Suspend_Countdown = 0
	GUICtrlSetColor($lbl_countdown, 0x000000)
EndFunc   ;==>_Restart_Compteur

;==== Fonction principale de gestion du compteur
Func Update_compteur()
	If $Active_Countdown Then
		$en_cours -= 1
		Update_label($en_cours)
		If $en_cours = 0 Then AdlibUnRegister("Update_compteur")
	EndIf
EndFunc   ;==>Update_compteur

Func InitOptionDATA()
	$optionsStruct = 0 ;reset the variable if was inited earlier
	$optionsStruct = DllStructCreate($optionList)
	If IsDllStruct($optionsStruct) == 0 Then
		$status = -1
		Return
	EndIf
	$status = 0
	Return
EndFunc   ;==>InitOptionDATA

Func IsShutdownCondition()
	If ($upsstatus <> "0") And ($upsstatus <> "OL" And $socket <> 0) Then
		If ($battCh < GetOption("shutdownpcbatt")) And ($battruntime < GetOption("shutdownpctime")) Then
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>IsShutdownCondition

Func GetOption($optionName)
	$result = DllStructGetData($optionsStruct, $optionName) ;
	If ($result == 0) Then
		If @error <> 0 Then
			Return -1
		EndIf
	Else
		Return $result
	EndIf

	Return $result

EndFunc   ;==>GetOption

Func SetOption($optionName, $value, $type)
	If $type == "string" Then
		$value = String($value)
	EndIf

	If $type == "number" Then
		$value = Number($value)
	EndIf

	$result = DllStructSetData($optionsStruct, $optionName, $value)
	If $result == 0 And @error <> 0 Then
		Return -1
	EndIf

	Return $result
EndFunc   ;==>SetOption

;This function reads parameters from ini file
;Used to read UPS connection settings
;Will also read color and other preferences that might be added in the future
;If ini file is not found in script's directory , default values are set for connection
;settings of UPS
Func Readparam($paramName, $sectionName, $type, $defaultValue, $iniName)

	$optionValue = IniRead($inipath, $sectionName, $iniName, "error")
	If $optionValue == "error" Then
		SetOption($paramName, $defaultValue, $type)
		IniWrite($inipath, $sectionName, $iniName, GetOption($paramName))
		Return $defaultValue
	Else
		SetOption($paramName, $optionValue, $type)
		Return $optionValue
	EndIf

EndFunc   ;==>Readparam

Func ReadParams()
	If FileExists($inipath) == 0 Then ; file not created yet/doesn't exist
		;then create ini file and write them to that file
		$clock_bkg = String($gray)
		$panel_bkg = String($gray)
		SetOption("ipaddr", "nutserver host", "string")
		SetOption("upsname", "ups", "string")
		SetOption("port", 3493, "number")
		SetOption("delay", 5000, "number")
		SetOption("autoreconnect", 0, "number")
		SetOption("mininputv", 170, "number")
		SetOption("maxinputv", 270, "number")
		SetOption("minoutputv", 170, "number")
		SetOption("maxoutputv", 270, "number")
		SetOption("mininputf", 20, "number")
		SetOption("mininputf", 20, "number")
		SetOption("maxinputf", 70, "number")
		SetOption("minupsl", 0, "number")
		SetOption("maxupsl", 100, "number")
		SetOption("minbattv", 0, "number")
		SetOption("maxbattv", 20, "number")
		SetOption("staticfrequencyhertz", 0, "number")
		SetOption("minimizetray", 0, "number")
		SetOption("startwithwindows", 0, "number")
		SetOption("defaultlang", "en-US", "string")
		SetOption("language", "system", "string")
		SetOption("minimizeonstart", 0, "number")
		SetOption("closetotray", 0, "number")
		SetOption("shutdownpcbatt", 30, "number")
		SetOption("shutdownpctime", 120, "number")
		SetOption("InstantShutdown", 1, "number")
		SetOption("ShutdownDelay", 15, "number")
		SetOption("AllowGrace", 0, "number")
		SetOption("GraceDelay", 15, "number")
		WriteParams()
	Else
		Readparam("ipaddr", "Connection", "string", "nutserver host", "Server address")
		Readparam("port", "Connection", "number", "3493", "Port")
		Readparam("upsname", "Connection", "string", "ups", "UPS name")
		Readparam("delay", "Connection", "number", "5000", "Delay")
		Readparam("autoreconnect", "Connection", "number", "0", "AutoReconnect")
		Readparam("mininputv", "Calibration", "number", "170", "Min Input Voltage")
		Readparam("maxinputv", "Calibration", "number", "270", "Max Input Voltage")
		Readparam("minoutputv", "Calibration", "number", "170", "Min Output Voltage")
		Readparam("maxoutputv", "Calibration", "number", "270", "Max Output Voltage")
		Readparam("mininputf", "Calibration", "number", "20", "Min Input Frequency")
		Readparam("maxinputf", "Calibration", "number", "70", "Max Input Frequency")
		Readparam("minupsl", "Calibration", "number", "0", "Min UPS Load")
		Readparam("maxupsl", "Calibration", "number", "100", "Max UPS Load")
		Readparam("minbattv", "Calibration", "number", "0", "Min Batt Voltage")
		Readparam("maxbattv", "Calibration", "number", "20", "Max Batt Voltage")
		Readparam("staticfrequencyhertz", "Appearance", "number", "0", "Static Frequency Hertz")
		Readparam("minimizetray", "Appearance", "number", "0", "Minimize to tray")
		Readparam("closetotray", "Appearance", "number", "0", "Close to tray")
		Readparam("minimizeonstart", "Appearance", "number", "0", "Minimize on Start")
		Readparam("startwithwindows", "Appearance", "number", "0", "Start with Windows")
		Readparam("defaultlang", "Appearance", "string", "en-US", "Default Language")
		Readparam("language", "Appearance", "string", "system", "Language")
		Readparam("shutdownpcbatt", "Power", "number", "30", "Shutdown Limit Battery Charge")
		Readparam("shutdownpctime", "Power", "number", "120", "Shutdown Limit UPS Remain Time")
		Readparam("InstantShutdown", "Power", "number", "1", "Shutdown Immediately")
		Readparam("ShutdownDelay", "Power", "number", "15", "Delay To Shutdown")
		Readparam("AllowGrace", "Power", "number", "0", "Allow Extended Shutdown Delay")
		Readparam("GraceDelay", "Power", "number", "15", "Extended Shutdown Delay")
		$clock_bkg = IniRead($inipath, "Colors", "Clocks Color", "error")

		If $clock_bkg == "error" Then
			$clock_bkg = $gray
			IniWrite($inipath, "Colors", "Clocks Color", "0x" & Hex($clock_bkg))
		Else
			$clock_bkg = Number($clock_bkg)
		EndIf
		$clock_bkg = Number($clock_bkg)
		$clock_bkg_bgr = RGBtoBGR($clock_bkg)
		;;;;;;;;;;;;;;;;;;;;;;;;;;
		$panel_bkg = IniRead($inipath, "Colors", "Panel Color", "error")

		If $panel_bkg == "error" Then
			$panel_bkg = $gray
			IniWrite($inipath, "Colors", "Panel Color", "0x" & Hex($panel_bkg))
		Else
			$panel_bkg = Number($panel_bkg)
		EndIf
		$panel_bkg = Number($panel_bkg)
		;$clock_bkg_bgr = RGBtoBGR($clock_bkg)

	EndIf
	;WriteLog("Done")
EndFunc   ;==>ReadParams

;This function writes parameters to ini file
;This is after these were set in the gui and apply or OK button was hit there
Func WriteParams()
	IniWrite($inipath, "Connection", "Server address", GetOption("ipaddr"))
	IniWrite($inipath, "Connection", "Port", GetOption("port"))
	IniWrite($inipath, "Connection", "UPS name", GetOption("upsname"))
	IniWrite($inipath, "Connection", "Delay", GetOption("delay"))
	IniWrite($inipath, "Connection", "AutoReconnect", GetOption("autoreconnect"))
	IniWrite($inipath, "Colors", "Clocks Color", "0x" & Hex($clock_bkg))
	IniWrite($inipath, "Colors", "Panel Color", "0x" & Hex($panel_bkg))
	IniWrite($inipath, "Appearance", "Static Frequency Hertz", GetOption("staticfrequencyhertz"))
	IniWrite($inipath, "Appearance", "Minimize to tray", GetOption("minimizetray"))
	IniWrite($inipath, "Appearance", "Close to tray", GetOption("closetotray"))
	IniWrite($inipath, "Appearance", "Minimize on Start", GetOption("minimizeonstart"))
	IniWrite($inipath, "Appearance", "Start with Windows", GetOption("startwithwindows"))
	IniWrite($inipath, "Appearance", "Default Language", GetOption("defaultlang"))
	IniWrite($inipath, "Appearance", "Language", GetOption("language"))
	IniWrite($inipath, "Power", "Shutdown Limit Battery Charge", GetOption("shutdownpcbatt"))
	IniWrite($inipath, "Power", "Shutdown Limit UPS Remain Time", GetOption("shutdownpctime"))
	IniWrite($inipath, "Power", "Shutdown Immediately", GetOption("InstantShutdown"))
	IniWrite($inipath, "Power", "Delay To Shutdown", GetOption("ShutdownDelay"))
	IniWrite($inipath, "Power", "Allow Extended Shutdown Delay", GetOption("AllowGrace"))
	IniWrite($inipath, "Power", "Extended Shutdown Delay", GetOption("GraceDelay"))
	IniWrite($inipath, "Calibration", "Min Input Voltage", GetOption("mininputv"))
	IniWrite($inipath, "Calibration", "Max Input Voltage", GetOption("maxinputv"))
	IniWrite($inipath, "Calibration", "Min Output Voltage", GetOption("minoutputv"))
	IniWrite($inipath, "Calibration", "Max Output Voltage", GetOption("maxoutputv"))
	IniWrite($inipath, "Calibration", "Min Input Frequency", GetOption("mininputf"))
	IniWrite($inipath, "Calibration", "Max Input Frequency", GetOption("maxinputf"))
	IniWrite($inipath, "Calibration", "Min UPS Load", GetOption("minupsl"))
	IniWrite($inipath, "Calibration", "Max UPS Load", GetOption("maxupsl"))
	IniWrite($inipath, "Calibration", "Min Batt Voltage", GetOption("minbattv"))
	IniWrite($inipath, "Calibration", "Max Batt Voltage", GetOption("maxbattv"))
EndFunc   ;==>WriteParams
