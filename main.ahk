#Requires AutoHotkey v2.0


start_time := a_tickcount

VERSION := "v3.3"

try {
    if !isset(newthread) {
        throw
    }
} catch error {

}

global main := gui("-caption -minimizebox -maximizebox", "obby macros v3")
    main.backcolor := "333845"
    main.setfont("q2", "segoe ui")
    main_top_raw                := 40
    main_leftoffset_raw         := 10
    main_toggletype_width_raw   := 30
    main_toggletype_xoffset_raw := 110
    main_leftoffset             := "x" main_leftoffset_raw " "
    main_toggletype_width       := " w" main_toggletype_width_raw
    main_exitapp_bind           := "*!p"
    global main_width_raw       := 300
    global main_height_raw      := 400
    main_top                    := "y" main_top_raw
    main_width                  := "w" main_width_raw
    main_height                 := "h" main_height_raw
    installmousehook
    setmousedelay -1

sendmode "input"

setworkingdir "C:\Users\" a_username "\AppData\Local"
    dircreate "Obby Macros V3"

setworkingdir "C:\Users\" a_username "\AppData\Local\Obby Macros V3"
    if !fileexist("config.ini") {
        fileappend "", "config.ini"
    }

hotkey main_exitapp_bind, hotkey_exitapp

hotkey_exitapp(thishotkey) {
    exitapp
}

guictrl_exitapp(x, y) {
    exitapp
}

haskey(obj, key) {
    try {
        value := obj[key]
        return true
    } catch {
        return false
    }
}

hextodec(hex) {
    result := 0

    if (substr(hex, 1, 2) == "0x") {
        hex := substr(hex, 3)
    }

    hex_digits := "0123456789ABCDEF"

    loop parse, hex {
        digit := substr(A_LoopField, 1, 1)
        value := instr(hex_digits, digit) - 1
        result := result * 16 + value
    }

    return result
}

clamp(min := false, max := false, value := false) {
    if !value {
        msgbox "clamp error: no value"
        exitapp
    }

    if max {
        if value > max {
            return max
        }
    }

    if min {
        if value < min {
            return min
        }
    }

    return value
}

gui_center(control_width, gui_width) {
    return "x" (gui_width / 2) - (control_width / 2)
}

guictrl_center_raw(controlname, width) {
    controlname.getpos(&getpos_x,, &getpos_width)

    if !isinteger(getpos_width) {
        regexreplace(getpos_width, "x")
    }

    return (getpos_x + (getpos_width - width) / 2)
}

guictrl_center(controlname, width) {
    controlname.getpos(&getpos_x,, &getpos_width)
    return "x" guictrl_center_raw(controlname, width) " "
}

moveside_raw(controlname, side) {
    controlname.getpos(,,&getpos_width)
    side := strlower(side)

    if side = "left" {
        return (main_width_raw / 4) - (getpos_width / 2)
    } else if side = "right" {
        return (main_width_raw / 2) + (main_width_raw / 4) - (getpos_width / 2)
    } else {
        msgbox "Error: invalid side"
    }
}

moveside(controlname, side) {
    return "x" moveside_raw(controlname, side) " "
}

fullguictrl_center(centeredctrl, refctrl) {
    centeredctrl.getpos(,,&getpos_width)
    centeredctrl.move(guictrl_center_raw(refctrl,getpos_width))
}

fps(x) {
    return 1000 / x
}

guictrl_setrightof(setctrl, refctrl) {
    refctrl.getpos(&getpos_x, &getpos_y, &getpos_width)
    setctrl.move(getpos_x + getpos_width, getpos_y)
}

global hotkeyselect_exitkeys := "{backspace}{delete}{escape}"

global hotkeyselect_mousekeys := [
    "lbutton",
    "mbutton",
    "rbutton",
    "xbutton1",
    "xbutton2",
    "wheeldown",
    "wheelup",
    "wheelleft",
    "wheelright",
    "lalt",
    "ralt",
    "lwin",
    "rwin",
    "lshift",
    "rshift"
]

