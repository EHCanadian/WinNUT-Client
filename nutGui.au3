Global $gui = 0
Global $log

Func WriteLog($msg)
	$msg = _Now() & " : " & $msg
	ControlCommand($gui, "", $log, "AddString", $msg)
	ControlCommand($gui, "", $log, "SetCurrentSelection", _GUICtrlComboBox_GetCount($log) - 1)
EndFunc   ;==>WriteLog

Func prefGui()
	Local $Iipaddr = 0
	Local $Iport = 0
	Local $Iupsname = 0
	Local $Idelay = 0
	Local $tempcolor1, $tempcolor2
	Local $result = 0
	$tempcolor2 = $clock_bkg
	$tempcolor1 = $panel_bkg
	ReadParams()
	If $guipref <> 0 Then
		GUIDelete($guipref)
		$guipref = 0
	EndIf
	$minimizetray = GetOption("minimizetray")
	If $minimizetray == 1 Then
		TraySetClick(0)
	EndIf
	$guipref = GUICreate(__("Preferences"), 364, 331, 190, 113, -1, -1, $gui)
	GUISetIcon(@TempDir & "upsicon.ico")
	$Bcancel = GUICtrlCreateButton(__("Cancel"), 286, 298, 75, 25, 0)
	$Bapply = GUICtrlCreateButton(__("Apply"), 206, 298, 75, 25, 0)
	$Bok = GUICtrlCreateButton(__("Ok"), 126, 298, 75, 25, 0)
	$Tconnection = GUICtrlCreateTab(0, 0, 361, 289)
	$TSconnection = GUICtrlCreateTabItem(__("Connection"))
	$Lipaddr = GUICtrlCreateLabel(__("UPS host :"), 16, 40, 80, 17, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	$Iipaddr = GUICtrlCreateInput(GetOption("ipaddr"), 100, 37, 249, 21)
	$Lport = GUICtrlCreateLabel(__("UPS port :"), 16, 82, 80, 17, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	$Iport = GUICtrlCreateInput(GetOption("port"), 100, 77, 73, 21)
	$Lname = GUICtrlCreateLabel(__("UPS name :"), 16, 122, 80, 17, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	$Iupsname = GUICtrlCreateInput(GetOption("upsname"), 100, 120, 249, 21)
	$Ldelay = GUICtrlCreateLabel(__("Delay :"), 16, 162, 80, 17, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	$Idelay = GUICtrlCreateInput(GetOption("delay"), 100, 159, 73, 21)
	$Checkbox1 = GUICtrlCreateCheckbox("ACheckbox1", 334, 256, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	$Label9 = GUICtrlCreateLabel(__("Re-establish connection"), 217, 256, 115, 17, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	If GetOption("autoreconnect") == 0 Then
		GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($Checkbox1, $GUI_CHECKED)
	EndIf
	$TabSheet2 = GUICtrlCreateTabItem(__("Colors"))
	GUICtrlCreateLabel(__("Panel background color"), 16, 48, 131, 25)
	GUICtrlCreateLabel(__("Analogue background color"), 16, 106, 179, 25)
	$colorchoose1 = GUICtrlCreateLabel("", 232, 40, 25, 25, BitOR($SS_SUNKEN, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetBkColor(-1, $panel_bkg)
	$colorchoose2 = GUICtrlCreateLabel("", 232, 104, 25, 25, BitOR($SS_SUNKEN, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetBkColor(-1, $clock_bkg)
	GUICtrlCreateTabItem(__("Calibration"))
	GUICtrlCreateLabel(__("Input Voltage"), 16, 56, 120, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel(__("Input Frequency"), 16, 96, 120, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel(__("Output Voltage"), 16, 136, 120, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel(__("UPS Load"), 16, 176, 120, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel(__("Battery Voltage"), 16, 216, 120, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	GUICtrlCreateLabel(__("Min"), 175, 32, 23, 19)
	GUICtrlCreateLabel(__("Max"), 255, 32, 25, 19)
	$lminInputVoltage = GUICtrlCreateInput(GetOption("mininputv"), 160, 56, 49, 23)
	$lmaxInputVoltage = GUICtrlCreateInput(GetOption("maxinputv"), 250, 56, 49, 23)
	$lminInputFreq = GUICtrlCreateInput(GetOption("mininputf"), 160, 96, 49, 23)
	$lmaxInputFreq = GUICtrlCreateInput(GetOption("maxinputf"), 250, 96, 49, 23)
	$lminOutputVoltage = GUICtrlCreateInput(GetOption("minoutputv"), 160, 136, 49, 23)
	$lmaxOutputVoltage = GUICtrlCreateInput(GetOption("maxoutputv"), 250, 136, 49, 23)
	$lminUpsLoad = GUICtrlCreateInput(GetOption("minupsl"), 160, 176, 49, 23)
	$lmaxUpsLoad = GUICtrlCreateInput(GetOption("maxupsl"), 250, 176, 49, 23)
	$lminBattVoltage = GUICtrlCreateInput(GetOption("minbattv"), 160, 216, 49, 23)
	$lmaxBattVoltage = GUICtrlCreateInput(GetOption("maxbattv"), 250, 216, 49, 23)

	$TabSheet1 = GUICtrlCreateTabItem(__("Misc"))
	GUICtrlCreateLabel(__("Minimize to tray"), 16, 42, 150, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chMinimizeTray = GUICtrlCreateCheckbox("MinimizeTray", 224, 39, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	$lblstartminimized = GUICtrlCreateLabel(__("Start Minimized"), 16, 84, 150, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chstartminimized = GUICtrlCreateCheckbox("StartMinimized", 224, 81, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	$lblclosetotray = GUICtrlCreateLabel(__("Close to Tray"), 16, 126, 150, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chclosetotray = GUICtrlCreateCheckbox("ClosetoTray", 224, 123, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	If GetOption("minimizetray") == 0 Then
		GUICtrlSetState($chMinimizeTray, $GUI_UNCHECKED)
		GUICtrlSetState($chstartminimized, $GUI_UNCHECKED)
		GUICtrlSetState($chclosetotray, $GUI_UNCHECKED)
		GUICtrlSetState($lblstartminimized, $GUI_DISABLE)
		GUICtrlSetState($chstartminimized, $GUI_DISABLE)
		GUICtrlSetState($lblclosetotray, $GUI_DISABLE)
		GUICtrlSetState($chclosetotray, $GUI_DISABLE)
	Else
		GUICtrlSetState($chMinimizeTray, $GUI_CHECKED)
		GUICtrlSetState($lblstartminimized, $GUI_ENABLE)
		GUICtrlSetState($chstartminimized, $GUI_ENABLE)
		GUICtrlSetState($lblclosetotray, $GUI_ENABLE)
		GUICtrlSetState($chclosetotray, $GUI_ENABLE)
		If GetOption("minimizeonstart") == 0 Then
			GUICtrlSetState($chstartminimized, $GUI_UNCHECKED)
		Else
			GUICtrlSetState($chstartminimized, $GUI_CHECKED)
		EndIf
		If GetOption("closetotray") == 0 Then
			GUICtrlSetState($chclosetotray, $GUI_UNCHECKED)
		Else
			GUICtrlSetState($chclosetotray, $GUI_CHECKED)
		EndIf
	EndIf

	$lblstartwithwindows = GUICtrlCreateLabel(__("Start with Windows"), 16, 168, 150, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chStartWithWindows = GUICtrlCreateCheckbox("Startwithwindows", 224, 167, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	If $runasexe == True Then
		GUICtrlSetState($chStartWithWindows, $GUI_ENABLE)
		GUICtrlSetState($lblstartwithwindows, $GUI_ENABLE)
		If GetOption("startwithwindows") == 0 Then
			GUICtrlSetState($chStartWithWindows, $GUI_UNCHECKED)
		Else
			GUICtrlSetState($chStartWithWindows, $GUI_CHECKED)
		EndIf
	Else
		GUICtrlSetState($chStartWithWindows, $GUI_UNCHECKED)
		GUICtrlSetState($lblstartwithwindows, $GUI_DISABLE)
		GUICtrlSetState($chStartWithWindows, $GUI_DISABLE)
	EndIf

	$TSShutdown = GUICtrlCreateTabItem(__("Shutdown Options"))
	GUICtrlCreateLabel(__("Shutdown if battery lower than"), 16, 39, 179, 34, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$lshutdownpcbatt = GUICtrlCreateInput(GetOption("shutdownpcbatt"), 217, 36, 25, 23)
	GUICtrlCreateLabel("%", 248, 39, 15, 19)
	GUICtrlCreateLabel(__("Shutdown if runtime lower than (sec)"), 16, 81, 179, 34, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$lshutdownrtime = GUICtrlCreateInput(GetOption("shutdownpctime"), 217, 81, 40, 23)
	$lblInstantShutdown = GUICtrlCreateLabel(__("Shutdown Immediately"), 16, 123, 179, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chInstantShutdown = GUICtrlCreateCheckbox("Shutdown Immediately", 224, 122, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	$lbldelayshutdown = GUICtrlCreateLabel(__("Delay to Shutdown"), 16, 165, 179, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$ldelayshutdown = GUICtrlCreateInput(GetOption("ShutdownDelay"), 217, 162, 40, 23)
	$lblAllowGrace = GUICtrlCreateLabel(__("Allow Extended Shutdown Time"), 16, 207, 179, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$chAllowGrace = GUICtrlCreateCheckbox("AllowExtendedShutdownTime", 224, 206, 17, 17, BitOR($BS_AUTOCHECKBOX, $WS_TABSTOP), $WS_EX_STATICEDGE)
	$lbldelaygrace = GUICtrlCreateLabel(__("Grace Delay to Shutdown"), 16, 249, 179, 17, BitOR($SS_BLACKRECT, $SS_GRAYFRAME, $SS_LEFTNOWORDWRAP))
	$ldelaygrace = GUICtrlCreateInput(GetOption("GraceDelay"), 217, 246, 40, 23)
	If GetOption("InstantShutdown") == 0 Then
		GUICtrlSetState($chInstantShutdown, $GUI_UNCHECKED)
		GUICtrlSetState($lbldelayshutdown, $GUI_ENABLE)
		GUICtrlSetState($ldelayshutdown, $GUI_ENABLE)
	Else
		GUICtrlSetState($chInstantShutdown, $GUI_CHECKED)
		GUICtrlSetState($lbldelayshutdown, $GUI_DISABLE)
		GUICtrlSetState($ldelayshutdown, $GUI_DISABLE)
	EndIf
	If GetOption("AllowGrace") == 0 Then
		GUICtrlSetState($chAllowGrace, $GUI_UNCHECKED)
		GUICtrlSetState($lbldelaygrace, $GUI_DISABLE)
		GUICtrlSetState($ldelaygrace, $GUI_DISABLE)
	Else
		GUICtrlSetState($chAllowGrace, $GUI_CHECKED)
		GUICtrlSetState($lbldelaygrace, $GUI_ENABLE)
		GUICtrlSetState($ldelaygrace, $GUI_ENABLE)
	EndIf

	GUICtrlCreateTabItem("")
	GUISetState(@SW_DISABLE, $gui)
	GUISetState(@SW_SHOW, $guipref)

	While 1
		$nMsg1 = GUIGetMsg()
		Switch $nMsg1
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $Bapply, $Bok
				SetOption("ipaddr", GUICtrlRead($Iipaddr), "string")
				SetOption("port", GUICtrlRead($Iport), "number")
				SetOption("upsname", GUICtrlRead($Iupsname), "string")
				SetOption("delay", GUICtrlRead($Idelay), "number")
				$AutoReconnectCB = GUICtrlRead($Checkbox1)
				If $AutoReconnectCB == $GUI_CHECKED Then
					SetOption("autoreconnect", 1, "number")
				Else
					SetOption("autoreconnect", 0, "number")
				EndIf
				SetOption("mininputv", GUICtrlRead($lminInputVoltage), "number")
				SetOption("maxinputv", GUICtrlRead($lmaxInputVoltage), "number")
				SetOption("minoutputv", GUICtrlRead($lminOutputVoltage), "number")
				SetOption("maxoutputv", GUICtrlRead($lmaxOutputVoltage), "number")
				SetOption("mininputf", GUICtrlRead($lminInputFreq), "number")
				SetOption("maxinputf", GUICtrlRead($lmaxInputFreq), "number")
				SetOption("minupsl", GUICtrlRead($lminUpsLoad), "number")
				SetOption("maxupsl", GUICtrlRead($lmaxUpsLoad), "number")
				SetOption("minbattv", GUICtrlRead($lminBattVoltage), "number")
				SetOption("maxbattv", GUICtrlRead($lmaxBattVoltage), "number")
				SetOption("shutdownpcbatt", GUICtrlRead($lshutdownpcbatt), "number")
				$guiminruntime = GUICtrlRead($lshutdownrtime)
				If $guiminruntime < 60 Then
					$guiminruntime = 60
					GUICtrlSetData($lshutdownrtime, $guiminruntime)
				EndIf
				SetOption("shutdownpctime", $guiminruntime, "number")
				$InstantShutdown = GUICtrlRead($chInstantShutdown)
				If $InstantShutdown == $GUI_CHECKED Then
					SetOption("InstantShutdown", 1, "number")
				Else
					SetOption("InstantShutdown", 0, "number")
				EndIf
				$guidelayshutdown = GUICtrlRead($ldelayshutdown)
				If $guidelayshutdown > $guiminruntime Then
					$guidelayshutdown = $guiminruntime
					GUICtrlSetData($ldelayshutdown, $guidelayshutdown)
				EndIf
				SetOption("ShutdownDelay", $guidelayshutdown, "number")
				$guigracedelay = GUICtrlRead($ldelaygrace)
				If $guigracedelay > ($guiminruntime - $guidelayshutdown) Then
					$guigracedelay = ($guiminruntime - $guidelayshutdown)
					GUICtrlSetData($ldelaygrace, $guigracedelay)
				ElseIf $guigracedelay > $guidelayshutdown Then
					$guigracedelay = $guidelayshutdown
					GUICtrlSetData($ldelaygrace, $guigracedelay)
				EndIf
				$AllowGrace = GUICtrlRead($chAllowGrace)
				If ($AllowGrace == $GUI_UNCHECKED) Or ($guigracedelay = 0) Then
					SetOption("AllowGrace", 0, "number")
				Else
					SetOption("AllowGrace", 1, "number")
				EndIf
				SetOption("GraceDelay", $guigracedelay, "number")
				If GetOption("AllowGrace") == 0 Then
					GUICtrlSetState($chAllowGrace, $GUI_UNCHECKED)
					GUICtrlSetState($lbldelaygrace, $GUI_DISABLE)
					GUICtrlSetState($ldelaygrace, $GUI_DISABLE)
				Else
					GUICtrlSetState($chAllowGrace, $GUI_CHECKED)
					GUICtrlSetState($lbldelaygrace, $GUI_ENABLE)
					GUICtrlSetState($ldelaygrace, $GUI_ENABLE)
				EndIf
				$minimizetray = GUICtrlRead($chMinimizeTray)
				If $minimizetray == $GUI_CHECKED Then
					SetOption("minimizetray", 1, "number")
					$startminimized = GUICtrlRead($chstartminimized)
					If $startminimized == $GUI_CHECKED Then
						SetOption("minimizeonstart", 1, "number")
					Else
						SetOption("minimizeonstart", 0, "number")
					EndIf
					$closetotray = GUICtrlRead($chclosetotray)
					If $closetotray == $GUI_CHECKED Then
						SetOption("closetotray", 1, "number")
					Else
						SetOption("closetotray", 0, "number")
					EndIf
				Else
					SetOption("minimizetray", 0, "number")
					SetOption("minimizeonstart", 0, "number")
					SetOption("closetotray", 0, "number")
				EndIf
				If $runasexe == True Then
					$startwithwindows = GUICtrlRead($chStartWithWindows)
					$linkexe = @StartupDir & "\Upsclient.lnk"
					If $startwithwindows == $GUI_CHECKED Then
						SetOption("startwithwindows", 1, "number")
						If FileExists($linkexe) == 0 Then
							FileCreateShortcut(@ScriptFullPath, $linkexe)
						EndIf
					Else
						If FileExists($linkexe) <> 0 Then
							FileDelete($linkexe)
						EndIf
						SetOption("startwithwindows", 0, "number")
					EndIf
				Else
					SetOption("startwithwindows", 0, "number")
				EndIf
				$panel_bkg = $tempcolor1
				$clock_bkg = $tempcolor2
				$clock_bkg_bgr = RGBtoBGR($clock_bkg)
				GUISetBkColor($clock_bkg, $dial1)
				GUISetBkColor($clock_bkg, $dial2)
				GUISetBkColor($clock_bkg, $dial3)
				GUISetBkColor($clock_bkg, $dial4)
				GUISetBkColor($clock_bkg, $dial5)
				GUISetBkColor($clock_bkg, $dial6)
				GUISetBkColor($panel_bkg, $wPanel)
				$result = 1
				WriteParams()
				setTrayMode()
				AdlibUnRegister("GetUPSData")
				AdlibRegister("GetUPSData", GetOption("delay"))
				If $nMsg1 == $Bok Then
					ExitLoop
				EndIf
			Case $Bcancel
				ExitLoop
			Case $colorchoose1
				$tempcolor1 = _ChooseColor(2, 0, 2)
				If $tempcolor1 <> -1 Then
					;$panel_bkg = $tempcolor
					GUICtrlSetBkColor($colorchoose1, $tempcolor1)
				Else
					$tempcolor1 = $panel_bkg
				EndIf
				$result = 1
			Case $colorchoose2
				$tempcolor2 = _ChooseColor(2, 0, 2)
				If $tempcolor2 <> -1 Then
					;$panel_bkg = $tempcolor
					GUICtrlSetBkColor($colorchoose2, $tempcolor2)
				Else
					$tempcolor2 = $clock_bkg
				EndIf
				$result = 1
			Case $chMinimizeTray
				$minimizetray = GUICtrlRead($chMinimizeTray)
				If $minimizetray == $GUI_CHECKED Then
					GUICtrlSetState($lblstartminimized, $GUI_ENABLE)
					GUICtrlSetState($chstartminimized, $GUI_ENABLE)
					GUICtrlSetState($lblclosetotray, $GUI_ENABLE)
					GUICtrlSetState($chclosetotray, $GUI_ENABLE)
				Else
					GUICtrlSetState($chstartminimized, $GUI_UNCHECKED)
					GUICtrlSetState($chclosetotray, $GUI_UNCHECKED)
					GUICtrlSetState($lblstartminimized, $GUI_DISABLE)
					GUICtrlSetState($chstartminimized, $GUI_DISABLE)
					GUICtrlSetState($lblclosetotray, $GUI_DISABLE)
					GUICtrlSetState($chclosetotray, $GUI_DISABLE)
				EndIf
			Case $chInstantShutdown
				$InstantShutdown = GUICtrlRead($chInstantShutdown)
				If $InstantShutdown == $GUI_CHECKED Then
					GUICtrlSetState($lbldelayshutdown, $GUI_DISABLE)
					GUICtrlSetState($ldelayshutdown, $GUI_DISABLE)
				Else
					GUICtrlSetState($lbldelayshutdown, $GUI_ENABLE)
					GUICtrlSetState($ldelayshutdown, $GUI_ENABLE)
				EndIf
			Case $chAllowGrace
				$AllowGrace = GUICtrlRead($chAllowGrace)
				If $AllowGrace == $GUI_CHECKED Then
					GUICtrlSetState($lbldelaygrace, $GUI_ENABLE)
					GUICtrlSetState($ldelaygrace, $GUI_ENABLE)
				Else
					GUICtrlSetState($lbldelaygrace, $GUI_DISABLE)
					GUICtrlSetState($ldelaygrace, $GUI_DISABLE)
				EndIf
		EndSwitch
	WEnd
	If $minimizetray == 1 Then
		TraySetClick(8)
	EndIf
	GUIDelete($guipref)
	If (WinGetState($gui) <> 17) Then
		GUISetState(@SW_ENABLE, $gui)
		WinActivate($gui)
	EndIf
	$guipref = 0
	Return $result
EndFunc   ;==>prefGui

Func OpenMainWindow()
	Local $aLanguageList = _i18n_GetLocaleList()

	$gui = GUICreate($ProgramDesc, 640, 380, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_CLIPCHILDREN))
	GUISetIcon(@TempDir & "upsicon.ico")
	$fileMenu = GUICtrlCreateMenu("&" & __("File"))
	$listvarMenu = GUICtrlCreateMenuItem("&" & __("List UPS Vars"), $fileMenu)
	$exitMenu = GUICtrlCreateMenuItem("&" & __("Exit"), $fileMenu)
	$editMenu = GUICtrlCreateMenu("&" & __("Connection"))
	$reconnectMenu = GUICtrlCreateMenuItem("&" & __("Reconnect"), $editMenu)
	$settingsMenu = GUICtrlCreateMenu("&" & __("Settings"))
	$settingssubMenu = GUICtrlCreateMenuItem("&" & __("Preferences"), $settingsMenu)
	$LanguageSettings = GUICtrlCreateMenu("&" & __("Language"), $settingsMenu)
	$LangSubMenuSystem = GUICtrlCreateMenuItem("&" & __("System"), $LanguageSettings)
	If UBound($aLanguageList) > 1 Then
		; Create dictionary object
		$MenuLangListhwd = ObjCreate("Scripting.Dictionary")
		$MenuLangListhwd.Add('system', $LangSubMenuSystem)
		GUICtrlCreateMenuItem("", $LanguageSettings)
		If Not @error Then
			For $l = 1 To $aLanguageList[0]
				Local $langid = _StringBetween($aLanguageList[$l], '(', ')', $STR_ENDNOTSTART, False)
				$MenuLangListhwd.Add($langid[0], GUICtrlCreateMenuItem("&" & $aLanguageList[$l], $LanguageSettings))
			Next
		EndIf
	EndIf
	Local $ActualLang = GetOption("language")
	For $vKey In $MenuLangListhwd
		If $ActualLang == $vKey Then
			GUICtrlSetState($MenuLangListhwd.Item($vKey), $GUI_CHECKED)
		Else
			GUICtrlSetState($MenuLangListhwd.Item($vKey), $GUI_UNCHECKED)
		EndIf
	Next
	If $ActualLang == 'system' Then
		GUICtrlSetState($LangSubMenuSystem, $GUI_CHECKED)
	Else
		GUICtrlSetState($LangSubMenuSystem, $GUI_UNCHECKED)
	EndIf
	$helpMenu = GUICtrlCreateMenu("&" & __("Help"))
	$aboutMenu = GUICtrlCreateMenuItem(__("About"), $helpMenu)

	$log = GUICtrlCreateCombo("", 5, 335, 630, 25, BitOR($CBS_DROPDOWNLIST, 0))
	$wPanel = GUICreate("", 150, 250, 0, 70, BitOR($WS_CHILD, $WS_DLGFRAME), $WS_EX_CLIENTEDGE, $gui)
	GUISetBkColor($panel_bkg, $wPanel)
	$Label1 = GUICtrlCreateLabel(__("UPS On Line"), 8, 8, 110, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsonline = GUICtrlCreateLabel("", 121, 6, 16, 16, BitOR($SS_CENTER, $SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label2 = GUICtrlCreateLabel(__("UPS On Battery"), 8, 28, 110, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsonbatt = GUICtrlCreateLabel("", 121, 26, 16, 16, BitOR($SS_CENTER, $SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label3 = GUICtrlCreateLabel(__("UPS Overload"), 8, 48, 110, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsoverload = GUICtrlCreateLabel("", 121, 46, 16, 16, BitOR($SS_CENTER, $SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$Label4 = GUICtrlCreateLabel(__("UPS Battery low"), 8, 68, 110, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upslowbatt = GUICtrlCreateLabel("", 121, 66, 16, 16, BitOR($SS_CENTER, $SS_SUNKEN))
	GUICtrlSetBkColor(-1, $gray)
	$labelUpsRemain = GUICtrlCreateLabel(__("Remaining Time"), 8, 88, 110, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	$remainTimeLabel = GUICtrlCreateLabel($battrtimeStr, 8, 104, 130, 16, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label5 = GUICtrlCreateLabel(__("Manufacturer :"), 8, 122, 130, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsmfr = GUICtrlCreateLabel($mfr, 8, 138, 130, 16, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label14 = GUICtrlCreateLabel(__("Name :"), 8, 154, 130, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsmodel = GUICtrlCreateLabel($name, 8, 170, 130, 16, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label15 = GUICtrlCreateLabel(__("Serial :"), 8, 186, 130, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsserial = GUICtrlCreateLabel($serial, 8, 202, 130, 16, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")
	$Label16 = GUICtrlCreateLabel(__("Firmware :"), 8, 218, 130, 16, BitOR($SS_LEFTNOWORDWRAP, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 400, 0, "MS SansSerif")
	$upsfirmware = GUICtrlCreateLabel($firmware, 8, 234, 130, 16, BitOR($SS_RIGHT, $GUI_SS_DEFAULT_LABEL))
	GUICtrlSetFont(-1, 8, 800, 0, "MS SansSerif")

	$Group8 = GUICreate("", 638, 60, 0, 0, BitOR($WS_CHILD, $WS_BORDER), 0, $gui)
	$exitb = GUICtrlCreateButton(__("Exit"), 10, 10, 73, 40, 0)
	$toolb = GUICtrlCreateButton(__("Settings"), 102, 10, 73, 40, 0)
	$calc = 1 / ((GetOption("maxinputv") - GetOption("mininputv")) / 100)
	$dial1 = DrawDial(160, 70, GetOption("mininputv"), __("Input Voltage"), "V", $inputv, $needle1, $calc)
	$calc = 1 / ((GetOption("maxoutputv") - GetOption("minoutputv")) / 100)
	$dial2 = DrawDial(480, 70, GetOption("minoutputv"), __("Output Voltage"), "V", $outputv, $needle2, $calc)
	$calc = 1 / ((GetOption("maxinputf") - GetOption("mininputf")) / 100)
	$dial3 = DrawDial(320, 70, GetOption("mininputf"), __("Input Frequency"), "Hz", $inputf, $needle3, $calc)
	$calc = 1 / ((GetOption("maxbattv") - GetOption("minbattv")) / 100)
	$dial4 = DrawDial(480, 200, GetOption("minbattv"), __("Battery Voltage"), "V", $battv, $needle4, $calc, 20, 120)
	$calc = 1 / ((GetOption("maxupsl") - GetOption("minupsl")) / 100)
	$dial5 = DrawDial(320, 200, 0, __("UPS Load"), "%", $upsl, $needle5, $calc, -1, 80)
	$dial6 = DrawDial(160, 200, 0, __("Battery Charge"), "%", $upsch, $needle6, 1, 30, 101)
	GUISwitch($gui)
	GUISetState(@SW_SHOW, $Group8)
	GUISetState(@SW_SHOW, $wPanel)
EndFunc   ;==>OpenMainWindow

Func aboutGui()
	$minimizetray = GetOption("minimizetray")
	If $minimizetray == 1 Then
		TraySetClick(0)
	EndIf
	$guiabout = GUICreate("About", 324, 220, 271, 178)
	GUISetIcon(@TempDir & "upsicon.ico")
	$GroupBox1 = GUICtrlCreateGroup("", 8, 0, 308, 184)
	$Image1 = GUICtrlCreatePic(@TempDir & "ups.jpg", 16, 16, 104, 104, BitOR($SS_NOTIFY, $WS_GROUP))
	$Label10 = GUICtrlCreateLabel($ProgramDesc, 128, 16, 180, 18, $WS_GROUP)
	$Label11 = GUICtrlCreateLabel(__("Version ") & $ProgramVersion, 128, 34, 180, 18, $WS_GROUP)
	$Label12 = GUICtrlCreateLabel("Copyright Michael Liberman" & @LF & "2006-2007", 128, 52, 270, 44, $WS_GROUP)
	$Label13 = GUICtrlCreateLabel("Based from Winnut Sf https://sourceforge.net/projects/winnutclient/", 16, 128, 270, 44, $WS_GROUP)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$AboutBtnOk = GUICtrlCreateButton("&OK", 126, 188, 72, 24)
	GUISetState(@SW_SHOW, $guiabout)
	GUISetState(@SW_DISABLE, $gui)
	While 1
		$nMsg2 = GUIGetMsg()
		Switch $nMsg2
			Case $GUI_EVENT_CLOSE, $AboutBtnOk
				GUIDelete($guiabout)
				$guiabout = 0
				If (WinGetState($gui) <> 17) Then
					GUISetState(@SW_ENABLE, $gui)
					WinActivate($gui)
				EndIf
				If $minimizetray == 1 Then
					TraySetClick(8)
				EndIf
				ExitLoop
		EndSwitch
	WEnd
EndFunc   ;==>aboutGui

Func ShutdownGui()
	Local $Halt, $msg

	$ShutdownDelay = GetOption("ShutdownDelay")
	$grace_time = GetOption("GraceDelay")
	$AllowGrace = GetOption("AllowGrace")
	$guishutdown = GUICreate("Shutdown", (290 + $AllowGrace * 110), 120, -1, -1, BitOR($WS_EX_TOPMOST, $WS_POPUP))
	$Grace_btn = GUICtrlCreateButton("Grace Time", 10, 10, 100, 100, BitOR($BS_NOTIFY, $GUI_SS_DEFAULT_BUTTON))
	If $AllowGrace = 0 Then GUICtrlSetState($Grace_btn, $GUI_HIDE)
	$Shutdown_btn = GUICtrlCreateButton("Shutdown Immediately" & @CRLF & "Double-Click to Shutdown", (180 + $AllowGrace * 110), 10, 100, 100, BitOR($BS_MULTILINE, $BS_NOTIFY, $GUI_SS_DEFAULT_BUTTON))
	$lbl_ups_status = GUICtrlCreateLabel("", (8 + $AllowGrace * 110), 10, 170, 40)
	$lbl_countdown = GUICtrlCreateLabel("", (8 + $AllowGrace * 110), 45, 170, 70)
	GUICtrlSetFont(-1, 48, 800, 0, "MS SansSerif")
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor(-1, 0x000000)
	GUISetState(@SW_SHOW, $guishutdown)
	Reset_Shutdown_Timer()
	Init_Shutdown_Timer()
	$sec = @SEC
	$REDText = 1
	While 1
		$nMsg3 = GUIGetMsg()
		Select
			Case $nMsg3 = $Grace_btn
				GUICtrlSetState($Grace_btn, $GUI_DISABLE)
				_Timer_SetTimer($guishutdown, $grace_time * 1000, "_Restart_Compteur")
				$Suspend_Countdown = 1
				AdlibUnRegister("Update_compteur")
			Case $nMsg3 = $Shutdown_btn Or $en_cours = 0
				GUICtrlSetState($Grace_btn, $GUI_DISABLE)
				GUICtrlSetState($Shutdown_btn, $GUI_DISABLE)
				AdlibUnRegister("Update_compteur")
				Reset_Shutdown_Timer()
				Shutdown(17)
				Exit
			Case IsShutdownCondition() = False
				AdlibUnRegister("Update_compteur")
				Reset_Shutdown_Timer()
				GUIDelete($guishutdown)
				ExitLoop
			Case $Suspend_Countdown = 1
				If @SEC <> $sec Then
					$sec = @SEC
					If $REDText Then
						GUICtrlSetColor($lbl_countdown, 0xffffff)
					Else
						GUICtrlSetColor($lbl_countdown, 0xff0000)
					EndIf
					$REDText = Not $REDText
				EndIf
		EndSelect
	WEnd
EndFunc   ;==>ShutdownGui
