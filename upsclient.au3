﻿;**** Directives created by AutoIt3Wrapper_GUI ****
#Region
#AutoIt3Wrapper_Icon=images\upsicon.ico
#AutoIt3Wrapper_Outfile=Build\AutoItWinNutClient_x86.exe
#AutoIt3Wrapper_Outfile_x64=Build\AutoItWinNutClient_x64.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Description=AutoIt Windows NUT Client. A WinNUT-Client fork for monitoring a remote ups system that has network abilities.
#AutoIt3Wrapper_Res_Fileversion=1.7.2.2
#AutoIt3Wrapper_Res_ProductName=AutoIt Windows NUT Client
#AutoIt3Wrapper_Res_CompanyName=AutoIt Windows NUT Client
#AutoIt3Wrapper_Res_LegalCopyright=https://sourceforge.net/projects/winnutclient/
#AutoIt3Wrapper_Res_LegalTradeMarks=https://github.com/gawindx/WinNUT-Client
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#EndRegion
Opt("TrayAutoPause", 0)

#include-once
#include <Array.au3>
#include <Color.au3>
#include <Constants.au3>
#include <Date.au3>
#include <File.au3>
#include <GuiComboBox.au3>
#include <GuiComboBoxEx.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEX.au3>
#include <GuiTreeView.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Timers.au3>
#include <TrayConstants.au3>
#include <TreeViewConstants.au3>
#include <WinAPI.au3>
#include <WinAPIFiles.au3>
#include "nutColor.au3"
#include "nutDraw.au3"
#include "nutGlobal.au3"
#include "nutGui.au3"
#include "nuti18n.au3"
#include "nutNetwork.au3"
#include "nutOption.au3"
#include "nutTreeView.au3"

If UBound(ProcessList(@ScriptName)) > 2 Then Exit

;This function repaints all needles when required and passes on control
;to internal AUTOIT repaint handler
;This is registered for WM_PAINT event
Func rePaint()
	repaintNeedle($needle6, $battCh, $dial6, 0, 100)
	repaintNeedle($needle4, $battVol, $dial4, getOption("minbattv"), getOption("maxbattv"))
	repaintNeedle($needle5, $upsLoad, $dial5, getOption("minupsl"), getOption("maxupsl"))
	repaintNeedle($needle1, $inputVol, $dial1, getOption("mininputv"), getOption("maxinputv"))
	repaintNeedle($needle2, $outputVol, $dial2, getOption("minoutputv"), getOption("maxoutputv"))
	repaintNeedle($needle3, $inputFreq, $dial3, getOption("mininputf"), getOption("maxinputf"))
	Return $GUI_RUNDEFMSG
EndFunc   ;==>rePaint

Func updateVarList()
	$selected = _GUICtrlTreeViewGetTree1($TreeView1, ".", 0)
	GUICtrlSetData($varselected, $selected)
	$upsval = ""
	$upsdesc = ""
	$checkstatus1 = GetUPSVar(GetOption("upsname"), $selected, $upsval)
	$checkstatus2 = GetUPSDescVar(GetOption("upsname"), $selected, $upsdesc)
	If $checkstatus1 == -1 Or $checkstatus2 == -1 Then
		$upsval = ""
		$upsdesc = ""
	EndIf
	If GUICtrlRead($varvalue) <> $upsval Then
		GUICtrlSetData($varvalue, $upsval)
	EndIf
	If GUICtrlRead($vardesc) <> $upsdesc Then
		GUICtrlSetData($vardesc, $upsdesc)
	EndIf
EndFunc   ;==>updateVarList

