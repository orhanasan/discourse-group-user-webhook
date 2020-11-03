# frozen_string_literal: true

# name: discourse-group-user-webhook
# about: Adds webhooks for when user is added/removed from group
# version: 0.1
# authors: Faizaan Gagan

enabled_site_setting :discourse_group_user_webhook_enabled

after_initialize do
  class ::WebHookEventType
    USERGROUP = 20
  end

  register_seedfu_fixtures(File.expand_path('../db/fixtures/', __FILE__))

  class ::WebHook
    def self.enqueue_usergroup_hooks(event, payload)
      if active_web_hooks(:usergroup).exists?
        WebHook.enqueue_hooks(:usergroup, event,
          payload: payload
        )
      end
    end
  end

  on(:user_added_to_group) do |user, group|
    if WebHook.active_web_hooks(:usergroup).exists?
      type = :user_added_to_group
      payload = {
        type: type,
        username: user.username,
        user_email: user.email,
        group_name: group.name,
        group_id: group.id
      }

      WebHook.enqueue_usergroup_hooks(type, payload.to_json)
    end
  end

  on(:user_removed_from_group) do |user, group|
    if WebHook.active_web_hooks(:usergroup).exists?
      type = :user_removed_from_group
      payload = {
        type: type,
        username: user.username,
        user_email: user.email,
        group_name: group.name,
        group_id: group.id
      }

    WebHook.enqueue_usergroup_hooks(type, payload.to_json)
    end
  end
end