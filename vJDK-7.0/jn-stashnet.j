/* JNStashNet 1.0 */
/* REFERENCE : https://github.com/escaco95/Warcraft-III-Libraries/blob/escaco/vJDK-7.0/jn-stashnet.j */
/*
RECENT CHANGES
1.0 - Official release (2023 / 05 / 30)
*/
library JNStashNet initializer onInit requires Stash
    /*========================================================================*/
    /* TEXTMACRO */
    /*========================================================================*/
    //! textmacro VALIDATE_JNSTASHNET_USER takes PLAYER
        if $PLAYER$ == null then
            call warn( "null 플레이어가 전달되었습니다." )
            return
        endif
        if GetPlayerController( $PLAYER$ ) != MAP_CONTROL_USER then
            call warn( "유저가 아닌 플레이어가 전달되었습니다." )
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_JNSTASHNET_MAPDATA takes MAPID, USERID, SECRETKEY
        if $MAPID$ == null then
            call error( "null 맵 ID 가 전달되었습니다." )
            return
        endif
        if $USERID$ == null then
            call error( "null 유저 ID 가 전달되었습니다." )
            return
        endif
        if $SECRETKEY$ == null then
            call error( "null 맵 API 키가 전달되었습니다." )
            return
        endif
    //! endtextmacro
    //! textmacro VALIDATE_JNSTASHNET_DUPESTASH takes STASH, DUPESTASH
        if $STASH$ == 0 then
            call error( "null stash 가 전달되었습니다." )
            return
        endif
        if not StashExists( $STASH$ ) then
            call error( "파괴되었거나, 생성에 실패한 stash 가 전달되었습니다." )
            return
        endif
        set $DUPESTASH$ = StashCopy( $STASH$ )
        if not StashExists( $DUPESTASH$ ) then
            call error( "stash 사본 생성에 실패했습니다." )
            return
        endif
    //! endtextmacro
    /*========================================================================*/
    /* LOGGING */
    /*========================================================================*/
    private function trace takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[추적] JNStashNet - " + message )
    endfunction
    private function warn takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[경고] JNStashNet - " + message )
    endfunction
    private function error takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0.0, 0.0, 3600.0, "[오류] JNStashNet - " + message )
    endfunction
    /*========================================================================*/
    /* INTERNAL LOGICS */
    /*========================================================================*/
    native DzTriggerRegisterSyncData takes trigger trig, string prefix, boolean server returns nothing
    native DzSyncData takes string prefix, string data returns nothing
    native DzGetTriggerSyncData takes nothing returns string
    native JNStringSplit takes string str, string sub, integer index returns string
    /* REFERENCE : https://m16tool.xyz/JNAPI/Use */
    native JNUse takes nothing returns boolean
    /* REFERENCE : https://m16tool.xyz/JNAPI/ObjectUser */
    native JNObjectUserInit takes string MapId, string UserId, string SecretKey, string Character returns integer
    native JNObjectUserInit2 takes string MapId, string UserId, string SecretKey, string Character returns integer
    native JNObjectUserSave takes string MapId, string UserId, string SecretKey, string Character returns string
    native JNObjectUserSetInt takes string UserId, string Field, integer Value returns nothing
    native JNObjectUserGetInt takes string UserId, string Field returns integer
    native JNObjectUserSetString takes string UserId, string Field, string Value returns nothing
    native JNObjectUserGetString takes string UserId, string Field returns string
    
    globals
        private constant real CONNECTION_PROCESS_INTERVAL = 0.03125
        private constant string TASK_SYNC_KEY = "STSH_TASK"

        private constant integer TASK_DOWNLOAD_USER_JNUSE = 10
        private constant integer TASK_DOWNLOAD_USER_JNUSE_WAIT = 11
        private constant integer TASK_DOWNLOAD_USER_INIT = 12
        private constant integer TASK_DOWNLOAD_USER_INIT_WAIT = 13
        private constant integer TASK_DOWNLOAD_USER_HEADER = 14
        private constant integer TASK_DOWNLOAD_USER_HEADER_WAIT = 15
        private constant integer TASK_DOWNLOAD_USER_BODY = 16
        private constant integer TASK_DOWNLOAD_USER_BODY_WAIT = 17
        private constant integer TASK_DOWNLOAD_USER_FINALIZE = 18
        
        private constant integer TASK_UPLOAD_USER_STORE_DATA = 100
        private constant integer TASK_UPLOAD_USER_SAVE = 101
        private constant integer TASK_UPLOAD_USER_SAVE_WAIT = 102
        private constant integer TASK_UPLOAD_USER_FINALIZE = 103

        private integer TASK_NEXT = 0
        private hashtable TASK_USER_TABLE = InitHashtable( )
        private hashtable TASK_STR_TABLE = InitHashtable( )
        private hashtable TASK_INT_TABLE = InitHashtable( )
        private hashtable TASK_TRIG_TABLE = InitHashtable( )

        private constant integer TASK_USER = 0
        private constant integer TASK_MAPID = 1
        private constant integer TASK_USERID = 2
        private constant integer TASK_SECRETKEY = 3
        private constant integer TASK_MAX = 10
        private constant integer TASK_PROGRESS = 11
        private constant integer TASK_STAGE = 12
        private constant integer TASK_STASH = 20
        private constant integer TASK_CALLBACK = 30
        private constant integer TASK_RES_JNUSE = 50
        private constant integer TASK_RES_INIT = 51
        private constant integer TASK_RES_HEADER_SIZE = 52
        private constant integer TASK_RES_BODY_REQUEST = 53
        private constant integer TASK_RES_SAVE_RESULT = 100

        private timer TASK_ACTIVATOR = CreateTimer( )

        private integer ACTIVE_TASK_COUNT = 0
        private integer array ACTIVE_TASKS
        
        private player EV_USER = null
        private stash EV_STASH = 0
        private boolean EV_FINISHED = false
        private boolean EV_RESULT = false
        private string EV_MESSAGE = null
        private integer EV_MAX = 0
        private integer EV_PROGRESS = 0
        
        private player ARG_USER = null
        private string ARG_MAPID = null
        private string ARG_USERID = null
        private string ARG_SECRETKEY = null
        private stash ARG_STASH = 0
        private trigger ARG_CALLBACK = null
        
        private boolean RES_FLAG = false

        private integer ARG_TASK = 0
        private boolean RES_TASK = false
    endglobals

    private function fireTrigger takes trigger trig, player user, stash whichStash, boolean finished, boolean result, string message, integer max, integer progress returns nothing
        local player pUser = EV_USER
        local stash pStash = EV_STASH
        local boolean pFinished = EV_FINISHED
        local boolean pResult = EV_RESULT
        local string pMessage = EV_MESSAGE
        local integer pMax = EV_MAX
        local integer pProgress = EV_PROGRESS

        /* call trace( message ) */

        set EV_USER = user
        set EV_STASH = whichStash
        set EV_FINISHED = finished
        set EV_RESULT = result
        set EV_MESSAGE = message
        set EV_MAX = max
        set EV_PROGRESS = progress
        call TriggerExecute( trig )
        set EV_USER = pUser
        set EV_STASH = pStash
        set EV_FINISHED = pFinished
        set EV_RESULT = pResult
        set EV_MESSAGE = pMessage
        set EV_MAX = pMax
        set EV_PROGRESS = pProgress

        set pUser = null
    endfunction

    private function createTask takes nothing returns integer
        set TASK_NEXT = TASK_NEXT + 1
        return TASK_NEXT
    endfunction

    private function flushTask takes integer task returns nothing
        call FlushChildHashtable( TASK_USER_TABLE, task )
        call FlushChildHashtable( TASK_STR_TABLE, task )
        call FlushChildHashtable( TASK_INT_TABLE, task )
        call FlushChildHashtable( TASK_TRIG_TABLE, task )
    endfunction

    private function queueTask takes integer task returns nothing
        set ACTIVE_TASKS[ACTIVE_TASK_COUNT] = task
        set ACTIVE_TASK_COUNT = ACTIVE_TASK_COUNT + 1

        if ACTIVE_TASK_COUNT == 1 then
            call TimerStart( TASK_ACTIVATOR, CONNECTION_PROCESS_INTERVAL, true, null )
        endif
    endfunction

    private function syncDownloadJNUse takes integer task, string data returns nothing
        call SaveInteger( TASK_INT_TABLE, task, TASK_RES_JNUSE, S2I(data) )
    endfunction
    
    private function syncDownloadUserInitResult takes integer task, string data returns nothing
        call SaveInteger( TASK_INT_TABLE, task, TASK_RES_INIT, S2I(data) )
    endfunction
    
    private function syncDownloadUserHeaderSizeResult takes integer task, string data returns nothing
        call SaveInteger( TASK_INT_TABLE, task, TASK_RES_HEADER_SIZE, S2I(data) )
    endfunction
    
    private function syncDownloadUserBody takes integer task, string data returns nothing
        local string field = JNStringSplit( data, "/", 0 )
        local string value = SubString( data, StringLength(field) + 1, StringLength(data) )
        local stash whichStash = LoadInteger( TASK_INT_TABLE, task, TASK_STASH )
        local integer progress = LoadInteger( TASK_INT_TABLE, task, TASK_PROGRESS )
        call StashSave( whichStash, field, value )
        call SaveInteger( TASK_INT_TABLE, task, TASK_PROGRESS, progress + 1 )
    endfunction

    private function syncUploadUserSaveResult takes integer task, string data returns nothing
        call SaveStr( TASK_STR_TABLE, task, TASK_RES_SAVE_RESULT, data )
    endfunction

    private function onTaskSync takes nothing returns nothing
        local string packet = DzGetTriggerSyncData( )
        local string task = JNStringSplit( packet, "|", 0 )
        local string header = JNStringSplit( SubString(packet, StringLength(task) + 1, StringLength(packet)), "|", 0 )
        local string data = SubString(packet, StringLength(task) + StringLength(header) + 2, StringLength(packet))

        /* call trace( packet ) */

        if header == "DL_US_JN" then
            call syncDownloadJNUse( S2I(task), data )
        elseif header == "DL_US_INIT" then
            call syncDownloadUserInitResult( S2I(task), data )
        elseif header == "DL_US_SIZE" then
            call syncDownloadUserHeaderSizeResult( S2I(task), data )
        elseif header == "DL_US_BODY" then
            call syncDownloadUserBody( S2I(task), data )
        elseif header == "UP_US_SAVE" then
            call syncUploadUserSaveResult( S2I(task), data )
        else
            call error( "핸들링 불가능한 TASK SYNC 헤더를 수신했습니다." )
        endif
    endfunction

    private function processDownloadJNUse takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string jnOk = I2S(task) + "|DL_US_JN|1"
        local string jnNo = I2S(task) + "|DL_US_JN|0"

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "서버와 통신을 시도합니다.", 0, 0 )
        endif

        if GetLocalPlayer( ) == user then
            if JNUse( ) then
                call DzSyncData( TASK_SYNC_KEY, jnOk )
            else
                call DzSyncData( TASK_SYNC_KEY, jnNo )
            endif
        endif
        
        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_JNUSE_WAIT )

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadJNUseWait takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )

        if HaveSavedInteger( TASK_INT_TABLE, task, TASK_RES_JNUSE ) then
            if LoadInteger( TASK_INT_TABLE, task, TASK_RES_JNUSE ) == 1 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, false, false, "서버와 연결했습니다.", 0, 0 )
                endif

                call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_INIT )
            else
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "서버와 연결하지 못했습니다.", 0, 0 )
                endif
                set user = null
                return
            endif
        else
            if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                call fireTrigger( /*
                */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                */ user, 0, false, false, "서버와 연결 중입니다...", 0, 0 )
            endif
        endif

        set RES_TASK = true
        set user = null
    endfunction

    private function processDownloadInit takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string mapId = LoadStr( TASK_STR_TABLE, task, TASK_MAPID )
        local string userId = LoadStr( TASK_STR_TABLE, task, TASK_USERID )
        local string secretKey = LoadStr( TASK_STR_TABLE, task, TASK_SECRETKEY )
        local string charId = "Default String"
        local integer localResult = 0
        local string jnOk = I2S(task) + "|DL_US_INIT|0"
        local string jnM1 = I2S(task) + "|DL_US_INIT|-1"
        local string jnM3 = I2S(task) + "|DL_US_INIT|-3"
        local string jnMX = I2S(task) + "|DL_US_INIT|9999"

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "서버 데이터를 수신 시도합니다.", 0, 0 )
        endif

        if GetLocalPlayer( ) == user then
            set localResult = JNObjectUserInit( mapId, userId, secretKey, charId )
            if localResult == 0 then
                call DzSyncData( TASK_SYNC_KEY, jnOk )
            elseif localResult == - 1 then
                call DzSyncData( TASK_SYNC_KEY, jnM1 )
            elseif localResult == - 3 then
                call DzSyncData( TASK_SYNC_KEY, jnM3 )
            else
                call DzSyncData( TASK_SYNC_KEY, jnMX )
            endif
        endif

        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_INIT_WAIT )

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadInitWait takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local integer initResult

        if HaveSavedInteger( TASK_INT_TABLE, task, TASK_RES_INIT ) then
            set initResult = LoadInteger( TASK_INT_TABLE, task, TASK_RES_INIT )
            if initResult == 0 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, false, false, "서버 데이터를 수신했습니다.", 0, 0 )
                endif

                call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_HEADER )
            elseif initResult == - 1 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "인증 실패했습니다.", 0, 0 )
                endif
                set user = null
                return
            elseif initResult == - 3 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "중복 로드로 인해 통신이 중단되었습니다.", 0, 0 )
                endif
                set user = null
                return
            elseif initResult == 9999 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "서버에서 알 수 없는 응답을 반환했습니다. 버전이 호환되지 않을 수 있습니다.", 0, 0 )
                endif
                set user = null
                return
            else
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "알 수 없는 내부 오류로 서버 데이터를 수신하지 못했습니다.", 0, 0 )
                endif
                set user = null
                return
            endif
        else
            if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                call fireTrigger( /*
                */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                */ user, 0, false, false, "서버 데이터를 수신 중입니다...", 0, 0 )
            endif
        endif

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadUserHeader takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string userId = LoadStr( TASK_STR_TABLE, task, TASK_USERID )
        local integer localValue = - 1

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "데이터 헤더 동기화를 시도합니다.", 0, 0 )
        endif

        if GetLocalPlayer( ) == user then
            set localValue = JNObjectUserGetInt( userId, "stash.size" )
            call DzSyncData( TASK_SYNC_KEY, I2S(task) + "|DL_US_SIZE|" + I2S(localValue) )
        endif

        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_HEADER_WAIT )

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadUserHeaderWait takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local integer size

        if HaveSavedInteger( TASK_INT_TABLE, task, TASK_RES_HEADER_SIZE ) then
            set size = LoadInteger( TASK_INT_TABLE, task, TASK_RES_HEADER_SIZE )
            if size < 0 then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, "데이터 헤더가 손상되었습니다.", 0, 0 )
                endif
                set user = null
                return
            endif

            call SaveInteger( TASK_INT_TABLE, task, TASK_MAX, size )
            call SaveInteger( TASK_INT_TABLE, task, TASK_RES_BODY_REQUEST, 0 )
            call SaveInteger( TASK_INT_TABLE, task, TASK_STASH, CreateStash() )

            if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                call fireTrigger( /*
                */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                */ user, 0, false, false, "데이터 헤더를 동기화했습니다.", /*
                */ LoadInteger( TASK_INT_TABLE, task, TASK_MAX ), /*
                */ LoadInteger( TASK_INT_TABLE, task, TASK_PROGRESS ) )
            endif
            
            call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_BODY )
        else
            if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                call fireTrigger( /*
                */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                */ user, 0, false, false, "데이터 헤더 동기화 중입니다...", 0, 0 )
            endif
        endif

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadUserBody takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string userId = LoadStr( TASK_STR_TABLE, task, TASK_USERID )
        local integer bodyRequest = LoadInteger( TASK_INT_TABLE, task, TASK_RES_BODY_REQUEST )
        local integer bodyRequestMax = LoadInteger( TASK_INT_TABLE, task, TASK_RES_HEADER_SIZE )
        local string bodyRequestKey

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "데이터 동기화 중입니다.", /*
            */ LoadInteger( TASK_INT_TABLE, task, TASK_MAX ), /*
            */ LoadInteger( TASK_INT_TABLE, task, TASK_PROGRESS ) )
        endif

        if bodyRequest >= bodyRequestMax then
            call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_BODY_WAIT )
        else
            set bodyRequestKey = "stash." + I2S( bodyRequest )
            if GetLocalPlayer( ) == user then
                call DzSyncData( TASK_SYNC_KEY, I2S(task) + "|DL_US_BODY|" + JNObjectUserGetString( userId, bodyRequestKey ) )
            endif

            set bodyRequest = bodyRequest + 1
            call SaveInteger( TASK_INT_TABLE, task, TASK_RES_BODY_REQUEST, bodyRequest )
        endif

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processDownloadUserBodyWait takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local integer progress = LoadInteger( TASK_INT_TABLE, task, TASK_PROGRESS )
        local integer max = LoadInteger( TASK_INT_TABLE, task, TASK_MAX )

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "데이터 동기화 중입니다.", /*
            */ max, /*
            */ progress )
        endif

        if progress >= max then
            call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_FINALIZE )
        endif

        set RES_TASK = true
        set user = null
    endfunction

    private function processDownloadUserFinalize takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, /*
            */ LoadInteger( TASK_INT_TABLE, task, TASK_STASH ), true, true, "데이터가 동기화되었습니다.", /*
            */ LoadInteger( TASK_INT_TABLE, task, TASK_MAX ), /*
            */ LoadInteger( TASK_INT_TABLE, task, TASK_PROGRESS ) )
        endif

        set user = null
    endfunction
    
    private function processUploadUserStoreData takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string userId = LoadStr( TASK_STR_TABLE, task, TASK_USERID )
        local stash whichStash = LoadInteger( TASK_INT_TABLE, task, TASK_STASH )
        local integer imax = StashSize( whichStash )
        local integer i = 0
        local string field
        local string value

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "데이터 준비 중...", 0, 0 )
        endif

        loop
            exitwhen i >= imax

            set field = "stash." + I2S(i)
            set value = StashKeyAt( whichStash, i )+"/"+StashValueAt( whichStash, i, "" )
            if GetLocalPlayer() == user then
                call JNObjectUserSetString( userId, field, value )
            endif

            set i = i + 1
        endloop

        set field = "stash.size"
        if GetLocalPlayer() == user then
            call JNObjectUserSetInt( userId, field, imax )
        endif

        call DestroyStash( whichStash )
        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_UPLOAD_USER_SAVE )

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processUploadUserSave takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string mapId = LoadStr( TASK_STR_TABLE, task, TASK_MAPID )
        local string userId = LoadStr( TASK_STR_TABLE, task, TASK_USERID )
        local string secretKey = LoadStr( TASK_STR_TABLE, task, TASK_SECRETKEY )
        local string charId = "Default String"
        local string jnNo = I2S(task) + "|UP_US_SAVE|서버와 연결하지 못했습니다."
        local string localResult = ""

        if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
            call fireTrigger( /*
            */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
            */ user, 0, false, false, "데이터 업로드를 시작합니다.", 0, 0 )
        endif

        if GetLocalPlayer() == user then
            if JNUse() then
                set localResult = JNObjectUserSave( mapId, userId, secretKey, charId )
                call DzSyncData( TASK_SYNC_KEY, I2S(task) + "|UP_US_SAVE|" + localResult )
            else
                call DzSyncData( TASK_SYNC_KEY, jnNo )
            endif
        endif
        
        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_UPLOAD_USER_SAVE_WAIT )

        set RES_TASK = true
        set user = null
    endfunction
    
    private function processUploadUserSaveWait takes integer task returns nothing
        local player user = LoadPlayerHandle( TASK_USER_TABLE, task, TASK_USER )
        local string saveResult

        if HaveSavedString( TASK_STR_TABLE, task, TASK_RES_SAVE_RESULT ) then
            set saveResult = LoadStr( TASK_STR_TABLE, task, TASK_RES_SAVE_RESULT )
            if saveResult == "저장이 성공적으로 되었습니다." then
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, true, saveResult, 0, 0 )
                endif
            else
                if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                    call fireTrigger( /*
                    */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                    */ user, 0, true, false, saveResult, 0, 0 )
                endif
            endif
            set user = null
            return
        else
            if HaveSavedHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ) then
                call fireTrigger( /*
                */ LoadTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK ), /*
                */ user, 0, false, false, "데이터 업로드 중입니다...", 0, 0 )
            endif
        endif

        set RES_TASK = true
        set user = null
    endfunction

    private function processTaskSwitch takes nothing returns nothing
        local integer task = ARG_TASK
        local integer stage = LoadInteger( TASK_INT_TABLE, task, TASK_STAGE )

        if stage == TASK_DOWNLOAD_USER_JNUSE then
            call processDownloadJNUse( task )
        elseif stage == TASK_DOWNLOAD_USER_JNUSE_WAIT then
            call processDownloadJNUseWait( task )
        elseif stage == TASK_DOWNLOAD_USER_INIT then
            call processDownloadInit( task )
        elseif stage == TASK_DOWNLOAD_USER_INIT_WAIT then
            call processDownloadInitWait( task )
        elseif stage == TASK_DOWNLOAD_USER_HEADER then
            call processDownloadUserHeader( task )
        elseif stage == TASK_DOWNLOAD_USER_HEADER_WAIT then
            call processDownloadUserHeaderWait( task )
        elseif stage == TASK_DOWNLOAD_USER_BODY then
            call processDownloadUserBody( task )
        elseif stage == TASK_DOWNLOAD_USER_BODY_WAIT then
            call processDownloadUserBodyWait( task )
        elseif stage == TASK_DOWNLOAD_USER_FINALIZE then
            call processDownloadUserFinalize( task )
        elseif stage == TASK_UPLOAD_USER_STORE_DATA then
            call processUploadUserStoreData( task )
        elseif stage == TASK_UPLOAD_USER_SAVE then
            call processUploadUserSave( task )
        elseif stage == TASK_UPLOAD_USER_SAVE_WAIT then
            call processUploadUserSaveWait( task )
        else
            call error( "핸들링 불가능한 TASK 상태에 도달했습니다." )
        endif
    endfunction

    private function processTask takes integer task returns boolean
        set ARG_TASK = task
        set RES_TASK = false
        call ForForce( bj_FORCE_PLAYER[0], function processTaskSwitch )
        return RES_TASK
    endfunction

    private function queueAction takes nothing returns nothing
        local integer i
        local integer task

        if ACTIVE_TASK_COUNT == 0 then
            call PauseTimer( TASK_ACTIVATOR )
            return
        endif

        set i = 0
        loop
            exitwhen i >= ACTIVE_TASK_COUNT
            if processTask( ACTIVE_TASKS[i] ) then
                set i = i + 1
            else
                call flushTask( ACTIVE_TASKS[i] )
                if i < ACTIVE_TASK_COUNT - 1 then
                    set ACTIVE_TASKS[i] = ACTIVE_TASKS[ACTIVE_TASK_COUNT - 1]
                endif
                set ACTIVE_TASK_COUNT = ACTIVE_TASK_COUNT - 1
            endif
        endloop
    endfunction

    private function onInit takes nothing returns nothing
        local trigger trig

        set trig = CreateTrigger( )
        call TriggerRegisterTimerExpireEvent( trig, TASK_ACTIVATOR )
        call TriggerAddAction( trig, function queueAction )

        set trig = CreateTrigger( )
        call TriggerAddAction( trig, function onTaskSync )
        call DzTriggerRegisterSyncData( trig, TASK_SYNC_KEY, false )

        set trig = null
    endfunction

    private function downloadUser takes player user, string mapId, string userId, string secretKey, trigger callback returns nothing
        local integer task
        //! runtextmacro VALIDATE_JNSTASHNET_USER( "user" )
        //! runtextmacro VALIDATE_JNSTASHNET_MAPDATA( "mapId", "userId", "secretKey" )

        set task = createTask( )
        call SavePlayerHandle( TASK_USER_TABLE, task, TASK_USER, user )
        call SaveStr( TASK_STR_TABLE, task, TASK_MAPID, mapId )
        call SaveStr( TASK_STR_TABLE, task, TASK_USERID, userId )
        call SaveStr( TASK_STR_TABLE, task, TASK_SECRETKEY, secretKey )
        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_DOWNLOAD_USER_JNUSE )
        call SaveInteger( TASK_INT_TABLE, task, TASK_MAX, 0 )
        call SaveInteger( TASK_INT_TABLE, task, TASK_PROGRESS, 0 )
        if callback != null then
            call SaveTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK, callback )
        endif

        call queueTask( task )

        set RES_FLAG = true
    endfunction
    
    private function uploadUser takes player user, string mapId, string userId, string secretKey, stash whichStash, trigger callback returns nothing
        local stash dupeStash
        local integer task
        //! runtextmacro VALIDATE_JNSTASHNET_USER( "user" )
        //! runtextmacro VALIDATE_JNSTASHNET_MAPDATA( "mapId", "userId", "secretKey" )
        //! runtextmacro VALIDATE_JNSTASHNET_DUPESTASH( "whichStash", "dupeStash" )

        set task = createTask( )
        call SavePlayerHandle( TASK_USER_TABLE, task, TASK_USER, user )
        call SaveStr( TASK_STR_TABLE, task, TASK_MAPID, mapId )
        call SaveStr( TASK_STR_TABLE, task, TASK_USERID, userId )
        call SaveStr( TASK_STR_TABLE, task, TASK_SECRETKEY, secretKey )
        call SaveInteger( TASK_INT_TABLE, task, TASK_STAGE, TASK_UPLOAD_USER_STORE_DATA )
        call SaveInteger( TASK_INT_TABLE, task, TASK_MAX, 0 )
        call SaveInteger( TASK_INT_TABLE, task, TASK_PROGRESS, 0 )
        call SaveInteger( TASK_INT_TABLE, task, TASK_STASH, dupeStash )
        if callback != null then
            call SaveTriggerHandle( TASK_TRIG_TABLE, task, TASK_CALLBACK, callback )
        endif

        call queueTask( task )

        set RES_FLAG = true
    endfunction
    /*========================================================================*/
    /* PROXY FUNCTIONS */
    /*========================================================================*/
    private function downloadUserProxy takes nothing returns nothing
        call downloadUser( ARG_USER, ARG_MAPID, ARG_USERID, ARG_SECRETKEY, ARG_CALLBACK )
    endfunction
    
    private function uploadUserProxy takes nothing returns nothing
        call uploadUser( ARG_USER, ARG_MAPID, ARG_USERID, ARG_SECRETKEY, ARG_STASH, ARG_CALLBACK )
    endfunction
    /*========================================================================*/
    /* EXTERNAL INTERFACES */
    /*========================================================================*/
    /* JNStashNet - 스태쉬를 UserObject 로부터 다운로드 */
    function JNStashNetDownloadUser takes player user, string mapId, string userId, string secretKey, trigger callback returns boolean
        set ARG_USER = user
        set ARG_MAPID = mapId
        set ARG_USERID = userId
        set ARG_SECRETKEY = secretKey
        set ARG_CALLBACK = callback
        set RES_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function downloadUserProxy )
        return RES_FLAG
    endfunction
    
    /* JNStashNet - 스태쉬를 UserObject 에 업로드 */
    function JNStashNetUploadUser takes player user, string mapId, string userId, string secretKey, stash whichStash, trigger callback returns boolean
        set ARG_USER = user
        set ARG_MAPID = mapId
        set ARG_USERID = userId
        set ARG_SECRETKEY = secretKey
        set ARG_STASH = whichStash
        set ARG_CALLBACK = callback
        set RES_FLAG = false
        call ForForce( bj_FORCE_PLAYER[0], function uploadUserProxy )
        return RES_FLAG
    endfunction
    
    /* 이벤트 응답 - (다운로드/업로드) 중인 플레이어 */
    function JNStashNetGetPlayer takes nothing returns player
        return EV_USER
    endfunction
    
    /* 이벤트 응답 - (다운로드/업로드) 최종 성공 여부 */
    function JNStashNetGetResult takes nothing returns boolean
        return EV_RESULT
    endfunction
    
    /* 이벤트 응답 - (다운로드/업로드) 절차 종료 여부 */
    function JNStashNetGetFinished takes nothing returns boolean
        return EV_FINISHED
    endfunction
    
    /* 이벤트 응답 - (다운로드/업로드) 관련 메시지 (또는 오류 메시지) */
    function JNStashNetGetMessage takes nothing returns string
        return EV_MESSAGE
    endfunction

    /* 이벤트 응답 - (다운로드/업로드) 전체량 */
    function JNStashNetGetMaximum takes nothing returns integer
        return EV_MAX
    endfunction

    /* 이벤트 응답 - (다운로드/업로드) 현재 진행량 */
    function JNStashNetGetProgress takes nothing returns integer
        return EV_PROGRESS
    endfunction
    
    /* 이벤트 응답 - 다운로드된 스태쉬 */
    function JNStashNetGetStash takes nothing returns stash
        return EV_STASH
    endfunction

endlibrary
