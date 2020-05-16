//*****************************************************************
// 데미지 엔진 - 나만의 데미지 시스템을 만들자!
//     Version 1.0
//*****************************************************************
library DamageEngine
    //=============================================================
    // DamageEngine 사용자 설정
    private struct CONFIG extends array
        //---------------------------------------------------------
        // *** 주의 : 시스템 구동에 영향을 주는 핵심 설정입니다 ***
        //  시스템에 대한 충분한 이해 없이 이하의 설정을 변경하게 될 경우 급격한
        //  퍼포먼스 감소, 예기지 않은 버그가 발생할 수 있습니다. 변경하기 전에
        //  신중하게 고민하고 결정하세요!
        //---------------------------------------------------------
        // CONFIG.CLEAR_DELAY 설명
        //  - DamageEngine은 call DamageEngine.Add( 유닛 ) 호출을
        //    통해 수동 등록된 유닛들만 관리합니다.
        //  - 단, 등록된 유닛에 대한 제거 과정은 '자동'으로 진행합니다.
        //  > CLEAR_DELAY(초)는 자동 메모리 최적화 간격을 의미하며, 해당
        //    간격이 짧을수록 메모리 효율은 증가하나 최적화 렉은 증가합니다.
        static constant real CLEAR_DELAY = 0.03125
        //---------------------------------------------------------
    endstruct
    //=============================================================
    private struct DEBUGINFO extends array
        //---------------------------------------------------------
        static constant string ARGNULL /*
        */ = "DamageEngine 경고: null 유닛의 등록 시도됨"
        static constant string ARGEXISTS /*
        */ = "DamageEngine 경고: 중복 등록 시도됨"
        static constant string CLEARED /*
        */ = "DamageEngine 알림: 핸들 제거됨"
        //---------------------------------------------------------
    endstruct
    //=============================================================
    private struct INDEX
        //---------------------------------------------------------
        boolean Exists
        integer Handle
        unit Unit
        trigger Trig
        triggercondition Cond
        //---------------------------------------------------------
    endstruct
    //=============================================================
    private struct PROC extends array
        //---------------------------------------------------------
        static hashtable TABLE = InitHashtable()
        //---------------------------------------------------------
        static trigger E_ANYATK = CreateTrigger()
        static trigger E_ANYHIT = CreateTrigger()
        static key E_TYPEATK
        static key E_TYPEHIT
        //---------------------------------------------------------
        static item P_ITEM = null
        //---------------------------------------------------------
        static boolean FIRSTRUN = true
        static timer TIMER = CreateTimer()
        static integer CUR = 0
        static integer MAX = 0
        //---------------------------------------------------------
        static method Contains takes unit u returns boolean
            return HaveSavedInteger(TABLE,0,GetHandleId(u))
        endmethod
        //---------------------------------------------------------
        private static method DamageProcess /*
            */ takes unit src, unit dst returns nothing
            call TriggerEvaluate(E_ANYATK)
            
            call TriggerEvaluate(LoadTriggerHandle(TABLE /*
            */ , E_TYPEATK, GetUnitTypeId(src) ))
            
            call TriggerEvaluate(LoadTriggerHandle(TABLE /*
            */ , E_TYPEHIT, GetUnitTypeId(dst) ))
            
            call TriggerEvaluate(E_ANYHIT)
        endmethod
        private static method OnEvaluate takes nothing returns boolean
            if GetEventDamage() == 0 then
                return false
            endif
            call DamageProcess(GetEventDamageSource(),GetTriggerUnit())
            return false
        endmethod
        //---------------------------------------------------------
        private static method OnClearTick takes nothing returns nothing
            local INDEX i
            
            if CUR > MAX then
                set CUR = 1
                return
            endif
            
            set i = CUR
            set CUR = CUR + 1
            
            if not i.Exists then
                return
            endif
            
            if GetUnitTypeId(i.Unit) != 0 then
                return
            endif
            
            set i.Exists = false
            call TriggerRemoveCondition(i.Trig,i.Cond)
            set i.Cond = null
            call DestroyTrigger(i.Trig)
            set i.Trig = null
            set i.Unit = null
            call RemoveSavedInteger(TABLE,0,i.Handle)
            set i.Handle = 0
            call i.destroy()
            
            debug call DisplayTextToPlayer(GetLocalPlayer() /*
            */ , 0.0, 0.0, DEBUGINFO.CLEARED )
        endmethod
        //---------------------------------------------------------
        static method Register takes unit u returns nothing
            local INDEX i = INDEX.create()
            local integer i2i = i
            set i.Handle = GetHandleId(u)
            set i.Unit = u
            set i.Trig = CreateTrigger()
            set i.Cond = TriggerAddCondition(i.Trig, /*
            */ Condition(function thistype.OnEvaluate))
            call SaveInteger(TABLE,0,i.Handle,i)
            set i.Exists = true
            call TriggerRegisterUnitEvent(i.Trig,u, /*
            */ EVENT_UNIT_DAMAGED)
            if i2i > MAX then
                set MAX = i
                if FIRSTRUN then
                    set FIRSTRUN = false
                    set CUR = 1
                    call TimerStart( /*
                    */ TIMER, CONFIG.CLEAR_DELAY, true /*
                    */ , function thistype.OnClearTick )
                endif
            endif
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
    struct DamageEngine extends array
        //---------------------------------------------------------
        static method RegisterAnyUnitAttackEvent /*
            */ takes code trigAction /*
            */ returns triggercondition
            return TriggerAddCondition(PROC.E_ANYATK,Condition(trigAction))
        endmethod
        static method RegisterUnitTypeAttackEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(PROC.TABLE,PROC.E_TYPEATK,typeId) then
                call SaveTriggerHandle(PROC.TABLE,PROC.E_TYPEATK,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(PROC.TABLE,PROC.E_TYPEATK,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
        static method RegisterAnyUnitHitEvent /*
            */ takes code trigAction /*
            */ returns triggercondition
            return TriggerAddCondition(PROC.E_ANYHIT,Condition(trigAction))
        endmethod
        static method RegisterUnitTypeHitEvent /*
            */ takes integer typeId, code trigAction /*
            */ returns triggercondition
            if not HaveSavedHandle(PROC.TABLE,PROC.E_TYPEHIT,typeId) then
                call SaveTriggerHandle(PROC.TABLE,PROC.E_TYPEHIT,typeId,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(PROC.TABLE,PROC.E_TYPEHIT,typeId) /*
                */ , Condition(trigAction))
        endmethod
        //---------------------------------------------------------
        static method GetEventItem takes nothing returns item
            return PROC.P_ITEM
        endmethod
        //---------------------------------------------------------
        static method Add takes unit u returns nothing
            if u == null then
                debug call BJDebugMsg(DEBUGINFO.ARGNULL)
                return
            endif
            if PROC.Contains(u) then
                debug call BJDebugMsg(DEBUGINFO.ARGEXISTS)
                return
            endif
            call PROC.Register(u)
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
endlibrary    
//*****************************************************************