Func varlistGui()
	$varlist = ""
	$templist = ""
	AdlibUnRegister("Update")
	$status1 = ListUPSVars(GetOption("upsname"), $varlist)
	$varlist = StringReplace($varlist, GetOption("upsname"), "")
	$vars = StringSplit($varlist, "VAR", 1)
	AdlibRegister("Update", 1000)
	$guilistvar = GUICreate(__("LIST UPS Variables"), 365, 331, 196, 108, -1, -1, $gui)
	GUISetIcon(@TempDir & "upsicon.ico")
	$TreeView1 = GUICtrlCreateTreeView(0, 8, 361, 169)

	$Group1 = GUICtrlCreateGroup(__("Item properties"), 0, 184, 361, 105, $BS_CENTER)
	$Label1 = GUICtrlCreateLabel(__("Name :"), 8, 200, 38, 17)
	$Label2 = GUICtrlCreateLabel(__("Value :"), 8, 232, 37, 17)
	$Label3 = GUICtrlCreateLabel(__("Description :"), 8, 264, 63, 17)
	$varselected = GUICtrlCreateLabel("", 50, 200, 291, 17, $SS_SUNKEN)
	$varvalue = GUICtrlCreateLabel("", 50, 232, 291, 17, $SS_SUNKEN)
	$vardesc = GUICtrlCreateLabel("", 72, 264, 283, 17, $SS_SUNKEN)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$Reload_Btn = GUICtrlCreateButton(__("Reload"), 80, 296, 65, 25, 0)
	$Clear_Btn = GUICtrlCreateButton(__("Clear"), 200, 296, 65, 25, 0)
	GUISetState(@SW_DISABLE, $gui)
	GUISetState(@SW_SHOW, $guilistvar)

	$varcount = UBound($vars) - 2
	$varlist = "" ;
	For $i = 3 To $varcount
		If $i == $varcount Then
			ContinueLoop
		EndIf
		$templist = StringSplit($vars[$i], '"')
		$curpath = StringStripWS($templist[1], 3)
		_addPath($TreeView1, $curpath)
	Next
	_SetIcons($TreeView1, 0)
	_GUICtrlTreeView_Expand($TreeView1, 0, False)

	AdlibUnRegister("Update")
	AdlibRegister("updateVarList", 500)
	While 1
		$nMsg = GUIGetMsg(1)
		Switch $nMsg[0]
			Case $GUI_EVENT_CLOSE
				AdlibUnRegister("updateVarList")
				GUISetState(@SW_ENABLE, $gui)
				GUIDelete($guilistvar)
				WinActivate($gui)
				AdlibRegister("Update", 1000)
				Return
			Case $Clear_Btn
				_GUICtrlTreeView_Expand($TreeView1, 0, False)
			Case $Reload_Btn
				AdlibUnRegister("updateVarList")
				_GUICtrlTreeView_DeleteAll($TreeView1)
				For $i = 3 To $varcount
					If $i == $varcount Then
						ContinueLoop
					EndIf
					$templist = StringSplit($vars[$i], '"')
					$curpath = StringStripWS($templist[1], 3)
					_addPath($TreeView1, $curpath)
				Next
				_SetIcons($TreeView1, 0)
				_GUICtrlTreeView_Expand($TreeView1, 0, False)
				AdlibRegister("updateVarList", 500)
		EndSwitch
	WEnd
EndFunc   ;==>varlistGui

Func GetUPSInfo()
	Local $status = 0
	$mfr = ""
	$name = ""
	$serial = ""
	$firmware = ""
	If $socket == 0 Then ; not connected to server/connection lost
		Return
	EndIf
	$status = GetUPSVar(GetOption("upsname"), "ups.mfr", $mfr)
	If $status = -1 Then ;UPS name wrong or variable not supported or connection lost
		If $socket == 0 Then
			Return
		EndIf
		If StringInStr($errorstring, "UNKNOWN-UPS") <> 0 Then
			$mfr = ""
			WriteLog(__("Disconnecting from server"))
			TCPSend($socket, "LOGOUT")
			TCPCloseSocket($socket)
			$socket = 0
			ResetGui()
			Return
		EndIf
	EndIf

	$status = GetUPSVar(GetOption("upsname"), "ups.model", $name)
	If $status = -1 Then
		If $socket == 0 Then
			Return
		EndIf
		$name = ""
	EndIf
	;trim $name
	$name = StringStripWS($name, $STR_STRIPLEADING + $STR_STRIPTRAILING)

	$status = GetUPSVar(GetOption("upsname"), "ups.serial", $serial)
	If $status = -1 Then
		If $socket == 0 Then
			Return
		EndIf
		$serial = ""
	EndIf

	$status = GetUPSVar(GetOption("upsname"), "ups.firmware", $firmware)
	If $status = -1 Then
		If $socket == 0 Then
			Return
		EndIf
		$firmware = ""
	EndIf
