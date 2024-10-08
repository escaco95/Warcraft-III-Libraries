// ---
// # Periodic 라이브러리
//
// > 이 라이브러리는 주기적으로 코드를 실행할 수 있는 트리거를 생성하는 기능을 제공합니다. 
// > 특정 시간이 지나면 주어진 코드가 반복적으로 실행되도록 설정할 수 있으며, 비활성화된 상태로 트리거를 생성하는 기능도 포함됩니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [periodic.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/periodic.j)
//
// ## 버전
// - **Version**: 20240905.0
//
// ## Changelog
// - **2024-09-05**: 초기 릴리스. 주기적 코드 실행 트리거 생성 기능 제공.
//
// ## 주요 기능:
// - **주기적 코드 실행**: 지정된 시간 간격으로 코드가 반복 실행되도록 설정할 수 있는 트리거 생성.
// - **비활성화된 트리거 생성**: 트리거를 비활성화된 상태로 생성하고 나중에 활성화할 수 있는 기능 제공.
//
// ## 활용 시나리오:
// - 특정 이벤트가 일정 시간 간격으로 반복적으로 발생해야 할 때 (예: 주기적인 상태 변화, 체력 회복 등).
// - 특정 코드를 일시적으로 비활성화하고, 나중에 필요할 때 다시 활성화하여 실행하고 싶을 때.
//
// ## 문제해결:
// - 트리거가 예상대로 동작하지 않으면, 트리거가 올바르게 생성되고 활성화되었는지 확인하세요.
// ---
library Periodic

    globals
        // 마지막으로 생성된 트리거를 저장하는 변수
        private trigger lastCreatedTrigger = null
    endglobals

    // ## 주기적 트리거 생성 함수
    // 주어진 시간 간격(`interval`)마다 주어진 코드(`action`)가 반복적으로 실행되는 트리거를 생성합니다.
    function CreatePeriodic takes real interval, code action returns trigger
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddAction( lastCreatedTrigger, action )
        call TriggerRegisterTimerEvent( lastCreatedTrigger, interval, true )
        return lastCreatedTrigger
    endfunction

    // ## 비활성화된 주기적 트리거 생성 함수
    // 주어진 시간 간격(`interval`)마다 주어진 코드(`action`)가 실행되지만, 비활성화된 상태로 트리거를 생성합니다.
    // 이후에 수동으로 트리거를 활성화해야 합니다.
    function CreatePeriodicDisabled takes real interval, code action returns trigger
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddAction( lastCreatedTrigger, action )
        call TriggerRegisterTimerEvent( lastCreatedTrigger, interval, true )
        call DisableTrigger( lastCreatedTrigger )
        return lastCreatedTrigger
    endfunction

    // ## 단일 실행 트리거 생성 함수
    // 주어진 시간(`delay`)이 지난 후 한 번만 주어진 코드(`action`)를 실행하는 트리거를 생성합니다.
    function CreateSingle takes real delay, code action returns trigger
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddAction( lastCreatedTrigger, action )
        call TriggerRegisterTimerEvent( lastCreatedTrigger, delay, false )
        return lastCreatedTrigger
    endfunction

endlibrary
