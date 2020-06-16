/********************************************************************************/
native UnitAlive takes unit id returns boolean
/********************************************************************************/
library Struct2Timeline
    globals
        hashtable S2TL_IN_TABLE = InitHashtable()
    endglobals
endlibrary
/********************************************************************************/
//! textmacro Struct2Timeline
private timer timer
private method Next takes code c, real t, boolean f returns nothing
    call TimerStart(.timer,t,f,c)
endmethod
private static method GetTriggerTimeline takes nothing returns thistype
    return LoadInteger(S2TL_IN_TABLE,0,GetHandleId(GetExpiredTimer()))
endmethod
method Start takes nothing returns nothing
    static if thistype.OnStart.exists then
        call .OnStart()
    endif
endmethod
method Stop takes nothing returns nothing
    static if thistype.OnStop.exists then
        call .OnStop()
    endif
    call DestroyTimer(.timer)
    set .timer = null
    call .deallocate()
endmethod
static method Create takes nothing returns thistype
    local thistype this = .allocate()
    set .timer = CreateTimer()
    call SaveInteger(S2TL_IN_TABLE,0,GetHandleId(.timer),this)
    static if thistype.OnCreate.exists then
        call .OnCreate()
    endif
    return this
endmethod
static method create takes nothing returns thistype
    call BJDebugMsg("<Timeline>: " + create.name + " 사용 금지!")
    return 0
endmethod
method destroy takes nothing returns nothing
    call BJDebugMsg("<Timeline>: " + destroy.name + " 사용 금지!")
endmethod
//! endtextmacro
/********************************************************************************/
