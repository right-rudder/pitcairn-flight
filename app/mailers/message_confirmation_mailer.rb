class MessageConfirmationMailer < ApplicationMailer

  default from: 'no-reply@pitcairnmailer.com'

  def message_confirmation_email(message)
    @message = message

    mail(to: @message.email, bcc: ["no-reply@pitcairnmailer.com", "marisa@pitcairnflight.com"], subject: "✈️ Thank you for contacting Pitcairn Flight")
  end

end
