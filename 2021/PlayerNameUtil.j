library PlayerNameUtil initializer main
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
//  PNU(Player Name Util) By 동동주
//  2021.02.16
//
//
//  GetPlayerDefaultName(player whichPlayer)
//  GetPlayerDefaultNameById(integer playerId)
//
//
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
globals
    private string array PLAYER_NAME_DEFAULT
    private string array PLAYER_NAME_COLOR
endglobals
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
private function main takes nothing returns nothing
    local integer i = 0
    set PLAYER_NAME_COLOR[0] = "|cffff0303"
    set PLAYER_NAME_COLOR[1] = "|cff0042ff"
    set PLAYER_NAME_COLOR[2] = "|cff1ce6b9"
    set PLAYER_NAME_COLOR[3] = "|cff540081"
    set PLAYER_NAME_COLOR[4] = "|cfffffc00"
    set PLAYER_NAME_COLOR[5] = "|cfffe8a0e"
    set PLAYER_NAME_COLOR[6] = "|cff20c000"
    set PLAYER_NAME_COLOR[7] = "|cffe55bb0"
    set PLAYER_NAME_COLOR[8] = "|cff959697"
    set PLAYER_NAME_COLOR[9] = "|cff7ebff1"
    set PLAYER_NAME_COLOR[10] = "|cff106246"
    set PLAYER_NAME_COLOR[11] = "|cff4a2a04"
    set PLAYER_NAME_COLOR[12] = "|cff9b0000"
    set PLAYER_NAME_COLOR[13] = "|cff0000c3"
    set PLAYER_NAME_COLOR[14] = "|cff00eaff"
    set PLAYER_NAME_COLOR[15] = "|cffbe00fe"
    set PLAYER_NAME_COLOR[16] = "|cffebcd87"
    set PLAYER_NAME_COLOR[17] = "|cfff8a48b"
    set PLAYER_NAME_COLOR[18] = "|cffbfff80"
    set PLAYER_NAME_COLOR[19] = "|cffdcb9eb"
    set PLAYER_NAME_COLOR[20] = "|cff282828"
    set PLAYER_NAME_COLOR[21] = "|cffebf0ff"
    set PLAYER_NAME_COLOR[22] = "|cff00781e"
    set PLAYER_NAME_COLOR[23] = "|cffa46f33"
    loop
        exitwhen i == bj_MAX_PLAYER_SLOTS
        set PLAYER_NAME_DEFAULT[i] = GetPlayerName(Player(i))
        set i = i + 1
    endloop
endfunction
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
function GetPlayerDefaultName takes player p returns string
    return PLAYER_NAME_DEFAULT[GetPlayerId(p)]
endfunction
function GetPlayerDefaultNameById takes integer id returns string
    return PLAYER_NAME_DEFAULT[id]
endfunction
//··············································································
function GetPlayerNameColor takes player p returns string
    return PLAYER_NAME_COLOR[GetPlayerId(p)]
endfunction
function GetPlayerNameColorById takes integer id returns string
    return PLAYER_NAME_COLOR[id]
endfunction
//··············································································
function GetPlayerNameColored takes player p returns string
    return PLAYER_NAME_COLOR[GetPlayerId(p)] + GetPlayerName(p) + "|r"
endfunction
function GetPlayerNameColoredById takes integer id returns string
    return PLAYER_NAME_COLOR[id] + GetPlayerName(Player(id)) + "|r"
endfunction
//■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
endlibrary
