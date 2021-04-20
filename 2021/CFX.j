/**
 * CFX 라이브러리
 *
 * Copyright (c) 2021 escaco95@naver.com
 * Distributed under the BSD License, Version 210421.1
 *
 * [210421.1] 코드 점검 제안. thistype.Count 메트릭 제공. CFX_COUNTWARNINGBASE 단위의 개체 초과생성 경고 알림.
 *            버전 혼재로 인한 OnInvalidate -> OnBeforeTick 으로 이름 재조정. New / Last 모두 지원.
 * [210421.0] 미사용 변수 1개 제거, this.Stop()이후 this.Start()가 가능한 취약점 경고 알림.(DEBUG MODE)
 */
library CFX
globals
constant boolean CFX_COUNTWARNING = DEBUG_MODE
constant integer CFX_COUNTWARNINGBASE = 300
constant real    CFX_GCTIMEOUT = 2.5
hashtable CFX_TABLE = InitHashtable()
endglobals
endlibrary
/**
    * CFX struct
    *
    * [Supports]
    *  - local thistype fx = thistype.Create()
    *  - local thistype fx = thistype.New (또는 thistype.Last)
    *  - local integer  핸들카운트 = thistype.Count
    *  - call this.Start()
    *  - call this.Stop()
    *  - local boolean exists = this.Exists
    *  - local integer timerHandle = this.Handle
    *  - local real elapsed = this.Elapsed
    *  - local real timeout = this.Timeout
    *  - local integer stage = this.Stage
    *  - private method OnCreate takes nothing returns nothing
    *  - private method OnStop takes nothing returns nothing
    *  - private method OnStart takes nothing returns nothing
    *  - private method OnBeforeTick takes nothing returns nothing
    *  - private method OnTick takes nothing returns nothing
    */
//! textmacro CFX takes TIMEOUT
/*================================================================================================*/
static method create takes nothing returns thistype
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.create는 사용할 수 없습니다. 대신 thistype.Create()를 사용하세요.")
    return 0
endmethod
method destroy takes nothing returns nothing
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.destroy는 사용할 수 없습니다. 대신 thistype.Stop()을 사용하세요.")
endmethod
/*================================================================================================*/
private static thistype CFXLast = 0
private static integer CFXCount = 0
static method operator New takes nothing returns thistype
    return CFXLast
endmethod
static method operator Last takes nothing returns thistype
    return CFXLast
endmethod
static method operator Count takes nothing returns integer
    return CFXCount
endmethod
private boolean CFXexists
private timer CFXtimer
private integer CFXhandle
private real CFXelapsed
method operator Exists takes nothing returns boolean
    return this.CFXexists
endmethod
method operator Handle takes nothing returns integer
    return this.CFXhandle
endmethod
method operator Elapsed takes nothing returns real
    return this.CFXelapsed
endmethod
method operator Timeout takes nothing returns real
    return TimerGetTimeout(this.CFXtimer)
endmethod
private real CFXtimeout
method operator Timeout= takes real v returns nothing
    set this.CFXtimeout = v
endmethod
private integer Stage
/*================================================================================================*/
private static method CFXAtTick takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    static if thistype.OnBeforeTick.exists then
        call this.OnBeforeTick()
        if not this.CFXexists then
            return
        endif
    endif
    set this.CFXelapsed = this.CFXelapsed + TimerGetTimeout(this.CFXtimer)
    set this.Stage = this.Stage + 1
    static if thistype.OnTick.exists then
        call this.OnTick()
    endif
    if not this.CFXexists then
        return
    endif
    if this.CFXtimeout < 0.0 then
        return
    endif
    call TimerStart(this.CFXtimer,this.CFXtimeout,true,function thistype.CFXAtTick)
    set this.CFXtimeout = -1.0
endmethod
private static method CFXAtDestroy takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    call DestroyTimer(this.CFXtimer)
    set this.CFXtimer = null
    call RemoveSavedInteger(CFX_TABLE,0,this.CFXhandle)
    set this.CFXhandle = 0
    set thistype.CFXCount = thistype.CFXCount - 1
    call this.deallocate()
endmethod
/*================================================================================================*/
static method Create takes nothing returns thistype
    local thistype this = thistype.allocate()
    set this.CFXexists = true
    set this.CFXtimer = CreateTimer()
    set this.CFXhandle = GetHandleId(this.CFXtimer)
    call SaveInteger(CFX_TABLE,0,this.CFXhandle,this)
    set this.CFXelapsed = 0.0
    set this.CFXtimeout = -1.0
    set this.Stage = 0
    set thistype.CFXCount = thistype.CFXCount + 1
    static if CFX_COUNTWARNING then
        if ModuloInteger(thistype.CFXCount,CFX_COUNTWARNINGBASE) == 0 then
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] thistype CFX 개체수 "+I2S(thistype.CFXCount)+" 돌파!")
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 코드 점검 제안.")
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 1. thistype.Create()이후 call this.Start()를 빠뜨렸을 가능성.")
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 2. OnTick에서 thistype.Stop()을 빼먹었거나 조건 미충족으로 인해 실행되지 않았을 가능성.")
            debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 3. OnCreate/OnStart/OnTick 등의 과정에서 스레드가 사망했을 가능성")
        endif
    endif
    static if thistype.OnCreate.exists then
        call this.OnCreate()
    endif
    set thistype.CFXLast = this
    return this
endmethod
method Stop takes nothing returns nothing
    if not this.CFXexists then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] thistype CFX 중복 Stop 시도됨!")
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 코드 점검 제안.")
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 1. 복붙 과정에서 call this.Stop()이 여러 번 붙여넣어졌을 가능성.")
        return
    endif
    set this.CFXexists = false
    static if thistype.OnStop.exists then
        call this.OnStop()
    endif
    call TimerStart(this.CFXtimer,CFX_GCTIMEOUT,false,function thistype.CFXAtDestroy)
endmethod
method Start takes nothing returns nothing
    if not this.CFXexists then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] thistype CFX 중단된 개체에 대한 Start 시도됨!")
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 코드 점검 제안.")
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] 1. 복붙 과정에서 ~.Start()가 여러 번 붙여넣어졌을 가능성.")
        return
    endif
    static if thistype.OnStart.exists then
        call this.OnStart()
    endif
    call TimerStart(this.CFXtimer,$TIMEOUT$,true,function thistype.CFXAtTick)
endmethod
/*================================================================================================*/
//! endtextmacro
