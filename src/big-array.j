// ---
// # Big Array 라이브러리
//
// > 이 라이브러리는 0~8191 범위의 정수를 인덱스로 사용하는 기존 배열을 대체하는 라이브러리입니다.
// > 정수에 해당하는 어떤 값이라도 인덱스로 사용할 수 있으며, 하나의 배열 안에 다양한 데이터 형식을 저장할 수 있습니다.
// > 내부적으로 하나의 해시 테이블을 나누어 사용하므로, 255개 제한의 부담 없이 기능을 사용할 수 있습니다.
// > `BigArrayFlush` 함수를 통해 메모리를 해제할 수 있습니다. 
//
// ## 작성자
// - **Name**: 동동주
// - **Mail**: escaco95@naver.com
// - **GitHub**: [big-array.j](https://github.com/escaco95/Warcraft-III-Libraries/blob/release/src/big-array.j)
//
// ## 버전
// - **Version**: 20241213.0
//
// ## Changelog
// - **2024-12-13**: 초기 릴리스. 기본적인 입출력 기능 포함.
// ---
library bigarray

    globals
        private hashtable ARRAY_TABLE = InitHashtable()
        private integer LAST_INDEX = 0
    endglobals

    private function allocate takes nothing returns integer
        set LAST_INDEX = LAST_INDEX + 1
        return LAST_INDEX
    endfunction

    // ## 거대 배열
    // 정수라면 어떤 값이든 인덱스로 사용할 수 있는 거대 배열입니다.
    struct bigarray extends array
    endstruct

    // ## 거대 배열 - 거대 배열 생성
    // 새로운 거대 배열을 생성하고 초기화합니다.
    function BigArray takes nothing returns bigarray
        return allocate()
    endfunction

    // ## 거대 배열 - 메모리 해제
    // (거대 배열)의 내용을 초기화하여 메모리를 해제합니다.
    // 메모리를 해제한 후에도 해당 배열을 다시 사용할 수 있습니다.
    function BigArrayFlush takes bigarray this returns nothing
        call FlushChildHashtable(ARRAY_TABLE, this)
    endfunction

    //! runtextmacro BIGARRAY_GETTER_SETTER( "integer", "Struct", "Integer" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "integer", "Int", "Integer" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "real", "Real", "Real" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "string", "Str", "Str" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "boolean", "Bool", "Boolean" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "player", "Player", "PlayerHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "widget", "Widget", "WidgetHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "destructable", "Destructable", "DestructableHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "item", "Item", "ItemHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "unit", "Unit", "UnitHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "ability", "Ability", "AbilityHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "timer", "Timer", "TimerHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "trigger", "Trigger", "TriggerHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "triggercondition", "TriggerCondition", "TriggerConditionHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "triggeraction", "TriggerAction", "TriggerActionHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "event", "Event", "TriggerEventHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "force", "Force", "ForceHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "group", "Group", "GroupHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "location", "Location", "LocationHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "rect", "Rect", "RectHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "boolexpr", "BoolExpr", "BooleanExprHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "sound", "Sound", "SoundHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "effect", "Effect", "EffectHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "unitpool", "UnitPool", "UnitPoolHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "itempool", "ItemPool", "ItemPoolHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "quest", "Quest", "QuestHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "questitem", "QuestItem", "QuestItemHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "defeatcondition", "DefeatCondition", "DefeatConditionHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "timerdialog", "TimerDialog", "TimerDialogHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "leaderboard", "Leaderboard", "LeaderboardHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "multiboard", "Multiboard", "MultiboardHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "multiboarditem", "MultiboardItem", "MultiboardItemHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "trackable", "Trackable", "TrackableHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "dialog", "Dialog", "DialogHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "button", "Button", "ButtonHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "texttag", "TextTag", "TextTagHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "lightning", "Lightning", "LightningHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "image", "Image", "ImageHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "ubersplat", "Ubersplat", "UbersplatHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "region", "Region", "RegionHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "fogstate", "FogState", "FogStateHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "fogmodifier", "FogModifier", "FogModifierHandle" )
    //! runtextmacro BIGARRAY_GETTER_SETTER( "hashtable", "Hashtable", "HashtableHandle" )

endlibrary

//! textmacro BIGARRAY_GETTER_SETTER takes TYPE, INTERFACE, CALLER
    // ## 거대 배열 - $INTERFACE$ 값 저장
    // (거대 배열)의 (인덱스) 번호에 $INTERFACE$ (값)을 저장합니다.
    function BigArraySet$INTERFACE$ takes bigarray this, integer index, $TYPE$ value returns nothing
        call Save$CALLER$(ARRAY_TABLE, this, index, value)
    endfunction

    // ## 거대 배열 - $INTERFACE$ 값 가져오기
    // (거대 배열)의 (인덱스) 번호에 저장된 $INTERFACE$ 값을 가져옵니다.
    function BigArrayGet$INTERFACE$ takes bigarray this, integer index returns $TYPE$
        return Load$CALLER$(ARRAY_TABLE, this, index)
    endfunction
//! endtextmacro