EndFunc   ;==>GetUPSInfo

Func SetUPSInfo()
	If $socket == 0 Then ;if not connected or connection lost
		$mfr = ""
		$name = ""
		$serial = ""
		$firmware = ""
	EndIf
	GUICtrlSetData($upsmfr, $mfr)
	GUICtrlSetData($upsmodel, $name)
	GUICtrlSetData($upsserial, $serial)
	GUICtrlSetData($upsfirmware, $firmware)
EndFunc   ;==>SetUPSInfo

Func GetUPSData()
	;$status = 0
	$ups_name = GetOption("upsname")
	;
	; Read the INI file for the value of 'Static Frequency Hertz' in the section labelled 'Appearance'.
	Local $localstaticfrequencyhertz = IniRead(@ScriptDir & "\" & "AutoItWinNutClient.ini", "Appearance", "Static Frequency Hertz", "notsetstaticfrequencyhertz")
	;Add a $error check incase it wasn't set
	;
	;
	If $socket == 0 Then $status = -1
	If GetUPSVar($ups_name, "battery.charge", $battch) == -1 Then $status = -1
	If GetUPSVar($ups_name, "battery.voltage", $battVol) == -1 Then $status = -1
	If GetUPSVar($ups_name, "battery.runtime", $battruntime) == -1 Then $status = -1
	If GetUPSVar($ups_name, "battery.capacity", $batcapacity) == -1 Then $status = -1
	If $localstaticfrequencyhertz <> "" Then
		$inputFreq = $localstaticfrequencyhertz
		$mininputf = $inputFreq - 10
		$maxinputf = $inputFreq + 10
	Else
		If GetUPSVar($ups_name, "input.frequency", $inputFreq) == -1 Then
			$status = -1
		EndIf
	EndIf
	If GetUPSVar($ups_name, "input.voltage", $inputVol) == -1 Then $status = -1
	If GetUPSVar($ups_name, "output.voltage", $outputVol) == -1 Then $status = -1
	If GetUPSVar($ups_name, "ups.load", $upsLoad) == -1 Then $status = -1
	If GetUPSVar($ups_name, "ups.status", $upsstatus) == -1 Then $status = -1
	If GetUPSVar($ups_name, "ups.realpower.nominal", $upsoutpower) == -1 Then $status = -1
EndFunc   ;==>GetUPSData

Func UpdateValue(ByRef $needle, $value, $label, $whandle, $min = 170, $max = 270, $force = 0)
	$oldval = Round(GUICtrlRead($label))
	If $oldval < $min Then
		$oldval = $min
	EndIf
	If $oldval > $max Then
		$oldval = $max
	EndIf
	If $oldval == Round($value) And $force == 0 Then
		Return
	EndIf
	GUICtrlSetData($label, $value)
	$value = Round($value)
	If $value < $min Then
		$value = $min
	EndIf
	If $value > $max Then
		$value = $max
	EndIf
	$oldneedle = ($oldval - $min) / (($max - $min) / 100)
	If $oldneedle > 0 Or $oldneedle == 0 Then
		DrawNeedle(15 + $oldneedle, $clock_bkg_bgr, $whandle, $needle)
	EndIf
	$setneedle = ($value - $min) / (($max - $min) / 100)
	DrawNeedle(15 + $setneedle, 0x0, $whandle, $needle)
EndFunc   ;==>UpdateValue

Func ResetGui()
	If $socket == 0 Then
		$battVol = 0
		$battch = 0
		$upsLoad = 0
		$inputVol = 0
		$outputVol = 0
		$inputFreq = 0
	EndIf
	UpdateValue($needle4, 0, $battv, $dial4, getOption("minbattv"), getOption("maxbattv"))
	UpdateValue($needle5, 0, $upsl, $dial5, getOption("minupsl"), getOption("maxupsl"))
	UpdateValue($needle6, 0, $upsch, $dial6, 0, 100)
	UpdateValue($needle1, 0, $inputv, $dial1, getOption("mininputv"), getOption("maxinputv"))
	UpdateValue($needle2, 0, $outputv, $dial2, getOption("minoutputv"), getOption("maxoutputv"))
	UpdateValue($needle3, 0, $inputf, $dial3, getOption("mininputf"), getOption("maxinputf"))
	GUICtrlSetBkColor($upsonline, $gray)
	GUICtrlSetBkColor($upsonbatt, $gray)
	GUICtrlSetBkColor($upsoverload, $gray)
	GUICtrlSetBkColor($upslowbatt, $gray)
	If ($socket <> 0) Then
		SetUPSInfo()
	EndIf
	rePaint()
EndFunc   ;==>ResetGui

Func Update()
	GetUPSData()
	If $socket == 0 And $LastSocket <> 0 Then
		;Connection is lost from last Update Loop
		$ReconnectTry = 0
		ResetGui()
		If GetOption("autoreconnect") == 1 Then
			ReconnectNut()
			AdlibRegister("ReconnectNut", 30000)
		EndIf
		AdlibUnRegister("Update")
		Return
	ElseIf $socket == 0 Then ; connection lost so throw all needles to left
		ResetGui()
		AdlibUnRegister("Update")
		Return
	Else
		$LastSocket = $socket
		$ReconnectTry = 0
	EndIf
	If $upsstatus == "OL" Then
		SetColor($green, $wPanel, $upsonline)
		SetColor(0xffffff, $wPanel, $upsonbatt)
	Else
		SetColor($yellow, $wPanel, $upsonbatt)
		SetColor(0xffffff, $wPanel, $upsonline)
	EndIf
	Local $PowerDivider = 0.9
	If $upsLoad > 100 Then
		SetColor($red, $wPanel, $upsoverload)
	Else
		SetColor(0xffffff, $wPanel, $upsoverload)
		If $upsLoad > 75 Then
			$PowerDivider = 0.8
		ElseIf $upsLoad > 50 Then
			$PowerDivider = 0.85
		EndIf
	EndIf
	;In case of that your inverter does not provide the State of Charge, he will be estimated.
	;The calculation method used is linear and considers that a fully charged 12V battery has
	;a voltage of 13.6V while the voltage of a fully discharged battery is only 11.6V .
	;In this way each percentage of Charge level corresponds to 0.02V.
	;This method is not accurate but offers a consistent approximation.
	If ($battch = 255) Then
		Local $nbattery = Floor($battVol / 12)
		$battch = Floor(($battVol - (11.6 * $nbattery)) / (0.02 * $nbattery))
	EndIf
	;In case your inverter does not provide a consistent value for its runtime,
	;he will also be determined by the calculation
	;The calculation takes into account the capacity of the batteries,
	; the instantaneous charge, the battery voltage, their state of charge,
	; the Power Factor as well as a coefficient allowing to take into account
	;a large instantaneous charge (this limits the runtime ).
	If ($battruntime >= 86400) Then
		Local $RealLoad = ($upsoutpower * ($upsLoad / 100))
		Local $InstantCurrent = $RealLoad / $battVol
		$battruntime = Floor(((($batcapacity / $InstantCurrent) * $upsPF) * ($battch / 100) * $PowerDivider) * 3600)
	EndIf
	If $battch < 40 Then
		SetColor($red, $wPanel, $upslowbatt)
	Else
		SetColor(0xffffff, $wPanel, $upslowbatt)
	EndIf
	$battrtimeStr = TimeToStr($battruntime)
	GUICtrlSetData($remainTimeLabel, $battrtimeStr)
	UpdateValue($needle1, $inputVol, $inputv, $dial1, getOption("mininputv"), getOption("maxinputv"))
	UpdateValue($needle2, $outputVol, $outputv, $dial2, getOption("minoutputv"), getOption("maxoutputv"))
	UpdateValue($needle3, $inputFreq, $inputf, $dial3, getOption("mininputf"), getOption("maxinputf"))
	UpdateValue($needle4, $battVol, $battv, $dial4, getOption("minbattv"), getOption("maxbattv"))
	UpdateValue($needle5, $upsLoad, $upsl, $dial5, getOption("minupsl"), getOption("maxupsl"))
	UpdateValue($needle6, $battch, $upsch, $dial6, 0, 100)
	rePaint()
	;if connection to UPS is in fact alive and charge below shutdown setting and ups is not online
	;add different from status 0 when UPS not connected but NUT is running
	If (IsShutdownCondition()) Then
		$InstantShutdown = GetOption("InstantShutdown")
		If $InstantShutdown = 1 Then
			Shutdown(17)
		Else
			ShutdownGui()
		EndIf
	EndIf
EndFunc   ;==>Update

Func SetTrayIconText()
	$trayStatus = ""
	If $socket > 0 Then
		If $battch < 40 Then
			$trayStatus = $trayStatus & @LF & __("Low Battery")
		Else
			$trayStatus = $trayStatus & @LF & __("Battery OK")
		EndIf
		If $upsstatus == "OL" Then
			$trayStatus = $trayStatus & @LF & __("UPS On Line")
		Else
			$trayStatus = $trayStatus & @LF & __("UPS On Battery") & "(" & $battch & "%)"
		EndIf
	ElseIf $ReconnectTry <> 0 Then
		$trayStatus = __("Connection lost") & @LF & StringFormat(__("%d attempts remaining"), (30 - $ReconnectTry))
	Else
		$trayStatus = __("Not Connected")
	EndIf
	TraySetToolTip($ProgramDesc & " - " & $ProgramVersion & $trayStatus)
EndFunc   ;==>SetTrayIconText

Func ReconnectNut()
	Local $NewSocket = ConnectServer()
	Opt("TCPTimeout", 3000)
	$ReconnectTry = $ReconnectTry + 1
	If $ReconnectTry > 29 Then
		AdlibUnRegister("ReconnectNut")
	ElseIf $NewSocket >= 0 Then
		GetUPSInfo()
		SetUPSInfo()
		Update()
		AdlibRegister("Update", 1000)
		AdlibUnRegister("ReconnectNut")
	EndIf
EndFunc   ;==>ReconnectNut

Func DrawDial($left, $top, $basescale, $title, $units, ByRef $value, ByRef $needle, $scale = 1, $leftG = 20, $rightG = 70)
	Local $group = 0

	$group = GUICreate(" " & $title, 150, 120, $left, $top, BitOR($WS_CHILD, $WS_DLGFRAME), $WS_EX_CLIENTEDGE, $gui)
	GUISetBkColor($clock_bkg, $group)
	GUISwitch($group)
	GUICtrlCreateLabel($title, 0, 0, 150, 14, $SS_CENTER)

	For $x = 0 To 100 Step 10
		If StringInStr($x / 20, ".") = 0 Then
			GUICtrlCreateLabel("", $x * 1.2 + 15, 15, 1, 15, $SS_BLACKRECT)
			GUICtrlSetState(-1, $GUI_DISABLE)
			If $x < 100 Then
				$test = GUICtrlCreateLabel("", $x * 1.2 + 16, 15, 11, 5, 0)
				GUICtrlSetState(-1, $GUI_DISABLE)
				If $x < $rightG And $x > $leftG Then
					GUICtrlSetBkColor($test, 0x00ff00)
				Else
					GUICtrlSetBkColor($test, 0xff0000)
				EndIf
			EndIf
			$scalevalue = $basescale + $x / $scale
			Switch $scalevalue
				Case 0 To 9
					GUICtrlCreateLabel($scalevalue, $x * 1.2 + 13, 25, 20, 10)
				Case 10 To 99
					GUICtrlCreateLabel($scalevalue, $x * 1.2 + 10, 25, 20, 10)
				Case 100 To 1000
					GUICtrlCreateLabel($scalevalue, $x * 1.2 + 7, 25, 20, 10)
			EndSwitch
			GUICtrlSetFont(-1, 7)
		Else
			GUICtrlCreateLabel("", $x * 1.2 + 15, 15, 1, 5, $SS_BLACKRECT)
			GUICtrlSetState(-1, $GUI_DISABLE)
			$test = GUICtrlCreateLabel("", $x * 1.2 + 16, 15, 11, 5, 0)
			;GuiCtrlSetState(-1,$GUI_DISABLE)
			If $x < $rightG And $x > $leftG Then
				GUICtrlSetBkColor($test, 0x00ff00)
			Else
				GUICtrlSetBkColor($test, 0xff0000)
			EndIf
		EndIf
	Next
	If $units == "%" Then
		$value = GUICtrlCreateLabel(0, 10, 100, 40, 15, $SS_LEFT)
	Else
		$value = GUICtrlCreateLabel(220, 10, 100, 40, 15, $SS_LEFT)
	EndIf
	$Label2 = GUICtrlCreateLabel($units, 116, 100, 25, 15, $SS_RIGHT)
	$needle = GUICtrlCreateGraphic(10, 35, 120, 60)
	;GUICtrlSetBkColor(-1,$aqua)
	;$fill = GuiCtrlCreateGraphic(0 , 0 , 150 , 120)
	If BitAND(WinGetState($gui), $WIN_STATE_MINIMIZED) Then
		GUISetState(@SW_HIDE, $group)
	Else
		GUISetState(@SW_SHOW, $group)
	EndIf
	;GuiCtrlSetBkColor(-1,0x00ffff)
	$result = $group
	Return $group
EndFunc   ;==>DrawDial

Func ShutdownGui_Event($hWnd, $Msg, $wParam, $lParam)
	$nNotifyCode = BitShift($wParam, 16)
	$nID = BitAND($wParam, 0x0000FFFF)
	$hCtrl = $lParam
	writelog("notify " & $nNotifyCode)
	If $nID = $guishutdown Then
		Switch $nNotifyCode
			Case $LBN_DBLCLK
				writelog("bidule")
		EndSwitch
	EndIf
	If $nID = $Grace_btn Then
		Switch $nNotifyCode
			Case $LBN_DBLCLK
				writelog("grace")
		EndSwitch
	EndIf
	If $nID = $Shutdown_btn Then
		Switch $nNotifyCode
			Case $LBN_DBLCLK
				writelog("shutdown")
		EndSwitch
	EndIf
EndFunc   ;==>ShutdownGui_Event

Func setTrayMode()
	$minimizetray = GetOption("minimizetray")
	If $minimizetray == 1 Then
		TraySetIcon(@TempDir & "upsicon.ico")
		TraySetState($TRAY_ICONSTATE_SHOW)
		Opt("TrayAutoPause", 0) ; Le script n'est pas mis en pause lors de la sélection de l'icône de la zone de notification.
		Opt("TrayMenuMode", 3) ; Les items ne sont pas cochés lorsqu'ils sont sélectionnés.
		TraySetClick(8)
		TraySetToolTip($ProgramDesc & " - " & $ProgramVersion)
	Else
		TraySetState($TRAY_ICONSTATE_HIDE)
	EndIf
EndFunc   ;==>setTrayMode

Func mainLoop()
	$minimizetray = GetOption("minimizetray")
	While 1
		If ($minimizetray == 1) Then
			$tMsg = TrayGetMsg()
			Switch $tMsg
				Case $TRAY_EVENT_PRIMARYDOUBLE
					GUISetState(@SW_SHOW, $gui)
					GUISetState(@SW_RESTORE, $gui)
					TraySetState($TRAY_ICONSTATE_HIDE)
				Case $idTrayExit
					TCPSend($socket, "LOGOUT")
					TCPCloseSocket($socket)
					TCPShutdown()
					Exit
				Case $idTrayAbout
					aboutGui()
				Case $idTrayPref
					AdlibUnRegister("Update")
					$changedprefs = prefGui()
					If $changedprefs == 1 Then
						$painting = 1
						GUIDelete($dial1)
						GUIDelete($dial2)
						GUIDelete($dial3)
						GUIDelete($dial5)
						GUIDelete($dial4)
						DrawError(160, 70, "Delete")
						$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100)
						$dial1 = DrawDial(160, 70, GetOption("mininputv"), "Input Voltage", "V", $inputv, $needle1, $calc)
						$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100)
						$dial2 = DrawDial(480, 70, GetOption("minoutputv"), "Output Voltage", "V", $outputv, $needle2, $calc)
						$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100)
						$dial3 = DrawDial(320, GetOption("maxinputf"), GetOption("mininputf"), "Input Frequency", "Hz", $inputf, $needle3, $calc)
						$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100)
						$dial4 = DrawDial(480, 200, GetOption("minbattv"), "Battery Voltage", "V", $battv, $needle4, $calc, 20, 120)
						$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100)
						$dial5 = DrawDial(320, 200, 0, "UPS Load", "%", $upsl, $needle5, $calc, -1, 80)
						$painting = 0
					EndIf
					If $haserror == 0 Then
						Update()
						AdlibRegister("Update", 1000)
					EndIf
			EndSwitch
		EndIf
		$nMsg = GUIGetMsg(1)
		If GetOption("closetotray") == 0 Then
			If ($nMsg[0] == $GUI_EVENT_CLOSE And $nMsg[1] == $gui) Or $nMsg[0] == $exitMenu Or $nMsg[0] == $exitb Then
				TCPSend($socket, "LOGOUT")
				TCPCloseSocket($socket)
				TCPShutdown()
				Exit
			EndIf
		Else
			If $nMsg[0] == $exitMenu Or $nMsg[0] == $exitb Then
				TCPSend($socket, "LOGOUT")
				TCPCloseSocket($socket)
				TCPShutdown()
				Exit
			EndIf
			If ($nMsg[0] == $GUI_EVENT_CLOSE And $nMsg[1] == $gui) Then
				GUISetState(@SW_HIDE, $gui)
				TraySetState($TRAY_ICONSTATE_SHOW)
			EndIf
		EndIf
		If ($nMsg[0] == $GUI_EVENT_MINIMIZE And $nMsg[1] == $gui And $minimizetray == 1) Then ;minimize to tray
			GUISetState(@SW_HIDE, $gui)
			TraySetState($TRAY_ICONSTATE_SHOW)
		EndIf
		If $nMsg[0] == $toolb Or $nMsg[0] == $settingssubMenu Then
			AdlibUnRegister("Update")
			$changedprefs = prefGui()
			If $changedprefs == 1 Then
				$painting = 1
				GUIDelete($dial1)
				GUIDelete($dial2)
				GUIDelete($dial3)
				GUIDelete($dial5)
				GUIDelete($dial4)
				DrawError(160, 70, "Delete")
				$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100)
				$dial1 = DrawDial(160, 70, GetOption("mininputv"), "Input Voltage", "V", $inputv, $needle1, $calc)
				$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100)
				$dial2 = DrawDial(480, 70, GetOption("minoutputv"), "Output Voltage", "V", $outputv, $needle2, $calc)
				$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100)
				$dial3 = DrawDial(320, GetOption("maxinputf"), GetOption("mininputf"), "Input Frequency", "Hz", $inputf, $needle3, $calc)
				$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100)
				$dial4 = DrawDial(480, 200, GetOption("minbattv"), "Battery Voltage", "V", $battv, $needle4, $calc, 20, 120)
				$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100)
				$dial5 = DrawDial(320, 200, 0, "UPS Load", "%", $upsl, $needle5, $calc, -1, 80)
				$painting = 0
			EndIf
			If $haserror == 0 Then
				Update()
				AdlibRegister("Update", 1000)
			EndIf
		EndIf
		If $nMsg[0] == $aboutMenu Then
			aboutGui()
		EndIf
		If ($nMsg[0] == $listvarMenu) Then
			varlistGui()
		EndIf
		If $nMsg[0] == $reconnectMenu Then
			AdlibUnRegister("Update")
			$socket = ConnectServer() ;;aaaaa
			Opt("TCPTimeout", 3000)
			GetUPSInfo()
			SetUPSInfo()
			AdlibRegister("Update", 1000)
		EndIf
		For $vKey In $MenuLangListhwd
			If $nMsg[0] == $MenuLangListhwd.Item($vKey) Then
				GUICtrlSetState($MenuLangListhwd.Item($vKey), $GUI_CHECKED)
				SetOption("language", $vKey, "string")
				MsgBox($MB_SYSTEMMODAL, "", __("The language change will be effective after restarting WinNut"))
				WriteParams()
				For $vxKey In $MenuLangListhwd
					If $vxKey == $vKey Then
						GUICtrlSetState($MenuLangListhwd.Item($vxKey), $GUI_CHECKED)
					Else
						GUICtrlSetState($MenuLangListhwd.Item($vxKey), $GUI_UNCHECKED)
					EndIf
				Next
				;_i18n_SetLanguage($vKey)
				ExitLoop
			EndIf
		Next

	WEnd
