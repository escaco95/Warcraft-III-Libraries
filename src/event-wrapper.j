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
// - **Version**: 20250302.0
//
// ## Changelog
// - **2025-03-02**: 타이머 이벤트 추가
// - **2024-12-29**: 모든 이벤트를 사용하는 것은 부담이 심하므로, 필요한 이벤트만 초기화하도록 수정
// - **2024-09-03**: 초기 릴리스.
// ---
library EventWrapper

    globals

        private trigger array anyEvent
        private hashtable eventTable = InitHashtable( )

        private trigger lastCreatedTrigger

        // 아이템 이벤트
        private constant integer KEY_ITEM_PAWN              = 1
        private constant integer KEY_ITEM_SOLD              = 2
        private constant integer KEY_ITEM_USE               = 3
        private constant integer KEY_ITEM_PICKUP            = 4
        private constant integer KEY_ITEM_DROP              = 5

        // 유닛 이벤트
        private constant integer KEY_UNIT_SOLD              = 100
        private constant integer KEY_UNIT_DEAD              = 101
        private constant integer KEY_UNIT_KILL              = 102
        private constant integer KEY_UNIT_SELECT            = 103
        private constant integer KEY_UNIT_RESEARCH_COMPLETE = 104
        private constant integer KEY_UNIT_OWNER_CHANGE      = 105

        // 영웅 이벤트
        private constant integer KEY_HERO_LEARN             = 200

        // 연구 이벤트
        private constant integer KEY_RESEARCH_COMPLETE      = 300

        // 능력 이벤트
        private constant integer KEY_SPELL_EFFECT           = 400

    endglobals

    private function registerAction takes integer eventKey, integer childKey, code action returns nothing
        if not HaveSavedHandle( eventTable, eventKey, childKey ) then
            call SaveTriggerHandle( eventTable, eventKey, childKey, CreateTrigger( ) )
        endif
        call TriggerAddCondition( LoadTriggerHandle( eventTable, eventKey, childKey ), Condition( action ) )
    endfunction

    private function registerAnyAction takes integer eventKey, code action returns nothing
        if anyEvent[eventKey] == null then
            set anyEvent[eventKey] = CreateTrigger( )
        endif
        call TriggerAddCondition( anyEvent[eventKey], Condition( action ) )
    endfunction

    // '####:'########:'########:'##::::'##::::::::::'########:::::'###::::'##:::::'##:'##::: ##:
    // . ##::... ##..:: ##.....:: ###::'###:::::::::: ##.... ##:::'## ##::: ##:'##: ##: ###:: ##:
    // : ##::::: ##:::: ##::::::: ####'####:::::::::: ##:::: ##::'##:. ##:: ##: ##: ##: ####: ##:
    // : ##::::: ##:::: ######::: ## ### ##:'#######: ########::'##:::. ##: ##: ##: ##: ## ## ##:
    // : ##::::: ##:::: ##...:::: ##. #: ##:........: ##.....::: #########: ##: ##: ##: ##. ####:
    // : ##::::: ##:::: ##::::::: ##:.:: ##:::::::::: ##:::::::: ##.... ##: ##: ##: ##: ##:. ###:
    // '####:::: ##:::: ########: ##:::: ##:::::::::: ##:::::::: ##:::: ##:. ###. ###:: ##::. ##:
    // ....:::::..:::::........::..:::::..:::::::::::..:::::::::..:::::..:::...::...:::..::::..::

    private function onItemPawn takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_ITEM_PAWN] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_ITEM_PAWN, GetItemTypeId( GetSoldItem( ) ) ) )
        return false
    endfunction

    globals
        private boolean isItemPawnEventPrepared = false
    endglobals

    private function prepareItemPawnEvent takes nothing returns nothing
        if not isItemPawnEventPrepared then
            set isItemPawnEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemPawn ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_PAWN_ITEM )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 아이템이든 상점에 판매되면...
    // > ### 어떤 아이템이든 상점에 판매되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 판매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 판매 이벤트](<function WhenAnyItemPawned>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 아이템 판매 이벤트](<function WhenItemPawned>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyItemPawned takes code action returns nothing
        call prepareItemPawnEvent( )
        call registerAnyAction( KEY_ITEM_PAWN, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 아이템이 상점에 판매되면...
    // > ### [특정 타입](<integer itemTypeId>)의 아이템이 상점에 판매되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 판매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 판매 이벤트](<function WhenAnyItemPawned>)
    // ##### 2️⃣ [특정 타입의 아이템 판매 이벤트](<function WhenItemPawned>) (현재 이벤트)
    // ---
    // takes
    // - integer itemTypeId 판매된 아이템의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenItemPawned takes integer itemTypeId, code action returns nothing
        call prepareItemPawnEvent( )
        call registerAction( KEY_ITEM_PAWN, itemTypeId, action )
    endfunction

    // '####:'########:'########:'##::::'##:::::::::::'######:::'#######::'##:::::::'########::
    // . ##::... ##..:: ##.....:: ###::'###::::::::::'##... ##:'##.... ##: ##::::::: ##.... ##:
    // : ##::::: ##:::: ##::::::: ####'####:::::::::: ##:::..:: ##:::: ##: ##::::::: ##:::: ##:
    // : ##::::: ##:::: ######::: ## ### ##:'#######:. ######:: ##:::: ##: ##::::::: ##:::: ##:
    // : ##::::: ##:::: ##...:::: ##. #: ##:........::..... ##: ##:::: ##: ##::::::: ##:::: ##:
    // : ##::::: ##:::: ##::::::: ##:.:: ##::::::::::'##::: ##: ##:::: ##: ##::::::: ##:::: ##:
    // '####:::: ##:::: ########: ##:::: ##::::::::::. ######::. #######:: ########: ########::
    // ....:::::..:::::........::..:::::..::::::::::::......::::.......:::........::........:::
    
    private function onItemBuy takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_ITEM_SOLD] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_ITEM_SOLD, GetItemTypeId( GetSoldItem( ) ) ) )
        return false
    endfunction

    globals
        private boolean isItemBuyEventPrepared = false
    endglobals

    private function prepareItemBuyEvent takes nothing returns nothing
        if not isItemBuyEventPrepared then
            set isItemBuyEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemBuy ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELL_ITEM )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 아이템이든 구매하면...
    // > ### 어떤 아이템이든 구매하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 구매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 구매 이벤트](<function WhenAnyItemBought>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 아이템 구매 이벤트](<function WhenItemBought>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyItemBought takes code action returns nothing
        call prepareItemBuyEvent( )
        call registerAnyAction( KEY_ITEM_SOLD, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 아이템을 구매하면...
    // > ### [특정 타입](<integer itemTypeId>)의 아이템을 구매하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 구매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 구매 이벤트](<function WhenAnyItemBought>)
    // ##### 2️⃣ [특정 타입의 아이템 구매 이벤트](<function WhenItemBought>) (현재 이벤트)
    // ---
    // takes
    // - integer itemTypeId 구매한 아이템의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenItemBought takes integer itemTypeId, code action returns nothing
        call prepareItemBuyEvent( )
        call registerAction( KEY_ITEM_SOLD, itemTypeId, action )
    endfunction

    // '####:'########:'########:'##::::'##::::::::::'##::::'##::'######::'########:
    // . ##::... ##..:: ##.....:: ###::'###:::::::::: ##:::: ##:'##... ##: ##.....::
    // : ##::::: ##:::: ##::::::: ####'####:::::::::: ##:::: ##: ##:::..:: ##:::::::
    // : ##::::: ##:::: ######::: ## ### ##:'#######: ##:::: ##:. ######:: ######:::
    // : ##::::: ##:::: ##...:::: ##. #: ##:........: ##:::: ##::..... ##: ##...::::
    // : ##::::: ##:::: ##::::::: ##:.:: ##:::::::::: ##:::: ##:'##::: ##: ##:::::::
    // '####:::: ##:::: ########: ##:::: ##::::::::::. #######::. ######:: ########:
    // ....:::::..:::::........::..:::::..::::::::::::.......::::......:::........::

    private function onItemUse takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_ITEM_USE] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_ITEM_USE, GetItemTypeId( GetManipulatedItem( ) ) ) )
        return false
    endfunction

    globals
        private boolean isItemUseEventPrepared = false
    endglobals

    private function prepareItemUseEvent takes nothing returns nothing
        if not isItemUseEventPrepared then
            set isItemUseEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemUse ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_USE_ITEM )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 아이템이든 사용하면...
    // > ### 어떤 아이템이든 사용하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 사용 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 사용 이벤트](<function WhenAnyItemUse>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 아이템 사용 이벤트](<function WhenItemUsed>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyItemUse takes code action returns nothing
        call prepareItemUseEvent( )
        call registerAnyAction( KEY_ITEM_USE, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 아이템을 사용하면...
    // > ### [특정 타입](<integer itemTypeId>)의 아이템을 사용하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 사용 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 사용 이벤트](<function WhenAnyItemUse>)
    // ##### 2️⃣ [특정 타입의 아이템 사용 이벤트](<function WhenItemUsed>) (현재 이벤트)
    // ---
    // takes
    // - integer itemTypeId 사용한 아이템의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenItemUsed takes integer itemTypeId, code action returns nothing
        call prepareItemUseEvent( )
        call registerAction( KEY_ITEM_USE, itemTypeId, action )
    endfunction

    // '####:'########:'########:'##::::'##::::::::::'########::'####::'######::'##:::'##:'##::::'##:'########::
    // . ##::... ##..:: ##.....:: ###::'###:::::::::: ##.... ##:. ##::'##... ##: ##::'##:: ##:::: ##: ##.... ##:
    // : ##::::: ##:::: ##::::::: ####'####:::::::::: ##:::: ##:: ##:: ##:::..:: ##:'##::: ##:::: ##: ##:::: ##:
    // : ##::::: ##:::: ######::: ## ### ##:'#######: ########::: ##:: ##::::::: #####:::: ##:::: ##: ########::
    // : ##::::: ##:::: ##...:::: ##. #: ##:........: ##.....:::: ##:: ##::::::: ##. ##::: ##:::: ##: ##.....:::
    // : ##::::: ##:::: ##::::::: ##:.:: ##:::::::::: ##::::::::: ##:: ##::: ##: ##:. ##:: ##:::: ##: ##::::::::
    // '####:::: ##:::: ########: ##:::: ##:::::::::: ##::::::::'####:. ######:: ##::. ##:. #######:: ##::::::::
    // ....:::::..:::::........::..:::::..:::::::::::..:::::::::....:::......:::..::::..:::.......:::..:::::::::

    private function onItemPickUp takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_ITEM_PICKUP] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_ITEM_PICKUP, GetItemTypeId( GetManipulatedItem( ) ) ) )
        return false
    endfunction

    globals
        private boolean isItemPickUpEventPrepared = false
    endglobals

    private function prepareItemPickUpEvent takes nothing returns nothing
        if not isItemPickUpEventPrepared then
            set isItemPickUpEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemPickUp ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_PICKUP_ITEM )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 아이템이든 습득하면...
    // > ### 어떤 아이템이든 습득하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 획득 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 습득 이벤트](<function WhenAnyItemPick>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 아이템 습득 이벤트](<function WhenItemPick>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyItemPick takes code action returns nothing
        call prepareItemPickUpEvent( )
        call registerAnyAction( KEY_ITEM_PICKUP, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 아이템을 습득하면...
    // > ### [특정 타입](<integer itemTypeId>)의 아이템을 습득하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 획득 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 습득 이벤트](<function WhenAnyItemPick>)
    // ##### 2️⃣ [특정 타입의 아이템 습득 이벤트](<function WhenItemPick>) (현재 이벤트)
    // ---
    // takes
    // - integer itemTypeId 습득한 아이템의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenItemPick takes integer itemTypeId, code action returns nothing
        call prepareItemPickUpEvent( )
        call registerAction( KEY_ITEM_PICKUP, itemTypeId, action )
    endfunction

    // '####:'########:'########:'##::::'##::::::::::'########::'########:::'#######::'########::
    // . ##::... ##..:: ##.....:: ###::'###:::::::::: ##.... ##: ##.... ##:'##.... ##: ##.... ##:
    // : ##::::: ##:::: ##::::::: ####'####:::::::::: ##:::: ##: ##:::: ##: ##:::: ##: ##:::: ##:
    // : ##::::: ##:::: ######::: ## ### ##:'#######: ##:::: ##: ########:: ##:::: ##: ########::
    // : ##::::: ##:::: ##...:::: ##. #: ##:........: ##:::: ##: ##.. ##::: ##:::: ##: ##.....:::
    // : ##::::: ##:::: ##::::::: ##:.:: ##:::::::::: ##:::: ##: ##::. ##:: ##:::: ##: ##::::::::
    // '####:::: ##:::: ########: ##:::: ##:::::::::: ########:: ##:::. ##:. #######:: ##::::::::
    // ....:::::..:::::........::..:::::..:::::::::::........:::..:::::..:::.......:::..:::::::::
    
    private function onItemDrop takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_ITEM_DROP] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_ITEM_DROP, GetItemTypeId( GetManipulatedItem( ) ) ) )
        return false
    endfunction

    globals
        private boolean isItemDropEventPrepared = false
    endglobals

    private function prepareItemDropEvent takes nothing returns nothing
        if not isItemDropEventPrepared then
            set isItemDropEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onItemDrop ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_DROP_ITEM )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 아이템이든 떨어뜨리면...
    // > ### 어떤 아이템이든 떨어뜨리면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 버림 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 떨어뜨림 이벤트](<function WhenAnyItemDrop>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 아이템 떨어뜨림 이벤트](<function WhenItemDrop>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyItemDrop takes code action returns nothing
        call prepareItemDropEvent( )
        call registerAnyAction( KEY_ITEM_DROP, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 아이템을 떨어뜨리면...
    // > ### [특정 타입](<integer itemTypeId>)의 아이템을 떨어뜨리면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 아이템 버림 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 아이템이든 떨어뜨림 이벤트](<function WhenAnyItemDrop>)
    // ##### 2️⃣ [특정 타입의 아이템 떨어뜨림 이벤트](<function WhenItemDrop>) (현재 이벤트)
    // ---
    // takes
    // - integer itemTypeId 떨어뜨린 아이템의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenItemDrop takes integer itemTypeId, code action returns nothing
        call prepareItemDropEvent( )
        call registerAction( KEY_ITEM_DROP, itemTypeId, action )
    endfunction

    // '##::::'##:'##::: ##:'####:'########:::::::::::'######:::'#######::'##:::::::'########::
    //  ##:::: ##: ###:: ##:. ##::... ##..:::::::::::'##... ##:'##.... ##: ##::::::: ##.... ##:
    //  ##:::: ##: ####: ##:: ##::::: ##::::::::::::: ##:::..:: ##:::: ##: ##::::::: ##:::: ##:
    //  ##:::: ##: ## ## ##:: ##::::: ##::::'#######:. ######:: ##:::: ##: ##::::::: ##:::: ##:
    //  ##:::: ##: ##. ####:: ##::::: ##::::........::..... ##: ##:::: ##: ##::::::: ##:::: ##:
    //  ##:::: ##: ##:. ###:: ##::::: ##:::::::::::::'##::: ##: ##:::: ##: ##::::::: ##:::: ##:
    // . #######:: ##::. ##:'####:::: ##:::::::::::::. ######::. #######:: ########: ########::
    // :.......:::..::::..::....:::::..:::::::::::::::......::::.......:::........::........:::

    private function onUnitBuy takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_UNIT_SOLD] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_SOLD, GetUnitTypeId( GetSoldUnit( ) ) ) )
        return false
    endfunction

    globals
        private boolean isUnitBuyEventPrepared = false
    endglobals

    private function prepareUnitBuyEvent takes nothing returns nothing
        if not isUnitBuyEventPrepared then
            set isUnitBuyEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitBuy ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELL )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 용병이든 구매하면...
    // > ### 어떤 용병이든 구매하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 용병 구매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 용병이든 구매 이벤트](<function WhenAnyUnitBought>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 용병 구매 이벤트](<function WhenUnitBought>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitBought takes code action returns nothing
        call prepareUnitBuyEvent( )
        call registerAnyAction( KEY_UNIT_SOLD, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 용병을 구매하면...
    // > ### [특정 타입](<integer unitTypeId>)의 용병을 구매하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 용병 구매 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 용병이든 구매 이벤트](<function WhenAnyUnitBought>)
    // ##### 2️⃣ [특정 타입의 용병 구매 이벤트](<function WhenUnitBought>) (현재 이벤트)
    // ---
    // takes
    // - integer unitTypeId 구매한 용병의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitBought takes integer unitTypeId, code action returns nothing
        call prepareUnitBuyEvent( )
        call registerAction( KEY_UNIT_SOLD, unitTypeId, action )
    endfunction

    // '##::::'##:'##::: ##:'####:'########::::::::::'########::'########::::'###::::'########::
    //  ##:::: ##: ###:: ##:. ##::... ##..::::::::::: ##.... ##: ##.....::::'## ##::: ##.... ##:
    //  ##:::: ##: ####: ##:: ##::::: ##::::::::::::: ##:::: ##: ##::::::::'##:. ##:: ##:::: ##:
    //  ##:::: ##: ## ## ##:: ##::::: ##::::'#######: ##:::: ##: ######:::'##:::. ##: ##:::: ##:
    //  ##:::: ##: ##. ####:: ##::::: ##::::........: ##:::: ##: ##...:::: #########: ##:::: ##:
    //  ##:::: ##: ##:. ###:: ##::::: ##::::::::::::: ##:::: ##: ##::::::: ##.... ##: ##:::: ##:
    // . #######:: ##::. ##:'####:::: ##::::::::::::: ########:: ########: ##:::: ##: ########::
    // :.......:::..::::..::....:::::..::::::::::::::........:::........::..:::::..::........:::

    private function onUnitDead takes nothing returns boolean
        if GetUnitTypeId( GetKillingUnit() ) != 0 then
            call TriggerEvaluate( anyEvent[KEY_UNIT_KILL] )
            call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_KILL, GetUnitTypeId( GetKillingUnit( ) ) ) )
        endif
        call TriggerEvaluate( anyEvent[KEY_UNIT_DEAD] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_DEAD, GetUnitTypeId( GetDyingUnit( ) ) ) )
        return false
    endfunction

    globals
        private boolean isUnitDeadEventPrepared = false
    endglobals

    private function prepareUnitDeadEvent takes nothing returns nothing
        if not isUnitDeadEventPrepared then
            set isUnitDeadEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitDead ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_DEATH )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 유닛이든 사망하면...
    // > ### 어떤 유닛이든 사망하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 사망 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 처치 이벤트](<function WhenAnyUnitKill>)
    // ##### 2️⃣ [특정 타입의 유닛이 처치 이벤트](<function WhenUnitKill>)
    // ##### 3️⃣ [어떤 유닛이든 사망 이벤트](<function WhenAnyUnitDead>) (현재 이벤트)
    // ##### 4️⃣ [특정 타입의 유닛이 사망 이벤트](<function WhenUnitDead>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitDead takes code action returns nothing
        call prepareUnitDeadEvent( )
        call registerAnyAction( KEY_UNIT_DEAD, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 유닛이 사망하면...
    // > ### [특정 타입](<integer unitTypeId>)의 유닛이 사망하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 사망 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 처치 이벤트](<function WhenAnyUnitKill>)
    // ##### 2️⃣ [특정 타입의 유닛이 처치 이벤트](<function WhenUnitKill>)
    // ##### 3️⃣ [어떤 유닛이든 사망 이벤트](<function WhenAnyUnitDead>)
    // ##### 4️⃣ [특정 타입의 유닛이 사망 이벤트](<function WhenUnitDead>) (현재 이벤트)
    // ---
    // takes
    // - integer unitTypeId 사망한 유닛의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitDead takes integer unitTypeId, code action returns nothing
        call prepareUnitDeadEvent( )
        call registerAction( KEY_UNIT_DEAD, unitTypeId, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 유닛이든 처치하면...
    // > ### 어떤 유닛이든 유닛을 처치하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 처치 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 처치 이벤트](<function WhenAnyUnitKill>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 유닛이 처치 이벤트](<function WhenUnitKill>)
    // ##### 3️⃣ [어떤 유닛이든 사망 이벤트](<function WhenAnyUnitDead>)
    // ##### 4️⃣ [특정 타입의 유닛이 사망 이벤트](<function WhenUnitDead>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitKill takes code action returns nothing
        call prepareUnitDeadEvent( )
        call registerAnyAction( KEY_UNIT_KILL, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 유닛이 처치하면...
    // > ### [특정 타입](<integer unitTypeId>)의 유닛이 유닛을 처치하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 처치 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 처치 이벤트](<function WhenAnyUnitKill>)
    // ##### 2️⃣ [특정 타입의 유닛이 처치 이벤트](<function WhenUnitKill>) (현재 이벤트)
    // ##### 3️⃣ [어떤 유닛이든 사망 이벤트](<function WhenAnyUnitDead>)
    // ##### 4️⃣ [특정 타입의 유닛이 사망 이벤트](<function WhenUnitDead>)
    // ---
    // takes
    // - integer unitTypeId 처치자 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitKill takes integer unitTypeId, code action returns nothing
        call prepareUnitDeadEvent( )
        call registerAction( KEY_UNIT_KILL, unitTypeId, action )
    endfunction

    // '##::::'##:'##::: ##:'####:'########:::::::::::'######::'########:'##:::::::'########::'######::'########:
    //  ##:::: ##: ###:: ##:. ##::... ##..:::::::::::'##... ##: ##.....:: ##::::::: ##.....::'##... ##:... ##..::
    //  ##:::: ##: ####: ##:: ##::::: ##::::::::::::: ##:::..:: ##::::::: ##::::::: ##::::::: ##:::..::::: ##::::
    //  ##:::: ##: ## ## ##:: ##::::: ##::::'#######:. ######:: ######::: ##::::::: ######::: ##:::::::::: ##::::
    //  ##:::: ##: ##. ####:: ##::::: ##::::........::..... ##: ##...:::: ##::::::: ##...:::: ##:::::::::: ##::::
    //  ##:::: ##: ##:. ###:: ##::::: ##:::::::::::::'##::: ##: ##::::::: ##::::::: ##::::::: ##::: ##:::: ##::::
    // . #######:: ##::. ##:'####:::: ##:::::::::::::. ######:: ########: ########: ########:. ######::::: ##::::
    // :.......:::..::::..::....:::::..:::::::::::::::......:::........::........::........:::......::::::..:::::

    private function onUnitSelect takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_UNIT_SELECT] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_SELECT, GetUnitTypeId( GetTriggerUnit( ) ) ) )
        return false
    endfunction

    globals
        private boolean isUnitSelectEventPrepared = false
    endglobals

    private function prepareUnitSelectEvent takes nothing returns nothing
        if not isUnitSelectEventPrepared then
            set isUnitSelectEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitSelect ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SELECTED )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 유닛이든 선택하면...
    // > ### 어떤 유닛이든 선택하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 선택 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 선택 이벤트](<function WhenAnyUnitSelected>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 유닛을 선택 이벤트](<function WhenUnitSelected>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitSelected takes code action returns nothing
        call prepareUnitSelectEvent( )
        call registerAnyAction( KEY_UNIT_SELECT, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 유닛을 선택하면...
    // > ### [특정 타입](<integer unitTypeId>)의 유닛을 선택하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 선택 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 선택 이벤트](<function WhenAnyUnitSelected>)
    // ##### 2️⃣ [특정 타입의 유닛을 선택 이벤트](<function WhenUnitSelected>) (현재 이벤트)
    // ---
    // takes
    // - integer unitTypeId 선택한 유닛의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitSelected takes integer unitTypeId, code action returns nothing
        call prepareUnitSelectEvent( )
        call registerAction( KEY_UNIT_SELECT, unitTypeId, action )
    endfunction

    // '##::::'##:'##::: ##:'####:'########::::::::::'########::'########::'######::'########::::'###::::'########:::'######::'##::::'##:
    //  ##:::: ##: ###:: ##:. ##::... ##..::::::::::: ##.... ##: ##.....::'##... ##: ##.....::::'## ##::: ##.... ##:'##... ##: ##:::: ##:
    //  ##:::: ##: ####: ##:: ##::::: ##::::::::::::: ##:::: ##: ##::::::: ##:::..:: ##::::::::'##:. ##:: ##:::: ##: ##:::..:: ##:::: ##:
    //  ##:::: ##: ## ## ##:: ##::::: ##::::'#######: ########:: ######:::. ######:: ######:::'##:::. ##: ########:: ##::::::: #########:
    //  ##:::: ##: ##. ####:: ##::::: ##::::........: ##.. ##::: ##...:::::..... ##: ##...:::: #########: ##.. ##::: ##::::::: ##.... ##:
    //  ##:::: ##: ##:. ###:: ##::::: ##::::::::::::: ##::. ##:: ##:::::::'##::: ##: ##::::::: ##.... ##: ##::. ##:: ##::: ##: ##:::: ##:
    // . #######:: ##::. ##:'####:::: ##::::::::::::: ##:::. ##: ########:. ######:: ########: ##:::: ##: ##:::. ##:. ######:: ##:::: ##:
    // :.......:::..::::..::....:::::..::::::::::::::..:::::..::........:::......:::........::..:::::..::..:::::..:::......:::..:::::..::

    private function onUnitResearchComplete takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_UNIT_RESEARCH_COMPLETE] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_RESEARCH_COMPLETE, GetUnitTypeId( GetResearchingUnit( ) ) ) )
        call TriggerEvaluate( anyEvent[KEY_RESEARCH_COMPLETE] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_RESEARCH_COMPLETE, GetResearched( ) ) )
        return false
    endfunction

    globals
        private boolean isUnitResearchEventPrepared = false
    endglobals

    private function prepareUnitResearchEvent takes nothing returns nothing
        if not isUnitResearchEventPrepared then
            set isUnitResearchEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitResearchComplete ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_RESEARCH_FINISH )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 유닛이든 연구를 완료하면...
    // > ### 어떤 유닛이든 연구를 완료하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 연구 완료 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 연구 완료 이벤트](<function WhenAnyUnitResearchFinished>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 유닛이 연구 완료 이벤트](<function WhenUnitResearchFinished>)
    // ##### 1️⃣ [어떤 연구든 완료 이벤트](<function WhenAnyResearchFinished>)
    // ##### 2️⃣ [특정 타입의 연구 완료 이벤트](<function WhenResearchFinished>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitResearchFinished takes code action returns nothing
        call prepareUnitResearchEvent( )
        call registerAnyAction( KEY_UNIT_RESEARCH_COMPLETE, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 유닛이 연구를 완료하면...
    // > ### [특정 타입](<integer unitTypeId>)의 유닛이 연구를 완료하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 연구 완료 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 연구 완료 이벤트](<function WhenAnyUnitResearchFinished>)
    // ##### 2️⃣ [특정 타입의 유닛이 연구 완료 이벤트](<function WhenUnitResearchFinished>) (현재 이벤트)
    // ##### 1️⃣ [어떤 연구든 완료 이벤트](<function WhenAnyResearchFinished>)
    // ##### 2️⃣ [특정 타입의 연구 완료 이벤트](<function WhenResearchFinished>)
    // ---
    // takes
    // - integer unitTypeId 연구를 완료한 유닛의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitResearchFinished takes integer unitTypeId, code action returns nothing
        call prepareUnitResearchEvent( )
        call registerAction( KEY_UNIT_RESEARCH_COMPLETE, unitTypeId, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 연구든 완료하면...
    // > ### 어떤 연구든 완료하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 연구 완료 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 연구 완료 이벤트](<function WhenAnyUnitResearchFinished>)
    // ##### 2️⃣ [특정 타입의 유닛이 연구 완료 이벤트](<function WhenUnitResearchFinished>)
    // ##### 1️⃣ [어떤 연구든 완료 이벤트](<function WhenAnyResearchFinished>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 연구 완료 이벤트](<function WhenResearchFinished>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyResearchFinished takes code action returns nothing
        call prepareUnitResearchEvent( )
        call registerAnyAction( KEY_RESEARCH_COMPLETE, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입의 연구를 완료하면...
    // > ### [특정 타입](<integer researchTypeId>)의 연구를 완료하면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 연구 완료 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 연구 완료 이벤트](<function WhenAnyUnitResearchFinished>)
    // ##### 2️⃣ [특정 타입의 유닛이 연구 완료 이벤트](<function WhenUnitResearchFinished>)
    // ##### 1️⃣ [어떤 연구든 완료 이벤트](<function WhenAnyResearchFinished>)
    // ##### 2️⃣ [특정 타입의 연구 완료 이벤트](<function WhenResearchFinished>) (현재 이벤트)
    // ---
    // takes
    // - integer researchTypeId 완료한 연구의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenResearchFinished takes integer researchTypeId, code action returns nothing
        call prepareUnitResearchEvent( )
        call registerAction( KEY_RESEARCH_COMPLETE, researchTypeId, action )
    endfunction

    // '##::::'##:'##::: ##:'####:'########:::::::::::'#######::'##:::::'##:'##::: ##:'########:'########::
    //  ##:::: ##: ###:: ##:. ##::... ##..:::::::::::'##.... ##: ##:'##: ##: ###:: ##: ##.....:: ##.... ##:
    //  ##:::: ##: ####: ##:: ##::::: ##::::::::::::: ##:::: ##: ##: ##: ##: ####: ##: ##::::::: ##:::: ##:
    //  ##:::: ##: ## ## ##:: ##::::: ##::::'#######: ##:::: ##: ##: ##: ##: ## ## ##: ######::: ########::
    //  ##:::: ##: ##. ####:: ##::::: ##::::........: ##:::: ##: ##: ##: ##: ##. ####: ##...:::: ##.. ##:::
    //  ##:::: ##: ##:. ###:: ##::::: ##::::::::::::: ##:::: ##: ##: ##: ##: ##:. ###: ##::::::: ##::. ##::
    // . #######:: ##::. ##:'####:::: ##:::::::::::::. #######::. ###. ###:: ##::. ##: ########: ##:::. ##:
    // :.......:::..::::..::....:::::..:::::::::::::::.......::::...::...:::..::::..::........::..:::::..::

    private function onUnitOwnerChange takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_UNIT_OWNER_CHANGE] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_UNIT_OWNER_CHANGE, GetUnitTypeId( GetTriggerUnit( ) ) ) )
        return false
    endfunction

    globals
        private boolean isUnitOwnerChangeEventPrepared = false
    endglobals

    private function prepareUnitOwnerChangeEvent takes nothing returns nothing
        if not isUnitOwnerChangeEventPrepared then
            set isUnitOwnerChangeEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onUnitOwnerChange ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_CHANGE_OWNER )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 어떤 유닛이든 소유자가 변경되면...
    // > ### 어떤 유닛이든 소유자가 변경되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 소유자 변경 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 소유자 변경 이벤트](<function WhenAnyUnitOwnerChanged>) (현재 이벤트)
    // ##### 2️⃣ [특정 타입의 유닛 소유자 변경 이벤트](<function WhenUnitOwnerChanged>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyUnitOwnerChanged takes code action returns nothing
        call prepareUnitOwnerChangeEvent( )
        call registerAnyAction( KEY_UNIT_OWNER_CHANGE, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 타입 유닛의 소유자가 변경되면...
    // > ### [특정 타입](<integer unitTypeId>) 유닛의 소유자가 변경되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 소유자 변경 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [어떤 유닛이든 소유자 변경 이벤트](<function WhenAnyUnitOwnerChanged>)
    // ##### 2️⃣ [특정 타입의 유닛 소유자 변경 이벤트](<function WhenUnitOwnerChanged>) (현재 이벤트)
    // ---
    // takes
    // - integer unitTypeId 소유자 변경된 유닛의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenUnitOwnerChanged takes integer unitTypeId, code action returns nothing
        call prepareUnitOwnerChangeEvent( )
        call registerAction( KEY_UNIT_OWNER_CHANGE, unitTypeId, action )
    endfunction

    // '##::::'##:'########:'########:::'#######:::::::::::'##:::::::'########::::'###::::'########::'##::: ##:
    //  ##:::: ##: ##.....:: ##.... ##:'##.... ##:::::::::: ##::::::: ##.....::::'## ##::: ##.... ##: ###:: ##:
    //  ##:::: ##: ##::::::: ##:::: ##: ##:::: ##:::::::::: ##::::::: ##::::::::'##:. ##:: ##:::: ##: ####: ##:
    //  #########: ######::: ########:: ##:::: ##:'#######: ##::::::: ######:::'##:::. ##: ########:: ## ## ##:
    //  ##.... ##: ##...:::: ##.. ##::: ##:::: ##:........: ##::::::: ##...:::: #########: ##.. ##::: ##. ####:
    //  ##:::: ##: ##::::::: ##::. ##:: ##:::: ##:::::::::: ##::::::: ##::::::: ##.... ##: ##::. ##:: ##:. ###:
    //  ##:::: ##: ########: ##:::. ##:. #######::::::::::: ########: ########: ##:::: ##: ##:::. ##: ##::. ##:
    // ..:::::..::........::..:::::..:::.......::::::::::::........::........::..:::::..::..:::::..::..::::..::

    private function onHeroLearn takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_HERO_LEARN] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_HERO_LEARN, GetLearnedSkill( ) ) )
        return false
    endfunction

    globals
        private boolean isHeroLearnEventPrepared = false
    endglobals

    private function prepareHeroLearnEvent takes nothing returns nothing
        if not isHeroLearnEventPrepared then
            set isHeroLearnEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onHeroLearn ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_HERO_SKILL )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 영웅이 스킬을 배우면...
    // > ### 영웅이 스킬을 배우면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 스킬 배우기 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [영웅이 스킬을 배우면 이벤트](<function WhenAnyHeroSkillLearned>) (현재 이벤트)
    // ##### 2️⃣ [특정 스킬을 배우면 이벤트](<function WhenHeroSkillLearned>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnyHeroSkillLearned takes code action returns nothing
        call prepareHeroLearnEvent( )
        call registerAnyAction( KEY_HERO_LEARN, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 스킬을 배우면...
    // > ### [특정 스킬](<integer abilityTypeId>)을 배우면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 스킬 배우기 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [영웅이 스킬을 배우면 이벤트](<function WhenAnyHeroSkillLearned>)
    // ##### 2️⃣ [특정 스킬을 배우면 이벤트](<function WhenHeroSkillLearned>) (현재 이벤트)
    // ---
    // takes
    // - integer abilityTypeId 배운 스킬의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenHeroSkillLearned takes integer abilityTypeId, code action returns nothing
        call prepareHeroLearnEvent( )
        call registerAction( KEY_HERO_LEARN, abilityTypeId, action )
    endfunction

    // :'######::'########::'########:'##:::::::'##::::::::::::::::'########:'########:'########:'########::'######::'########:
    // '##... ##: ##.... ##: ##.....:: ##::::::: ##:::::::::::::::: ##.....:: ##.....:: ##.....:: ##.....::'##... ##:... ##..::
    //  ##:::..:: ##:::: ##: ##::::::: ##::::::: ##:::::::::::::::: ##::::::: ##::::::: ##::::::: ##::::::: ##:::..::::: ##::::
    // . ######:: ########:: ######::: ##::::::: ##:::::::'#######: ######::: ######::: ######::: ######::: ##:::::::::: ##::::
    // :..... ##: ##.....::: ##...:::: ##::::::: ##:::::::........: ##...:::: ##...:::: ##...:::: ##...:::: ##:::::::::: ##::::
    // '##::: ##: ##:::::::: ##::::::: ##::::::: ##:::::::::::::::: ##::::::: ##::::::: ##::::::: ##::::::: ##::: ##:::: ##::::
    // . ######:: ##:::::::: ########: ########: ########:::::::::: ########: ##::::::: ##::::::: ########:. ######::::: ##::::
    // :......:::..:::::::::........::........::........:::::::::::........::..::::::::..::::::::........:::......::::::..:::::

    private function onSpellEffect takes nothing returns boolean
        call TriggerEvaluate( anyEvent[KEY_SPELL_EFFECT] )
        call TriggerEvaluate( LoadTriggerHandle( eventTable, KEY_SPELL_EFFECT, GetSpellAbilityId( ) ) )
        return false
    endfunction

    globals
        private boolean isSpellEffectEventPrepared = false
    endglobals

    private function prepareSpellEffectEvent takes nothing returns nothing
        if not isSpellEffectEventPrepared then
            set isSpellEffectEventPrepared = true
            set lastCreatedTrigger = CreateTrigger( )
            call TriggerAddCondition( lastCreatedTrigger, Condition( function onSpellEffect ) )
            call TriggerRegisterAnyUnitEventBJ( lastCreatedTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT )
        endif
    endfunction

    // ---
    // ## 🚩 이벤트 - 아무 능력이든 효과가 시작되면...
    // > ### 아무 능력이든 효과가 시작되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 능력 효과 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [아무 능력이든 효과가 시작되면 이벤트](<function WhenAnySpellEffect>) (현재 이벤트)
    // ##### 2️⃣ [특정 능력 효과가 시작되면 이벤트](<function WhenSpellEffect>)
    // ---
    // takes
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenAnySpellEffect takes code action returns nothing
        call prepareSpellEffectEvent( )
        call registerAnyAction( KEY_SPELL_EFFECT, action )
    endfunction

    // ---
    // ## 🚩 이벤트 - 특정 능력 효과가 시작되면...
    // > ### [특정 능력](<integer abilityTypeId>) 효과가 시작되면 [액션](<code action>)을 실행합니다
    // ---
    // ##### ⚠️ 능력 효과 이벤트의 우선도는 아래와 같습니다
    // ##### 1️⃣ [아무 능력이든 효과가 시작되면 이벤트](<function WhenAnySpellEffect>)
    // ##### 2️⃣ [특정 능력 효과가 시작되면 이벤트](<function WhenSpellEffect>) (현재 이벤트)
    // ---
    // takes
    // - integer abilityTypeId 효과가 시작된 능력의 타입
    // - code action 실행할 액션
    // returns
    // - nothing
    function WhenSpellEffect takes integer abilityTypeId, code action returns nothing
        call prepareSpellEffectEvent( )
        call registerAction( KEY_SPELL_EFFECT, abilityTypeId, action )
    endfunction

    
    // '########:'####:'##::::'##:'########:'########::
    // ... ##..::. ##:: ###::'###: ##.....:: ##.... ##:
    // ::: ##::::: ##:: ####'####: ##::::::: ##:::: ##:
    // ::: ##::::: ##:: ## ### ##: ######::: ########::
    // ::: ##::::: ##:: ##. #: ##: ##...:::: ##.. ##:::
    // ::: ##::::: ##:: ##:.:: ##: ##::::::: ##::. ##::
    // ::: ##::::'####: ##:::: ##: ########: ##:::. ##:
    // :::..:::::....::..:::::..::........::..:::::..::

    function WhenTimer takes real timeout, boolean periodic, code action returns nothing
        local trigger t = CreateTrigger( )
        call TriggerAddAction( t, action )
        call TriggerRegisterTimerEvent( t, timeout, periodic )
    endfunction

    function WhenTimerSingle takes real timeout, code action returns nothing
        local trigger t = CreateTrigger( )
        call TriggerAddAction( t, action )
        call TriggerRegisterTimerEvent( t, timeout, false )
    endfunction

    function WhenTimerPeriodic takes real timeout, code action returns nothing
        local trigger t = CreateTrigger( )
        call TriggerAddAction( t, action )
        call TriggerRegisterTimerEvent( t, timeout, true )
    endfunction

endlibrary
