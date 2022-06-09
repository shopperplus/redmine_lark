require 'lark_helper'

class LarkHookListener < Redmine::Hook::Listener
  include Redmine::Helpers::Lark
  def controller_issues_new_after_save(context = {})
    send_issue_event(get_lark_issue_data(context[:issue]))
  end

  def controller_issues_edit_after_save(context = {})
    send_issue_event(get_lark_issue_data(context[:journal]))
  end
end