global hotkeyselect_inviskeys := [
    "09 TAB",
    "0d ENTER",
    "20 SPACE"
]

global inputhook_stop_mousekeys := false

hotkeyselect(x, y, valueselect := false, checkbox := false) {
    if !checkbox {
        msgbox "Error: Params #4 is invalid"
        exitapp
    }

    global inputhook_stop_mousekeys := false
    x.text := "[...]"
    x.move(,,strlen(x.text) * 10 - 6)

    if valueselect {
        guictrl_setrightof(valueselect, x)
    }
    
    global checkkeys_value := ""

    checkkeys() {
        for i, v in hotkeyselect_inviskeys {
            inviskey := strsplit(v, " ")
            if getkeyvk(ih.input) = hextodec(inviskey[1]) {
                global checkkeys_value := inviskey[2]
                return true
            }
        }
        return false
    }

    if valueselect {
        guictrl_setrightof(valueselect, x)
    }

    global ih := inputhook("L1 M B", hotkeyselect_exitkeys)

    ih.start()

    for _, v in hotkeyselect_mousekeys {
        hotkey v, inputhookstop, "On"
    }
    
    inputhookstop(thishotkey) {
        ih.stop()
        x.text := "[" strupper(thishotkey) "]"
        x.move(,,strlen(x.text) * 10 - 6)
        if valueselect {
            guictrl_setrightof(valueselect, x)
        }
        for _, v in hotkeyselect_mousekeys {
            hotkey v, inputhookstop, "Off"
        }
        inputhook_stop_mousekeys := true
        if !checkbox.value {
            return
        }
        checkbox.boundfunc(checkbox)
    }

    ih.wait()

    if inputhook_stop_mousekeys {
        return
    }

    if strlower(ih.endreason) = "endkey" {
        x.text := "[NONE]"
    } else if checkkeys() {
        x.text := "[" checkkeys_value "]"
    } else {
        x.text := "[" strupper(ih.input) "]"
    }

    x.move(,,strlen(x.text) * 10 - 6)

    if valueselect {
        guictrl_setrightof(valueselect, x)
    }

    for _, v in hotkeyselect_mousekeys {
        hotkey v, inputhookstop, "Off"
    }

    if !checkbox.value {
        return
    }

    checkbox.boundfunc(checkbox)
    ; WIP, NEEDS TO WORK WITH MODIFIERS
}

global amountselect_identifier := ""

amountselect(x, y, checkbox, unit := false, min := false, max := false) {
    ; REALLY BAD HARD CODED CODE BUT IT WORKS
    global using_drag_function, amountselect_identifier

    ; disables drag function
    using_drag_function := false

    ; checks if a checkbox boundfunc exists
    boundfunc_nonexistent := false

    try {
        if checkbox.boundfunc {

        }
    } catch error {
        boundfunc_nonexistent := true
    }

    ; get old text
    oldtext := regexreplace(x.text, "[\[\]]")
    x.text := "["

    ; get old width
    x.getpos(,, &old_width)

    ; hardcoded width resize
    x.move(,, 6)

    if amountselect_identifier = "" {
        guiparent := x.gui
        global rightbracket := guiparent.addtext(, "]")
        global editbox := guiparent.addedit("cblack w50")
        editbox.setfont(, "consolas")
        amountselect_identifier := editbox.classnn
    }

    ; forces editbox and rightbracket to be visible
    editbox.visible := true
    rightbracket.visible := true

    ; sets editbox and rightbracket to their positions
    guictrl_setrightof(editbox, x)
    guictrl_setrightof(rightbracket, editbox)
    rightbracket.getpos(, &getpos_y)
    rightbracket.move(, getpos_y-2)

    ; focusses on editbox
    editbox.focus()

    ; sets editbox text to be oldtext
    if isnumber(oldtext) {
        editbox.value := oldtext
    }

    ; exit amountselect function
    exitselect() {
        hotifwinactive "obby macros v3"
        hotkey "lbutton", detectclick, "off"
        hotkey "lbutton", drag, "on"
        hotifwinactive

        if !isnumber(editbox.value) {
            ; hardcoded width resize
            x.move(,, 44)
            x.text := "[N/A]"
            
            editbox.visible := false
            rightbracket.visible := false
            using_drag_function := true

            boundfunc_nonexistent ? false : checkbox.boundfunc(checkbox)
            return
        }

        newvalue := min or max ? clamp(min ? min : false, max, editbox.value) : editbox.value

        x.move(,, old_width + (strlen(newvalue) * 12))

        x.text := unit ? "[" newvalue unit "]" : "[" newvalue "]"

        editbox.visible := false
        rightbracket.visible := false
        using_drag_function := true

        boundfunc_nonexistent ? false : checkbox.boundfunc(checkbox)
        return
    }

    ; check enter
    newthreadloop_1() {
        if getkeystate("enter", "p") {
            settimer , 0
            exitselect()
        }
    }

    ; check click
    detectclick(thishotkey) {
        mousegetpos ,,, &control_classnn

        if control_classnn != amountselect_identifier {
            exitselect()
        }

        if !editbox.visible or control_classnn = amountselect_identifier  {
            send "{" thishotkey " down}"
            keywait thishotkey
            send "{" thishotkey " up}"
        }
    }

    ; run check enter
    settimer newthreadloop_1, fps(60)

    ; run check click
    hotifwinactive "obby macros v3"
    hotkey "lbutton", drag, "off"
    hotkey "lbutton", detectclick, "on"
    hotifwinactive
}

