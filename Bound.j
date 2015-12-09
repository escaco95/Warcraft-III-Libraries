/*
  카메라 경계를 쉽게 조작할 수 있도록 구성된 객체입니다.
  bound.apply( 플레이어, X, Y )
  플레이어의 카메라 경계를 좌표로 고정합니다 = 카메라 위치를 고정합니다.
  bound.applyPosition( 플레이어, minX, minY, maxX, maxY )
  플레이어의 카메라 경계를 좌표 범위로 설정합니다.
  bound.applyDimension( 플레이어, X, Y, 너비, 높이 )
  플레이어의 카메라 경계를 좌표 기준 너비 높이를 가진 직사각형으로 설정합니다.
  bound.applyRect( 플레이어, 구역 )
  더 이상의 자세한 설명은 생략합니다.
*/
library Bound
    struct bound extends array
        static method apply takes player p, real x, real y returns nothing
            if GetLocalPlayer() == p or p == null then
                call SetCameraBounds( x, y, x, y, x, y, x, y )
            endif
        endmethod
        static method applyPosition takes player p, real minX, real minY, real maxX, real maxY returns nothing
            if GetLocalPlayer() == p or p == null then
                call SetCameraBounds( minX, minY, minX, maxY, maxX, maxY, maxX, minY )
            endif
        endmethod
        static method applyDimension takes player p, real x, real y, real w, real h returns nothing
            local real minX = x
            local real minY = y-h
            local real maxX = x+w
            local real maxY = y
            if GetLocalPlayer() == p or p == null then
                call SetCameraBounds( minX, minY, minX, maxY, maxX, maxY, maxX, minY )
            endif
        endmethod
        static method applyRect takes player p, rect r returns nothing
            local real minX = GetRectMinX(r)
            local real minY = GetRectMinY(r)
            local real maxX = GetRectMaxX(r)
            local real maxY = GetRectMaxY(r)
            if GetLocalPlayer() == p or p == null then
                call SetCameraBounds( minX, minY, minX, maxY, maxX, maxY, maxX, minY )
            endif
        endmethod
    endstruct
endlibrary

