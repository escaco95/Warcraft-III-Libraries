/**
 *  Angle Distance Polar.j
 *
 *  Copyright (c) escaco95@naver.com
 *  Distributed under the BSD License, Version 201206.3
 */
library CustomEvent
    globals
        private hashtable TABLE = InitHashtable()

        private integer P_E1 = 0
        private integer P_E2 = 0
        private player P_P = null
        private unit P_U = null
        private item P_T = null
        private integer P_I = 0
    endglobals

    struct MonoEvent extends array
        static method operator Event takes nothing returns integer
            return P_E1
        endmethod
        static method operator Player takes nothing returns player
            return P_P
        endmethod
        static method operator Unit takes nothing returns unit
            return P_U
        endmethod
        static method operator Item takes nothing returns item
            return P_T
        endmethod
        static method operator Integer takes nothing returns integer
            return P_I
        endmethod
        static method Add takes integer e1, code c returns triggercondition
            if not HaveSavedHandle(TABLE,e1,0) then
                call SaveTriggerHandle(TABLE,e1,0,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(TABLE,e1,0),Condition(c))
        endmethod
        static method Fire takes integer e, player p, unit u, item t, integer i returns boolean
            local integer pe1 = P_E1
            local integer pe2 = P_E2
            local player pp = P_P
            local unit pu = P_U
            local item pt = P_T
            local integer pi = P_I
            local boolean result
            set P_E1 = e
            set P_E2 = 0
            set P_P = p
            set P_U = u
            set P_T = t
            set P_I = i
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE,e,0))
            set P_E1 = pe1
            set P_E2 = pe2
            set P_P = pp
            set P_U = pu
            set P_T = pt
            set P_I = pi
            set pp = null
            set pu = null
            set pt = null
            return result
        endmethod
    endstruct

    struct DuoEvent extends array
        static method operator Event1 takes nothing returns integer
            return P_E1
        endmethod
        static method operator Event2 takes nothing returns integer
            return P_E2
        endmethod
        static method operator Player takes nothing returns player
            return P_P
        endmethod
        static method operator Unit takes nothing returns unit
            return P_U
        endmethod
        static method operator Item takes nothing returns item
            return P_T
        endmethod
        static method operator Integer takes nothing returns integer
            return P_I
        endmethod
        static method Add takes integer e1, integer e2, code c returns triggercondition 
            if not HaveSavedHandle(TABLE,e1,e2) then
                call SaveTriggerHandle(TABLE,e1,e2,CreateTrigger())
            endif
            return TriggerAddCondition(LoadTriggerHandle(TABLE,e1,e2),Condition(c))
        endmethod
        static method Fire takes integer e1, integer e2, player p, unit u, item t, integer i returns boolean
            local integer pe1 = P_E1
            local integer pe2 = P_E2
            local player pp = P_P
            local unit pu = P_U
            local item pt = P_T
            local integer pi = P_I
            local boolean result
            set P_E1 = e1
            set P_E2 = e2
            set P_P = p
            set P_U = u
            set P_T = t
            set P_I = i
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE,e1,0))
            set result = TriggerEvaluate(LoadTriggerHandle(TABLE,e1,e2))
            set P_E1 = pe1
            set P_E2 = pe2
            set P_P = pp
            set P_U = pu
            set P_T = pt
            set P_I = pi
            set pp = null
            set pu = null
            set pt = null
            return result
        endmethod
    endstruct

endlibrary
