library FixCam initializer main
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FixCam By 동동주
// 2021.02.15
// 
// 시야나 카메라를 설정하고 나서, 플레이어가 마우스휠을 굴리거나, Insert/Delete 키를 누르면
// 카메라 설정이 풀려 되돌아가는 현상. 짜증나셨죠?
//
// 픽스캠 라이브러리는 사용자가 무슨 난리를 쳐도, 제작자가 설정한 카메라 옵션을 변경하지 못하도록
// '고정'할 수 있습니다.
//··············································································
//
// [카메라 고정 액션]
// 픽스캠 - (플레이어)의 카메라를 (카메라 개체)에 고정합니다. [화면 이동 (가능/불가능)]
//      call FixCamSetup( 플레이어, 카메라 개체, 화면 이동 )
//      call FixCamSetupEx( 플레이어, 카메라 개체, 화면 이동, 전환시간 )
// 픽스캠 - (플레이어)의 (카메라 필드)를 (값)으로 고정합니다.
//      call FixCamSetField( 플레이어, 카메라 필드, 값 )
//      call FixCamSetFieldEx( 플레이어, 카메라 필드, 값, 전환시간 )
// 픽스캠 - (플레이어)의 카메라 좌표를 (X), (Y)로 고정합니다.
//      call FixCamSetField( 플레이어, X, Y )
//      call FixCamSetFieldEx( 플레이어, X, Y, 전환시간 )
//
// [고정 해제 액션]
// 픽스캠 - (플레이어)의 카메라 고정 설정을 모두 해제합니다.
//      call FixCamReset( 플레이어 )
// 픽스캠 - (플레이어)의 카메라 고정 설정 중 (필드)만 해제합니다.
//      call FixCamResetField( 플레이어, 필드 )
// 픽스캠 - (플레이어)의 카메라 좌표 고정을 해제합니다.
//      call FixCamResetPosition( 플레이어 )
//
// [기타]
// 픽스캠 - (플레이어)의 카메라 부드러움 (전환시간)을 설정합니다.
//      call FixCamSetEase( 플레이어, 전환시간 )
//
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
globals
    //
    // 시스템 설정
    //
    private constant real SYSTEM_TIMEOUT = 0.03125 /*카메라 고정 간격*/
endglobals
//··············································································
globals
    private constant integer OFFSET = 20
    
    private boolean array FIX
    private real    array VALUE
    private real    array EASE
endglobals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function FixCamReset takes player p returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set FIX[id+ 0] = false /*CAMERA_FIELD_TARGET_DISTANCE*/
    set FIX[id+ 1] = false /*CAMERA_FIELD_FARZ*/
    set FIX[id+ 2] = false /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set FIX[id+ 3] = false /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set FIX[id+ 4] = false /*CAMERA_FIELD_ROLL*/
    set FIX[id+ 5] = false /*CAMERA_FIELD_ROTATION*/
    set FIX[id+ 6] = false /*CAMERA_FIELD_ZOFFSET*/
    set FIX[id+10] = false /*CAMERA_X*/
    set FIX[id+11] = false /*CAMERA_Y*/
    set EASE[id+ 0] = 0.0 /*CAMERA_FIELD_TARGET_DISTANCE*/
    set EASE[id+ 1] = 0.0 /*CAMERA_FIELD_FARZ*/
    set EASE[id+ 2] = 0.0 /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set EASE[id+ 3] = 0.0 /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set EASE[id+ 4] = 0.0 /*CAMERA_FIELD_ROLL*/
    set EASE[id+ 5] = 0.0 /*CAMERA_FIELD_ROTATION*/
    set EASE[id+ 6] = 0.0 /*CAMERA_FIELD_ZOFFSET*/
    set EASE[id+10] = 0.0 /*CAMERA_X*/
    //set EASE[id+11] = 0.0 /*CAMERA_Y*/
endfunction
function FixCamResetField takes player p, camerafield field returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET+GetHandleId(field)
    set FIX[id] = false
    set EASE[id] = 0.0
endfunction
function FixCamResetPosition takes player p returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set FIX[id+10] = false
    //set FIX[id+11] = false
    set EASE[id+10] = 0.0
    //set EASE[id+11] = 0.0
