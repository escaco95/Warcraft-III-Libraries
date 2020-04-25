//*****************************************************************
// 래리엇트(사슬) 라이브러리
//     Version 2.1
/*
  기존 워크래프트의 라이트닝 효과를 대체합니다.
  
  기본 기능
  local Lariat myFx = Lariat.Create( 사슬 종류, 시야 체크, X, Y, X2, Y2 )
  local Lariat myFx = Lariat.CreateEx( 사슬 종류, 시야 체크, X, Y, Z, X2, Y2, Z2 )
  set myFx.R = 50 // 빨간 색조 0~255 사이로 설정
  set myFx.G = 50 // 초록 색조 0~255 사이로 설정
  set myFx.B = 50 // 파랑 색조 0~255 사이로 설정
  set myFx.A = 50 // 투명도 0~255 사이로 설정
  set myFx.A = myFx.A - 10 // RGBA값을 불러와 상대적으로 변경할 수 있음
  call myFx.SetSource( X, Y, Z ) // 라이트닝 시작점 이동
  call myFx.SetTarget( X2, Y2, Z2 ) // 라이트닝 종료점 이동
  call myFx.Destroy() // 라이트닝 파괴
*/
//*****************************************************************
library Lariat
    //=============================================================
    globals
        private integer COUNT = 0
    endglobals
    //=============================================================
    struct Lariat
        //---------------------------------------------------------
        // 사슬 - 체인 라이트닝 ( 강함 )
        static string CHAIN_1 = "CLPB"
        // 사슬 - 체인 라이트닝 ( 약함, 후속타 )
        static string CHAIN_2 = "CLSB"
        // 사슬 - 체력 / 마나 드레인
        static string DRAIN = "DRAB"
        // 사슬 - 체력 드레인
        static string DRAIN_LIFE = "DRAL"
        // 사슬 - 마나 드레인
        static string DRAIN_MANA = "DRAM"
        // 사슬 - 핑거 오브 데스 ( 붉은 체인 라이트닝 )
        static string FINGER_OF_DEATH = "AFOD"
        // 사슬 - 포크 라이트닝
        static string FORK = "FORK"
        // 사슬 - 힐링 웨이브 ( 강함 )
        static string HEAL_1 = "HWPB"
        // 사슬 - 힐링 웨이브 ( 약함, 후속타 )
        static string HEAL_2 = "HWSB"
        // 사술 - 키메라 공격 ( 라이트닝 )
        static string CHIMERA_ATTACK = "CHIM"
        // 사슬 - 에어리얼 쉐클
        static string SHACKLE = "LEAS"
        // 사슬 - 마나 번
        static string MANA_BURN = "MBUR"
        // 사슬 - 마나 플레어
        static string MANA_FLARE = "MFPB"
        // 사슬 - 스피릿 링크
        static string SPIRIT_LINK = "SPLK"
        //---------------------------------------------------------
        private lightning L
        private integer r
        private integer g
        private integer b
        private integer a
        private boolean v
        integer DataA
        integer DataB
        private real sx
        private real sy
        private real sz
        private real tx
        private real ty
        private real tz
        //---------------------------------------------------------
        static method operator Count takes nothing returns integer
            return COUNT
        endmethod
        //---------------------------------------------------------
        static method Create takes string c, boolean cvis, real x, real y, real fx, real fy returns thistype
            local thistype this = thistype.allocate(  )
            set COUNT = COUNT + 1
            set sx = x
            set sy = y
            set sz = 0
            set tx = fx
            set ty = fy
            set tz = 0
            set v = cvis
            set r = 255
            set g = 255
            set b = 255
            set a = 255
            set DataA = 0
            set DataB = 0
            set L = AddLightning( c, v, x, y, tx, ty )
            return this
        endmethod
        static method CreateEx takes string c, boolean cvis, real x, real y, real z, real fx, real fy, real fz returns thistype
            local thistype this = thistype.allocate(  )
            set sx = x
            set sy = y
            set sz = z
            set tx = fx
            set ty = fy
            set tz = fz
            set v = cvis
            set r = 255
            set g = 255
            set b = 255
            set a = 255
            set DataA = 0
            set DataB = 0
            set L = AddLightningEx( c, v, x, y, z, tx, ty, tz )
            return this
        endmethod
        //---------------------------------------------------------
        method operator Base takes nothing returns lightning
            return L
        endmethod
        //---------------------------------------------------------
        method operator R takes nothing returns integer
            return r
        endmethod
        method operator G takes nothing returns integer
            return g
        endmethod
        method operator B takes nothing returns integer
            return b
        endmethod
        method operator A takes nothing returns integer
            return a
        endmethod
        method operator R= takes integer c returns nothing
            set r = c
            call SetLightningColor( L, r / 255.0, g / 255.0, b / 255.0, a / 255.0 )
        endmethod
        method operator G= takes integer c returns nothing
            set g = c
            call SetLightningColor( L, r / 255.0, g / 255.0, b / 255.0, a / 255.0 )
        endmethod
        method operator B= takes integer c returns nothing
            set b = c
            call SetLightningColor( L, r / 255.0, g / 255.0, b / 255.0, a / 255.0 )
        endmethod
        method operator A= takes integer c returns nothing
            set a = c
            call SetLightningColor( L, r / 255.0, g / 255.0, b / 255.0, a / 255.0 )
        endmethod
        //---------------------------------------------------------
        method SetColor takes integer cr, integer cg, integer cb, integer ca returns nothing
            set r = cr
            set g = cg
            set b = cb
            set a = ca
            call SetLightningColor( L, r / 255.0, g / 255.0, b / 255.0, a / 255.0 )
        endmethod
        method SetRealColor takes real cr, real cg, real cb, real ca returns nothing
            set r = R2I(cr*255)
            set g = R2I(cg*255)
            set b = R2I(cb*255)
            set a = R2I(ca*255)
            call SetLightningColor( L, cr, cg, cb, ca )
        endmethod
        //---------------------------------------------------------
        method SetSource takes real x, real y, real z returns nothing
            set sx = x
            set sy = y
            set sz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        method SetTarget takes real x, real y, real z returns nothing
            set tx = x
            set ty = y
            set tz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        //---------------------------------------------------------
        method SetSourceUnitZ takes unit u, real z returns nothing
            set sx = GetUnitX(u)
            set sy = GetUnitY(u)
            set sz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        method SetTargetUnitZ takes unit u, real z returns nothing
            set tx = GetUnitX(u)
            set ty = GetUnitY(u)
            set tz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        //---------------------------------------------------------
        method Destroy takes nothing returns nothing
            call DestroyLightning( L )
            set L = null
            call deallocate()
            set COUNT = COUNT - 1
        endmethod
    endstruct
    //=============================================================
endlibrary
//*****************************************************************
