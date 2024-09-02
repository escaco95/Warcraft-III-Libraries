// ---
// # DamageEngineBase 라이브러리
//
// > 이 라이브러리는 게임 내 모든 유닛의 데미지 이벤트를 효율적으로 관리하기 위한
// > 방어적인 데미지 엔진의 기본 모듈입니다. 라이브러리는 데미지 관련 이벤트를 캡처하고
// > 등록된 코드(액션)를 평가하여 다양한 게임 내 효과를 처리할 수 있도록 합니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [damage-engine-base.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/damage-engine-base.j)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-02**: 초기 릴리스. 데미지 이벤트 캡처, 유닛 자동 등록, 중복 등록 방지 기능 포함.
//
// ## 주요 기능:
// - **데미지 이벤트 캡처**: 모든 유닛이 데미지를 받을 때마다 발생하는 이벤트를 트리거로 캡처.
// - **유닛 자동 등록**: 모든 유닛을 자동으로 등록하여, 데미지 이벤트를 감지할 수 있도록 설정.
// - **중복 등록 방지**: 유닛이 중복 등록되지 않도록 능력('Asph')을 부여하고 이를 확인.
// - **주기적 새로고침**: 주기적으로 트리거를 리셋하고 모든 유닛을 재등록하여 최신 상태 유지.
//
// ## 주요 상수:
// - `REGISTER_CHECK_ABILITY_ID`: 중복 등록 방지를 위해 유닛에 부여되는 능력의 ID.
// - `REFRESH_PERIOD`: 트리거 새로고침 간격(초 단위).
//
// ## 활용 시나리오:
// - 데미지 기반의 특수 효과 처리 (예: 방어구 무효화, 추가 피해, 흡혈 효과 등).
// - 특정 유닛의 데미지 수신을 감시하여 능동적인 게임 이벤트 트리거링.
// - 복잡한 데미지 계산 및 수정 로직을 일관성 있게 적용.
//
// ## 문제해결:
// - 만약 모든 유닛에게 이상한 이펙트 효과가 나타난다면, 이는 'Asph' 능력 때문입니다.
//   눈에 보이지 않는 더미 능력을 생성하고, 그 능력의 코드값을 'Asph' 대신 사용하세요.
// ---
library DamageEngineBase initializer onInit

    globals
        // 중복 등록 방지를 위한 기능으로, 휴먼 - '스피어' 같은 능력 기반의 커스텀 능력
        private constant integer REGISTER_CHECK_ABILITY_ID = 'Asph'
        // 트리거 새로고침 간격(초)
        private constant real REFRESH_PERIOD = 60.0

        private trigger baseTrigger = null
        private boolexpr array actions
        private integer actionCount = 0

        private boolexpr registerAction
        private group playerUnits = CreateGroup()
    endglobals

    private function clearBaseTrigger takes nothing returns nothing
        call TriggerClearConditions(baseTrigger)
        call DestroyTrigger(baseTrigger)
        set baseTrigger = null
    endfunction

    private function initBaseTrigger takes nothing returns nothing
        set baseTrigger = CreateTrigger()
    endfunction

    private function registerActions takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= actionCount
            call TriggerAddCondition(baseTrigger, actions[i])
            set i = i + 1
        endloop
    endfunction

    private function resetBaseTrigger takes nothing returns nothing
        call clearBaseTrigger()
        call initBaseTrigger()
        call registerActions()
    endfunction

    private function registerUnit takes nothing returns boolean
        if GetUnitTypeId(GetFilterUnit()) != 0 then
            call UnitAddAbility( GetFilterUnit(), REGISTER_CHECK_ABILITY_ID )
            call UnitMakeAbilityPermanent( GetFilterUnit(), true, REGISTER_CHECK_ABILITY_ID )
            call TriggerRegisterUnitEvent( baseTrigger, GetFilterUnit(), EVENT_UNIT_DAMAGED )
        endif
        return false
    endfunction

    private function registerEntireGameUnits takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call GroupEnumUnitsOfPlayer( playerUnits, Player(i), registerAction )
            set i = i + 1
        endloop
        call GroupClear( playerUnits )
    endfunction

    private function onRefreshTimeout takes nothing returns nothing
        call resetBaseTrigger()
        call registerEntireGameUnits()
    endfunction

    private function initRefreshTrigger takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function onRefreshTimeout )
        call TriggerRegisterTimerEvent( t, REFRESH_PERIOD, true )
        set t = null
    endfunction

    private function onAnyUnitEntersWorld takes nothing returns nothing
        local unit u = GetEnteringUnit()
        if GetUnitTypeId(u) != 0 and GetUnitAbilityLevel( u, REGISTER_CHECK_ABILITY_ID ) < 1 then
            call UnitAddAbility( u, REGISTER_CHECK_ABILITY_ID )
            call UnitMakeAbilityPermanent( u, true, REGISTER_CHECK_ABILITY_ID )
            call TriggerRegisterUnitEvent( baseTrigger, u, EVENT_UNIT_DAMAGED )
        endif
        set u = null
    endfunction

    private function initAutoRegisterTrigger takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction( t, function onAnyUnitEntersWorld )
        call TriggerRegisterEnterRectSimple( t, GetWorldBounds() )
        set t = null
    endfunction

    private function onInit takes nothing returns nothing
        // 라이브러리 초기화
        set registerAction = Filter(function registerUnit)

        // 새로고침 동작 & 자동 등록 초기화
        call initRefreshTrigger()
        call initAutoRegisterTrigger()

        // 초기 유닛 등록
        call initBaseTrigger()
        call registerActions()
        call registerEntireGameUnits()
    endfunction

    // 이벤트 - 데미지 받음 판정 발생함
    function DamageEngineBaseRegister takes code action returns nothing
        set actions[actionCount] = Condition(action)
        if baseTrigger != null then
            call TriggerAddCondition(baseTrigger, actions[actionCount])
        endif
        set actionCount = actionCount + 1
    endfunction

endlibrary
