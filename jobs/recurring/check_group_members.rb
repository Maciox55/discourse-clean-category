module Jobs
  class CheckGroupMembers < ::Jobs::Scheduled
    interval = SiteSetting.clean_category_interval_value
    every interval.minutes
    def execute(args)
      if SiteSetting.clean_category_enabled
        group_name = SiteSetting.clean_category_group_name
        custom_field_value = SiteSetting.clean_category_custom_field_value
        group = Group.find_by_name(group_name)

        return unless group

        custom_field_id = UserField.find_by(name: "#{custom_field_value}").id

    
        group.users.each do |user|
          custom_field_value = UserCustomField.where(user_id: user.id, name: "user_field_#{custom_field_id}").pluck(:value).first
          if custom_field_value.nil? || custom_field_value.blank?
            group.remove(user)
          end
        end
      end
    end

    def self.schedule_next_run
      next_run_in = SiteSetting.clean_category_interval_value.minutes

      self.perform_in(next_run_in)
    end
  end
end


