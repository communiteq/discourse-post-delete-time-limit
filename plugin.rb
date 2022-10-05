# name: discourse-post-delete-time-limit
# version: 1.0
# author: Communiteq
# url: https://github.com/communiteq/discourse-post-delete-time-limit

enabled_site_setting :post_delete_time_limit_enabled

after_initialize do

  module ExtendPostGuardianTimeLimit
    def can_delete_post?(post)
      return false unless super # we impose an EXTRA restriction so false stays false

      # taken from https://github.com/discourse/discourse/blob/f5194aadd39d5c323df52a346c6641e49d3279c5/lib/guardian/post_guardian.rb#L196-L199
      if is_my_own?(post)
        return true if post.user_deleted && !post.deleted_at
        return false if (Time.now - (SiteSetting.post_delete_time_limit_hours * 3600)) > post.created_at
      end
      true
    end
  end

  class ::Guardian
    prepend ExtendPostGuardianTimeLimit
  end

end
