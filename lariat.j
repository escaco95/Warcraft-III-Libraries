/*
  래리엇트(사슬) 라이브러리입니다.
  기존 워크래프트의 라이트닝 효과를 대체합니다.
  
  기본 기능
  local lariat myFx = lariat.create( 사슬 종류, 시야 체크, X, Y, X2, Y2 )
  local lariat myFx = lariat.createEx( 사슬 종류, 시야 체크, X, Y, Z, X2, Y2, Z2 )
  set myFx.R = 50 // 빨간 색조 0~255 사이로 설정
  set myFx.G = 50 // 초록 색조 0~255 사이로 설정
  set myFx.B = 50 // 파랑 색조 0~255 사이로 설정
  set myFx.A = 50 // 투명도 0~255 사이로 설정
  set myFx.A = myFx.A - 10 // RGBA값을 불러와 상대적으로 변경할 수 있음
  call myFx.setSource( X, Y, Z ) // 라이트닝 시작점 이동
  call myFx.setTarget( X2, Y2, Z2 ) // 라이트닝 종료점 이동
  call myFx.destroy() // 라이트닝 파괴
*/

library Lariat
        
    struct lariat

        static string CHAIN_1 = "CLPB"
        static string CHAIN_2 = "CLSB"
        static string DRAIN = "DRAB"
        static string DRAIN_LIFE = "DRAL"
        static string DRAIN_MANA = "DRAM"
        static string FINGER_OF_DEATH = "AFOD"
        static string FORK = "FORK"
        static string HEAL_1 = "HWPB"
        static string HEAL_2 = "HWSB"
        static string ATTACK = "CHIM"
        static string LEASH = "LEAS"
        static string BURN = "MBUR"
        static string FLARE = "MFPB"
        static string LINK = "SPLK"
        
        private lightning L
        private integer r
        private integer g
        private integer b
        private integer a
        private boolean v
        integer data1
        integer data2
        private real sx
        private real sy
        private real sz
        private real tx
        private real ty
        private real tz
        
        static method create takes string c, boolean cvis, real x, real y, real fx, real fy returns thistype
            local thistype this = thistype.allocate(  )
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
            set data1 = 0
            set data2 = 0
            set L = AddLightning( c, v, x, y, tx, ty )
            return this
        endmethod
        static method createEx takes string c, boolean cvis, real x, real y, real z, real fx, real fy, real fz returns thistype
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
            set data1 = 0
            set data2 = 0
            set L = AddLightningEx( c, v, x, y, z, tx, ty, tz )
            return this
        endmethod
        
        method operator super takes nothing returns lightning
            return L
        endmethod
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
            call SetLightningColor( L, r / 255.00, g / 255.00, b / 255.00, a / 255.00 )
        endmethod
        method operator G= takes integer c returns nothing
            set g = c
            call SetLightningColor( L, r / 255.00, g / 255.00, b / 255.00, a / 255.00 )
        endmethod
        method operator B= takes integer c returns nothing
            set b = c
            call SetLightningColor( L, r / 255.00, g / 255.00, b / 255.00, a / 255.00 )
        endmethod
        method operator A= takes integer c returns nothing
            set a = c
            call SetLightningColor( L, r / 255.00, g / 255.00, b / 255.00, a / 255.00 )
        endmethod
        
        method setSource takes real x, real y, real z returns nothing
            set sx = x
            set sy = y
            set sz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        
        method setTarget takes real x, real y, real z returns nothing
            set tx = x
            set ty = y
            set tz = z
            call MoveLightningEx( L, v, sx, sy, sz, tx, ty, tz )
        endmethod
        
        method onDestroy takes nothing returns nothing
            call DestroyLightning( L )
            set L = null
        endmethod
    endstruct
    
endlibrary

