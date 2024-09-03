# frozen_string_literal: true

# name: discourse-clean-category
# about: A plugin to periodically check group members for custom field status, will remove user from group if changed.
# version: 0.1
# authors: InvisibleCat

enabled_site_setting :clean_category_enabled

plugin_name = 'clean-category'

after_initialize do
  
  require_relative "jobs/recurring/check_group_members"
  if SiteSetting.clean_category_enabled
    Jobs::CheckGroupMembers.schedule_next_run
  end

  DiscourseEvent.on(:site_setting_changed) do |name, old_value, new_value|
    if ["clean_category_enabled", "clean_category_group_name", "clean_category_interval_value", "clean_category_custom_field_value"].include?(name)
      Jobs::CheckGroupMembers.schedule_next_run if SiteSetting.clean_category_enabled
    else
      Jobs::CheckGroupMembers.cancel_scheduled_jobs
    end
  end
end

