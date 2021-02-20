//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/*
    유닛인덱서 21.02.21
    
    지원하는 함수
    
        local integer 유닛번호 = IndexUnit( 유닛 )
            ＋해당 유닛의 고유 번호를 가져옵니다. 고유 번호가 없다면, 설정합니다.
            －만약 0이 반환되었다면, null 또는 이미 제거된 유닛을 넣어서 그렇습니다. 
            
        local integer 유닛번호 = GetUnitIndex( 유닛 )
            ＋해당 유닛의 고유 번호를 가져옵니다. 고유 번호가 없다면, 0이 반환됩니다.
            －만약 0이 반환되었다면, null 또는 이미 제거된 유닛이거나. 인덱싱 하지 않은 유닛입니다. 
        
        if IsUnitIndexed( 유닛 ) then
            ＋해당 유닛이 고유 번호를 가지고 있는지/없는지의 여부를 true/false로 반환합니다.
            －false가 반환되는 경우는. null 또는 이미 제거된 유닛이거나, 인덱싱 하지 않은 유닛입니다. 
        
        local real 점유율 = GetIndexRate()
            ＋시스템 최대 수용량인 8191에 대한 인덱싱된 유닛의 점유율을 %로 구해줍니다.
            
        // 누수때문에 임시중단
        local trigger 트리거 = GetUnitRemoveTrigger(유닛)
            ＋인덱싱된 유닛에 대한 '유닛 제거됨' 이벤트에 대응되는 트리거 핸들을 빌려옵니다.
            －만약 null이 반환되었다면. null 또는 이미 제거되었거나, 인덱싱 하지 않은 유닛입니다. 
        
        // 누수때문에 임시중단
        local integer 유닛번호 = GetTriggerIndex()
            ＋GetUnitRemoveTrigger()의 유닛 제거 이벤트에 대응하는, 제거된 유닛의 고유번호입니다.
            －주의! GetUnitRemoveTrigger() 액션을 제외한 다른 이벤트의 액션에서는 0으로 작동합니다
*/
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
library UnitIndexer initializer main
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
globals
    // 시스템 설정 - 가비지컬렉터 실행간격
    private constant real    GC_TIMEOUT   = 0.03125
    // 시스템 설정 - 가비지컬렉터 오버클럭
    private constant integer GC_OVERCLOCK = 50
endglobals
//··············································································
globals
    private hashtable INDEX_TABLE = InitHashtable()
    private boolean array E
    private integer array H
    private unit    array U
endglobals
//··············································································
private struct UDX
endstruct
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  +a. 성능 평가
globals
    private integer M = 0
    private integer C = 0
endglobals
function GetIndexRate takes nothing returns real
    return C / 8191.0
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  3/3. 인덱서
function GetUnitIndex takes unit u returns integer
    return LoadInteger(INDEX_TABLE,GetHandleId(u),0)
endfunction
function IsUnitIndexed takes unit u returns boolean
    return HaveSavedInteger(INDEX_TABLE,GetHandleId(u),0)
endfunction
function IndexUnit takes unit u returns integer
    local integer id = LoadInteger(INDEX_TABLE,GetHandleId(u),0)
    if id == 0 then
        if GetUnitTypeId(u) == 0 then
            return 0
        endif
        set id = UDX.create()
        set id:E = true
        set id:U = u
        set id:H = GetHandleId(u)
        call SaveInteger(INDEX_TABLE,id:H,0,id)
        set C = C + 1
        if id > M then
            set M = id
        endif
    endif
    return id
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  +a. 디인덱서
globals
    private integer DEINDEX_ID = 1
endglobals
//··············································································
private function DeindexAction takes nothing returns nothing
    local UDX rm
    local integer id
    local integer i = GC_OVERCLOCK
    loop
        exitwhen DEINDEX_ID > M
        set id = DEINDEX_ID
        if id:E then
            if GetUnitTypeId(id:U) == 0 then
                call FlushChildHashtable(INDEX_TABLE,id:H)
                set id:U = null
                set id:H = 0
                set id:E = false
                set rm = id
                call rm.destroy()
            endif
        endif
        set DEINDEX_ID = DEINDEX_ID + 1
        set i = i - 1
        exitwhen i < 1
    endloop
    if DEINDEX_ID > M then
        set DEINDEX_ID = 1
    endif
endfunction
//··············································································
private function InitDeindexer takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerAddAction(t,function DeindexAction)
    call TriggerRegisterTimerEvent(t,GC_TIMEOUT,true)
    set t = null
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  +b. 프리인덱서/포스트인덱서
private function OnAllocateCondition takes nothing returns boolean
    return not HaveSavedInteger(INDEX_TABLE,0,GetHandleId(GetTriggerUnit()))
endfunction
private function OnAllocateAction takes nothing returns nothing
    call IndexUnit(GetTriggerUnit())
endfunction
private function PostAllocate takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerAddAction(t, function OnAllocateAction)
    call TriggerAddCondition(t, Condition(function OnAllocateCondition))
    call TriggerRegisterEnterRectSimple(t, GetWorldBounds()) /*요주의 인물*/
    set t = null
endfunction
//··············································································
private function EnumPreAllocate takes nothing returns boolean
    call IndexUnit( GetFilterUnit() )
    return false
endfunction
private function PreAllocate takes nothing returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRect(g,GetWorldBounds(),Filter(function EnumPreAllocate))
    call DestroyGroup( g )
    set g = null
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 시스템 초기화
private function main takes nothing returns nothing
    call PreAllocate()
    call PostAllocate()
    call InitDeindexer()
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
endlibrary
