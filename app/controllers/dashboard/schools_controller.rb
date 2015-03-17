#coding: utf-8

class Dashboard::SchoolsController < Dashboard::BaseController
  load_and_authorize_resource :only => [:edit_basic_info, :finances, :wizard_basic_info,
      :wizard_choose_plans, :course_evaluations, :create, :update, :certificate, :show_certificate,
      :students, :team]  

  include Apotomo::Rails::ControllerMethods 
  has_widgets do |root|
    root << widget(:school_team)
    root << widget(:school_library)
    root << widget(:school_bandwidth)
  end

  def wizard_basic_info
    @user = current_user 
    @school = @user.school || School.new
    render layout: "dashboard/create_school"
  end

  def wizard_choose_plans
    @user = current_user 
    @school = @user.school
    flash[:school_status] = :wizard_choose_plans
    render layout: "dashboard/create_school"
  end

  def edit_basic_info
    @user = current_user
    @school = @user.school
    flash[:school_status] = :edit_basic_info
  end

  def finances
    @school = current_school
    @courses = @school.courses
    @billing_last_month = @school.purchases.payment_confirmed.between((Date.today - 1.month).beginning_of_month, (Date.today - 1.month).end_of_month).sum(&:amount_paid)
    @billing_this_month = @school.purchases.payment_confirmed.between(Date.today.beginning_of_month, Date.today).sum(&:amount_paid)

    @purchases = @school.purchases
    @purchases_length = @purchases.length

    @purchases_confirmed = @purchases.payment_confirmed.length
    @purchases_pending = @purchases.pending.length
    @purchases_canceled = @purchases.canceled.length
    @purchases_paid_with_billet = @purchases.payment_confirmed.paid_with_billet.length
    @purchases_paid_with_online_debit = @purchases.payment_confirmed.paid_with_online_debit.length
    @purchases_paid_with_credit_card = @purchases.payment_confirmed.paid_with_credit_card.length
    
    @purchases = @purchases.order("created_at DESC").page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.xls { send_data Purchase.to_csv(col_sep: "\t", encoding: "ISO8859-1") }
    end
  end
    
  def course_evaluations
	  @user = current_user 
    @school = @user.school
    @courses = @school.courses
  end

  def create
    @user = current_user

    @school = School.new(params[:school])
    @school.users = [@user]

    if @school.save
      SchoolMailer.new_school(@school, @user).deliver
      flash[:notice] = "Escola criada com sucesso! Está iniciando agora seu período de 15 dias de teste gratuito com todas as funcionalidades liberadas."
      redirect_to dashboard_courses_path(subdomain: @school.subdomain, code: current_user.encrypted_password)
    else
      render :wizard_basic_info, layout: "dashboard/create_school"
    end
  end

  def update
    @school = School.find(params[:id])
    old_plan = @school.plan

    if @school.update_attributes(params[:school])
      if old_plan != @school.plan
        AdminMailer.school_plan_change(@school, current_user, old_plan).deliver
      end

      case flash[:school_status]
      when :wizard_choose_plans
        Notification.create(
          receiver: current_user, 
          code: Notification::SCHOOL_PLAN_CHOOSE, 
          notifiable: @school
        )
        flash[:notice] = "Parabéns! Sua escola foi criada com sucesso!"
        redirect_to dashboard_courses_path
      when :edit_basic_info
        flash[:notice] = "Informações atualizadas com sucesso."
        redirect_to edit_basic_info_dashboard_schools_path
      when :configurations_integrations
        flash[:notice] = "Configurações de integração atualizadas com sucesso."
        redirect_to configurations_integrations_dashboard_schools_path
      when :configurations_domain
        flash[:notice] = "Configurações de domínio atualizadas com sucesso."
        redirect_to configurations_domain_dashboard_schools_path
      when :configurations_general
        flash[:notice] = "Configurações gerais atualizadas com sucesso."
        redirect_to configurations_general_dashboard_schools_path
      when :configurations_plan
        flash[:notice] = "Plano atualizado com sucesso."
        redirect_to configurations_plan_dashboard_schools_path
      when :configurations_moip
        flash[:notice] = "Conta MoIP atualizada com sucesso."
        redirect_to configurations_moip_dashboard_schools_path
      when :configurations_notifications
        flash[:notice] = "Configurações de notificação atualizadas com sucesso."
        redirect_to configurations_notifications_dashboard_schools_path
      else
        flash[:notice] = t('messages.school.update.success')
        redirect_to request.referer
      end
    else
      flash[:school_status] = flash[:school_status]
      if flash[:school_status]
        if wizard_step?
          render action: flash[:school_status], layout: "dashboard/create_school"
        else
          render action: flash[:school_status]
        end
      else
        redirect_to edit_basic_info_dashboard_schools_path
      end
    end 
  end
  
  def show_certificate
    @course = Course.find(params[:course])
    @student = User.find(params[:student]) 
    @school = @course.school
    @layout_configuration = @school.layout_configuration

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "certificado", orientation: "landscape" 
      end
    end
  end

  def team
    @school = current_user.school
  end
  
  def library
    @school = current_user.school    
    
    authorize! :library, @school
  end

  def conversions
    @school = current_user.school    
    @courses = @school.courses

    authorize! :conversions, @school
  end

  def configurations_general
    @school = current_user.school    
    flash[:school_status] = :configurations_general

    authorize! :configurations, @school
  end

  def configurations_integrations
    @school = current_user.school    
    flash[:school_status] = :configurations_integrations

    authorize! :configurations, @school
  end

  def configurations_plan
    @school = current_user.school    
    flash[:school_status] = :configurations_plan

    authorize! :configurations, @school
  end

  def configurations_domain
    @school = current_user.school    
    flash[:school_status] = :configurations_domain

    authorize! :configurations, @school
  end

  def configurations_moip
    @school = current_user.school    
    flash[:school_status] = :configurations_moip

    authorize! :configurations, @school
  end

  def configurations_notifications
    @school = current_user.school    
    @school.build_notification_configuration unless @school.notification_configuration.present?
    flash[:school_status] = :configurations_notifications

    authorize! :configurations, @school
  end  

  def coupons
    @school = current_user.school
    @courses = @school.courses

    authorize! :coupons, @school
  end
  
  private
  def wizard_step?
    [:wizard_basic_info, :wizard_choose_plans].include? flash[:school_status]
  end
end
