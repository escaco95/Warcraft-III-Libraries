/********************************************************************************/
native UnitAlive takes unit id returns boolean
/********************************************************************************/
library Struct2Pattern
    globals
        hashtable S2PT_IN_TABLE = InitHashtable()
    endglobals
endlibrary
/********************************************************************************/
//! textmacro Struct2Pattern
private timer IN_TIMER
private unit unit
private real timer
private integer IN_N_PHASE
private integer IN_C_PHASE
private method operator Phase takes nothing returns integer
    return .IN_C_PHASE
endmethod
private method operator Phase= takes integer new returns nothing
    if new <= .IN_C_PHASE then
        return
    endif
    set .IN_N_PHASE = new
    debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"페이즈 "+I2S(new)+" 할당!")
endmethod
private static method IN_TICK takes nothing returns nothing
    local thistype this = LoadInteger(S2PT_IN_TABLE,0,GetHandleId(GetExpiredTimer()))
    static if thistype.OnPatternTick.exists then
        call .OnPatternTick()
    endif
    if .IN_C_PHASE < .IN_N_PHASE then
        static if thistype.OnPhaseEnd.exists then
            call .OnPhaseEnd()
        endif
        set .IN_C_PHASE = .IN_N_PHASE
        static if thistype.OnPhaseStart.exists then
            call .OnPhaseStart()
        endif
    endif
    if .timer > 0.01 then
        call TimerStart(.IN_TIMER,.timer,false,function thistype.IN_TICK)
    endif
endmethod
static method Set takes unit u returns nothing
    local thistype this = .allocate()
    set .unit = u
    set .IN_C_PHASE = 1
    set .IN_N_PHASE = 1
    set .timer = -1.0
    set .IN_TIMER = CreateTimer()
    call SaveInteger(S2PT_IN_TABLE,0,GetHandleId(.IN_TIMER),this)
    static if thistype.OnPatternSet.exists then
        call .OnPatternSet()
    endif
    static if thistype.OnPhaseStart.exists then
        call .OnPhaseStart()
    endif
    if .timer > 0.01 then
        call TimerStart(.IN_TIMER,.timer,false,function thistype.IN_TICK)
    endif
endmethod
static method create takes nothing returns thistype
    call BJDebugMsg("<Pattern>: " + create.name + " 사용 금지!")
    return 0
endmethod
method destroy takes nothing returns nothing
    call BJDebugMsg("<Pattern>: " + destroy.name + " 사용 금지!")
endmethod
//! endtextmacro
/********************************************************************************/
