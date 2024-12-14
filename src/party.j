// ---
// # Party 라이브러리
//
// > 이 라이브러리는 Warcraft III의 `group` 자료구조를 효율적으로 관리하기 위한 래퍼(wrapper)로, 
// > 그룹의 생성 및 파괴로 인한 메모리 부하를 줄이고 성능을 최적화합니다. 
// > 유닛 그룹을 생성하고 관리하는 기능을 제공하며, 그룹 내 유닛 추가 및 제거 등을 간편하게 처리할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [party.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/party.j)
//
// ## 버전
// - **Version**: 20240904.0
//
// ## Changelog
// - **2024-09-04**: 초기 릴리스. 그룹 관리 기능 제공.
//
// ## 주요 기능:
// - **그룹 생성 및 관리**: `party`라는 추상화된 자료구조로 `group`의 생성, 삭제, 초기화, 유닛 추가 및 제거.
// - **메모리 부하 감소**: `group`의 빈번한 생성과 파괴로 인한 메모리 할당/해제를 최적화.
//
// ## 활용 시나리오:
// - 게임 내에서 대규모 유닛 그룹을 생성, 관리할 때 효율적인 그룹 관리 메커니즘 제공.
// - 유닛 그룹을 자주 추가, 제거, 초기화해야 하는 상황에서 성능을 최적화.
//
// ## 문제해결:
// - 만약 그룹에 유닛이 정상적으로 추가/제거되지 않거나 그룹이 파괴되지 않는다면, `GROUPS` 배열의 인덱스가 올바르게 설정되었는지 확인하세요.
// ---
library party initializer onInit

    // ## 인덱서를 위한 구조체
    // 파티 인덱스를 관리하는 구조체입니다.
    private struct INDEXER
    endstruct

    globals
        // 항상 참인 필터
        private boolexpr FILTER_TRUE = null

        // 그룹을 저장하는 배열
        private group array GROUPS
    endglobals

    private function alwaysTrue takes nothing returns boolean
        return true
    endfunction

    private function onInit takes nothing returns nothing
        set FILTER_TRUE = Filter( function alwaysTrue )
    endfunction

    private function PartyPickRandomUnitEnum takes nothing returns nothing
        set bj_groupRandomConsidered = bj_groupRandomConsidered + 1
        if(GetRandomInt(1, bj_groupRandomConsidered) == 1) then
            set bj_groupRandomCurrentPick = GetEnumUnit()
        endif
    endfunction

    // ## 파티 구조체
    // 그룹을 관리하는 파티 자료구조를 정의합니다.
    struct party extends array
    endstruct

    // ## 파티 - 새 파티 생성
    // 새로운 파티를 생성합니다.
    function PartyCreate takes nothing returns party
        local party this = INDEXER.create()
        if GROUPS[this] == null then
            set GROUPS[this] = CreateGroup()
        endif
        return this
    endfunction

    // ## 파티 - 초기화
    // (파티)를 텅 비웁니다.
    function PartyClear takes party this returns nothing
        call GroupClear( GROUPS[this] )
    endfunction

    // ## 파티 - 파티 파괴
    // (파티)를 파괴하여 메모리를 확보합니다.
    function PartyDestroy takes party this returns nothing
        call GroupClear( GROUPS[this] )
        call INDEXER.destroy( this )
    endfunction

    // ## 파티 - 유닛 추가
    // (파티)에 (유닛)을 추가합니다.
    function PartyAddUnit takes party this, unit u returns nothing
        call GroupAddUnit( GROUPS[this], u )
    endfunction

    // ## 파티 - 유닛 제거
    // (파티)에서 (유닛)을 제거합니다.
    function PartyRemoveUnit takes party this, unit u returns nothing
        call GroupRemoveUnit( GROUPS[this], u )
    endfunction

    // ## 파티 - 유닛이 포함됨
    // (파티)에 (유닛)이 포함되어 있는지 확인합니다.
    function PartyContains takes party this, unit u returns boolean
        return IsUnitInGroup( u, GROUPS[this] )
    endfunction

    // ## 파티 - 원형 범위 내 유닛들로 재설정
    // (파티)의 내용물을 (x), (y) 중심으로 (범위) 내의 유닛들로 재설정합니다.
    function PartyEnumUnitsInRange takes party this, real x, real y, real range returns nothing 
        call GroupEnumUnitsInRange( GROUPS[this], x, y, range, FILTER_TRUE )
    endfunction

    // ## 파티 - 원형 범위 내 유닛들로 재설정 (필터 포함)
    // (파티)의 내용물을 (x), (y) 중심으로 (범위) 내의 (조건)에 맞는 유닛들로 재설정합니다.
    function PartyEnumUnitsInRangeEx takes party this, real x, real y, real range, boolexpr filter returns nothing
        call GroupEnumUnitsInRange( GROUPS[this], x, y, range, filter )
    endfunction

    // ## 파티 - 구역 위 유닛들로 재설정
    // (파티)의 내용물을 (구역) 위의 유닛들로 재설정합니다.
    function PartyEnumUnitsInRect takes party this, rect r returns nothing
        call GroupEnumUnitsInRect( GROUPS[this], r, FILTER_TRUE )
    endfunction

    // ## 파티 - 구역 위 유닛들로 재설정 (필터 포함)
    // (파티)의 내용물을 (구역) 위의 (조건)에 맞는 유닛들로 재설정합니다.
    function PartyEnumUnitsInRectEx takes party this, rect r, boolexpr filter returns nothing
        call GroupEnumUnitsInRect( GROUPS[this], r, filter )
    endfunction

    // ## 파티 - 플레이어의 유닛들로 재설정
    // (파티)의 내용물을 (플레이어) 소유의 유닛들로 재설정합니다.
    function PartyEnumUnitsOfPlayer takes party this, player p returns nothing
        call GroupEnumUnitsOfPlayer( GROUPS[this], p, FILTER_TRUE )
    endfunction

    // ## 파티 - 플레이어의 유닛들로 재설정 (필터 포함)
    // (파티)의 내용물을 (플레이어) 소유의 (조건)에 맞는 유닛들로 재설정합니다.
    function PartyEnumUnitsOfPlayerEx takes party this, player p, boolexpr filter returns nothing
        call GroupEnumUnitsOfPlayer( GROUPS[this], p, filter )
    endfunction

    // ## 파티 - 랜덤 유닛 선택
    // (파티)에서 랜덤하게 유닛을 선택합니다.
    function PartyPickRandomUnit takes party this returns unit
        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 범위 내 랜덤 유닛 선택
    // (x), (y) 중심으로 (범위) 내에서 랜덤하게 유닛을 선택합니다.
    function PartyPickRandomUnitInRange takes real x, real y, real range returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsInRange( GROUPS[this], x, y, range, FILTER_TRUE )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 범위 내 랜덤 유닛 선택 (필터 포함)
    // (x), (y) 중심으로 (범위) 내에서 (조건)에 맞는 유닛 중 랜덤하게 하나를 선택합니다.
    function PartyPickRandomUnitInRangeEx takes real x, real y, real range, boolexpr filter returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsInRange( GROUPS[this], x, y, range, filter )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 구역 내 랜덤 유닛 선택
    // (구역) 내에서 랜덤하게 유닛을 선택합니다.
    function PartyPickRandomUnitInRect takes rect r returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsInRect( GROUPS[this], r, FILTER_TRUE )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 구역 내 랜덤 유닛 선택 (필터 포함)
    // (구역) 내에서 (조건)에 맞는 유닛 중 랜덤하게 하나를 선택합니다.
    function PartyPickRandomUnitInRectEx takes rect r, boolexpr filter returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsInRect( GROUPS[this], r, filter )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 플레이어의 랜덤 유닛 선택
    // (플레이어) 소유의 유닛 중 랜덤하게 하나를 선택합니다.
    function PartyPickRandomUnitOfPlayer takes player p returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsOfPlayer( GROUPS[this], p, FILTER_TRUE )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

    // ## 파티 - 플레이어의 랜덤 유닛 선택 (필터 포함)
    // (플레이어) 소유의 (조건)에 맞는 유닛 중 랜덤하게 하나를 선택합니다.
    function PartyPickRandomUnitOfPlayerEx takes player p, boolexpr filter returns unit
        local party this = PartyCreate( )
        call GroupEnumUnitsOfPlayer( GROUPS[this], p, filter )

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup( GROUPS[this], function GroupPickRandomUnitEnum )
        call PartyDestroy( this )
        return bj_groupRandomCurrentPick
    endfunction

endlibrary
