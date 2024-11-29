#Requires AutoHotkey v2.0

; CLASS DEFINITIONS

class OrderedMap extends Map {
    keyarray := []

    __new(kvpairs*) {
        super.__new(kvpairs*)
        for i, key in kvpairs {
            if (mod(i, 2) != 0) {
                this.keyarray.push(kvpairs[i - 1])
            }
        }
    }

    __item[key] {
        set {
            if !this.has(key) {
                this.keyarray.push(key)
            }
            return super[key] := value
        }
    }

    __enum(*) {
        keyenum := this.keyarray.__enum(1)
        keyvalenum(&key := unset, &val := unset) {
            if keyenum(&key) {
                val := this[key]
                return true
            } else {
                return false
            }
        }
        return keyvalenum
    }
}

; VERSION INITIATION

global version := "v5"

*$!p:: ExitApp

DirCreate("Obby Macros V5")

SetWorkingDir(A_WorkingDir "\Obby Macros V5")

if FileExist("Config.ini") {
    try
        IniRead("Config.ini", "Version", "VersionNumber") = version ? true : false
    catch Error
        FileDelete("Config.ini")
} else FileAppend("", "Config.ini")


global GUIYOffsets := Map()
global GUIControls := OrderedMap()

if !FileExist("j.ico")
    Download("https://files.catbox.moe/8qyoi8.ico", "j.ico")

Icon := DllCall("LoadImage", "UInt", 0, "Str", A_WorkingDir "\j.ico", "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x10)

global MainGUI := Gui("-MaximizeBox +LastFound +OwnDialogs", "Obby Macros " version)

SendMessage(0x80, 0, Icon)
SendMessage(0x80, 1, Icon)

return

