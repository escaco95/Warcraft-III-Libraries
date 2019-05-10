// Copyright (c) 2019 W3UMF https://cafe.naver.com/w3umf
// Distributed under the BSD License, Version 190510.2320
// See original source at GitHub https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/CommonVJ.j
// TESH custom intellisense https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/CommonVJ.Intellisense.txt
/* 
Contributors
escaco, 은방
*/
library CommonVJ
//===========================================================
// 텍스트 - 모든 플레이어에게 (메시지)를 표시합니다
function VJDebugMsg takes string s returns nothing
    call DisplayTextToPlayer(GetLocalPlayer(),0.00,0.00,s)
endfunction
// BJ에는 없는 기능 (플레이어)의 화면에 떠 있는 모든 텍스트 지우기
function ClearTextMessagesVJ takes player p returns nothing
    if p == GetLocalPlayer() then
        call ClearTextMessages()
    endif
endfunction
//===========================================================
// if GetOwningPlayer(유닛) == 플레이어 then을 if IsUnitOwner(유닛,플레이어) then 으로 압축 가능합니다
function IsUnitOwnerVJ takes unit u, player p returns boolean
    return GetOwningPlayer(u)==p
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
//===========================================================
// 타이머 다이얼로그를 만들고 제목을 설정하는 것까지 하나의 기능으로 묶었습니다. BJ에는 없습니다
function CreateTimerDialogVJ takes timer t, string s, player p returns timerdialog
    set bj_lastCreatedTimerDialog=CreateTimerDialog(t)
    call TimerDialogSetTitle(bj_lastCreatedTimerDialog,s)
    call TimerDialogDisplay(bj_lastCreatedTimerDialog,GetLocalPlayer()==p)
    return bj_lastCreatedTimerDialog
endfunction
//===========================================================
// 특수효과를 좌표에 만들고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectVJ takes string s, real x, real y returns nothing
    call DestroyEffect(AddSpecialEffect(s,x,y))
endfunction
// 특수효과를 목표물의 위치에 만들고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectTargetPositionVJ takes string s, widget w returns nothing
    call DestroyEffect(AddSpecialEffect(s,GetWidgetX(w),GetWidgetY(w)))
endfunction
// 특수효과를 목표물의 모델에 부착시키고, 즉시 번쩍 파괴합니다. BJ에는 없습니다
function FlashSpecialEffectTargetVJ takes string s, widget w, string o returns nothing
    call DestroyEffect(AddSpecialEffectTarget(s,w,o))
endfunction
//===========================================================
// 유닛이 사망 상태라면 true, 생존 상태라면 false를 반환합니다. 기존 BJ의 판정 버그를 개선했습니다
function IsUnitDeadVJ takes unit u returns boolean
    return IsUnitType(u,UNIT_TYPE_DEAD) or GetUnitTypeId(u) == 0
endfunction
// 유닛이 사망 상태라면 false, 생존 상태라면 true를 반환합니다. 기존 BJ의 판정 버그를 개선했습니다
function IsUnitAliveVJ takes unit u returns boolean
    return not IsUnitType(u,UNIT_TYPE_DEAD) and GetUnitTypeId(u) != 0
endfunction
// SetUnitLifeBJ는 있는데, AddUnitLifeBJ는 없습니다. 유닛에게 체력을 추가합니다. 음수를 추가하면 빠집니다
function AddUnitLifeVJ takes unit u, real a returns nothing
    call SetUnitState(u,UNIT_STATE_LIFE,GetUnitState(u,UNIT_STATE_LIFE)+a)
endfunction
// SetUnitManaBJ는 있는데, AddUnitManaBJ는 없습니다. 유닛에게 마나을 추가합니다. 음수를 추가하면 빠집니다
function AddUnitManaVJ takes unit u, real a returns nothing
    call SetUnitState(u,UNIT_STATE_MANA,GetUnitState(u,UNIT_STATE_MANA)+a)
endfunction
// SetUnitLifeBJ에서 추가적인 RMaxBJ 연산을 제거했습니다
function SetUnitLifeVJ takes unit u, real a returns nothing
    call SetUnitState(u,UNIT_STATE_LIFE,a)
endfunction
// SetUnitManaBJ에서 추가적인 RMaxBJ 연산을 제거했습니다
function SetUnitManaVJ takes unit u, real a returns nothing
    call SetUnitState(u,UNIT_STATE_MANA,a)
