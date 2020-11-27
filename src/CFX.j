/**
 * CFX Library
 *
 * Copyright (c) 2020 escaco95@naver.com
 * Distributed under the BSD License, Version 201128.1
 */
library CFX
globals
constant real CFX_TIMEOUT = 0.02
constant real CFX_GCTIMEOUT = 2.5
hashtable CFX_TABLE = InitHashtable()
endglobals
endlibrary
/**
 * CFX struct
 *
 * [Supports]
 *  - local thistype this = thistype.Create()
 *  - call this.Start()
 *  - call this.Stop()
 *  - local boolean exists = this.Exists
 *  - local integer timerHandle = this.Handle
 *  - local real elapsed = this.Elapsed
 *  - local real timeout = this.Timeout
 *  - private method OnCreate takes nothing returns nothing
 *  - private method OnStop takes nothing returns nothing
 *  - private method OnStart takes nothing returns nothing
 *  - private method OnInvalidate takes nothing returns nothing
 *  - private method OnTick takes nothing returns nothing
 */
//! textmacro CFX
/*================================================================================================*/
static method create takes nothing returns thistype
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.create는 사용할 수 없습니다. 대신 thistype.Create()를 사용하세요.")
    return 0
endmethod
method destroy takes nothing returns nothing
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.destroy는 사용할 수 없습니다. 대신 thistype.Stop()을 사용하세요.")
endmethod
/*================================================================================================*/
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
/*================================================================================================*/
private static method CFXAtTick takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    static if thistype.OnInvalidate.exists then
        call this.OnInvalidate()
        if not this.CFXexists then
            return
        endif
    endif
    set this.CFXelapsed = this.CFXelapsed + TimerGetTimeout(this.CFXtimer)
    static if thistype.OnTick.exists then
        call this.OnTick()
    endif
endmethod
private static method CFXAtDestroy takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    call DestroyTimer(this.CFXtimer)
    set this.CFXtimer = null
    call RemoveSavedInteger(CFX_TABLE,0,this.CFXhandle)
    set this.CFXhandle = 0
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
    static if thistype.OnCreate.exists then
        call this.OnCreate()
    endif
    return this
endmethod
method Stop takes nothing returns nothing
    if not this.CFXexists then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] thistype CTX 중복 Stop 시도됨!")
        return
    endif
    set this.CFXexists = false
    static if thistype.OnStop.exists then
        call this.OnStop()
    endif
    call TimerStart(this.CFXtimer,CFX_GCTIMEOUT,false,function thistype.CFXAtDestroy)
endmethod
method Start takes nothing returns nothing
    static if thistype.OnStart.exists then
        call this.OnStart()
    endif
    call TimerStart(this.CFXtimer,CFX_TIMEOUT,true,function thistype.CFXAtTick)
endmethod
/*================================================================================================*/
//! endtextmacro
/**
 * CFXFrame struct
 *
 * [Supports]
 *  - local thistype this = thistype.Create()
 *  - call this.Start()
 *  - call this.Stop()
 *  - local boolean exists = this.Exists
 *  - local integer timerHandle = this.Handle
 *  - local real elapsed = this.Elapsed
 *  - local real timeout = this.Timeout
 *  - local integer frame = this.Frame
 *  - private method OnCreate takes nothing returns nothing
 *  - private method OnStop takes nothing returns nothing
 *  - private method OnStart takes nothing returns nothing
 *  - private method OnInvalidate takes nothing returns nothing
 *  - private method OnTick takes nothing returns nothing
 */
//! textmacro CFXFrame
/*================================================================================================*/
static method create takes nothing returns thistype
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.create는 사용할 수 없습니다. 대신 thistype.Create()를 사용하세요.")
    return 0
endmethod
method destroy takes nothing returns nothing
    debug call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, "[경고] thistype.destroy는 사용할 수 없습니다. 대신 thistype.Stop()을 사용하세요.")
endmethod
/*================================================================================================*/
private boolean CFXexists
private timer CFXtimer
private integer CFXhandle
private real CFXelapsed
private integer Frame
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
/*================================================================================================*/
private static method CFXAtTick takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    static if thistype.OnInvalidate.exists then
        call this.OnInvalidate()
        if not this.CFXexists then
            return
        endif
    endif
    set this.CFXelapsed = this.CFXelapsed + TimerGetTimeout(this.CFXtimer)
    set this.Frame = this.Frame + 1
    static if thistype.OnTick.exists then
        call this.OnTick()
    endif
endmethod
private static method CFXAtDestroy takes nothing returns nothing
    local thistype this = LoadInteger(CFX_TABLE,0,GetHandleId(GetExpiredTimer()))
    call DestroyTimer(this.CFXtimer)
    set this.CFXtimer = null
    call RemoveSavedInteger(CFX_TABLE,0,this.CFXhandle)
    set this.CFXhandle = 0
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
    set this.Frame = 0
    static if thistype.OnCreate.exists then
        call this.OnCreate()
    endif
    return this
endmethod
method Stop takes nothing returns nothing
    if not this.CFXexists then
        debug call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"[WARN] thistype CTX 중복 Stop 시도됨!")
        return
    endif
    set this.CFXexists = false
    static if thistype.OnStop.exists then
        call this.OnStop()
    endif
    call TimerStart(this.CFXtimer,CFX_GCTIMEOUT,false,function thistype.CFXAtDestroy)
endmethod
method Start takes nothing returns nothing
    static if thistype.OnStart.exists then
        call this.OnStart()
    endif
    call TimerStart(this.CFXtimer,CFX_TIMEOUT,true,function thistype.CFXAtTick)
endmethod
/*================================================================================================*/
//! endtextmacro
