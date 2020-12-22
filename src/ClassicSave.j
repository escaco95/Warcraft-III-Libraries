//==============================================================================
//! textmacro SaveCode takes NAME,ID,CHARSET
private struct $NAME$ extends array
    static constant string CHARSET = "$CHARSET$"
    static integer ARGS = 0
    static integer array ARGMAX
    static integer array ARG
    static constant integer MAX_PARITY = 5
endstruct

function Save$NAME$ takes player p, string pn returns string
    local integer pid = GetPlayerId(p)
    local ClassicSaveCode cd = ClassicSaveCode.create($NAME$.CHARSET)
    local string s
    local integer i = 0
    local integer parity = GetRandomInt(1,$NAME$.MAX_PARITY)
    call cd.Encode(parity,$NAME$.MAX_PARITY)
    loop
        exitwhen i == $NAME$.ARGS
        call cd.Encode($NAME$.ARG[pid*$NAME$.ARGS+i],$NAME$.ARGMAX[i])
        set i = i + 1
    endloop
    call cd.Encode(parity,$NAME$.MAX_PARITY)
    set s = cd.Save(pn,$ID$)
    call cd.destroy()
    return s
endfunction

function Load$NAME$ takes player p, string pn, string s returns boolean
    local integer pid = GetPlayerId(p)
    local ClassicSaveCode cd = ClassicSaveCode.create($NAME$.CHARSET)
    local boolean b = cd.Load(pn,s,$ID$)
    local integer i = $NAME$.ARGS - 1
    local integer parity
    if b then
        set parity = cd.Decode($NAME$.MAX_PARITY)
        if parity < 1 then
            set b = false
        endif
        loop
            exitwhen i < 0
            set $NAME$.ARG[pid*$NAME$.ARGS+i] = cd.Decode($NAME$.ARGMAX[i])
            set i = i - 1
        endloop
        if cd.Decode($NAME$.MAX_PARITY) != parity then
            set b = false
        endif
    endif
    call cd.destroy()
    return b
endfunction

function Clear$NAME$ takes player p returns nothing
    local integer pid = GetPlayerId(p)
    local integer i = 0
    loop
        exitwhen i == $NAME$.ARGS
        set $NAME$.ARG[pid*$NAME$.ARGS+i] = 0
        set i = i + 1
    endloop
endfunction
//! endtextmacro
//! textmacro SaveCodeData takes NAME,ARG,MAXIMUM
private struct $NAME$$ARG$ extends array
    static integer ARGIDX
    private static method onInit takes nothing returns nothing
        local integer i = 0
        set ARGIDX = $NAME$.ARGS
        set $NAME$.ARGMAX[ARGIDX] = $MAXIMUM$
        set $NAME$.ARGS = $NAME$.ARGS + 1
        debug call DisplayTextToPlayer(GetLocalPlayer(),0,0,"[$NAME$:$ARG$] record "+I2S(ARGIDX)+" max "+I2S($MAXIMUM$))
    endmethod
endstruct
function Set$NAME$$ARG$ takes player p, integer v returns nothing
    set $NAME$.ARG[GetPlayerId(p)*$NAME$.ARGS+$NAME$$ARG$.ARGIDX] = v
endfunction
function Get$NAME$$ARG$ takes player p returns integer
    return $NAME$.ARG[GetPlayerId(p)*$NAME$.ARGS+$NAME$$ARG$.ARGIDX]
