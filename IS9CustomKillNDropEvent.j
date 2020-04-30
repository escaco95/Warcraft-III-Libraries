//*****************************************************************
// Custom Kill N Drop System
//
//  call TriggerRegisterAnyUnitDropEvent( 함수 )
//  call TriggerRegisterUnitTypeDropEvent( 원시코드, '함수' )
//*****************************************************************
library IS9CustomKillNDropEvent initializer OnMapLoad
    //=============================================================
    private struct CONFIG extends array
        //---------------------------------------------------------
        // 설정 - 반드시 처치자가 존재해야 함
        // 자살할 경우 아이템을 드랍하지 않습니다.
        static constant boolean MUST_HAVE_KILLER = true
        //---------------------------------------------------------
    endstruct
    //=============================================================
    globals
        private hashtable TABLE = InitHashtable()
        private key E_DROP_TYPE
        private trigger E_DROP_ANY = CreateTrigger()
    endglobals
    //=============================================================
    function TriggerRegisterAnyUnitDropEvent takes code c returns triggercondition
        return TriggerAddCondition(E_DROP_ANY,Condition(c))
    endfunction
    function TriggerRegisterUnitTypeDropEvent takes integer id, code c returns triggercondition
        if not HaveSavedHandle(TABLE,E_DROP_TYPE,id) then
            call SaveTriggerHandle(TABLE,E_DROP_TYPE,id,CreateTrigger())
        endif
        return TriggerAddCondition(LoadTriggerHandle(TABLE,E_DROP_TYPE,id),Condition(c))
    endfunction
    //=============================================================
    private function OnAnyUnitKilled takes nothing returns nothing
        call TriggerEvaluate(E_DROP_ANY)
        call TriggerEvaluate(LoadTriggerHandle(TABLE,E_DROP_TYPE,GetUnitTypeId(GetTriggerUnit())))
    endfunction
    //=============================================================
    private function KillerCondition takes nothing returns boolean
        return GetKillingUnit() != null
    endfunction
    //=============================================================
    private function OnMapLoad takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerAddAction(t,function OnAnyUnitKilled)
        static if CONFIG.MUST_HAVE_KILLER then
            call TriggerAddCondition(t,Condition(function KillerCondition))
        endif
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_DEATH)
        set t = null
    endfunction
    //=============================================================
endlibrary
//*****************************************************************