endfunction
// 유닛의 체력값을 받아옵니다. BJ에는 없습니다
function GetUnitLifeVJ takes unit u returns real
    return GetUnitState(u,UNIT_STATE_LIFE)
endfunction
// 유닛의 마나값을 받아옵니다. BJ에는 없습니다
function GetUnitManaVJ takes unit u returns real
    return GetUnitState(u,UNIT_STATE_MANA)
endfunction
// 유닛이 특정 오브젝트 능력을 갖고 있는지의 여부를 알려줍니다. true 갖고있음. false 능력 없음
function UnitHasAbilityVJ takes unit u, integer i returns boolean
    return GetUnitAbilityLevel(u,i) > 0
endfunction
// 유닛의 최대 체력값을 받아옵니다. BJ에는 없습니다
function GetUnitMaxLifeVJ takes unit u returns real
    return GetUnitState(u,UNIT_STATE_MAX_LIFE)
endfunction
// 유닛의 최대 마나값을 받아옵니다. BJ에는 없습니다
function GetUnitMaxManaVJ takes unit u returns real
    return GetUnitState(u,UNIT_STATE_MAX_MANA)
endfunction
// 유닛의 (속성값)에 수치를 더합니다. BJ에는 없습니다
function AddUnitStateVJ takes unit u, unitstate s, real d returns nothing
    call SetUnitState(u,s,GetUnitState(u,s)+d)
endfunction
// 유닛의 고도를 변경 가능하게 합니다(지상 유닛도!). BJ에는 없습니다
function SetUnitFlyVJ takes unit u returns nothing
    call UnitAddAbility(u,'Amrf')
    call UnitRemoveAbility(u,'Amrf')
endfunction
// 유닛의 좌표를 설정합니다
function SetUnitXYVJ takes unit u, real x, real y returns nothing
    call SetUnitX(u,x)
    call SetUnitY(u,y)
endfunction
// 유닛의 좌표를 지점 좌표로 설정합니다
function SetUnitXYLocVJ takes unit u, location l returns nothing
    call SetUnitX(u,GetLocationX(l))
    call SetUnitY(u,GetLocationY(l))
endfunction
// 유닛의 좌표를 (거리) (각도) 만큼 이동합니다
function PolarUnitVJ takes unit u, real d, real a returns nothing
    call SetUnitX(u,GetUnitX(u)+d*Cos(a*bj_DEGTORAD))
    call SetUnitY(u,GetUnitY(u)+d*Sin(a*bj_DEGTORAD))
endfunction
// 유닛의 좌표를 (거리) (호도) 만큼 이동합니다
function PolarUnitRadVJ takes unit u, real d, real a returns nothing
    call SetUnitX(u,GetUnitX(u)+d*Cos(a))
    call SetUnitY(u,GetUnitY(u)+d*Sin(a))
endfunction
//===========================================================
// 구역 내 무작위 X좌표를 가져옵니다. BJ에는 없습니다
function GetRandomRectXVJ takes rect r returns real
    return GetRandomReal(GetRectMinX(r),GetRectMaxX(r))
endfunction
// 구역 내 무작위 Y좌표를 가져옵니다. BJ에는 없습니다
function GetRandomRectYVJ takes rect r returns real
    return GetRandomReal(GetRectMinY(r),GetRectMaxY(r))
endfunction
//===========================================================
// 실수의 소수점을 떼고 문자열로 변환합니다. BJ에 없는 기능입니다
function R2I2S takes real r returns string
    return I2S(R2I(r))
endfunction
//===========================================================
// GUI에 유닛 그룹 파괴를 요청합니다
function WantDestroyGroupVJ takes nothing returns nothing
    set bj_wantDestroyGroup = true
endfunction
// 플레이어의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsOfPlayerVJ takes player p, boolexpr f returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsOfPlayer(g,p,f)
    call DestroyGroup(g)
    set g = null
endfunction
// 구역 위의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsInRectVJ takes rect r, boolexpr f returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRect(g,r,f)
    call DestroyGroup(g)
    set g = null
endfunction
// 좌표를 중심으로 반경 안의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. BJ에 없는 기능입니다
function EnumUnitsInRangeVJ takes real x, real y, real r, boolexpr f returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRange(g,x,y,r,f)
    call DestroyGroup(g)
    set g = null