endfunction
//! endtextmacro
//==============================================================================
// Legacy (Obsolete)
library ClassicSaveColorizer
    private constant function uppercolor takes nothing returns string
        return "|cffff0000"
    endfunction
    private constant function lowercolor takes nothing returns string
        return "|cff00ff00"
    endfunction
    private constant function numcolor takes nothing returns string
        return "|cff0000ff"
    endfunction

    private function isupper takes string c returns boolean
        return c == StringCase(c,true)
    endfunction

    private function ischar takes string c returns boolean
        return S2I(c) == 0 and c!= "0"
    endfunction

    private function chartype takes string c returns integer
        if(ischar(c)) then
            if isupper(c) then
                return 0
            else
                return 1
            endif
        else
            return 2
        endif
    endfunction

    public function Colorize takes string s returns string
     local string out = ""
     local integer i = 0
     local integer len = StringLength(s)
     local integer ctype
     local string c
     loop
      exitwhen i >= len
      set c = SubString(s,i,i+1)
      set ctype = chartype(c)
      if ctype == 0 then
       set out = out + uppercolor()+c+"|r"
      elseif ctype == 1 then
       set out = out + lowercolor()+c+"|r"
      else
       set out = out + numcolor()+c+"|r"
      endif
      set i = i + 1
     endloop
     return out
    endfunction
    
endlibrary
//==============================================================================
library ClassicSaveTest initializer RunTests
    private function interface proposition takes nothing returns boolean
    public function Closeto takes real x, real y returns boolean
        return RAbsBJ(x - y) <= 0.001
    endfunction
    private function prop_Closeto takes nothing returns boolean
        return Closeto(1,1) and Closeto(1,1.0005) and not Closeto(0,1)
    endfunction
    public function DebugMsg takes string s returns nothing
        call BJDebugMsg(s)
        call Cheat("DebugMsg: "+s)
    endfunction  
    public function Assert takes string name, proposition t returns nothing
        if t.evaluate() then
            //call BJDebugMsg("|cff00ff00"+"OK  "+"|r"+name)
            //call Cheat("DebugMsg: OK   "+name)
        else
            call DebugMsg("|cffff0000"+"Failed  "+"|r"+name)
            call Cheat("DebugMsg: Failed  "+name)
        endif
    endfunction
    private function RunTests takes nothing returns nothing
        debug local string n = "SelfTest "
        debug call ClassicSaveTest_Assert(n+"Closeto",proposition.prop_Closeto)
    endfunction
endlibrary
//==============================================================================
library ClassicSave initializer RunTests requires ClassicSaveTest
//prefer algebraic approach because of real subtraction issues
    private function log takes real y, real base returns real
        local real x
        local real factor = 1.0
        local real logy = 0.0
        local real sign = 1.0
        if(y < 0.) then
            return 0.0
        endif
        if(y < 1.) then
            set y = 1.0/y
            set sign = -1.0
        endif
        //Chop out powers of the base
        loop
            exitwhen y < 1.0001    //decrease this ( bounded below by 1) to improve precision
            if(y > base) then
                set y = y / base
                set logy = logy + factor
            else
                set base = SquareRoot(base)     //If you use just one base a lot, precompute its squareroots
                set factor = factor / 2.
            endif
        endloop
        return sign*logy
    endfunction

    private function prop_Log takes nothing returns boolean
        if not ClassicSaveTest_Closeto(log(10,10),1) then
            return false
        elseif not ClassicSaveTest_Closeto(log(10,2.7182818),2.302585) then
            return false
        elseif not ClassicSaveTest_Closeto(log(0.5,10),-0.30103) then
            return false
        endif
        return true
    endfunction

    private struct BigNum_l
        integer leaf
        BigNum_l next
        debug static integer nalloc = 0

        static method create takes nothing returns BigNum_l
            local BigNum_l bl = BigNum_l.allocate()
            set bl.next = 0
            set bl.leaf = 0
            debug set BigNum_l.nalloc = BigNum_l.nalloc + 1
            return bl
        endmethod

        method onDestroy takes nothing returns nothing
            debug set BigNum_l.nalloc = BigNum_l.nalloc - 1
        endmethod

        //true:  want destroy
        method Clean takes nothing returns boolean
            if .next == 0 and .leaf == 0 then
                return true
            elseif .next != 0 and .next.Clean() then
                call .next.destroy()
                set .next = 0
                return .leaf == 0
            else
                return false
            endif
        endmethod
        
 method DivSmall takes integer base, integer denom returns integer
  local integer quotient
  local integer remainder = 0
  local integer num
  
  if .next != 0 then
   set remainder = .next.DivSmall(base,denom)
  endif
  
        set num = .leaf + remainder*base
  set quotient = num/denom
  set remainder = num - quotient*denom
  set .leaf = quotient
  return remainder
 endmethod
