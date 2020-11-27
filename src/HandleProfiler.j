/*
    통합 핸들관리 프로파일러
        - HandleProfiler -
            Version 201128.0
            
            
    유즈맵에서 점유(=사용)한 최대 핸들값을 추적하는 프로파일러입니다.
    핸들의 증가 추세를 확인하여, 누수의 원인이 되는 트리거 또는 상황을 특정할 수 있습니다.
    
    
    * 사용 팁 *
    
    
        - 특정 상황에서, 최대 핸들값이 증가함
        
            예시)) 유닛이 어딘가에 입장, 스킬 사용 또는 공격 등
            = 해당 이벤트와 관련된 트리거에서 폭발적 핸들값 증가가 유발되는 것으로 추측됩니다.
            
            
        - 지속적으로 최대 핸들값이 증가함
        
            예시)) 1초마다 핸들값이 4씩 올라감 등등
            = 지속적으로 실행되는 이벤트, 또는 타이머와 관련된 트리거가 원인으로 추측됩니다.
            
    
    * 맵 상태 판단하기 *
        (최소 30분 이상의 장기 플레이의 관찰 결과를 기준으로 합니다)
        
        
        [정상]
            게임플레이 초반 : 빠른 속도로 핸들 최대가 갱신되다가... 
            게임플레이 후반 : 갱신 간격이 확연히 느려지거나 멈춤.
            
            
        [치명적 핸들 누수 존재]
            최대 핸들값이 끝없이 증가하다 게임 중후반부에 페이탈 발생.
            
        
        [=null 누수 존재]
            최대 핸들값이 끝없이 증가하나, 장기간 플레이에도 페이탈이 발생하지 않음.
            
        
    * 맵 분석용 참고 자료 *
    
    
        1048576 = 최소 핸들값. (0x100000)
            모든 핸들값은 1048576(0x100000)부터 하나씩 배정됩니다.
            
        
        초기 핸들값 = 맵 로딩 직후의 핸들값
            사전에 배치되어 있는 오브젝트, 트리거들이 차지하는 핸들값
    
*/
library HandleProfiler

    globals
        /* 맵 로딩 이후 ~ INITIAL_HANDLE_TIMEOUT(초)
            사이에 생겨난 모든 핸들을 '초기 핸들값'으로 칩니다. */
        private constant real INITIAL_HANDLE_TIMEOUT = 1.0
        private constant real HANDLE_TIMEOUT = 1.0
        
        /* 분석 결과를 화면에 표시합니다 */
        private boolean SHOW_MSG = DEBUG_MODE
        /* 분석 결과를 간단하게 표시합니다 */
        private boolean SIMPLE_MSG = true
        
        private constant integer HANDLE_OFFSET = 0x100000
        
        private integer INITIAL_HANDLE = HANDLE_OFFSET
        private integer INITIAL_INSTANCE = 0
        
        private integer NEWEST_HANDLE = HANDLE_OFFSET
        private integer NEWEST_INSTANCE = 0
        
        private integer LATEST_HANDLE = HANDLE_OFFSET
        private integer LATEST_INSTANCE = 0
        
        private integer COUNTER_REUSE = 0
        private integer COUNTER_ALLOC = 1
        private integer COUNTER_BOTH = 1
        
        private constant real HOLDER_X = -3.141592
        private constant real HOLDER_Y = 3.141592
        
        private location HANDLE_HOLDER = null
        private trigger TRIG_INITIAL_HANDLE = CreateTrigger()
        private timer HANDLE_TIMER = CreateTimer()
    endglobals
    
    struct HandleProfiler extends array
        
        static method operator ShowMessage= takes boolean f returns nothing
            set SHOW_MSG = f
        endmethod
        static method operator ShowMessage takes nothing returns boolean
            return SHOW_MSG
        endmethod
        
        static method operator HandleOffset takes nothing returns integer
            return HANDLE_OFFSET
        endmethod
        
        static method operator InitialHandle takes nothing returns integer
            return INITIAL_HANDLE
        endmethod
        static method operator InitialInstance takes nothing returns integer
            return INITIAL_INSTANCE
        endmethod
        
        static method operator NewestHandle takes nothing returns integer
            return NEWEST_HANDLE
        endmethod
        static method operator NewestInstance takes nothing returns integer
            return NEWEST_INSTANCE
        endmethod
        
        static method operator LatestHandle takes nothing returns integer
            return LATEST_HANDLE
        endmethod
        static method operator LatestInstance takes nothing returns integer
            return LATEST_INSTANCE
        endmethod
        
    endstruct
    
    private struct ProfileAction extends array
        private static method onHandleTimeout takes nothing returns nothing
            local location l = Location(HOLDER_X,HOLDER_Y)
            
            set NEWEST_HANDLE = GetHandleId(HANDLE_HOLDER)
            set NEWEST_INSTANCE = NEWEST_HANDLE - INITIAL_HANDLE
            
            call RemoveLocation(HANDLE_HOLDER)
            set HANDLE_HOLDER = l
            set l = null
            
            set COUNTER_BOTH = COUNTER_BOTH + 1
            if NEWEST_HANDLE > LATEST_HANDLE then
                set COUNTER_ALLOC = COUNTER_ALLOC + 1
                
                set LATEST_HANDLE = NEWEST_HANDLE
                set LATEST_INSTANCE = LATEST_HANDLE - INITIAL_HANDLE
            else
                set COUNTER_REUSE = COUNTER_REUSE + 1
            endif
            
            if SHOW_MSG then
                if not SIMPLE_MSG then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, /*
                    */ "최근 핸들값: " + I2S(NEWEST_HANDLE) + "\n" + /*
                    */ "최근 개체수: " + I2S(NEWEST_INSTANCE-1) + "\n" + /*
                    */ "최대 핸들값: " + I2S(LATEST_HANDLE) + "\n" + /*
                    */ "최대 개체수: " + I2S(LATEST_INSTANCE-1) + "\n" + /*
                    */ "재사용 비율: " + R2S(COUNTER_REUSE * 100.0 / COUNTER_BOTH) + "%" )
                else
                    call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, /*
                    */ "최대 개체수: " + I2S(LATEST_INSTANCE-1) + " (" + R2S(COUNTER_REUSE * 100.0 / COUNTER_BOTH) + "% 재사용됨)")
                endif
            endif
            
        endmethod
        private static method onInitialHandleTimeout takes nothing returns nothing
            set HANDLE_HOLDER = Location(HOLDER_X,HOLDER_Y)
            set INITIAL_HANDLE = GetHandleId(HANDLE_HOLDER)
            set INITIAL_INSTANCE = INITIAL_HANDLE - HANDLE_OFFSET
            
            set NEWEST_HANDLE = GetHandleId(HANDLE_HOLDER)
            set NEWEST_INSTANCE = NEWEST_HANDLE - INITIAL_HANDLE
            
            set LATEST_HANDLE = GetHandleId(HANDLE_HOLDER)
            set LATEST_INSTANCE = LATEST_HANDLE - INITIAL_HANDLE
            
            if SHOW_MSG then
                call DisplayTextToPlayer(GetLocalPlayer(), 0.0, 0.0, /*
                */ "핸들 오프셋: " + I2S(HANDLE_OFFSET) + "\n" + /*
                */ "초기 핸들값: " + I2S(INITIAL_HANDLE) + "\n" + /*
                */ "초기 개체수: " + I2S(INITIAL_INSTANCE-1) )
            endif
            call TimerStart(HANDLE_TIMER,HANDLE_TIMEOUT,true,function thistype.onHandleTimeout)
        endmethod
        private static method onInit takes nothing returns nothing
            local trigger trig = CreateTrigger()
            call TriggerAddAction(trig,function thistype.onInitialHandleTimeout)
            call TriggerRegisterTimerEvent(trig,INITIAL_HANDLE_TIMEOUT,false)
            set trig = null
        endmethod
    endstruct
    
endlibrary
