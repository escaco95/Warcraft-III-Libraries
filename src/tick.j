// ---
// # Tick 라이브러리
//
// > 이 라이브러리는 게임 내 반복적인 이벤트와 타이머 기반 작업을 효율적으로 처리하기 위한
// > 인덱스화된 타이머 시스템을 제공합니다. `tick`은 배열 인덱스로 활용할 수 있어, 
// > 복잡한 타이머 관리 작업을 간소화하고 성능을 향상시킵니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [tick.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/tick.j)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-02**: 초기 릴리스. 인덱스화된 타이머 관리 기능 구현.
//
// ## 주요 기능:
// - **틱 타이머 생성 및 관리**: 새로운 틱 타이머를 생성하고, 이를 효율적으로 관리.
// - **틱 타이머 상태 조회**: 틱 타이머의 경과 시간, 남은 시간, 전체 실행 시간을 조회.
// - **틱 타이머 제어**: 타이머를 일시 정지하거나 재개하고, 반복적이거나 단일 실행으로 설정.
// - **틱 타이머 파괴**: 사용이 끝난 타이머를 안전하게 파괴, 메모리 누수를 방지.
//
// ## 주요 상수 및 변수:
// - `DISPOSAL_DELAY`: 파괴된 틱이 완전 소멸되기까지의 딜레이(초).
// - `TICK_QUANTITY`: 미리 생성한 타이머 수량.
//
// ## 활용 시나리오:
// - 주기적인 게임 이벤트를 관리할 때 (예: 매 초마다 특정 효과를 발동).
// - 여러 타이머를 동시에 관리해야 할 때, 효율적인 인덱스 관리를 통해 성능을 최적화.
// - 특정 유닛이나 개체가 일정 시간 후에 특정 행동을 수행해야 할 때 (예: 지연된 폭발 효과).
// ---
library tick initializer onInit

    private struct TICKINDEXER
    endstruct

    globals
        // 파괴된 틱이 완전 소멸되기까지의 딜레이(초)
        private constant real DISPOSAL_DELAY = 5.00
        // 미리 생성한 타이머 수량
        private constant integer TICK_QUANTITY = 1024

        private hashtable TABLE = InitHashtable()

        private boolean array ENABLE
        private timer array TIMER
        private integer array VALUE
    endglobals

    private function onInit takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > TICK_QUANTITY
            set TIMER[i] = CreateTimer()
            call SaveInteger(TABLE, 0, GetHandleId(TIMER[i]), i)
            set i = i + 1
        endloop
    endfunction

    private function dispose takes nothing returns nothing
        local TICKINDEXER index = LoadInteger(TABLE, 0, GetHandleId(GetExpiredTimer()))
        
        set VALUE[index] = 0

        call index.destroy()
    endfunction

    // ## 틱 인스턴스
    // ---
    // ℹ️ 인덱스화된 타이머 객체입니다.
    // ℹ️ 타이머와 달리 1 ~ 8191까지의 핸들값을 가지므로 배열의 인덱스로 활용 가능합니다.
    // ℹ️ 만약 null check 를 하고 싶다면 `== 0` 비교를 사용할 수 있습니다.
    // ℹ️ 틱은 의도치 않은 동작의 발생을 방지하기 위해, 파괴 시 딜레이(`DISPOSAL_DELAY`)를 두고 소멸합니다.
    // ⚠️ 즉, 수천개에 달하는 탄막과 같은 연출 구현에는 적합하지 않습니다. (8191개로 커버 안 됨)
    // 🚨 이런 식의 접근은 절대 자제해 주세요! `local tick t = 3`
    struct tick extends array
    endstruct

    // ## 틱 - 새로운 틱 타이머를 생성합니다.
    // ℹ️ 커스텀 정수 데이터는 0으로 초기화됩니다.
    function TickCreate takes nothing returns tick
        local tick this = TICKINDEXER.create()

        if TIMER[this] == null then
            set TIMER[this] = CreateTimer()
            call SaveInteger(TABLE, 0, GetHandleId(TIMER[this]), this)
        endif
        set VALUE[this] = 0

        set ENABLE[this] = true
        return this
    endfunction

    // ## 틱 - 새로운 틱 타이머를 생성합니다. (커스텀 정수 데이터와 함께)
    function TickCreateEx takes integer dataValue returns tick
        local tick this = TICKINDEXER.create()

        if TIMER[this] == null then
            set TIMER[this] = CreateTimer()
            call SaveInteger(TABLE, 0, GetHandleId(TIMER[this]), this)
        endif
        set VALUE[this] = dataValue

        set ENABLE[this] = true
        return this
    endfunction

    // ## 틱 - 틱 타이머의 현재 경과 시간을 가져옵니다.
    function TickGetElapsed takes tick this returns real
        return TimerGetElapsed(TIMER[this])
    endfunction

    // ## 틱 - 틱 타이머의 남은 시간을 가져옵니다.
    function TickGetRemaining takes tick this returns real
        return TimerGetRemaining(TIMER[this])
    endfunction

    // ## 틱 - 틱 타이머의 전체 실행 시간을 가져옵니다.
    function TickGetTimeout takes tick this returns real
        return TimerGetTimeout(TIMER[this])
    endfunction

    // ## 틱 - 틱 타이머를 일시 정지합니다.
    function TickPause takes tick this returns nothing
        if not ENABLE[this] then
            return
        endif

        call PauseTimer(TIMER[this])
    endfunction

    // ## 틱 - 틱 타이머를 재개합니다.
    function TickResume takes tick this returns nothing
        if not ENABLE[this] then
            return
        endif

        call ResumeTimer(TIMER[this])
    endfunction

    // ## 틱 - 틱 타이머를 실행합니다.
    function TickStart takes tick this, real timeout, boolean periodic, code callback returns nothing
        if not ENABLE[this] then
            return
        endif

        call TimerStart(TIMER[this], timeout, periodic, callback)
    endfunction

    // ## 틱 - 틱 타이머를 반복 실행합니다.
    function TickPeriodic takes tick this, real timeout, code callback returns nothing
        if not ENABLE[this] then
            return
        endif

        call TimerStart(TIMER[this], timeout, true, callback)
    endfunction

    // ## 틱 - 틱 타이머를 한 번 실행합니다.
    function TickOnce takes tick this, real timeout, code callback returns nothing
        if not ENABLE[this] then
            return
        endif

        call TimerStart(TIMER[this], timeout, false, callback)
    endfunction

    // ## 틱 - 틱 타이머를 파괴합니다.
    function TickDestroy takes tick this returns nothing
        if not ENABLE[this] then
            return
        endif

        set ENABLE[this] = false
        call TimerStart(TIMER[this], DISPOSAL_DELAY, false, function dispose)
    endfunction

    // ## 틱 - 커스텀 정수 데이터를 가져옵니다.
    function TickGetValue takes tick this returns integer
        return VALUE[this]
    endfunction

    // ## 틱 - 커스텀 정수 데이터를 설정합니다.
    function TickSetValue takes tick this, integer dataValue returns nothing
        if not ENABLE[this] then
            return
        endif

        set VALUE[this] = dataValue
    endfunction

    // ## 틱 - 트리거 또는 함수를 작동시킨 틱 타이머를 가져옵니다.
    // ℹ️ 트리거 또는 함수가 틱에 의해 작동되지 않은 경우, `0 (=null)`을 반환합니다.
    function GetExpiredTick takes nothing returns tick
        return LoadInteger(TABLE, 0, GetHandleId(GetExpiredTimer()))
    endfunction

    // ## 틱 - 틱 타이머를 구성하는 내부 핸들을 가져옵니다.
    // ℹ️ 이 함수는 주로 틱에 대한 타이머 창을 만들기 위한 목적으로 활용됩니다.
    // 🚨 이 함수로 취득한 내부 타이머를 임의로 조작하거나 파괴할 경우 틱 시스템 전체가 붕괴할 수 있습니다!
    function TickGetTimer takes tick this returns timer
        return TIMER[this]
    endfunction

endlibrary
