#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\GitHub\AltLauncher\Resources\AltLauncher.ico
#AutoIt3Wrapper_Outfile=Build\LuduSavi.AltWrapper.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Fileversion=0.1.0.0
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <Math.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
Opt("GUIOnEventMode", True)
Opt("TrayIconHide", True)
Opt("ExpandEnvStrings", True)
Global $Title = "LuduSavi AltWrapper", $backup = "backup", $restore = "restore", $Profile_Set = False, $Profile = ""
ReadEnvironmentVariables()
If RegRead("HKCU\Environment", "LuduSavi AltWrapper_Path") = "" Then Setup()
ReadConfig()
GuiInit()
Do
	Sleep(100)
Until $Profile_Set = True
CreateProfileFolderIfEmpty()
RunGame()
Exit

Func ReadEnvironmentVariables()
	EnvSet("LuduSavi AltWrapper_UseProfileFile", RegRead("HKCU\Environment", "LuduSavi AltWrapper_UseProfileFile"))
	EnvSet("LuduSavi AltWrapper_ButtonWidth", RegRead("HKCU\Environment", "LuduSavi AltWrapper_ButtonWidth"))
	EnvSet("LuduSavi AltWrapper_ButtonHeight", RegRead("HKCU\Environment", "LuduSavi AltWrapper_ButtonHeight"))
	EnvSet("LuduSavi AltWrapper_NumberOfButtonsPerDirection", RegRead("HKCU\Environment", "LuduSavi AltWrapper_NumberOfButtonsPerDirection"))
	EnvSet("LuduSavi AltWrapper_ButtonSpacing", RegRead("HKCU\Environment", "LuduSavi AltWrapper_ButtonSpacing"))
	EnvSet("LuduSavi AltWrapper_ButtonDirection", RegRead("HKCU\Environment", "LuduSavi AltWrapper_ButtonDirection"))
EndFunc   ;==>ReadEnvironmentVariables
Func ReadConfig()
	Global $ProfilesPath = (RegRead("HKCU\Environment", "LuduSavi AltWrapper_Path") <> "") ? RegRead("HKCU\Environment", "LuduSavi AltWrapper_Path") : "C:\LuduSavi AltWrapper"
	Global $ProfilesSubPath = RegRead("HKCU\Environment", "LuduSavi AltWrapper_SubPath")
EndFunc   ;==>ReadConfig
Func GuiInit()
	If $Profile <> "" Then
		$Profile_Set = True
		Return
	EndIf
	Local $aFolders = _FileListToArray($ProfilesPath, "*", $FLTA_FOLDERS)
	Local Const $iSpacing = (EnvGet("LuduSavi AltWrapper_ButtonSpacing") <> "" ? Int(EnvGet("LuduSavi AltWrapper_ButtonSpacing")) : 4)
	Local $iMaxPer = (EnvGet("LuduSavi AltWrapper_NumberOfButtonsPerDirection") <> "" ? Int(EnvGet("LuduSavi AltWrapper_NumberOfButtonsPerDirection")) : 5)
	Local $iBtnW = (EnvGet("LuduSavi AltWrapper_ButtonWidth") <> "" ? Int(EnvGet("LuduSavi AltWrapper_ButtonWidth")) : 120)
	Local $iBtnH = (EnvGet("LuduSavi AltWrapper_ButtonHeight") <> "" ? Int(EnvGet("LuduSavi AltWrapper_ButtonHeight")) : 55)
	Global $iTotal = 0
	If IsArray($aFolders) And UBound($aFolders) > 0 Then
		$iTotal = $aFolders[0]
	EndIf
	Local $sLayout = (EnvGet("LuduSavi AltWrapper_ButtonDirection") <> "" ? EnvGet("LuduSavi AltWrapper_ButtonDirection") : "down")

	Local $iCols, $iRows
	If $sLayout = "right" Then
		$iRows = Ceiling(($iTotal + 1) / $iMaxPer)
		$iCols = _Min(($iTotal + 1), $iMaxPer)
	Else ;down
		$iCols = Ceiling(($iTotal + 1) / $iMaxPer)
		$iRows = _Min(($iTotal + 1), $iMaxPer)
	EndIf

	Local $iWinW = ($iSpacing + $iBtnW + 1) * $iCols + $iSpacing + 2
	Local $iWinH = ($iSpacing + $iBtnH) * $iRows + $iSpacing + 30
	Local $hGUI = GUICreate($Title, $iWinW, $iWinH, -1, -1, $WS_SYSMENU)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseGUI")
	Local $iX = $iSpacing, $iY = $iSpacing
	For $i = 1 To $iTotal + 1
		If $i <= $iTotal Then
			Local $sLabel = $aFolders[$i]
		Else
			Local $sLabel = "+"
		EndIf
		Local $iStyle = ($sLabel = $Profile) ? BitOR($WS_BORDER, $WS_TABSTOP) : $WS_TABSTOP
		Local $hBtn = GUICtrlCreateButton($sLabel, $iX, $iY, $iBtnW, $iBtnH, $iStyle)
		If GUICtrlSetOnEvent($hBtn, "_ButtonClick") = 0 Then
			Exit MsgBox(0, "Error", "Can't register click event for: " & $sLabel & @CRLF & "[CtrlID]: " & $hBtn)
		EndIf

		If $sLayout = "down" Then
			$iY += $iBtnH + $iSpacing
			If Mod($i, $iMaxPer) = 0 Then
				$iY = $iSpacing
				$iX += $iBtnW + $iSpacing
			EndIf
		Else
			$iX += $iBtnW + $iSpacing
			If Mod($i, $iMaxPer) = 0 Then
				$iX = $iSpacing
				$iY += $iBtnH + $iSpacing
			EndIf
		EndIf
	Next
	If $iTotal = 0 Then _ButtonClick()
	GUISetState(@SW_SHOW)
