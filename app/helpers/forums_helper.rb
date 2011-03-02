module ForumsHelper

  def last_post(post_id)
    post=Message.find(post_id)
    # id | parent_id | user_id | forum_id | name | message | post_date | updated_at | status | icon | describe
    author=User.find(post.user_id)
    return post,author
  end

  def state_list
    {t('general.open') => 0,
      t('general.close') => 1,
      t('general.private') => 3}
  end

end
