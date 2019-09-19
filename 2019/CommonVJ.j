// Copyright (c) 2019 W3UMF https://cafe.naver.com/w3umf
// Distributed under the BSD License, Version 190920.0059
// See original source at GitHub https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/CommonVJ.j
// TESH custom intellisense https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/CommonVJ.Intellisense.txt
/* 
Contributors
escaco, 은방
*/
library vJDKCommon
//===========================================================
// 텍스트 - 모든 플레이어에게 (메시지)를 표시합니다
function VJDebugMsg takes string message returns nothing
    call DisplayTextToPlayer(GetLocalPlayer(),0.00,0.00,message)
endfunction
// BJ에는 없는 기능 (플레이어)의 화면에 떠 있는 모든 텍스트 지우기
function ClearTextMessagesVJ takes player whichPlayer returns nothing
    if whichPlayer == GetLocalPlayer() then
        call ClearTextMessages()
    endif
endfunction
//===========================================================
// if GetOwningPlayer(유닛) == 플레이어 then을 if IsUnitOwner(유닛,플레이어) then 으로 압축 가능합니다
function IsUnitOwnerVJ takes unit whichUnit, player whichPlayer returns boolean
    return GetOwningPlayer(whichUnit)==whichPlayer
endfunction
// 유닛의 소유자의 플레이어 번호를 바로 가져오는 기능으로, BJ에는 없는 기능입니다
function GetOwningPlayerIdVJ takes unit u returns integer
    return GetPlayerId(GetOwningPlayer(u))
endfunction
// 유닛의 소유자의 이름을 바로 가져오는 기능으로, BJ에는 없는 기능입니다
function GetOwnerNameVJ takes unit u returns string
    return GetPlayerName(GetOwningPlayer(u))
endfunction
// 플레이어가 현재 '접속 중'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerPlayingVJ takes player p returns boolean
    return GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING
endfunction
// 플레이어 번호의 플레이어가 현재 '접속 중'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerPlayingByIdVJ takes integer i returns boolean
    return GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING
endfunction
// 플레이어에게 골드를 '추가' 합니다. BJ에는 없는 함수입니다
function AddPlayerGoldVJ takes player p, integer delta returns nothing
    call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)+delta)
endfunction
// 플레이어에게 나무를 '추가' 합니다. BJ에는 없는 함수입니다
function AddPlayerLumberVJ takes player p, integer delta returns nothing
    call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)+delta)
endfunction
// 플레이어의 골드를 '설정' 합니다. BJ에는 없는 함수입니다
function SetPlayerGoldVJ takes player p, integer amount returns nothing
    call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,amount)
endfunction
// 플레이어의 나무를 '설정' 합니다. BJ에는 없는 함수입니다
function SetPlayerLumberVJ takes player p, integer amount returns nothing
    call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,amount)
endfunction
// 플레이어가 가진 골드가 얼마인지 알아냅니다. BJ에는 없는 함수입니다
function GetPlayerGoldVJ takes player p returns integer
    return GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
endfunction
// 플레이어가 가진 목재가 얼마인지 알아냅니다. BJ에는 없는 함수입니다
function GetPlayerLumberVJ takes player p returns integer
    return GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
endfunction
// 플레이어의 '속성값'을 추가하는 함수입니다. BJ의 AdjustPlayerStateSimpleBJ는 이름이 길고, 내부가 복잡하게 돌아갑니다.
function AddPlayerStateVJ takes player p, playerstate ps, integer delta returns nothing
    call SetPlayerState(p,ps,GetPlayerState(p,ps)+delta)
endfunction
// 맵 설정에서, 플레이어가 N(0~11) 번째 '팀'에 해당하면 true, 해당하지 않으면 false를 반환합니다.
function IsPlayerTeamVJ takes player p, integer t returns boolean
    return GetPlayerTeam(p) == t
endfunction
// 플레이어가 '접속 중인 유저(컴퓨터 아님)'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerPlayingUserVJ takes player p returns boolean
    return GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER
endfunction
// 플레이어가 '유저(컴퓨터 아님)'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerUserVJ takes player p returns boolean
    return GetPlayerController(p) == MAP_CONTROL_USER
endfunction
// 플레이어가 'CPU(유저 아님)'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerComputerVJ takes player p returns boolean
    return GetPlayerController(p) == MAP_CONTROL_COMPUTER
endfunction
// 플레이어가 '중립(피해자,엑스트라,패시브)'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerNeutralVJ takes player p returns boolean
    return GetPlayerController(p) == MAP_CONTROL_NEUTRAL
