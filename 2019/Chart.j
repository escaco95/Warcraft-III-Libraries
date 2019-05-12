// Copyright (c) 2019 escaco95
// Distributed under the BSD License, Version 1.0.
// See original source at GitHub https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/Chart.j
// TESH custom intellisense https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/2019/Chart.Intellisense.txt
library Chart
    globals
        private multiboard array IN_B
    endglobals
    // 차트 아이템입니다
    struct chartitem extends array
        method operator x takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method operator columns takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method getColumns takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method operator column takes nothing returns chartcolumn
            return this/10000*10000 + ModuloInteger(this/100,100)
        endmethod
        method getColumn takes nothing returns chartcolumn
            return this/10000*10000 + ModuloInteger(this/100,100)
        endmethod
        method operator y takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method operator rows takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method getRows takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method operator row takes nothing returns chartrow
            return this/10000*10000 + ModuloInteger(this,100)
        endmethod
        method getRow takes nothing returns chartrow
            return this/10000*10000 + ModuloInteger(this,100)
        endmethod
        method operator chart takes nothing returns chart
            return this/10000
        endmethod
        method getChart takes nothing returns chart
            return this/10000
        endmethod
        method operator icon= takes string iconFileName returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setIcon takes string iconFileName returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method operator value= takes string value returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setValue takes string value returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method operator width= takes real itemWidth returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemWidth(t,itemWidth)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setWidth takes real itemWidth returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemWidth(t,itemWidth)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setStyle takes boolean showIcon, boolean showValue returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemStyle(t,showValue,showIcon)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setColor takes integer red, integer green, integer blue returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method clear takes nothing returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this/10000],ModuloInteger(this,100),ModuloInteger(this/100,100))
            call MultiboardSetItemIcon(t,"")
            call MultiboardSetItemValue(t,"")
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
    endstruct
    // 단일 차트 열입니다
    struct chartcolumn extends array
        // ====[    GetChartItem    ]====
        method operator x takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method operator columns takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method getColumns takes nothing returns integer
            return ModuloInteger(this/100,100)
        endmethod
        method operator chart takes nothing returns chart
            return this/10000
        endmethod
        method getChart takes nothing returns chart
            return this/10000
        endmethod
        method operator [] takes integer y returns chartitem
            return this + y
        endmethod
        method operator icons= takes string iconFileName returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,iconFileName)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setIcons takes string iconFileName returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,iconFileName)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method operator values= takes string value returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValue(t,value)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setValues takes string value returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValue(t,value)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method operator widths= takes real itemWidth returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemWidth(t,itemWidth)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setWidths takes real itemWidth returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemWidth(t,itemWidth)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setStyles takes boolean showIcons, boolean showValues returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemStyle(t,showValues,showIcons)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setColors takes integer red, integer green, integer blue returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValueColor(t,red,green,blue,255)
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
        method clear takes nothing returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = ModuloInteger(this/100,100)
            local integer y = MultiboardGetRowCount(b) - 1
            local multiboarditem t
            loop
                exitwhen y < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,"")
                call MultiboardSetItemValue(t,"")
                call MultiboardReleaseItem(t)
                set y = y - 1
            endloop
            set t = null
            set b = null
        endmethod
    endstruct
    struct chartrow extends array
        // ====[    GetChartItem    ]====
        method operator y takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method operator rows takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method getRows takes nothing returns integer
            return ModuloInteger(this,100)
        endmethod
        method operator chart takes nothing returns chart
            return this/10000
        endmethod
        method getChart takes nothing returns chart
            return this/10000
        endmethod
        method operator [] takes integer x returns chartitem
            return this + x * 100
        endmethod
        method operator icons= takes string iconFileName returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,iconFileName)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setIcons takes string iconFileName returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,iconFileName)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method operator values= takes string value returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValue(t,value)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setValues takes string value returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValue(t,value)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method operator widths= takes real itemWidth returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemWidth(t,itemWidth)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setWidths takes real itemWidth returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemWidth(t,itemWidth)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setStyles takes boolean showIcons, boolean showValues returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemStyle(t,showValues,showIcons)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method setColors takes integer red, integer green, integer blue returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemValueColor(t,red,green,blue,255)
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
        method clear takes nothing returns nothing
            local multiboard b = IN_B[this/10000]
            local integer x = MultiboardGetColumnCount(b) - 1
            local integer y = ModuloInteger(this,100)
            local multiboarditem t
            loop
                exitwhen x < 0
                set t = MultiboardGetItem(b,y,x)
                call MultiboardSetItemIcon(t,"")
                call MultiboardSetItemValue(t,"")
                call MultiboardReleaseItem(t)
                set x = x - 1
            endloop
            set t = null
            set b = null
        endmethod
    endstruct
    // X,Y 단위로 제어 가능한 차트입니다
    struct chart
        // ====[    STATICS    ]====
        static method operator suppressed= takes boolean flag returns nothing
            call MultiboardSuppressDisplay(flag)
        endmethod
        static method suppress takes boolean flag returns nothing
            call MultiboardSuppressDisplay(flag)
        endmethod
        static method suppressDisplay takes boolean flag returns nothing
            call MultiboardSuppressDisplay(flag)
        endmethod
        // ====[    CONSTRUCTOR/DESTRUCTOR    ]====
        // 새로운 인스턴스를 생성합니다
        static method create takes nothing returns thistype
            local thistype this = allocate()
            set IN_B[this] = CreateMultiboard()
            //call SaveInteger(IN_H,0,GetHandleId(IN_B[this]),this)
            return this
        endmethod
        // 더 이상 사용하지 않을 인스턴스를 파괴합니다
        method destroy takes nothing returns nothing
            call DestroyMultiboard(IN_B[this])
            //call RemoveSavedInteger(IN_H,0,GetHandleId(IN_B[this]))
            set IN_B[this] = null
            call deallocate()
        endmethod
        // ====[    VISIBILITY    ]====
        // 인스턴스의 보임/숨김 여부를 결정합니다
        method operator visible= takes boolean flag returns nothing
            call MultiboardDisplay(IN_B[this],flag)
        endmethod
        method operator visible takes nothing returns boolean
            return IsMultiboardDisplayed(IN_B[this])
        endmethod
        // 인스턴스의 보임/숨김 여부를 결정합니다 (모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method display takes boolean flag returns nothing
            call MultiboardDisplay(IN_B[this],flag)
        endmethod
        method displayForPlayer takes player whichPlayer, boolean flag returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardDisplay(IN_B[this],flag)
            endif
        endmethod
        method displayForForce takes force whichForce, boolean flag returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardDisplay(IN_B[this],flag)
            endif
        endmethod
        // 인스턴스를 화면에 노출시킵니다 (모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method show takes nothing returns nothing
            call MultiboardDisplay(IN_B[this],true)
        endmethod
        method showForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardDisplay(IN_B[this],true)
            endif
        endmethod
        method showForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardDisplay(IN_B[this],true)
            endif
        endmethod
        // 인스턴스를 화면에서 숨깁니다 (모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method hide takes nothing returns nothing
            call MultiboardDisplay(IN_B[this],false)
        endmethod
        method hideForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardDisplay(IN_B[this],false)
            endif
        endmethod
        method hideForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardDisplay(IN_B[this],false)
            endif
        endmethod
        // ====[    VISIBILITY(EXTRA)    ]====
        method operator maximized= takes boolean flag returns nothing
            call MultiboardMinimize(IN_B[this],not flag)
        endmethod
        method operator maximized takes nothing returns boolean
            return not IsMultiboardMinimized(IN_B[this])
        endmethod
        method maximize takes nothing returns nothing
            call MultiboardMinimize(IN_B[this],false)
        endmethod
        method maximizeForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardMinimize(IN_B[this],false)
            endif
        endmethod
        method maximizeForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardMinimize(IN_B[this],false)
            endif
        endmethod
        method operator minimized= takes boolean flag returns nothing
            call MultiboardMinimize(IN_B[this],flag)
        endmethod
        method operator minimized takes nothing returns boolean
            return IsMultiboardMinimized(IN_B[this])
        endmethod
        method minimize takes nothing returns nothing
            call MultiboardMinimize(IN_B[this],true)
        endmethod
        method minimizeForPlayer takes player whichPlayer returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardMinimize(IN_B[this],true)
            endif
        endmethod
        method minimizeForForce takes force whichForce returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardMinimize(IN_B[this],true)
            endif
        endmethod
        // ====[    ITEM HANDLING    ]====
        method setSize takes integer newWidth, integer newHeight returns nothing
            call MultiboardSetColumnCount(IN_B[this],newWidth)
            call MultiboardSetRowCount(IN_B[this],newHeight)
        endmethod
        method operator width= takes integer newWidth returns nothing
            call MultiboardSetColumnCount(IN_B[this],newWidth)
        endmethod
        method operator width takes nothing returns integer
            return MultiboardGetColumnCount(IN_B[this])
        endmethod
        method operator columns= takes integer newWidth returns nothing
            call MultiboardSetColumnCount(IN_B[this],newWidth)
        endmethod
        method operator columns takes nothing returns integer
            return MultiboardGetColumnCount(IN_B[this])
        endmethod
        method setWidth takes integer newWidth returns nothing
            call MultiboardSetColumnCount(IN_B[this],newWidth)
        endmethod
        method getWidth takes nothing returns integer
            return MultiboardGetColumnCount(IN_B[this])
        endmethod
        method setColumns takes integer newWidth returns nothing
            call MultiboardSetColumnCount(IN_B[this],newWidth)
        endmethod
        method getColumns takes nothing returns integer
            return MultiboardGetColumnCount(IN_B[this])
        endmethod
        method operator height= takes integer newHeight returns nothing
            call MultiboardSetRowCount(IN_B[this],newHeight)
        endmethod
        method operator height takes nothing returns integer
            return MultiboardGetRowCount(IN_B[this])
        endmethod
        method operator rows= takes integer newHeight returns nothing
            call MultiboardSetRowCount(IN_B[this],newHeight)
        endmethod
        method operator rows takes nothing returns integer
            return MultiboardGetRowCount(IN_B[this])
        endmethod
        method setHeight takes integer newHeight returns nothing
            call MultiboardSetRowCount(IN_B[this],newHeight)
        endmethod
        method getHeight takes nothing returns integer
            return MultiboardGetRowCount(IN_B[this])
        endmethod
        method setRows takes integer newHeight returns nothing
            call MultiboardSetRowCount(IN_B[this],newHeight)
        endmethod
        method getRows takes nothing returns integer
            return MultiboardGetRowCount(IN_B[this])
        endmethod
        method operator values= takes string value returns nothing
            call MultiboardSetItemsValue(IN_B[this],value)
        endmethod
        method operator itemsValue= takes string value returns nothing
            call MultiboardSetItemsValue(IN_B[this],value)
        endmethod
        method setItemsValue takes string value returns nothing
            call MultiboardSetItemsValue(IN_B[this],value)
        endmethod
        method setValues takes string value returns nothing
            call MultiboardSetItemsValue(IN_B[this],value)
        endmethod
        method operator icons= takes string iconFileName returns nothing
            call MultiboardSetItemsIcon(IN_B[this],iconFileName)
        endmethod
        method operator itemsIcon= takes string iconFileName returns nothing
            call MultiboardSetItemsIcon(IN_B[this],iconFileName)
        endmethod
        method setItemsIcon takes string iconFileName returns nothing
            call MultiboardSetItemsIcon(IN_B[this],iconFileName)
        endmethod
        method setIcons takes string iconFileName returns nothing
            call MultiboardSetItemsIcon(IN_B[this],iconFileName)
        endmethod
        method operator widths= takes real itemWidth returns nothing
            call MultiboardSetItemsWidth(IN_B[this],itemWidth)
        endmethod
        method operator itemsWidth= takes real itemWidth returns nothing
            call MultiboardSetItemsWidth(IN_B[this],itemWidth)
        endmethod
        method setItemsWidth takes real itemWidth returns nothing
            call MultiboardSetItemsWidth(IN_B[this],itemWidth)
        endmethod
        method setWidths takes real itemWidth returns nothing
            call MultiboardSetItemsWidth(IN_B[this],itemWidth)
        endmethod
        method setItemsStyle takes boolean showIcon, boolean showValue returns nothing
            call MultiboardSetItemsStyle(IN_B[this],showValue,showIcon)
        endmethod
        method setStyles takes boolean showIcon, boolean showValue returns nothing
            call MultiboardSetItemsStyle(IN_B[this],showValue,showIcon)
        endmethod
        method setItemsColor takes integer red, integer green, integer blue returns nothing
            call MultiboardSetItemsValueColor(IN_B[this],red,green,blue,255)
        endmethod
        method setColors takes integer red, integer green, integer blue returns nothing
            call MultiboardSetItemsValueColor(IN_B[this],red,green,blue,255)
        endmethod
        method operator [] takes integer x returns chartcolumn
            return this * 10000 + x * 100
        endmethod
        method getColumn takes integer x returns chartcolumn
            return this * 10000 + x * 100
        endmethod
        method column takes integer x returns chartcolumn
            return this * 10000 + x * 100
        endmethod
        method getRow takes integer y returns chartrow
            return this * 10000 + y
        endmethod
        method row takes integer y returns chartrow
            return this * 10000 + y
        endmethod
        method getItem takes integer x, integer y returns chartitem
            return this * 10000 + x * 100 + y
        endmethod
        method item takes integer x, integer y returns chartitem
            return this * 10000 + x * 100 + y
        endmethod
        method setItemValue takes integer x, integer y, string value returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this],y,x)
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setItemIcon takes integer x, integer y, string iconFileName returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this],y,x)
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setItemWidth takes integer x, integer y, real itemWidth returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this],y,x)
            call MultiboardSetItemWidth(t,itemWidth)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setItemStyle takes integer x, integer y, boolean showIcon, boolean showValue returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this],y,x)
            call MultiboardSetItemStyle(t,showValue,showIcon)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method setItemColor takes integer x, integer y, integer red, integer green, integer blue returns nothing
            local multiboarditem t = MultiboardGetItem(IN_B[this],y,x)
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set t = null
        endmethod
        method clear takes nothing returns nothing
            call MultiboardClear(IN_B[this])
        endmethod
        // ====[    TITLE    ]====
        method operator title= takes string title returns nothing
            call MultiboardSetTitleText(IN_B[this],title)
        endmethod
        method operator title takes nothing returns string
            return MultiboardGetTitleText(IN_B[this])
        endmethod
        // 인스턴스의 제목을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setTitle takes string title returns nothing
            call MultiboardSetTitleText(IN_B[this],title)
        endmethod
        method setTitleForPlayer takes player whichPlayer, string title returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardSetTitleText(IN_B[this],title)
            endif
        endmethod
        method setTitleForForce takes force whichForce, string title returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardSetTitleText(IN_B[this],title)
            endif
        endmethod
        // 객체의 타이머 창 제목 색상을 설정합니다(모든 플레이어/특정 플레이어/특정 플레이어 그룹)
        method setTitleColor takes integer red, integer green, integer blue returns nothing
            call MultiboardSetTitleTextColor(IN_B[this],red,green,blue,255)
        endmethod
        method setTitleColorForPlayer takes player whichPlayer, integer red, integer green, integer blue returns nothing
            if GetLocalPlayer() == whichPlayer then
                call MultiboardSetTitleTextColor(IN_B[this],red,green,blue,255)
            endif
        endmethod
        method setTitleColorForForce takes force whichForce, integer red, integer green, integer blue returns nothing
            if IsPlayerInForce(GetLocalPlayer(),whichForce) then
                call MultiboardSetTitleTextColor(IN_B[this],red,green,blue,255)
            endif
        endmethod
    endstruct
    // ====[    CHART ITEM    ]====
    function ChartItemGetX takes chartitem whichChartItem returns integer
        return ModuloInteger(whichChartItem/100,100)
    endfunction
    function ChartItemGetColumns takes chartitem whichChartItem returns integer
        return ModuloInteger(whichChartItem/100,100)
    endfunction
    function ChartItemGetColumn takes chartitem whichChartItem returns chartcolumn
        return whichChartItem/10000*10000 + ModuloInteger(whichChartItem/100,100)
    endfunction
    function ChartItemGetY takes chartitem whichChartItem returns integer
        return ModuloInteger(whichChartItem,100)
    endfunction
    function ChartItemGetRows takes chartitem whichChartItem returns integer
        return ModuloInteger(whichChartItem,100)
    endfunction
    function ChartItemGetRow takes chartitem whichChartItem returns chartrow
        return whichChartItem/10000*10000 + ModuloInteger(whichChartItem,100)
    endfunction
    function ChartItemGetChart takes chartitem whichChartItem returns chart
        return whichChartItem/10000
    endfunction
    function ChartItemClear takes chartitem whichChartItem returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChartItem/10000],ModuloInteger(whichChartItem,100),ModuloInteger(whichChartItem/100,100))
        call MultiboardSetItemIcon(t,"")
        call MultiboardSetItemValue(t,"")
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartItemSetIcon takes chartitem whichChartItem, string iconFileName returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChartItem/10000],ModuloInteger(whichChartItem,100),ModuloInteger(whichChartItem/100,100))
        call MultiboardSetItemIcon(t,iconFileName)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartItemSetValue takes chartitem whichChartItem, string value returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChartItem/10000],ModuloInteger(whichChartItem,100),ModuloInteger(whichChartItem/100,100))
        call MultiboardSetItemValue(t,value)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartItemSetStyle takes chartitem whichChartItem, boolean showIcon, boolean showValue returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChartItem/10000],ModuloInteger(whichChartItem,100),ModuloInteger(whichChartItem/100,100))
        call MultiboardSetItemStyle(t,showValue,showIcon)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartItemSetColor takes chartitem whichChartItem, integer red, integer green, integer blue returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChartItem/10000],ModuloInteger(whichChartItem,100),ModuloInteger(whichChartItem/100,100))
        call MultiboardSetItemValueColor(t,red,green,blue,255)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    // ====[    CHART COLUMN    ]====
    function ChartColumnGetX takes chartcolumn whichChartColumn returns integer
        return ModuloInteger(whichChartColumn/100,100)
    endfunction
    function ChartColumnGetColumns takes chartcolumn whichChartColumn returns integer
        return ModuloInteger(whichChartColumn/100,100)
    endfunction
    function ChartColumnGetChart takes chartcolumn whichChartColumn returns chart
        return whichChartColumn/10000
    endfunction
    function ChartColumnGetItem takes chartcolumn whichChartColumn, integer y returns chartitem
        return whichChartColumn + y
    endfunction
    function ChartColumnSetItemsIcon takes chartcolumn whichChartColumn, string iconFileName returns nothing
        local multiboard b = IN_B[whichChartColumn/10000]
        local integer x = ModuloInteger(whichChartColumn/100,100)
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartColumnSetItemsValue takes chartcolumn whichChartColumn, string value returns nothing
        local multiboard b = IN_B[whichChartColumn/10000]
        local integer x = ModuloInteger(whichChartColumn/100,100)
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartColumnSetItemsWidth takes chartcolumn whichChartColumn, real width returns nothing
        local multiboard b = IN_B[whichChartColumn/10000]
        local integer x = ModuloInteger(whichChartColumn/100,100)
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemWidth(t,width)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartColumnSetItemsStyle takes chartcolumn whichChartColumn, boolean showIcons, boolean showValues returns nothing
        local multiboard b = IN_B[whichChartColumn/10000]
        local integer x = ModuloInteger(whichChartColumn/100,100)
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemStyle(t,showValues,showIcons)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartColumnSetItemsColor takes chartcolumn whichChartColumn, integer red, integer green, integer blue returns nothing
        local multiboard b = IN_B[whichChartColumn/10000]
        local integer x = ModuloInteger(whichChartColumn/100,100)
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    // ====[    CHART ROW    ]====
    function ChartRowGetY takes chartrow whichChartRow returns integer
        return ModuloInteger(whichChartRow/100,100)
    endfunction
    function ChartRowGetRows takes chartrow whichChartRow returns integer
        return ModuloInteger(whichChartRow/100,100)
    endfunction
    function ChartRowGetChart takes chartrow whichChartRow returns chart
        return whichChartRow/10000
    endfunction
    function ChartRowGetItem takes chartrow whichChartRow, integer x returns chartitem
        return whichChartRow + x * 100
    endfunction
    function ChartRowSetItemsIcon takes chartrow whichChartRow, string iconFileName returns nothing
        local multiboard b = IN_B[whichChartRow/10000]
        local integer x = MultiboardGetColumnCount(b) - 1
        local integer y = ModuloInteger(whichChartRow,100)
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartRowSetItemsValue takes chartrow whichChartRow, string value returns nothing
        local multiboard b = IN_B[whichChartRow/10000]
        local integer x = MultiboardGetColumnCount(b) - 1
        local integer y = ModuloInteger(whichChartRow,100)
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartRowSetItemsWidth takes chartrow whichChartRow, real width returns nothing
        local multiboard b = IN_B[whichChartRow/10000]
        local integer x = MultiboardGetColumnCount(b) - 1
        local integer y = ModuloInteger(whichChartRow,100)
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemWidth(t,width)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartRowSetItemsStyle takes chartrow whichChartRow, boolean showIcons, boolean showValues returns nothing
        local multiboard b = IN_B[whichChartRow/10000]
        local integer x = MultiboardGetColumnCount(b) - 1
        local integer y = ModuloInteger(whichChartRow,100)
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemStyle(t,showValues,showIcons)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartRowSetItemsColor takes chartrow whichChartRow, integer red, integer green, integer blue returns nothing
        local multiboard b = IN_B[whichChartRow/10000]
        local integer x = MultiboardGetColumnCount(b) - 1
        local integer y = ModuloInteger(whichChartRow,100)
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    // ====[    CHART    ]====
    function CreateChart takes nothing returns chart
        return chart.create()
    endfunction
    function DestroyChart takes chart whichChart returns nothing
        call whichChart.destroy()
    endfunction
    function ChartSetSize takes chart whichChart, integer newWidth, integer newHeight returns nothing
        call MultiboardSetColumnCount(IN_B[whichChart],newWidth)
        call MultiboardSetRowCount(IN_B[whichChart],newHeight)
    endfunction
    function ChartGetWidth takes chart whichChart returns integer
        return MultiboardGetColumnCount(IN_B[whichChart])
    endfunction
    function ChartGetColumns takes chart whichChart returns integer
        return MultiboardGetColumnCount(IN_B[whichChart])
    endfunction
    function ChartSetWidth takes chart whichChart, integer newWidth returns nothing
        call MultiboardSetColumnCount(IN_B[whichChart],newWidth)
    endfunction
    function ChartSetColumns takes chart whichChart, integer newWidth returns nothing
        call MultiboardSetColumnCount(IN_B[whichChart],newWidth)
    endfunction
    function ChartGetHeight takes chart whichChart returns integer
        return MultiboardGetColumnCount(IN_B[whichChart])
    endfunction
    function ChartGetRows takes chart whichChart returns integer
        return MultiboardGetColumnCount(IN_B[whichChart])
    endfunction
    function ChartSetHeight takes chart whichChart, integer newHeight returns nothing
        call MultiboardSetRowCount(IN_B[whichChart],newHeight)
    endfunction
    function ChartSetRows takes chart whichChart, integer newHeight returns nothing
        call MultiboardSetRowCount(IN_B[whichChart],newHeight)
    endfunction
    function ChartGetColumn takes chart whichChart, integer x returns chartcolumn
        return whichChart * 10000 + x * 100
    endfunction
    function ChartGetRow takes chart whichChart, integer y returns chartrow
        return whichChart * 10000 + y
    endfunction
    function ChartGetItem takes chart whichChart, integer x, integer y returns chartitem
        return whichChart * 10000 + x * 100 + y
    endfunction
    function ChartSetItemsIcon takes chart whichChart, string iconPath returns nothing
        call MultiboardSetItemsIcon(IN_B[whichChart],iconPath)
    endfunction
    function ChartSetItemsValue takes chart whichChart, string value returns nothing
        call MultiboardSetItemsValue(IN_B[whichChart],value)
    endfunction
    function ChartSetItemsWidth takes chart whichChart, real width returns nothing
        call MultiboardSetItemsWidth(IN_B[whichChart],width)
    endfunction
    function ChartSetItemsStyle takes chart whichChart, boolean showIcons, boolean showValues returns nothing
        call MultiboardSetItemsStyle(IN_B[whichChart],showValues,showIcons)
    endfunction
    function ChartSetItemsColor takes chart whichChart, integer red, integer green, integer blue returns nothing
        call MultiboardSetItemsValueColor(IN_B[whichChart],red,green,blue,255)
    endfunction
    function ChartSetItemIcon takes chart whichChart, integer x, integer y, string iconFileName returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChart],y,x)
        call MultiboardSetItemIcon(t,iconFileName)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartSetItemValue takes chart whichChart, integer x, integer y, string value returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChart],y,x)
        call MultiboardSetItemValue(t,value)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartSetItemWidth takes chart whichChart, integer x, integer y, real width returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChart],y,x)
        call MultiboardSetItemWidth(t,width)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartSetItemStyle takes chart whichChart, integer x, integer y, boolean showIcon, boolean showValue returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChart],y,x)
        call MultiboardSetItemStyle(t,showValue,showIcon)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartSetItemColor takes chart whichChart, integer x, integer y, integer red, integer green, integer blue returns nothing
        local multiboarditem t = MultiboardGetItem(IN_B[whichChart],y,x)
        call MultiboardSetItemValueColor(t,red,green,blue,255)
        call MultiboardReleaseItem(t)
        set t = null
    endfunction
    function ChartSetColumnIcon takes chart whichChart, integer x, string iconFileName returns nothing
        local multiboard b = IN_B[whichChart]
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetColumnValue takes chart whichChart, integer x, string value returns nothing
        local multiboard b = IN_B[whichChart]
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetColumnWidth takes chart whichChart, integer x, real width returns nothing
        local multiboard b = IN_B[whichChart]
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemWidth(t,width)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetColumnStyle takes chart whichChart, integer x, boolean showIcons, boolean showValues returns nothing
        local multiboard b = IN_B[whichChart]
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemStyle(t,showValues,showIcons)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetColumnColor takes chart whichChart, integer x, integer red, integer green, integer blue returns nothing
        local multiboard b = IN_B[whichChart]
        local integer y = MultiboardGetRowCount(b) - 1
        local multiboarditem t
        loop
            exitwhen y < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set y = y - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetRowIcon takes chart whichChart, integer y, string iconFileName returns nothing
        local multiboard b = IN_B[whichChart]
        local integer x = MultiboardGetColumnCount(b) - 1
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemIcon(t,iconFileName)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetRowValue takes chart whichChart, integer y, string value returns nothing
        local multiboard b = IN_B[whichChart]
        local integer x = MultiboardGetColumnCount(b) - 1
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValue(t,value)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetRowWidth takes chart whichChart, integer y, real width returns nothing
        local multiboard b = IN_B[whichChart]
        local integer x = MultiboardGetColumnCount(b) - 1
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemWidth(t,width)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetRowStyle takes chart whichChart, integer y, boolean showIcons, boolean showValues returns nothing
        local multiboard b = IN_B[whichChart]
        local integer x = MultiboardGetColumnCount(b) - 1
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemStyle(t,showValues,showIcons)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartSetRowColor takes chart whichChart, integer y, integer red, integer green, integer blue returns nothing
        local multiboard b = IN_B[whichChart]
        local integer x = MultiboardGetColumnCount(b) - 1
        local multiboarditem t
        loop
            exitwhen x < 0
            set t = MultiboardGetItem(b,y,x)
            call MultiboardSetItemValueColor(t,red,green,blue,255)
            call MultiboardReleaseItem(t)
            set x = x - 1
        endloop
        set t = null
        set b = null
    endfunction
    function ChartClear takes chart whichChart returns nothing
        call MultiboardClear(IN_B[whichChart])
    endfunction
    function ChartSetTitle takes chart whichChart, string title returns nothing
        call MultiboardSetTitleText(IN_B[whichChart],title)
    endfunction
    function ChartSetTitleForPlayer takes chart whichChart, player whichPlayer, string title returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardSetTitleText(IN_B[whichChart],title)
        endif
    endfunction
    function ChartSetTitleForForce takes chart whichChart, force whichForce, string title returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardSetTitleText(IN_B[whichChart],title)
        endif
    endfunction
    function ChartSetTitleColor takes chart whichChart, integer red, integer green, integer blue returns nothing
        call MultiboardSetTitleTextColor(IN_B[whichChart],red,green,blue,255)
    endfunction
    function ChartSetTitleColorForPlayer takes chart whichChart, player whichPlayer, integer red, integer green, integer blue returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardSetTitleTextColor(IN_B[whichChart],red,green,blue,255)
        endif
    endfunction
    function ChartSetTitleColorForForce takes chart whichChart, force whichForce, integer red, integer green, integer blue returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardSetTitleTextColor(IN_B[whichChart],red,green,blue,255)
        endif
    endfunction
    function ShowChart takes chart whichChart returns nothing
        call MultiboardDisplay(IN_B[whichChart],true)
    endfunction
    function ShowChartForPlayer takes chart whichChart, player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardDisplay(IN_B[whichChart],true)
        endif
    endfunction
    function ShowChartForForce takes chart whichChart, force whichForce returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardDisplay(IN_B[whichChart],true)
        endif
    endfunction
    function HideChart takes chart whichChart returns nothing
        call MultiboardDisplay(IN_B[whichChart],false)
    endfunction
    function HideChartForPlayer takes chart whichChart, player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardDisplay(IN_B[whichChart],false)
        endif
    endfunction
    function HideChartForForce takes chart whichChart, force whichForce returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardDisplay(IN_B[whichChart],false)
        endif
    endfunction
    function ChartDisplay takes chart whichChart, boolean show returns nothing
        call MultiboardDisplay(IN_B[whichChart],show)
    endfunction
    function ChartDisplayForPlayer takes chart whichChart, player whichPlayer, boolean show returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardDisplay(IN_B[whichChart],show)
        endif
    endfunction
    function ChartDisplayForForce takes chart whichChart, force whichForce, boolean show returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardDisplay(IN_B[whichChart],show)
        endif
    endfunction
    function ChartSuppressDisplay takes boolean flag returns nothing
        call MultiboardSuppressDisplay(flag)
    endfunction
    function ChartMaximize takes chart whichChart, boolean maximize returns nothing
        call MultiboardMinimize(IN_B[whichChart],not maximize)
    endfunction
    function ChartMaximizeForPlayer takes chart whichChart, player whichPlayer, boolean maximize returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardMinimize(IN_B[whichChart],not maximize)
        endif
    endfunction
    function ChartMaximizeForForce takes chart whichChart, force whichForce, boolean maximize returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardMinimize(IN_B[whichChart],not maximize)
        endif
    endfunction
    function ChartMinimize takes chart whichChart, boolean minimize returns nothing
        call MultiboardMinimize(IN_B[whichChart],minimize)
    endfunction
    function ChartMinimizeForPlayer takes chart whichChart, player whichPlayer, boolean minimize returns nothing
        if GetLocalPlayer() == whichPlayer then
            call MultiboardMinimize(IN_B[whichChart],minimize)
        endif
    endfunction
    function ChartMinimizeForForce takes chart whichChart, force whichForce, boolean minimize returns nothing
        if IsPlayerInForce(GetLocalPlayer(),whichForce) then
            call MultiboardMinimize(IN_B[whichChart],minimize)
        endif
    endfunction
endlibrary
