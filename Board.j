library Board
    globals
        private board THIS = 0
        private integer X = 0
        private integer Y = 0
        private multiboard array B
    endglobals
    struct boardItem extends array
        method get takes nothing returns multiboarditem
            return MultiboardGetItem(B[THIS],Y,X)
        endmethod
        method operator value= takes string s returns nothing
            local multiboarditem mbi = MultiboardGetItem(B[THIS],Y,X)
            call MultiboardSetItemValue( mbi, s )
            call MultiboardReleaseItem( mbi )
            set mbi = null
        endmethod
        method operator icon= takes string s returns nothing
            local multiboarditem mbi = MultiboardGetItem(B[THIS],Y,X)
            call MultiboardSetItemIcon( mbi, s )
            call MultiboardReleaseItem( mbi )
            set mbi = null
        endmethod
        method operator scale= takes real r returns nothing
            local multiboarditem mbi = MultiboardGetItem(B[THIS],Y,X)
            call MultiboardSetItemWidth( mbi, r )
            call MultiboardReleaseItem( mbi )
            set mbi = null
        endmethod
        method setStyle takes boolean f1, boolean f2 returns nothing
            local multiboarditem mbi = MultiboardGetItem(B[THIS],Y,X)
            call MultiboardSetItemStyle( mbi, f1, f2 )
            call MultiboardReleaseItem( mbi )
            set mbi = null
        endmethod
    endstruct
    struct boardY extends array
        method operator [] takes integer i returns boardItem
            set Y = i
            return 0
        endmethod
    endstruct
    struct board
        static method supress takes boolean f returns nothing
            call MultiboardSuppressDisplay( f )
        endmethod
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set B[this] = CreateMultiboard()
            return this
        endmethod
        method operator [] takes integer i returns boardY
            set THIS = this
            set X = i
            return 0
        endmethod
        method operator width= takes integer i returns nothing
            call MultiboardSetColumnCount( B[this], i )
        endmethod
        method operator width takes nothing returns integer
            return MultiboardGetColumnCount( B[this] )
        endmethod
        method operator height= takes integer i returns nothing
            call MultiboardSetRowCount( B[this], i )
        endmethod
        method operator height takes nothing returns integer
            return MultiboardGetRowCount( B[this] )
        endmethod
        method operator title= takes string s returns nothing
            call MultiboardSetTitleText( B[this], s )
        endmethod
        method operator title takes nothing returns string
            return MultiboardGetTitleText( B[this] )
        endmethod
        method operator visible= takes boolean f returns nothing
            call MultiboardDisplay( B[this], f )
        endmethod
        method operator visible takes nothing returns boolean
            return IsMultiboardDisplayed( B[this] )
        endmethod
        method operator value= takes string s returns nothing
            call MultiboardSetItemsValue( B[THIS], s )
        endmethod
        method operator icon= takes string s returns nothing
            call MultiboardSetItemsIcon( B[THIS], s )
        endmethod
        method operator scale= takes real r returns nothing
            call MultiboardSetItemsWidth( B[THIS], r )
        endmethod
        method clear takes nothing returns nothing
            call MultiboardClear( B[this] )
        endmethod
        method minimize takes boolean f returns nothing
            call MultiboardMinimize( B[this], f )
        endmethod
        method minimized takes nothing returns boolean
            return IsMultiboardMinimized( B[this] )
        endmethod
        method setStyle takes boolean f1, boolean f2 returns nothing
            call MultiboardSetItemsStyle( B[this], f1, f2 )
        endmethod
        method destroy takes nothing returns nothing
            call DestroyMultiboard( B[this] )
            set B[this] = null
            call thistype.deallocate( this )
        endmethod
    endstruct
endlibrary

