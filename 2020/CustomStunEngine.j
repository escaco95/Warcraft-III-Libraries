//*****************************************************************
// Custom Stun System
//*****************************************************************
library CustomStun initializer OnMapLoad
    //=============================================================
    globals
        //---------------------------------------------------------
        private constant real SYSTEM_TIMEOUT_DELAY = 0.03125
        private constant integer SYSTEM_DUMMY_ID   = 'h000'
        private constant integer SYSTEM_BUFF_ID    = 'BPSE'
        private constant player SYSTEM_DUMMY_OWNER = Player(PLAYER_NEUTRAL_PASSIVE)
        private constant real SYSTEM_DUMMY_X       = 0.0
        private constant real SYSTEM_DUMMY_Y       = 0.0
        private constant string SYSTEM_DUMMY_COMMAND = "thunderbolt"
        //---------------------------------------------------------
        private unit SYSTEM_DUMMY = null
        //---------------------------------------------------------
        private hashtable TABLE = InitHashtable()
        private key KEY_STUN_DATA
        //---------------------------------------------------------
        private trigger E_STUN_NEW = CreateTrigger()
        private trigger E_STUN_STACK = CreateTrigger()
        private trigger E_STUN_START = CreateTrigger()
        private trigger E_STUN_TIMEOUT = CreateTrigger()
        private trigger E_STUN_END = CreateTrigger()
        //---------------------------------------------------------
        private integer P_STUN = 0
        private unit P_UNIT_SOURCE = null
        private unit P_UNIT_TARGET = null
        private real P_TIMEOUT = 0.0
        private real P_ELAPSED = 0.0
        private real P_REMAINING = 0.0
        //---------------------------------------------------------
    endglobals
    //=============================================================
    private struct EVENT extends array
        //---------------------------------------------------------
        static method Fire takes trigger t, integer id, unit src, unit dst, /*
            */ real timeout, real elapsed, real remaining returns nothing
            local integer ps = P_STUN
            local unit pusrc = P_UNIT_SOURCE
            local unit pudst = P_UNIT_TARGET
            local real ptout = P_TIMEOUT
            local real pelap = P_ELAPSED
            local real prema = P_REMAINING
            set P_STUN = id
            set P_UNIT_SOURCE = src
            set P_UNIT_TARGET = dst
            set P_TIMEOUT = timeout
            set P_ELAPSED = elapsed
            set P_REMAINING = remaining
            call TriggerEvaluate(t)
            set P_STUN = ps
            set P_UNIT_SOURCE = pusrc
            set P_UNIT_TARGET = pudst
            set P_TIMEOUT = ptout
            set P_ELAPSED = pelap
            set P_REMAINING = prema
            set pusrc = null
            set pudst = null
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
    private struct StunData
        //---------------------------------------------------------
        integer Handle
        unit Source
        unit Target
        timer Timer
        real FullTimeout
        real Elapsed
        //---------------------------------------------------------
        static method GetStunData takes handle h returns thistype
            return LoadInteger(TABLE,KEY_STUN_DATA,GetHandleId(h))
        endmethod
        //---------------------------------------------------------
        static method OnStunTimeout takes nothing returns nothing
            local thistype this = LoadInteger(TABLE,KEY_STUN_DATA,GetHandleId(GetExpiredTimer()))
            local real timeout = this.FullTimeout
            local real elapsed = this.Elapsed + SYSTEM_TIMEOUT_DELAY
            local real remaining = timeout - elapsed
            set this.Elapsed = elapsed
            if remaining < 0.0 then
                // 이벤트 격발 - 스턴 종료
                call EVENT.Fire(E_STUN_END,this,Source,Target,timeout,timeout,0.0)
                // 마감
                call UnitRemoveAbility(this.Target,SYSTEM_BUFF_ID)
                call RemoveSavedInteger(TABLE,KEY_STUN_DATA,GetHandleId(Timer))
                call RemoveSavedInteger(TABLE,KEY_STUN_DATA,Handle)
                set Source = null
                set Target = null
                call DestroyTimer(Timer)
                set Timer = null
                call destroy()
                return
            endif
            // 이벤트 격발 - 스턴 중
            call EVENT.Fire(E_STUN_TIMEOUT,this,Source,Target,timeout,elapsed,remaining)
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
    // 외부에서 직접 접근 가능한 기능
    struct CustomStun extends array
        //---------------------------------------------------------
        // 이벤트 - 맨 처음 스턴이 걸렸으면 발동
        static method RegisterStunNewEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_NEW,Condition(c))
        endmethod
        // 이벤트 - 스턴이 중첩되면 발동
        static method RegisterStunStackEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_STACK,Condition(c))
        endmethod
        // 이벤트 - 중첩 여부에 상관 없이 일단 뭐든 스턴이 걸리면 발동
        static method RegisterStunStartEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_START,Condition(c))
        endmethod
        // 이벤트 - 스턴에 걸려있는 동안 발동
        static method RegisterStunTimeoutEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_TIMEOUT,Condition(c))
        endmethod
        // 이벤트 - 스턴 지속시간이 종료되면 발동
        static method RegisterStunEndEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_END,Condition(c))
        endmethod
        //---------------------------------------------------------
        // 이벤트 대응 - 스턴 인스턴스 ID
        static method GetEventStunId takes nothing returns integer
            return P_STUN
        endmethod
        // 이벤트 대응 - 스턴을 가한 유닛
        static method GetEventStunSource takes nothing returns unit
            return P_UNIT_SOURCE
        endmethod
        // 이벤트 대응 - 스턴을 받은 유닛
        static method GetTriggerUnit takes nothing returns unit
            return P_UNIT_TARGET
        endmethod
        // 이하동문 ( 보다 편한 쪽으로 사용 )
        static method GetStunnedUnit takes nothing returns unit
            return P_UNIT_TARGET
        endmethod
        // 이벤트 대응 - 총 스턴 시간
        static method GetTimeout takes nothing returns real
            return P_TIMEOUT
        endmethod
        // 이벤트 대응 - 지나간 스턴 시간
        static method GetElapsed takes nothing returns real
            return P_ELAPSED
        endmethod
        // 이벤트 대응 - 남은 스턴 시간
        static method GetRemaining takes nothing returns real
            return P_REMAINING
        endmethod
        //---------------------------------------------------------
        private static method DoStun takes unit src, unit dst, real timeout returns nothing
            local StunData data = StunData.GetStunData(dst)
            if data == 0 then
                set data = StunData.create()
                set data.Source = null
                set data.Target = dst
                set data.FullTimeout = timeout
                set data.Elapsed = 0.0
                set data.Timer = CreateTimer()
                set data.Handle = GetHandleId(dst)
                call SaveInteger(TABLE,KEY_STUN_DATA,GetHandleId(data.Timer),data)
                call SaveInteger(TABLE,KEY_STUN_DATA,GetHandleId(dst),data)
                
                call IssueTargetOrder(SYSTEM_DUMMY,SYSTEM_DUMMY_COMMAND,dst)
                // 이벤트 격발 - 새 스턴
                call EVENT.Fire(E_STUN_NEW,data,src,dst,timeout,0.0,timeout)
            else
                set data.FullTimeout = data.FullTimeout + timeout
                // 이벤트 격발 - 중첩
                call EVENT.Fire(E_STUN_STACK,data,src,dst,data.FullTimeout,data.Elapsed,data.FullTimeout-data.Elapsed)
            endif
            
            // 이벤트 격발 - 스턴 시작됨
            call EVENT.Fire(E_STUN_START,data,src,dst,data.FullTimeout,data.Elapsed,data.FullTimeout-data.Elapsed)
            call TimerStart(data.Timer,SYSTEM_TIMEOUT_DELAY,true,function StunData.OnStunTimeout)
        endmethod
        //---------------------------------------------------------
        // 커스텀 스턴 - (dst)유닛을 (timeout)초 동안 '추가로' 기절시킵니다
        static method Stun takes unit dst, real timeout returns nothing
            if GetUnitTypeId(dst) == 0 then
                return
            endif
            call DoStun(null,dst,timeout)
        endmethod
        // 커스텀 스턴 - (src)유닛이 (dst)유닛을 (timeout)초 동안 '추가로' 기절시킨 판정을 발생시킵니다
        static method StunEx takes unit src, unit dst, real timeout returns nothing
            if GetUnitTypeId(dst) == 0 then
                return
            endif
            call DoStun(src,dst,timeout)
        endmethod
        //---------------------------------------------------------
        // 커스텀 스턴 - (dst)유닛으로부터 스턴을 해제합니다
        static method Clear takes unit dst returns nothing
            local StunData data = StunData.GetStunData(dst)
            if data == 0 then
                return
            endif
            set data.Elapsed = 0.0
            set data.FullTimeout = 0.0
        endmethod
        // 커스텀 스턴 - (dst)유닛의 남은 스턴 시간을 가져옵니다
        static method GetUnitStunRemaining takes unit dst returns real
            local StunData data = StunData.GetStunData(dst)
            if data == 0 then
                return 0.0
            endif
            return data.FullTimeout - data.Elapsed
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        set SYSTEM_DUMMY = CreateUnit( SYSTEM_DUMMY_OWNER, SYSTEM_DUMMY_ID, /*
        */ SYSTEM_DUMMY_X, SYSTEM_DUMMY_Y, 270.0 )
        call UnitAddAbility(SYSTEM_DUMMY,'Avul')
        call UnitAddAbility(SYSTEM_DUMMY,'Aloc')
    endfunction
    //=============================================================
endlibrary
//*****************************************************************