endstruct

private struct BigNum
 BigNum_l list
    integer base
    
    static method create takes integer base returns BigNum
        local BigNum b = BigNum.allocate()
        set b.list = 0
        set b.base = base
        return b
    endmethod

 method onDestroy takes nothing returns nothing
  local BigNum_l cur = .list
  local BigNum_l next
  loop
   exitwhen cur == 0
   set next = cur.next
   call cur.destroy()
   set cur = next
  endloop
 endmethod
 
 method IsZero takes nothing returns boolean
  local BigNum_l cur = .list
  loop
   exitwhen cur == 0
   if cur.leaf != 0 then
    return false
   endif
   set cur = cur.next
  endloop
  return true
 endmethod
 
 method Dump takes nothing returns nothing
  local BigNum_l cur = .list
  local string s = ""
  loop
   exitwhen cur == 0
   set s = I2S(cur.leaf)+" "+s
   set cur = cur.next
  endloop
  call BJDebugMsg(s)
 endmethod
 
 method Clean takes nothing returns nothing
  local BigNum_l cur = .list
  call cur.Clean()
 endmethod
 
 //fails if bignum is null
 //BASE() + carry must be less than MAXINT()
 method AddSmall takes integer carry returns nothing
  local BigNum_l next
  local BigNum_l cur = .list
  local integer sum
  
  if cur == 0 then
   set cur = BigNum_l.create()
   set .list = cur
  endif
  
  loop
   exitwhen carry == 0
   set sum = cur.leaf + carry
   set carry = sum / .base
   set sum = sum - carry*.base
   set cur.leaf = sum
   
   if cur.next == 0 then
    set cur.next = BigNum_l.create()
   endif
   set cur = cur.next
  endloop
 endmethod
 
 //x*BASE() must be less than MAXINT()
 method MulSmall takes integer x returns nothing
  local BigNum_l cur = .list
  local integer product
  local integer remainder
  local integer carry = 0
  loop
   exitwhen cur == 0 and carry == 0
   set product = x * cur.leaf + carry
   set carry = product/.base
   set remainder = product - carry*.base
   set cur.leaf = remainder
   if cur.next == 0 and carry != 0 then
    set cur.next = BigNum_l.create()
   endif
   set cur = cur.next
  endloop
 endmethod
 
 //Returns remainder
 method DivSmall takes integer denom returns integer
  return .list.DivSmall(.base,denom)
 endmethod
 
 method LastDigit takes nothing returns integer
  local BigNum_l cur = .list
  local BigNum_l next
  loop
   set next = cur.next
   exitwhen next == 0
   set cur = next
  endloop
  return cur.leaf
 endmethod
