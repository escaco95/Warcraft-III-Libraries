/*
  보다 '스크립트'환경에서 대화 상자(다이얼로그)를 사용하기 편하도록 제작된 라이브러리입니다.
  
  function Button1Pressed takes nothing returns nothing
    local window pWin = window.getClicked() //선택된 다이얼로그를 받아옵니다.
    local windowbutton pBtn = windowbutton.getClicked() //클릭된 버튼 번호를 받아옵니다.
    call pWin.destroy() //선택된 다이얼로그를 파괴합니다.
  endfunction
  
  local window myWindow = window.create( "다이얼로그 제목" ) //새 다이얼로그를 만듭니다.
  call myWindow.addButton( 0, "버튼 1", 0, function Button1Pressed ) //0번 버튼 : "버튼 1"이라는 글자를 가진 버튼을 생성합니다.
  //이 버튼을 누르면 Button1Pressed 함수가 실행됩니다.
  call myWindow.display( Player(0), true ) //이 다이얼로그를 1플레이어에게 보여줍니다.
  
  기타 기능
  call myWindow.clear() //모든 버튼을 제거합니다.
  set myWindow.title = "새 제목" //다이얼로그의 제목을 변경합니다.
  
  누수 체크용 기능
  local integer counted = window.count //현재 맵 상에 생성된 모든 window갯수를 셉니다.
*/

library Window
    globals
        private window Ev = 0
        private windowbutton Eb = 0
    endglobals
    struct windowbutton extends array
        static method getClicked takes nothing returns integer
            return Eb
        endmethod
    endstruct
    struct window
        private static integer MAX = 0
        private static hashtable H = InitHashtable(  )
        private static hashtable HB = InitHashtable(  )
        private trigger T
        private dialog D
        private integer C
        private button array B[20]
        private integer array BI[20]
        private trigger array BT[20]
        private triggeraction array BTA[20]
        static method operator count takes nothing returns integer
            return MAX
        endmethod
        static method getClicked takes nothing returns thistype
            return Ev
        endmethod
        static method create takes string title returns thistype
            local thistype this = thistype.allocate(  )
            set MAX = MAX + 1
            if .D == null then
                set .D = DialogCreate(  )
                call SaveInteger( H, 0, GetHandleId(.D), this )
            endif
            call DialogSetMessage( .D, title )
            set .T = CreateTrigger(  )
            call TriggerAddCondition( .T, Filter( function thistype.onPress ) )
            call TriggerRegisterDialogEvent( .T, .D )
            set .C = 0
            return this
        endmethod
        method operator title= takes string title returns nothing
            call DialogSetMessage( .D, title )
        endmethod
        method display takes player p, boolean flag returns nothing
            call DialogDisplay( p, .D, flag )
        endmethod
        method addButton takes integer id, string name, integer hotkey, code c returns nothing
            if .C == 20 then
                return
            endif
            set .B[.C] =DialogAddButton( .D, name, hotkey )
            set .BI[.C] = id
            set .BT[.C] = CreateTrigger(  )
            set .BTA[.C] = TriggerAddAction( .BT[.C], c )
            call SaveInteger( HB, 0, GetHandleId( .B[.C] ), .C )
            set .C = .C + 1
        endmethod
        method clear takes nothing returns nothing
            local integer i = 0
            loop
                exitwhen i == .C
                call SaveInteger( HB, 0, GetHandleId( .B[i] ), 0 )
                set .B[i] = null
                set .BI[i] = 0
                call TriggerRemoveAction( .BT[i], .BTA[i] )
                set .BTA[i] = null
                call DestroyTrigger( .BT[i] )
                set .BT[i] = null
                set i = i + 1
            endloop
            set .C = 0
            call DialogClear( .D )
        endmethod
        method destroy takes nothing returns nothing
            set MAX = MAX - 1
            call .clear(  )
            call thistype.deallocate( this )
        endmethod
        
        private static method onPress takes nothing returns boolean
            local thistype prevW = Ev
            local integer prevB = Eb
            local thistype this = LoadInteger( H, 0, GetHandleId(GetClickedDialog()) )
            local integer btn = LoadInteger( HB, 0, GetHandleId(GetClickedButton()) )
            set Ev = this
            set Eb = .BI[btn]
            call TriggerExecute( .BT[btn] )
            set Eb = prevB
            set Ev = prevW
            return true
        endmethod
    endstruct
endlibrary

