module RequestHelpers
  def test_request
    ActionController::TestRequest.new
  end
end

RSpec.configure do |c|
  c.include RequestHelpers
end
