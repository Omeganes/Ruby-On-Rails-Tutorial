class ApplicationController < ActionController::Base
    include SessionsHelper


    private

        # Checks if a user is logged in
        def logged_in_user
            unless logged_in?
                store_location
                flash[:danger] = "Please log in."
                redirect_to login_path
            end
        end
end