global red := 0
global green := 0
global blue := 0

updaterainbow(light, speed, min) {
    global red
    global green
    global blue

    if light < min {
        msgbox "rainbow error"
        exitapp
    }

    step := (light - min) * (speed / 100)

    if red = light and green < light and blue = min {
        green += step
        green := clamp(min, 255, green)
    } else if green = light and red > min and blue = min {
        red -= step
        red := clamp(min, 255, red)
    } else if green = light and blue < light and red = min {
        blue += step
        blue := clamp(min, 255, blue)
    } else if blue = light and green > min and red = min {
        green -= step
        green := clamp(min, 255, green)
    } else if blue = light and red < light and green = min {
        red += step
        red := clamp(min, 255, red)
    } else if red = light and blue > min and green = min {
        blue -= step
        blue := clamp(min, 255, blue)
    }

    format_red := format("{:x}", red)
    format_green := format("{:x}", green)
    format_blue := format("{:x}", blue)

    if red < 16 {
        format_red := "0" format_red
    }

    if green < 16 {
        format_green := "0" format_green
    }

    if blue < 16 {
        format_blue := "0" format_blue
    }

    return "c" format_red format_green format_blue
}

drag(thishotkey := false) {
    if isset(loaded) {
        global loaded
        global under_title
        global title
        global main
    }

    if strlower(thishotkey) != "lbutton" and thishotkey {
        msgbox "error: drag() being used by a non-lbutton hotkey"
        exitapp
    }

    coordmode "tooltip", "screen"
    mousegetpos &test_x, &test_y
    mousegetpos ,,, &control_classnn
    coordmode "mouse", "window"
    mousegetpos &mouse_x_window, &mouse_y_window

    if !isset(loaded) {
        send "{" thishotkey " down}"
        keywait thishotkey
        send "{" thishotkey " up}"
        return
    }

    if isset(loaded) {
        if control_classnn = under_title.classnn or control_classnn = title.classnn {
            if !thishotkey {
                tooltip "success: " control_classnn, test_x, test_y + 10
                return
            }
            while getkeystate(thishotkey, "P") {
                coordmode "mouse", "screen"
                mousegetpos &mouse_x_screen, &mouse_y_screen
                main.move(mouse_x_screen - mouse_x_window, mouse_y_screen - mouse_y_window)
            }
        } else {
            if !thishotkey {
                tooltip "fail: " control_classnn, test_x, test_y + 10
                return
            }
            send "{" thishotkey " down}"
            keywait thishotkey
            send "{" thishotkey " up}"
        }
    }
}

