native UnitAlive takes unit id returns boolean
//===================================================================
library EffectMomoShikiDragon
//-------------------------------------------------------------------
    // 기술 타임라인
    private struct Timeline
        unit Caster
        real X
        real Y
        real Facing
        unit Dummy
        private method OnDestroy takes nothing returns nothing
            set .Caster = null
            set .Dummy = null
        endmethod
        //! runtextmacro Struct2Tick()
    endstruct
//-------------------------------------------------------------------
    // 설정
    private struct Config extends array
        // 그래픽 - 충격파 이펙트 모델 경로
        static method GetImpactEffectModel takes Timeline t returns string
            return "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl"
        endmethod
        // 그래픽 - 더미 유닛 타입
        static method GetDummyType takes Timeline t returns integer
            return 'u000'
        endmethod
        // 판정 - 타격 시점(초)
        static method GetImpactDelay takes Timeline t returns real
            return 1.0
        endmethod
        // 판정 - 타격 범위(128 = 중형 격자 1칸, 512 = 대형 격자 1칸)
        static method GetImpactRadius takes Timeline t returns real
            return 300.0
        endmethod
        // 판정 - 타격 피해 오프셋 거리
        static method GetImpactOffsetDistance takes Timeline t returns real
            return 320.0
        endmethod
        // 수치 - 타격 피해량
        static method GetImpactDamage takes Timeline t returns real
            return 250.0
        endmethod
        // 판정 - 타격 대상 필터링
        static method FilterTarget takes Timeline t, unit dst returns boolean
            if not UnitAlive(dst) then
                return false
            endif
            if IsPlayerAlly(GetOwningPlayer(t.Caster),GetOwningPlayer(dst)) then
                return false
            endif
            return true
        endmethod
        // 액션 - 타격
        static method ImpactTarget takes Timeline t, unit dst returns nothing
            call UnitDamageTarget(t.Caster,dst,GetImpactDamage(t),true,true, /*
            */ ATTACK_TYPE_MELEE, /*
            */ DAMAGE_TYPE_NORMAL, /*
            */ WEAPON_TYPE_WOOD_HEAVY_BASH)
        endmethod
    endstruct
//-------------------------------------------------------------------
    private struct SpellAction extends array
        private static method OnFire takes Timeline t returns nothing
            local group g = CreateGroup()
            local unit u
            call GroupEnumUnitsInRange(g,t.X,t.Y,Config.GetImpactRadius(t),null)
            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                call GroupRemoveUnit(g,u)
                if Config.FilterTarget(t,u) then
                    call Config.ImpactTarget(t,u)
                endif
            endloop
            call DestroyGroup(g)
            set g = null
        endmethod
        private static method AtImpact takes nothing returns nothing
            local Timeline t = Timeline.GetExpired()
            call DestroyEffect(AddSpecialEffect(Config.GetImpactEffectModel(t),t.X,t.Y))
            call OnFire(t)
            call t.Destroy()
        endmethod
        static method Start takes unit src, real x, real y, real f returns nothing
            local Timeline t = Timeline.Create()
            local real dist
            set t.Caster = src
            set t.Facing = f
            set t.Dummy = CreateUnit(GetOwningPlayer(src),Config.GetDummyType(t),x,y,f)
            set dist = Config.GetImpactOffsetDistance(t)
            set t.X = x + dist * Cos(f*bj_DEGTORAD)
            set t.Y = y + dist * Sin(f*bj_DEGTORAD)
            call t.Start(Config.GetImpactDelay(t),false,function thistype.AtImpact)
        endmethod
    endstruct
//-------------------------------------------------------------------
    struct EffectMomoShikiDragon extends array
        // 사망 여부를 무시하고 시전
        static method ForceCast takes unit src, real x, real y, real f returns nothing
            call SpellAction.Start(src,x,y,f)
        endmethod
        // 사망 여부를 확인하고 시전
        static method Cast takes unit src, real x, real y, real f returns nothing
            if not UnitAlive(src) then
                return
            endif
            call SpellAction.Start(src,x,y,f)
        endmethod
    endstruct
//-------------------------------------------------------------------
endlibrary
//===================================================================
library SpellMomoshikiA000
//-------------------------------------------------------------------
    // 기술 타임라인
    private struct Timeline
        unit Caster
        private method OnDestroy takes nothing returns nothing
            set .Caster = null
        endmethod
        //! runtextmacro Struct2Tick()
    endstruct
//-------------------------------------------------------------------
    // 설정
    private struct Config extends array
        // 그래픽 - 더미 소환 개체수
        static method GetDummyAmount takes Timeline t returns integer
            return 3
        endmethod
        // 그래픽 - 최초 더미 소환 간격
        static method GetDummyDistance takes Timeline t returns real
            return 512.0
        endmethod
        // 그래픽 - 더미 소환 각도 오프셋
        static method GetDummyAngleOffset takes Timeline t returns real
            return 0.0
        endmethod
        // 그래픽 - 최초 더미 소환 대기 시간
        static method GetDummyDelay takes Timeline t returns real
            return 0.03125
        endmethod
    endstruct
//-------------------------------------------------------------------
    private struct SpellAction extends array
        private static method OnFire takes Timeline t returns nothing
            local real ox = GetUnitX(t.Caster)
            local real oy = GetUnitY(t.Caster)
            local real facing = GetUnitFacing(t.Caster) + Config.GetDummyAngleOffset(t)
            local real dist = Config.GetDummyDistance(t)
            local integer i = Config.GetDummyAmount(t)
            local real df = 360.0 / i
            local real x
            local real y
            loop
                exitwhen i < 1
                set x = ox + dist * Cos(facing*bj_DEGTORAD)
                set y = oy + dist * Sin(facing*bj_DEGTORAD)
                call EffectMomoShikiDragon.Cast(t.Caster,x,y,facing)
                set facing = facing + df
                set i = i - 1
            endloop
        endmethod
        private static method AtImpact takes nothing returns nothing
            local Timeline t = Timeline.GetExpired()
            if UnitAlive(t.Caster) then
                call OnFire(t)
            endif
            call t.Destroy()
        endmethod
        static method Start takes unit src returns nothing
            local Timeline t = Timeline.Create()
            set t.Caster = src
            call t.Start(Config.GetDummyDelay(t),false,function thistype.AtImpact)
        endmethod
    endstruct
//-------------------------------------------------------------------
    struct SpellMomoshikiA000 extends array
        // 사망 여부를 무시하고 시전
        static method ForceCast takes unit src returns nothing
            call SpellAction.Start(src)
        endmethod
        // 사망 여부를 확인하고 시전
        static method Cast takes unit src returns nothing
            if not UnitAlive(src) then
                return
            endif
            call SpellAction.Start(src)
        endmethod
    endstruct
//-------------------------------------------------------------------
endlibrary
//===================================================================
