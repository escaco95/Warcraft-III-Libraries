//*****************************************************************
// Custom Item Events
//*****************************************************************
library CustomItemEvent
    //=============================================================
    globals
        private hashtable TABLE = InitHashtable()
        private unit P_UNIT = null
        private item P_ITEM = null
    endglobals
    //=============================================================
    struct CustomItemEvent extends array
        //---------------------------------------------------------
        static method GetTriggerUnit takes nothing returns unit
            return P_UNIT
        endmethod
        static method GetTriggerItem takes nothing returns item
            return P_ITEM
        endmethod
        //---------------------------------------------------------
        static method Fire takes integer eventId, unit u, item t returns boolean
            local unit pu = P_UNIT
            local item pt = P_ITEM
            local boolean result
            set P_UNIT = u
            set P_ITEM = t
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE,eventId,GetItemTypeId(t)))
            set P_UNIT = pu
            set P_ITEM = pt
            set pu = null
            set pt = null
            return result
        endmethod
        //---------------------------------------------------------
        static method Register /*
            */ takes integer eventId, integer itemTypeId, code itemAction /*
            */ returns triggercondition
            if not HaveSavedHandle(TABLE,eventId,itemTypeId) then
                call SaveTriggerHandle(TABLE,eventId,itemTypeId,CreateTrigger())
            endif
            return TriggerAddCondition( /*
                */ LoadTriggerHandle(TABLE,eventId,itemTypeId), /*
                */ Condition(itemAction))
        endmethod
        //---------------------------------------------------------
        static method Remove /*
            */ takes integer eventId, integer itemTypeId, triggercondition itemAction /*
            */ returns nothing
            call TriggerRemoveCondition( /*
                */ LoadTriggerHandle(TABLE,eventId,itemTypeId), /*
                */ itemAction)
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
endlibrary
//*****************************************************************
