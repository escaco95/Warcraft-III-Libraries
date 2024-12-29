// ---
// # Euclid 라이브러리
//
// > 이 라이브러리는 게임 내 각종 좌표 및 각도 계산을 위한 기능을 제공합니다. 
// > 각도를 계산하여 유닛과 위젯의 방향을 조정하거나, 극좌표 시스템을 사용하여 
// > 특정 거리만큼 이동시킬 수 있는 다양한 유틸리티 함수들을 포함하고 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**:  escaco95@naver.com
// - **GitHub**: [euclid.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/euclid.j)
//
// ## 버전
// - **Version**: 20240914.0
//
// ## Changelog
// - **2024-09-02**: 좌표 관련 함수 추가 및 수정.
// - **2024-09-01**: 맵 저장 속도를 높이고, 의도치 않은 struct 역전 호출 문제를 해결하기 위해 function 으로 변경.
// - **2024-08-31**: (구) angle distance polar 라이브러리를 통합하여 Euclid 라이브러리로 재작성.
//
// ## 주요 기능:
// 1. **각도 조작 기능**:
//    - 두 좌표나 개체 간의 각도를 계산.
//    - 유닛이 특정 각도나 좌표를 바라보게 설정.
//    - 무작위 각도 생성.
//
// 2. **거리 계산 기능**:
//    - 좌표 간, 개체 간의 직선 거리 계산.
//
// 3. **극좌표 이동 기능**:
//    - 특정 각도와 거리만큼 좌표를 이동.
//    - 유닛이나 아이템을 특정 방향으로 이동.
//
// 4. **곡선 계산 기능**:
//    - 두 좌표 사이의 사인 곡선, 원호, 가속/감속 이동 등 다양한 곡선 경로 계산.
//    - Catmull-Rom 곡선과 베지어 곡선 지원.
//
// 5. **좌표 제한 기능**:
//    - 좌표를 특정 원 또는 사각형 내로 제한.
//
// ## 활용 시나리오:
// - 유닛이나 프로젝트가 특정 지점을 향해 이동하는 게임 로직.
// - 유닛들이 특정 각도로 이동하거나 회전할 때.
// - 복잡한 곡선 이동을 구현할 때 (예: 유도 미사일 경로).
// - 게임 맵에서 특정 범위 내에 좌표를 제한할 때.
//
// 이 라이브러리는 게임 개발 시 반복적으로 사용되는 좌표 및 각도 계산을 단순화하고 
// 코드의 재사용성을 높이기 위해 설계되었습니다.
// ---
library Euclid

    globals
        private constant real MAX_RADIAN = bj_PI * 2
    endglobals

    private function AngleCycle takes real a, real b, real c returns real
        local real d = c - b
        local real v = ModuloReal( a - b, d )
        if v < 0 then
            set v = v + d
        endif
        return b + v
    endfunction

    // ---
    // ## 📐 유클리드 - 유도 회전
    // > ### [지정 각도](<real currentAngle>)가 [목표 각도](<real targetAngle>)를 향해 [변화량](<real delta>)만큼 회전합니다
    // ---
    // ##### ⚠️ [변화량](<real delta>)이 0 미만인 경우 오작동합니다
    // ##### ℹ️ [변화량](<real delta>)이 0인 경우 유도 회전이 없습니다
    // ##### ℹ️ [변화량](<real delta>)이 180보다 큰 경우 즉시 목표 각도를 바라봅니다
    // ---
    // takes
    // - real currentAngle 현재 각도
    // - real targetAngle 목표 각도
    // - real delta 변화량
    // returns
    // - real 변화량만큼 목표 각도를 향해 회전된 각도
    function AngleTrans takes real currentAngle, real targetAngle, real delta returns real
        return currentAngle + RMaxBJ( -delta, RMinBJ( delta, AngleCycle( targetAngle - currentAngle, -180, 180 ) ) )
    endfunction
    
    // ---
    // ## 📐 유클리드 - 무작위 각도
    // > ### 0부터 360까지의 무작위 각도를 반환합니다
    // ---
    // ##### ℹ️ [무작위 호도](<function AngleRadRandom>)를 반환하는 함수도 따로 있습니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 무작위 각도
    function AngleRandom takes nothing returns real
        return GetRandomReal( 0.0, 360.0 )
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표 간 각도
    // > ### [X](<real x>)와 [Y](<real y>) 좌표가 [X](<real tx>)와 [Y](<real ty>) 좌표를 바라보는 각도를 계산합니다
    // ---
    // ##### ℹ️ 두 좌표가 같은 경우 0을 반환합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 기준점이 목표를 바라보는 각도
    function AnglePBP takes real x, real y, real tx, real ty returns real
        return Atan2( ty - y, tx - x ) * bj_RADTODEG
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표와 개체 간 각도
    // > ### [X](<real x>)와 [Y](<real y>) 좌표가 [개체](<widget t>)를 바라보는 각도를 계산합니다
    // ---
    // ##### ℹ️ 좌표과 개체 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - widget t 목표 개체
    // returns
    // - real 기준점이 개체를 바라보는 각도
    function AnglePBW takes real x, real y, widget t returns real
        return Atan2( GetWidgetY( t ) - y, GetWidgetX( t ) - x ) * bj_RADTODEG
    endfunction

    // ---
    // ## 📐 유클리드 - 개체와 좌표 간 각도
    // > ### [개체](<widget w>)가 [X](<real tx>)와 [Y](<real ty>) 좌표를 바라보는 각도를 계산합니다
    // ---
    // ##### ℹ️ 개체 위치와 좌표가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 기준 개체가 목표를 바라보는 각도
    function AngleWBP takes widget w, real tx, real ty returns real
        return Atan2( ty - GetWidgetY( w ), tx - GetWidgetX( w ) ) * bj_RADTODEG
    endfunction

    // ---
    // ## 📐 유클리드 - 개체 간 각도
    // > ### [개체](<widget w>)가 [개체](<widget t>)를 바라보는 각도를 계산합니다
    // ---
    // ##### ℹ️ 두 개체의 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - widget t 목표 개체
    // returns
    // - real 기준 개체가 목표 개체를 바라보는 각도
    function AngleWBW takes widget w, widget t returns real
        return Atan2( GetWidgetY( t ) - GetWidgetY( w ), GetWidgetX( t ) - GetWidgetX( w ) ) * bj_RADTODEG
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛이 각도를 바라보게 함
    // > ### [유닛](<unit u>)이 [각도](<real angle>)를 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real angle 목표 각도
    // returns
    // - nothing
    function AngleUTA takes unit u, real angle returns nothing
        call SetUnitFacing( u, angle )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛이 좌표를 바라보게 함
    // > ### [유닛](<unit u>)이 [X](<real x>)와 [Y](<real y>) 좌표를 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ℹ️ 유닛과 좌표가 같은 경우 0도(오른쪽)를 바라봅니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real x 목표 X 좌표
    // - real y 목표 Y 좌표
    // returns
    // - nothing
    function AngleUTP takes unit u, real x, real y returns nothing
        call SetUnitFacing( u, Atan2( y - GetWidgetY( u ), x - GetWidgetX( u ) ) * bj_RADTODEG )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛이 개체를 바라보게 함
    // > ### [유닛](<unit u>)이 [개체](<widget t>)를 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ℹ️ 유닛과 개체가 같은 경우 0도(오른쪽)를 바라봅니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표를 바라봅니다
    function AngleUTW takes unit u, widget t returns nothing
        call SetUnitFacing( u, Atan2( GetWidgetY( t ) - GetWidgetY( u ), GetWidgetX( t ) - GetWidgetX( u ) ) * bj_RADTODEG )
    endfunction

    // ---
    // ## 📐 유클리드 - 무작위 호도
    // > ### 0부터 2π까지의 무작위 호도를 반환합니다
    // ---
    // ##### ℹ️ [무작위 각도](<function AngleRandom>)를 반환하는 함수도 따로 있습니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 무작위 호도
    function AngleRadRandom takes nothing returns real
        return GetRandomReal( 0.0, MAX_RADIAN )
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표 간 호도
    // > ### [X](<real x>)와 [Y](<real y>) 좌표가 [X](<real tx>)와 [Y](<real ty>) 좌표를 바라보는 호도를 계산합니다
    // ---
    // ##### ℹ️ 두 좌표가 같은 경우 0을 반환합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 기준점이 목표를 바라보는 호도
    function AngleRadPBP takes real x, real y, real tx, real ty returns real
        return Atan2( ty - y, tx - x )
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표와 개체 간 호도
    // > ### [X](<real x>)와 [Y](<real y>) 좌표가 [개체](<widget t>)를 바라보는 호도를 계산합니다
    // ---
    // ##### ℹ️ 좌표과 개체 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - widget t 목표 개체
    // returns
    // - real 기준점이 개체를 바라보는 호도
    function AngleRadPBW takes real x, real y, widget t returns real
        return Atan2( GetWidgetY( t ) - y, GetWidgetX( t ) - x )
    endfunction

    // ---
    // ## 📐 유클리드 - 개체와 좌표 간 호도
    // > ### [개체](<widget w>)가 [X](<real tx>)와 [Y](<real ty>) 좌표를 바라보는 호도를 계산합니다
    // ---
    // ##### ℹ️ 개체 위치와 좌표가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 기준 개체가 목표를 바라보는 호도
    function AngleRadWBP takes widget w, real tx, real ty returns real
        return Atan2( ty - GetWidgetY( w ), tx - GetWidgetX( w ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 개체 간 호도
    // > ### [개체](<widget w>)가 [개체](<widget t>)를 바라보는 호도를 계산합니다
    // ---
    // ##### ℹ️ 두 개체의 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - widget t 목표 개체
    // returns
    // - real 기준 개체가 목표 개체를 바라보는 호도
    function AngleRadWBW takes widget w, widget t returns real
        return Atan2( GetWidgetY( t ) - GetWidgetY( w ), GetWidgetX( t ) - GetWidgetX( w ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛이 호도를 바라보게 함
    // > ### [유닛](<unit u>)이 [호도](<real radian>)를 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real radian 목표 호도
    // returns
    // - nothing
    function AngleRadUTA takes unit u, real radian returns nothing
        call SetUnitFacing( u, radian * bj_RADTODEG )
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표 간 거리
    // > ### [X](<real x>)와 [Y](<real y>) 좌표와 [X](<real tx>)와 [Y](<real ty>) 좌표 간의 직선 거리를 계산합니다
    // ---
    // ##### ℹ️ 두 좌표가 같은 경우 0을 반환합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 두 좌표 간의 직선 거리
    function DistancePBP takes real x, real y, real tx, real ty returns real
        local real dx = tx - x
        local real dy = ty - y
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표와 개체 간 거리
    // > ### [X](<real x>)와 [Y](<real y>) 좌표와 [개체](<widget t>) 간의 직선 거리를 계산합니다
    // ---
    // ##### ℹ️ 좌표과 개체 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - real x 기준점 X 좌표
    // - real y 기준점 Y 좌표
    // - widget t 목표 개체
    // returns
    // - real 기준점과 개체 간의 직선 거리
    function DistancePBW takes real x, real y, widget t returns real
        local real dx = GetWidgetX( t ) - x
        local real dy = GetWidgetY( t ) - y
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ---
    // ## 📐 유클리드 - 개체와 좌표 간 거리
    // > ### [개체](<widget w>)와 [X](<real tx>)와 [Y](<real ty>) 좌표 간의 직선 거리를 계산합니다
    // ---
    // ##### ℹ️ 개체 위치와 좌표가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - real tx 목표 X 좌표
    // - real ty 목표 Y 좌표
    // returns
    // - real 기준 개체와 좌표 간의 직선 거리
    function DistanceWBP takes widget w, real tx, real ty returns real
        local real dx = tx - GetWidgetX( w )
        local real dy = ty - GetWidgetY( w )
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ---
    // ## 📐 유클리드 - 개체 간 거리
    // > ### [개체](<widget w>)와 [개체](<widget t>) 간의 직선 거리를 계산합니다
    // ---
    // ##### ℹ️ 두 개체의 위치가 같은 경우 0을 반환합니다
    // ##### ⚠️ [개체](<widget t>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 기준 개체
    // - widget t 목표 개체
    // returns
    // - real 개체 간 직선 거리
    function DistanceWBW takes widget w, widget t returns real
        local real dx = GetWidgetX( t ) - GetWidgetX( w )
        local real dy = GetWidgetY( t ) - GetWidgetY( w )
        return SquareRoot( dx * dx + dy * dy )
    endfunction

    // ---
    // ## 📐 유클리드 - 각도 이동 X
    // > ### 원점(0,0) 기준 [거리](<real dist>)만큼 [각도](<real angle>) 방향으로 이동한 X 좌표를 계산합니다
    // ---
    // takes
    // - real dist 거리
    // - real angle 각도
    // returns
    // - real 원점(0,0) 기준 지정한 각도로 거리만큼 이동한 X 좌표
    function PolarX takes real dist, real angle returns real
        return dist * Cos( angle * bj_DEGTORAD )
    endfunction

    // ---
    // ## 📐 유클리드 - 각도 이동 Y
    // > ### 원점(0,0) 기준 [거리](<real dist>)만큼 [각도](<real angle>) 방향으로 이동한 Y 좌표를 계산합니다
    // ---
    // takes
    // - real dist 거리
    // - real angle 각도
    // returns
    // - real 원점(0,0) 기준 지정한 각도로 거리만큼 이동한 Y 좌표
    function PolarY takes real dist, real angle returns real
        return dist * Sin( angle * bj_DEGTORAD )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 방향으로 거리만큼 이동
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [각도](<real angle>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real angle 이동 각도
    // returns
    // - nothing
    function PolarUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( angle * bj_DEGTORAD ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( angle * bj_DEGTORAD ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 좌표 방향으로 거리만큼 이동
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [X](<real x>)와 [Y](<real y>) 좌표 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ⚠️ 목표 좌표를 넘어갈 수 있습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real x 목표 X 좌표
    // - real y 목표 Y 좌표
    // returns
    // - nothing
    function PolarUTP takes unit u, real dist, real x, real y returns nothing
        local real angle = Atan2( y - GetWidgetY( u ), x - GetWidgetX( u ) )
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( angle ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( angle ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 개체 방향으로 거리만큼 이동
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [개체](<widget t>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ℹ️ 개체가 존재하지 않는 경우 (0,0) 좌표로 이동합니다
    // ##### ⚠️ 목표 개체를 넘어갈 수 있습니다
    // ---
    function PolarUTW takes unit u, real dist, widget t returns nothing
        local real angle = Atan2( GetWidgetY( t ) - GetWidgetY( u ), GetWidgetX( t ) - GetWidgetX( u ) )
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( angle ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( angle ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 아이템을 지정한 방향으로 거리만큼 이동
    // > ### [아이템](<item i>)을 [거리](<real dist>)만큼 [각도](<real angle>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 아이템이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - item i 대상 아이템
    // - real dist 이동 거리
    // - real angle 이동 각도
    // returns
    // - nothing
    function PolarITA takes item i, real dist, real angle returns nothing
        call SetItemPosition( i, GetWidgetX( i ) + dist * Cos( angle * bj_DEGTORAD ), GetWidgetY( i ) + dist * Sin( angle * bj_DEGTORAD ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 아이템을 좌표 방향으로 거리만큼 이동
    // > ### [아이템](<item i>)을 [거리](<real dist>)만큼 [X](<real x>)와 [Y](<real y>) 좌표 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 아이템이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ⚠️ 목표 좌표를 넘어갈 수 있습니다
    // ---
    // takes
    // - item i 대상 아이템
    // - real dist 이동 거리
    // - real x 목표 X 좌표
    // - real y 목표 Y 좌표
    // returns
    // - nothing
    function PolarITP takes item i, real dist, real x, real y returns nothing
        local real angle = Atan2( y - GetWidgetY( i ), x - GetWidgetX( i ) )
        call SetItemPosition( i, GetWidgetX( i ) + dist * Cos( angle ), GetWidgetY( i ) + dist * Sin( angle ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 아이템을 개체 방향으로 거리만큼 이동
    // > ### [아이템](<item i>)을 [거리](<real dist>)만큼 [개체](<widget t>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 아이템이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ℹ️ 개체가 존재하지 않는 경우 (0,0) 좌표 방향으로 이동합니다
    // ##### ⚠️ 목표 개체를 넘어갈 수 있습니다
    // ---
    // takes
    // - item i 대상 아이템
    // - real dist 이동 거리
    // - widget t 목표 개체
    // returns
    // - nothing
    function PolarITW takes item i, real dist, widget t returns nothing
        local real angle = Atan2( GetWidgetY( t ) - GetWidgetY( i ), GetWidgetX( t ) - GetWidgetX( i ) )
        call SetItemPosition( i, GetWidgetX( i ) + dist * Cos( angle ), GetWidgetY( i ) + dist * Sin( angle ))
    endfunction

    // ---
    // ## 📐 유클리드 - 호도 이동 X
    // > ### 원점(0,0) 기준 [거리](<real dist>)만큼 [호도](<real angle>) 방향으로 이동한 X 좌표를 계산합니다
    // ---
    // takes
    // - real dist 거리
    // - real radian 호도
    // returns
    // - real 원점(0,0) 기준 지정한 호도로 거리만큼 이동한 X 좌표
    function PolarRadX takes real dist, real radian returns real
        return dist * Cos( radian )
    endfunction

    // ---
    // ## 📐 유클리드 - 호도 이동 Y
    // > ### 원점(0,0) 기준 [거리](<real dist>)만큼 [호도](<real angle>) 방향으로 이동한 Y 좌표를 계산합니다
    // ---
    // takes
    // - real dist 거리
    // - real radian 호도
    // returns
    // - real 원점(0,0) 기준 지정한 호도로 거리만큼 이동한 Y 좌표
    function PolarRadY takes real dist, real radian returns real
        return dist * Sin( radian )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 호도로 거리만큼 이동
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [호도](<real radian>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real radian 이동 호도
    // returns
    // - nothing
    function PolarRadUTA takes unit u, real dist, real radian returns nothing
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( radian ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( radian ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 아이템을 지정한 호도로 거리만큼 이동
    // > ### [아이템](<item i>)을 [거리](<real dist>)만큼 [호도](<real radian>) 방향으로 이동시킵니다
    // ---
    // ##### ℹ️ 아이템이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - item i 대상 아이템
    // - real dist 이동 거리
    // - real radian 이동 호도
    // returns
    // - nothing
    function PolarRadITA takes item i, real dist, real radian returns nothing
        call SetItemPosition( i, GetWidgetX( i ) + dist * Cos( radian ), GetWidgetY( i ) + dist * Sin( radian ) )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 방향으로 거리만큼 이동 및 방향 전환
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [각도](<real angle>) 방향으로 이동시키고, 해당 방향을 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real angle 이동 각도
    // returns
    // - nothing
    function PolarAngleUTA takes unit u, real dist, real angle returns nothing
        call SetUnitX( u, GetUnitX(u)+ dist * Cos(angle * bj_DEGTORAD))
        call SetUnitY( u, GetUnitY(u)+ dist * Sin(angle * bj_DEGTORAD))
        call SetUnitFacing( u, angle )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 좌표 방향으로 이동 및 방향 전환
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [X](<real x>)와 [Y](<real y>) 좌표 방향으로 이동시키고, 해당 방향을 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ⚠️ 목표 좌표를 넘어갈 수 있습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real x 목표 X 좌표
    // - real y 목표 Y 좌표
    // returns
    // - nothing
    function PolarAngleUTP takes unit u, real dist, real x, real y returns nothing
        local real radian = Atan2( y - GetWidgetY(u), x - GetWidgetX( u ) )
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( radian ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( radian ) )
        call SetUnitFacing( u, radian * bj_RADTODEG )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 개체 방향으로 이동 및 방향 전환
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [개체](<widget t>) 방향으로 이동시키고, 해당 방향을 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ##### ℹ️ 개체가 존재하지 않는 경우 (0,0) 좌표 방향으로 이동합니다
    // ##### ⚠️ 목표 개체를 넘어갈 수 있습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - widget t 목표 개체
    // returns
    // - nothing
    function PolarAngleUTW takes unit u, real dist, widget t returns nothing
        local real angle = Atan2( GetWidgetY( t ) - GetWidgetY( u ), GetWidgetX( t ) - GetWidgetX( u ) )
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( angle ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( angle ) )
        call SetUnitFacing( u, angle * bj_RADTODEG )
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지정한 호도로 거리만큼 이동 및 방향 전환
    // > ### [유닛](<unit u>)을 [거리](<real dist>)만큼 [호도](<real radian>) 방향으로 이동시키고, 해당 방향을 바라보게 합니다
    // ---
    // ##### ℹ️ 유닛이 존재하지 않는 경우 아무런 동작도 하지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // - real dist 이동 거리
    // - real radian 이동 호도
    // returns
    // - nothing
    function PolarAngleRadUTA takes unit u, real dist, real radian returns nothing
        call SetUnitX( u, GetUnitX( u ) + dist * Cos( radian ) )
        call SetUnitY( u, GetUnitY( u ) + dist * Sin( radian ) )
        call SetUnitFacing( u, radian * bj_RADTODEG )
    endfunction

    globals
        private real CURVE_X = 0.0
        private real CURVE_Y = 0.0
        private real CURVE_Z = 0.0
    endglobals

    // ---
    // ## 📐 유클리드 - 곡선 좌표 X
    // > ### 계산된 곡선의 X 좌표를 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 곡선의 X 좌표
    function CurveX takes nothing returns real
        return CURVE_X
    endfunction

    // ---
    // ## 📐 유클리드 - 곡선 좌표 Y
    // > ### 계산된 곡선의 Y 좌표를 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 곡선의 Y 좌표
    function CurveY takes nothing returns real
        return CURVE_Y
    endfunction

    // ---
    // ## 📐 유클리드 - 곡선 좌표 Z
    // > ### 계산된 곡선의 Z 좌표를 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 곡선의 Z 좌표
    function CurveZ takes nothing returns real
        return CURVE_Z
    endfunction

    // ---
    // ## 📐 유클리드 - 사인 곡선
    // > ### 좌표([X](<real x1>), [Y](<real y1>), [Z](<real z1>))와 좌표([X](<real x2>), [Y](<real y2>), [Z](<real z2>))를 연결하는 지정 [높이](<real h>)를 가진 사인 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x1 시작 X 좌표
    // - real y1 시작 Y 좌표
    // - real z1 시작 Z 좌표
    // - real x2 끝 X 좌표
    // - real y2 끝 Y 좌표
    // - real z2 끝 Z 좌표
    // - real h 곡선 높이
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveSin takes real x1, real y1, real z1, real x2, real y2, real z2, real h, real p returns nothing
        set CURVE_X = x1 + p * (x2 - x1)
        set CURVE_Y = y1 + p * (y2 - y1)
        set CURVE_Z = z1 + p * (z2 - z1) + h * Sin( bj_PI * p )
    endfunction

    // ---
    // ## 📐 유클리드 - 원호 곡선
    // > ### 좌표([X](<real x1>), [Y](<real y1>), [Z](<real z1>))와 좌표([X](<real x2>), [Y](<real y2>), [Z](<real z2>))를 연결하는 지정 [반지름](<real radius>)을 가진 원호 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    function CurveArc takes real x1, real y1, real z1, real x2, real y2, real z2, real radius, real p returns nothing
        local real angle = Atan2(y2 - y1, x2 - x1)
        local real d = SquareRoot((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        local real a = angle + (p - 0.5) * (d / radius)
    
        set CURVE_X = x1 + radius * Cos(a)
        set CURVE_Y = y1 + radius * Sin(a)
        set CURVE_Z = z1 + p * (z2 - z1)
    endfunction

    // ---
    // ## 📐 유클리드 - 부드러운 밀도의 직선
    // > ### 좌표([X](<real x1>), [Y](<real y1>), [Z](<real z1>))와 좌표([X](<real x2>), [Y](<real y2>), [Z](<real z2>))를 연결하는 부드러운 밀도 직선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x1 시작 X 좌표
    // - real y1 시작 Y 좌표
    // - real z1 시작 Z 좌표
    // - real x2 끝 X 좌표
    // - real y2 끝 Y 좌표
    // - real z2 끝 Z 좌표
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveEase takes real x1, real y1, real z1, real x2, real y2, real z2, real p returns nothing
        local real p2 = p * p
        local real p_inv = 1.0 - p
        local real p2_inv = p_inv * p_inv
    
        set CURVE_X = p2_inv * x1 + p2 * x2
        set CURVE_Y = p2_inv * y1 + p2 * y2
        set CURVE_Z = p2_inv * z1 + p2 * z2
    endfunction

    // ---
    // ## 📐 유클리드 - Catmull-Rom 곡선
    // > ### 4개의 좌표를 경유하는 Catmull-Rom 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x0 시작 X 좌표
    // - real y0 시작 Y 좌표
    // - real z0 시작 Z 좌표
    // - real x1 중간1 X 좌표
    // - real y1 중간1 Y 좌표
    // - real z1 중간1 Z 좌표
    // - real x2 중간2 X 좌표
    // - real y2 중간2 Y 좌표
    // - real z2 중간2 Z 좌표
    // - real x3 끝 X 좌표
    // - real y3 끝 Y 좌표
    // - real z3 끝 Z 좌표
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveCatmullRom takes real x0, real y0, real z0, real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real p returns nothing
        local real p2 = p * p
        local real p3 = p2 * p
    
        set CURVE_X = 0.5 * ((2 * x1) + (-x0 + x2) * p + (2*x0 - 5*x1 + 4*x2 - x3) * p2 + (-x0 + 3*x1 - 3*x2 + x3) * p3)
        set CURVE_Y = 0.5 * ((2 * y1) + (-y0 + y2) * p + (2*y0 - 5*y1 + 4*y2 - y3) * p2 + (-y0 + 3*y1 - 3*y2 + y3) * p3)
        set CURVE_Z = 0.5 * ((2 * z1) + (-z0 + z2) * p + (2*z0 - 5*z1 + 4*z2 - z3) * p2 + (-z0 + 3*z1 - 3*z2 + z3) * p3)
    endfunction

    // ---
    // ## 📐 유클리드 - 베지어 곡선 (1차)
    // > ### 2개의 좌표를 경유하는 베지어 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x1 시작 X 좌표
    // - real y1 시작 Y 좌표
    // - real z1 시작 Z 좌표
    // - real x2 끝 X 좌표
    // - real y2 끝 Y 좌표
    // - real z2 끝 Z 좌표
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveBezier1 takes real x1, real y1, real z1, real x2, real y2, real z2, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * x1 + p * x2
        set CURVE_Y = oneMinusP * y1 + p * y2
        set CURVE_Z = oneMinusP * z1 + p * z2
    endfunction

    // ---
    // ## 📐 유클리드 - 베지어 곡선 (2차)
    // > ### 3개의 좌표를 경유하는 베지어 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x1 시작 X 좌표
    // - real y1 시작 Y 좌표
    // - real z1 시작 Z 좌표
    // - real x2 중간 X 좌표
    // - real y2 중간 Y 좌표
    // - real z2 중간 Z 좌표
    // - real x3 끝 X 좌표
    // - real y3 끝 Y 좌표
    // - real z3 끝 Z 좌표
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveBezier2 takes real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * oneMinusP * x1 + 2 * oneMinusP * p * x2 + p * p * x3
        set CURVE_Y = oneMinusP * oneMinusP * y1 + 2 * oneMinusP * p * y2 + p * p * y3
        set CURVE_Z = oneMinusP * oneMinusP * z1 + 2 * oneMinusP * p * z2 + p * p * z3
    endfunction

    // ---
    // ## 📐 유클리드 - 베지어 곡선 (3차)
    // > ### 4개의 좌표를 경유하는 베지어 곡선 위 [지점](<real p>)의 좌표를 계산합니다
    // ---
    // ##### ℹ️ 계산 결과 좌표는 [CurveX](<function CurveX>), [CurveY](<function CurveY>), [CurveZ](<function CurveZ>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [곡선 위 좌표](<real p>)는 0에서 1 사이의 값으로 지정되어야 합니다
    // ---
    // takes
    // - real x1 시작 X 좌표
    // - real y1 시작 Y 좌표
    // - real z1 시작 Z 좌표
    // - real x2 중간1 X 좌표
    // - real y2 중간1 Y 좌표
    // - real z2 중간1 Z 좌표
    // - real x3 중간2 X 좌표
    // - real y3 중간2 Y 좌표
    // - real z3 중간2 Z 좌표
    // - real x4 끝 X 좌표
    // - real y4 끝 Y 좌표
    // - real z4 끝 Z 좌표
    // - real p 곡선 위 지점
    // returns
    // - nothing
    function CurveBezier3 takes real x1, real y1, real z1, real x2, real y2, real z2, real x3, real y3, real z3, real x4, real y4, real z4, real p returns nothing
        local real oneMinusP = 1.0 - p
        set CURVE_X = oneMinusP * oneMinusP * oneMinusP * x1 + 3 * oneMinusP * oneMinusP * p * x2 + 3 * oneMinusP * p * p * x3 + p * p * p * x4
        set CURVE_Y = oneMinusP * oneMinusP * oneMinusP * y1 + 3 * oneMinusP * oneMinusP * p * y2 + 3 * oneMinusP * p * p * y3 + p * p * p * y4
        set CURVE_Z = oneMinusP * oneMinusP * oneMinusP * z1 + 3 * oneMinusP * oneMinusP * p * z2 + 3 * oneMinusP * p * p * z3 + p * p * p * z4
    endfunction

    globals
        private real POINT_X = 0.0
        private real POINT_Y = 0.0
    endglobals

    // ---
    // ## 📐 유클리드 - 좌표 X 값
    // > ### 계산한 좌표의 X 값을 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 좌표의 X 값
    function PointX takes nothing returns real
        return POINT_X
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표 Y 값
    // > ### 계산한 좌표의 Y 값을 반환합니다
    // ---
    // takes
    // - nothing
    // returns
    // - real 좌표의 Y 값
    function PointY takes nothing returns real
        return POINT_Y
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 원점으로 초기화
    // > ### 좌표를 (0,0)으로 초기화합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - nothing
    // returns
    // - nothing
    function PointReset takes nothing returns nothing
        set POINT_X = 0.0
        set POINT_Y = 0.0
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 X,Y 값으로 초기화
    // > ### 좌표를 지정한 [X](<real x>), [Y](<real y>) 위치로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x X 좌표
    // - real y Y 좌표
    // returns
    // - nothing
    function Point takes real x, real y returns nothing
        set POINT_X = x
        set POINT_Y = y
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 개체의 위치로 초기화
    // > ### 좌표를 지정한 [개체](<widget w>)의 위치로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 대상 개체
    // returns
    // - nothing
    function PointWidget takes widget w returns nothing
        set POINT_X = GetWidgetX(w)
        set POINT_Y = GetWidgetY(w)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 X 값을 개체 위치로 설정
    // > ### 좌표의 X 값을 지정한 [개체](<widget w>)의 X 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 대상 개체
    // returns
    // - nothing
    function PointWidgetX takes widget w returns nothing
        set POINT_X = GetWidgetX(w)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 Y 값을 개체 위치로 설정
    // > ### 좌표의 Y 값을 지정한 [개체](<widget w>)의 Y 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [개체](<widget w>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - widget w 대상 개체
    // returns
    // - nothing
    function PointWidgetY takes widget w returns nothing
        set POINT_Y = GetWidgetY(w)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 유닛의 위치로 초기화
    // > ### 좌표를 지정한 [유닛](<unit u>)의 위치로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [유닛](<unit u>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointUnit takes unit u returns nothing
        set POINT_X = GetUnitX(u)
        set POINT_Y = GetUnitY(u)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 X 값을 유닛 위치로 설정
    // > ### 좌표의 X 값을 지정한 [유닛](<unit u>)의 X 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [유닛](<unit u>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointUnitX takes unit u returns nothing
        set POINT_X = GetUnitX(u)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 Y 값을 유닛 위치로 설정
    // > ### 좌표의 Y 값을 지정한 [유닛](<unit u>)의 Y 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [유닛](<unit u>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointUnitY takes unit u returns nothing
        set POINT_Y = GetUnitY(u)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 아이템의 위치로 초기화
    // > ### 좌표를 지정한 [아이템](<item i>)의 위치로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [아이템](<item i>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - item i 대상 아이템
    // returns
    // - nothing
    function PointItem takes item i returns nothing
        set POINT_X = GetItemX(i)
        set POINT_Y = GetItemY(i)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 X 값을 아이템 위치로 설정
    // > ### 좌표의 X 값을 지정한 [아이템](<item i>)의 X 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [아이템](<item i>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - item i 대상 아이템
    // returns
    // - nothing
    function PointItemX takes item i returns nothing
        set POINT_X = GetItemX(i)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 Y 값을 아이템 위치로 설정
    // > ### 좌표의 Y 값을 지정한 [아이템](<item i>)의 Y 위치로 설정합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [아이템](<item i>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - item i 대상 아이템
    // returns
    // - nothing
    function PointItemY takes item i returns nothing
        set POINT_Y = GetItemY(i)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 플레이어의 시작 위치로 초기화
    // > ### 좌표를 지정한 [플레이어](<player p>)의 시작 위치로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [플레이어](<player p>)가 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - player p 대상 플레이어
    // returns
    // - nothing
    function PointPlayer takes player p returns nothing
        set POINT_X = GetStartLocationX(GetPlayerStartLocation(p))
        set POINT_Y = GetStartLocationY(GetPlayerStartLocation(p))
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 구역의 중심으로 초기화
    // > ### 좌표를 지정한 [구역](<rect r>)의 중심으로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [구역](<rect r>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - rect r 대상 구역
    // returns
    // - nothing
    function PointRect takes rect r returns nothing
        set POINT_X = GetRectCenterX(r)
        set POINT_Y = GetRectCenterY(r)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 구역 내 무작위 좌표로 초기화
    // > ### 좌표를 지정한 [구역](<rect r>) 내 무작위 좌표로 설정합니다
    // ---
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ [구역](<rect r>)이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - rect r 대상 구역
    // returns
    // - nothing
    function PointRandomRect takes rect r returns nothing
        set POINT_X = GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
        set POINT_Y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표 이동
    // > ### 좌표를 지정한 [X](<real x>), [Y](<real y>) 만큼 이동합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x X 이동 값
    // - real y Y 이동 값
    // returns
    // - nothing
    function PointMove takes real x, real y returns nothing
        set POINT_X = POINT_X + x
        set POINT_Y = POINT_Y + y
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 X 값을 이동
    // > ### 좌표의 X 값을 지정한 [X](<real x>) 만큼 이동합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x X 이동 값
    // returns
    // - nothing
    function PointMoveX takes real x returns nothing
        set POINT_X = POINT_X + x
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표의 Y 값을 이동
    // > ### 좌표의 Y 값을 지정한 [Y](<real y>) 만큼 이동합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real y Y 이동 값
    // returns
    // - nothing
    function PointMoveY takes real y returns nothing
        set POINT_Y = POINT_Y + y
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 중심점을 기준으로 회전
    // > ### 좌표를 지정한 중심점([X](<real x>), [Y](<real y>))을 기준으로 [각도](<real angle>)만큼 회전 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x 중심점 X 좌표
    // - real y 중심점 Y 좌표
    // - real angle 회전 각도
    // returns
    // - nothing
    function PointRotate takes real x, real y, real angle returns nothing
        local real cosA = Cos(angle * bj_DEGTORAD)
        local real sinA = Sin(angle * bj_DEGTORAD)
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        set POINT_X = x + dx * cosA - dy * sinA
        set POINT_Y = y + dx * sinA + dy * cosA
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 중심점을 기준으로 호의 길이만큼 회전
    // > ### 좌표를 지정한 중심점([X](<real x>), [Y](<real y>))을 기준으로 ([호의 길이](<real arc>))만큼 회전 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x 중심점 X 좌표
    // - real y 중심점 Y 좌표
    // - real arc 호의 길이
    // returns
    // - nothing
    function PointRotateArc takes real x, real y, real arc returns nothing
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        local real radius = SquareRoot(dx * dx + dy * dy)
        local real angle = arc / radius
        local real cosA = Cos(angle)
        local real sinA = Sin(angle)
        set POINT_X = x + dx * cosA - dy * sinA
        set POINT_Y = y + dx * sinA + dy * cosA
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 각도 방향으로 거리만큼 이동
    // > ### 좌표를 지정한 [거리](<real dist>), [각도](<real angle>)만큼 이동합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real dist 이동 거리
    // - real angle 이동 각도
    // returns
    // - nothing
    function PointPolar takes real dist, real angle returns nothing
        set POINT_X = POINT_X + dist * Cos(angle * bj_DEGTORAD)
        set POINT_Y = POINT_Y + dist * Sin(angle * bj_DEGTORAD)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 호도 방향으로 거리만큼 이동
    // > ### 좌표를 지정한 [거리](<real dist>), [호도](<real radian>)만큼 이동합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real dist 이동 거리
    // - real radian 이동 호도
    // returns
    // - nothing
    function PointPolarRad takes real dist, real radian returns nothing
        set POINT_X = POINT_X + dist * Cos(radian)
        set POINT_Y = POINT_Y + dist * Sin(radian)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 좌표를 향해 이동
    // > ### 좌표를 지정한 [거리](<real dist>)만큼 [X](<real x>), [Y](<real y>) 좌표를 향해 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ 목표 좌표를 넘어갈 수 있습니다
    // ---
    // takes
    // - real dist 이동 거리
    // - real x 이동 X 좌표
    // - real y 이동 Y 좌표
    // returns
    // - nothing
    function PointTowardPoint takes real dist, real x, real y returns nothing
        local real angle = Atan2(y - POINT_Y, x - POINT_X)
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 개체를 향해 이동
    // > ### 좌표를 지정한 [거리](<real dist>)만큼 [개체](<widget t>)를 향해 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ 목표 개체를 넘어갈 수 있습니다
    // ---
    // takes
    // - real dist 이동 거리
    // - widget t 대상 개체
    // returns
    // - nothing
    function PointTowardWidget takes real dist, widget t returns nothing
        local real angle = Atan2(GetWidgetY(t) - POINT_Y, GetWidgetX(t) - POINT_X)
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 반경 내 무작위 지점으로 이동
    // > ### 좌표를 지정한 [반경](<real radius>) 내 무작위 지점으로 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real radius 반경
    // returns
    // - nothing
    function PointSpreadCircle takes real radius returns nothing
        local real angle = GetRandomReal(0.0, bj_PI * 2)
        local real dist = radius * (1 - SquareRoot(GetRandomReal(0.0, 1.0)))
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 도넛 내 무작위 지점으로 이동
    // > ### 좌표를 지정한 [내부 반지름](<real inner>)과 [외부 반지름](<real outer>) 사이의 무작위 지점으로 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real inner 내부 반지름
    // - real outer 외부 반지름
    // returns
    // - nothing
    function PointSpreadDonut takes real inner, real outer returns nothing
        local real angle = GetRandomReal(0.0, bj_PI * 2)
        local real dist = inner + (outer - inner) * SquareRoot(GetRandomReal(0.0, 1.0))
        set POINT_X = POINT_X + dist * Cos(angle)
        set POINT_Y = POINT_Y + dist * Sin(angle)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 사각형 범위 내 무작위 지점으로 이동
    // > ### 좌표를 [너비](<real width>)와 [높이](<real height>) 사이의 무작위 지점으로 이동시킵니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real width 너비
    // - real height 높이
    // returns
    // - nothing
    function PointSpreadRect takes real width, real height returns nothing
        set POINT_X = POINT_X + GetRandomReal(-width, width)
        set POINT_Y = POINT_Y + GetRandomReal(-height, height)
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 구역 이내로 제한
    // > ### 좌표를 지정한 [구역](<rect r>) 내로 제한합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ##### ⚠️ 구역이 존재하지 않는 경우 (0,0) 좌표로 계산합니다
    // ---
    // takes
    // - rect r 대상 구역
    // returns
    // - nothing
    function PointLimitRect takes rect r returns nothing
        set POINT_X = RMaxBJ(GetRectMinX(r), RMinBJ(GetRectMaxX(r), POINT_X))
        set POINT_Y = RMaxBJ(GetRectMinY(r), RMinBJ(GetRectMaxY(r), POINT_Y))
    endfunction

    // ---
    // ## 📐 유클리드 - 좌표를 지정한 원 이내로 제한
    // > ### 좌표를 지정한 원([X](<real x>),[Y](<real y>),[반지름](<real radius>)) 내로 제한합니다
    // ---
    // ##### ℹ️ 좌표를 계산하기 전에 초기화하는 것이 좋습니다
    // ##### ℹ️ 계산한 좌표는 [PointX](<function PointX>), [PointY](<function PointY>) 함수로 확인할 수 있습니다
    // ---
    // takes
    // - real x 중심점 X 좌표
    // - real y 중심점 Y 좌표
    // - real radius 반지름
    // returns
    // - nothing
    function PointLimitCircle takes real x, real y, real radius returns nothing
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        local real dist = SquareRoot(dx * dx + dy * dy)
    
        // 좌표가 원의 반지름을 벗어났다면
        if dist > radius then
            // 원의 경계상 가장 가까운 지점으로 이동
            set POINT_X = x + dx * (radius / dist)
            set POINT_Y = y + dy * (radius / dist)
        endif
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛의 X 좌표를 지점 위치로 설정
    // > ### [유닛](<unit u>)의 X 좌표를 현재 계산 중인 좌표로 설정합니다
    // ---
    // ##### ℹ️ 유닛이 받은 명령이 취소되지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointBringUnitX takes unit u returns nothing
        call SetUnitX(u, POINT_X)
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛의 Y 좌표를 지점 위치로 설정
    // > ### [유닛](<unit u>)의 Y 좌표를 현재 계산 중인 좌표로 설정합니다
    // ---
    // ##### ℹ️ 유닛이 받은 명령이 취소되지 않습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointBringUnitY takes unit u returns nothing
        call SetUnitY(u, POINT_Y)
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지점 위치로 가져옵니다 (즉시)
    // > ### [유닛](<unit u>)을 현재 계산 중인 좌표로 가져옵니다
    // ---
    // ##### ℹ️ 유닛이 받은 명령이 취소되지 않습니다
    // ##### ℹ️ X 축 좌표가 먼저 이동된 후 Y 축 좌표가 이동됩니다
    // ##### ⚠️ 장거리 이동 시 주의하여 사용하십시오
    // ##### 🚨 각 좌표가 따로따로 이동되므로, 의도치 않은 위치에 이동 판정이 발생할 수 있습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointBringUnitXY takes unit u returns nothing
        call SetUnitX(u, POINT_X)
        call SetUnitY(u, POINT_Y)
    endfunction

    // ---
    // ## 📐 유클리드 - 유닛을 지점 위치로 가져옵니다
    // > ### [유닛](<unit u>)을 현재 계산 중인 좌표로 가져옵니다
    // ---
    // ##### ⚠️ 유닛이 받은 명령이 취소됩니다
    // ##### ⚠️ 재생 중인 유닛 애니메이션이 중단될 수 있습니다
    // ---
    // takes
    // - unit u 대상 유닛
    // returns
    // - nothing
    function PointBringUnit takes unit u returns nothing
        call SetUnitPosition(u, POINT_X, POINT_Y)
    endfunction

    // ---
    // ## 📐 유클리드 - 아이템을 지점 위치로 가져옵니다
    // > ### [아이템](<item i>)을 현재 계산 중인 좌표로 가져옵니다
    // ---
    // ##### ⚠️ 숨겨져 있던 아이템일 경우 보이게 됩니다
    // ##### ⚠️ 누군가 들고 있던 아이템일 경우 바닥에 떨어집니다
    // ---
    // takes
    // - item i 대상 아이템
    // returns
    // - nothing
    function PointBringItem takes item i returns nothing
        call SetItemPosition(i, POINT_X, POINT_Y)
    endfunction

    // ---
    // ## 📐 유클리드 - 현재 좌표가 지정한 범위 내에 있는지 확인
    // > ### 현재 좌표가 원([X](<real x>),[Y](<real y>),[범위](<real range>)) 내에 있는지 확인합니다
    // ---
    // ##### ℹ️ 좌표 정밀하며, 유닛 충돌 범위를 고려하지 않습니다
    // ##### ℹ️ 유닛 충돌 범위를 고려해야 할 경우 `IsUnitInRange`, `IsUnitInRangeXY` 함수를 사용하십시오
    // ---
    // takes
    // - real x X 좌표
    // - real y Y 좌표
    // - real range 범위
    // returns
    // - boolean 범위 내에 있으면 true, 아니면 false
    function IsPointInRange takes real x, real y, real range returns boolean
        return SquareRoot((POINT_X - x) * (POINT_X - x) + (POINT_Y - y) * (POINT_Y - y)) <= range
    endfunction

    // ---
    // ## 📐 유클리드 - 현재 좌표가 지정한 범위 구간 내에 있는지 확인
    // > ### 현재 좌표가 도넛([X](<real x>),[Y](<real y>),[최소 범위](<real minRange>),[최대 범위](<real maxRange)) 구간 내에 있는지 확인합니다
    // ---
    // ##### ℹ️ 좌표 정밀하며, 유닛 충돌 범위를 고려하지 않습니다
    // ##### ℹ️ 도넛 모양의 범위를 확인할 때 사용할 수 있습니다
    // ##### ℹ️ 유닛 충돌 범위를 고려해야 할 경우 `IsUnitInRange`, `IsUnitInRangeXY` 함수를 사용하십시오
    // ---
    // takes
    // - real x X 좌표
    // - real y Y 좌표
    // - real minRange 최소 범위
    // - real maxRange 최대 범위
    // returns
    // - boolean 범위 내에 있으면 true, 아니면 false
    function IsPointInRangeBetween takes real x, real y, real minRange, real maxRange returns boolean
        local real dx = POINT_X - x
        local real dy = POINT_Y - y
        local real distance = SquareRoot(dx * dx + dy * dy)
        return distance >= minRange and distance <= maxRange
    endfunction

    // ---
    // ## 📐 유클리드 - 현재 좌표가 지정한 선분 내에 있는지 확인
    // > ### 현재 좌표가 선분([시작 X](<real originX>),[시작 Y](<real originY>),[길이](<real length>),[방향](<real directionDeg>),[범위](<real range)) 내에 있는지 확인합니다
    // ---
    // ##### ℹ️ 좌표 정밀하며, 유닛 충돌 범위를 고려하지 않습니다
    // ---
    // takes
    // - real originX 시작 X 좌표
    // - real originY 시작 Y 좌표
    // - real length 선분 길이
    // - real directionDeg 선분 방향
    // - real range 선분 두께
    // returns
    // - boolean 범위 내에 있으면 true, 아니면 false
    function IsPointInRangeLine takes real originX, real originY, real length, real directionDeg, real range returns boolean
        local real dx = POINT_X - originX
        local real dy = POINT_Y - originY
        local real directionRad = bj_DEGTORAD * directionDeg
        local real endX
        local real endY
        local real lineDirX
        local real lineDirY
        local real lineLength
        local real projectionLength
        local real closestX
        local real closestY
        local real distX
        local real distY
        local real distance
    
        // Calculate the end point of the line
        set endX = originX + length * Cos(directionRad)
        set endY = originY + length * Sin(directionRad)
    
        // Calculate the direction vector of the line
        set lineDirX = endX - originX
        set lineDirY = endY - originY
        set lineLength = SquareRoot(lineDirX * lineDirX + lineDirY * lineDirY)
    
        // Normalize the direction vector
        set lineDirX = lineDirX / lineLength
        set lineDirY = lineDirY / lineLength
    
        // Calculate the projection length
        set projectionLength = dx * lineDirX + dy * lineDirY
    
        // Clamp the projection length to the line segment
        if projectionLength < 0 then
            set projectionLength = 0
        elseif projectionLength > length then
            set projectionLength = length
        endif
    
        // Calculate the closest point on the line segment
        set closestX = originX + projectionLength * lineDirX
        set closestY = originY + projectionLength * lineDirY
    
        // Calculate the distance from the point to the closest point on the line segment
        set distX = POINT_X - closestX
        set distY = POINT_Y - closestY
        set distance = SquareRoot(distX * distX + distY * distY)
    
        // Check if the distance is within the given range
        return distance <= range
    endfunction

    globals
        private real array POINT_X_STACK
        private real array POINT_Y_STACK
        private integer POINT_STACK_INDEX = 0
    endglobals

    // ---
    // ## 📐 유클리드 - 현재 좌표 스택
    // > ### 현재 좌표를 스택에 저장합니다
    // ---
    // ##### ℹ️ 트리거 간 좌표 계산 간섭을 방지하기 위해 사용됩니다
    // ##### ⚠️ 좌표는 최대 8191 중첩까지 스택 가능합니다
    // ##### ⚠️ `PointPush`와 `PointPop`은 반드시 쌍으로 사용되어야 합니다
    // ##### 🚨 만약 개발자 실수로 중첩 한계치를 넘기게 되면 치명적인 문제가 발생하게 됩니다
    // ---
    // **사용예시**
    // > `call PointPush( )`
    // > `// 이 사이에 Point 기능으로 하고 싶은 작업을 모두 코드로 작성`
    // > `call PointPop( )`
    // ---
    // takes
    // - nothing
    // returns
    // - nothing
    function PointPush takes nothing returns nothing
        set POINT_STACK_INDEX = POINT_STACK_INDEX + 1
        set POINT_X_STACK[POINT_STACK_INDEX] = POINT_X
        set POINT_Y_STACK[POINT_STACK_INDEX] = POINT_Y
    endfunction

    // ---
    // ## 📐 유클리드 - 현재 좌표 스택에서 불러오기
    // > ### 스택에 저장된 좌표를 불러옵니다
    // ---
    // ##### ℹ️ `PointPush`와 `PointPop`은 반드시 쌍으로 사용되어야 합니다
    // ##### ⚠️ 좌표 스택이 비어있을 경우 치명적인 오류가 발생합니다
    // ##### 🚨 만약 개발자 실수로 쌍이 맞지 않게 사용하게 되면 치명적인 문제가 발생하게 됩니다
    // ---
    // takes
    // - nothing
    // returns
    // - nothing
    function PointPop takes nothing returns nothing
        if POINT_STACK_INDEX <= 0 then
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "|cFFFF0000[FATAL] ERROR!! 좌표 스택이 비어있으나 PointPop 함수가 호출되었습니다!!|r")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "스크립트 어딘가에서 PointPush 와 PointPop 함수의 쌍이 맞지 않는 문제가 발생한 게 분명합니다.")
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 3600, "전수조사를 통해 문제를 해결하지 않을 경우, 좌표 기반 스크립트들이 모두 오작동할 수 있습니다.")
            return
        endif
        set POINT_X = POINT_X_STACK[POINT_STACK_INDEX]
        set POINT_Y = POINT_Y_STACK[POINT_STACK_INDEX]
        set POINT_STACK_INDEX = POINT_STACK_INDEX - 1
    endfunction

endlibrary
