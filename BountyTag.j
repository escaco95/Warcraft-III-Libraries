/*
  오브젝트 현상금이 아닌, 트리거 현상금을 사용할 때 현상금 텍스트와 이펙트를 쉽게 표시하기 위한 라이브러리입니다.
  이 라이브러리의 원본이 되는 라이브러리는
  TEXT TAG - Floating text system by Cohadar - v5.0
  입니다.
  
  //주의 : 실제로 보상금이 주어지지는 않습니다! 텍스트와 이펙트 표시용입니다!
  call bountyTag.gold( 플레이어, X, Y, 보상금 )
  call bountyTag.lumber( 플레이어, X, Y, 보상금 )
  
  [특징과 사용 예시]
  call bountyTag.gold( null, X, Y, 보상금 ) // 이렇게 입력하면 모든 플레이어에게 다 보여집니다
  call bountyTag.gold( Player(0), X, Y, 보상금 ) // 이렇게 작성하면 1플레이어에게만 현상금 이펙트가 보여집니다
*/

library BountyTag

    globals    
        // for custom centered texttags
        private constant real MEAN_CHAR_WIDTH = 5.5
        private constant real MAX_TEXT_SHIFT = 200.0
        private constant real DEFAULT_HEIGHT = 16.0

        // for default texttags
        private constant real   SIGN_SHIFT = 16.0
        private constant real   FONT_SIZE = 0.024
    endglobals

    struct bountyTag extends array
        static method gold takes player killer, real x, real y, integer bounty returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(bounty)
            local string feedback = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, x-SIGN_SHIFT, y, 0.0)
            call SetTextTagColor(tt, 255, 220, 0, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==killer or killer == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            if GetLocalPlayer() != killer and killer != null then
                set feedback = ""
            endif
            call DestroyEffect( AddSpecialEffect( feedback, x, y ) )
            set text = null
            set tt = null
        endmethod
        static method lumber takes player killer, real x, real y, integer bounty returns nothing
            local texttag tt = CreateTextTag()
            local string text = "+" + I2S(bounty)
            call SetTextTagText(tt, text, FONT_SIZE)
            call SetTextTagPos(tt, x-SIGN_SHIFT, y, 0.0)
            call SetTextTagColor(tt, 0, 200, 80, 255)
            call SetTextTagVelocity(tt, 0.0, 0.03)
            call SetTextTagVisibility(tt, GetLocalPlayer()==killer or killer == null)
            call SetTextTagFadepoint(tt, 2.0)
            call SetTextTagLifespan(tt, 3.0)
            call SetTextTagPermanent(tt, false)
            set text = null
            set tt = null
        endmethod
    endstruct

endlibrary
