# == Schema Information
#
# Table name: wikis
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  title        :string(255)
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#  rating_count :integer
#  rating_total :decimal(, )
#  rating_avg   :decimal(10, 2)
#

require 'test_helper'

class WikiTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
