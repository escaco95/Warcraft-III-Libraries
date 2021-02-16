library NoMoreFatal initializer main
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 페이탈은 이제 NAVER...
// 뭐 하나 만들기 전에, 반드시 핸들값 증가폭을 체크하는 습관을 들여야 합니다.
//
// CreateTimerSafe
// CreateGroupSafe
// AddSpecialEffectSafe
// AddSpecialEffectTargetSafe
// CreateItemSafe
// PlaceRandomItemSafe
// UnitAddItemByIdSafe
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
globals
    private constant boolean SYSTEM_ENABLED = DEBUG_MODE /*시스템 사용 여부*/
    
    integer HANDLE_MAX  = 0 /*사유에 관계없이 기록된 최대 핸들값*/
    integer HANDLE_LAST = 0 /*사유에 관계없이 기록된 최근 핸들값*/
    
    private rect     WORLD_BOUND = null
    private boolexpr ITEM_FILTER = null
endglobals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 핸들값을 즉시 계측하는 스크립트입니다.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function CheckHandle takes handle h returns nothing
    static if SYSTEM_ENABLED then
        set HANDLE_LAST = GetHandleId(h)
        if HANDLE_LAST > HANDLE_MAX then
            set HANDLE_MAX = HANDLE_LAST
        endif
    endif
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 핸들값이 즉시 계측되는 타이머/유닛그룹/이펙트/아이템 생성 스크립트입니다.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
private function HandleTimer takes timer h returns timer
    set HANDLE_LAST = GetHandleId(h)
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
    return h
endfunction
private function HandleGroup takes group h returns group
    set HANDLE_LAST = GetHandleId(h)
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
    return h
endfunction
private function HandleEffect takes effect h returns effect
    set HANDLE_LAST = GetHandleId(h)
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
    return h
endfunction
private function HandleItem takes item h returns item
    set HANDLE_LAST = GetHandleId(h)
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
    return h
endfunction
//------------------------------------------------------------------------------
function CreateTimerSafe takes nothing returns timer
    static if SYSTEM_ENABLED then
        return HandleTimer(CreateTimer())
    else
        return CreateTimer()
    endif
endfunction
//------------------------------------------------------------------------------
function CreateGroupSafe takes nothing returns group
    static if SYSTEM_ENABLED then
        return HandleGroup(CreateGroup())
    else
        return CreateGroup()
    endif
endfunction
//------------------------------------------------------------------------------
function AddSpecialEffectSafe takes string modelName, real x, real y returns effect
    static if SYSTEM_ENABLED then
        return HandleEffect(AddSpecialEffect(modelName,x,y))
    else
        return AddSpecialEffect(modelName,x,y)
    endif
endfunction
function AddSpecialEffectTargetSafe takes string modelName, widget targetWidget, string attachPointName returns effect
    static if SYSTEM_ENABLED then
        return HandleEffect(AddSpecialEffectTarget(modelName,targetWidget,attachPointName))
    else
        return AddSpecialEffectTarget(modelName,targetWidget,attachPointName)
    endif
endfunction
//------------------------------------------------------------------------------
function CreateItemSafe takes integer itemid, real x, real y returns item
    static if SYSTEM_ENABLED then
        return HandleItem(CreateItem(itemid,x,y))
    else
        return CreateItem(itemid,x,y)
    endif
endfunction
function PlaceRandomItemSafe takes itempool whichItemPool, real x, real y returns item
    static if SYSTEM_ENABLED then
        return HandleItem(PlaceRandomItem(whichItemPool,x,y))
    else
        return PlaceRandomItem(whichItemPool,x,y)
    endif
endfunction
function UnitAddItemByIdSafe takes unit whichUnit, integer itemId returns item
    static if SYSTEM_ENABLED then
        return HandleItem(UnitAddItemById(whichUnit,itemId))
    else
        return UnitAddItemById(whichUnit,itemId)
    endif
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 구역 입장을 이용한 유닛 누수 체크 / 15초당 맵 전체 아이템 체크입니다.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
private function OnAnyUnitEnterWorld takes nothing returns nothing
    set HANDLE_LAST = GetHandleId(GetTriggerUnit())
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
endfunction
//------------------------------------------------------------------------------
private function ItemFilter takes nothing returns boolean
    set HANDLE_LAST = GetHandleId(GetFilterItem())
    if HANDLE_LAST > HANDLE_MAX then
        set HANDLE_MAX = HANDLE_LAST
    endif
    return false
endfunction
private function OnTimeout takes nothing returns nothing
    call EnumItemsInRect(WORLD_BOUND,ITEM_FILTER,null)
endfunction
//------------------------------------------------------------------------------
private function main takes nothing returns nothing
    static if SYSTEM_ENABLED then
        local trigger t = CreateTrigger()
        /*의존 독립성이 보장되는 1회의 허용 가능한 누수 GetWorldBounds()*/
        set WORLD_BOUND = GetWorldBounds()
        call TriggerAddAction(t,function OnAnyUnitEnterWorld)
        call TriggerRegisterEnterRectSimple(t,WORLD_BOUND)
        set t = CreateTrigger()
        set ITEM_FILTER = Filter(function ItemFilter)
        call TriggerAddAction(t,function OnTimeout)
        call TriggerRegisterTimerEvent(t,15.0,true)
        set t = null
    endif
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
endlibrary
