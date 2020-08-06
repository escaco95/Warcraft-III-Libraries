library AutoLoader

    globals
        private boolean BS_ERROR = false
    endglobals

    private function I2BSP takes integer i returns string
        local string s = ""
        local integer temp
        
        loop
            exitwhen i == 0
            set temp = i / 2
            if ( i - temp * 2 ) == 0 then
                set s = "0" + s
            else
                set s = "1" + s
            endif
            set i = temp
        endloop
        
        set i = StringLength(s)
        set s = "00000000000000000000000000000000" + s
        set s = SubString(s,i,StringLength(s))
        
        return s
    endfunction
    
    private function I2BSM takes integer i returns string
        local string s = ""
        local integer temp
        
        loop
            exitwhen i == 0
            set temp = i / 2 
            if ( i - ( temp * 2 ) ) == 0 then
                set s = "1" + s
            else
                set s = "0" + s
            endif
            set i = temp
        endloop
        
        set i = StringLength(s)
        set s = "11111111111111111111111111111111" + s
        set s = SubString(s,i,StringLength(s))
        
        return s
    endfunction

    function I2BS takes integer i returns string
        if i >= 0 or i == -2147483648 then
            return I2BSP(i)
        else
            return I2BSM(i + 1)
        endif
    endfunction
    
    private function BSP2I takes string s returns integer
        local integer i = 31
        local string ch
        local integer init = 1
        local integer sum = 0
        
        loop
            exitwhen i < 0
            set ch = SubString(s,i,i+1)
            if ch == "1" then
                set sum = sum + init
            elseif ch == "0" then
                /* IS NORMAL */
            else
                set BS_ERROR = true
                return 0
            endif
            set init = init * 2
            set i = i - 1
        endloop
        
        return sum
    endfunction
    
    private function BSM2I takes string s returns integer
        local integer i = 31
        local string ch
        local integer init = -1
        local integer sum = -1
        
        loop
            exitwhen i < 0
            set ch = SubString(s,i,i+1)
            if ch == "0" then
                set sum = sum + init
            elseif ch == "1" then
                /* IS NORMAL */
            else
                set BS_ERROR = true
                return 0
            endif
            set init = init * 2
            set i = i - 1
        endloop
        
        return sum
    endfunction
    
    function BS2I takes string s returns integer
        if StringLength(s) != 32 then
            set BS_ERROR = true
            return 0
        endif
        if SubString(s,0,1) == "0" then
            return BSP2I(s)
        else
            return BSM2I(s)
        endif
    endfunction

endlibrary