global toggle_counter := 0
global caption_counter := 0
global first_checkbox := ""
global valued_guictrls := map()

create_checkbox(gui, &name, text, action_function := false, hotkey := false, valueselect := false, add_caption := false, enabled := false) {
    if !action_function {
        msgbox "Error: checkbox has no action_function"
        exitapp
    }

    global toggle_counter, first_checkbox, caption_counter, valued_guictrls

    main_heightoffset_raw := 45
    name := gui.addcheckbox(main_leftoffset "y" main_heightoffset_raw + (20 * toggle_counter) + caption_counter, text)
    name.value := enabled
    enabled ? name.setfont("cc0ffc0") : name.setfont("cffc0c0")

    toggle_counter += 1

    if isobject(add_caption) {
        caption_string := add_caption[1]
        caption_text_size := add_caption[2]
        checkbox_text_size := add_caption[3]
        name.getpos(&getpos_x, &getpos_y,, &getpos_height)
        gui.setfont(caption_text_size)
        caption := gui.addtext(, caption_string)
        caption.move(getpos_x, getpos_y + getpos_height - 1)
        caption.setfont(caption_text_size)
        caption.getpos(,,, &getpos_height)
        gui.setfont(checkbox_text_size)
        caption_counter += getpos_height + 3 ; plus three due to tailed letters like y, g, p, q, j clipping into the checkbox below, plus a gap for aesthetics
    }

    if hotkey {
        hotkey_noref := create_hotkey(gui, name, &hotkey)
    }

    if isobject(valueselect) {
        valueselect_name  := valueselect[1]
        starting_value    := valueselect[2]
        valueselect_length := valueselect.length

        ; really bad way of doing this :skull:
        if valueselect_length >= 3 {
            valueselect_unit := valueselect[3]
            if valueselect_length >= 4 {
                valueselect_min := valueselect[4]
                if valueselect_length >= 5 {
                    valueselect_max := valueselect[5]
                }
            }
        }

        valueselect_noref := create_valueselect(gui, name,
            &valueselect_name,
            starting_value,
            isset(valueselect_unit) ? valueselect_unit : false,
            isset(valueselect_min) ? valueselect_min : false,
            isset(valueselect_max) ? valueselect_max : false
        )
    }

    name.boundfunc := macro_toggle_function.bind(,,
        hotkey ? hotkey : false,
        isobject(valueselect) ? valueselect_noref : false,
        action_function
    )

    name.onevent("click", name.boundfunc)

    return_array := [name, isset(hotkey_noref) ? hotkey_noref : false, isset(valueselect_noref) ? valueselect_noref : false]

    valued_guictrls[name] := return_array

    if toggle_counter != 1 {
        return return_array
    }
    
    first_checkbox := name
    return return_array
}

create_text(gui, &name, text, valueselect, add_caption := false) {
    global toggle_counter, first_checkbox, caption_counter

    main_heightoffset_raw := 45
    name := gui.addtext(main_leftoffset "y" main_heightoffset_raw + (20 * toggle_counter) + caption_counter, text " ")
    name.setfont("cc0c0ff")

    toggle_counter += 1

    if isobject(add_caption) {
        caption_string := add_caption[1]
        caption_text_size := add_caption[2]
        checkbox_text_size := add_caption[3]
        name.getpos(&getpos_x, &getpos_y,, &getpos_height)
        gui.setfont(caption_text_size)
        caption := gui.addtext(, caption_string)
        caption.move(getpos_x, getpos_y + getpos_height)
        caption.setfont(caption_text_size)
        caption.getpos(,,, &getpos_height)
        gui.setfont(checkbox_text_size)
        caption_counter += getpos_height
    }

    if isobject(valueselect) {
        valueselect_name  := valueselect[1]
        starting_value    := valueselect[2]
        valueselect_length := valueselect.length
        
        ; really bad way of doing this :skull:
        if valueselect_length >= 3 {
            valueselect_unit := valueselect[3]
            if valueselect_length >= 4 {
                valueselect_min := valueselect[4]
                if valueselect_length >= 5 {
                    valueselect_max := valueselect[5]
                }
            }
        }

        valueselect_noref := create_valueselect(gui, name,
            &valueselect_name,
            starting_value,
            isset(valueselect_unit) ? valueselect_unit : false,
            isset(valueselect_min) ? valueselect_min : false,
            isset(valueselect_max) ? valueselect_max : false
        )
    }

    return_array := [name, false, isset(valueselect_noref) ? valueselect_noref : false]

    valued_guictrls[name] := return_array

    if toggle_counter != 1 {
        return return_array
    }
    
    first_checkbox := name
    return return_array
}

