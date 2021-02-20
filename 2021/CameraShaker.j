library CameraShaker initializer onInit

    globals
        private timer CS_T
        private integer CS_U
        private real CS_S
    endglobals
    
    private function Shake takes nothing returns nothing
        local integer i = GetPlayerId(GetLocalPlayer())
        set CS_U = CS_U * -1
        call SetCameraField( CAMERA_FIELD_ZOFFSET, CS_S * CS_U, 0.00 )
        set CS_S = CS_S - CS_S / 5
    endfunction
    
    private function onInit takes nothing returns nothing
        set CS_T = CreateTimer()
        set CS_U = 1
        set CS_S = 0
        call TimerStart(CS_T, 0.04, true, function Shake)
    endfunction
    
    struct CameraShaker extends array
        static method setShakeForPlayer takes player p, real v returns nothing
            if GetLocalPlayer() == p then
                if CS_S < v then
                    set CS_S = v
                endif
            endif
        endmethod
        static method setShake takes real v returns nothing
            if CS_S < v then
                set CS_S = v
            endif
        endmethod
        static method stopShake takes nothing returns nothing
            set CS_S = 0
        endmethod
        static method stopShakeForPlayer takes player p returns nothing
            if GetLocalPlayer() == p then
                set CS_S = 0
            endif
        endmethod
        static method setShakePosition takes real v, real x, real y, real r, real d returns nothing
            local real dx = x - GetCameraTargetPositionX()
            local real dy = y - GetCameraTargetPositionY()
            local real dist = SquareRoot( dx * dx + dy * dy ) - r
            if dist <= 0 then
                set dist = 1
            else
                if d - r <= 0 then
                    set dist = 0
                else
                    set dist = 1 - ( dist / (d - r) )
                    if dist <= 0 then
                        set dist = 0
                    endif
                endif
            endif
            set CS_S = v * dist
        endmethod
    endstruct
    
endlibrary
