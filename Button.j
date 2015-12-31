/*
  버튼으로 사용할 목적의 유닛을 생성/관리할 수 있는 라이브러리입니다.
  
  local Button myButton = Button.create( 타입ID, X, Y, 크기 )
  call myButton.addAction( 함수 )
  call myButton.destroy()
  
  local Button clickedButton = Button.getTrigger()
*/
  
  library Button
    struct Button
        private static hashtable H = InitHashtable(  )
        private static hashtable H2 = InitHashtable(  )
        private static trigger TRIG = CreateTrigger(  )
        private static trigger VTRIG = CreateTrigger(  )
        private unit unit
        integer data
        integer parent
        private static method onInit takes nothing returns nothing
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(0), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(1), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(2), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(3), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(4), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(5), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(6), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(7), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(8), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(9), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(10), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerRegisterPlayerUnitEvent( TRIG, Player(11), EVENT_PLAYER_UNIT_SELECTED, null )
            call TriggerAddCondition( TRIG, Filter( function thistype.evaluate ) )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(0), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(1), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(2), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(3), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(4), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(5), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(6), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(7), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(8), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(9), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(10), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerRegisterPlayerUnitEvent( VTRIG, Player(11), EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, null )
            call TriggerAddCondition( VTRIG, Filter( function thistype.vvaluate ) )
        endmethod
        private static method vvaluate takes nothing returns boolean
            local integer selected = LoadInteger( H, 0, GetHandleId( GetOrderTargetUnit() ) )
            if selected == 0 then
                return false
            endif
            call PauseUnit( GetTriggerUnit(), true )
            call PauseUnit( GetTriggerUnit(), false )
            call IssueImmediateOrder( GetTriggerUnit(), "stop" )
            return false
        endmethod
        private static method evaluate takes nothing returns boolean
            local integer selected = LoadInteger( H, 0, GetHandleId( GetTriggerUnit() ) )
            if selected == 0 then
                return false
            endif
            call TriggerEvaluate( LoadTriggerHandle( H2, 0, selected ) )
            call SelectUnitRemoveForPlayer( GetTriggerUnit(), GetTriggerPlayer() )
            return false
        endmethod
        method operator super takes nothing returns unit
            return .unit
        endmethod
        static method getTrigger takes nothing returns thistype
            return LoadInteger( H, 0, GetHandleId( GetTriggerUnit() ) )
        endmethod
        static method create takes integer id, real x, real y, real size returns thistype
            local thistype this = thistype.allocate(  )
            set .unit = CreateUnit( Player(15), id, x, y, 270.00 )
            call SaveInteger( H, 0, GetHandleId( .unit ), this )
            call SetUnitScale( .unit, size, size, size )
            call SetUnitVertexColor( .unit, 0, 0, 0, 0 )
            call SaveTriggerHandle( H2, 0, this, CreateTrigger() )
            set .data = 0
            set .parent = 0
            return this
        endmethod
        method addAction takes code c returns triggercondition
            local boolean doNotInline = true
            return TriggerAddCondition( LoadTriggerHandle( H2, 0, this ), Filter( c ) )
        endmethod
        method destroy takes nothing returns nothing
            call SaveInteger( H, 0, GetHandleId( .unit ), 0 )
            call RemoveUnit( .unit )
            call DestroyTrigger( LoadTriggerHandle( H2, 0, this ) )
            call SaveTriggerHandle( H2, 0, this, null )
            set .unit = null
            call thistype.deallocate( this )
        endmethod
    endstruct
endlibrary

