class Api::V1::SessionsController < ApplicationController
  before_action :ensure_params
  before_action :prepare_data, only: :facebook

  # Sign Up/Sign In
  def facebook
    @user = User.find_by_email(@data[:email])
    if @user
      created_header
      render status: :created, json: @user
      return
    else
      @user = User.new(@data)
      if @user.save
        created_header
        render status: :created, json: @user
        return
      else
        render status: 422, json: @user.errors.full_messages.to_sentence
        return
      end
    end
  end

  private
    def created_header
      # create token
      token = DeviseTokenAuth::TokenFactory.create

      # store client + token in user's token hash
      @user.tokens[token.client] = {
        token:  token.token_hash,
        expiry: token.expiry
      }

      new_auth_header = @user.build_auth_header(token.token, token.client)

      # update response with the header that will be required by the next request
      response.headers.merge!(new_auth_header)
    end

    def user_params
      params.require(:user).permit(:facebook_access_token)
    end

    def ensure_params
      if params[:user].present?
        return if params[:user][:facebook_access_token].present?
      end
      # Need too throw an exception
      render status: 400, json: { message: 'Error en facebook Access Token!' }
      return
    end

    def prepare_data
      graph = Koala::Facebook::API.new(user_params[:facebook_access_token])
      user_data = graph.get_object('me?fields=name,first_name,last_name,'\
                                    'email,id,birthday,picture.type(large)')
      @data = {
        email: user_data['email'],
        name: user_data['first_name'] + ' ' + user_data['last_name'],
        uid: user_data['email'],
        remote_avatar: user_data['picture']['data']['url'],
        provider: 'facebook',
        birthday: user_data['birthday']
      }
    end
end
