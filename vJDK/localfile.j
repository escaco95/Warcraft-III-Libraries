//! textmacro UseLocalFileVJ
library LocalFile initializer onInit
    /*========================================================================*/
    private function error takes string scopes, string reason returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[WARN] LocalFile::" + scopes + " Error!! reason=" + reason )
    endfunction
    private function info takes string scopes, string reason returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[INFO] LocalFile::" + scopes + " message=" + reason )
    endfunction
    /*========================================================================*/
    /*      READ      */
    /*========================================================================*/
    globals
        private constant integer MAX_BITS = 30
        
        private unit packetFailRead = null
        private unit packetOK = null
        private unit array packetBits
        
        private trigger packetSyncTrig = null
    endglobals
    
    private function createBits takes nothing returns nothing
        local integer bit = 0
        loop
            exitwhen bit >= MAX_BITS
            set bit:packetBits = CreateUnit( Player(PLAYER_NEUTRAL_PASSIVE), 'hpea', 0.0, 0.0, 270.0 )
            set bit = bit + 1
        endloop
        set packetFailRead = CreateUnit( Player(PLAYER_NEUTRAL_PASSIVE), 'hpea', 0.0, 0.0, 270.0 )
        set packetOK = CreateUnit( Player(PLAYER_NEUTRAL_PASSIVE), 'hpea', 0.0, 0.0, 270.0 )
    endfunction
    
    private function getBinaryOf takes integer value returns string
        local integer i = 0
        local integer exp = 536870912
        local string result = ""
        loop
            exitwhen i >= MAX_BITS
            if value >= exp then
                set value = value - exp
                set result = result + "1"
            else
                set result = result + "0"
            endif
            set exp = exp / 2
            set i = i + 1
        endloop
        return result
    endfunction
    
    private function findBitOf takes unit u returns integer
        local integer bit = 0
        local integer value = 1
        loop
            exitwhen bit >= MAX_BITS
            if u == bit:packetBits then
                return value
            endif
            set bit = bit + 1
            set value = value * 2
        endloop
        return 0
    endfunction
    /*========================================================================*/
    /*      SYNC      */
    /*========================================================================*/
    globals
        private hashtable eventTable = InitHashtable( )
        
        private player eventPlayer = null
        private integer eventCallbackId = 0
        private string eventFileName = null
        private integer eventValue = 0
        private boolean eventResult = false
        private string eventMessage = null
    endglobals
    
    private function finalizeSync takes player p, integer pId, string fileName, integer callbackId, integer value, boolean result, string message returns nothing
        set eventPlayer = p
        set eventCallbackId = callbackId
        set eventFileName = fileName
        set eventValue = value
        set eventResult = result
        set eventMessage = message
        if HaveSavedHandle( eventTable, 0, callbackId ) then
            call TriggerExecute( LoadTriggerHandle(eventTable, 0, callbackId) )
        endif
        set eventPlayer = null
        set eventCallbackId = 0
        set eventFileName = null
        set eventValue = 0
        set eventResult = false
        set eventMessage = null
    endfunction
    
    function GetEventLocalFilePlayer takes nothing returns player
        return eventPlayer
    endfunction
    function GetEventLocalFileCallbackId takes nothing returns integer
        return eventCallbackId
    endfunction
    function GetEventLocalFileName takes nothing returns string
        return eventFileName
    endfunction
    function GetEventLocalFileValue takes nothing returns integer
        return eventValue
    endfunction
    function GetEventLocalFileResult takes nothing returns boolean
        return eventResult
    endfunction
    function GetEventLocalFileMessage takes nothing returns string
        return eventMessage
    endfunction
    
    function WhenLocalFileRead takes integer id, code c returns nothing
        if not HaveSavedHandle( eventTable, 0, id ) then
            call SaveTriggerHandle( eventTable, 0, id, CreateTrigger() )
        endif
        call TriggerAddAction( LoadTriggerHandle(eventTable, 0, id), c )
    endfunction
    /*========================================================================*/
    /*      READ      */
    /*========================================================================*/
    globals
        private player readPlayer = null
        private integer readCallbackId = 0
        private string readFile = null
        private boolean readRequestResult = false
        
        private boolean array isBusy
        private integer array syncCallbackId
        private integer array syncPackets
        private string array syncFileName
        
        private timer array syncTimer
    endglobals
    
    private function findPlayerIdOf takes timer t returns integer
        local integer pId = 0
        loop
            exitwhen pId >= bj_MAX_PLAYER_SLOTS
            if t == pId:syncTimer then
                return pId
            endif
            set pId = pId + 1
        endloop
        return - 1
    endfunction
    
    private function onConnectionTimeout takes nothing returns nothing
        local integer pId = findPlayerIdOf( GetExpiredTimer() )
        set pId:isBusy = false
        call finalizeSync( Player(pId), pId, pId:syncFileName, pId:syncCallbackId, 0, false, "네트워크 연결 시간 초과" )
    endfunction
    
    private function onPacketFailed takes nothing returns nothing
        local integer pId = findPlayerIdOf( GetExpiredTimer() )
        set pId:isBusy = false
        call finalizeSync( Player(pId), pId, pId:syncFileName, pId:syncCallbackId, 0, false, "저장소가 손상되었거나 존재하지 않음" )
    endfunction
    
    private function onPacketOK takes nothing returns nothing
        local integer pId = findPlayerIdOf( GetExpiredTimer() )
        set pId:isBusy = false
        call finalizeSync( Player(pId), pId, pId:syncFileName, pId:syncCallbackId, pId:syncPackets, true, "성공" )
    endfunction
    
    private function processPacket takes player p, unit u returns nothing
        local integer pId = GetPlayerId( p )
        local integer bitValue
        if u == packetFailRead then
            debug call error( "processPacket", "싱크 실패: 저장소가 손상되었거나 없음" )
            call TimerStart( pId:syncTimer, 0.03125, false, function onPacketFailed )
            return
        endif
        if u == packetOK then
            debug call info( "processPacket", "싱크 성공: " + I2S(pId:syncPackets) )
            call TimerStart( pId:syncTimer, 0.03125, false, function onPacketOK )
            return
        endif
        
        set bitValue = findBitOf( u )
        if bitValue > 0 then
            if not pId:isBusy then
                debug call error( "processPacket", "싱크 무시: 네트워크 동기화 외의 단계에서 패킷 인입됨" )
                return
            endif
            debug call info( "processPacket", "비트 수신: " + I2S(bitValue) + " from " + GetPlayerName(p) )
            set pId:syncPackets = pId:syncPackets + bitValue
            return
        endif
    endfunction
    
    private function onPacketReceived takes nothing returns nothing
        call processPacket( GetTriggerPlayer(), GetTriggerUnit() )
    endfunction
    
    private function readAsync takes nothing returns nothing
        local integer pId
        local string oldName
        local string localCode
        local integer bit
        if readPlayer == null then
            debug call error( "LocalFileRead::readAsync", "PlayerNullException" )
            return
        endif
        if readFile == null then
            debug call error( "LocalFileRead::readAsync", "FileNameNullException" )
            return
        endif
        set pId = GetPlayerId( readPlayer )
        if pId:isBusy then
            debug call error( "LocalFileRead::readAsync", "PlayerWasBusyException" )
            return
        endif
        
        set pId:syncCallbackId = readCallbackId
        set pId:syncFileName = readFile
        set pId:syncPackets = 0
        if pId:syncTimer == null then
            set pId:syncTimer = CreateTimer( )
        endif
        call TimerStart( pId:syncTimer, 3.0, false, function onConnectionTimeout )
        set oldName = GetPlayerName( Player(PLAYER_NEUTRAL_PASSIVE) )
        if GetLocalPlayer() == readPlayer then
            call PreloadRefresh( )
            // Use only local code (no net traffic) within this block to avoid desyncs.
            call Preloader( readFile )
            set localCode = GetPlayerName( Player(PLAYER_NEUTRAL_PASSIVE) )
            call SetPlayerName( Player(PLAYER_NEUTRAL_PASSIVE), oldName )
            
            call ClearSelection()
            if StringLength(localCode) != MAX_BITS + 5 or SubString( localCode, 0, 5 ) != "BINR:" then
                /*FAIL TO READ*/
                call SelectUnit(packetFailRead, true)
                call SelectUnit(packetFailRead, false)
            else
                set bit = 0
                loop
                    exitwhen bit >= MAX_BITS
                    if SubString( localCode, MAX_BITS + 4 - bit, MAX_BITS + 5 - bit ) == "1" then
                        call SelectUnit(bit:packetBits, true)
                        call SelectUnit(bit:packetBits, false)
                    endif
                    set bit = bit + 1
                endloop
                call SelectUnit(packetOK, true)
                call SelectUnit(packetOK, false)
            endif
        endif
        
        set pId:isBusy = true
        set readRequestResult = true
    endfunction
    
    function LocalFileRead takes player p, integer callbackId, string fileName returns boolean
        set readPlayer = p
        set readFile = fileName
        set readCallbackId = callbackId
        set readRequestResult = false
        call ForForce( bj_FORCE_PLAYER[0], function readAsync )
        return readRequestResult
    endfunction
    /*========================================================================*/
    /*      WRITE      */
    /*========================================================================*/
    globals
        private player writePlayer = null
        private string writeFile = null
        private integer writeValue = 0
        private boolean writeResult = false
    endglobals
    
    private function writeAsync takes nothing returns nothing
        local string binaries
        if writePlayer == null then
            debug call error( "LocalFileWrite::writeAsync", "PlayerNullException" )
            return
        endif
        if writeFile == null then
            debug call error( "LocalFileWrite::writeAsync", "FileNameNullException" )
            return
        endif
        if writeValue < 0 or 1073741823 < writeValue then
            debug call error( "LocalFileWrite::writeAsync", "ValueOutOfRangeException" )
            return
        endif
        set binaries = "BINR:" + getBinaryOf( writeValue )
        if GetLocalPlayer() == writePlayer then
            // Use only local code (no net traffic) within this block to avoid desyncs.
            call PreloadGenStart()
            call PreloadGenClear()
            call Preload( "\" )
            call SetPlayerName( Player( PLAYER_NEUTRAL_PASSIVE ) , \"" + binaries + "\" )  //")
            call Preload( "\" )
        endfunction
        function Speedup takes nothing returns nothing //")
            call PreloadGenEnd(writeFile)
        endif
        set writeResult = true
    endfunction
    function LocalFileWrite takes player p, string fileName, integer value returns boolean
        set writePlayer = p
        set writeFile = fileName
        set writeValue = value
        set writeResult = false
        call ForForce( bj_FORCE_PLAYER[0], function writeAsync )
        return writeResult
    endfunction
    /*========================================================================*/
    /*      TEST CODES      */
    /*========================================================================*/
    private function getBinaryOfTest_True takes integer value, string bits returns nothing
        local string binary = getBinaryOf( value )
        if binary != bits then
            call error( "initTest::getBinaryOfTest_True", "expected: " + bits + ", actual: " + binary )
        endif
    endfunction
    
    private function initTest takes nothing returns nothing
        call getBinaryOfTest_True( 0 , "000000000000000000000000000000" )
        call getBinaryOfTest_True( 99999, "000000000000011000011010011111" )
        call getBinaryOfTest_True( 536870912 , "100000000000000000000000000000" )
        call getBinaryOfTest_True( 1073741823 , "111111111111111111111111111111" )
    endfunction
    /*========================================================================*/
    private function onInit takes nothing returns nothing
        call createBits( )
        
        set packetSyncTrig = CreateTrigger( )
        call TriggerAddAction( packetSyncTrig, function onPacketReceived )
        call TriggerRegisterAnyUnitEventBJ( packetSyncTrig, EVENT_PLAYER_UNIT_SELECTED )
        
        debug call initTest( )
    endfunction
    /*========================================================================*/
endlibrary
//! endtextmacro
