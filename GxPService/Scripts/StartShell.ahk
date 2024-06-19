	SetTitleMatchMode, 2
	#SingleInstance Force
	#NoEnv
	#Persistent
	#NoTrayIcon
	#InstallKeybdHook
	#UseHook



; Function to verify the identity of the caller
CallerIsTrustedService() {
    ; Check if the correct token is provided
    if (A_Args.Length() > 0 && A_Args[1] = "a13e07c188ba1fd889773096e0bfeccf") {
        ; Check for a unique registry value indicating a trusted launch
        RegRead, trustedLaunch, HKEY_LOCAL_MACHINE, Software\VShield\GxPService\Agents\rns, TrustedLauncher
		;MsgBox, %trustedLaunch% ; Debugging: Show the value of trustedLaunch
        if (trustedLaunch = "true") {
            ;MsgBox, The script was launched by a trusted source.
			RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, Software\VShield\GxPService\Agents\rns, TrustedLauncher, false

            return true
        }
    }
    return false
}

; Check if the correct token is provided
if (!CallerIsTrustedService()) {
    MsgBox, Access denied. This script can only be called from the trusted source.
    ExitApp
}




	
b64Decode(string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
}


; Initialize variables to store the settings
StartButton := "0"

IfExist, %SystemDrive%\ProgramData\Origami IT Lab\VShield\GxPService\AHK\Configuration.enc
{
    SettingsFile = %SystemDrive%\ProgramData\Origami IT Lab\VShield\GxPService\AHK\Configuration.enc
    
    ; Read the base64-encoded content from the file
    FileRead, encodedContent, %SettingsFile%
    
    ; Decode the base64-encoded content
    decodedContent := b64Decode(encodedContent)
    
    ; Split the INI content into an array of lines
    lines := StrSplit(decodedContent, "`r`n")


    ; Loop through each line of the INI content
    for each, line in lines
    {
        ; Debug: Show the raw line content
        ;MsgBox, Line: %line%
        
        ; Check if the line is not empty and contains an equal sign
        if (line != "" && InStr(line, "="))
        {
            ; Split the line into key-value pairs
            keyValue := StrSplit(line, "=")
            
            ; Trim whitespace from the key and value
            key := Trim(keyValue[1])
            value := Trim(keyValue[2])
            
            ; Remove any carriage return or newline characters from the key
            key := StrReplace(key, "`r", "")
            key := StrReplace(key, "`n", "")
            
            ; Debug: Show the cleaned key and value
            ;MsgBox, Cleaned Key: %key%`nValue: %value%
            
            ; Store the value based on the key using if statements
            if (key == "Start Button") {
                StartButton := value
			}

        }
    }
        
}



	
if(StartButton="0")
{
	ExitApp
}

;Restrictdrag and drop need to be stopped from Open And Save Window
		if(control="Start1" or control="" )
		{
			#If MouseIsOverOpenWindow("ahk_class Button")
				LButton::return
				RButton::return
			#If
			#If MouseIsOverOpenWindow("ahk_class Shell_TrayWnd")
				LButton::return
				RButton::return
			#If
			#If MouseIsOverOpenWindow("ahk_class ImmersiveSwitchList")
				LButton::return
				RButton::return
			#If
			#If MouseIsOverOpenWindow("ahk_class Windows.UI.Core.CoreWindow")
				LButton::return
				RButton::return
			#If
		}
	
	MouseIsOverOpenWindow(WinTitle) {
		MouseGetPos, , , id, control
		if (control="Start1" or control="" ){
			return WinExist(WinTitle . " ahk_id " . id)
		}
	}