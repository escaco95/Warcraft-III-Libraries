/*
  [랜덤 객체]
    
    local random 랜덤 = random.create( 초기 시드 )
    
    랜덤.pick() -> 0~32767
    
    랜덤.destroy()
    
    랜덤.seed
    
*/
library Random

    globals
        private integer array F
        private integer array S
    endglobals

    struct random
        static method create takes integer seed returns thistype
            local integer this = thistype.allocate()
            set F[this] = seed
            set S[this] = seed
            return this
        endmethod
        method operator seed takes nothing returns integer
            return F[this]
        endmethod
        method pick takes nothing returns integer
            set S[this] = S[this] * 1103515245 + 12345
            return ModuloInteger(S[this] / 65536, 32768)
        endmethod
        method destroy takes nothing returns nothing
            call thistype.deallocate(this)
        endmethod
    endstruct

endlibrary

