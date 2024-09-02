// ---
// # TICK_STRUCT 매크로
//
// > 이 매크로는 반복적인 타이머 기반 작업을 쉽게 구현할 수 있도록 설계된 템플릿입니다. 
// > 매크로는 일정 시간 간격으로 실행되는 작업을 자동으로 관리하며, 각 단계의 상태와 경과 시간을 추적합니다. 
// > 사용자는 특정 조건에 따라 타이머를 시작, 중지하거나 각 실행 단계에서 원하는 작업을 수행할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [tick-struct.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/tick-struct.j)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-02**: 초기 릴리스.
//
// ## 사용 방법
// - `TICK_STRUCT` 매크로를 사용할 때는 `TIMEOUT` 파라미터를 설정하여, 타이머가 실행되는 시간 간격(초)을 지정해야 합니다.
// - 이 매크로를 사용하는 구조체 내에서 사용자 정의 메서드(`onStart`, `onStage`, `onStop`)를 구현하여 특정 조건에 따라 타이머의 동작을 제어할 수 있습니다.
//
// ## 제공 기능 및 인터페이스
// - `timeout`: 매크로 실행 시 지정된 시간 간격입니다. 각 `onStage` 호출 사이의 시간(초)을 나타냅니다.
// - `new`: 마지막으로 생성된 구조체 인스턴스를 나타내는 변수입니다.
// - `stage`: 타이머가 몇 번째 호출되는지를 나타내는 단계 값입니다. 각 호출마다 1씩 증가합니다.
// - `elapsed`: 타이머가 시작된 후 경과된 시간을 나타냅니다. 각 호출마다 `timeout` 값만큼 증가합니다.
// - `.wait()`: `stage` 와 `elapsed` 값을 진행시키지 않은 것으로 간주합니다.
//
// ## 사용자 정의 메서드 작성
// - `onStart`: 타이머가 처음 시작될 때 호출되는 메서드입니다. 이 메서드를 통해 초기화 작업이나 특정 조건 설정을 수행할 수 있습니다. 
//   이 메서드는 선택 사항이며, 필요할 경우에만 구현합니다.
//
// - `onStage`: 타이머가 반복적으로 호출될 때 실행되는 메서드입니다. 
//   이 메서드는 반환값으로 `boolean`을 가지며, `true`를 반환하면 타이머를 중지합니다. 
//   예를 들어, 특정 조건이 충족되면(예: 타이머가 N번 호출되었을 때, 유닛이 사망했을 때 등) `true`를 반환하여 타이머를 멈출 수 있습니다.
//   이 메서드는 각 단계에서 실행할 반복 작업을 정의하는 데 사용됩니다.
//
// - `onStop`: 타이머가 중지될 때 호출되는 메서드입니다. 이 메서드를 통해 리소스 해제나 종료 처리를 수행할 수 있습니다. 
//   이 메서드는 선택 사항이며, 필요할 경우에만 구현합니다.
//
// ## 사용 예시: KnightTripleAttack 구조체
// - `KnightTripleAttack`는 `TICK_STRUCT` 매크로를 사용하여 `0.10`초 간격으로 실행되는 공격을 구현합니다.
// - `onStage` 메서드는 타이머가 4번 호출되거나, `caster` 또는 `target` 유닛이 죽었을 때 타이머를 중지하도록 구현됩니다. 
//   각 호출마다 `caster`가 `target`에게 100의 피해를 줍니다.
// - `onStop` 메서드는 타이머가 중지될 때 유닛 참조를 해제하여 메모리 누수를 방지합니다.
//
// ## 예시 코드 분석
// ```
// struct KnightTripleAttack extends array
//
//     unit caster
//     unit target
//     
//     private method onStop takes nothing returns nothing
//         set .caster = null
//         set .target = null
//     endmethod
//     
//     private method onStage takes nothing returns boolean
//         if .stage == 4 or not UnitAlive(.caster) or not UnitAlive(.target) then
//             return true
//         endif
//         call SuspendDamageEvent()
//         call UnitDamageTarget(.caster, .target, 100.0, true, false, ATTACK_TYPE_MELEE, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_METAL_MEDIUM_CHOP)
//         call ResumeDamageEvent()
//         return false
//     endmethod
//     
//     //! runtextmacro TICK_STRUCT("0.10")
//     
// endstruct
// ```
// - 위 코드에서 `KnightTripleAttack` 구조체는 `0.10`초 간격으로 타겟 유닛에 피해를 주는 작업을 수행합니다.
// - `onStage` 메서드가 호출될 때마다 `stage`가 증가하며, 특정 조건(유닛 사망, 4단계 도달)에 따라 타이머가 중지됩니다.
// - `onStop` 메서드는 타이머가 중지될 때 유닛 참조를 해제합니다.
//
// 이 매크로는 반복적인 타이머 기반 작업을 간결하게 구현할 수 있도록 돕습니다. 
// 개발자는 `onStart`, `onStage`, `onStop` 메서드를 적절히 구현하여 원하는 기능을 추가할 수 있습니다.
// ---
//! textmacro TICK_STRUCT takes TIMEOUT
    private method wait takes nothing returns nothing
        set .stage = .stage - 1
        set .elapsed = .elapsed - .timeout
    endmethod

    static constant real timeout = $TIMEOUT$
    static thistype new

    integer stage
    real elapsed
    
    static method create takes nothing returns thistype
        set new = TickCreate()
        set new.stage = 0
        set new.elapsed = 0
        static if thistype.onStart.exists then
            call new.onStart()
        endif
        return new
    endmethod
    
    private method stop takes nothing returns nothing
        static if thistype.onStop.exists then
            call this.onStop()
        endif
        call TickDestroy(this)
    endmethod
    
    private static method tickCallback takes nothing returns nothing
        local thistype this = GetExpiredTick()
        set .stage = .stage + 1
        set .elapsed = .elapsed + .timeout
        static if thistype.onStage.exists then
            if .onStage() then
                call .stop()
                return
            endif
        endif
    endmethod
    
    method start takes nothing returns nothing
        static if thistype.onStart.exists then
            call .onStart()
        endif
        call TickPeriodic(this, timeout, function thistype.tickCallback)
    endmethod
    
//! endtextmacro
