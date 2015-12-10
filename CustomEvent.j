/*
  트리거액션 = eventCustom.addAction( 어떤_이벤트_?, 함수 )
  // 사용자 정의 이벤트에 액션을 추가하는 함수입니다.
  // 어떤_이벤트_? 에는 원하는 이벤트 번호를 삽입할 수 있습니다. 1~8191 사이로 원하시는 번호를 작성하시면 됩니다.
  
  eventCustom.removeAction( 트리거액션 )
  // 사용자 정의 이벤트에 추가했던 액션을 제거합니다.
  // 사용자 정의 이벤트 트리거 액션이 아니라 일반 트리거 액션을 집어넣으면 오류가 뜹니다.
  
  eventCustom.evaluate( 어떤_이벤트_?, 트작플, 트작유, 트작템, 트작ID )
  // 특정 번호의 사용자 정의 이벤트를 격발(=실행)시킵니다.
  // 이 이벤트 번호에 등록되어 있던 모든 액션이 실행됩니다.
  
  eventCustom.getTriggerPlayer()
  // 사용자 정의 이벤트의 트작플을 받아옵니다
  eventCustom.getTriggerUnit()
  // 사용자 정의 이벤트의 트작유를 받아옵니다
  eventCustom.getTriggerItem()
  // 사용자 정의 이벤트의 트작템을 받아옵니다
  eventCustom.getTriggerId()
  // 사용자 정의 이벤트의 트작ID를 받아옵니다
*/

library CustomEvent
    globals
        private hashtable TH = InitHashtable(  )
        private hashtable H = InitHashtable(  )
        private trigger array T
        private integer CUSTOM_EVENT = 0
        private player CUSTOM_PLAYER = null
        private unit CUSTOM_UNIT = null
        private item CUSTOM_ITEM = null
        private integer CUSTOM_ID = 0
    endglobals
    struct eventCustom extends array
        static method getTriggerId takes nothing returns integer
            return CUSTOM_ID
        endmethod
        static method getTriggerPlayer takes nothing returns player
            return CUSTOM_PLAYER
        endmethod
        static method getTriggerUnit takes nothing returns unit
            return CUSTOM_UNIT
        endmethod
        static method getTriggerItem takes nothing returns item
            return CUSTOM_ITEM
        endmethod
        private static method RegisterAction takes triggeraction ta, integer id returns triggeraction
            call SaveInteger( H, 0, GetHandleId( ta ), id )
            return ta
        endmethod
        static method removeAction takes triggeraction ta returns nothing
            local integer ev = LoadInteger( H, 0, GetHandleId( ta ) )
            if ev == 0 then
                call DisplayTextToPlayer( GetLocalPlayer(), 0.00, 0.00, "경고 : 비 커스텀 이벤트 액션 요소를 커스텀 이벤트에서 제거하려고 시도했습니다" )
            endif
            call TriggerRemoveAction( LoadTriggerHandle(TH,0,ev), ta )
            return
        endmethod
        static method addAction takes integer ev, code c returns triggeraction
            if not HaveSavedHandle( TH, 0, ev ) then
                call SaveTriggerHandle( TH, 0, ev, CreateTrigger() )
            endif
            return RegisterAction( TriggerAddAction( LoadTriggerHandle(TH,0,ev), c ), ev )
        endmethod
        static method evaluate takes integer ev, player p, unit u, item i, integer id returns nothing
            local integer pev = CUSTOM_EVENT
            local player pp = CUSTOM_PLAYER
            local unit pu = CUSTOM_UNIT
            local item pi = CUSTOM_ITEM
            local integer pid = CUSTOM_ID
            set CUSTOM_EVENT = ev
            set CUSTOM_PLAYER = p
            set CUSTOM_UNIT = u
            set CUSTOM_ITEM = i
            set CUSTOM_ID = id
            call TriggerExecute( LoadTriggerHandle(TH,0,ev) )
            set CUSTOM_EVENT = pev
            set CUSTOM_PLAYER = pp
            set CUSTOM_UNIT = pu
            set CUSTOM_ITEM = pi
            set CUSTOM_ID = pid
            set pp = null
            set pu = null
            set pi = null
        endmethod
    endstruct
endlibrary


