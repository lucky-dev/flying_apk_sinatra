require 'sidekiq'
require 'mail'

class MailNotification
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*params)
    method = params[0].to_sym

    if method == :add_new_build
      app_id = params[1].to_i
      build_id = params[2].to_i
      build = Build.where(id: build_id).first
      recipients = User.select(:email).where(id: PermissionApp.select(:user_id).where(android_app_id: app_id)).all

      emails = []
      recipients.each { |recipient| emails << recipient.email }

      app_name = build.android_app.name

      Mail.deliver do
        to emails
        from FlyingApk::App::MAIL_SENDER
        subject "FlyingApk - #{app_name} [#{build.name}]"
        html_part do
          content_type 'text/html; charset=UTF-8'
          body "<body>A new build of #{app_name} app was uploaded. You can #{MailNotificationHelper.link_for_build(app_id, app_name, build.type, 'download this build')}.</body>"
        end
        delivery_method :smtp, FlyingApk::App::SMTP_SETTINGS
      end
    elsif method == :add_user_to_app
      email = params[1]
      app_id = params[2].to_i
      app = AndroidApp.where(id: app_id).first
      Mail.deliver do
        to email
        from FlyingApk::App::MAIL_SENDER
        subject "FlyingApk - You was added to the #{app.name}"
        body "You was added to the #{app.name}. Now you can download and test all builds. Enjoy!"
        delivery_method :smtp, FlyingApk::App::SMTP_SETTINGS
      end
    elsif method == :remove_user_from_app
      email = params[1]
      app_id = params[2].to_i
      app = AndroidApp.where(id: app_id).first
      Mail.deliver do
        to email
        from FlyingApk::App::MAIL_SENDER
        subject "FlyingApk - You was removed from the #{app.name}"
        body "You was removed from the #{app.name}. Now you can not to download and test all builds."
        delivery_method :smtp, FlyingApk::App::SMTP_SETTINGS
      end
    end
  end
end
