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

    // ---
    // ## 🕒 틱
    // > ### [MUI](<Multi-unit Instanceability>)([관련 문서](https://www.hiveworkshop.com/threads/mui-triggers-with-waits.218354/)) 목적으로 사용하기 위한 [타이머](<type timer extends agent>) 유틸리티
    // ---
    // ##### ℹ️ 틱은 1 ~ [8191](<배열 크기 한계>)까지의 핸들값을 가지므로 배열의 인덱스로 활용 가능합니다
    // ##### ℹ️ null check를 수행하려면 `== 0`을 사용할 수 있습니다
    // ##### ℹ️ 파괴 시 [일정 딜레이](<constant real DISPOSAL_DELAY>) 후 소멸하여 의도치 않은 동작을 방지합니다
    // ##### ⚠️ 수천 개의 탄막과 같은 연출 구현에는 적합하지 않습니다 ([8191](<배열 크기 한계>)개 제한)
    // ##### 🚨 핸들값을 직접 할당하는 접근 방식은 사용하지 마세요! 예: `local tick t = 3`
    // ---
    struct tick extends array
    endstruct

    // ---
    // ## 🕒 틱 - 생성
    // > ### 새로운 틱 타이머를 생성합니다
    // ---
    // ##### ⚠️ 동시에 [8192](<배열 크기 한계>)개 이상의 틱 타이머는 존재할 수 없으며, 이 경우 [0](<=null>)을 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - tick 생성된 틱 타이머
    // ---
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

    // ---
    // ## 🕒 틱 - 생성 (커스텀 데이터 포함)
    // > ### 새로운 틱 타이머를 생성합니다 ([커스텀 정수 데이터](<integer dataValue>) 포함) 
    // ---
    // ##### ⚠️ 동시에 [8192](<배열 크기 한계>)개 이상의 틱 타이머는 존재할 수 없으며, 이 경우 [0](<=null>)을 반환합니다
    // ---
    // takes
    // - integer dataValue 생성 시 설정할 커스텀 정수 데이터
    // returns
    // - tick 생성된 틱 타이머
    // ---
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

    // ---
    // ## 🕒 틱 - 경과 시간 조회
    // > ### [틱](<tick whichTick>) 객체의 실행 주기 중 경과 시간을 반환합니다
    // ---
    // takes
    // - tick whichTick 경과 시간을 조회할 틱 객체
    // returns
    // - real 경과 시간 (초)
    // ---
    function TickGetElapsed takes tick whichTick returns real
        return TimerGetElapsed(TIMER[whichTick])
    endfunction

    // ---
    // ## 🕒 틱 - 남은 시간 조회
    // > ### [틱](<tick whichTick>) 객체의 실행 주기 중 남은 시간을 반환합니다
    // ---
    // takes
    // - tick whichTick 남은 시간을 조회할 틱 객체
    // returns
    // - real 남은 시간 (초)
    // ---
    function TickGetRemaining takes tick whichTick returns real
        return TimerGetRemaining(TIMER[whichTick])
    endfunction

    // ---
    // ## 🕒 틱 - 실행 주기 조회
    // > ### [틱](<tick whichTick>) 객체의 실행 주기를 반환합니다
    // ---
    // takes
    // - tick whichTick 실행 주기를 조회할 틱 객체
    // returns
    // - real 실행 주기 (초)
    // ---
    function TickGetTimeout takes tick whichTick returns real
        return TimerGetTimeout(TIMER[whichTick])
    endfunction

    // ---
    // ## 🕒 틱 - 일시 정지
    // > ### 실행 중인 [틱](<tick whichTick>) 객체를 일시 정지합니다
    // ---
    // ##### ⚠️ 실행하지 않은 [틱](<tick whichTick>)을 일시 정지할 경우 예상하지 못한 문제가 발생할 수 있습니다
    // ---
    // takes
    // - tick whichTick 일시 정지할 틱 객체
    // returns
    // - nothing
    // ---
    function TickPause takes tick whichTick returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        call PauseTimer(TIMER[whichTick])
    endfunction

    // ---
    // ## 🕒 틱 - 재개
    // > ### 일시 정지된 [틱](<tick whichTick>) 객체를 재개합니다
    // ---
    // ##### 🚨 일시 정지 상태가 아닌 [틱](<tick whichTick>)을 재개할 경우 페이탈 오류가 발생합니다
    // ---
    // takes
    // - tick whichTick 재개할 틱 객체
    // returns
    // - nothing
    // ---
    function TickResume takes tick whichTick returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        call ResumeTimer(TIMER[whichTick])
    endfunction

    // ---
    // ## 🕒 틱 - 실행
    // > ### [틱](<tick whichTick>) 객체가 지정한 [시간](<real timeout>) 간격으로 [(반복하여/한 번만)](<boolean periodic>) 특정 [함수](<code callback>)를 실행하도록 설정합니다
    // ---
    // ##### ℹ️ [null](<code callback>) 입력 시 아무런 함수도 실행하지 않도록 설정할 수 있습니다
    // ---
    // takes
    // - tick whichTick 실행할 틱 객체
    // - real timeout 실행될 시간 (초)
    // - boolean periodic 반복 실행 여부
    // - code callback 실행할 함수
    // returns
    // - nothing
    // ---
    function TickStart takes tick whichTick, real timeout, boolean periodic, code callback returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        call TimerStart(TIMER[whichTick], timeout, periodic, callback)
    endfunction

    // ---
    // ## 🕒 틱 - 반복 실행
    // > ### [틱](<tick whichTick>) 객체가 일정 [시간](<real timeout>) 간격으로 [함수](<code callback>)를 반복 실행하도록 설정합니다
    // ---
    // ##### ℹ️ [null](<code callback>) 입력 시 아무런 함수도 실행하지 않도록 설정할 수 있습니다
    // ---
    // takes
    // - tick whichTick 반복 실행할 틱 객체
    // - real timeout 실행 간격 (초)
    // - code callback 실행할 함수
    // returns
    // - nothing
    // ---
    function TickPeriodic takes tick whichTick, real timeout, code callback returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        call TimerStart(TIMER[whichTick], timeout, true, callback)
    endfunction

    // ---
    // ## 🕒 틱 - 한 번 실행
    // > ### [틱](<tick whichTick>) 객체가 일정 [시간](<real timeout>) 후 [함수](<code callback>)를 실행하도록 설정합니다
    // ---
    // ##### ℹ️ [null](<code callback>) 입력 시 아무런 함수도 실행하지 않도록 설정할 수 있습니다
    // ---
    // takes
    // - tick whichTick 실행할 틱 객체
    // - real timeout 실행될 시간 (초)
    // - code callback 실행될 함수
    // returns
    // - nothing
    // ---
    function TickOnce takes tick whichTick, real timeout, code callback returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        call TimerStart(TIMER[whichTick], timeout, false, callback)
    endfunction

    // ---
    // ## 🕒 틱 - 파괴
    // > ### [틱](<tick whichTick>) 객체를 파괴합니다.
    // ---
    // ##### ℹ️ 파괴된 틱 타이머는 [일정 딜레이](<constant real DISPOSAL_DELAY>) 후 완전히 소멸됩니다
    // ---
    // takes
    // - tick whichTick 파괴할 틱 객체
    // returns
    // - nothing
    // ---
    function TickDestroy takes tick whichTick returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        set ENABLE[whichTick] = false
        call TimerStart(TIMER[whichTick], DISPOSAL_DELAY, false, function dispose)
    endfunction

    // ---
    // ## 🕒 틱 - 커스텀 정수 데이터 조회
    // > ### [틱](<tick whichTick>) 객체에 저장된 커스텀 정수 데이터를 반환합니다
    // ---
    // ##### ℹ️ 반환값은 틱 객체에 설정된 커스텀 정수 데이터입니다. 값이 설정되지 않았다면 기본값 0을 반환합니다
    // ---
    // takes
    // - tick whichTick 조회할 틱 객체
    // returns
    // - integer 저장된 커스텀 정수 데이터
    // ---
    function TickGetValue takes tick whichTick returns integer
        return VALUE[whichTick]
    endfunction

    // ---
    // ## 🕒 틱 - 커스텀 정수 데이터 설정
    // > ### [틱](<tick whichTick>) 객체에 [커스텀 정수 데이터](<integer dataValue>)를 설정합니다
    // ---
    // ##### ℹ️ 활성화되지 않은 틱 객체에 값을 설정하려는 경우, 함수는 아무 작업도 수행하지 않습니다
    // ---
    // takes
    // - tick whichTick 설정할 틱 객체
    // - integer dataValue 설정할 커스텀 정수 값
    // returns
    // - nothing
    // ---
    function TickSetValue takes tick whichTick, integer dataValue returns nothing
        if not ENABLE[whichTick] then
            return
        endif

        set VALUE[whichTick] = dataValue
    endfunction

    // ---
    // ## 🕒 틱 - 트리거 또는 함수를 작동시킨 틱
    // > ### 트리거 또는 함수를 작동시킨 틱 타이머를 반환합니다
    // ---
    // ##### ℹ️ 트리거 또는 함수가 틱에 의해 작동되지 않은 경우 [0](<=null>)을 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - tick 만료된 틱 객체 또는 [0](<=null>)
    // ---
    function GetExpiredTick takes nothing returns tick
        return LoadInteger(TABLE, 0, GetHandleId(GetExpiredTimer()))
    endfunction

    // ---
    // ## 🕒 틱 - 타이머 핸들 조회
    // > ### [틱](<tick whichTick>) 의 내부 타이머 핸들을 반환합니다
    // ---
    // ##### 🚨 이 함수로 취득한 내부 타이머를 임의로 조작하거나 파괴할 경우 틱 시스템 전체가 붕괴할 수 있습니다!
    // ---
    // takes
    // - tick whichTick 조회할 틱 객체
    // returns
    // - timer 내부 타이머 객체
    // ---
    function TickGetTimer takes tick whichTick returns timer
        return TIMER[whichTick]
    endfunction

endlibrary