endfunction
// 위젯(유닛,아이템,장식물)을 중심으로 반경 안의 모든 유닛을 대상으로 (필터 함수)를 실행합니다. 
function EnumUnitsInWidgetRangeVJ takes widget w, real r, boolexpr f returns nothing
    local group g = CreateGroup()
    call GroupEnumUnitsInRange(g,GetWidgetX(w),GetWidgetY(w),r,f)
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
function DistanceP2PVJ takes real x1, real y1, real x2, real y2 returns real
    local real dx = x2-x1
    local real dy = y2-y1
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceP2WVJ takes real x1, real y1, widget w2 returns real
    local real dx = GetWidgetX(w2)-x1
    local real dy = GetWidgetY(w2)-y1
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceW2PVJ takes widget w1, real x2, real y2 returns real
    local real dx = x2-GetWidgetX(w1)
    local real dy = y2-GetWidgetY(w1)
    return SquareRoot(dx*dx+dy*dy)
endfunction
function DistanceW2WVJ takes widget w1, widget w2 returns real
    local real dx = GetWidgetX(w2)-GetWidgetX(w1)
    local real dy = GetWidgetY(w2)-GetWidgetY(w1)
    return SquareRoot(dx*dx+dy*dy)
endfunction
function AngleP2PVJ takes real x1, real y1, real x2, real y2 returns real
    return Atan2(y2-y1,x2-x1)*bj_RADTODEG
endfunction
function AngleP2PRadVJ takes real x1, real y1, real x2, real y2 returns real
    return Atan2(y2-y1,x2-x1)
endfunction
function AngleW2PVJ takes widget w1, real x2, real y2 returns real
    return Atan2(y2-GetWidgetY(w1),x2-GetWidgetX(w1))*bj_RADTODEG
endfunction
function AngleW2PRadVJ takes widget w1, real x2, real y2 returns real
    return Atan2(y2-GetWidgetY(w1),x2-GetWidgetX(w1))
endfunction
function AngleP2WVJ takes real x1, real y1, widget w2 returns real
    return Atan2(GetWidgetY(w2)-y1,GetWidgetX(w2)-x1)*bj_RADTODEG
endfunction
function AngleP2WRadVJ takes real x1, real y1, widget w2 returns real
    return Atan2(GetWidgetY(w2)-y1,GetWidgetX(w2)-x1)
endfunction
function AngleW2WVJ takes widget w1, widget w2 returns real
    return Atan2(GetWidgetY(w2)-GetWidgetY(w1),GetWidgetX(w2)-GetWidgetX(w1))*bj_RADTODEG
endfunction
function AngleW2WRadVJ takes widget w1, widget w2 returns real
    return Atan2(GetWidgetY(w2)-GetWidgetY(w1),GetWidgetX(w2)-GetWidgetX(w1))
endfunction
function PolarXVJ takes real d, real a returns real
    return d*Cos(a*bj_DEGTORAD)
endfunction
function PolarYVJ takes real d, real a returns real
    return d*Sin(a*bj_DEGTORAD)
endfunction
function PolarXRadVJ takes real d, real a returns real
    return d*Cos(a)
endfunction
function PolarYRadVJ takes real d, real a returns real
    return d*Sin(a)
endfunction
// 현재 각도가 유도율만큼 목표 각도를 바라보게 만드는 산술 함수입니다
function MoveAngleToVJ takes real a, real t, real d returns real
    local real v = ModuloReal(t-a+180,360)
    if v < 0 then
        set v = v + 360
    endif
    return a + RMaxBJ(-d, RMinBJ(d,-180 + v))
endfunction
//===========================================================
// 텍스트 파일 작성 기능입니다. Preload가 있지만, 직관적인 함수명으로 교체
function TextWriteStartVJ takes player p returns nothing
    if GetLocalPlayer() == p then
        call PreloadGenClear()
        call PreloadGenStart()
    endif
endfunction
function TextWriteVJ takes player p, string s returns nothing
    if GetLocalPlayer() == p then
        call Preload(s)
    endif
endfunction
function TextWriteEndVJ takes player p, string f returns nothing
    if GetLocalPlayer() == p then
        call PreloadGenEnd(f)
    endif
endfunction
//===========================================================
// 게임 내 시간이 저녁임
function IsNightVJ takes nothing returns boolean
    return 6.0 > GetTimeOfDay() or GetTimeOfDay() >= 18.0
endfunction
// 게임 내 시간이 아침임
function IsDayVJ takes nothing returns boolean
    return 6.0 <= GetTimeOfDay() and GetTimeOfDay() < 18.0
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
