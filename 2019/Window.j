// Copyright (c) 2019 escaco95
// Distributed under the BSD License, Version 1.0.
// See original source at GitHub https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/Window.j
// TESH custom intellisense https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/Window.Intellisense.txt
library Window
    globals
        private hashtable H2ID = InitHashtable()
    endglobals
    private struct windowbuttonindexer
        button button
        thistype next
    endstruct
    struct windowbutton extends array
        static method getclicked takes nothing returns thistype
            return LoadInteger(H2ID,0,GetHandleId(GetClickedButton()))
        endmethod
    endstruct
    struct window
        private trigger trigger
        private triggeraction triggeraction
        private windowbuttonindexer head
        dialog super
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set .super = DialogCreate()
            set .trigger = CreateTrigger()
            set .triggeraction = null
            set .head = 0
            call SaveInteger(H2ID,0,GetHandleId(.super),this)
            call TriggerRegisterDialogEvent(.trigger,.super)
            return this
        endmethod
        static method getclicked takes nothing returns thistype
            return LoadInteger(H2ID,0,GetHandleId(GetClickedDialog()))
        endmethod
        /*=======================================================================*/
        method operator callback= takes code c returns nothing
            if .triggeraction != null then
                call TriggerRemoveAction(.trigger,.triggeraction)
            endif
            set .triggeraction = TriggerAddAction(.trigger,c)
        endmethod
        method operator message= takes string s returns nothing
            call DialogSetMessage(.super,s)
        endmethod
        method addbutton takes integer id, string text, integer hotkey returns windowbutton
            local windowbuttonindexer idx = windowbuttonindexer.create()
            set idx.button = DialogAddButton(.super,text,hotkey)
            set idx.next = .head
            call SaveInteger(H2ID,0,GetHandleId(idx.button),id)
            set .head = idx
            return idx
        endmethod
        method show takes player p, boolean f returns nothing
            call DialogDisplay(p,.super,f)
        endmethod
        method clear takes nothing returns nothing
            local windowbuttonindexer idx = .head
            local windowbuttonindexer cdx
            loop
                exitwhen idx == 0
                set cdx = idx
                set idx = idx.next
                call RemoveSavedInteger(H2ID,0,GetHandleId(cdx.button))
                set cdx.button = null
            endloop
            set .head = 0
            call DialogClear(.super)
        endmethod
        /*=======================================================================*/
        method destroy takes nothing returns nothing
            call .clear()
            call DialogDestroy(.super)
            call RemoveSavedInteger(H2ID,0,GetHandleId(.super))
            set .super = null
            call .deallocate()
        endmethod
    endstruct
    /*=======================================================================*/
    function TriggerRegisterWindowButtonEvent takes trigger t, windowbuttonindexer idx returns event
        return TriggerRegisterDialogButtonEvent(t,idx.button)
    endfunction
    function TriggerRegisterWindowEvent takes trigger t, window w returns event
        return TriggerRegisterDialogEvent(t,w.super)
    endfunction
    function GetClickedWindow takes nothing returns window
        return LoadInteger(H2ID,0,GetHandleId(GetClickedDialog()))
    endfunction
    function GetClickedWindowButton takes nothing returns windowbutton
        return LoadInteger(H2ID,0,GetHandleId(GetClickedButton()))
    endfunction
    /*=======================================================================*/
    function DestroyWindow takes window w returns nothing
        call w.destroy()
    endfunction
    /*=======================================================================*/
    function WindowAddButton takes window w, integer id, string text returns windowbutton
        return w.addbutton(id,text,0)
    endfunction
    function WindowAddButtonEx takes window w, integer id, string text, integer hotkey returns windowbutton
        return w.addbutton(id,text,hotkey)
    endfunction
    function WindowSetCallback takes window w, code c returns nothing
        set w.callback = c
    endfunction
    function WindowSetMessage takes window w, string msg returns nothing
        call DialogSetMessage(w.super,msg)
    endfunction
    function WindowDisplay takes window w, player p, boolean f returns nothing
        call DialogDisplay(p,w.super,f)
    endfunction
    function WindowClear takes window w returns nothing
        call w.clear()
    endfunction
    /*=======================================================================*/
    function CreateWindow takes nothing returns window
        return window.create()
    endfunction
    function CreateWindowEx takes string title returns window
        local window wnd = window.create()
        call DialogSetMessage(wnd.super,title)
        return wnd
    endfunction
endlibrary
