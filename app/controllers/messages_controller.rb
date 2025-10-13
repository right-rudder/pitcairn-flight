class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :authenticate_admin!, except: [:create, :new, :confirmation, :location, :cfi, :home2]
  #invisible_captcha only: [:create], honeypot: :confirm_email, on_spam: :log_spam, if: -> { Rails.env.production? }

  if Rails.env.production?
    invisible_captcha only: [:create], honeypot: :confirm_email, on_spam: :log_spam
  end

  # GET /messages or /messages.json
  def index
    @messages = Message.all
  end

  def confirmation
  end

  def home2
    @message = Message.new
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end
  
  def location
    @message = Message.new
  end
  def cfi
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  def log_spam
    Rails.logger.info "Honeypot triggered by IP: #{request.remote_ip}"
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)
    success = verify_recaptcha(action: 'message', minimum_score: 0.3, secret_key: ENV['RECAPTCHA_SECRET_KEY'])
    checkbox_success = verify_recaptcha unless success

    respond_to do |format|
      if @message.save && (success || checkbox_success)
        MessageConfirmationMailer.message_confirmation_email(@message).deliver_later
        format.html { redirect_to contact_confirmation_path, notice: @message.body }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { 
          if !success
            @show_checkbox_recaptcha = true
          end
          render :reject, status: :unprocessable_entity  }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  #def update
  #  success = verify_recaptcha(action: 'message', minimum_score: 0.3, secret_key: ENV['RECAPTCHA_SECRET_KEY'])
  #  checkbox_success = verify_recaptcha unless success
  #  
  #  respond_to do |format|
  #    if @message.update(message_params) && (success || checkbox_success)
  #      MessageMailer.new_message(@message).deliver
  #      format.html { redirect_to contact_confirmation_path, notice: @message.body }
  #      #format.json { render :show, status: :ok, location: @message }
  #    else
  #      format.html { 
  #        if !success
  #          @show_checkbox_recaptcha = true
  #        end
  #        render :new, status: :unprocessable_entity }
  #      format.json { render json: @message.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:name, :email, :phone, :body)
    end
end