endfunction
// 플레이어가 '적대적 중립'인지 확인하는 기능입니다. BJ에는 없습니다
function IsPlayerCreepVJ takes player p returns boolean
    return GetPlayerController(p) == MAP_CONTROL_CREEP
endfunction
// 어떤 플레이어든 이벤트를 등록합니다.
function TriggerRegisterAnyPlayerEventVJ takes trigger whichTrigger, playerevent whichEvent returns nothing
    local integer index
    set index = 0
    loop
        call TriggerRegisterPlayerEvent(whichTrigger, Player(index), whichEvent)
        set index = index + 1
        exitwhen index == bj_MAX_PLAYER_SLOTS
    endloop
endfunction
//===========================================================
// 타이머 다이얼로그를 만들고 제목을 설정하는 것까지 하나의 기능으로 묶었습니다. BJ에는 없습니다
function CreateTimerDialogVJ takes timer whichTimer, string title, player whichPlayer returns timerdialog
    set bj_lastCreatedTimerDialog=CreateTimerDialog(whichTimer)
    call TimerDialogSetTitle(bj_lastCreatedTimerDialog,title)
    call TimerDialogDisplay(bj_lastCreatedTimerDialog,GetLocalPlayer()==whichPlayer)
    return bj_lastCreatedTimerDialog
endfunction
//===========================================================
// 특수효과를 좌표에 만들고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectVJ takes string modelName, real x, real y returns nothing
    call DestroyEffect(AddSpecialEffect(modelName,x,y))
endfunction
// 특수효과를 목표물의 위치에 만들고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectTargetPositionVJ takes string modelName, widget targetWidget returns nothing
    call DestroyEffect(AddSpecialEffect(modelName,GetWidgetX(targetWidget),GetWidgetY(targetWidget)))
endfunction
// 특수효과를 목표물의 모델에 부착시키고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectTargetVJ takes string modelName, widget targetWidget, string attachPointName returns nothing
    call DestroyEffect(AddSpecialEffectTarget(modelName,targetWidget,attachPointName))
endfunction
//===========================================================
// N명의 유닛을 생성합니다. 별도의 누수가 발생하지 않습니다.(스크립트 버전)
function CreateUnitsVJ takes integer amount, player id, integer unitid, real x, real y, real face returns nothing
    loop
        exitwhen amount < 1
        call CreateUnit(id,unitid,x,y,face)
        set amount = amount - 1
    endloop
endfunction
// N명의 유닛을 생성합니다. 별도의 누수가 발생하지 않습니다.(GUI 버전 스왑)
function CreateUnitsSwapVJ takes integer amount, integer unitid, player id, real x, real y, real face returns nothing
    loop
        exitwhen amount < 1
        call CreateUnit(id,unitid,x,y,face)
        set amount = amount - 1
    endloop
endfunction
// 유닛이 사망 상태라면 true, 생존 상태라면 false를 반환합니다. 기존 BJ의 판정 버그를 개선했습니다
function IsUnitDeadVJ takes unit whichUnit returns boolean
    return IsUnitType(whichUnit,UNIT_TYPE_DEAD) or GetUnitTypeId(whichUnit) == 0
endfunction
// 유닛이 사망 상태라면 false, 생존 상태라면 true를 반환합니다. 기존 BJ의 판정 버그를 개선했습니다
function IsUnitAliveVJ takes unit whichUnit returns boolean
    return not IsUnitType(whichUnit,UNIT_TYPE_DEAD) and GetUnitTypeId(whichUnit) != 0
endfunction
// SetUnitLifeBJ는 있는데, AddUnitLifeBJ는 없습니다. 유닛에게 체력을 추가합니다. 음수를 추가하면 빠집니다
function AddUnitLifeVJ takes unit whichUnit, real deltaLife returns nothing
    call SetUnitState(whichUnit,UNIT_STATE_LIFE,GetUnitState(whichUnit,UNIT_STATE_LIFE)+deltaLife)
endfunction
// SetUnitManaBJ는 있는데, AddUnitManaBJ는 없습니다. 유닛에게 마나을 추가합니다. 음수를 추가하면 빠집니다
function AddUnitManaVJ takes unit whichUnit, real deltaMana returns nothing
    call SetUnitState(whichUnit,UNIT_STATE_MANA,GetUnitState(whichUnit,UNIT_STATE_MANA)+deltaMana)
