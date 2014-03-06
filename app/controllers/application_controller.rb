class ApplicationController < ActionController::Base
  include LocalesHelper
  include ReadableUnguessableUrlsHelper
  protect_from_forgery

  around_filter :user_time_zone, if: :current_user
  before_filter :set_application_locale
  before_filter :save_selected_locale_if_possible
  helper :analytics_data
  helper :locales
  helper_method :current_user_or_visitor

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      store_location
      authenticate_user!
    end
  end

  protected
  def default_url_options
    if !user_signed_in? and params.has_key?(:locale)
      super.merge({locale: selected_locale})
    else
      super
    end
  end

  def current_user_or_visitor
    current_user || LoggedOutUser.new
  end

  def dashboard_or_root_path
    if current_user
      dashboard_path
    else
      root_path
    end
  end

  def store_location
    session['user_return_to'] = request.original_url
  end

  def clear_stored_location
    session['user_return_to'] = nil
  end

  def after_sign_in_path_for(resource)
    save_detected_locale
    path = session['user_return_to'] || dashboard_path
    clear_stored_location
    path
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
  end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :name, :password, :password_confirmation, :language_preference)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :language_preference, :remember_me)
    end
  end
end
