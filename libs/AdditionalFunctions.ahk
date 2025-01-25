;;;;;;;;;; Loading ;;;;;;;;;;

;;;;;;;;;; Variables ;;;;;;;;;;

;;;;;;;;;; Additional functions ;;;;;;;;;;
    InputIfWindowActive(Key_Code, Key_status = "", NameWindow = "") {
        if (!NameWindow && !PWN)
            MsgBox, 4144, Input If Window Active, Window name error
        NameWindow := NameWindow ? NameWindow : PWN
        IfWinActive, %NameWindow%
            Send, {Blind}{%Key_Code% %Key_status%}
    }

    fWinGetClientPos(winTitle) {
        if !hWnd := WinExist(winTitle)  {
           MsgBox, winTitle is wrong
           Return
        }
        VarSetCapacity(WINDOWINFO, 60, 0)
        DllCall("GetWindowInfo", Ptr, hWnd, Ptr, &WINDOWINFO)
        Return { x: x := NumGet(WINDOWINFO, 20, "UInt")
               , y: y := NumGet(WINDOWINFO, 24, "UInt")
               , w: NumGet(WINDOWINFO, 28, "UInt") - x
               , h: NumGet(WINDOWINFO, 32, "UInt") - y }
    }