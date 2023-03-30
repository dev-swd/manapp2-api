class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken

        before_action :configure_permitted_parameters, if: :devise_controller?
        private
        def configure_permitted_parameters
                added_attrs = [ :email, :password, :password_confirmation, :employee_number, :name, :name_kana, :birthday, :address, :phone, :joining_date, :authority_id ]
                devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
        end
end
