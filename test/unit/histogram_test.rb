# == Schema Information
#
# Table name: histograms
#
#  id         :integer         not null, primary key
#  photo_id   :integer
#  r          :integer         default(0)
#  g          :integer         default(0)
#  b          :integer         default(0)
#  y          :integer         default(0)
#  u          :integer         default(0)
#  v          :integer         default(0)
#  count      :integer         default(0)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class HistogramTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
