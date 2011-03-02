# == Schema Information
#
# Table name: contests
#
#  id           :integer         not null, primary key
#  title        :string(255)     not null
#  description  :text            not null
#  prize        :string(255)
#  sponsor      :text
#  photo_id     :integer
#  date_from    :date
#  date_to      :date
#  is_completed :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

require 'test_helper'

class ContestTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
