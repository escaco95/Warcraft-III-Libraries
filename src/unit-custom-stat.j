// ---
// # Unit Custom Stat 라이브러리
//
// > 이 라이브러리는 유닛의 커스텀 스탯(예: 공격력, 방어력, 속도 등)을 관리하고 조작하기 위한 기능을 제공합니다.
// > 이러한 스탯은 기본적인 Warcraft III 유닛 속성을 보완하거나 대체할 수 있습니다.
//
// ## 주요 기능:
// - CustomStatSet: 유닛의 특정 커스텀 스탯 값을 설정합니다.
// - CustomStatAdd: 유닛의 특정 커스텀 스탯에 값을 추가합니다.
// - CustomStatGet: 유닛의 특정 커스텀 스탯 값을 반환합니다.
// - CustomStatReset: 유닛의 특정 커스텀 스탯을 초기화합니다.
// - CustomStatClear: 유닛의 모든 커스텀 스탯 데이터를 제거합니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**:  escaco95@naver.com
// - **GitHub**: [unit-custom-stat.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/unit-custom-stat.j)
//
// ## 버전
// - **Version**: 20241222.0
//
// ## Changelog
// - **2024-12-22**: 라이브러리 전체 주석 추가 및 정리. 초기화 및 데이터 삭제 관련 함수 설명 개선.
// ---
library UnitCustomStat initializer onInit

    globals
        private hashtable UNITS = InitHashtable()
        private hashtable STATS = InitHashtable()

        // 마지막으로 할당된 스탯 ID (영구적으로 증가)
        // -- 이는 스탯 ID의 중복을 방지하기 위한 방어책입니다.
        // -- 이에 대한 부작용으로 2147483647 이상의 스탯 ID를 할당할 수 없습니다. (즉, 반드시 오동작합니다)
        // -- 이 라이브러리 사용 시 반드시 유닛을 2147483647 개 이상 생성하기 전에 게임이 끝나도록 설계해야 합니다.
        // -- 하지만 현실적으로 7일 내내 1초 마다 1000개의 유닛을 처치하더라도 604800000(6억) 핸들이므로 너무 걱정하지 않아도 됩니다.
        private integer last_stat_id = 0

        // 스탯 회수 대기열
        // -- 스탯 회수 대기열이 유닛 핸들을 붙잡음으로써 워크래프트가 유닛의 핸들값을 재사용하지 못하도록 합니다.
        // -- 이는 커스텀 스탯 라이브러리 몰래 워크래프트가 유닛의 핸들값을 재사용하는 것을 방지하기 위한 방어책입니다.
        // -- 이에 대한 부작용으로 핸들값 재사용 회전율이 이 라이브러리의 GC 동작 간격에 의해 결정됩니다.
        private integer array gc_statIds
        private unit array gc_units
        private integer gc_count = 0
        private constant real GC_TIMEOUT = 1.00
        private constant integer GC_BATCH = 50
        private trigger gc_trigger
        private integer gc_index = 0

        // 임시 변수
        private integer stat_id
        private integer stat_value
    endglobals

    private function onGC takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= GC_BATCH
            if gc_index >= gc_count then
                set gc_index = 0
                return
            endif
            if GetUnitTypeId(gc_units[gc_index]) == 0 then
                call RemoveSavedInteger(UNITS, 0, GetHandleId(gc_units[gc_index]))
                call FlushChildHashtable(STATS, gc_statIds[gc_index])
                // pull last item
                set gc_count = gc_count - 1
                if gc_count > 0 then
                    set gc_statIds[gc_index] = gc_statIds[gc_count]
                    set gc_units[gc_index] = gc_units[gc_count]
                endif
                set gc_statIds[gc_count] = 0
                set gc_units[gc_count] = null
            else
                set gc_index = gc_index + 1
            endif
            set i = i + 1
        endloop
    endfunction

    private function onInit takes nothing returns nothing
        // GC 초기화
        set gc_trigger = CreateTrigger()
        call TriggerAddAction(gc_trigger, function onGC)
        call TriggerRegisterTimerEvent(gc_trigger, GC_TIMEOUT, true)
    endfunction

    private function PrepareStatHandleId takes unit whichUnit returns nothing
        set stat_id = LoadInteger(UNITS, 0, GetHandleId(whichUnit))
        if stat_id != 0 then
            return
        endif
        // 스탯 ID 할당
        set last_stat_id = last_stat_id + 1
        call SaveInteger(UNITS, 0, GetHandleId(whichUnit), last_stat_id)
        set stat_id = last_stat_id
        // 스탯 회수 대기열에 추가
        set gc_statIds[gc_count] = stat_id
        set gc_units[gc_count] = whichUnit
        set gc_count = gc_count + 1
    endfunction

    // ---
    // ## 🧊 커스텀 스탯 - 스탯 설정
    // > ### [유닛](<unit whichUnit>) 의 [커스텀 스탯](<integer customStatCode>) 을 [값](<integer value>) 으로 설정합니다.
    // ---
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 유즈맵 제작자가 임의로 정의할 수 있는 스탯 코드입니다.
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 [정수 범위](<-2147483648 ~ 2147483647>) 내의 값을 모두 사용할 수 있습니다.
    // ##### ⚠️ [제거된 유닛](<GetUnitTypeId(whichUnit) == 0>) 은 무시되며 0 을 반환합니다.
    // ---
    // takes
    // - unit whichUnit
    // - integer customStatCode
    // - integer value
    // returns
    // - integer 설정된 스탯 값
    function CustomStatSet takes unit whichUnit, integer customStatCode, integer value returns integer
        if GetUnitTypeId(whichUnit) == 0 then
            return 0
        endif

        call PrepareStatHandleId(whichUnit)
        call SaveInteger(STATS, stat_id, customStatCode, value)

        return value
    endfunction

    // ---
    // ## 🧊 커스텀 스탯 - 스탯 추가
    // > ### [유닛](<unit whichUnit>) 의 [커스텀 스탯](<integer customStatCode>) 을 [값](<integer delta>) 만큼 추가합니다.
    // ---
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 유즈맵 제작자가 임의로 정의할 수 있는 스탯 코드입니다.
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 [정수 범위](<-2147483648 ~ 2147483647>) 내의 값을 모두 사용할 수 있습니다.
    // ##### ⚠️ [제거된 유닛](<GetUnitTypeId(whichUnit) == 0>) 은 무시되며 0 을 반환합니다.
    // ---
    // takes
    // - unit whichUnit
    // - integer customStatCode
    // - integer delta
    // returns
    // - integer 추가 값이 합산된 최종 스탯 값
    function CustomStatAdd takes unit whichUnit, integer customStatCode, integer delta returns integer
        if GetUnitTypeId(whichUnit) == 0 then
            return 0
        endif

        call PrepareStatHandleId(whichUnit)
        set stat_value = LoadInteger(STATS, stat_id, customStatCode) + delta
        call SaveInteger(STATS, stat_id, customStatCode, stat_value)

        return stat_value
    endfunction

    // ---
    // ## 🧊 커스텀 스탯 - 스탯 값 조회
    // > ### [유닛](<unit whichUnit>) 의 [커스텀 스탯](<integer customStatCode>) 의 값을 조회합니다.
    // ---
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 유즈맵 제작자가 임의로 정의할 수 있는 스탯 코드입니다.
    // ##### ⚠️ [제거된 유닛](<GetUnitTypeId(whichUnit) == 0>) 은 무시되며 0 을 반환합니다.
    // ---
    // takes
    // - unit whichUnit
    // - integer customStatCode
    // returns
    // - integer 조회된 스탯 값
    function CustomStatGet takes unit whichUnit, integer customStatCode returns integer
        if GetUnitTypeId(whichUnit) == 0 then
            return 0
        endif

        call PrepareStatHandleId(whichUnit)

        return LoadInteger(STATS, stat_id, customStatCode)
    endfunction

    // ---
    // ## 🧊 커스텀 스탯 - 스탯 값 초기화
    // > ### [유닛](<unit whichUnit>) 의 [커스텀 스탯](<integer customStatCode>) 의 값을 초기화합니다.
    // ---
    // ##### ℹ️ [커스텀 스탯](<integer customStatCode>) 은 유즈맵 제작자가 임의로 정의할 수 있는 스탯 코드입니다.
    // ##### ⚠️ [제거된 유닛](<GetUnitTypeId(whichUnit) == 0>) 은 무시되며 0 을 반환합니다.
    // ---
    // takes
    // - unit whichUnit
    // - integer customStatCode
    // returns
    // - integer 초기화되어 사라진 스탯 값
    function CustomStatReset takes unit whichUnit, integer customStatCode returns integer
        if GetUnitTypeId(whichUnit) == 0 then
            return 0
        endif

        call PrepareStatHandleId(whichUnit)
        set stat_value = LoadInteger(STATS, stat_id, customStatCode)
        call RemoveSavedInteger(STATS, stat_id, customStatCode)

        return stat_value
    endfunction

    // ---
    // ## 🧊 커스텀 스탯 - 모든 스탯 초기화
    // > ### [유닛](<unit whichUnit>) 의 모든 [커스텀 스탯](<integer customStatCode>) 의 값을 초기화합니다.
    // ---
    // ##### ⚠️ [제거된 유닛](<GetUnitTypeId(whichUnit) == 0>) 은 무시되며 false 를 반환합니다.
    // ---
    // takes
    // - unit whichUnit
    // returns
    // - boolean 초기화 성공 여부
    function CustomStatClear takes unit whichUnit returns boolean
        if GetUnitTypeId(whichUnit) == 0 then
            return false
        endif

        call PrepareStatHandleId(whichUnit)
        call FlushChildHashtable(STATS, stat_id)

        return true
    endfunction

endlibrary
