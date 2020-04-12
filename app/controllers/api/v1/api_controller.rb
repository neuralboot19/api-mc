class Api::V1::ApiController < ApplicationController
  before_action :authenticate_user!, unless: :devise_controller?
end