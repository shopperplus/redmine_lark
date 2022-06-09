require 'redmine'

require_dependency 'lark_hook_listener'

Redmine::Plugin.register :redmine_lark do
  name 'Redmine Lark Bot'
  author 'Shopperplus Inc.'
  description 'Lark bot with redmine'
  version '1.0'
  url 'https://github.com/shopperplus/redmine_lark'
  author_url 'https://github.com/shopperplus/redmine_lark'

  settings :default => {'empty' => true}, :partial => 'settings/lark'
end

