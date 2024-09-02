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
        // 경고성 피해가 아닌, 실제 피해가 발생했을 때만 트리거를 실행합니다. 
        if GetEventDamage() != 0 then
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

endlibrary
