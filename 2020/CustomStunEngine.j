/********************************************************************************/
/*
    CustomStun by 동동주(escaco)
        Version 1.4
        
    [업데이트]
    
    - 2020.05.29 : 1.4
    
        # 새로운 기능
            * call CustomStun.SetUnitStunRemaining( 유닛, 남은 시간 )
            * local boolean 조절성공? = CustomStun.SetUnitStunRemaining( 유닛, 남은 시간 )
                ** 유닛의 스턴 남은 시간을 설정합니다
                ** 설정에 성공하면 true, 실패하면 false를 반환합니다 (스턴에 안 걸린 유닛)
                
            * call CustomStun.AddUnitStunRemaining( 유닛, 추가 남은 시간 )
            * local boolean 조절성공? = CustomStun.AddUnitStunRemaining( 유닛, 추가 남은 시간 )
                ** 유닛의 스턴 남은 시간을 추가합니다
                ** 음수로 설정하면 남은 시간이 그만큼 감소합니다
                ** 설정에 성공하면 true, 실패하면 false를 반환합니다 (스턴에 안 걸린 유닛)
         
         
        # 라이브러리 문서화 및 코드 최적화
            * 대부분의 주석을 /**/ 으로 변경하여, 저장 시 사라지도록 조치
    
    
    [개요]

    1. 라이브러리 세팅하는 법
    
        Q: 코드를 넣었는데도 커스텀 스턴이 안 먹혀요!
        A: 라이브러리가 동작하는 원리를 알아야 하고, 원리에 맞는 세팅이 필요합니다
    
            # CustomStun의 동작 원리
                1. 맵 로딩 직후 맵 상에 '투명한' 유닛이 생김
                2. 커스텀 스턴이 필요할 때마다 그 유닛이 '스톰 볼트'를 날림
                3. 스톰 볼트의 기절 시간 = 영원히 기절
                4. 적용 시간이 지나면 시스템이 영구스턴을 해제해줌
    
            # 원리에 의해 고려해야 할 세팅
                1. SYSTEM_DUMMY_ID = '맵 로딩 직후 맵 상에 생길 투명 유닛의 원시코드'
                    * 타입        :이동이나 회전이 불가능한 건물
                    * 마법 구사 지점 : 0.00초
                    * 마법 백스윙   : 0.00초
                    * 실수로 죽지 않도록 무적 세팅
                    
                2. SYSTEM_BUFF_ID = 스톰 볼트가 거는 '기절함 버프의 원시코드'
                
                스톰 볼트의 세팅
                    * 마나 비용    : 0
                    * 시전 시간    : 0.00초
                    * 마법 유효 범위: 99999 (너무 커서 오류가 나지 않는 선에서 가능한 크게)
                    * 미사일 그림  : 없음
                    * 미사일 속도  : 99999 (너무 커서 오류가 나지 않는 선에서 가능한 크게)
                    * 데미지      : 0.00
                    * 존속 기간   : 0.00 (0.00 = 무한 스턴, 오류 발생 시 99999.00등으로 조정)
                    * 목표물      : 무적, 취약
                    
                    
                3. SYSTEM_DUMMY_OWNER = 투명 유닛의 소유자 플레이어
                    * 맵 전역의 시야가 보이는 플레이어여야 합니다
                        ** 안 보이는 곳에 있는 유닛에게는 투명 유닛이 스턴을 걸지 못합니다
                        
                4. SYSTEM_DUMMY_X, SYSTEM_DUMMY_Y = 투명 유닛의 위치
                    * 맵 중앙 '추천' : 투명 망치가 어디든 비슷한 거리로 날아가게 됩니다
        
                5. SYSTEM_DUMMY_COMMAND = 스톰 볼트 능력의 "명령 문자열"
                    * 트리거를 통해 해당 지시를 수행하게 됩니다
                    
                6. SYSTEM_TIMEOUT_DELAY = 시스템 처리 간격
                    * 추천값 = 0.03125
                    * 시스템이 스턴을 다루는 시간 간격입니다
                    * 이 간격이 짧을수록 스턴 시간 체크가 더욱 정밀해집니다
                        ** 맵에 가해지는 부하도 증가합니다
                
                
    2. 이 라이브러리로 스턴 걸기 / 이미 걸린 스턴 조절하기
    
        * 기절 걸기 - (유닛)을 (기절 시간)동안 기절시킵니다
            call CustomStun.Stun( 유닛, 기절 시간 )
            
        * 기절 걸기 - (가해자)가 (피해자)를 (기절 시간)동안 기절시킵니다
            call CustomStun.StunEx( 가해자, 피해자, 기절 시간 )
            # 스턴을 건 유닛을 이용하고 싶을 때 사용하라고 만든 기능입니다
    
        * 조절 - (유닛)의 스턴을 바로 풀어버립니다
            call CustomStun.Clear( 유닛 )
            # 시스템 정밀도에 따라 해제 시간에 오차가 생길 수 있습니다
            
        * 조절 - (유닛)의 스턴 남은 시간을 받아옵니다
            local real 스턴 남은 시간 = CustomStun.GetUnitStunRemaining( 유닛 )
            
        * 조절 - (유닛)의 남은 스턴 시간을 설정합니다
            local boolean 조절성공? = CustomStun.SetUnitStunRemaining( 유닛, 새 남은 시간 )
    
        * 조절 - (유닛)의 남은 스턴 시간을 추가 / 감소합니다
            local boolean 조절성공? = CustomStun.AddUnitStunRemaining( 유닛, 추가 남은 시간 )
            
    
    3. 이 라이브러리를 바탕으로 나만의 스페셜한 스턴 시스템 만들기
    
        # 새로운 이벤트들!
    
            call CustomStun.RegisterStunNewEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 스턴이 1차로 걸리면 발동
            
            call CustomStun.RegisterStunBeforeStackEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 스턴이 중첩으로 걸리기 전에 발동
                    # 스턴이 동시에 걸리면, 어떻게 처리할 것인지를 결정합니다
                    # CustomStun.GetStackDuration()
                    # CustomStun.SetStackDuration( real 시간 )
                
            call CustomStun.RegisterStunStackEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 스턴이 중첩으로 걸리면 발동
                
            call CustomStun.RegisterStunStartEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 스턴에 걸리면 발동[중첩 여부에 관계 없음]
                
            call CustomStun.RegisterStunTimeoutEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 스턴에 걸려있는 동안...
                ** 시스템 정밀도(SYSTEM_TIMEOUT_DELAY) 간격으로 실행됩니다
                
            call CustomStun.RegisterStunEndEvent( function 액션함수 )
                ** 이벤트 - 아무 유닛이나 걸려있던 스턴에서 풀리면 발동
                    # 시스템 정밀도 세팅값에 따라 최초 지시한 스턴 시간과 오차가 있을 수 있습니다
            
        
        # 이벤트에서 받아올 수 있는 값들!
        
            local integer 고유 스턴 ID = CustomStun.GetEventStunId()
                ** 모든 스턴 디버프는 고유한 스턴 ID를 갖습니다 (1~8191)
                ** WARNING : !!! 한 맵에서 8192개 이상의 스턴을 동시에 유지할 수 없습니다 !!!
            local unit 스턴당한유닛 = CustomStun.GetTriggerUnit()
            local unit 스턴당한유닛 = CustomStun.GetStunnedUnit()
            local unit 스턴을 건 유닛 = CustomStun.GetEventStunSource()
                ** 스턴을 건 유닛이 없을 경우 = null
            local real 스턴 총 시간 = CustomStun.GetTimeout()
            local real 스턴 지나간 시간 = CustomStun.GetElapsed()
            local real 스턴 남은 시간 = CustomStun.GetRemaining()
        
            local real 중첩 시도중인 시간(원본) = CustomStun.DefaultGetStackDuration()
            local real 중첩 시도중인 시간 = CustomStun.GetStackDuration()
            
            call CustomStun.SetStackDuration( 추가될 중첩 시간 )