endfunction
// SetUnitLifeBJ에서 추가적인 RMaxBJ 연산을 제거했습니다
function SetUnitLifeVJ takes unit whichUnit, real life returns nothing
    call SetUnitState(whichUnit,UNIT_STATE_LIFE,life)
endfunction
// SetUnitManaBJ에서 추가적인 RMaxBJ 연산을 제거했습니다
function SetUnitManaVJ takes unit whichUnit, real mana returns nothing
    call SetUnitState(whichUnit,UNIT_STATE_MANA,mana)
endfunction
// 유닛의 체력값을 받아옵니다. BJ에는 없습니다
function GetUnitLifeVJ takes unit whichUnit returns real
    return GetUnitState(whichUnit,UNIT_STATE_LIFE)
endfunction
// 유닛의 마나값을 받아옵니다. BJ에는 없습니다
function GetUnitManaVJ takes unit whichUnit returns real
    return GetUnitState(whichUnit,UNIT_STATE_MANA)
endfunction
// 유닛이 특정 오브젝트 능력을 갖고 있는지의 여부를 알려줍니다. true 갖고있음. false 능력 없음
function UnitHasAbilityVJ takes unit whichUnit, integer abilityId returns boolean
    return GetUnitAbilityLevel(whichUnit,abilityId) > 0
endfunction
// 유닛의 최대 체력값을 받아옵니다. BJ에는 없습니다
function GetUnitMaxLifeVJ takes unit whichUnit returns real
    return GetUnitState(whichUnit,UNIT_STATE_MAX_LIFE)
endfunction
// 유닛의 최대 마나값을 받아옵니다. BJ에는 없습니다
function GetUnitMaxManaVJ takes unit whichUnit returns real
    return GetUnitState(whichUnit,UNIT_STATE_MAX_MANA)
endfunction
// 유닛의 (속성값)에 수치를 더합니다. BJ에는 없습니다
function AddUnitStateVJ takes unit whichUnit, unitstate whichUnitState, real delta returns nothing
    call SetUnitState(whichUnit,whichUnitState,GetUnitState(whichUnit,whichUnitState)+delta)
endfunction
// 유닛의 고도를 변경 가능하게 합니다(지상 유닛도!). BJ에는 없습니다
function SetUnitFlyVJ takes unit whichUnit returns nothing
    call UnitAddAbility(whichUnit,'Amrf')
    call UnitRemoveAbility(whichUnit,'Amrf')
endfunction
// 유닛의 좌표를 설정합니다
function SetUnitXYVJ takes unit whichUnit, real x, real y returns nothing
    call SetUnitX(whichUnit,x)
    call SetUnitY(whichUnit,y)
endfunction
// 유닛의 좌표를 지점 좌표로 설정합니다
function SetUnitXYLocVJ takes unit whichUnit, location targetLoc returns nothing
    call SetUnitX(whichUnit,GetLocationX(targetLoc))
    call SetUnitY(whichUnit,GetLocationY(targetLoc))
endfunction
// 유닛의 좌표를 (거리) (각도) 만큼 이동합니다
function PolarUnitVJ takes unit whichUnit, real distance, real angle returns nothing
    call SetUnitX(whichUnit,GetUnitX(whichUnit)+distance*Cos(angle*bj_DEGTORAD))
    call SetUnitY(whichUnit,GetUnitY(whichUnit)+distance*Sin(angle*bj_DEGTORAD))
endfunction
// 유닛의 좌표를 (거리) (호도) 만큼 이동합니다
function PolarUnitRadVJ takes unit whichUnit, real distance, real angle returns nothing
    call SetUnitX(whichUnit,GetUnitX(whichUnit)+distance*Cos(angle))
    call SetUnitY(whichUnit,GetUnitY(whichUnit)+distance*Sin(angle))
endfunction
//===========================================================
// 구역 내 무작위 X좌표를 가져옵니다. BJ에는 없습니다
function GetRandomRectXVJ takes rect whichRect returns real
    return GetRandomReal(GetRectMinX(whichRect),GetRectMaxX(whichRect))
endfunction
// 구역 내 무작위 Y좌표를 가져옵니다. BJ에는 없습니다
function GetRandomRectYVJ takes rect whichRect returns real
    return GetRandomReal(GetRectMinY(whichRect),GetRectMaxY(whichRect))
endfunction
//===========================================================
// 실수의 소수점을 떼고 문자열로 변환합니다. BJ에 없는 기능입니다
function R2I2S takes real value returns string
    return I2S(R2I(value))