global identify_hotkey_valueselect_counter := map()
global identifier := map()

; deprecated function due to AHK's limitations
check_for_future_value(checked_val, delay, fail_attempts, error_bypass := false) {
    global identifier

    exitfunction := false
    returnvalue := false

    newthreadloop_1() {
        if error_bypass {
            try {
                msgbox "ongoing 1"
                if checked_val {
                    msgbox "success"
                    settimer , 0
                    exitfunction := true
                    returnvalue := true
                }
    
                settimer , 0
            } catch error {
                if !identifier.has(checked_val) {
                    identifier[checked_val] := 1
                    msgbox "ongoing"
                } else {
                    identifier[checked_val] := 1 + identifier[checked_val]
                    msgbox "ongoing"
                }
    
                if identifier[checked_val] >= fail_attempts {
                    msgbox "success"
                    settimer , 0
                    exitfunction := true
                }
            }
        } else {
            if checked_val {
                settimer , 0
                exitfunction := true
                returnvalue := true
                return
            }

            if !identifier.has(checked_val) {
                identifier[checked_val] := 1
            } else {
                identifier[checked_val] := 1 + identifier[checked_val]
            }

            if identifier[checked_val] >= fail_attempts {
                settimer , 0
                exitfunction := true
                return
            }
        }
    }

    settimer newthreadloop_1, delay

    while !exitfunction {
        sleep 10
    }

    return returnvalue
}

create_hotkey(gui, checkbox, &name) {
    global identify_hotkey_valueselect_counter

    name := gui.addtext(, "[NONE]")
    name.setfont(, "consolas")
    guictrl_setrightof(name, checkbox)
    checkbox.hotkey := name

    if fileexist("config.ini") and filegetsize("config.ini") > 0 {
        cfg_values := strsplit(iniread("config.ini", "main", checkbox.classnn), "|")
        cfg_value := strupper(cfg_values[1])
        old_length := strlen(name.value)
        name.value := "[" cfg_value "]"
        new_length := strlen(name.value)
        name.move(,,strlen(name.text) * 10 - 6)
    }

    ; terrible way of doing this but idrc
    newthreadloop_1() {
        try {
            ; checks if a valueselect exists and sets a boundfunc declaration and an onevent declaration with valueselect as a param if it does
            ; checkbox.valueselect would error if it doesn't exist
            if checkbox.valueselect {
                name.boundfunc := hotkeyselect.bind(,, checkbox.valueselect, checkbox)
                name.onevent("click", name.boundfunc)
            }

            settimer , 0
        } catch error {
            ; when catching the error, it adds 1 to a counter
            if !identify_hotkey_valueselect_counter.has(checkbox.hotkey) {
                identify_hotkey_valueselect_counter[checkbox.hotkey] := 1
            } else {
                identify_hotkey_valueselect_counter[checkbox.hotkey] += 1
            }

            ; if the error has been caught 3 or more times, it will set a boundfunc declaration and an onevent declaration without valueselect as a param
            if identify_hotkey_valueselect_counter[checkbox.hotkey] >= 3 {
                name.boundfunc := hotkeyselect.bind(,,, checkbox)
                name.onevent("click", name.boundfunc)
                settimer , 0
            }
        }
    }

    settimer newthreadloop_1, fps(20)

    try {
        if checkbox.valueselect {
            guictrl_setrightof(name, checkbox.valueselect)
            return name
        }
    } catch error {
        return name
    }
}

global identify_valueselect_hotkey_counter := map()

