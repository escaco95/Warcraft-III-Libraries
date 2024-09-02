// ---
// # HandleProfiler 라이브러리
//
// > 이 라이브러리는 유즈맵에서 점유한 최대 핸들값을 추적하는 프로파일러를 제공합니다.
// > 핸들의 증가 추세를 확인하여, 핸들 누수의 원인이 되는 트리거나 상황을 특정할 수 있습니다.
// > 이를 통해 게임 내 안정성을 확보하고, 퍼포먼스를 최적화할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [handle-profiler.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/handle-profiler.j)
//
// ## 버전
// - **Version**: 201128.0
//
// ## Changelog
// - **2020-11-28**: 초기 릴리스. 핸들값 추적 및 프로파일링 기능 구현.
//
// ## 주요 기능:
// - **핸들값 추적**: 맵에서 사용된 최대 핸들값을 지속적으로 추적하여, 핸들 누수의 가능성을 진단.
// - **핸들 증가 추세 모니터링**: 핸들의 증가 추세를 확인하여, 특정 상황에서의 폭발적인 핸들값 증가를 감지.
// - **핸들 재사용 비율 계산**: 핸들의 재사용 여부를 감지하고, 재사용 비율을 계산하여 최적화에 도움.
// - **실시간 메시지 출력**: 분석 결과를 실시간으로 화면에 표시하여, 개발자가 즉시 대응할 수 있도록 지원.
//
// ## 주요 상수 및 변수:
// - `INITIAL_HANDLE_TIMEOUT`: 맵 로딩 후 초기 핸들값으로 간주하는 시간(초).
// - `HANDLE_TIMEOUT`: 핸들값 갱신 주기(초).
// - `HANDLE_OFFSET`: 최소 핸들값. 모든 핸들값은 이 값부터 시작.
// - `SHOW_MSG`: 분석 결과를 화면에 표시할지 여부.
// - `SIMPLE_MSG`: 간단한 형식으로 메시지를 표시할지 여부.
//
// ## 활용 시나리오:
// - 게임 내 특정 이벤트(예: 유닛 입장, 스킬 사용)와 연관된 핸들 누수를 확인할 때.
// - 장기적인 플레이에서 핸들값의 증가 추세를 모니터링하여, 게임 안정성을 평가할 때.
// - 맵 로딩 시 초기 핸들값을 기록하여, 기본 리소스 소모량을 측정하고 최적화할 때.
// ---
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
