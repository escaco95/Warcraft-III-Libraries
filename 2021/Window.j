library Window requires optional NoMoreFatal
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//  Window By 동동주
//  2021.02.16
//
//  다이얼로그 창을 다루기 쉽게 개조한 라이브러리
//  NoMoreFatal 라이브러리를 통해 핸들값 재사용률이 100%에 도달하는지를 체크했습니다.
//      dialog -> window
//      button -> windowbutton
//
//  실행 안정성을 보장받기 위해 내부 로직과 인터페이스를 분리했습니다.
//
//  
//  local window  w   = GetClickedWindow()
//  local integer id  = GetClickedWindowButton()
//  CreateWindow     ()
//  CreateWindowEx   (string title)
//  DestroyWindow    (window whichWindow)
//  WindowClear      (window whichWindow)
//  WindowDisplay    (window whichWindow, player p, boolean flag)
//  WindowSetMessage (window whichWindow, string title)
//  WindowSetCallback(window whichWindow, code actionFunc)
//  WindowAddButton  (window whichWindow, integer id, string text)
//  WindowAddButtonEx(window whichWindow, integer id, string text, integer hotkey)
//
//  local window  w   = window.clicked()
//  local integer id  = windowbutton.clicked()
//  window.create    ()
//  .destroy         ()
//  .clear           ()
//  .display         (player p, boolean flag)
//  .message        = string text
//  .callback       = code actionFunc
//  .buttons.add     (integer id, string text, integer hotkey = 0)
//
//
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
globals
    private integer STA_WINDOW
    private string  STA_TITLE
    private code    STA_CALLBACK
    private player  STA_PLAYER
    private boolean STA_FLAG
    private integer STA_ID
    private integer STA_HOTKEY
    //
    private boolean        array M_ALLOCATED
    private boolean        array M_EXISTS
    private integer        array M_HANDLE
    private dialog         array M_DIALOG
    private trigger        array M_TRIGGER
    private triggeraction  array M_ACTION
    //
    private hashtable WIN_TABLE = InitHashtable()
    // 
    private constant integer DIALOG_2_WINDOW = -101
    private constant integer WINDOW_2_DIALOG = -102
endglobals
//··············································································
private struct DATA
endstruct
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
private function STACALLWindowAddButtonEx takes DATA w, integer id, string text, integer hotkey returns nothing
    local button b
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 WindowAddButton하려 했습니다.")
        return
    endif
    // 실행
    set b = DialogAddButton(w:M_DIALOG,text,hotkey)
    call SaveInteger(WIN_TABLE,w:M_HANDLE,GetHandleId(b),id)
    // 누수 계측
    static if LIBRARY_NoMoreFatal then
        call CheckHandle(b)
    endif
    set b = null
endfunction
private function STAWindowAddButtonEx takes nothing returns nothing
    call STACALLWindowAddButtonEx(STA_WINDOW,STA_ID,STA_TITLE,STA_HOTKEY)
endfunction
private function STACALLWindowSetCallback takes DATA w, code c returns nothing
    // STA 참조 해제
    set STA_CALLBACK = null
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 SetCallback하려 했습니다.")
        return
    endif
    // 실행
    if w:M_ACTION != null then
        call TriggerRemoveAction(w:M_TRIGGER,w:M_ACTION)
        set w:M_ACTION = null
    endif
    if c != null then
        set w:M_ACTION = TriggerAddAction(w:M_TRIGGER,c)
        // 누수 계측
        static if LIBRARY_NoMoreFatal then
            call CheckHandle(w:M_ACTION)
        endif
    endif
endfunction
private function STAWindowSetCallback takes nothing returns nothing
    call STACALLWindowSetCallback(STA_WINDOW,STA_CALLBACK)
endfunction
private function STACALLWindowSetMessage takes DATA w, string msg returns nothing
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 SetMessage하려 했습니다.")
        return
    endif
    // 실행
    call DialogSetMessage(w:M_DIALOG,msg)
endfunction
private function STAWindowSetMessage takes nothing returns nothing
    call STACALLWindowSetMessage(STA_WINDOW,STA_TITLE)
endfunction
private function STACALLWindowDisplay takes DATA w, player p, boolean f returns nothing
    // STA 참조 해제
    set STA_PLAYER = null
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 Display하려 했습니다.")
        return
    endif
    // 실행
    call DialogDisplay(p,w:M_DIALOG,f)
endfunction
private function STAWindowDisplay takes nothing returns nothing
    call STACALLWindowDisplay(STA_WINDOW,STA_PLAYER,STA_FLAG)
endfunction
private function STAWindowClear takes nothing returns nothing
    local DATA w = STA_WINDOW
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 Clear하려 했습니다.")
        return
    endif
    // 실행
    call FlushChildHashtable(WIN_TABLE,w:M_HANDLE)
    call SaveInteger        (WIN_TABLE,w:M_HANDLE,DIALOG_2_WINDOW,w)
    call DialogClear(w:M_DIALOG)
endfunction
//··············································································
private function STADestroyWindow takes nothing returns nothing
    local DATA w = STA_WINDOW
    // Clear를 먼저 진행
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowClear)
    // 인자 유효성 검사
    if not w:M_EXISTS then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"경고: 존재하지 않는 윈도우 창을 Destroy하려 했습니다.")
        return
    endif
    // 실행
    if w:M_ACTION != null then
        call TriggerRemoveAction(w:M_TRIGGER,w:M_ACTION)
        set w:M_ACTION = null
    endif
    call DialogDisplay(GetLocalPlayer(),w:M_DIALOG,false)
    call w.destroy()
    set w:M_EXISTS = false
