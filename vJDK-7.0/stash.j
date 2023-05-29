/* Stash 1.11 */
/* REFERENCE : https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/vJDK-7.0/stash.j */
/*
    RECENT CHANGES
        1.11 - Reference/History comment added (2023/05/30)
        1.1 - Stash clear function added (2023/05/07)
        1.0 - Official release (2023/05/06)
*/
library Stash
    /*========================================================================*/
    /* TEXTMACRO */
    /*========================================================================*/
    //! textmacro VALIDATE_STASH_EXISTENCE takes THIS
        if $THIS$ <= 0 then
            return
        endif
        if $THIS$ > MAX_STASH then
            return
        endif
        if not LoadBoolean( EXIST_TABLE, $THIS$, 0 ) then
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_STASH_EXISTENCE_WARN takes THIS
        if $THIS$ <= 0 then
            call warn( "null 또는 유효하지 않은 개체 인덱스에 접근했습니다!" )
            return
        endif
        if $THIS$ > MAX_STASH then
            call warn( "아직 할당되지 않은 영역의 개체 인덱스에 접근했습니다!" )
            return
        endif
        if not LoadBoolean( EXIST_TABLE, $THIS$, 0 ) then
            call warn( "이미 파괴된 객체에 접근했습니다!" )
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_STASH_INDEX_WARN takes THIS, INDEX
        if not HaveSavedString( PROPT_TABLE, $THIS$, $INDEX$ ) then
            call warn( "유효하지 않은 스태쉬 인덱스에 접근했습니다!" )
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_STASH_PROPERTY_WARN takes PROPERTY
        if $PROPERTY$ == null then
            call warn( "스태쉬에 null 속성을 기록하려 시도했습니다!" )
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_STASH_VALUE_WARN takes VALUE
        if $VALUE$ == null then
            call warn( "스태쉬에 null 값을 기록하려 시도했습니다!" )
            return
        endif
    //! endtextmacro
    /*========================================================================*/
    /* LOGGING */
    /*========================================================================*/
    private function warn takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[경고] Stash - " + message )
    endfunction
    private function error takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[오류] Stash - " + message )
    endfunction
    /*========================================================================*/
    /* INTERNAL LOGICS */
    /*========================================================================*/
    globals
        private integer ALIVE_STASH = 0
        private integer MAX_STASH = 0
        
        private hashtable EXIST_TABLE = InitHashtable( )
        private hashtable SCALE_TABLE = InitHashtable( )
        private hashtable HNAME_TABLE = InitHashtable( )
        private hashtable HINDX_TABLE = InitHashtable( )
        private hashtable PROPT_TABLE = InitHashtable( )
        private hashtable VALUE_TABLE = InitHashtable( )
        private hashtable STAMP_TABLE = InitHashtable( )
        private constant integer SCALE_SIZE = 0
        private constant integer SCALE_REMAINING = 1
        
        private integer ARG_STASH = 0
        private string ARG_PROPERTY = null
        private integer ARG_INDEX = 0
        private string ARG_VALUE = null
        private boolean ARG_FLAG = false
        private integer ARG_SIGNAL = 0
        
        private integer MK_THIS = 0
        private string MK_PROPERTY = null
        private integer MK_INDEX = -1
    endglobals
    
    private function mogi takes integer this, string property returns nothing
        local integer hash = StringHash( property )
        local integer offset = 1
        local integer index
        loop
            if not HaveSavedString( HNAME_TABLE, this, hash ) then
                set index = LoadInteger( SCALE_TABLE, this, SCALE_SIZE )
                call SaveStr( HNAME_TABLE, this, hash, property )
                call SaveInteger( HINDX_TABLE, this, hash, index )
                call SaveStr( PROPT_TABLE, this, index, property )
                call SaveInteger( SCALE_TABLE, this, SCALE_SIZE, index + 1 )
                set MK_INDEX = index
                return
            endif 
            if LoadStr( HNAME_TABLE, this, hash ) == property then
                set MK_INDEX = LoadInteger( HINDX_TABLE, this, hash )
                return
            endif
            set hash = hash + offset
            set offset = offset + 2
        endloop
    endfunction
    private function mogiProxy takes nothing returns nothing
        call mogi( MK_THIS, MK_PROPERTY )
    endfunction
    
    private function gi takes integer this, string property returns nothing
        local integer hash = StringHash( property )
        local integer offset = 1
        loop
            if not HaveSavedString( HNAME_TABLE, this, hash ) then
                return
            endif 
            if LoadStr( HNAME_TABLE, this, hash ) == property then
                set MK_INDEX = LoadInteger( HINDX_TABLE, this, hash )
                return
            endif
            set hash = hash + offset
            set offset = offset + 2
        endloop
    endfunction
    private function giProxy takes nothing returns nothing
        call gi( MK_THIS, MK_PROPERTY )
    endfunction
    
    private function makeOrGetIndex takes integer this, string property returns integer
        set MK_THIS = this
        set MK_PROPERTY = property
        set MK_INDEX = -1
        call ForForce( bj_FORCE_PLAYER[0], function mogiProxy )
        return MK_INDEX
    endfunction
    
    private function getIndex takes integer this, string property returns integer
        set MK_THIS = this
        set MK_PROPERTY = property
        set MK_INDEX = -1
        call ForForce( bj_FORCE_PLAYER[0], function giProxy )
        return MK_INDEX
    endfunction

    private function create takes nothing returns nothing
        local integer this
        set MAX_STASH = MAX_STASH + 1
        set this = MAX_STASH
        
        call SaveInteger( STAMP_TABLE, this, 0, 1 )
        call SaveInteger( SCALE_TABLE, this, SCALE_SIZE, 0 )
        call SaveInteger( SCALE_TABLE, this, SCALE_REMAINING, 0 )
        call SaveBoolean( EXIST_TABLE, this, 0, true )
        
        set ALIVE_STASH = ALIVE_STASH + 1
        set ARG_STASH = this
    endfunction
    private function createProxy takes nothing returns nothing
        call create( )
    endfunction
    
    private function destroy takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        
        set ALIVE_STASH = ALIVE_STASH - 1
        
        call FlushChildHashtable( EXIST_TABLE, this )
        call FlushChildHashtable( SCALE_TABLE, this )
        call FlushChildHashtable( HNAME_TABLE, this )
        call FlushChildHashtable( HINDX_TABLE, this )
        call FlushChildHashtable( PROPT_TABLE, this )
        call FlushChildHashtable( VALUE_TABLE, this )
        call FlushChildHashtable( STAMP_TABLE, this )
        
        set ARG_FLAG = true
    endfunction
    private function destroyProxy takes nothing returns nothing
        call destroy( ARG_STASH )
    endfunction
    
    private function clear takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        
        call SaveInteger( SCALE_TABLE, this, SCALE_SIZE, 0 )
        call SaveInteger( SCALE_TABLE, this, SCALE_REMAINING, 0 )
        call FlushChildHashtable( HNAME_TABLE, this )
        call FlushChildHashtable( HINDX_TABLE, this )
        call FlushChildHashtable( PROPT_TABLE, this )
        call FlushChildHashtable( VALUE_TABLE, this )
        call SaveInteger( STAMP_TABLE, this, 0, LoadInteger(STAMP_TABLE, this, 0) + 1 )
        
        set ARG_FLAG = true
    endfunction
    private function clearProxy takes nothing returns nothing
        call clear( ARG_STASH )
    endfunction
    
    private function exists takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE( "this" )
        
        set ARG_FLAG = true
    endfunction
    private function existsProxy takes nothing returns nothing
        call exists( ARG_STASH )
    endfunction
    
    private function getSize takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE( "this" )
        
        set ARG_SIGNAL = LoadInteger( SCALE_TABLE, this, SCALE_SIZE )
    endfunction
    private function sizeProxy takes nothing returns nothing
        call getSize( ARG_STASH )
    endfunction
    
    private function getRemaining takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE( "this" )
        
        set ARG_SIGNAL = LoadInteger( SCALE_TABLE, this, SCALE_REMAINING )
    endfunction
    private function remainingProxy takes nothing returns nothing
        call getRemaining( ARG_STASH )
    endfunction
    
    private function keyAt takes integer this, integer index returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_INDEX_WARN( "this", "index" )
        
        set ARG_PROPERTY = LoadStr( PROPT_TABLE, this, index )
    endfunction
    private function keyAtProxy takes nothing returns nothing
        call keyAt( ARG_STASH, ARG_INDEX )
    endfunction
    
    private function valueAt takes integer this, integer index returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_INDEX_WARN( "this", "index" )
        
        if not HaveSavedString( VALUE_TABLE, this, index ) then
            return
        endif
        set ARG_VALUE = LoadStr( VALUE_TABLE, this, index )
    endfunction
    private function valueAtProxy takes nothing returns nothing
        call valueAt( ARG_STASH, ARG_INDEX )
    endfunction
    
    private function save takes integer this, string property, string value returns nothing
        local integer propertyIndex
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_PROPERTY_WARN( "property" )
        //! runtextmacro VALIDATE_STASH_VALUE_WARN( "value" )
        
        set propertyIndex = makeOrGetIndex( this, property )
        if not HaveSavedString( VALUE_TABLE, this, propertyIndex ) then
            call SaveInteger( SCALE_TABLE, this, SCALE_REMAINING, LoadInteger(SCALE_TABLE, this, SCALE_REMAINING) + 1 )
        endif
        call SaveStr( VALUE_TABLE, this, propertyIndex, value )
        call SaveInteger( STAMP_TABLE, this, 0, LoadInteger(STAMP_TABLE, this, 0) + 1 )
        set ARG_FLAG = true
    endfunction
    private function saveProxy takes nothing returns nothing
        call save( ARG_STASH, ARG_PROPERTY, ARG_VALUE )
    endfunction
    
    private function load takes integer this, string property returns nothing
        local integer propertyIndex
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_PROPERTY_WARN( "property" )
        
        set propertyIndex = getIndex( this, property )
        if propertyIndex < 0 then
            return
        endif
        if not HaveSavedString( VALUE_TABLE, this, propertyIndex ) then
            return
        endif
        set ARG_VALUE = LoadStr( VALUE_TABLE, this, propertyIndex )
    endfunction
    private function loadProxy takes nothing returns nothing
        call load( ARG_STASH, ARG_PROPERTY )
    endfunction
    
    private function contains takes integer this, string property returns nothing
        local integer propertyIndex
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_PROPERTY_WARN( "property" )
        
        set propertyIndex = getIndex( this, property )
        if propertyIndex < 0 then
            return
        endif
        if not HaveSavedString( VALUE_TABLE, this, propertyIndex ) then
            return
        endif
        
        set ARG_FLAG = true
    endfunction
    private function containsProxy takes nothing returns nothing
        call contains( ARG_STASH, ARG_PROPERTY )
    endfunction
    
    private function remove takes integer this, string property returns nothing
        local integer propertyIndex
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        //! runtextmacro VALIDATE_STASH_PROPERTY_WARN( "property" )
        
        set propertyIndex = getIndex( this, property )
        if propertyIndex < 0 then
            return
        endif
        if not HaveSavedString( VALUE_TABLE, this, propertyIndex ) then
            return
        endif
        call RemoveSavedString( VALUE_TABLE, this, propertyIndex )
        call SaveInteger( SCALE_TABLE, this, SCALE_REMAINING, LoadInteger(SCALE_TABLE, this, SCALE_REMAINING) - 1 )
        call SaveInteger( STAMP_TABLE, this, 0, LoadInteger(STAMP_TABLE, this, 0) + 1 )
        set ARG_FLAG = true
    endfunction
    private function removeProxy takes nothing returns nothing
        call remove( ARG_STASH, ARG_PROPERTY )
    endfunction
    
    globals
        private constant integer COPY_PAGE = 2000
        private integer COPY_THIS = 0
        private integer COPY_SOURCE = 0
        private integer COPY_SORUCE_SIZE = 0
        private integer COPY_SORUCE_INDEX = 0
        private integer COPY_INDEX = 0
    endglobals
    private function copyPage takes nothing returns nothing
        local integer this = COPY_THIS
        local integer source = COPY_SOURCE
        local integer sourceSize = IMinBJ( COPY_SORUCE_INDEX + COPY_PAGE, COPY_SORUCE_SIZE )
        local integer sourceIndex = COPY_SORUCE_INDEX
        local integer index = COPY_INDEX
        local integer propertyIndex
        loop
            exitwhen sourceIndex == sourceSize
            if HaveSavedString( VALUE_TABLE, source, sourceIndex ) then
                set propertyIndex = makeOrGetIndex( this, LoadStr( PROPT_TABLE, source, sourceIndex ) )
                call SaveStr( VALUE_TABLE, this, index, LoadStr( VALUE_TABLE, source, sourceIndex ) )
                set index = index + 1
            endif
            set sourceIndex = sourceIndex + 1
        endloop
        set COPY_INDEX = index
        set COPY_SORUCE_INDEX = sourceSize
    endfunction
    private function copy takes integer source returns nothing
        local integer this
        local integer sourceRemaining
        local integer sourceSize
        local integer sourceIndex
        local integer index
        local integer propertyIndex
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "source" )
        set MAX_STASH = MAX_STASH + 1
        set this = MAX_STASH
        
        call SaveInteger( STAMP_TABLE, this, 0, 1 )
        call SaveInteger( SCALE_TABLE, this, SCALE_SIZE, 0 )
        call SaveInteger( SCALE_TABLE, this, SCALE_REMAINING, LoadInteger(SCALE_TABLE,source,SCALE_REMAINING) )
        call SaveBoolean( EXIST_TABLE, this, 0, true )
        
        set COPY_THIS = this
        set COPY_SOURCE = source
        set COPY_SORUCE_SIZE = LoadInteger( SCALE_TABLE, source, SCALE_SIZE )
        set COPY_SORUCE_INDEX = 0
        set COPY_INDEX = 0
        loop
            exitwhen COPY_SORUCE_INDEX >= COPY_SORUCE_SIZE
            call ForForce( bj_FORCE_PLAYER[0], function copyPage )
        endloop
        
        set ALIVE_STASH = ALIVE_STASH + 1
        
        set ARG_STASH = this
    endfunction
    private function copyProxy takes nothing returns nothing
        call copy( ARG_INDEX )
    endfunction
    
    globals
        private constant integer PRINT_PAGE = 2000
        private integer PRINT_STASH = 0
        private integer PRINT_INDEX = 0
        private integer PRINT_MAX = 0
    endglobals
    private function printPage takes nothing returns nothing
        local integer this = PRINT_STASH
        local integer i = PRINT_INDEX
        local integer imax = IMinBJ( i + PRINT_PAGE, PRINT_MAX )
        local string property
        loop
            exitwhen i == imax
            set property = LoadStr( PROPT_TABLE, this, i )
            if HaveSavedString( VALUE_TABLE, this, i ) then
                call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, " -" + property + "=" + LoadStr(VALUE_TABLE, this, i) )
            else
                call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, " -" + property + "(삭제됨)" )
            endif
            set i = i + 1
        endloop
        set PRINT_INDEX = imax
    endfunction
    private function print takes integer this returns nothing
        local integer size
        local integer remaining
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
        
        set size = LoadInteger( SCALE_TABLE, this, SCALE_SIZE )
        set remaining = LoadInteger( SCALE_TABLE, this, SCALE_REMAINING )
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[정보] Stash - 출력 ("+I2S(remaining)+"/"+I2S(size)+")" )
        set PRINT_STASH = this
        set PRINT_INDEX = 0
        set PRINT_MAX = size
        loop
            exitwhen PRINT_INDEX >= PRINT_MAX
            call ForForce( bj_FORCE_PLAYER[0], function printPage )
        endloop
    endfunction
    private function printProxy takes nothing returns nothing
        call print( ARG_STASH )
    endfunction
    
    private function age takes integer this returns nothing
        //! runtextmacro VALIDATE_STASH_EXISTENCE_WARN( "this" )
    
        set ARG_INDEX = LoadInteger( STAMP_TABLE, this, 0 )
    endfunction
    private function ageProxy takes nothing returns nothing
        call age( ARG_STASH )
    endfunction
    /*========================================================================*/
    /* EXTERNAL INTERFACES */
    /*========================================================================*/
    struct stash extends array
    endstruct
    
    /* 모니터링용 - 누적 스태쉬 사용량 반환 (파괴됨 + 사용중) */
    function MaxStashCount takes nothing returns integer
        return MAX_STASH
    endfunction
    
    /* 모니터링용 - 사용중인 스태쉬 개수 반환 */
    function AliveStashCount takes nothing returns integer
        return ALIVE_STASH
    endfunction
    
    /* 새 스태쉬 만들기 */
    function CreateStash takes nothing returns stash
        set ARG_STASH = 0
        call ForForce( bj_FORCE_PLAYER[0], function createProxy )
        return ARG_STASH
    endfunction
    
    /* 더 이상 사용하지 않는 스태쉬 파괴하기 */
    function DestroyStash takes stash whichStash returns boolean
        set ARG_STASH = whichStash
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function destroyProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬 내용 깔끔하게 비우기 (Age 는 초기화되지 않음) */
    function StashClear takes stash whichStash returns boolean
        set ARG_STASH = whichStash
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function clearProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬의 존재 여부 확인 */
    function StashExists takes stash whichStash returns boolean
        set ARG_STASH = whichStash
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function existsProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬에 값 저장하기 (저장 성공 여부 반환) */
    function StashSave takes stash whichStash, string property, string value returns boolean
        set ARG_STASH = whichStash
        set ARG_PROPERTY = property
        set ARG_VALUE = value
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function saveProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬에 저장된 값 불러오기 (없으면 기본값 반환) */
    function StashLoad takes stash whichStash, string property, string defaultValue returns string
        set ARG_STASH = whichStash
        set ARG_PROPERTY = property
        set ARG_VALUE = defaultValue
        call ForForce( bj_FORCE_PLAYER[0], function loadProxy )
        return ARG_VALUE
    endfunction
    
    /* 스태쉬가 특정 이름에 값을 보관하고 있는지 체크 */
    function StashContains takes stash whichStash, string property returns boolean
        set ARG_STASH = whichStash
        set ARG_PROPERTY = property
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function containsProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬에 "이름" 으로 저장한 값 제거 */
    function StashRemove takes stash whichStash, string property returns boolean
        set ARG_STASH = whichStash
        set ARG_PROPERTY = property
        set ARG_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function removeProxy )
        return ARG_FLAG
    endfunction
    
    /* 스태쉬 크기 (삭제된 항목 포함) */
    function StashSize takes stash whichStash returns integer
        set ARG_STASH = whichStash
        set ARG_SIGNAL = 0
        call ForForce( bj_FORCE_PLAYER[0], function sizeProxy )
        return ARG_SIGNAL
    endfunction
    
    /* 삭제되지 않은 스태쉬 항목 수 */
    function StashRemaining takes stash whichStash returns integer
        set ARG_STASH = whichStash
        set ARG_SIGNAL = 0
        call ForForce( bj_FORCE_PLAYER[0], function remainingProxy )
        return ARG_SIGNAL
    endfunction

    /* index 번째 저장된 값 이름 읽어오기 */
    function StashKeyAt takes stash whichStash, integer index returns string
        set ARG_STASH = whichStash
        set ARG_INDEX = index
        set ARG_PROPERTY = null
        call ForForce( bj_FORCE_PLAYER[0], function keyAtProxy )
        return ARG_PROPERTY
    endfunction
    
    /* index 번째 저장된 값 읽어오기 */
    function StashValueAt takes stash whichStash, integer index, string defaultValue returns string
        set ARG_STASH = whichStash
        set ARG_INDEX = index
        set ARG_VALUE = defaultValue
        call ForForce( bj_FORCE_PLAYER[0], function valueAtProxy )
        return ARG_VALUE
    endfunction
    
    /* 스태쉬를 복제합니다 (삭제된 데이터는 복제되지 않습니다) */
    function StashCopy takes stash whichStash returns stash
        set ARG_INDEX = whichStash
        set ARG_STASH = 0
        call ForForce( bj_FORCE_PLAYER[0], function copyProxy )
        return ARG_STASH
    endfunction
    
    /* 스태쉬 내용물을 출력합니다 */
    function StashPrint takes stash whichStash returns nothing
        set ARG_STASH = whichStash
        call ForForce( bj_FORCE_PLAYER[0], function printProxy )
    endfunction
    
    /* 스태쉬의 데이터 변경 횟수를 받아옵니다. */
    function StashAge takes stash whichStash returns integer
        set ARG_STASH = whichStash
        set ARG_INDEX = 0
        call ForForce( bj_FORCE_PLAYER[0], function ageProxy )
        return ARG_INDEX
    endfunction

endlibrary