endstruct

    private function prop_Allocator1 takes nothing returns boolean
        local BigNum b1
        local BigNum b2
        set b1 = BigNum.create(37)
        call b1.destroy()
        set b2 = BigNum.create(37)
        call b2.destroy()
        return b1 == b2
    endfunction

    private function prop_Allocator2 takes nothing returns boolean
        local BigNum b1
        local boolean b = false
        set b1 = BigNum.create(37)
        call b1.AddSmall(17)
        call b1.MulSmall(19)
        debug if BigNum_l.nalloc < 1 then
        debug     return false
        debug endif
        call b1.destroy()
        debug set b = BigNum_l.nalloc == 0
        return b
    endfunction

    private function prop_Arith takes nothing returns boolean
        local BigNum b1
        set b1 = BigNum.create(37)
        call b1.AddSmall(73)
        call b1.MulSmall(39)
        call b1.AddSmall(17)
        //n = 2864
        if b1.DivSmall(100) != 64 then
            return false
        elseif b1.DivSmall(7) != 0 then
            return false
        elseif b1.IsZero() then
            return false
        elseif b1.DivSmall(3) != 1 then
            return false
        elseif b1.DivSmall(3) != 1 then
            return false
        elseif not b1.IsZero() then
            return false
        endif
        return true
    endfunction

    private function RunTests takes nothing returns nothing
        debug local string n = "BigNum "
        debug call ClassicSaveTest_Assert(n+"Log",proposition.prop_Log)
        debug call ClassicSaveTest_Assert(n+"Allocator1",proposition.prop_Allocator1)
        debug call ClassicSaveTest_Assert(n+"Allocator2",proposition.prop_Allocator2)
        debug call ClassicSaveTest_Assert(n+"Arithmetic",proposition.prop_Arith)
    endfunction
    
    
//library Savecode requires BigNum
    globals
        private string CHARSET = "0123456789"
    endglobals
