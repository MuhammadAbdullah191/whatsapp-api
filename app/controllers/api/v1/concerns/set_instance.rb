require 'active_support/inflector'

module Api::V1::Concerns::SetInstance
  extend ActiveSupport::Concern

  def set_instance(id, model_class)
    instance = model_class.find_by_id(id)
    
    unless instance
      render json: { message: "#{model_class.name} not found" }, status: :not_found
      return
    end
  
    instance
  end
end
