class CompetitionConstraint
  def self.matches?(request)
    self.standalone_or_phase_request?(request) &&
    self.tag_is_valid?(request) &&
    self.order_is_valid?(request) &&
    self.pagination?(request)
  end

  def self.standalone_or_phase_request?(request)
    return true if request.path_parameters[:phase].nil?
    Competition::PHASES.include? request.path_parameters[:phase].try(:to_sym)
  end

  def self.tag_is_valid?(request)
    return true if request.path_parameters[:tag_id].nil?
    request.path_parameters[:tag_id].match(/\d+/)
  end

  def self.order_is_valid?(request)
    return true if request.path_parameters[:order].nil?
    Competition::ORDERS.include? request.path_parameters[:order]
  end

  def self.pagination?(request)
    return true if request.path_parameters[:page].nil?
    request.path_parameters[:page].match(/\d+/)
  end
end