EndFunc   ;==>mainLoop

Func WinNut_Init()
	;Install all needed Files
	;icon
	FileInstall(".\images\ups.jpg", @TempDir & "ups.jpg", 1)
	FileInstall(".\images\upsicon.ico", @TempDir & "upsicon.ico", 1)

	If Not FileExists(@ScriptDir & "\Language") Then
		DirCreate(@ScriptDir & "\Language")
	EndIf

	;Language
	; function to auto include all language file
	_ListFileInstallFolder(".\Language", "\Language", 0, "*.lng", "include", True)
	;Now file is generated so include it
	#include "include.au3"

	;Get Script Version
	$ProgramVersion = _GetScriptVersion()

	;HERE STARTS MAIN SCRIPT
	$status = TCPStartup()
	If $status == False Then
		MsgBox(48, "Critical Error", "Couldn't startup TCP")
		Exit
	EndIf
	Opt("GUIDataSeparatorChar", ".")

	;Initialize all Option Data
	InitOptionDATA()
	If $status == -1 Then
		MsgBox(48, "Critical Error", "Couldn't initialize Options")
		Exit
	EndIf

	;Determine if running as exe or script
	If @Compiled Then $runasexe = True

	;load/create ini file
	ReadParams()

	;Define default language and language file directory
	_i18n_SetLangBase(@ScriptDir & "\Language")
	Local $sDefLang = GetOption("defaultlang")
	If $sDefLang == -1 Then
		$sDefLang = 'en-US'
		SetOption("defaultlang", $sDefLang, "string")
	EndIf
	_i18n_SetDefault($sDefLang)
	Local $sLanguage = GetOption("language")
	If $sLanguage == -1 Then
		$sLanguage = 'system'
		SetOption("language", $sLanguage, "string")
	EndIf
	_i18n_SetLanguage($sLanguage)

	;Create and iitialize Systray Icon
	TraySetState($TRAY_ICONSTATE_HIDE)
	setTrayMode()
	$idTrayPref = TrayCreateItem(__("Preferences"))
	TrayCreateItem("")
	$idTrayAbout = TrayCreateItem(__("About"))
	TrayCreateItem("")
	$idTrayExit = TrayCreateItem(__("Exit"))

	OpenMainWindow()
	If ( GetOption("minimizeonstart") == 1 And GetOption("minimizetray") == 1) Then
		GUISetState(@SW_HIDE, $gui)
		TraySetState($TRAY_ICONSTATE_SHOW)
	Else
		GUISetState(@SW_SHOW, $gui)
		TraySetState($TRAY_ICONSTATE_HIDE)
	EndIf

	;Initilize connexion to Nut/Ups
	$status = ConnectServer()
	Opt("TCPTimeout", 3000)
	GetUPSInfo()
	SetUPSInfo()
	GetUPSData()
	Update()
	GUIRegisterMsg(0x000F, "rePaint")
	AdlibRegister("GetUPSData", GetOption("delay"))
	AdlibRegister("Update", 1000)
	AdlibRegister("SetTrayIconText", 1000)
EndFunc   ;==>WinNut_Init

WinNut_Init()
mainLoop()
