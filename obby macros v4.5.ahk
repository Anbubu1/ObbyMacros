#requires AutoHotkey v2.0

global VERSION := "v4.4"

$*!p:: {
    exitapp
}

dircreate "Obby Macros V4"

setworkingdir a_workingdir "\Obby Macros V4"
    if fileexist("config.ini") {
        try {
            iniread("config.ini", "version", "version_number") = VERSION ? true : false
        } catch error {
            filedelete "config.ini"
        }
    }

    if !fileexist("config.ini") {
        fileappend "", "config.ini"
    }

; initial declarations
global y_amts_used_map_guis := map()
global valued_guictrls := map()

if !fileexist("j.ico")
    download "https://files.catbox.moe/8qyoi8.ico", "j.ico"

icon := dllcall("LoadImage", "uint", 0, "str", a_workingdir "\j.ico", "uint", 1, "int", 0, "int", 0, "uint", 0x10)

global main := gui("-maximizebox +lastfound +owndialogs", "Obby Macros " VERSION)

    sendmessage 0x80, 0, icon
    sendmessage 0x80, 1, icon

    sendmode "input"

    main.raw_width  := 600
    main.width      := "w" main.raw_width
    main.raw_height := 450
    main.height     := "h" main.raw_height

    main.backcolor := "19222D"
    
    DWMWA_CAPTION_COLOR := 35
    SetDwmAttribute(main.hwnd, DWMWA_CAPTION_COLOR, 0x2D2219)

    main.setfont("q2", "segoe ui")
    main.setfont("cwhite")
    
    main.onevent("close", main_close)

    main.guictrl_x_offset := 10
    main.guictrl_y_offset := 5
    main.guictrl_y_split  := 6
    
    main.columns          := 2
    main.column_positions := set_columns(main)

    shift_column(main, 2, 25)

    main.setfont("s12")
        create_checkbox(main, "Flick Macro",               flick,          1, ["flicks your mouse, mainly used for wallhops", "s8", "s12", true],, true, [90, "°", -360, 360])
        create_checkbox(main, "Second Flick Macro",        flick,          1, ["in-case you needed another value or hotkey",  "s8", "s12", true],, true, [45, "°", -360, 360])
        create_checkbox(main, "Third Flick Macro",         flick,          1, ["in-case you needed ANOTHER value or hotkey!", "s8", "s12", true],, true, [45, "°", -360, 360])
        create_checkbox(main, "Single Flick Macro",        single_flick,   1, ["does a single flick", "s8", "s12", true],,                         true, [90, "°", -360, 360])
        create_checkbox(main, "Second Single Flick Macro", single_flick,   1, ["what", "s8", "s12", true],,                                        true, [-90, "°", -360, 360])
        create_checkbox(main, "Spam Flick Macro",          wallwalk,       1, ["mainly for wallwalks", "s8", "s12", true],,                        true, [15, "°", -360, 360])
        create_checkbox(main, "Second Spam Flick Macro",   wallwalk,       1, ["ermm what", "s8", "s12", true],,                                   true, [-15, "°", -360, 360])
        create_checkbox(main, "Chat Message Macro",        chat_msg,       1, ["pastes a message in chat", "s8", "s12", true],,                    true, ["/e dance2", "", -360, 360, true])
        create_checkbox(main, "Second Chat Message Macro", chat_msg,       1, ["if you wanna hotkey another chat message", "s8", "s12", true],,                    true, ["/e laugh", "", -360, 360, true])
        create_checkbox(main, "Freeze Macro",              freeze,         1, ["freezes roblox", "s8", "s12", true],,                              true)
        create_checkbox(main, "Low FPS Macro",             low_fps,        1, ["spam freezes roblox", "s8", "s12", true],,                         true, [30, " FPS", 0.5, 240])
        ;create_checkbox(main, "Switch FPS Macro (no work)",          switch_fps,     1, ["switches fps on roblox", "s8", "s12", true],,                      true, [30, " FPS", 0.5, 240,, true])
        create_checkbox(main, "Always On Top",             always_on_top,  2, ["makes the gui always on top", "s8", "s12", true])
        create_checkbox(main, "Transparent GUI",           transparency,   2, ["makes the gui transparent [0-255] (0 is invisible)", "s8", "s12", true],,,[125, "", 0, 255])
        global flick_sensitivity := create_text(main, "Flick Sensitivity", 2, ["Set your flick sensitivity here.", "s8", "s12"], [1, "x", 0.01, 100])
        create_text(main, "Credits",           2, ["
                                                   (
                                                   Creator {
                                                       Discord - @anbubu (463321359741616149)
                                                       GitHub  - @Anbubu1
                                                       YouTube - @anbubu
                                                   }
                                                   )", "s8", "s12",, "consolas", 8])
        create_text(main, "Info",              2, ["
                                                   (
                                                    Macros that use flicks requires manually setting
                                                    the flick sens! Don't worry, it will be saved.
                                                    ALT + P to force exit script.
                                                   )", "s8", "s12"])
        create_text(main, "Values and Hotkeys",2, ["
                                                   (
                                                    BACKSPACE key to reset.
                                                    ENTER key to set.
                                                   )", "s8", "s12"])
        create_text(main, "Disclaimer",2,         ["
                                                   (
                                                   Make sure you're allowed to use this macro, cuz
                                                   it basically gives you an advantage 💀
                                                   )", "s8", "s12",,, 10])

main.show(main.width " " main.height)

onexit save_config

return

set_columns(gui) {
    try {
        columns := gui.columns
    } catch error {
        msgbox "gui.columns non-existent"
        exitapp
    }

    column_array := []
    column_array.length := columns

    for i, _ in column_array {
        column_array[i] := [((gui.raw_width / columns) * (i - 1)) + 10, 10]
    }

    return column_array
}

shift_column(gui, column, x_offset) {
    for i, v in gui.column_positions {
        if i = 1
            continue

        if v = gui.column_positions[column] {
            v[1] += x_offset
            continue
        }

        v[1] += (x_offset / 2)
    }
}

create_checkbox(
    gui,
    text,
    onevent_function,
    column        := false,
    caption_array := false,
    is_enabled    := false,
    var_hotkey    := false,
    valueselect   := false,
    y_offset      := false
) {
    global y_amts_used_map_guis
    global valued_guictrls

    if !y_amts_used_map_guis.has(gui) {
        y_amts_used_map_guis[gui] := []
        y_amts_used_map_guis[gui].length := gui.columns
    }

    if !y_amts_used_map_guis[gui].has(column)
        y_amts_used_map_guis[gui][column] := 0

    if column {
        column_x_offset := gui.column_positions[column][1]
        column_x_offset_2nd := gui.column_positions.length = column ? gui.raw_width + 10 : gui.column_positions[column + 1][1]
    }

    checkbox := gui.addcheckbox("x" column_x_offset " y" gui.guictrl_y_offset + y_offset, text)
    checkbox.value := is_enabled
    checkbox.setfont(is_enabled ? "cc0ffc0" : "cwhite")

    checkbox.getpos(, &checkbox_y,, &checkbox_h)
    checkbox.move(, checkbox_y + y_amts_used_map_guis[gui][column] + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0))

    old_y_amts_used := y_amts_used_map_guis[gui][column]

    y_amts_used_map_guis[gui][column] += checkbox_h + y_offset + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0)

    if isobject(valueselect) {
        valueselect_value := valueselect[1]
        valueselect_unit  := valueselect[2]
        valueselect_min   := valueselect[3]
        valueselect_max   := valueselect[4]
        valueselect_text  := valueselect.has(5) ? valueselect[5] : false
        valueselect_dropdown := valueselect.has(6) ? valueselect[6] : false

        valueselect_guictrl := gui.addtext("+backgroundtrans +right", "[" valueselect_value  valueselect_unit "]")

        valueselect_guictrl.setfont("cd0d0d0 s10 q2", "consolas")

        checkbox.getpos(, &guictrl_y)
        valueselect_guictrl.move(column_x_offset_2nd - 20, guictrl_y + (var_hotkey ? 18 : 2.5), valueselect_text ? 100 : 80, 16)

        valueselect_guictrl.getpos(&guictrl_x,, &guictrl_w)
        valueselect_guictrl.move(guictrl_x - guictrl_w)

        valueselect_guictrl.array := valueselect

        binded_valueselect_change := valueselect_change.bind(,, checkbox,, valueselect_text, valueselect_dropdown)
        valueselect_guictrl.onevent("click", binded_valueselect_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := cfg_values[2]
                if cfg_value = "" {
                    cfg_value := 0
                }
                old_length := strlen(valueselect_guictrl.value)
                valueselect_guictrl.value := "[" cfg_value valueselect_unit "]"
                new_length := strlen(valueselect_guictrl.value)
            } catch error {
    
            }
        }
    } else {
        valueselect_guictrl := false
    }

    if var_hotkey {
        var_hotkey := gui.addtext("+backgroundtrans +right", "[NONE]")
        var_hotkey.setfont("cd0d0d0 s10 q2", "consolas")
        
        checkbox.getpos(, &guictrl_y)
        var_hotkey.move(column_x_offset_2nd - 20, guictrl_y - (isobject(valueselect) ? 0 : -2), 65, 16)

        var_hotkey.getpos(&guictrl_x,, &guictrl_w)
        var_hotkey.move(guictrl_x - guictrl_w)

        binded_hotkey_change := hotkey_change.bind(,, checkbox)

        var_hotkey.onevent("click", binded_hotkey_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := strupper(cfg_values[1])
                old_length := strlen(var_hotkey.value)
                var_hotkey.value := "[" cfg_value "]"
            } catch error {
    
            }
        }
    }

    if isobject(caption_array) {
        caption_string     := caption_array[1]
        caption_text_size  := caption_array[2]
        checkbox_text_size := caption_array[3]

        if caption_array.has(4) {
            if caption_array[4] {
                offset_denied := true
            }
        }

        if caption_array.has(5) {
            if caption_array[5] {
                caption_font := caption_array[5]
            } else {
                caption_font := ""
            }
        } else {
            caption_font := ""
        }

        if caption_array.has(6) {
            if caption_array[6] {
                caption_w_offset := caption_array[6]
            } else {
                caption_w_offset := 0
            }
        } else {
            caption_w_offset := 0
        }

        gui.setfont(caption_text_size)

        checkbox.getpos(&guictrl_x, &guictrl_y,, &guictrl_h)

        caption := gui.addtext("+backgroundtrans", caption_string)

        caption.move(guictrl_x, guictrl_y + guictrl_h + (isobject(valueselect) and var_hotkey and (!offset_denied) ? 5 : 0))

        caption.setfont(, caption_font)
        caption.getpos(,,, &guictrl_h)

        y_amts_used_map_guis[gui][column] += guictrl_h + (isobject(valueselect) and var_hotkey and (!offset_denied) ? 5 : 0)

        column_ahead := column = gui.column_positions.length ? gui.raw_width : gui.column_positions[column + 1][1]

        caption.move(,, column_ahead - gui.column_positions[column][1] - 20 + caption_w_offset)
        
        gui.setfont(checkbox_text_size)
    }

    if is_enabled and !var_hotkey
        onevent_function(checkbox, "startup enabled")

    guictrl_port_bind := guictrl_port.bind(,, onevent_function, var_hotkey, valueselect_guictrl)

    checkbox.onevent("click", guictrl_port_bind)

    if is_enabled
        guictrl_port_bind

    checkbox.boundfunc := guictrl_port_bind
    
    if !var_hotkey and !valueselect {
        checkbox.onevent("click", onevent_function)
    }

    if !var_hotkey and isobject(valueselect) {
        binded_onevent_function := onevent_function.bind(,, valueselect_guictrl)

        checkbox.onevent("click", binded_onevent_function)
    }

    return_info := [checkbox, onevent_function, column, var_hotkey, valueselect_guictrl]

    valued_guictrls[checkbox] := return_info

    return return_info
}

create_text(
    gui,
    text,
    column        := false,
    caption_array := false,
    valueselect   := false,
    y_offset      := false,
    colorless     := false
) {
    global y_amts_used_map_guis
    global valued_guictrls

    if !y_amts_used_map_guis.has(gui) {
        y_amts_used_map_guis[gui] := []
        y_amts_used_map_guis[gui].length := gui.columns
    }

    if !y_amts_used_map_guis[gui].has(column)
        y_amts_used_map_guis[gui][column] := 0

    if column {
        column_x_offset := gui.column_positions[column][1]
        column_x_offset_2nd := gui.column_positions.length = column ? gui.raw_width + 10 : gui.column_positions[column + 1][1]
    }

    checkbox := gui.addtext("x" column_x_offset " y" gui.guictrl_y_offset + y_offset, text)
    checkbox.setfont(colorless ? "cwhite" : "cc0c0ff")

    checkbox.getpos(, &checkbox_y,, &checkbox_h)
    checkbox.move(, checkbox_y + y_amts_used_map_guis[gui][column] + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0))

    y_amts_used_map_guis[gui][column] += checkbox_h + y_offset + (y_amts_used_map_guis[gui][column] != 0 ? gui.guictrl_y_split : 0)

    if isobject(valueselect) {
        valueselect_value := valueselect[1]
        valueselect_unit  := valueselect[2]
        valueselect_min   := valueselect[3]
        valueselect_max   := valueselect[4]

        valueselect_guictrl := gui.addtext("+backgroundtrans +right", "[" valueselect_value  valueselect_unit "]")

        valueselect_guictrl.setfont("cd0d0d0 s10 q2", "consolas")

        checkbox.getpos(, &guictrl_y)
        valueselect_guictrl.move(column_x_offset_2nd - 20, guictrl_y + 2.75, 65, 16)

        valueselect_guictrl.getpos(&guictrl_x,, &guictrl_w)
        valueselect_guictrl.move(guictrl_x - guictrl_w)

        valueselect_guictrl.array := valueselect

        binded_valueselect_change := valueselect_change.bind(,, checkbox,, true)
        valueselect_guictrl.onevent("click", binded_valueselect_change)

        if fileexist("config.ini") and filegetsize("config.ini") > 0 {
            try {
                cfg_values := strsplit(iniread("config.ini", "main", checkbox.text), "|")
                cfg_value := cfg_values[2]
                if cfg_value = "" {
                    cfg_value := 0
                }
                old_length := strlen(valueselect_guictrl.value)
                valueselect_guictrl.value := "[" cfg_value valueselect_unit "]"
                new_length := strlen(valueselect_guictrl.value)
            } catch error {
    
            }
        }
    } else {
        valueselect_guictrl := false
    }

    if isobject(caption_array) {
        caption_string     := caption_array[1]
        caption_text_size  := caption_array[2]
        checkbox_text_size := caption_array[3]

        if caption_array.has(4) {
            if caption_array[4] {
                offset_denied := true
            }
        }

        if caption_array.has(5) {
            if caption_array[5] {
                caption_font := caption_array[5]
            } else {
                caption_font := ""
            }
        } else {
            caption_font := ""
        }

        if caption_array.has(6) {
            if caption_array[6] {
                caption_w_offset := caption_array[6]
            } else {
                caption_w_offset := 0
            }
        } else {
            caption_w_offset := 0
        }

        gui.setfont(caption_text_size)

        checkbox.getpos(&guictrl_x, &guictrl_y, &guictrl_w, &guictrl_h)

        caption := gui.addtext("+backgroundtrans", caption_string)

        caption.move(guictrl_x, guictrl_y + guictrl_h)

        caption.setfont(, caption_font)
        caption.getpos(,,, &guictrl_h)

        y_amts_used_map_guis[gui][column] += guictrl_h

        column_ahead := column = gui.column_positions.length ? gui.raw_width : gui.column_positions[column + 1][1]

        caption.move(,, column_ahead - gui.column_positions[column][1] - 20 + caption_w_offset)
        
        gui.setfont(checkbox_text_size)
    }

    return_info := [checkbox, false, column, false, valueselect_guictrl]

    valued_guictrls[checkbox] := return_info

    return return_info
}

; i like making up random words
guictrl_port(checkbox,
             href,
             onevent_function,
             var_hotkey := false,
             valueselect := false
) {
    static hotkeys_for_functions := map()

    checkbox.setfont(checkbox.value ? "cc0ffc0" : "cwhite")

    if var_hotkey {
        hotkey_key := "*$" regexreplace(var_hotkey.value, "[\[\]]")

        if strlower(regexreplace(hotkey_key, "[\*\$]")) = ("none" or "...") {
            return
        }

        if hotkeys_for_functions.has(hotkey_key) {
            if hotkeys_for_functions[hotkey_key] != onevent_function {
                msgbox "please pick another hotkey!`nthis one is being used already",, "T2"

                checkbox.setfont("cwhite")
                checkbox.value := 0

                return
            }
        }

        if valueselect
            onevent_function_bind := onevent_function.bind(, valueselect)
        
        hotkey hotkey_key, valueselect ? onevent_function_bind : onevent_function, checkbox.value ? "on" : "off"

        if checkbox.value {
            hotkeys_for_functions[hotkey_key] := onevent_function
        } else {
            if hotkeys_for_functions.has(hotkey_key)
                hotkeys_for_functions.delete(hotkey_key)
        }
    }
}

test(checkbox, href := false) {
    if href = "startup enabled" {
        return
    }

    msgbox "test"
}

flick(thishotkey, valueselect) {
    unfiltered_flick_value      := valueselect.value
    flick_val_unit              := valueselect.array[2]
    unfiltered_flick_multiplier := flick_sensitivity[5].value
    flick_mult_unit             := flick_sensitivity[5].array[2]


    flick_value := regexreplace(unfiltered_flick_value, "[\[\]" flick_val_unit "]")
    flick_multiplier := regexreplace(unfiltered_flick_multiplier, "[\[\]" flick_mult_unit "]")

    new_mousemove(flick_value * flick_multiplier)
    sleep (1000 / 60) + 15
    new_mousemove(-flick_value * flick_multiplier)
}

single_flick(thishotkey, valueselect) {
    unfiltered_flick_value      := valueselect.value
    flick_val_unit              := valueselect.array[2]
    unfiltered_flick_multiplier := flick_sensitivity[5].value
    flick_mult_unit             := flick_sensitivity[5].array[2]


    flick_value := regexreplace(unfiltered_flick_value, "[\[\]" flick_val_unit "]")
    flick_multiplier := regexreplace(unfiltered_flick_multiplier, "[\[\]" flick_mult_unit "]")

    new_mousemove(flick_value * flick_multiplier)
}

wallwalk(thishotkey, valueselect) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    while getkeystate(fixed_hotkey, "P") {
        flick(thishotkey, valueselect)
    }
}

chat_msg(thishotkey, valueselect) {
    unfiltered_chat_msg_value := valueselect.value
    unit                      := valueselect.array[2]

    chat_message := regexreplace(unfiltered_chat_msg_value, "[\[\]" unit "]")

    old_clipboard := a_clipboard

    a_clipboard := chat_message

    send "/{backspace}"
    sleep 25
    send "{ctrl down}{v down}"
    sleep 50
    send "{ctrl up}{v up}"
    sleep 25
    send "{enter}"

    a_clipboard := old_clipboard
}

new_mousemove(x := false, y := false) {
    dllcall("mouse_event", "UInt", 0x0001, "Int", x ? x : 0, "Int", y ? y : 0, "UInt", 0, "UInt", 0)
}

freeze(thishotkey) {
    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    process_suspend("RobloxPlayerBeta.exe")
    keywait fixed_hotkey
    process_resume("RobloxPlayerBeta.exe")
}

low_fps(thishotkey, valueselect) {
    unfiltered_amount := valueselect.value
    unit              := valueselect.array[2]

    amount := regexreplace(unfiltered_amount, "[\[\]" unit "]")

    fixed_hotkey := regexreplace(thishotkey, "\*\$")

    while getkeystate(fixed_hotkey, "P") {
        process_suspend("RobloxPlayerBeta.exe")
        sleep 1000 / amount
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

switch_fps(thishotkey, valueselect) {

}

always_on_top(checkbox, href) {
    winsetalwaysontop checkbox.value, "Obby Macros v4"
}

transparency(checkbox, href, valueselect) {
    unfiltered_transparency := valueselect.value
    unit                    := valueselect.array[2]

    transparency_val := regexreplace(unfiltered_transparency, "[\[\]" unit "]")

    winsettransparent checkbox.value ? transparency_val : 255
}

hotkey_change(text, href, checkbox, valueselect := false) {

    inputhook_stop_mousekeys := false

    static exitkeys := "{backspace}{delete}{escape}"

    static mousekeys := [
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
        "rshift",
        "lcontrol",
        "rcontrol"
    ]

    static inviskeys := [
        "09 TAB",
        "0d ENTER",
        "20 SPACE"
    ]

    text.value := "[...]"

    text.setfont("cyellow")

    checkkeys() {
        for i, v in inviskeys {
            inviskey := strsplit(v, " ")
            if getkeyvk(ih.input) = hextodec(inviskey[1]) {
                global checkkeys_value := inviskey[2]
                return true
            }
        }
        return false
    }

    global ih := inputhook("L1 M B", exitkeys)

    ih.start()

    for _, v in mousekeys {
        hotkey v, inputhookstop, "On"
    }
    
    inputhookstop(thishotkey) {
        ih.stop()
        text.text := "[" strupper(thishotkey) "]"

        for _, v in mousekeys {
            hotkey v, inputhookstop, "Off"
        }

        inputhook_stop_mousekeys := true

        if !checkbox.value {
            return
        }

        checkbox.boundfunc(checkbox)
    }

    ih.wait()

    text.setfont("cd0d0d0")

    if inputhook_stop_mousekeys {
        return
    }

    if strlower(ih.endreason) = "endkey" {
        text.text := "[NONE]"
    } else if checkkeys() {
        text.text := "[" checkkeys_value "]"
    } else {
        text.text := "[" strupper(ih.input) "]"
    }

    for _, v in mousekeys {
        hotkey v, inputhookstop, "Off"
    }

    if !checkbox.value {
        return
    }

    checkbox.boundfunc(checkbox)
}

valueselect_change(text, href, checkbox, valueselect := false, is_text := false, is_dropdown := false) {
    unit := text.array[2]

    oldtext_value := text.value

    text.value := "[..." unit "]"

    text.setfont("cyellow")

    if is_dropdown
        msgbox "yaya"

    checkkeys(inputhook, vk, sc) {
        if (inputhook.input = "." or regexmatch(inputhook.input, "^(?=.*?\..*?\.).*$")) and !is_text {
            inputhook.stop()
            return
        }

        if getkeyname("vk" format("{:X}", vk)) = "Space" {
            text.value := regexreplace(substr(text.value, 1, strlen(text.value) - strlen(unit) - 1) " " unit "]", "(\.\.\.)")
            return
        }

        text.value := regexreplace(substr(text.value, 1, strlen(text.value) - strlen(unit) - 1) getkeyname("vk" format("{:X}", vk)) unit "]", "(\.\.\.)")
    }

    global ih := inputhook((is_text ? "L12" : "L5") " M B", "{enter}")

    ih.keyopt(is_text ? "{all}" : "0123456789.", "+N")

    ih.onkeydown := checkkeys

    ih.start()

    ih.wait()

    text.setfont("cd0d0d0")

    if strlower(ih.endreason) = "stopped" {
        text.value := oldtext_value
        return
    }

    if strlower(ih.endreason) = "max" and text.value = "[..." unit "]" {
        text.value := oldtext_value
        return
    }

    if is_text
        return

    if text.array.has(3)
        text.value := "[" clamp(regexreplace(text.value, "[\[\]" unit "]"), text.array[3]) unit "]"

    if text.array.has(4)
        text.value := "[" clamp(regexreplace(text.value, "[\[\]" unit "]"),, text.array[4]) unit "]"

    text.value := "[" remove_trailing_zeroes(regexreplace(text.value, "[\[\]" unit "]")) unit "]"

    checkbox.boundfunc(checkbox)
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

remove_trailing_zeroes(num) {
    regexmatch(num, "(-?([1-9][0-9]*|0(?=\.))(\.[0-9]+(?=[1-9])[1-9])?)", &return_num)

    return return_num[]
}

clamp(num, min := false, max := false) {
    if num < min and min
        return min
    if num > max and max
        return max
    return num
}

setdwmattribute(hwnd, attribute, value) {
    buf := Buffer(4, 0)
    numput("Int", value, buf)
    dllcall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", attribute, "Ptr", buf, "Int", 4)
}

main_close(thisGui) {
    exitapp
}

save_config(exitreason := false, exitcode := false) {
    global VERSION
    iniwrite VERSION, "config.ini", "version", "version_number"
    for i, v in valued_guictrls {
        main_guictrl := v[1].text
        try {
            if v[1].value = (0 or 1) {
                guictrl_enabled := v[1].value
            } else {
                guictrl_enabled := 0
            }
        } catch error {
            guictrl_enabled := 0
        }
        set_hotkey := v[4] ? regexreplace(strlower(v[4].text), "[\[\]]") : v[4]
        set_value := v[5] ? regexreplace(regexreplace(v[5].value, "[\[\]]"), v[5].array[2]) : v[5]
        iniwrite set_hotkey "|" set_value "|" guictrl_enabled, "config.ini", "main", main_guictrl
    }
}
