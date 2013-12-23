module CompetitionsHelper

  def remaining_days_countdown_in phase
    if @competition.current_phase == phase
      days = @competition.remaining_days_in_current_phase
      if days == 1
        content_tag("p", Time.now.day_countdown, :class => "qtd day_countdown") +
        content_tag("p", "restantes", :class => "sobre")
      else
        content_tag("p", days, :class => "qtd") +
        content_tag("p", "dias restantes", :class => "sobre")
      end
    end
  end

  def phase_over_or_current?(competition, phase)
    return false unless competition.current_phase
    competition.phase_over?(phase) or competition.current_phase == phase
  end
end
