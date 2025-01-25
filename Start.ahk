;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\BaseLibs\Header.ahk
    #IfWinActive, Gunfire Reborn
    global PWN := "Gunfire Reborn" ; Program window name
    OnExit("BeforeExiting")

;;;;;;;;;; Setting ;;;;;;;;;;

;;;;;;;;;; Variables ;;;;;;;;;;
    CheckingFiles(,"SavedSettings.ini")
    LoadIniSection(FP_SavedSettings, "Gunfire Reborn")
    ;--------------------------------------------------
    gNameKey := [AbilityB_Key, AbilityA_Key, ShiftB_Key, Jump_Key]
    global gStatusKey := []
    for A_Loop, A_key in [AbilityB_Status, AbilityA_Status, Shift_Status, Jump_Status]
        gStatusKey.Push(A_key ? A_key : 0)
    ;--------------------------------------------------
    FunctionList := ["AoBai","RadioactiveGauntlet", "ChromaticMagazine"]
    gFunctions := {}
    Loop, % FunctionList.Count()
        gFunctions.InsertAt(A_Index, Func(FunctionList[A_Index]))
    global A_Function := A_Function ? A_Function : 0
    ;--------------------------------------------------
    global WorkingMethod := WorkingMethod ? WorkingMethod : 0
    global A_ScriptStatus

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, BaseScript

    Hotkey, *%WorkingMethodKey%, SwitchWorkingMethod
    
    for A_Loop, A_key in [AbilityB_Key, AbilityA_Key, ShiftA_Key, Jump_Key] {
        fHotkey := Func("SwitchKey").Bind(A_Loop)
        Hotkey, %EditStatusKey% & %A_key%, %fHotkey%
    } 
    for A_Loop, A_key in [IncreaseKey, DecreaseKey] {
        fHotkey := Func("SwitchFunctions").Bind(A_Loop)
        Hotkey, %EditStatusKey% & %A_key%, %fHotkey%
    } 
    fHotkey := ""

;;;;;;;;;; Gui ;;;;;;;;;;
    PlaceForTheText := " Functions "
    ;--------------------------------------------------
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale, "BorderColor" : "E6C44F", "BorderSize" : 2})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Right vT1_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T1_1, Keys:
        for A_Loop, A_key in [" Q ", " E ", "  Shift  ", "  Jump  "]
            Gui, MainInterface: Add, Text, % " x+m +Border +c" (gStatusKey[A_Loop] ? "Lime" : "Red") " vGui_Ability" A_Loop " HwndGui_Ability" A_Loop , %A_key%
        ;--------------------------------------------------
        Gui, MainInterface: Add, Text, xm y+m +Right vT2_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T2_1, Settings:
        A_Width := ((GuiLineWidth(Gui_Ability1, Gui_Ability4) - DGP.Margin.1) / 2)
        Gui, MainInterface: Add, Text, x+m w%A_Width% +Border +Center cYellow vWorkingMethod_Gui, % WorkingMethod ? "On \ Off" : "Clamp" 
        Gui, MainInterface: Add, Text, x+m w%A_Width% +Border +Center cRed vScriptStatus_Gui,` Disabled `
        ;--------------------------------------------------
        Gui, MainInterface: Add, Text, xm y+m +Right vT3_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T3_1, Functions:
        A_Width := GuiLineWidth(Gui_Ability1, Gui_Ability4)
        Gui, MainInterface: Add, Text, % " x+m w" A_Width " +Center +Border c" (A_Function ? "Lime" : "Red") " vGui_Function", % A_Function ? FunctionList[A_Function] : "Off"
    GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
    fSuspendGui("On", "MainInterface")
    if DebugGui
        fDebugGui("Create", MainInterface)
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
Return

