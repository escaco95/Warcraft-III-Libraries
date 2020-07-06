/********************************************************************************/
/*
    Struct2Splash by 동동주(escaco)
        Version 0.43
        
    1. 방사 효과 사용하기
    
        call 방사효과.Splash( X, Y, 반지름, argument )
            *** 'X', 'Y' 좌표를 중심으로 한 '반지름' 내 모든 유닛에게 방사 효과를 적용합니다.
            *** argument : 추가 정수. 구조체를 전달하는 방식으로 응용 가능합니다
        
        
    2. 나만의 방사 효과 만들기
    
        struct 방사효과 extends array
        
            ** 방사 효과 대상 필터링
            private static method OnFilter takes unit u, integer argument returns boolean
        
            ** 방사 효과 적용
            private static method OnEnum takes unit u, integer argument returns nothing
            
            //! runtextmacro Struct2Splash()
            
        endstruct
*/
/********************************************************************************/
native UnitAlive takes unit id returns boolean
/********************************************************************************/
library Struct2Splash
    private keyword INITS
    
    globals
        integer S2SP_ENV = 0
        group array S2SP_GROUP
        boolexpr S2SP_B
    
        integer S2SP_COUNT = 0
    endglobals
    struct Struct2Splash extends array
        implement INITS
        static method operator Count takes nothing returns integer
            return S2SP_COUNT
        endmethod
    endstruct
    
    private module INITS
        private static method SafeFilter takes nothing returns boolean
            return true
        endmethod
        private static method onInit takes nothing returns nothing
            set S2SP_B = Filter(function thistype.SafeFilter)
        endmethod
    endmodule
endlibrary
/********************************************************************************/
//! textmacro Struct2Splash
private static trigger IN_SPLASH = CreateTrigger()
private static real IN_X = 0.0
private static real IN_Y = 0.0
private static rect IN_R = null
private static real IN_DIST = 0.0
private static integer IN_ARG = 0
private static method OnSplash takes nothing returns boolean
    local thistype this = IN_ARG
    local real x = IN_X
    local real y = IN_Y
    local real dist = IN_DIST
    local rect r = IN_R
    local group g = S2SP_GROUP[S2SP_ENV]
    local unit u
    if g == null then
        set g = CreateGroup()
        set S2SP_GROUP[S2SP_ENV] = g
        set S2SP_ENV = S2SP_ENV + 1
    endif
    if r != null then
        call GroupEnumUnitsInRect(g,r,S2SP_B)
        set r = null
    else
        call GroupEnumUnitsInRange(g,x,y,dist,S2SP_B)
    endif
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g,u)
        static if thistype.OnFilter.exists then
            if .OnFilter(u) then
                call .OnEnum(u)
            endif
        else
            call .OnEnum(u)
        endif
    endloop
    set S2SP_ENV = S2SP_ENV - 1
    set g = null
    return false
endmethod
static method Create takes nothing returns thistype
    set S2SP_COUNT = S2SP_COUNT + 1
    return .allocate()
endmethod
method Destroy takes nothing returns nothing
    static if thistype.OnDestroy.exists then
        call .OnDestroy()
    endif
    call .deallocate()
    set S2SP_COUNT = S2SP_COUNT - 1
endmethod
static method create takes nothing returns thistype
    call BJDebugMsg("<Splash>: " + create.name + " 사용 금지!")
    return 0
endmethod
method destroy takes nothing returns nothing
    call BJDebugMsg("<Splash>: " + destroy.name + " 사용 금지!")
endmethod
method Splash takes real x, real y, real dist returns nothing
    set IN_X = x
    set IN_Y = y
    set IN_DIST = dist
    set IN_ARG = this
    set IN_R = null
    call TriggerEvaluate(IN_SPLASH)
endmethod
method SplashRect takes rect r returns nothing
    set IN_X = 0.0
    set IN_Y = 0.0
    set IN_DIST = 0.0
    set IN_ARG = this
    set IN_R = r
    call TriggerEvaluate(IN_SPLASH)
endmethod
private static method onInit takes nothing returns nothing
    call TriggerAddCondition(IN_SPLASH,Condition(function thistype.OnSplash))
endmethod
//! endtextmacro
/********************************************************************************/
