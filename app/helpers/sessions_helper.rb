module SessionsHelper

    # logs in the given user
    def log_in(user)
        session[:user_id] = user.id
    end

    # shows the current user
    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    # checks if a user is logged in
    def logged_in?
        !current_user.nil?
    end

    # Logs out the current user
    def log_out
        reset_session
        @current_user = nil
    end

end
