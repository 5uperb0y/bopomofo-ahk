; functions and scripts for improving user experience of Microsoft Bopomofo

; ====================
; FUNCTIONS
; ====================
; check whether IME is in chinese keyboard layout
isChineseIme(hwnd){
    threadID := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "Uint", 0)
    keyboardLayout := DllCall("GetKeyboardLayout", "UInt", threadID, "UInt", 0)
    ; 67372036 is the keyboard hexadecimal identifier of chinese (traditional, taiwan) in decimal, see https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values?view=windows-11
    return keyboardLayout == 67372036                    
}

; check whether IME is in Microsoft Bopomofo
isBopomofo(hwnd){
    DetectHiddenWindows True
    WM_IME_CONTROL := 0x283
    IMC_GETCONVERSIONMODE := 0x001
    result := SendMessage(
    	WM_IME_CONTROL, IMC_GETCONVERSIONMODE, 0,, DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", hwnd, "Uint")
    )
    if isChineseIME(hwnd){
        return result == 1
    } else {
        return result == 0
    }
}

; send strings in english when IME is under Microsoft Bopomofo 
sendEng(str){
    Send "{Shift}" ; assume that IME is under Microsoft Bopomofo
    Send str
    Send "{Shift}"
}

; change bopomofo strings that can not compose chinesese character into alphanumeric characters
; [TODO|2023-01-29]: support numeric inputs, deal with space key input 
zhToEng(){
    ; the maximum length of bopomofo strings that compose chinese characters is four
    ih := inputHook("L4 V", "{Enter}") 
    ih.Start()
    ih.Wait()
    ; bopomofo strings that compose chinese characters feature tone keys such as 3, 4, 6, 7, and Space.
    if !RegExMatch(ih.Input, "3|4|6|7| ") {
        sendEng(ih.Input)
    }
}

; ====================
; MAIN 
; ====================

; remap CapsLock to Down, which serves a word candidate toggle in ime 
; [TODO|2023-01-29]: add toggle for this hotkey remapping
#HotIf isBopomofo(WinGetID("A"))
CapsLock::Down
^CapsLock::CapsLock

; turn on/off automatic changing key sequences to alphanumeric characters  
; to understand how does the following toggle work, see https://www.autohotkey.com/docs/v2/FAQ.htm#repeat
; [TODO|2023-01-29]: fix the problem that zhToEng() does not stop immediately (extra one run..) after turning off the function
#MaxThreadsPerHotkey 3
^Home::{
    static toggle := false
    if toggle {
        toggle := false
        return
    } else {
        toggle := true
        Loop{
            if isBopomofo(WinGetID("A")) {
                Send zhToEng()
            }
            if !toggle {
                break
            }
        }
    }
    toggle := false
}
#MaxThreadsPerHotkey 1