create_valueselect(gui, checkbox, &name, default_value, unit := false, min := false, max := false, freeform := false) {
    global identify_valueselect_hotkey_counter, valueselects

    gui.setfont(, "consolas")
    name := unit ? gui.addtext(, "[" default_value unit "]") : gui.addtext(, "[" default_value "]")
    checkbox.valueselect := name

    name.boundfunc := amountselect.bind(,,
        checkbox, unit ? unit : false,
        min ? min : false,
        max ? max : false
    )

    name.onevent("click", name.boundfunc)

    gui.setfont(, "segoe ui")

    if fileexist("config.ini") and filegetsize("config.ini") > 0 {
        cfg_values := strsplit(iniread("config.ini", "main", checkbox.classnn), "|")
        cfg_value := cfg_values[2]
        if cfg_value = "" {
            cfg_value := 0
        }
        old_length := strlen(name.value)
        name.value := unit ? "[" cfg_value unit "]" : "[" cfg_value "]"
        new_length := strlen(name.value)
        name.getpos(,, &getpos_width)
        name.move(,, getpos_width + (new_length * 12))
    }

    try {
        if checkbox.hotkey {
            guictrl_setrightof(name, checkbox.hotkey)
            return name
        }
    } catch error {
        guictrl_setrightof(name, checkbox)
        return name
    }
}

getarrayvalue(value, array) {
    for _, v in array {
        if v = value {
            return v
        }
    }

    msgbox "No array value found"
}

; global bottom_texts_heights := map()

bottom_text(gui, &name, string := false, rightside := false) {
    global bottom_texts_heights

    string ? true : string := "N/A"
    name := gui.addtext(, string)
    name.getpos(,, &getpos_width, &getpos_height)
    name.move(!rightside ? 10 : main_width_raw - getpos_width - 10, main_height_raw - getpos_height - 10)

    ; bottom_texts_heights[name] := getpos_height

    return name
}

