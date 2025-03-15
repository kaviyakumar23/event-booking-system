module RoleAuthorization
  extend ActiveSupport::Concern

  def authorize_role!(*allowed_roles)
    unless allowed_roles.include?(current_user&.role)
      render json: { error: 'Unauthorized access' }, status: :forbidden
    end
  end

  def authorize_event_organizer!
    authorize_role!('event_organizer')
  end

  def authorize_customer!
    authorize_role!('customer')
  end
end
