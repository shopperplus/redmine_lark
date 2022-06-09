require 'net/http'
require 'uri'
require 'open-uri'
require 'json'

module Redmine
  module Helpers
    module Lark
      def get_lark_issue_data(issue_or_journal)
        issue = nil
        event_title = ""
        content = ""
        if issue_or_journal.is_a?(Issue)
          issue = issue_or_journal
          content = issue_or_journal.description
          event_title = "**#{issue_or_journal.author.name}**创建了Issue"
        elsif issue_or_journal.is_a?(Journal)
          issue = issue_or_journal.issue
          content = issue_or_journal.notes
          event_title = "**#{issue_or_journal.user.name}**更新了Issue"
        end
        custom_fields_data = issue.custom_field_values.map do |field|
          {
            is_short: true,
            text: {
              content: "**📋 #{field.custom_field.name}:**\n#{field.value}",
              tag: "lark_md"
            }
          }
        end
        data = {
          config: {
            wide_screen_mode: true
          },
          header: {
            template: "red",
            title: {
              content: "#{issue.subject} ##{issue.id}",
              tag: "plain_text"
            }
          },
          elements: [
            {
              tag: "div",
              text: {
                tag: "lark_md",
                content: "#{event_title}"
              }
            },
            {
              tag: "hr"
            },
            {
              tag: "div",
              fields: [
                {
                  is_short: true,
                  text: {
                    content: "**🕐 开始日期:**\n#{issue.start_date ? issue.start_date.strftime('%Y-%m-%d') : '' }",
                    tag: "lark_md"
                  }
                },
                {
                  is_short: true,
                  text: {
                    content: "**🕐 计划完成日期:**\n#{issue.due_date ? issue.due_date.strftime('%Y-%m-%d') : '' }",
                    tag: "lark_md"
                  }
                },
                {
                  is_short: true,
                  text: {
                    content: "**👤 作者:**\n#{issue.author.firstname} #{issue.author.lastname}",
                    tag: "lark_md"
                  }
                },
                {
                  is_short: true,
                  text: {
                    content: "**👤 指派给:**\n#{issue.assigned_to ? issue.assigned_to.name : ''}",
                    tag: "lark_md"
                  }
                },
                {
                  is_short: true,
                  text: {
                    content: "**🚀 优先级:**\n#{issue.priority ? issue.priority.name : ''}",
                    tag: "lark_md"
                  }
                },
                {
                  is_short: true,
                  text: {
                    content: "**🚀 状态:**\n#{issue.status ? issue.status.name : ''} ",
                    tag: "lark_md"
                  }
                }
              ]
            },
            {
              tag: "div",
              text: {
                tag: "lark_md",
                content: "#{content}"
              }
            },
            {
              tag: "hr"
            },
            {
              tag: "div",
              text: {
                tag: "lark_md",
                content: "🙋🏼 [打开详情](#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id})"
              }
            }
          ]
        }
        data[:elements][2][:fields].concat(custom_fields_data)
        {
          chat_id: Time.now.strftime("%Y%m%d%H%M%S%L"),
          msg_type: "interactive",
          card: data
        }
      end

      def send_issue_event(data)
        begin
          uri = URI.parse(Setting.plugin_redmine_lark['lark_bot_webhook_url'])
        rescue => e
          logger.error "Parsing URI for notifications failed:\n"\
                       "  Exception: #{e.message}" if logger
          return
        end

        unless uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS)
          logger.error "Parsing URI for notifications failed" if logger
          return
        end

        # Prepare the data
        header = {
          'Content-Type' => 'text/json'
        }
        json_data = JSON.generate(data)

        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
        end
        request = Net::HTTP::Post.new(uri.request_uri, header)
        request.body = json_data

        begin
          response = http.request(request)
        rescue => e
          logger.error "Sending notification failed:\n"\
                       "  URI: #{uri}\n"\
                       "  Exception: #{e.message}" if logger
          return
        end

        unless response.code.to_i == 200
          logger.error "Sending notification failed:\n"\
                       "  URI: #{uri}\n"\
                       "  Response code: #{response.code}" if logger
          return
        else
          logger.info "Notification has been sent successfully:\n"\
                      "  URI: #{uri}\n"\
                      "  Response code: #{response.code}" if logger
        end
      end

      def logger
        Rails.logger
      end
    end
  end
end
