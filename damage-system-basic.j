// ---
// # DamageSystemBasic 라이브러리
//
// > 이 라이브러리는 `DamageEngineBase`를 기반으로 하여, 게임 내 다양한 데미지 관련 이벤트를
// > 처리하고 관리하는 시스템을 제공합니다. 특정 유닛 타입이나 아이템 타입에 기반한 맞춤형
// > 데미지 이벤트 처리를 가능하게 하여 게임의 복잡한 전투 메커니즘을 구현할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [damage-system-basic.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/damage-system-basic.j)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-02**: 초기 릴리스. 유닛 및 아이템별 데미지 이벤트 처리 기능 구현.
//
// ## 주요 기능:
// - **데미지 이벤트 관리**: 유닛이나 아이템이 피해를 가하거나 받을 때 발생하는 다양한 이벤트를 관리.
// - **유닛 및 아이템별 이벤트 처리**: 특정 유닛 타입이나 아이템 타입에 대해 개별적인 데미지 이벤트를 등록하고 처리.
// - **전역 데미지 이벤트 등록**: 모든 유닛이 피해를 가하거나 받을 때의 공통 이벤트를 쉽게 등록.
//
// ## 주요 상수 및 변수:
// - `ACTION_UNIT_TYPE_ATTACK`: 특정 유닛 타입의 공격 이벤트 식별자.
// - `ACTION_ITEM_TYPE_ATTACK`: 특정 아이템 타입의 공격 이벤트 식별자.
// - `ACTION_ITEM_TYPE_HIT`: 특정 아이템 타입의 피격 이벤트 식별자.
// - `ACTION_UNIT_TYPE_HIT`: 특정 유닛 타입의 피격 이벤트 식별자.
//
// ## 활용 시나리오:
// - 특정 아이템을 착용한 유닛이 공격할 때 발생하는 특수 효과를 처리할 때.
// - 특정 유닛 타입이 공격을 받을 때 발동되는 방어 메커니즘을 구현할 때.
// - 모든 유닛의 공격과 방어 이벤트를 일괄 관리하여 게임의 전투 시스템을 일관되게 유지할 때.
// ---
library DamageSystemBasic initializer onInit requires DamageEngineBase

    globals
        private integer damageEventSuspendCount = 0

        private trigger actionAnyUnitAttack = CreateTrigger()

        private hashtable actionTable = InitHashtable()
        private constant integer ACTION_UNIT_TYPE_ATTACK = 1
        private constant integer ACTION_ITEM_TYPE_ATTACK = 2
        private constant integer ACTION_ITEM_TYPE_HIT = 3
        private constant integer ACTION_UNIT_TYPE_HIT = 4

        private trigger actionAnyUnitHit = CreateTrigger()

        private item eventItem = null
    endglobals

    private function processDamageLogic takes unit source, unit target returns nothing
        local integer slotIndex
        local item previousItem

        // 1. 어떤 유닛이든 피해 가함 이벤트 실행
        call TriggerEvaluate( actionAnyUnitAttack )

        // 2. 특정 유닛 타입이 피해를 가함 이벤트 실행
        call TriggerEvaluate( LoadTriggerHandle(actionTable, ACTION_UNIT_TYPE_ATTACK, GetUnitTypeId(source)) )

        // 3. 특정 아이템 타입을 들고 피해를 가함 이벤트 실행
        if IsUnitType( source, UNIT_TYPE_HERO ) then
            set previousItem = eventItem
            set slotIndex = UnitInventorySize( source )
            loop
                exitwhen slotIndex == 0
                set slotIndex = slotIndex - 1
                set eventItem = UnitItemInSlot( source, slotIndex )
                call TriggerEvaluate( LoadTriggerHandle(actionTable, ACTION_ITEM_TYPE_ATTACK, GetItemTypeId(eventItem) ))
            endloop
            set eventItem = previousItem
            set previousItem = null
        endif

        // 4. 특정 아이템 타입을 들고 피해를 받음 이벤트 실행
        if IsUnitType( target, UNIT_TYPE_HERO ) then
            set previousItem = eventItem
            set slotIndex = UnitInventorySize( target )
            loop
                exitwhen slotIndex == 0
                set slotIndex = slotIndex - 1
                set eventItem = UnitItemInSlot( target, slotIndex )
                call TriggerEvaluate( LoadTriggerHandle(actionTable, ACTION_ITEM_TYPE_HIT, GetItemTypeId(eventItem) ))
            endloop
            set eventItem = previousItem
            set previousItem = null
        endif

        // 5. 특정 유닛 타입이 피해를 받음 이벤트 실행
        call TriggerEvaluate( LoadTriggerHandle(actionTable, ACTION_UNIT_TYPE_HIT, GetUnitTypeId(target)) )

        // 6. 어떤 유닛이든 피해 받음 이벤트 실행
        call TriggerEvaluate( actionAnyUnitHit )

    endfunction

    private function onAnyDamageOccurs takes nothing returns boolean
        // 경고성 피해(건물에 적이 접근 중 등...)가 아닌, 실제 피해가 발생했을 때만 트리거를 실행합니다. 
        if damageEventSuspendCount == 0 and GetEventDamage() != 0 then
            call processDamageLogic( GetEventDamageSource(), GetTriggerUnit() )
        endif
        return false
    endfunction

    private function onInit takes nothing returns nothing
        call DamageEngineBaseRegister(function onAnyDamageOccurs)
    endfunction

    private function registerTypeSpecificEvent takes integer actionType, integer typeId, code action returns nothing
        if not HaveSavedHandle(actionTable, actionType, typeId) then
            call SaveTriggerHandle(actionTable, actionType, typeId, CreateTrigger())
        endif
        call TriggerAddCondition(LoadTriggerHandle(actionTable, actionType, typeId), Condition(action))
    endfunction

    // 데미지 받음 시스템 - 타격한 아이템 / 피격한 아이템
    function GetEventDamageSourceItem takes nothing returns item
        return eventItem
    endfunction

    // 데미지 받음 시스템 - 어떤 유닛이든 피해 가함 이벤트 등록
    function RegisterAnyUnitAttackEvent takes code action returns nothing
        call TriggerAddCondition(actionAnyUnitAttack, Condition(action))
    endfunction

    // 데미지 받음 시스템 - 특정 유닛 타입이 피해 가함 이벤트 등록
    function RegisterUnitTypeAttackEvent takes integer typeId, code action returns nothing
        call registerTypeSpecificEvent(ACTION_UNIT_TYPE_ATTACK, typeId, action)
    endfunction

    // 데미지 받음 시스템 - 특정 아이템 타입을 들고 피해 가함 이벤트 등록
    function RegisterItemTypeAttackEvent takes integer typeId, code action returns nothing
        call registerTypeSpecificEvent(ACTION_ITEM_TYPE_ATTACK, typeId, action)
    endfunction

    // 데미지 받음 시스템 - 특정 아이템 타입을 들고 피해 받음 이벤트 등록
    function RegisterItemTypeHitEvent takes integer typeId, code action returns nothing
        call registerTypeSpecificEvent(ACTION_ITEM_TYPE_HIT, typeId, action)
    endfunction

    // 데미지 받음 시스템 - 특정 유닛 타입이 피해 받음 이벤트 등록
    function RegisterUnitTypeHitEvent takes integer typeId, code action returns nothing
        call registerTypeSpecificEvent(ACTION_UNIT_TYPE_HIT, typeId, action)
    endfunction

    // 데미지 받음 시스템 - 어떤 유닛이든 피해 받음 이벤트 등록
    function RegisterAnyUnitHitEvent takes code action returns nothing
        call TriggerAddCondition(actionAnyUnitHit, Condition(action))
    endfunction

    // 데미지 받음 시스템 - 데미지 이벤트 일시 중지
    // ℹ️ 치명타 판정 등으로 이벤트 중첩 발생 없이 추가 데미지를 주고 싶은 경우 사용해주세요.
    // ℹ️ `ResumeDamageEvent` 함수를 호출하기 전까지 데미지 이벤트가 실행되지 않습니다.
    // ⚠️ `SuspendDamageEvent`와 `ResumeDamageEvent`는 반드시 쌍으로 사용되어야 합니다.
    // 🚨 만약 이 쌍이 맞지 않는 경우, 맵 상의 모든 데미지 판정이 발생하지 않을 수 있습니다.
    function SuspendDamageEvent takes nothing returns nothing
        set damageEventSuspendCount = damageEventSuspendCount + 1
    endfunction

    // 데미지 받음 시스템 - 데미지 이벤트 재개
    function ResumeDamageEvent takes nothing returns nothing
        if damageEventSuspendCount <= 0 then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "|cFFFF0000[FATAL] ERROR!! 데미지 이벤트가 일시 중지되어 있지 않으나 ResumeDamageEvent 함수가 호출되었습니다!!|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "스크립트 어딘가에서 SuspendDamageEvent 와 ResumeDamageEvent 함수의 쌍이 맞지 않는 문제가 발생한 게 분명합니다.")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "전수조사를 통해 문제를 해결하지 않을 경우, 데미지 받음 이벤트 기반 트리거들이 모두 오동작할 수 있습니다.")
            return
        endif
        set damageEventSuspendCount = damageEventSuspendCount - 1
    endfunction

endlibrary
