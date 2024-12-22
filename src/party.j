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
// - **Version**: 20241222.0
//
// ## Changelog
// - **2024-12-22**: 복제/일괄 추가 기능 추가, 인스턴스 풀링, 코드 정리
// - **2024-09-04**: 초기 릴리스
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
        // 미리 생성한 파티 수량
        private constant integer PARTY_QUANTITY = 1024

        // 항상 참인 필터
        private boolexpr FILTER_TRUE = null

        // 그룹을 저장하는 배열
        private group array GROUPS
    endglobals

    private function initInstancePool takes nothing returns nothing
        local integer i = 1
        loop
            exitwhen i > PARTY_QUANTITY
            set GROUPS[i] = CreateGroup()
            set i = i + 1
        endloop
    endfunction

    private function alwaysTrue takes nothing returns boolean
        return true
    endfunction

    private function onInit takes nothing returns nothing
        set FILTER_TRUE = Filter( function alwaysTrue )
        call initInstancePool()
    endfunction

    // ---
    // ## 👥 파티
    // > ### 재사용성을 높이고 핸들 참조를 줄이기 위한 [유닛 그룹](<type group extends agent>) 유틸리티
    // ---
    // ##### ℹ️ 파티는 [유닛 그룹](<type group extends agent>)을 효율적으로 관리하기 위한 데이터 구조입니다
    // ##### ℹ️ 파티는 1 ~ [8191](<배열 크기 한계>)까지의 핸들값을 갖습니다
    // ##### ℹ️ null check를 수행하려면 `== 0`을 사용할 수 있습니다
    // ##### ⚠️ 동시에 [8192](<배열 크기 한계>)개 이상의 파티는 존재할 수 없으므로 생성 및 파괴 시 주의해야 합니다
    // ##### 🚨 핸들값을 직접 할당하는 접근 방식은 사용하지 마세요! 예: `local party p = 3`
    // ---
    struct party extends array
    endstruct

    // ---
    // ## 👥 파티 - 생성
    // > ### 새로운 파티를 생성합니다
    // ---
    // ##### ⚠️ 동시에 [8192](<배열 크기 한계>)개 이상의 파티는 존재할 수 없으며, 이 경우 [0](<=null>)을 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - party 생성된 파티
    // ---
    function PartyCreate takes nothing returns party
        local party this = INDEXER.create()
        if GROUPS[this] == null then
            set GROUPS[this] = CreateGroup()
        endif
        return this
    endfunction

    // ---
    // ## 👥 파티 - 초기화
    // > ### [파티](<party whichParty>)를 텅 비웁니다
    // ---
    // takes
    // - party this 초기화할 파티
    // returns
    // - nothing
    // ---
    function PartyClear takes party whichParty returns nothing
        call GroupClear(GROUPS[whichParty])
    endfunction

    // ---
    // ## 👥 파티 - 파괴
    // > ### [파티](<party whichParty>)를 파괴하여 메모리를 확보합니다
    // ---
    // takes
    // - party this 파괴할 파티
    // returns
    // - nothing
    // ---
    function PartyDestroy takes party whichParty returns nothing
        call GroupClear(GROUPS[whichParty])
        call INDEXER.destroy(whichParty)
    endfunction

    // ---
    // ## 👥 파티 - 유닛 추가
    // > ### [파티](<party whichParty>)에 [유닛](<unit whichUnit>)을 추가합니다
    // ---
    // ##### ℹ️ 유닛이 이미 파티에 속해 있는 경우 추가되지 않습니다
    // ---
    // takes
    // - party whichParty 유닛을 추가할 파티
    // - unit whichUnit 추가할 유닛
    // returns
    // - nothing
    // ---
    function PartyAddUnit takes party whichParty, unit whichUnit returns nothing
        call GroupAddUnit(GROUPS[whichParty], whichUnit)
    endfunction

    // ---
    // ## 👥 파티 - 유닛 제거
    // > ### [파티](<party whichParty>)에서 [유닛](<unit whichUnit>)을 제거합니다
    // ---
    // ##### ℹ️ 파티에 해당 유닛이 포함되어 있지 않은 경우 아무 작업도 수행하지 않습니다
    // ---
    // takes
    // - party whichParty 유닛을 제거할 파티
    // - unit whichUnit 제거할 유닛
    // returns
    // - nothing
    // ---
    function PartyRemoveUnit takes party whichParty, unit whichUnit returns nothing
        call GroupRemoveUnit(GROUPS[whichParty], whichUnit)
    endfunction

    // ---
    // ## 👥 파티 - 유닛 포함 여부 확인
    // > ### [파티](<party whichParty>)에 [유닛](<unit whichUnit>)이 포함되어 있는지 확인합니다
    // ---
    // takes
    // - party whichParty 확인할 파티
    // - unit whichUnit 확인할 유닛
    // returns
    // - boolean 유닛이 포함되어 있으면 true, 그렇지 않으면 false
    // ---
    function PartyContains takes party whichParty, unit whichUnit returns boolean
        return IsUnitInGroup(whichUnit, GROUPS[whichParty])
    endfunction

    // ---
    // ## 👥 파티 - 일괄 처리
    // > ### [파티](<party whichParty>)의 모든 유닛에 대해 [코드](<code action>)를 실행합니다
    // ---
    // takes
    // - party whichParty 대상 파티
    // - code action 실행할 코드
    // returns
    // - nothing
    // ---
    function ForParty takes party whichParty, code action returns nothing
        call ForGroup(GROUPS[whichParty], action)
    endfunction

    // ---
    // ## 👥 파티 - 첫 번째 유닛
    // > ### [파티](<party whichParty>)의 첫 번째 유닛을 반환합니다
    // ---
    // ##### ℹ️ [파티](<party whichParty>) 내 유닛이 없는 경우 `null` 값을 반환합니다
    // ---
    // takes
    // - party whichParty 대상 파티
    // returns
    // - unit 첫 번째 유닛
    // ---
    function FirstOfParty takes party whichParty returns unit
        return FirstOfGroup(GROUPS[whichParty])
    endfunction

    // ---
    // ## 👥 파티 - 원형 범위 유닛 설정
    // > ### [파티](<party whichParty>)의 내용물을 ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // returns
    // - nothing
    // ---
    function PartyEnumUnitsInRange takes party whichParty, real x, real y, real range returns nothing
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, FILTER_TRUE)
    endfunction

    // ---
    // ## 👥 파티 - 원형 범위 유닛 설정 (필터 포함)
    // > ### [파티](<party whichParty>)의 내용물을 ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내 [조건](<boolexpr filter>)에 맞는 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - nothing
    // --- 
    function PartyEnumUnitsInRangeEx takes party whichParty, real x, real y, real range, boolexpr filter returns nothing
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, filter)
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 유닛 설정
    // > ### [파티](<party whichParty>)의 내용물을 [구역](<rect r>) 내 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - rect r 설정할 구역
    // returns
    // - nothing
    // ---
    function PartyEnumUnitsInRect takes party whichParty, rect r returns nothing
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, FILTER_TRUE)
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 유닛 설정 (필터 포함)
    // > ### [파티](<party whichParty>)의 내용물을 [구역](<rect r>) 내 [조건](<boolexpr filter>)에 맞는 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - rect r 설정할 구역
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - nothing
    // ---
    function PartyEnumUnitsInRectEx takes party whichParty, rect r, boolexpr filter returns nothing
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, filter)
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 유닛 설정
    // > ### [파티](<party whichParty>)의 내용물을 [플레이어](<player whichPlayer>) 소유의 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - player whichPlayer 설정할 플레이어
    // returns
    // - nothing
    // ---
    function PartyEnumUnitsOfPlayer takes party whichParty, player whichPlayer returns nothing
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, FILTER_TRUE)
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 유닛 설정 (필터 포함)
    // > ### [파티](<party whichParty>)의 내용물을 [플레이어](<player whichPlayer>) 소유의 [조건](<boolexpr filter>)에 맞는 유닛들로 재설정합니다
    // ---
    // takes
    // - party whichParty 유닛을 설정할 파티
    // - player whichPlayer 설정할 플레이어
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - nothing
    // ---
    function PartyEnumUnitsOfPlayerEx takes party whichParty, player whichPlayer, boolexpr filter returns nothing
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, filter)
    endfunction

    // ---
    // ## 👥 파티 - 파티 병합
    // > ### [파티](<party destParty>)에 [다른 파티](<party sourceParty>)의 모든 유닛을 추가합니다
    // ---
    // takes
    // - party destParty 병합할 대상 파티
    // - party sourceParty 병합할 원본 파티
    // returns
    // - nothing
    // ---
    function PartyAddParty takes party destParty, party sourceParty returns nothing
        set bj_groupAddGroupDest = GROUPS[destParty]
        call ForGroup(GROUPS[sourceParty], function GroupAddGroupEnum)
    endfunction

    // ---
    // ## 👥 파티 - 그룹 병합
    // > ### [파티](<party destParty>)에 [그룹](<group sourceGroup>)의 모든 유닛을 추가합니다
    // ---
    // takes
    // - party destParty 병합할 대상 파티
    // - group sourceGroup 병합할 원본 그룹
    // returns
    // - nothing
    // ---
    function PartyAddGroup takes party destParty, group sourceGroup returns nothing
        set bj_groupAddGroupDest = GROUPS[destParty]
        call ForGroup(sourceGroup, function GroupAddGroupEnum)
    endfunction

    // ---
    // ## 👥 파티 - 파티 복사
    // > ### [파티](<party whichParty>)의 유닛을 포함하는 새 파티를 생성합니다
    // ---
    // takes
    // - party whichParty 복사할 원본 파티
    // returns
    // - party 복사된 새 파티
    // ---
    function PartyCopy takes party whichParty returns party
        local party newParty = PartyCreate()
        set bj_groupAddGroupDest = GROUPS[newParty]
        call ForGroup(GROUPS[whichParty], function GroupAddGroupEnum)
        return newParty
    endfunction

    // ---
    // ## 👥 파티 - 랜덤 유닛 선택
    // > ### [파티](<party whichParty>)에서 랜덤하게 유닛을 선택합니다
    // ---
    // takes
    // - party whichParty 랜덤 유닛을 선택할 파티
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnit takes party whichParty returns unit
        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 범위 내 랜덤 유닛 선택
    // > ### ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내에서 랜덤하게 유닛을 선택합니다
    // ---
    // takes
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitInRange takes real x, real y, real range returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, FILTER_TRUE)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 범위 내 랜덤 유닛 선택 (필터 포함)
    // > ### ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내 [조건](<boolexpr filter>)에 맞는 유닛 중 랜덤하게 하나를 선택합니다
    // ---
    // takes
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitInRangeEx takes real x, real y, real range, boolexpr filter returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, filter)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 랜덤 유닛 선택
    // > ### [구역](<rect r>) 내에서 랜덤하게 유닛을 선택합니다
    // ---
    // takes
    // - rect r 랜덤 유닛을 선택할 구역
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitInRect takes rect r returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, FILTER_TRUE)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 랜덤 유닛 선택 (필터 포함)
    // > ### [구역](<rect r>) 내 [조건](<boolexpr filter>)에 맞는 유닛 중 랜덤하게 하나를 선택합니다
    // ---
    // takes
    // - rect r 랜덤 유닛을 선택할 구역
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitInRectEx takes rect r, boolexpr filter returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, filter)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 랜덤 유닛 선택
    // > ### [플레이어](<player whichPlayer>) 소유의 유닛 중 랜덤하게 하나를 선택합니다
    // ---
    // takes
    // - player whichPlayer 랜덤 유닛을 선택할 플레이어
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitOfPlayer takes player whichPlayer returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, FILTER_TRUE)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 랜덤 유닛 선택 (필터 포함)
    // > ### [플레이어](<player whichPlayer>) 소유의 [조건](<boolexpr filter>)에 맞는 유닛 중 랜덤하게 하나를 선택합니다
    // ---
    // takes
    // - player whichPlayer 랜덤 유닛을 선택할 플레이어
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - unit 선택된 유닛
    // ---
    function PartyPickRandomUnitOfPlayerEx takes player whichPlayer, boolexpr filter returns unit
        local party whichParty = PartyCreate()
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, filter)

        set bj_groupRandomConsidered = 0
        set bj_groupRandomCurrentPick = null
        call ForGroup(GROUPS[whichParty], function GroupPickRandomUnitEnum)
        call PartyDestroy(whichParty)
        return bj_groupRandomCurrentPick
    endfunction

    // ---
    // ## 👥 파티 - 그룹 내 유닛 변환
    // > ### [그룹](<group g>)에 포함된 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - group g 변환할 유닛 그룹
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsInGroup takes group g returns party
        local party whichParty = PartyCreate()
        set bj_groupAddGroupDest = GROUPS[whichParty]
        call ForGroup(g, function GroupAddGroupEnum)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 범위 내 유닛 변환
    // > ### ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsInRange takes real x, real y, real range returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, FILTER_TRUE)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 범위 내 유닛 변환 (필터 포함)
    // > ### ([x](<real x>), [y](<real y>)) 중심의 [범위](<real range>) 내 [조건](<boolexpr filter>)에 맞는 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - real x 범위 중심의 x 좌표
    // - real y 범위 중심의 y 좌표
    // - real range 범위 크기
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsInRangeEx takes real x, real y, real range, boolexpr filter returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRange(GROUPS[whichParty], x, y, range, filter)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 유닛 변환
    // > ### [구역](<rect r>) 내 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - rect r 변환할 구역
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsInRect takes rect r returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, FILTER_TRUE)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 구역 내 유닛 변환 (필터 포함)
    // > ### [구역](<rect r>) 내 [조건](<boolexpr filter>)에 맞는 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - rect r 변환할 구역
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsInRectEx takes rect r, boolexpr filter returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsInRect(GROUPS[whichParty], r, filter)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 유닛 변환
    // > ### [플레이어](<player whichPlayer>) 소유의 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - player whichPlayer 변환할 플레이어
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsOfPlayer takes player whichPlayer returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, FILTER_TRUE)
        return whichParty
    endfunction

    // ---
    // ## 👥 파티 - 플레이어 유닛 변환 (필터 포함)
    // > ### [플레이어](<player whichPlayer>) 소유의 [조건](<boolexpr filter>)에 맞는 유닛을 새로운 파티로 만들어 반환합니다
    // ---
    // takes
    // - player whichPlayer 변환할 플레이어
    // - boolexpr filter 유닛 필터 조건
    // returns
    // - party 변환된 파티
    // ---
    function PartyOfUnitsOfPlayerEx takes player whichPlayer, boolexpr filter returns party
        local party whichParty = PartyCreate()
        call GroupEnumUnitsOfPlayer(GROUPS[whichParty], whichPlayer, filter)
        return whichParty
    endfunction

endlibrary
