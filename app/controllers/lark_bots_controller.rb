class LarkBotsController < ApplicationController
  layout 'admin'

  before_action :require_admin
  accept_api_auth :show_plugin_info

  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper


  def show_plugin_info
    respond_to do |format|
      format.api
    end
  end
end