endfunction
//··············································································
function FixCamSetEase takes player p, real ease returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set EASE[id+ 0] = ease /*CAMERA_FIELD_TARGET_DISTANCE*/
    set EASE[id+ 1] = ease /*CAMERA_FIELD_FARZ*/
    set EASE[id+ 2] = ease /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set EASE[id+ 3] = ease /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set EASE[id+ 4] = ease /*CAMERA_FIELD_ROLL*/
    set EASE[id+ 5] = ease /*CAMERA_FIELD_ROTATION*/
    set EASE[id+ 6] = ease /*CAMERA_FIELD_ZOFFSET*/
    set EASE[id+10] = ease /*CAMERA_X*/
    //set EASE[id+11] = ease /*CAMERA_Y*/
endfunction
//··············································································
function FixCamSetup takes player p, camerasetup cam, boolean pan returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    if cam == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set EASE[id+ 0] = 0.0 /*CAMERA_FIELD_TARGET_DISTANCE*/
    set EASE[id+ 1] = 0.0 /*CAMERA_FIELD_FARZ*/
    set EASE[id+ 2] = 0.0 /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set EASE[id+ 3] = 0.0 /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set EASE[id+ 4] = 0.0 /*CAMERA_FIELD_ROLL*/
    set EASE[id+ 5] = 0.0 /*CAMERA_FIELD_ROTATION*/
    set EASE[id+ 6] = 0.0 /*CAMERA_FIELD_ZOFFSET*/
    set VALUE[id+ 0] = CameraSetupGetField(cam,CAMERA_FIELD_TARGET_DISTANCE)
    set VALUE[id+ 1] = CameraSetupGetField(cam,CAMERA_FIELD_FARZ)
    set VALUE[id+ 2] = CameraSetupGetField(cam,CAMERA_FIELD_ANGLE_OF_ATTACK)
    set VALUE[id+ 3] = CameraSetupGetField(cam,CAMERA_FIELD_FIELD_OF_VIEW)
    set VALUE[id+ 4] = CameraSetupGetField(cam,CAMERA_FIELD_ROLL)
    set VALUE[id+ 5] = CameraSetupGetField(cam,CAMERA_FIELD_ROTATION)
    set VALUE[id+ 6] = CameraSetupGetField(cam,CAMERA_FIELD_ZOFFSET)
    set FIX[id+ 0] = true /*CAMERA_FIELD_TARGET_DISTANCE*/
    set FIX[id+ 1] = true /*CAMERA_FIELD_FARZ*/
    set FIX[id+ 2] = true /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set FIX[id+ 3] = true /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set FIX[id+ 4] = true /*CAMERA_FIELD_ROLL*/
    set FIX[id+ 5] = true /*CAMERA_FIELD_ROTATION*/
    set FIX[id+ 6] = true /*CAMERA_FIELD_ZOFFSET*/
    if pan then
        set EASE[id+10] = 0.0 /*CAMERA_X*/
        //set EASE[id+11] = 0.0 /*CAMERA_Y*/
        set VALUE[id+10] = CameraSetupGetDestPositionX(cam)
        set VALUE[id+11] = CameraSetupGetDestPositionY(cam)
        set FIX[id+10] = true /*CAMERA_X*/
        //set FIX[id+11] = true /*CAMERA_Y*/
    endif
