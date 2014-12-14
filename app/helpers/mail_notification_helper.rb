module MailNotificationHelper
  def self.link_for_build(app_id, app_name, text_link)
    "<a href=\"http://flyingapk?app_id=#{app_id}&app_name=#{app_name}\">#{text_link}</a>"
  end
end
