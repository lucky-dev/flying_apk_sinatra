module MailNotificationHelper
  def self.link_for_build(app_id, app_name, type_build, text_link)
    "<a href=\"http://flyingapk?app_id=#{app_id}&app_name=#{app_name}&type_build=#{type_build}\">#{text_link}</a>"
  end

  def self.perform_async(method, app_id, build_id)
    MailNotification.perform_async(method, app_id, build_id) if ENV['RACK_ENV'] == 'production'
  end
end