*/
/********************************************************************************/
library CustomStun initializer OnMapLoad
    /*==========================================================================*/
    /* <제작자가 변경 가능한 설정들> */
    globals
        /*----------------------------------------------------------------------*/
        private constant real SYSTEM_TIMEOUT_DELAY = 0.03125
        private constant integer SYSTEM_DUMMY_ID   = 'h000'
        private constant integer SYSTEM_BUFF_ID    = 'BPSE'
        private constant player SYSTEM_DUMMY_OWNER = Player(PLAYER_NEUTRAL_PASSIVE)
        private constant real SYSTEM_DUMMY_X       = 0.0
        private constant real SYSTEM_DUMMY_Y       = 0.0
        private constant string SYSTEM_DUMMY_COMMAND = "thunderbolt"
        /*----------------------------------------------------------------------*/
    endglobals
    /*==========================================================================*/
    /* <이 밑으로 어떤 코드든 시스템에 대한 이해 없이 수정하면 큰 고통을 받게 되실 수 있습니다> */
    globals
        /*----------------------------------------------------------------------*/
        private unit SYSTEM_DUMMY = null
        /*----------------------------------------------------------------------*/
        /* 데이터 테이블과 라이브러리 전용 키 */
        private hashtable TABLE = InitHashtable()
        private key IN_KEY
        /*----------------------------------------------------------------------*/
        /* 축약 호출기 */
        private trigger T_CALL = CreateTrigger()
        private unit T_SRC = null
        private unit T_DST = null
        private real T_TIMEOUT = 0.0
        /*----------------------------------------------------------------------*/
        /* 스턴 데이터 */
        private integer array M_HNDL
        private unit array M_UCAS
        private unit array M_UTAR
        private timer array M_TIMR
        private real array M_FTIM
        private real array M_ELAP
        private real array M_DSDU
        private real array M_SDUR
        /*----------------------------------------------------------------------*/
        /* 이벤트 데이터 */
        private trigger E_STUN_NEW = CreateTrigger()
        private trigger E_STUN_BEFORE_STACK = CreateTrigger()
        private trigger E_STUN_STACK = CreateTrigger()
        private trigger E_STUN_START = CreateTrigger()
        private trigger E_STUN_TIMEOUT = CreateTrigger()
        private trigger E_STUN_END = CreateTrigger()
        /*----------------------------------------------------------------------*/
        /* 이벤트 실행 환경 */
        private integer P_STUN = 0
        /*----------------------------------------------------------------------*/
    endglobals
    /*==========================================================================*/
    /* 데이터 할당기 */
    private struct IN_INDEXER
    endstruct
    /*==========================================================================*/
    /* 이벤트 실행기 */
    private struct EVENT extends array
        /*----------------------------------------------------------------------*/
        static method FireEx takes trigger t, integer obj returns nothing
            local integer pobj = P_STUN
            set P_STUN = obj
            call TriggerEvaluate(t)
            set P_STUN = pobj
        endmethod
        /*----------------------------------------------------------------------*/
    endstruct
    /*==========================================================================*/
    /* 내부 알고리즘 */
    private struct PROC extends array
        /*----------------------------------------------------------------------*/
        static method OnStunTimeout takes nothing returns nothing
            local IN_INDEXER data = LoadInteger(TABLE,IN_KEY,GetHandleId(GetExpiredTimer()))
            local real timeout = data:M_FTIM
            local real elapsed = data:M_ELAP + SYSTEM_TIMEOUT_DELAY
            local real remaining = timeout - elapsed
            set data:M_ELAP = elapsed
            if remaining < 0.0 then
                // 이벤트 격발 - 스턴 종료
                call EVENT.FireEx(E_STUN_END,data)
                // 마감
                call UnitRemoveAbility(data:M_UTAR,SYSTEM_BUFF_ID)
                call RemoveSavedInteger(TABLE,IN_KEY,GetHandleId(data:M_TIMR))
                call RemoveSavedInteger(TABLE,IN_KEY,data:M_HNDL)
                set data:M_UCAS = null
                set data:M_UTAR = null
                call DestroyTimer(data:M_TIMR)
                set data:M_TIMR = null
                call data.destroy()
                return
            endif
            // 이벤트 격발 - 스턴 중
            call EVENT.FireEx(E_STUN_TIMEOUT,data)
        endmethod
        /*----------------------------------------------------------------------*/
        private static method OnStun takes nothing returns boolean
            local unit src = T_SRC
            local unit dst = T_DST
            local real timeout = T_TIMEOUT
            local IN_INDEXER data = LoadInteger(TABLE,IN_KEY,GetHandleId(dst))
            if data == 0 then
                set data = IN_INDEXER.create()
                set data:M_UCAS = src
                set data:M_UTAR = dst
                set data:M_FTIM = timeout
                set data:M_DSDU = 0.0
                set data:M_SDUR = 0.0
                set data:M_ELAP = 0.0
                set data:M_TIMR = CreateTimer()
                set data:M_HNDL = GetHandleId(dst)
                call SaveInteger(TABLE,IN_KEY,GetHandleId(data:M_TIMR),data)
                call SaveInteger(TABLE,IN_KEY,GetHandleId(dst),data)
                
                call IssueTargetOrder(SYSTEM_DUMMY,SYSTEM_DUMMY_COMMAND,dst)
                // 이벤트 격발 - 새 스턴
                call EVENT.FireEx(E_STUN_NEW,data)
            else
                set data:M_DSDU = timeout
                set data:M_SDUR = timeout
                // 이벤트 격발 - 중첩 직전
                call EVENT.FireEx(E_STUN_BEFORE_STACK,data)
                set data:M_FTIM = data:M_FTIM + data:M_SDUR
                // 이벤트 격발 - 중첩
                call EVENT.FireEx(E_STUN_STACK,data)
            endif
            
            // 이벤트 격발 - 스턴 시작됨
            call EVENT.FireEx(E_STUN_START,data)
            call TimerStart(data:M_TIMR,SYSTEM_TIMEOUT_DELAY,true,function thistype.OnStunTimeout)
            set src = null
            set dst = null
            return false
        endmethod
        /*----------------------------------------------------------------------*/
        private static method onInit takes nothing returns nothing
            call TriggerAddCondition(T_CALL,Condition(function thistype.OnStun))
        endmethod
        /*----------------------------------------------------------------------*/
    endstruct
    /*==========================================================================*/
    /* 제작자가 접근 가능한 인터페이스 */
    struct CustomStun extends array
        /*----------------------------------------------------------------------*/
        /* 이벤트 - 맨 처음 스턴이 걸렸으면 발동 */
        static method RegisterStunNewEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_NEW,Condition(c))
        endmethod
        /* 이벤트 - 스턴이 중첩되기 전에 발동 */
        static method RegisterStunBeforeStackEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_BEFORE_STACK,Condition(c))
        endmethod
        /* 이벤트 - 스턴이 중첩되면 발동 */
        static method RegisterStunStackEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_STACK,Condition(c))
        endmethod
        /* 이벤트 - 중첩 여부에 상관 없이 일단 뭐든 스턴이 걸리면 발동 */
        static method RegisterStunStartEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_START,Condition(c))
        endmethod
        /* 이벤트 - 스턴에 걸려있는 동안 발동 */
        static method RegisterStunTimeoutEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_TIMEOUT,Condition(c))
        endmethod
        /* 이벤트 - 스턴 지속시간이 종료되면 발동 */
        static method RegisterStunEndEvent takes code c returns triggercondition
            return TriggerAddCondition(E_STUN_END,Condition(c))
        endmethod
        /*----------------------------------------------------------------------*/
        /* 이벤트 대응 - 스턴 인스턴스 ID */
        static method GetEventStunId takes nothing returns integer
            return P_STUN
        endmethod
        /* 이벤트 대응 - 스턴을 가한 유닛 */
        static method GetEventStunSource takes nothing returns unit
            return P_STUN:M_UCAS
        endmethod
        /* 이벤트 대응 - 스턴을 받은 유닛 */
        static method GetTriggerUnit takes nothing returns unit
            return P_STUN:M_UTAR
        endmethod
        /* 이하동문 ( 보다 편한 쪽으로 사용 ) */
        static method GetStunnedUnit takes nothing returns unit
            return P_STUN:M_UTAR
        endmethod
        /* 이벤트 대응 - 총 스턴 시간 */
        static method GetTimeout takes nothing returns real
            return P_STUN:M_FTIM
        endmethod
        /* 이벤트 대응 - 지나간 스턴 시간 */
        static method GetElapsed takes nothing returns real
            return P_STUN:M_ELAP
        endmethod
        /* 이벤트 대응 - 남은 스턴 시간 */
        static method GetRemaining takes nothing returns real
            return P_STUN:M_FTIM - P_STUN:M_ELAP
        endmethod
        /* 이벤트 대응 - 스택될 시간(원본 값) */
        static method GetDefaultStackDuration takes nothing returns real
            return P_STUN:M_DSDU
        endmethod
        /* 이벤트 대응 - 스택될 시간 */
        static method GetStackDuration takes nothing returns real
            return P_STUN:M_SDUR
        endmethod
        /* 이벤트 대응 - 스택될 시간 설정 */
        static method SetStackDuration takes real dur returns nothing
            set P_STUN:M_SDUR = dur
        endmethod
        /*----------------------------------------------------------------------*/
        /* 커스텀 스턴 - (dst)유닛을 (timeout)초 동안 '추가로' 기절시킵니다 */
        static method Stun takes unit dst, real timeout returns nothing
            if GetUnitTypeId(dst) == 0 then
                return
            endif
            set T_SRC = null
            set T_DST = dst
            set T_TIMEOUT = timeout
            call TriggerEvaluate(T_CALL)
        endmethod
        /* 커스텀 스턴 - (src)유닛이 (dst)유닛을 (timeout)초 동안 '추가로' 기절시킵니다 */
        static method StunEx takes unit src, unit dst, real timeout returns nothing
            if GetUnitTypeId(dst) == 0 then
                return
            endif
            set T_SRC = src
            set T_DST = dst
            set T_TIMEOUT = timeout
            call TriggerEvaluate(T_CALL)
        endmethod
        /*----------------------------------------------------------------------*/
        // 커스텀 스턴 - (dst)유닛으로부터 스턴을 해제합니다
        static method Clear takes unit dst returns nothing
            local integer data = LoadInteger(TABLE,IN_KEY,GetHandleId(dst))
            if data == 0 then
                return
            endif
            set data:M_ELAP = 0.0
            set data:M_FTIM = 0.0
        endmethod
        // 커스텀 스턴 - (dst)유닛의 남은 스턴 시간을 가져옵니다
        static method GetUnitStunRemaining takes unit dst returns real
            local integer data = LoadInteger(TABLE,IN_KEY,GetHandleId(dst))
            if data == 0 then
                return 0.0
            endif
            return data:M_FTIM - data:M_ELAP
        endmethod
        // 커스텀 스턴 - (dst)유닛의 남은 스턴 시간을 설정합니다
        static method SetUnitStunRemaining takes unit dst, real dur returns boolean
            local integer data = LoadInteger(TABLE,IN_KEY,GetHandleId(dst))
            if data == 0 then
                return false
            endif
            set data:M_FTIM = data:M_ELAP + dur
            return true
        endmethod
        // 커스텀 스턴 - (dst)유닛의 남은 스턴 시간을 추가(음수면 감소)합니다
        static method AddUnitStunRemaining takes unit dst, real delta returns boolean
            local integer data = LoadInteger(TABLE,IN_KEY,GetHandleId(dst))
            if data == 0 then
                return false
            endif
            set data:M_FTIM = data:M_FTIM + delta
            return true
        endmethod
        /*----------------------------------------------------------------------*/
    endstruct
    /*==========================================================================*/
    /* 시스템 더미 유닛 생성 */
    private function OnMapLoad takes nothing returns nothing
        set SYSTEM_DUMMY = CreateUnit( SYSTEM_DUMMY_OWNER, SYSTEM_DUMMY_ID, /*
        */ SYSTEM_DUMMY_X, SYSTEM_DUMMY_Y, 270.0 )
        call UnitAddAbility(SYSTEM_DUMMY,'Avul')
        call UnitAddAbility(SYSTEM_DUMMY,'Aloc')
    endfunction
    /*==========================================================================*/
endlibrary
/********************************************************************************/
