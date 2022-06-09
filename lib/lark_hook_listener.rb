require 'lark_helper'

class LarkHookListener < Redmine::Hook::Listener
  def controller_issues_new_after_save(context = {})
    Redmine::Helpers::Lark::send_issue_event(Redmine::Helpers::Lark::get_lark_issue_data(context[:issue]))
  end

  def controller_issues_edit_after_save(context = {})
    Redmine::Helpers::Lark::send_issue_event(Redmine::Helpers::Lark::get_lark_issue_data(context[:journal]))
  end
end
