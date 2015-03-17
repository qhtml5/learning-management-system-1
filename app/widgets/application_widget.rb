class ApplicationWidget < Apotomo::Widget

  include Devise::Controllers::Helpers 
  helper_method :current_user
  helper ApplicationHelper
  helper SchoolsHelper
  helper LayoutHelper

  def can?(action, object)
    current_ability.can? action, object
  end
  helper_method :can?

  def cannot?(action, object)
    current_ability.cannot? action, object
  end
  helper_method :cannot?

  def authorize! *args
    parent_controller.authorize! *args
  end

  def current_ability
    ::Ability.new current_user
  end

  def current_school
    @current_school ||= School.find_by_subdomain request.subdomain
  end

end