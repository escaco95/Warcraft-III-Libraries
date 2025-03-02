// ---
// ## 📚 vJass 라이브러리
// > ### vJass 라이브러리는 Jass 언어의 기능을 확장하고 보완합니다
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [vjass.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/vjass.j)
//
// ## 버전
// - **Version**: 20250302.0
//
// ## Changelog
// - **2025-03-02**: debug 조건 제거, 오류 메시지 표시 시간 변경
// ---
library vjass

    // ##### 💬 키워드 하이라이팅 목적의 구조체 선언
    struct vjass extends array
    endstruct

    // ##### 💬 키워드 하이라이팅 목적의 구조체 선언
    struct NULL extends array
    endstruct

    globals
        // ---
        // ## 💎 상수 - 구조체 NULL
        // > ### 아무 구조체의 NULL 값 비교 및 할당에 사용할 수 있는 상수입니다
        // ---
        constant integer NULL = 0
    endglobals

    // ---
    // ## 👤 유닛 - 제거 여부
    // > ### [유닛](<unit whichUnit>)의 제거 여부를 응답합니다
    // ---
    // ##### ℹ️ 이 함수는 null 유닛을 제거 상태로 간주합니다
    // ##### ⚠️ [UnitRemove](<native RemoveUnit takes unit whichUnit returns nothing>) 함수는 유닛을 즉시 제거하지 않으므로, 최소 0초 이상이 지나야 올바르게 확인할 수 있습니다
    // ---
    // takes
    // - unit whichUnit 제거 여부를 확인할 유닛
    // returns
    // - boolean 제거 여부
    // ---
    function IsUnitRemoved takes unit whichUnit returns boolean
        return GetUnitTypeId( whichUnit ) == 0
    endfunction

    // ---
    // ## 👤 유닛 - 생존 여부
    // > ### [유닛](<unit whichUnit>)의 생존 여부를 응답합니다
    // ---
    // ##### ℹ️ 이 함수는 null 유닛을 사망 상태로 간주합니다
    // ##### ℹ️ 이 함수는 제거된 유닛을 사망 상태로 간주합니다
    // ---
    // takes
    // - unit whichUnit 생존 여부를 확인할 유닛
    // returns
    // - boolean 생존 여부
    // ---
    function IsUnitAlive takes unit whichUnit returns boolean
        return GetUnitTypeId( whichUnit ) != 0 and not IsUnitType( whichUnit, UNIT_TYPE_DEAD )
    endfunction

    // ---
    // ## 👤 유닛 - 사망 여부
    // > ### [유닛](<unit whichUnit>)의 사망 여부를 응답합니다
    // ---
    // ##### ℹ️ 이 함수는 null 유닛을 사망 상태로 간주합니다
    // ##### ℹ️ 이 함수는 제거된 유닛을 사망 상태로 간주합니다
    // ---
    // takes
    // - unit whichUnit 사망 여부를 확인할 유닛
    // returns
    // - boolean 사망 여부
    // ---
    function IsUnitDead takes unit whichUnit returns boolean
        return GetUnitTypeId( whichUnit ) == 0 or IsUnitType( whichUnit, UNIT_TYPE_DEAD )
    endfunction

    // ---
    // ## 🔄 변환 - 실수를 문자열로
    // > ### [실수](<real r>)를 정수로 변환한 후 문자열로 변환합니다
    // ---
    // takes
    // - real r 문자열로 변환할 실수
    // returns
    // - string 변환된 문자열
    // ---
    function R2I2S takes real r returns string
        return I2S( R2I( r ) )
    endfunction

    // ---
    // ## ⚡ 실행 - 함수 실행
    // > ### [함수](<code callback>)를 실행합니다
    // ---
    // ##### ℹ️ 이 함수는 ForForce 함수를 이용하여 목표 함수를 실행합니다
    // ##### ℹ️ 이 함수로 실행된 목표 함수는 별도의 연산 한계 스택을 사용합니다
    // ---
    // takes
    // - code callback 실행할 코드 블록
    // returns
    // - nothing
    // ---
    function Execute takes code callback returns nothing
        call ForForce( bj_FORCE_PLAYER[0], callback )
    endfunction

    // ---
    // ## 📝 출력 - 게임 메시지 출력
    // > ### 게임 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 이 함수는 모든 플레이어에게 메시지를 출력합니다
    // ##### ℹ️ 메시지가 표시되는 시간은 메시지 길이에 따라 달라집니다
    // ---
    // takes
    // - string message 출력할 메시지
    // returns
    // - nothing
    // ---
    function Print takes string message returns nothing
        call DisplayTextToPlayer( GetLocalPlayer(), 0, 0, message )
    endfunction

    // ---
    // ## 📝 출력 - 플레이어에게 게임 메시지 출력
    // > ### [플레이어](<player whichPlayer>)에게 게임 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 메시지가 표시되는 시간은 메시지 길이에 따라 달라집니다
    // ---
    // takes
    // - player whichPlayer 대상 플레이어
    // - string message 출력할 메시지
    // returns
    // - nothing
    // ---
    function PrintTo takes player whichPlayer, string message returns nothing
        call DisplayTextToPlayer( whichPlayer, 0, 0, message )
    endfunction

    // ---
    // ## 📝 디버그 출력 - 추적 메시지
    // > ### 디버깅용 추적 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 조건문 분기점, 실행 여부 확인, 변수 값 임시 출력 등에 사용합니다
    // ---
    // takes
    // - string message 출력할 추적용 메시지
    // returns
    // - nothing
    // ---
    function LogTrace takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0, 0, 3600, "|cFF808080[TRACE] " + message )
    endfunction

    // ---
    // ## 📝 디버그 출력 - 정보 메시지
    // > ### 디버깅용 정보 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 함수 실행 결과, 중요 이벤트 발생, 상태 변경 알림 등에 사용합니다
    // ---
    // takes
    // - string message 출력할 정보용 메시지
    // returns
    // - nothing
    // ---
    function LogInfo takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0, 0, 3600, "|cFF4040FF[INFO] " + message )
    endfunction

    // ---
    // ## 📝 디버그 출력 - 경고 메시지
    // > ### 디버깅용 경고 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 잠재적인 오류 발생, 예외 상황 처리, 경고 알림 등에 사용합니다
    // ---
    // takes
    // - string message 출력할 경고용 메시지
    // returns
    // - nothing
    // ---
    function LogWarn takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0, 0, 3600, "|cFFFFA500[WARN] " + message )
    endfunction

    // ---
    // ## 📝 디버그 출력 - 오류 메시지
    // > ### 디버깅용 오류 메시지 [문자열](<string message>)을 출력합니다
    // ---
    // ##### ℹ️ 예외 처리 실패, 오류 발생, 예상치 못한 상황 알림 등에 사용합니다
    // ---
    // takes
    // - string message 출력할 오류용 메시지
    // returns
    // - nothing
    // ---
    function LogError takes string message returns nothing
        call DisplayTimedTextToPlayer( GetLocalPlayer(), 0, 0, 3600, "|cFFFF0000[ERROR] " + message )
    endfunction

endlibrary