;;;;;;;;;; Control Functions ;;;;;;;;;;
    SwitchKey(key) {
        global
        gStatusKey[key] := !gStatusKey[key]
        GuiControl, % "MainInterface: +c" (gStatusKey[key] ? "Lime" : "Red") " +Redraw", % "Gui_Ability" key
    }

    SwitchWorkingMethod() {
        global
        WorkingMethod := !WorkingMethod
        GuiControl, MainInterface: Text, WorkingMethod_Gui, % WorkingMethod ? "On \ Off" : "Clamp" 
    }

    SwitchFunctions(param) {
        global
        switch param {
            case 1 : A_Function := A_Function + 1 > FunctionList.Count() ? 0 : A_Function += 1
            case 2 : A_Function := A_Function - 1 < 0 ? FunctionList.Count() : A_Function -= 1
        }
        GuiControl, MainInterface: Text, Gui_Function, % A_Function ? FunctionList[A_Function] : "Off"
        GuiControl, % "MainInterface: +c" (A_Function ? "Lime" : "Red") " +Redraw", Gui_Function
    }

    ScriptStatus(param = "") {
        global
        if param in 1,True,On,Start
            A_ScriptStatus := 1
        else if param in 0,False,Off,Stop
            A_ScriptStatus := 0
        else
            A_ScriptStatus := !A_ScriptStatus
        GuiControl, MainInterface: Text, ScriptStatus_Gui, % A_ScriptStatus ? "Enabled" : "Disabled"
        GuiControl, % "MainInterface: +c" (A_ScriptStatus ? "Lime" : "Red") " +Redraw", ScriptStatus_Gui
        Return A_ScriptStatus
    }

;;;;;;;;;; Scripts ;;;;;;;;;;
    BaseScript() {
        global
        if WorkingMethod {
            if ScriptStatus()
                SetTimer, GunfireReborn, -1
        } Else if !A_ScriptStatus {
            ScriptStatus("Start")
            GunfireReborn()
        }
    }

    GunfireReborn() {
        global
        while (WorkingMethod && A_ScriptStatus) || GetKeyState(StartKey, "p") {
            TimeStamp(A_Stamp)
            for A_Loop, A_key in gStatusKey
                if A_key {
                    InputIfWindowActive(gNameKey[A_Loop])
                    Sleep, 1
                }
                if A_Function
                    gFunctions[A_Function].call()
                fDebugGui("Edit", "Cycle time", TimePassed(A_Stamp))
        }
        ScriptStatus("Stop")
    }

;;;;;;;;;; Additional functions ;;;;;;;;;;
    AoBai() {
        global
        IfWinActive, %PWN%
            fMouseInput("Left"), fMouseInput("Right")
    }

    RadioactiveGauntlet() {
        global
        local GameWindow := fWinGetClientPos(PWN), RG_X, RG_Y
        RG_X := GameWindow.x + Floor(GameWindow.w * ScreenRatio.1)
        RG_Y := GameWindow.y + Floor(GameWindow.h * ScreenRatio.2)
        PixelSearch,,, RG_X, RG_Y, RG_X + SizeArea.1, RG_Y + SizeArea.2, "0x"RG_Color, RG_A_Color, Fast RGB
            if !ErrorLevel
                IfWinActive, %PWN%
                    Loop, 3
                        fMouseInput("Right", 10) 
    }

    ChromaticMagazine() {
        global
        AoBai(), InputIfWindowActive(ReloadKey)
    }
    
;;;;;;;;;; Exit ;;;;;;;;;;
    BeforeExiting() {
        global
        for A_Loop, A_key in ["AbilityB_Status", "AbilityA_Status", "Shift_Status", "Jump_Status"]
            IniWrite, % gStatusKey[A_Loop] , %FP_SavedSettings%, Gunfire Reborn, %A_key%
        IniWrite, %WorkingMethod%, %FP_SavedSettings%, Gunfire Reborn, WorkingMethod
        IniWrite, %A_Function%, %FP_SavedSettings%, Gunfire Reborn, A_Function
    }