endfunction
//··············································································
private function STACreateWindowEx takes nothing returns nothing
    local string title = STA_TITLE
    local DATA w = DATA.create()
    // 실행
    if not w:M_ALLOCATED then
        set w:M_DIALOG = DialogCreate()
        set w:M_HANDLE = GetHandleId(w:M_DIALOG)
        call SaveDialogHandle(WIN_TABLE,w,WINDOW_2_DIALOG,w:M_DIALOG)
        call SaveInteger     (WIN_TABLE,w:M_HANDLE,DIALOG_2_WINDOW,w)
        set w:M_TRIGGER = CreateTrigger()
        set w:M_ACTION  = null
        call TriggerRegisterDialogEvent(w:M_TRIGGER,w:M_DIALOG)
        // 할당 성공
        set w:M_ALLOCATED = true
    endif
    set w:M_EXISTS = true
    // 누수 계측
    static if LIBRARY_NoMoreFatal then
        call CheckHandle(w:M_DIALOG)
        call CheckHandle(w:M_TRIGGER)
    endif
    // 결과 반환
    set STA_WINDOW = w
endfunction
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
struct windowbutton extends array
    static method operator clicked takes nothing returns thistype
        return LoadInteger(WIN_TABLE,GetHandleId(GetClickedDialog()),GetHandleId(GetClickedButton()))
    endmethod
endstruct
//··············································································
struct windowbuttoncollection extends array
    method add takes integer id, string text, integer hotkey returns nothing
        set STA_WINDOW = this
        set STA_ID     = id
        set STA_TITLE  = text
        set STA_HOTKEY = hotkey
        call ForForce(bj_FORCE_PLAYER[0],function STAWindowAddButtonEx)
    endmethod
endstruct
//··············································································
struct window extends array
    static method operator clicked takes nothing returns thistype
        return LoadInteger(WIN_TABLE,GetHandleId(GetClickedDialog()),DIALOG_2_WINDOW)
    endmethod
    //--------------------------------------------------------------------------
    method clear takes nothing returns nothing
        set STA_WINDOW = this
        call ForForce(bj_FORCE_PLAYER[0],function STAWindowClear)
    endmethod
    //--------------------------------------------------------------------------
    method operator buttons takes nothing returns windowbuttoncollection
        return this
    endmethod
    method operator callback= takes code c returns nothing
        set STA_WINDOW = this
        set STA_CALLBACK = c
        call ForForce(bj_FORCE_PLAYER[0],function STAWindowSetCallback)
    endmethod
    method operator message= takes string msg returns nothing
        set STA_WINDOW = this
        set STA_TITLE  = msg
        call ForForce(bj_FORCE_PLAYER[0],function STAWindowSetMessage)
    endmethod
    method display takes player p, boolean f returns nothing
        set STA_WINDOW = this
        set STA_PLAYER = p
        set STA_FLAG   = f
        call ForForce(bj_FORCE_PLAYER[0],function STAWindowDisplay)
    endmethod
    method destroy takes nothing returns nothing
        set STA_WINDOW = this
        call ForForce(bj_FORCE_PLAYER[0],function STADestroyWindow)
    endmethod
    //--------------------------------------------------------------------------
    static method create takes nothing returns thistype
        set STA_TITLE = ""
        call ForForce(bj_FORCE_PLAYER[0],function STACreateWindowEx)
        return STA_WINDOW
    endmethod
endstruct
//··············································································
function GetClickedWindow takes nothing returns window
    return LoadInteger(WIN_TABLE,GetHandleId(GetClickedDialog()),DIALOG_2_WINDOW)
endfunction
function GetClickedWindowButton takes nothing returns windowbutton
    return LoadInteger(WIN_TABLE,GetHandleId(GetClickedDialog()),GetHandleId(GetClickedButton()))
endfunction
//··············································································
function WindowAddButton takes window w, integer id, string text returns nothing
    set STA_WINDOW = w
    set STA_ID     = id
    set STA_TITLE  = text
    set STA_HOTKEY = 0
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowAddButtonEx)
endfunction
function WindowAddButtonEx takes window w, integer id, string text, integer hotkey returns nothing
    set STA_WINDOW = w
    set STA_ID     = id
    set STA_TITLE  = text
    set STA_HOTKEY = hotkey
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowAddButtonEx)
endfunction
function WindowSetCallback takes window w, code c returns nothing
    set STA_WINDOW   = w
    set STA_CALLBACK = c
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowSetCallback)
endfunction
function WindowSetMessage takes window w, string msg returns nothing
    set STA_WINDOW = w
    set STA_TITLE  = msg
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowSetMessage)
endfunction
function WindowDisplay takes window w, player p, boolean f returns nothing
    set STA_WINDOW = w
    set STA_PLAYER = p
    set STA_FLAG   = f
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowDisplay)
endfunction
function WindowClear takes window w returns nothing
    set STA_WINDOW = w
    call ForForce(bj_FORCE_PLAYER[0],function STAWindowClear)
endfunction
//··············································································
function DestroyWindow takes window w returns nothing
    set STA_WINDOW = w
    call ForForce(bj_FORCE_PLAYER[0],function STADestroyWindow)
endfunction
//··············································································
function CreateWindow takes nothing returns window
    set STA_TITLE = ""
    call ForForce(bj_FORCE_PLAYER[0],function STACreateWindowEx)
    return STA_WINDOW
endfunction
function CreateWindowEx takes string title returns window
    set STA_TITLE = title
    call ForForce(bj_FORCE_PLAYER[0],function STACreateWindowEx)
    return STA_WINDOW
endfunction
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
endlibrary