main.setfont("cwhite s14 bold")
    under_title := main.addtext("x0 y0")
    title := main.addtext("x0 y10 " main_width " Center", "Obby Macros " VERSION)

    ;settimer drag, fps(60)

    hotifwinactive "obby macros v3"
    hotkey "lbutton", drag, "on"
    hotifwinactive

    title_rainbow() {
        rainbow_step := updaterainbow(rainbow_declaration, 3, rainbow_min)
        title.setfont("cwhite s14 bold " rainbow_step)
    }

    global title_rainbow

    global rainbow_declaration := 255
    global rainbow_min := 200

    global red := rainbow_declaration
    global green := rainbow_min
    global blue := rainbow_min

    ; stupid ass rainbow

    try {
        if !isset(criticalobject) {
            throw
        }
        rainbow_critical_object := criticalobject({
            fps: fps,
            title_rainbow: title_rainbow
        })
    } catch error {

    }

    if isset(newthread) and isset(rainbow_critical_object) {
        rainbowthread := newthread("
        (
            rainbow_data := criticalobject(a_args)

            msgbox "object properties: " json.stringify(rainbow_data)

            while true {
                rainbow_data.title_rainbow()
                sleep rainbow_data.fps(144)
            }
        )", &rainbow_critical_object)
    }

main.setfont("cwhite s14 bold")
    close_button := main.addtext(, "X")
        close_button.setfont("cred", "consolas")
        close_button.getpos(,, &getpos_width)
        close_button.move(main_width_raw - getpos_width - 10, 8)
        close_button.onevent("click", guictrl_exitapp)

under_title.move(,, main_width_raw - getpos_width - 20)

main.setfont("cwhite s12 norm")
    ; quick tip, if you're defining the valueselect array, make sure to convert any number that has a decimal into a string to prevent a flurry of 0s
    ; i have yet to have create_checkbox return an array of useful things
    global flick_macro      := create_checkbox(main, &flick_macro_checkbox,      "Flick Macro",       flick,    &flick_macro_hotkey,      [&flick_macro_valueselect,      45,  "°", -1000, 1000], ["lets you flick, mainly for wall hops",                 "s8", "s12"])
    global wallwalk_macro   := create_checkbox(main, &wallwalk_macro_checkbox,   "Wallwalk Macro",    wallwalk, &wallwalk_macro_checkbox, [&wallwalk_macro_valueselect,   15,  "°", -1000, 1000], ["spams flick",                                          "s8", "s12"])
    global cornerclip_macro := create_checkbox(main, &cornerclip_macro_checkbox, "Corner Clip Macro", flick,    &cornerclip_macro_hotkey, [&cornerclip_macro_valueselect, 180, "°", -1000, 1000], ["flicks 180°, unless you change it",                    "s8", "s12"])
    global freeze_macro     := create_checkbox(main, &freeze_macro_checkbox,     "Freeze Macro",      freeze,   &freeze_macro_hotkey,,                                                            ["freezes roblox without the white bar, hold to freeze", "s8", "s12"])
    global low_fps_macro    := create_checkbox(main, &low_fps_macro_checkbox,    "Low FPS Macro",     low_fps,  &low_fps_macro_hotkey,    [&low_fps_macro_valueselect,    30, " FPS"],            ["spams freeze to replicate low fps, inaccurate",        "s8", "s12"])

main.setfont("cwhite s11 norm")
    global roblox_sensitivity := create_text(main, &roblox_sensitivity_text, "In-game Roblox Sensitivity", [&roblox_sensitivity_valueselect, "0.2", "", 0, 4], ["Please set this! It helps to create more accurate flicks", "s8", "s11"])

main.setfont("cwhite s10 norm")
    bottom_text(main, &bottom_exitapp_info,       "Created by @anbubu`n° = degree symbol`nFYI: Roblox Sensitivity affects flick amount`nForce Quit: Alt + P")
    loaded_in_text := bottom_text(main, &bottom_loaded_time, "loaded in: ", true)

/*
my rough calculation:
through some testing, for every 9 pixels on 0.2 sens, you flick roughly 90 degrees
    therefore 9 pixels * 0.2 sens = 90 degrees, 9 pixels * 1 sens = 450 degrees, 1 pixel * 1 sens = 50 degrees
    degree multiplication is 50 (rough estimate)
    to get amount of pixels to flick with degree and sens, it is 50 degrees / 1 sens / 50 = 1 pixel, 50 degrees / 0.2 sens / 50 = 5 pixels
*/

first_checkbox.getpos(, &getpos_y)
under_title.move(,,, getpos_y)
under_title.getpos(,, &getpos_width, &getpos_height)

global toggle_hotkey_map := map()
global hotkey_function_map := map()
global hotkey_checkbox_map := map()

macro_toggle_function(x, y := false, hotkey_guictrl := false, valueselect_guictrl := false, action_function := false) {
    global toggle_hotkey_map, hotkey_function_map, hotkey_checkbox_map

    if !action_function {
        msgbox "An Error has occurred: macro_toggle_function does not have an action_function"
        exitapp
    }

    ; color of checkboxes when toggling
    color := x.value ? "cc0ffc0" : "cffc0c0"
    x.setfont("c" . color)

    ; dumb fix for mouse buttons working 💀
    new_x_value := x.value ? "On" : "Off"

    macro_key := strlower(regexreplace(hotkey_guictrl.Text, "[\[\]]"))
    
    ; if hotkey not set or in the middle of setting, don't do anything
    if macro_key = "none" or macro_key = "..." or valueselect_guictrl.text = "[N/A]" {
        return
    }

    valueselect_guictrl ? amount := number(regexreplace(valueselect_guictrl.Value, "[^0-9.]")) : amount := false

    toggle_used := x.classnn

    ; check if the new hotkey is already in use by another checkbox
    if hotkey_checkbox_map.has(macro_key) and hotkey_checkbox_map[macro_key] != toggle_used {
        msgbox "the hotkey '" macro_key "' is already in use by another checkbox`nplease choose a different hotkey.", "Same Hotkey Error", "T3"
        hotkey_guictrl.value := "[NONE]"
        hotkey_guictrl.move(,,52)

        if valueselect_guictrl {
            valueselect_guictrl.getpos(&getpos_x)
            valueselect_guictrl.move(getpos_x + 28)
        }

        return
    }

    ; remove the old hotkey from the map if it exists
    if toggle_hotkey_map.has(toggle_used) {
        old_hotkey := toggle_hotkey_map[toggle_used]
        hotkey_checkbox_map.delete(old_hotkey)
        hotkey old_hotkey, "Off"
    }

    ; update the maps
    toggle_hotkey_map[toggle_used] := macro_key
    hotkey_checkbox_map[macro_key] := toggle_used

    ; set up the new hotkey
    hotkey macro_key, valueselect_guictrl and amount ? (thishotkey) => action_function(thishotkey, amount, x) : action_function, new_x_value
}

roblox_angle_to_pixel(angle, sensitivity) {
    return angle / sensitivity / 50
}

flick(thishotkey, amount, guictrl) {
    if thishotkey = "lbutton" {
        mousegetpos ,,, &control_classnn

        if control_classnn = guictrl.classnn  {
            send "{" thishotkey " down}"
            keywait thishotkey
            send "{" thishotkey " up}"
            return
        }
    }

    global roblox_sensitivity

    sensitivity := roblox_sensitivity[3].value

    newamount := roblox_angle_to_pixel(amount, regexreplace(sensitivity, "[\[\]]"))

    mousemove newamount, 0, 0, "R"
    sleep fps(60) + 15
    mousemove -newamount, 0, 0, "R"
    sleep fps(60) + 15
}

wallwalk(thishotkey, amount, guictrl) {
    while getkeystate(thishotkey, "P") {
        flick(thishotkey, amount, guictrl)
    }
}

freeze(thishotkey) {
    process_suspend("RobloxPlayerBeta.exe")
    keywait thishotkey
    process_resume("RobloxPlayerBeta.exe")
}

low_fps(thishotkey, amount, guictrl) {
    while getkeystate(thishotkey, "P") {
        process_suspend("RobloxPlayerBeta.exe")
        sleep fps(amount)
        process_resume("RobloxPlayerBeta.exe")
    }
}

process_suspend(PID_or_name) {
    process := instr(PID_or_name,".") ? processexist(PID_or_name) : PID_or_name

    process_openprocess := dllcall("OpenProcess", "uint", 0x1F0FFF, "int", 0, "int", process)

    if !process_openprocess {
        return -1
    }

    dllcall("ntdll.dll\NtSuspendProcess", "int", process_openprocess)
    dllcall("CloseHandle", "int", process_openprocess)
}

process_resume(PID_or_name) {
    process := instr(PID_or_name,".") ? processexist(PID_or_name) : PID_or_name

    process_openprocess := dllcall("OpenProcess", "uint", 0x1F0FFF, "int", 0, "int", process)

    if !process_openprocess {
        return -1
    }

    dllcall("ntdll.dll\NtResumeProcess", "int", process_openprocess)
    dllcall("CloseHandle", "int", process_openprocess)
}

main.show(main_width " " main_height)

save_config(exitreason := false, exitcode := false) {
    for i, v in valued_guictrls {
        main_guictrl := v[1].classnn
        set_hotkey := v[2] ? regexreplace(strlower(v[2].text), "[\[\]]") : v[2]
        set_value := v[3] ? regexreplace(strlower(v[3].text), "[^0-9.]") : v[3]
        iniwrite set_hotkey "|" set_value, "config.ini", "main", main_guictrl
    }
}

onexit save_config

global loaded := true

loaded_time := a_tickcount - start_time

loaded_in_text.text := "loaded in: " loaded_time " ms"
loaded_in_text.getpos(&getpos_x)

global short_len_counter := 0

for _, v in strsplit(loaded_time) {
    global short_len_counter
    if v = 1 {
        short_len_counter := short_len_counter + 1
    }
}

loaded_in_text.move(getpos_x - (strlen(loaded_time) * 18) + (short_len_counter * 9),, 1000)

sleep 2500

loaded_in_text.visible := false