endfunction
// 논리값을 논리값에 의거한 문자열로 변환합니다.
function B2S takes boolean value, string iffalse, string iftrue returns string
    if value then
        return iftrue
    endif
    return iffalse
endfunction
//===========================================================
// GUI에 유닛 그룹 파괴를 요청합니다
function WantDestroyGroupVJ takes nothing returns nothing
    set bj_wantDestroyGroup = true
endfunction
// 플레이어의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsOfPlayerVJ takes player whichPlayer, boolexpr filter returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsOfPlayer(g,whichPlayer,filter)
    call DestroyGroup(g)
    set g = null
endfunction
// 구역 위의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsInRectVJ takes rect whichRect, boolexpr filter returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRect(g,whichRect,filter)
    call DestroyGroup(g)
    set g = null
endfunction
// 좌표를 중심으로 반경 안의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsInRangeVJ takes real x, real y, real radius, boolexpr filter returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRange(g,x,y,radius,filter)
    call DestroyGroup(g)
    set g = null
endfunction
// 위젯(유닛,아이템,장식물)을 중심으로 반경 안의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsInWidgetRangeVJ takes widget whichWidget, real radius, boolexpr filter returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRange(g,GetWidgetX(whichWidget),GetWidgetY(whichWidget),radius,filter)
    call DestroyGroup(g)
    set g = null
endfunction
//===========================================================
// 해당 좌표가 경계(검정 지형)인지 판독합니다. 맞으면 true, 아니면 false
function IsTerrainBoundaryVJ takes real x, real y returns boolean
    return IsTerrainPathable(x,y,PATHING_TYPE_WALKABILITY) and IsTerrainPathable(x,y,PATHING_TYPE_FLYABILITY) and IsTerrainPathable(x,y,PATHING_TYPE_BUILDABILITY)
endfunction
//===========================================================
// 유동 텍스트 간편 생성 기능입니다
function CreateTextTagPermanentVJ takes real x, real y, real z, string text, real textsize returns texttag
    set bj_lastCreatedTextTag = CreateTextTag()
    call SetTextTagText(bj_lastCreatedTextTag, text, textsize)
    call SetTextTagPos(bj_lastCreatedTextTag, x, y, z)
    call SetTextTagVisibility(bj_lastCreatedTextTag, true)
    call SetTextTagPermanent(bj_lastCreatedTextTag, true)
    return bj_lastCreatedTextTag
endfunction
function CreateTextTagVJ takes real x, real y, real z, string s, real ss, real l, real fl, real sp, real a returns texttag
    local texttag tt = CreateTextTag()
    call SetTextTagText(tt, s, ss)
    call SetTextTagPos(tt, x, y, z)
    call SetTextTagVelocity(tt, sp*Cos(a*bj_DEGTORAD), sp*Sin(a*bj_DEGTORAD))
    call SetTextTagVisibility(tt, true)
    call SetTextTagFadepoint(tt, l)
    call SetTextTagLifespan(tt, fl)
    call SetTextTagPermanent(tt, false)
    return tt
endfunction
function CreateTextTagForPlayerVJ takes player p, real x, real y, real z, string s, real ss, real l, real fl, real sp, real a returns texttag
    local texttag tt = CreateTextTag()
    call SetTextTagText(tt, s, ss)
    call SetTextTagPos(tt, x, y, z)
    call SetTextTagVelocity(tt, sp*Cos(a*bj_DEGTORAD), sp*Sin(a*bj_DEGTORAD))
    call SetTextTagVisibility(tt, GetLocalPlayer()==p)
    call SetTextTagFadepoint(tt, l)
    call SetTextTagLifespan(tt, fl)
    call SetTextTagPermanent(tt, false)
    return tt
endfunction
//===========================================================
// 좌표, 객체 간의 거리,각도를 계산하는 산술 함수입니다. BJ의 누수를 해결
function DistanceP2PVJ takes real fromX, real fromY, real toX, real toY returns real
    local real dx = toX-fromX
    local real dy = toY-fromY
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceP2WVJ takes real fromX, real fromY, widget to returns real
    local real dx = GetWidgetX(to)-fromX
    local real dy = GetWidgetY(to)-fromY
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceW2PVJ takes widget from, real toX, real toY returns real
    local real dx = toX-GetWidgetX(from)
    local real dy = toY-GetWidgetY(from)
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceW2WVJ takes widget from, widget to returns real
    local real dx = GetWidgetX(to)-GetWidgetX(from)
    local real dy = GetWidgetY(to)-GetWidgetY(from)
    return SquareRoot(dx*dx+dy*dy)
