# == Schema Information
#
# Table name: friendships
#
#  id               :integer         not null, primary key
#  user_id          :integer         not null
#  friend_id        :integer         not null
#  xfn_friend       :boolean         not null
#  xfn_acquaintance :boolean         not null
#  xfn_contact      :boolean         not null
#  xfn_met          :boolean         not null
#  xfn_coworker     :boolean         not null
#  xfn_colleague    :boolean         not null
#  xfn_coresident   :boolean         not null
#  xfn_neighbor     :boolean         not null
#  xfn_child        :boolean         not null
#  xfn_parent       :boolean         not null
#  xfn_sibling      :boolean         not null
#  xfn_spouse       :boolean         not null
#  xfn_kin          :boolean         not null
#  xfn_muse         :boolean         not null
#  xfn_crush        :boolean         not null
#  xfn_date         :boolean         not null
#  xfn_sweetheart   :boolean         not null
#  created_at       :datetime
#  updated_at       :datetime
#

require 'test_helper'

class FriendshipTest < Test::Unit::TestCase
  fixtures :users
  def setup
    @user = users(:users_001)
    @friend = users(:friend)
  end
  def test_request
    Friendship.request(@user, @friend)
    assert Friendship.exists?(@user, @friend)
    assert_status @user, @friend, 'pending'
    assert_status @friend, @user, 'requested'
  end
  def test_accept
    Friendship.request(@user, @friend)
    Friendship.accept(@user, @friend)
    assert Friendship.exists?(@user, @friend)
    assert_status @user, @friend, 'accepted'
    assert_status @friend, @user, 'accepted'
  end
  def test_breakup
    Friendship.request(@user, @friend)
    Friendship.breakup(@user, @friend)
    assert !Friendship.exists?(@user, @friend)
  end
  private
  # Verify the existence of a friendship with the given status.
  def assert_status(user, friend, status)
    friendship = Friendship.find_by_user_id_and_friend_id(user, friend)
    assert_equal status, friendship.status
  end
end
