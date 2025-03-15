class AuthController < ApplicationController
    include JwtAuthentication
    skip_before_action :verify_authenticity_token
    
    def signin
      @user = User.find_by(email: signin_params[:email])

      if @user&.authenticate(signin_params[:password])
        # Update last signin timestamp
        @user.update(last_signin_at: Time.current)
        
        # Get the appropriate profile based on user role
        @profile = @user.role == 'event_organizer' ? @user.event_organizer : @user.customer

        # Generate JWT token
        token = generate_jwt_token(@user)

        render json: {
          message: 'Signin successful',
          token: token,
          user: {
            id: @user.id,
            email: @user.email,
            role: @user.role,
            profile: @profile
          }
        }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end

    def register
      ActiveRecord::Base.transaction do
        @user = User.new(user_params)
        
        if @user.save
          # Create associated profile based on role
          if @user.role == 'event_organizer'
            @profile = EventOrganizer.create!(
              user: @user,
              name: profile_params[:name],
              phone: profile_params[:phone],
              company_name: profile_params[:company_name]
            )
          else
            @profile = Customer.create!(
              user: @user,
              name: profile_params[:name],
              phone: profile_params[:phone]
            )
          end

          render json: {
            message: 'Registration successful',
            user: {
              id: @user.id,
              email: @user.email,
              role: @user.role,
              profile: @profile
            }
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :role)
    end

    def profile_params
      params.require(:profile).permit(:name, :phone, :company_name)
    end

    def signin_params
      params.require(:user).permit(:email, :password)
    end
end