endfunction
function FixCamSetupEx takes player p, camerasetup cam, boolean pan, real ease returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    if cam == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set EASE[id+ 0] = ease /*CAMERA_FIELD_TARGET_DISTANCE*/
    set EASE[id+ 1] = ease /*CAMERA_FIELD_FARZ*/
    set EASE[id+ 2] = ease /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set EASE[id+ 3] = ease /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set EASE[id+ 4] = ease /*CAMERA_FIELD_ROLL*/
    set EASE[id+ 5] = ease /*CAMERA_FIELD_ROTATION*/
    set EASE[id+ 6] = ease /*CAMERA_FIELD_ZOFFSET*/
    set VALUE[id+ 0] = CameraSetupGetField(cam,CAMERA_FIELD_TARGET_DISTANCE)
    set VALUE[id+ 1] = CameraSetupGetField(cam,CAMERA_FIELD_FARZ)
    set VALUE[id+ 2] = CameraSetupGetField(cam,CAMERA_FIELD_ANGLE_OF_ATTACK)
    set VALUE[id+ 3] = CameraSetupGetField(cam,CAMERA_FIELD_FIELD_OF_VIEW)
    set VALUE[id+ 4] = CameraSetupGetField(cam,CAMERA_FIELD_ROLL)
    set VALUE[id+ 5] = CameraSetupGetField(cam,CAMERA_FIELD_ROTATION)
    set VALUE[id+ 6] = CameraSetupGetField(cam,CAMERA_FIELD_ZOFFSET)
    set FIX[id+ 0] = true /*CAMERA_FIELD_TARGET_DISTANCE*/
    set FIX[id+ 1] = true /*CAMERA_FIELD_FARZ*/
    set FIX[id+ 2] = true /*CAMERA_FIELD_ANGLE_OF_ATTACK*/
    set FIX[id+ 3] = true /*CAMERA_FIELD_FIELD_OF_VIEW*/
    set FIX[id+ 4] = true /*CAMERA_FIELD_ROLL*/
    set FIX[id+ 5] = true /*CAMERA_FIELD_ROTATION*/
    set FIX[id+ 6] = true /*CAMERA_FIELD_ZOFFSET*/
    if pan then
        set EASE[id+10] = ease /*CAMERA_X*/
        //set EASE[id+11] = ease /*CAMERA_Y*/
        set VALUE[id+10] = CameraSetupGetDestPositionX(cam)
        set VALUE[id+11] = CameraSetupGetDestPositionY(cam)
        set FIX[id+10] = true /*CAMERA_X*/
        //set FIX[id+11] = true /*CAMERA_Y*/
    endif
endfunction
//··············································································
function FixCamSetField takes player p, camerafield field, real value returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET+GetHandleId(field)
    set VALUE[id] = value
    set EASE[id] = 0.0
    set FIX[id] = true
endfunction
function FixCamSetFieldEx takes player p, camerafield field, real value, real ease returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET+GetHandleId(field)
    set VALUE[id] = value
    set EASE[id] = ease
    set FIX[id] = true
endfunction
//··············································································
function FixCamSetPosition takes player p, real x, real y returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set VALUE[id+10] = x
    set VALUE[id+11] = y
    set EASE[id+10] = 0.0
    //set EASE[id+11] = 0.0
    set FIX[id+10] = true
    //set FIX[id+11] = true
endfunction
function FixCamSetPositionEx takes player p, real x, real y, real ease returns nothing
    local integer id
    /*인자 유효성 검사*/
    if p == null then
        return
    endif
    /*실행*/
    set id = GetPlayerId(p)*OFFSET
    set VALUE[id+10] = x
    set VALUE[id+11] = y
    set EASE[id+10] = ease
    //set EASE[id+11] = ease
    set FIX[id+10] = true
    //set FIX[id+11] = true
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
private function AtEnterFrame takes nothing returns nothing
    local integer id = GetPlayerId(GetLocalPlayer())*OFFSET
    if FIX[id+0] then
        call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,VALUE[id+0],EASE[id+0])
    endif
    if FIX[id+1] then
        call SetCameraField(CAMERA_FIELD_FARZ,VALUE[id+1],EASE[id+1])
    endif
    if FIX[id+2] then
        call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK,VALUE[id+2],EASE[id+2])
    endif
    if FIX[id+3] then
        call SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW,VALUE[id+3],EASE[id+3])
    endif
    if FIX[id+4] then
        call SetCameraField(CAMERA_FIELD_ROLL,VALUE[id+4],EASE[id+4])
    endif
    if FIX[id+5] then
        call SetCameraField(CAMERA_FIELD_ROTATION,VALUE[id+5],EASE[id+5])
    endif
    if FIX[id+6] then
        call SetCameraField(CAMERA_FIELD_ZOFFSET,VALUE[id+6],EASE[id+6])
    endif
    if FIX[id+10] then
        call PanCameraToTimed(VALUE[id+10],VALUE[id+11],EASE[id+10])
    endif
endfunction
//··············································································
private function main takes nothing returns nothing
    local trigger t = CreateTrigger()
    call TriggerAddAction(t,function AtEnterFrame)
    call TriggerRegisterTimerEvent(t,SYSTEM_TIMEOUT,true)
    set t = null
endfunction
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
endlibrary
