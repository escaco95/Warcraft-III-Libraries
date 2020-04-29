
//*****************************************************************
library ItemPriorityGroup requires CustomItemEvent
    //=============================================================
    globals
        private hashtable TABLE = InitHashtable()
        private key K_PARENT
        private key K_PRIORITY
        
        private key T_EXISTENCE
        private key T_ITEM
        private key T_PRIORITY
    endglobals
    //=============================================================
    struct ItemPriorityGroup extends array
        //---------------------------------------------------------
        static method Set /*
            */ takes integer itemTypeId, integer parentTypeId, integer priority /*
            */ returns nothing
            call SaveInteger(TABLE,K_PARENT,itemTypeId,parentTypeId)
            call SaveInteger(TABLE,K_PRIORITY,itemTypeId,priority)
        endmethod
        //---------------------------------------------------------
        static method Check takes unit u, integer callbackEventId returns nothing
            local hashtable h = InitHashtable()
            local integer smax = 0
            local integer array sids
            local integer i = 0
            local integer imax = UnitInventorySize(u)
            local item t
            local integer CType
            local integer CPrior
            local integer PType
            local integer PPrior
            loop
                exitwhen i >= imax
                set t = UnitItemInSlot(u,i)
                if t != null then
                    set CType = GetItemTypeId(t)
                    if HaveSavedInteger(TABLE,K_PRIORITY,CType) then
                        set CPrior = LoadInteger(TABLE,K_PRIORITY,CType)
                        set PType = LoadInteger(TABLE,K_PARENT,CType)
                    else
                        set CPrior = 0
                        set PType = CType
                    endif
                    if not HaveSavedBoolean(h,T_EXISTENCE,PType) then
                        set sids[smax] = PType
                        set smax = smax + 1
                        call SaveBoolean(h,T_EXISTENCE,PType,true)
                        call SaveItemHandle(h,T_ITEM,PType,t)
                        call SaveInteger(h,T_PRIORITY,PType,CPrior)
                    endif
                    set PPrior = LoadInteger(h,T_PRIORITY,PType)
                    if CPrior > PPrior then
                        call SaveItemHandle(h,T_ITEM,PType,t)
                        call SaveInteger(h,T_PRIORITY,PType,CPrior)
                    endif
                endif
                set i = i + 1
            endloop
            set i = 0
            loop
                exitwhen i >= smax
                set t = LoadItemHandle(h,T_ITEM,sids[i])
                call CustomItemEvent.Fire(callbackEventId,u,t)
                set i = i + 1
            endloop
            set t = null
            call FlushParentHashtable(h)
            set h = null
        endmethod
        //---------------------------------------------------------
    endstruct
    //=============================================================
endlibrary
//*****************************************************************