EndFunc   ;==>GuiInit
Func _CloseGUI()
	Exit
EndFunc   ;==>_CloseGUI
Func _ButtonClick()
	GUISetState(@SW_HIDE)
	$Profile = ($iTotal = 0) ? "+" : GUICtrlRead(@GUI_CtrlId)
	$Profile_Set = True
	If $Profile = "+" Then
		Do
			$ChosenName = InputBox($Title, "Please enter a new profile name.")
			If @error Then
				$Profile_Set = False
				GUISetState(@SW_SHOW)
			Else
				Select
					Case $ChosenName = ""
						MsgBox(48, $Title, 'Profile name cannot be blank. Please choose another name.')
					Case FileExists($ProfilesPath & '\' & $ChosenName) = True
						MsgBox(48, $Title, 'Profile "' & $ChosenName & '" already exists. Please choose another name.')
				EndSelect
			EndIf
		Until FileExists($ProfilesPath & '\' & $ChosenName) = False Or $Profile_Set = False
		DirCreate($ProfilesPath & '\' & $ChosenName)
		$Profile = $ChosenName
	EndIf
EndFunc   ;==>_ButtonClick
Func CreateProfileFolderIfEmpty()
	DirCreate($ProfilesPath & '\' & $Profile & '\' & $ProfilesSubPath & '\')
EndFunc   ;==>CreateProfileFolderIfEmpty
Func RunGame()
	ShellExecute(@ScriptDir & "\ludusavi.exe", 'wrap --gui --path "' & $ProfilesPath & '\' & $Profile & '\' & $ProfilesSubPath & '\" ' & $cmdlineraw, @ScriptDir)
EndFunc   ;==>RunGame
Func ExitMSG($msg)
	Exit MsgBox($MB_OK + $MB_ICONERROR + $MB_SYSTEMMODAL, "LuduSavi AltWrapper", $msg)
EndFunc   ;==>ExitMSG
Func Setup()
	MsgBox(0, $Title, "Welcome to LuduSavi AltWrapper. Since this is the first time you've ran this program, we need to do some setup first." & @CRLF & @CRLF & "Click ok to proceed.")
	MsgBox(0, $Title, "Please select where you want your save slots to be stored on the next window.")
	RegWrite("HKCU\Environment", "LuduSavi AltWrapper_Path", "REG_SZ", FileSelectFolder($Title, "", $FSF_CREATEBUTTON, "C:\LuduSavi AltWrapper"))
	RegWrite("HKCU\Environment", "LuduSavi AltWrapper_SubPath", "REG_SZ", InputBox($Title, "If you need to set up a sub-path, enter it now." & @CRLF & "If you don't need this, leave blank and click ok."))
	Exit MsgBox(0, $Title, "Setup Complete. Please relaunch LuduSavi AltWrapper.")
EndFunc   ;==>Setup
