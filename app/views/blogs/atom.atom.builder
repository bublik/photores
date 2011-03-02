atom_feed do |feed|
  feed.title "Blogs Ruby on Rails in UA"
  feed.updated((@blogs.first ? @blogs.first.created_at : Time.now))
  
  for post in @blogs
    tags = '<br/>'+post.tags.collect{|t|  
                link_to(t.name, {:controller => 'blogs',
                                 :action => 'tag',
                                 :id => t.name},
                  :class=>'tforum',
                  :title=>t.name, :rel=>'tag friend colleague')
              }.join(', ')
    feed.entry(post) do |entry|
      entry.title(post.title)
      entry.content(post.body + tags , :type => 'html')
      entry.author do |author|
        author.name(post.user.full_name)
      end
    end
  end
end