//Colorize colors
    private function player_charset takes nothing returns string
        return CHARSET
    endfunction
    private function player_charsetlen takes nothing returns integer
        return StringLength(CHARSET)
    endfunction

    private function charset takes nothing returns string
        return CHARSET
    endfunction
    private function charsetlen takes nothing returns integer
        return StringLength(CHARSET)
    endfunction
    
    private function BASE takes nothing returns integer
     return charsetlen()
    endfunction

    private constant function HASHN takes nothing returns integer
     return 5000  //1./HASHN() is the probability of a random code being valid
    endfunction

    private constant function MAXINT takes nothing returns integer
     return 2147483647
    endfunction

    private function player_chartoi takes string c returns integer
     local integer i = 0
     local string cs = player_charset()
     local integer len = player_charsetlen()
     loop
      exitwhen i>=len or c == SubString(cs,i,i+1)
      set i = i + 1
     endloop
     return i
    endfunction

    private function chartoi takes string c returns integer
     local integer i = 0
     local string cs = charset()
     local integer len = charsetlen()
     loop
      exitwhen i>=len or c == SubString(cs,i,i+1)
      set i = i + 1
     endloop
     return i
    endfunction

    private function itochar takes integer i returns string
     return SubString(charset(),i,i+1)
    endfunction

    private function modb takes integer x returns integer
     if x >= BASE() then
      return x - BASE()
     elseif x < 0 then
      return x + BASE()
     else
      return x
     endif
    endfunction

    struct ClassicSaveCode
        string charsets
        real digits  //logarithmic approximation
        BigNum bignum
 
        static method create takes string chs returns thistype
            local thistype sc = thistype.allocate()
            set sc.charsets = chs
            set sc.digits = 0.
            set CHARSET = sc.charsets
            set sc.bignum = BigNum.create(BASE())
            return sc
        endmethod

        method onDestroy takes nothing returns nothing
            call .bignum.destroy()
        endmethod

        method Encode takes integer val, integer max returns nothing
            set .digits = .digits + log(max+1,BASE())
            call .bignum.MulSmall(max+1)
            call .bignum.AddSmall(val)
        endmethod

        method Decode takes integer max returns integer
            return .bignum.DivSmall(max+1)
        endmethod

        method IsEmpty takes nothing returns boolean
            return .bignum.IsZero()
        endmethod

        method Length takes nothing returns real
            return .digits
        endmethod

        method Clean takes nothing returns nothing
            call .bignum.Clean()
        endmethod

        //These functions get too intimate with BigNum_l
        method Pad takes nothing returns nothing
            local BigNum_l cur = .bignum.list
            local BigNum_l prev
            local integer maxlen = R2I(1.0 + .Length())

            loop
            exitwhen cur == 0
            set prev = cur
            set cur = cur.next
            set maxlen = maxlen - 1
            endloop
            loop
            exitwhen maxlen <= 0
            set prev.next = BigNum_l.create()
            set prev = prev.next
            set maxlen = maxlen - 1
            endloop
        endmethod

        method ToString takes nothing returns string
            local BigNum_l cur = .bignum.list
            local string s = ""
            loop
            exitwhen cur == 0
            set s = itochar(cur.leaf) + s
            set cur = cur.next
            endloop
            return s
        endmethod

        method FromString takes string s returns nothing
            local integer i = StringLength(s)-1
            local BigNum_l cur = BigNum_l.create()
            set .bignum.list = cur
            loop
            set cur.leaf = chartoi(SubString(s,i,i+1))  
            exitwhen i <= 0
            set cur.next = BigNum_l.create()
            set cur = cur.next
            set i = i - 1
            endloop
        endmethod

        method Hash takes nothing returns integer
            local integer hash = 0
            local integer x
            local BigNum_l cur = .bignum.list
            loop
            exitwhen cur == 0
            set x = cur.leaf
            set hash = ModuloInteger(hash+79*hash/(x+1) + 293*x/(1+hash - (hash/BASE())*BASE()) + 479,HASHN())
            set cur = cur.next
            endloop
            return hash
        endmethod

        //this is not cryptographic which is fine for this application
        //sign = 1 is forward
        //sign = -1 is backward
        method Obfuscate takes integer key, integer sign returns nothing
            local integer seed = GetRandomInt(0,MAXINT())
            local integer advance
            local integer x
            local BigNum_l cur = .bignum.list

            if sign == -1 then
            call SetRandomSeed(.bignum.LastDigit())
            set cur.leaf = modb(cur.leaf + sign*GetRandomInt(0,BASE()-1))
            set x = cur.leaf
            endif

            call SetRandomSeed(key)
            loop
            exitwhen cur == 0
            if sign == -1 then
            set advance = cur.leaf
            endif
            set cur.leaf = modb(cur.leaf + sign*GetRandomInt(0,BASE()-1))
            if sign == 1 then
            set advance = cur.leaf
            endif
            set advance = advance + GetRandomInt(0,BASE()-1)
            call SetRandomSeed(advance)

            set x = cur.leaf
            set cur = cur.next
            endloop

            if sign == 1 then
            call SetRandomSeed(x)
            set .bignum.list.leaf = modb(.bignum.list.leaf + sign*GetRandomInt(0,BASE()-1))
            endif

            call SetRandomSeed(seed)
        endmethod

        method Dump takes nothing returns nothing
            local BigNum_l cur = .bignum.list
            local string s = ""
            set s = "max: "+R2S(.digits)

            loop
                exitwhen cur == 0
                set s = I2S(cur.leaf)+" "+s
                set cur = cur.next
            endloop
            call BJDebugMsg(s)
        endmethod

        method Save takes string p, integer loadtype returns string
            local integer key = StringHash(p)+loadtype*73
            local string s
            local integer hash

            call .Clean()
            set hash = .Hash()
            call .Encode(hash,HASHN())
            call .Clean()

            /////////////////////// Save code information.  Comment out next two lines in implementation
            //debug call BJDebugMsg("Expected length: " +I2S(R2I(1.0+.Length())))
            //debug call BJDebugMsg("Room left in last char: "+R2S(1.-ModuloReal((.Length()),1)))
            ///////////////////////

            call .Pad()
            call .Obfuscate(key,1)
            return .ToString()
        endmethod

        method Load takes string ps, string s, integer loadtype returns boolean
            local integer ikey = StringHash(ps)+loadtype*73
            local integer inputhash

            call .FromString(s)
            call .Obfuscate(ikey,-1)
            set inputhash = .Decode(HASHN())
            call .Clean()
            return inputhash == .Hash()
        endmethod
    endstruct

endlibrary
//==============================================================================
