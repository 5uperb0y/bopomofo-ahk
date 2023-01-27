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
    return result == 1
}

; remap CapsLock to Down, which serves a word candidate toggle in ime 
#HotIf isBopomofo(WinGetID("A"))
CapsLock::Down
^CapsLock::CapsLock