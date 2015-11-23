library Tick
    struct tick
        private static integer MAX = 0
        private static hashtable H = InitHashtable(  )
        private timer T
        integer data
        static method operator count takes nothing returns integer
            return MAX
        endmethod
        static method getExpired takes nothing returns thistype
            return LoadInteger( H, 0, GetHandleId(GetExpiredTimer()) )
        endmethod
        static method create takes integer userData returns thistype
            local thistype this = thistype.allocate(  )
            local integer i = this
            set MAX = MAX + 1
            if .T == null then
                set .T = CreateTimer(  )
                call SaveInteger( H, 0, GetHandleId(T), this )
            endif
            set .data = userData
            return this
        endmethod
        method operator super takes nothing returns timer
            return .T
        endmethod
        method operator elapsed takes nothing returns real
            return TimerGetElapsed( .T )
        endmethod
        method operator remaining takes nothing returns real
            return TimerGetRemaining( .T )
        endmethod
        method operator timeout takes nothing returns real
            return TimerGetTimeout( .T )
        endmethod
        method pause takes nothing returns nothing
            call PauseTimer( .T )
        endmethod
        method resume takes nothing returns nothing
            call ResumeTimer( .T )
        endmethod
        method start takes real r, boolean flag, code c returns nothing
            call TimerStart( .T, r, flag, c )
        endmethod
        method destroy takes nothing returns nothing
            set MAX = MAX - 1
            call PauseTimer( .T )
            call thistype.deallocate( this )
        endmethod
    endstruct
endlibrary
