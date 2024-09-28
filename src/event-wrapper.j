// ---
// # EventWrapper 라이브러리
//
// > 이 라이브러리는 게임 내 다양한 데미지 관련 이벤트를 확장하여 처리하고 관리하는 기능을 제공합니다.
// > 타입에 기반한 분기 처리를 가능하게 하여 게임의 이벤트를 효율적으로 처리할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [event-wrapper.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/event-wrapper.j)
//
// ## 버전
// - **Version**: 20240903.0
//
// ## Changelog
// - **2024-09-03**: 초기 릴리스.
// ---
library EventWrapper initializer onInit

    globals

        private hashtable eventTable = InitHashtable()
        private trigger lastCreatedTrigger

        private constant key KEY_ON_ITEM_BUY
        private constant key KEY_ON_ITEM_USE
        private trigger anyItemPickUp = CreateTrigger()
        private constant key KEY_ON_ITEM_PICKUP
        private trigger anyItemDrop = CreateTrigger()
        private constant key KEY_ON_ITEM_DROP

        private constant key KEY_ON_UNIT_BUY
        private constant key KEY_ON_UNIT_DEAD
        private constant key KEY_ON_UNIT_KILL
        private trigger anyUnitSelect = CreateTrigger()
        private constant key KEY_ON_UNIT_SELECT
        private constant key KEY_ON_UNIT_OWNER_CHANGE
        private constant key KEY_ON_UNIT_RESEARCH_COMPLETE

        private constant key KEY_ON_HERO_SKILL

        private constant key KEY_ON_SPELL_EFFECT

    endglobals

    private function registerAction takes integer eventKey, integer childKey, code action returns nothing
        if not HaveSavedHandle(eventTable,eventKey,childKey) then
            call SaveTriggerHandle(eventTable,eventKey,childKey,CreateTrigger())
        endif
        call TriggerAddCondition( LoadTriggerHandle(eventTable,eventKey,childKey), Condition( action ) )
    endfunction

    //===========================================================================
    // 아이템 이벤트

    private function onItemBuy takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_ITEM_BUY,GetItemTypeId(GetSoldItem())) )
        return false
    endfunction

    private function onItemUse takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_ITEM_USE,GetItemTypeId(GetManipulatedItem())) )
        return false
    endfunction

    private function onItemPickUp takes nothing returns boolean
        call TriggerEvaluate( anyItemPickUp )
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_ITEM_PICKUP,GetItemTypeId(GetManipulatedItem())) )
        return false
    endfunction

    private function onItemDrop takes nothing returns boolean
        call TriggerEvaluate( anyItemDrop )
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_ITEM_DROP,GetItemTypeId(GetManipulatedItem())) )
        return false
    endfunction

    private function initItemEvents takes nothing returns nothing
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemBuy ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELL_ITEM )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemUse ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_USE_ITEM )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemPickUp ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemDrop ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_DROP_ITEM )
    endfunction

    //===========================================================================
    // 유닛 이벤트

    private function onUnitBuy takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_BUY,GetUnitTypeId(GetSoldUnit())) )
        return false
    endfunction

    private function onUnitDead takes nothing returns boolean
        if GetUnitTypeId(GetKillingUnit()) != 0 then
            call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_KILL,GetUnitTypeId(GetKillingUnit())) )
        endif
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_DEAD,GetUnitTypeId(GetDyingUnit())) )
        return false
    endfunction

    private function onUnitSelect takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_SELECT,GetUnitTypeId(GetTriggerUnit())) )
        return false
    endfunction

    private function onUnitOwnerChange takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_OWNER_CHANGE,GetUnitTypeId(GetTriggerUnit())) )
        return false
    endfunction

    private function onUnitResearchComplete takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_UNIT_RESEARCH_COMPLETE,GetResearched()) )
        return false
    endfunction

    private function onHeroLearn takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_HERO_SKILL,GetLearnedSkill()) )
        return false
    endfunction

    private function initUnitEvents takes nothing returns nothing
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitBuy ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELL )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitDead ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_DEATH )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitSelect ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELECTED )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitOwnerChange ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_CHANGE_OWNER )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitResearchComplete ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_RESEARCH_FINISH )

        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onHeroLearn ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_HERO_SKILL )
    endfunction

    //===========================================================================
    // 능력 이벤트

    private function onSpellEffect takes nothing returns boolean
        call TriggerEvaluate( LoadTriggerHandle(eventTable,KEY_ON_SPELL_EFFECT,GetSpellAbilityId()) )
        return false
    endfunction

    private function initSpellEvents takes nothing returns nothing
        set lastCreatedTrigger = CreateTrigger()
        call TriggerAddCondition( lastCreatedTrigger, Condition( function onSpellEffect ) )
        call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    endfunction

    private function onInit takes nothing returns nothing
        call initItemEvents()
        call initUnitEvents()
        call initSpellEvents()
    endfunction
    
    //===========================================================================
    // API

    // ## 이벤트 래퍼 - 아이템 구매 시 발동
    function WhenItemBought takes integer itemId, code action returns nothing
        call registerAction(KEY_ON_ITEM_BUY,itemId,action)
    endfunction

    // ## 이벤트 래퍼 - 아이템 사용 시 발동
    function WhenItemUsed takes integer itemId, code action returns nothing
        call registerAction(KEY_ON_ITEM_USE,itemId,action)
    endfunction

    // ## 이벤트 래퍼 - 어떤 아이템이든 획득 시 발동
    function WhenAnyItemPick takes code action returns nothing
        call TriggerAddCondition( anyItemPickUp, Condition( action ) )
    endfunction

    // ## 이벤트 래퍼 - 아이템 획득 시 발동
    function WhenItemPick takes integer itemId, code action returns nothing
        call registerAction(KEY_ON_ITEM_PICKUP,itemId,action)
    endfunction

    // ## 이벤트 래퍼 - 어떤 아이템이든 버림 시 발동
    function WhenAnyItemDrop takes code action returns nothing
        call TriggerAddCondition( anyItemDrop, Condition( action ) )
    endfunction

    // ## 이벤트 래퍼 - 아이템 버림 시 발동
    function WhenItemDrop takes integer itemId, code action returns nothing
        call registerAction(KEY_ON_ITEM_DROP,itemId,action)
    endfunction

    // ## 이벤트 래퍼 - 유닛 구매 시 발동
    function WhenUnitBought takes integer unitId, code action returns nothing
        call registerAction(KEY_ON_UNIT_BUY,unitId,action)
    endfunction

    // ## 이벤트 래퍼 - 유닛 사망 시 발동
    function WhenUnitDead takes integer unitId, code action returns nothing
        call registerAction(KEY_ON_UNIT_DEAD,unitId,action)
    endfunction

    // ## 이벤트 래퍼 - 유닛 처치 시 발동
    function WhenUnitKill takes integer unitId, code action returns nothing
        call registerAction(KEY_ON_UNIT_KILL,unitId,action)
    endfunction

    // ## 이벤트 래퍼 - 어떤 유닛이든 선택 시 발동
    function WhenAnyUnitSelect takes code action returns nothing
        call TriggerAddCondition( anyUnitSelect, Condition( action ) )
    endfunction

    // ## 이벤트 래퍼 - 유닛 선택 시 발동
    function WhenUnitSelected takes integer unitId, code action returns nothing
        call registerAction(KEY_ON_UNIT_SELECT,unitId,action)
    endfunction

    // ## 이벤트 래퍼 - 유닛 소유자 변경 시 발동
    function WhenUnitOwnerChanged takes integer unitId, code action returns nothing
        call registerAction(KEY_ON_UNIT_OWNER_CHANGE,unitId,action)
    endfunction

    // ## 이벤트 래퍼 - 유닛 연구 완료 시 발동
    function WhenUnitResearchFinish takes integer researchId, code action returns nothing
        call registerAction(KEY_ON_UNIT_RESEARCH_COMPLETE,researchId,action)
    endfunction

    // ## 이벤트 래퍼 - 영웅 스킬 획득 시 발동
    function WhenHeroSkillLearned takes integer skillId, code action returns nothing
        call registerAction(KEY_ON_HERO_SKILL,skillId,action)
    endfunction

    // ## 이벤트 래퍼 - 특정 능력 효과 시작 시 발동
    function WhenSpellEffect takes integer abilityId, code action returns nothing
        call registerAction(KEY_ON_SPELL_EFFECT,abilityId,action)
    endfunction

endlibrary
