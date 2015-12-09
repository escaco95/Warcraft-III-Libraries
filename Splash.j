/*
  스플래시 효과를 보다 쉽게 발생시키기 위해 고안된 라이브러리.
  splash.range( 필터, 시전자, X, Y, 거리, 실행 함수 ) // X,Y좌표를 중심으로 거리 안에 있는 모든 필터 대상에게 함수 실행
  splash.zone( 필터, 시전자, X, Y, 너비, 높이, 실행 함수 ) // X,Y좌표를 중심으로 직사각형 ""
  splash.rect( 필터, 시전자, 구역, 함수 ) // 구역 내의 ""
  
  splash.ENEMY // 필터 : 살아있는 시전자의 적
  splash.PLAYER // 필터 : 살아있는 시전자와 동일한 플레이어 소유의 유닛
  splash.ALLY // 필터 : 살아있는 시전자의 동맹
  splash.ANY // 필터 : 살아있는 아무 유닛
  
  예시)) 능력 시전자로부터 500거리 내 모든 적 즉사
  function Kill takes nothing returns nothing
    call KillUnit(GetEnumUnit())
  endfunction
  
  local unit u = GetTriggerUnit()
  call splash.range( splash.ENEMY, u, GetUnitX(u), GetUnitY(u), 500, function Kill )
  set u = null
*/

library Splash
    globals
        private player PSRC = null
        private unit SRC = null
    endglobals

    private struct filter extends array
        static method E takes nothing returns boolean
            if not IsUnitEnemy( GetFilterUnit(), PSRC ) then
                return false
            endif
            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then
                return false
            endif
            return true
        endmethod
        static method O takes nothing returns boolean
            if GetOwningPlayer(GetFilterUnit()) != PSRC then
                return false
            endif
            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then
                return false
            endif
            return true
        endmethod
        static method A takes nothing returns boolean
            if not IsUnitAlly( GetFilterUnit(), PSRC ) then
                return false
            endif
            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then
                return false
            endif
            return true
        endmethod
        static method W takes nothing returns boolean
            return not IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD )
        endmethod
        static method ANOT takes nothing returns boolean
            if not IsUnitAlly( GetFilterUnit(), PSRC ) then
                return false
            endif
            if GetFilterUnit() == SRC then
                return false
            endif
            if IsUnitType( GetFilterUnit(), UNIT_TYPE_DEAD ) then
                return false
            endif
            return true
        endmethod
    endstruct

    struct splash extends array
        static boolexpr ENEMY = null
        static boolexpr PLAYER = null
        static boolexpr ALLY = null
        static boolexpr ANY = null
        static boolexpr ALLYNOTME = null
        private static trigger PTRG = null
        private static method onInit takes nothing returns nothing
            set ENEMY = Filter( function filter.E )
            set PLAYER = Filter( function filter.O )
            set ALLY = Filter( function filter.A )
            set ANY = Filter( function filter.W )
            set ALLYNOTME = Filter( function filter.ANOT )
        endmethod
        static method range takes boolexpr f, unit src, real x, real y, real rng, code c returns nothing
            local group ul = CreateGroup()
            local player ppsrc = PSRC
            local unit psrc = SRC
            set SRC = src
            set PSRC = GetOwningPlayer( src )
            call GroupEnumUnitsInRange( ul, x, y, rng, f )
            call ForGroup( ul, c )
            call DestroyGroup( ul )
            set ul = null
            set SRC = psrc
            set PSRC = ppsrc
            set psrc = null
            set ppsrc = null
        endmethod
        static method zone takes boolexpr f, unit src, real x, real y, real w, real h, code c returns nothing
            local group ul = CreateGroup()
            //unitList.create()
            local player ppsrc = PSRC
            local rect r = Rect( x-w/2,y-h/2,x+w/2,y+h/2)
            set PSRC = GetOwningPlayer( src )
            call GroupEnumUnitsInRect( ul, r, f )
            call ForGroup( ul, c )
            call DestroyGroup( ul )
            call RemoveRect( r )
            set r = null
            set ul = null
            set PSRC = ppsrc
            set ppsrc = null
        endmethod
        static method rect takes boolexpr f, unit src, rect r, code c returns nothing
            local group ul = CreateGroup()
            //unitList.create()
            local player ppsrc = PSRC
            set PSRC = GetOwningPlayer( src )
            call GroupEnumUnitsInRect( ul, r, f )
            call ForGroup( ul, c )
            call DestroyGroup( ul )
            set ul = null
            set PSRC = ppsrc
            set ppsrc = null
        endmethod
    endstruct
    
endlibrary

