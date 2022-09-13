//! textmacro UseDictionaryVJ
library Dictionary initializer onInit
    /*========================================================================*/
    private function error takes string scopes, string reason returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[WARN] Dictionary::" + scopes + " Error!! reason=" + reason )
    endfunction
    private function info takes string scopes, string reason returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[INFO] Dictionary::" + scopes + " message=" + reason )
    endfunction
    /*========================================================================*/
    globals
        private hashtable hids = InitHashtable( ) /* hash = index */
        private hashtable hkys = InitHashtable( ) /* hash = keystring */
        
        private hashtable keys = InitHashtable( ) /* 1.. = keystrings */
        private hashtable vals = InitHashtable( ) /* -1 = size, 1.. = tuples */
        
        private hashtable exis = InitHashtable( )
        private integer nextId = 0
    endglobals
    /*========================================================================*/
    private function createKeyIndex takes integer dict, string k, integer i returns nothing
        local integer hash = StringHash(k)
        local integer delta = 1
        loop
            exitwhen not HaveSavedString( hkys, dict, hash )
            set hash = hash + delta
            set delta = delta + 2
        endloop
        call SaveStr( hkys, dict, hash, k )
        call SaveInteger( hids, dict, hash, i )
    endfunction
    
    private function findKeyIndex takes integer dict, string k returns integer
        local integer hash = StringHash(k)
        local integer delta = 1
        loop
            exitwhen not HaveSavedString( hkys, dict, hash )
            if LoadStr( hkys, dict, hash ) == k then
                return LoadInteger( hids, dict, hash )
            endif
            set hash = hash + delta
            set delta = delta + 2
        endloop
        return -1
    endfunction
    
    private function containsKey takes integer dict, string k returns boolean
        local integer hash = StringHash(k)
        local integer delta = 1
        loop
            exitwhen not HaveSavedString( hkys, dict, hash )
            if LoadStr( hkys, dict, hash ) == k then
                return true
            endif
            set hash = hash + delta
            set delta = delta + 2
        endloop
        return false
    endfunction
    /*========================================================================*/
    globals
        private integer asyncDict = 0
        private string asyncKey = null
        private integer asyncValue = 0
        private boolean asyncResult = false
    endglobals
    
    private function existsAsync takes nothing returns nothing
        if not LoadBoolean( exis, asyncDict, 0 ) then
            return
        endif
        set asyncResult = true
    endfunction
    
    private function allocateAsync takes nothing returns nothing
        set nextId = nextId + 1
        set asyncDict = nextId
        call SaveBoolean( exis, nextId, 0, true )
    endfunction
    
    private function copyAsync takes nothing returns nothing
        local integer source = asyncDict
        local integer dest
        local integer i
        local integer size
        local integer v
        local string k
        set asyncDict = 0
        if not LoadBoolean( exis, source, 0 ) then
            return
        endif
        set nextId = nextId + 1
        set dest = nextId
        
        set size = LoadInteger( vals, source, -1 )
        set i = 1
        loop
            exitwhen i > size
            set k = LoadStr( keys, source, i )
            set v = LoadInteger( vals, source, i )
            call createKeyIndex( dest, k, i )
            call SaveStr( keys, dest, i, k )
            call SaveInteger( vals, dest, i, v )
            set i = i + 1
        endloop
        call SaveInteger( vals, dest, -1, size )
        call SaveBoolean( exis, dest, 0, true )
        
        set asyncDict = dest
    endfunction
    
    private function deallocateAsync takes nothing returns nothing
        if not LoadBoolean( exis, asyncDict, 0 ) then
            return
        endif
        call FlushChildHashtable( exis, asyncDict )
        call FlushChildHashtable( hids, asyncDict )
        call FlushChildHashtable( hkys, asyncDict )
        call FlushChildHashtable( keys, asyncDict )
        call FlushChildHashtable( vals, asyncDict )
        set asyncResult = true
    endfunction
    
    private function clearAsync takes nothing returns nothing
        if not LoadBoolean( exis, asyncDict, 0 ) then
            return
        endif
        call FlushChildHashtable( hids, asyncDict )
        call FlushChildHashtable( hkys, asyncDict )
        call FlushChildHashtable( keys, asyncDict )
        call FlushChildHashtable( vals, asyncDict )
        set asyncResult = true
    endfunction
    
    private function getSizeAsync takes nothing returns nothing
        if not LoadBoolean( exis, asyncDict, 0 ) then
            return
        endif
        set asyncValue = LoadInteger( vals, asyncDict, -1 )
    endfunction
    
    private function containsKeyAsync takes nothing returns nothing
        if not LoadBoolean( exis, asyncDict, 0 ) or asyncKey == null then
            return
        endif
        set asyncResult = containsKey( asyncDict, asyncKey )
    endfunction
    
    private function saveAsync takes nothing returns nothing
        local integer ki
        if not LoadBoolean( exis, asyncDict, 0 ) or asyncKey == null then
            return
        endif
        
        set ki = findKeyIndex( asyncDict, asyncKey )
        if ki < 0 then
            set ki = LoadInteger( vals, asyncDict, -1 ) + 1
            call SaveInteger( vals, asyncDict, -1, ki )
            call createKeyIndex( asyncDict, asyncKey, ki )
            call SaveStr( keys, asyncDict, ki, asyncKey )
        endif
        call SaveInteger( vals, asyncDict, ki, asyncValue )
        
        set asyncResult = true
    endfunction
    
    private function loadAsync takes nothing returns nothing
        local integer ki
        if not LoadBoolean( exis, asyncDict, 0 ) or asyncKey == null then
            return
        endif
        
        set ki = findKeyIndex( asyncDict, asyncKey )
        if ki < 0 then
            return
        endif
        set asyncValue = LoadInteger( vals, asyncDict, ki )
    endfunction
    
    private function printAsync takes nothing returns nothing
        local integer i
        local integer size
        if not LoadBoolean( exis, asyncDict, 0 ) then
            call info( "DictionaryPrint::printAsync", "no such dictionary("+I2S(asyncDict)+") exists" )
            return
        endif
        set size = LoadInteger( vals, asyncDict, -1 )
        set i = 1
        loop
            exitwhen i > size
            call info( "DictionaryPrint::printAsync", LoadStr(keys,asyncDict,-1)+"="+I2S(LoadInteger(vals,asyncDict,i)) )
            set i = i + 1
        endloop
    endfunction
    /*========================================================================*/
    struct dictionary extends array
    endstruct
    
    function DictionaryExists takes dictionary dict returns boolean
        set asyncDict = dict
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function existsAsync )
        return asyncResult
    endfunction
    
    function DictionaryCreate takes nothing returns dictionary
        set asyncDict = 0
        call ForForce( bj_FORCE_PLAYER[0], function allocateAsync )
        return asyncDict
    endfunction
    
    function DictionaryCopy takes dictionary dict returns dictionary
        set asyncDict = dict
        call ForForce( bj_FORCE_PLAYER[0], function copyAsync )
        return asyncDict
    endfunction
    
    function DictionaryFlush takes dictionary dict returns boolean
        set asyncDict = dict
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function deallocateAsync )
        return asyncResult
    endfunction
    
    function DictionaryClear takes dictionary dict returns boolean
        set asyncDict = dict
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function clearAsync )
        return asyncResult
    endfunction
    
    function DictionarySize takes dictionary dict returns integer
        set asyncDict = dict
        set asyncValue = 0
        call ForForce( bj_FORCE_PLAYER[0], function getSizeAsync )
        return asyncValue
    endfunction
    
    function DictionaryContains takes dictionary dict, string k returns boolean
        set asyncDict = dict
        set asyncKey = k
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function containsKeyAsync )
        return asyncResult
    endfunction
    
    function DictionarySave takes dictionary dict, string k, integer v returns boolean
        set asyncDict = dict
        set asyncKey = k
        set asyncValue = v
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function saveAsync )
        return asyncResult
    endfunction
    
    function DictionaryLoad takes dictionary dict, string k, integer default returns integer
        set asyncDict = dict
        set asyncKey = k
        set asyncValue = default
        set asyncResult = false
        call ForForce( bj_FORCE_PLAYER[0], function loadAsync )
        return asyncValue
    endfunction
    
    function DictionaryPrint takes dictionary dict returns nothing
        set asyncDict = dict
        call ForForce( bj_FORCE_PLAYER[0], function printAsync )
    endfunction
    /*========================================================================*/
    /*      TEST CODES      */
    /*========================================================================*/
    private function assertFalse takes string scopes, boolean actual returns nothing
        if actual then
            call error( "initTest::"+scopes, "expected: false, actual: true" )
        endif
    endfunction
    private function assertTrue takes string scopes, boolean actual returns nothing
        if not actual then
            call error( "initTest::"+scopes, "expected: false, actual: true" )
        endif
    endfunction
    private function assertIntEquals takes string scopes, integer expected, integer actual returns nothing
        if actual != expected then
            call error( "initTest::"+scopes, "expected: "+I2S(expected)+", actual: "+I2S(actual) )
        endif
    endfunction
    private function assertIntNonEquals takes string scopes, integer expected, integer actual returns nothing
        if actual == expected then
            call error( "initTest::"+scopes, "expected: not "+I2S(expected)+", actual: "+I2S(actual) )
        endif
    endfunction
    private function assertZero takes string scopes, integer actual returns nothing
        if actual != 0 then
            call error( "initTest::"+scopes, "expected: 0, actual: "+I2S(actual) )
        endif
    endfunction
    
    private function initTest takes nothing returns nothing
        local dictionary dict = 0
        
        // random access test
        call assertFalse( "DictionaryExists_False", DictionaryExists(dict) )
        call assertFalse( "DictionarySave_False", DictionarySave(dict,"SAMPLE.KEY.WOW",99999) )
        call assertFalse( "DictionarySave_False", DictionarySave(dict,"SAMPLE.KEY.wow",77777) )
        call assertFalse( "DictionaryContains_False", DictionaryContains(dict,"SAMPLE.KEY.WOW") )
        call assertFalse( "DictionaryContains_False", DictionaryContains(dict,"SAMPLE.KEY.wow") )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertZero( "DictionarySize_Zero", DictionarySize(dict) )
        call assertFalse( "DictionaryClear_False", DictionaryClear(dict) )
        call assertFalse( "DictionaryFlush_False", DictionaryFlush(dict) )
        
        // managed access test
        set dict = DictionaryCreate( )
        call assertTrue( "DictionaryExists_True", DictionaryExists(dict) )
        call assertTrue( "DictionarySave_True", DictionarySave(dict,"SAMPLE.KEY.WOW",99999) )
        call assertTrue( "DictionarySave_True", DictionarySave(dict,"SAMPLE.KEY.wow",77777) )
        call assertTrue( "DictionaryContains_True", DictionaryContains(dict,"SAMPLE.KEY.WOW") )
        call assertTrue( "DictionaryContains_True", DictionaryContains(dict,"SAMPLE.KEY.wow") )
        call assertIntEquals( "DictionaryLoad_Equals", 99999, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionaryLoad_Equals", 77777, DictionaryLoad(dict,"SAMPLE.KEY.wow",-1) )
        call assertIntEquals( "DictionarySize_Equals", 2, DictionarySize(dict) )
        
        call DictionaryPrint(dict)
        
        // post-copy access test
        set dict = DictionaryCopy( dict )
        call assertTrue( "DictionaryExists_True", DictionaryExists(dict) )
        call assertTrue( "DictionarySave_True", DictionarySave(dict,"SAMPLE.KEY.WOW",99999) )
        call assertTrue( "DictionarySave_True", DictionarySave(dict,"SAMPLE.KEY.wow",77777) )
        call assertTrue( "DictionaryContains_True", DictionaryContains(dict,"SAMPLE.KEY.WOW") )
        call assertTrue( "DictionaryContains_True", DictionaryContains(dict,"SAMPLE.KEY.wow") )
        call assertIntEquals( "DictionaryLoad_Equals", 99999, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionaryLoad_Equals", 77777, DictionaryLoad(dict,"SAMPLE.KEY.wow",-1) )
        call assertTrue( "DictionarySave_True", DictionarySave(dict,"SAMPLE.KEY.WOW",11111) )
        call assertIntEquals( "DictionaryLoad_Equals", 11111, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionarySize_Equals", 2, DictionarySize(dict) )
        
        call DictionaryPrint(dict)
        
        // post-clear access test
        call assertTrue( "DictionaryClear_True", DictionaryClear(dict) )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.wow",-1) )
        call assertZero( "DictionarySize_Zero", DictionarySize(dict) )
        call assertTrue( "DictionaryFlush_True", DictionaryFlush(dict) )
        
        // post-destruction access test
        call assertFalse( "DictionaryExists_False", DictionaryExists(dict) )
        call assertFalse( "DictionarySave_False", DictionarySave(dict,"SAMPLE.KEY.WOW",99999) )
        call assertFalse( "DictionarySave_False", DictionarySave(dict,"SAMPLE.KEY.wow",77777) )
        call assertFalse( "DictionaryContains_False", DictionaryContains(dict,"SAMPLE.KEY.WOW") )
        call assertFalse( "DictionaryContains_False", DictionaryContains(dict,"SAMPLE.KEY.wow") )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertIntEquals( "DictionaryLoad_NonEquals", -1, DictionaryLoad(dict,"SAMPLE.KEY.WOW",-1) )
        call assertZero( "DictionarySize_Zero", DictionarySize(dict) )
        call assertFalse( "DictionaryClear_False", DictionaryClear(dict) )
        call assertFalse( "DictionaryFlush_False", DictionaryFlush(dict) )
        
        call info( "initTest", "ALL TEST PASSED!" )
    endfunction
    /*========================================================================*/
    private function onInit takes nothing returns nothing
        debug call initTest( )
    endfunction
    /*========================================================================*/
endlibrary
//! endtextmacro
