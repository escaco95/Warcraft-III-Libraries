/*
  각도/거리/오프셋을 보다 쉽게 계산할 수 있도록 고안된 라이브러리입니다.
  
  PBP : Point Between Point (좌표와 좌표 간) (X,Y,X2,Y2)
  PBW : Point Between Widget (좌표와 위젯 간) (X,Y,T)
  WBP : Widget Between Point (위젯과 좌표 간) (S,X2,Y2)
  WBW : Widget Between Widget (위젯과 위젯 간) (S,T)
  
  위젯이란? 유닛/아이템/장식물을 통틀어서 부르는 말입니다.
  
  [각도]
    Angle.PBP //0~360도 체계를 사용합니다.
    Angle.PBW //0~360도 체계를 사용합니다.
    Angle.WBP //0~360도 체계를 사용합니다.
    Angle.WBW //0~360도 체계를 사용합니다.
    Angle.RadPBP //라디안 값을 반환합니다.
    Angle.RadPBW //라디안 값을 반환합니다.
    Angle.RadWBP //라디안 값을 반환합니다.
    Angle.RadWBW //라디안 값을 반환합니다.
    Angle.trans( 원본 각도, 목표 각도, 유도율 ) //원본 각도에 유도율을 더한 각도를 반환합니다. 목표 각도를 넘지 않습니다.
      예시))Angle.trans( 유도미사일의 현재 각도, 유도미사일과 적 사이 각도, 1 )
    
  [거리]
    Distance.PBP
    Distance.PBW
    Distance.WBP
    Distance.WBW
    
  [오프셋]
    Polar.X(거리, 각도) //원점(0,0)으로부터 (거리), (각도)만큼의 위치한 좌표의 X값을 반환합니다.
    Polar.Y(거리, 각도) //원점(0,0)으로부터 (거리), (각도)만큼의 위치한 좌표의 Y값을 반환합니다.
    Polar.RadX(거리, 라디안각)
    Polar.RadY(거리, 라디안각)
*/

library Angle

    struct Angle extends array
        private static method Cycle takes real a, real b, real c returns real
            local real d = c - b
            local real v = ModuloReal(a-b,d)
            if v < 0 then
                set v = v + d
            endif
            return b + v
        endmethod
        static method trans takes real a, real t, real d returns real
            return a + RMaxBJ(-d, RMinBJ(d, Cycle(t - a, -180, 180)))
        endmethod
        static method PBP takes real x, real y, real tx, real ty returns real
            local real dx = tx - x
            local real dy = ty - y
            return Atan2( dy, dx ) * bj_RADTODEG
        endmethod
        static method WBP takes widget w, real tx, real ty returns real
            local real dx = tx - GetWidgetX( w )
            local real dy = ty - GetWidgetY( w )
            return Atan2( dy, dx ) * bj_RADTODEG
        endmethod
        static method WBW takes widget w, widget t returns real
            local real dx = GetWidgetX( t ) - GetWidgetX( w )
            local real dy = GetWidgetY( t ) - GetWidgetY( w )
            return Atan2( dy, dx ) * bj_RADTODEG
        endmethod
        static method PBW takes real x, real y, widget t returns real
            local real dx = GetWidgetX( t ) - x
            local real dy = GetWidgetY( t ) - y
            return Atan2( dy, dx ) * bj_RADTODEG
        endmethod
        static method RadPBP takes real x, real y, real tx, real ty returns real
            local real dx = tx - x
            local real dy = ty - y
            return Atan2( dy, dx )
        endmethod
        static method RadWBP takes widget w, real tx, real ty returns real
            local real dx = tx - GetWidgetX( w )
            local real dy = ty - GetWidgetY( w )
            return Atan2( dy, dx )
        endmethod
        static method RadWBW takes widget w, widget t returns real
            local real dx = GetWidgetX( t ) - GetWidgetX( w )
            local real dy = GetWidgetY( t ) - GetWidgetY( w )
            return Atan2( dy, dx )
        endmethod
        static method RadPBW takes real x, real y, widget t returns real
            local real dx = GetWidgetX( t ) - x
            local real dy = GetWidgetY( t ) - y
            return Atan2( dy, dx )
        endmethod
    endstruct

endlibrary

library Distance

    struct Distance extends array
        static method PBP takes real x, real y, real tx, real ty returns real
            local real dx = tx - x
            local real dy = ty - y
            return SquareRoot( dx * dx + dy * dy )
        endmethod
        static method WBP takes widget w, real tx, real ty returns real
            local real dx = tx - GetWidgetX( w )
            local real dy = ty - GetWidgetY( w )
            return SquareRoot( dx * dx + dy * dy )
        endmethod
        static method WBW takes widget w, widget t returns real
            local real dx = GetWidgetX( t ) - GetWidgetX( w )
            local real dy = GetWidgetY( t ) - GetWidgetY( w )
            return SquareRoot( dx * dx + dy * dy )
        endmethod
        static method PBW takes real x, real y, widget t returns real
            local real dx = GetWidgetX( t ) - x
            local real dy = GetWidgetY( t ) - y
            return SquareRoot( dx * dx + dy * dy )
        endmethod
    endstruct

endlibrary

library Polar

    struct Polar extends array
        static method RadX takes real dist, real angle returns real
            return dist * Cos( angle )
        endmethod
        static method RadY takes real dist, real angle returns real
            return dist * Sin( angle )
        endmethod
        static method X takes real dist, real angle returns real
            return dist * Cos( angle * bj_DEGTORAD )
        endmethod
        static method Y takes real dist, real angle returns real
            return dist * Sin( angle * bj_DEGTORAD )
        endmethod
    endstruct

endlibrary
