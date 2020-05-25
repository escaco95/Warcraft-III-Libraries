/********************************************************************************/
/*
    버프 과부하 모니터링 트리거
*/
/********************************************************************************/
scope BuffPerformanceCheck initializer OnMapLoad
    /*==========================================================================*/
    globals
        private constant real CHECK_TIMEOUT = 1.0 /* 과부하 체크 간격(초) */
    endglobals
    /*==========================================================================*/
    /* 매 CHECK_TIMEOUT 초마다 발동 */
    private function OnMapTimeout takes nothing returns nothing
        local integer count = Struct2Buff.Count
        call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0, /*
            */ "버프 과부하 : " + I2S(count))
    endfunction
    /*--------------------------------------------------------------------------*/
    /* 맵 로딩 직후 발동 */
    private function OnMapLoad takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function OnMapTimeout)
        call TriggerRegisterTimerEvent(t,CHECK_TIMEOUT,true)
        set t = null
    endfunction
    /*==========================================================================*/
endscope
/********************************************************************************/


/********************************************************************************/
/* 특정 아이템을 하나라도 소지하고 있는 동안 버프가 무한히 유지됨 */
/********************************************************************************/
struct CnobBuff
    
    /* OnTimeout : 버프 '틱' 마다 발동되는 메소드(Timeout이 음수라면 발동안함) */
    method OnTimeout takes nothing returns boolean
        call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"버프 있음!")
        
        return UnitHasItemOfTypeBJ(.Target,'cnob') /* cnob를 갖고 있지 않으면 버프 중단 */
    endmethod
    
    /* struct를 Buff로 만듦 */
    //! runtextmacro Struct2Buff("1.0")
    
endstruct
/********************************************************************************/


/********************************************************************************/
/* 버프 만료 시 사살 */
/********************************************************************************/
struct WispKill
    
    effect Effect
    
    /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
    method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
        return this.Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
    endmethod
    
    /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
    method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
        set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
        set .Duration = dur
        set .Argument = arg
    endmethod
    
    /* OnApply : Buff 최초 적용 성공 시 발동되는 메소드 */
    method OnApply takes nothing returns nothing
        set .Effect = AddSpecialEffectTarget("units\\nightelf\\Wisp\\Wisp.mdl",.Target,"overhead")
    endmethod
    
    /* OnRemove : Buff 데이터 삭제 시 발동되는 메소드 */
    method OnRemove takes nothing returns nothing
        call DestroyEffect(.Effect)
        set .Effect = null
    endmethod
    
    /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
    method OnDuration takes nothing returns nothing
        call KillUnit(.Target)
    endmethod
    
    /* struct를 Buff로 만듦 */
    //! runtextmacro Struct2Buff("-1.0")
    
endstruct
/********************************************************************************/


/********************************************************************************/
/* 중첩 시 보다 긴 시간으로 갱신되는 버프 예제 */
/********************************************************************************/
struct StackExampleBuff
    
    /* OnBeforeStack : Buff 중첩 시도 시 발동되는 메소드 */
    method OnBeforeStack takes unit caster, real timeout, real dur, integer arg returns boolean
        return this.Remaining < dur /* 남은 시간 < 새로 적용될 시간 : 일 경우에만 갱신! */
    endmethod
    
    /* OnStack : Buff 중첩 시도(OnBeforeStack) 성공(true) 시 발동되는 메소드 */
    method OnAfterStack takes unit caster, real timeout, real dur, integer arg returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,"스택!!")
        set .Timeout = timeout /* 새로운 시간 설정으로 갱신 */
        set .Duration = dur
        set .Argument = arg
    endmethod
    
    /* OnDuration : 지속 시간 만료 시 발동되는 메소드(영구 지속 시 발동안함) */
    method OnDuration takes nothing returns nothing
        call DisplayTextToPlayer(GetLocalPlayer(),0.0,0.0,R2S(.Duration)+"초 경과!")
    endmethod
    
    /* struct를 Buff로 만듦 */
    //! runtextmacro Struct2Buff("-1.0")
    
endstruct
/********************************************************************************/