endfunction
function AngleP2PVJ takes real fromX, real fromY, real toX, real toY returns real
    return Atan2(toY-fromY,toX-fromX)*bj_RADTODEG
endfunction
function AngleP2PRadVJ takes real fromX, real fromY, real toX, real toY returns real
    return Atan2(toY-fromY,toX-fromX)
endfunction
function AngleW2PVJ takes widget from, real toX, real toY returns real
    return Atan2(toY-GetWidgetY(from),toX-GetWidgetX(from))*bj_RADTODEG
endfunction
function AngleW2PRadVJ takes widget from, real toX, real toY returns real
    return Atan2(toY-GetWidgetY(from),toX-GetWidgetX(from))
endfunction
function AngleP2WVJ takes real fromX, real fromY, widget to returns real
    return Atan2(GetWidgetY(to)-fromY,GetWidgetX(to)-fromX)*bj_RADTODEG
endfunction
function AngleP2WRadVJ takes real fromX, real fromY, widget to returns real
    return Atan2(GetWidgetY(to)-fromY,GetWidgetX(to)-fromX)
endfunction
function AngleW2WVJ takes widget from, widget to returns real
    return Atan2(GetWidgetY(to)-GetWidgetY(from),GetWidgetX(to)-GetWidgetX(from))*bj_RADTODEG
endfunction
function AngleW2WRadVJ takes widget from, widget to returns real
    return Atan2(GetWidgetY(to)-GetWidgetY(from),GetWidgetX(to)-GetWidgetX(from))
endfunction
function PolarXVJ takes real distance, real angle returns real
    return distance*Cos(angle*bj_DEGTORAD)
endfunction
function PolarYVJ takes real distance, real angle returns real
    return distance*Sin(angle*bj_DEGTORAD)
endfunction
function PolarXRadVJ takes real distance, real angle returns real
    return distance*Cos(angle)
endfunction
function PolarYRadVJ takes real distance, real angle returns real
    return distance*Sin(angle)
endfunction
// 현재 각도가 유도율만큼 목표 각도를 바라보게 만드는 산술 함수입니다
function MoveAngleToVJ takes real angle, real to, real delta returns real
    local real v = ModuloReal(to-angle+180,360)
    if v < 0 then
        set v = v + 360
    endif
    return angle + RMaxBJ(-delta, RMinBJ(delta,-180 + v))
endfunction
//===========================================================
// 텍스트 파일 작성 기능입니다. Preload가 있지만, 직관적인 함수명으로 교체
function TextWriteStartVJ takes player whichPlayer returns nothing
    if GetLocalPlayer() == whichPlayer then
        call PreloadGenClear()
        call PreloadGenStart()
    endif
endfunction
function TextWriteVJ takes player whichPlayer, string text returns nothing
    if GetLocalPlayer() == whichPlayer then
        call Preload(text)
    endif
endfunction
function TextWriteEndVJ takes player whichPlayer, string fileName returns nothing
    if GetLocalPlayer() == whichPlayer then
        call PreloadGenEnd(fileName)
    endif
endfunction
//===========================================================
// 게임 내 시간이 저녁임
function IsNightVJ takes nothing returns boolean
    return 6.0 > GetFloatGameState(GAME_STATE_TIME_OF_DAY) or GetFloatGameState(GAME_STATE_TIME_OF_DAY) >= 18.0
endfunction
// 게임 내 시간이 아침임
function IsDayVJ takes nothing returns boolean
    return 6.0 <= GetFloatGameState(GAME_STATE_TIME_OF_DAY) and GetFloatGameState(GAME_STATE_TIME_OF_DAY) < 18.0
endfunction
//===========================================================
// 확률에 당첨됨
function IsDiceEqualVJ takes integer min, integer max, integer dest returns boolean
    return GetRandomInt(min,max) == dest
endfunction
function IsDiceLessThanVJ takes integer min, integer max, integer dest returns boolean
    return GetRandomInt(min,max) < dest
endfunction
function IsDiceGreaterThanVJ takes integer min, integer max, integer dest returns boolean
    return GetRandomInt(min,max) > dest
endfunction
function IsRandomMatchedVJ takes real min, real max, real dest returns boolean
    return GetRandomReal(min,max) < dest
endfunction
//===========================================================
endlibrary
