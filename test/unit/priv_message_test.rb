# == Schema Information
#
# Table name: priv_messages
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  to_user_id :integer         not null
#  title      :text            not null
#  data       :text
#  read       :boolean
#  created_at :datetime
#

require 'test_helper'

class PrivMessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
