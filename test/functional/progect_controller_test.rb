require File.dirname(__FILE__) + '/../test_helper'
require 'progect_controller'

# Re-raise errors caught by the controller.
class ProgectController; def rescue_action(e) raise e end; end

class ProgectControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProgectController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
