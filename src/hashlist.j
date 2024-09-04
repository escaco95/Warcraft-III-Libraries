// ---
// # HashList 라이브러리
//
// > 이 라이브러리는 해시테이블을 기반으로 한 '키, 값' 쌍을 저장할 수 있는 자료구조입니다. 
// > 간단한 해시테이블 기능을 누리면서, 인덱스를 통한 데이터 조회가 필요한 경우에 사용할 수 있습니다.
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [hashlist.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/hashlist.j)
//
// ## 버전
// - **Version**: 20240902.0
//
// ## Changelog
// - **2024-09-04**: 초기 릴리스. 해시리스트 생성, 파괴, 조회, 삽입, 제거 기능 포함.
//
// ## 주요 기능:
// - **해시리스트 생성**: 새로운 해시리스트를 생성하고 관리.
// - **해시리스트 파괴**: 특정 해시리스트의 메모리를 해제.
// - **키로 값 조회**: 주어진 키를 통해 값을 빠르게 조회.
// - **키 존재 여부 확인**: 해시리스트 내에 특정 키가 존재하는지 확인.
// - **값 삽입**: 주어진 키에 해당하는 값을 저장 또는 갱신.
// - **값 제거**: 주어진 키에 해당하는 값을 제거.
// ---
library hashlist

    globals
        private integer lastHashListIndex = 0
    endglobals

    private function allocate takes nothing returns integer
        set lastHashListIndex = lastHashListIndex + 1
        return lastHashListIndex
    endfunction

    globals
        private hashtable META_TABLE = InitHashtable()
        private constant integer META_KEY_SIZE = 1

        private hashtable INDEX_KEY = InitHashtable()
        private hashtable INDEX_VALUE = InitHashtable()
        private hashtable KEY_INDEX = InitHashtable()
        private hashtable KEY_VALUE = InitHashtable()
    endglobals

    // ## 해시리스트
    // 해시테이블 기반의 `키, 값` 쌍을 저장할 수 있는 자료구조입니다.
    // ### 장점
    // - 인덱스로 키, 값 조회 가능
    // - 8192개 이상 생성 가능
    // ### 단점
    // - 정수만 저장 가능
    // - 단일 키 구조 (해시테이블은 부모키, 자식키)
    // - 내용물 순서 보장 안 됨
    struct hashlist extends array
    endstruct

    globals
        // ## 해시리스트 - 마지막으로 생성된 해시리스트
        hashlist bj_lastCreatedHashlist = 0
    endglobals

    // ## 해시리스트 - 해시리스트 생성
    // 새로운 해시리스트를 생성하고 초기화합니다.
    function HashlistCreate takes nothing returns hashlist
        set bj_lastCreatedHashlist = allocate()
        call SaveInteger( META_TABLE, bj_lastCreatedHashlist, META_KEY_SIZE, 0 )
        return bj_lastCreatedHashlist
    endfunction

    // ## 해시리스트 - 해시리스트 파괴
    // 주어진 해시리스트의 모든 데이터를 삭제하고 메모리를 해제합니다.
    function HashlistDestroy takes hashlist hlist returns nothing
        call FlushChildHashtable( META_TABLE, hlist )
        call FlushChildHashtable( INDEX_KEY, hlist )
        call FlushChildHashtable( INDEX_VALUE, hlist )
        call FlushChildHashtable( KEY_INDEX, hlist )
        call FlushChildHashtable( KEY_VALUE, hlist )
    endfunction

    // ## 해시리스트 - 해시리스트 초기화 (모든 값 제거)
    // 주어진 해시리스트의 모든 값을 제거하여 초기 상태로 되돌립니다.
    function HashlistClear takes hashlist hlist returns nothing
        call FlushChildHashtable( INDEX_KEY, hlist )
        call FlushChildHashtable( INDEX_VALUE, hlist )
        call FlushChildHashtable( KEY_INDEX, hlist )
        call FlushChildHashtable( KEY_VALUE, hlist )
        call SaveInteger( META_TABLE, hlist, META_KEY_SIZE, 0 )
    endfunction

    // ## 해시리스트 - 키 조회 (인덱스)
    // 주어진 인덱스에 해당하는 키를 반환합니다.
    function HashlistKeyAt takes hashlist hlist, integer index returns integer
        return LoadInteger( INDEX_KEY, hlist, index )
    endfunction

    // ## 해시리스트 - 값 조회 (인덱스)
    // 주어진 인덱스에 해당하는 값을 반환합니다.
    function HashlistValueAt takes hashlist hlist, integer index returns integer
        return LoadInteger( INDEX_VALUE, hlist, index )
    endfunction

    // ## 해시리스트 - 값 조회 (키)
    // 주어진 키에 해당하는 값을 반환합니다.
    function HashlistGet takes hashlist hlist, integer key returns integer
        return LoadInteger( KEY_VALUE, hlist, key )
    endfunction

    // ## 해시리스트 - 키 존재 여부 확인
    // 해시리스트에 주어진 키가 존재하는지 확인합니다.
    function HashlistContains takes hashlist hlist, integer key returns boolean
        return HaveSavedInteger( KEY_INDEX, hlist, key )
    endfunction

    // ## 해시리스트 - 지정한 키에 값 저장
    // 주어진 키에 값을 저장하거나, 기존 값을 갱신합니다.
    function HashlistPut takes hashlist hlist, integer key, integer value returns nothing
        local integer index
        if HaveSavedInteger( KEY_INDEX, hlist, key ) then
            set index = LoadInteger( KEY_INDEX, hlist, key )
            call SaveInteger( KEY_VALUE, hlist, key, value )
            call SaveInteger( INDEX_VALUE, hlist, index, value )
            return
        endif
        set index = LoadInteger( META_TABLE, hlist, META_KEY_SIZE )
        call SaveInteger( META_TABLE, hlist, META_KEY_SIZE, index + 1 )
        call SaveInteger( INDEX_KEY, hlist, index, key )
        call SaveInteger( INDEX_VALUE, hlist, index, value )
        call SaveInteger( KEY_INDEX, hlist, key, index )
        call SaveInteger( KEY_VALUE, hlist, key, value )
    endfunction

    // ## 해시리스트 - 저장한 키에 저장된 값 가산
    // 주어진 키에 저장된 값을 가산합니다.
    function HashlistAdd takes hashlist hlist, integer key, integer delta returns nothing
        call HashlistPut( hlist, key, LoadInteger( KEY_VALUE, hlist, key ) + delta )
    endfunction

    // ## 해시리스트 - 값 제거 (키)
    // 주어진 키에 해당하는 값을 제거합니다. 성공 여부를 반환합니다.
    function HashlistRemove takes hashlist hlist, integer key returns boolean
        local integer index
        local integer lastIndex
        if not HaveSavedInteger( KEY_INDEX, hlist, key ) then
            return false
        endif
        set index = LoadInteger( KEY_INDEX, hlist, key )
        set lastIndex = LoadInteger( META_TABLE, hlist, META_KEY_SIZE ) - 1
        if index != lastIndex then
            call SaveInteger( INDEX_KEY, hlist, index, LoadInteger( INDEX_KEY, hlist, lastIndex ) )
            call SaveInteger( INDEX_VALUE, hlist, index, LoadInteger( INDEX_VALUE, hlist, lastIndex ) )
            call SaveInteger( KEY_INDEX, hlist, LoadInteger( INDEX_KEY, hlist, lastIndex ), index )
        endif
        call SaveInteger( META_TABLE, hlist, META_KEY_SIZE, lastIndex )
        call RemoveSavedInteger( INDEX_KEY, hlist, lastIndex )
        call RemoveSavedInteger( INDEX_VALUE, hlist, lastIndex )
        call RemoveSavedInteger( KEY_INDEX, hlist, key )
        call RemoveSavedInteger( KEY_VALUE, hlist, key )
        return true
    endfunction

    // ## 해시리스트 - 값 제거 (인덱스)
    // 주어진 인덱스에 해당하는 값을 제거합니다. 성공 여부를 반환합니다.
    function HashlistRemoveAt takes hashlist hlist, integer index returns boolean
        local integer key
        local integer lastIndex = LoadInteger( META_TABLE, hlist, META_KEY_SIZE ) - 1
        if index < 0 or index > lastIndex then
            return false
        endif
        set key = LoadInteger( INDEX_KEY, hlist, index )
        if index != lastIndex then
            call SaveInteger( INDEX_KEY, hlist, index, LoadInteger( INDEX_KEY, hlist, lastIndex ) )
            call SaveInteger( INDEX_VALUE, hlist, index, LoadInteger( INDEX_VALUE, hlist, lastIndex ) )
            call SaveInteger( KEY_INDEX, hlist, LoadInteger( INDEX_KEY, hlist, lastIndex ), index )
        endif
        call SaveInteger( META_TABLE, hlist, META_KEY_SIZE, lastIndex )
        call RemoveSavedInteger( INDEX_KEY, hlist, lastIndex )
        call RemoveSavedInteger( INDEX_VALUE, hlist, lastIndex )
        call RemoveSavedInteger( KEY_INDEX, hlist, key )
        call RemoveSavedInteger( KEY_VALUE, hlist, key )
        return true
    endfunction

    // ## 해시리스트 - 무작위 인덱스 반환
    function HashlistRandomIndex takes hashlist hlist returns integer
        local integer size = LoadInteger( META_TABLE, hlist, META_KEY_SIZE )
        if size == 0 then
            return -1
        endif
        return GetRandomInt( 0, size - 1 )
    endfunction

endlibrary
