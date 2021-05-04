module SessionsHelper

    # logs in the given user
    def log_in(user)
        session[:user_id] = user.id
        session[:session_token] = user.session_token
    end

    # Remembers a user in a persistent session
    def remember(user)
        user.remember
        cookies.permanent.encrypted[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # shows the current user
    def current_user
        if (user_id = session[:user_id])
            user = User.find_by(id: user_id)
            # TODO: User.prototype.session_token sometimes cause a problem
            @current_user ||= user if session[:session_token] == user.session_token
        elsif (user_id = cookies.encrypted[:user_id])
            user = User.find_by(id: user_id)
            if user&.authenticated?(:remember, cookies[:remember_token])
                log_in(user)
                @current_user = user
            end
        end
    end

    def current_user?(user)
        user &. == current_user
    end


    # checks if a user is logged in
    def logged_in?
        !current_user.nil?
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Logs out the current user
    def log_out
        forget(current_user)
        reset_session
        @current_user = nil
    end

    def store_location
        session[:forwarding_url] = request.original_url if request.get?
    end

end
