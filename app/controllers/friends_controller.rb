class FriendsController < ApplicationController
  before_filter :check_authentificate, :except => [:index, :show]
  before_filter :init_user, :only => [:new, :edit, :create, :update]

  def index
    @user = User.find(params[:user_id], :include => [:friendships => :friend])
  end
  
  def show
    redirect_to user_path(params[:id])
  end
  
  def new
    @friend = User.find(params[:friend_id])
    unless @user.friends.include?(@friend)
      @friendship = @user.friendships.new(:friend_id => @friend.id)
    else
      redirect_to friend_path(:user_id => logged_in_user, :id => @friend)
    end
  end
  
  def edit
    @user = current_user
    @friendship = @user.friendships.find_by_friend_id(params[:id].to_i)
    @friend = @friendship.friend if @friendship
    if !@friendship
      redirect_to friend_path(:user_id => current_user, :id => params[:id])
    end
  end

  def create
    params[:friendship][:friend_id] = params[:friend_id]
    @friendship = @user.friendships.create(params[:friendship])
    redirect_to user_friends_path(:user_id => current_user)
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def update
    @friendship = @user.friendships.find_by_friend_id(params[:id].to_i)
    @friendship.update_attributes(params[:friendship])
    redirect_to user_friends_path(:user_id => current_user)
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def destroy
    @user = User.find(params[:user_id])
    @friendship = @user.friendships.find_by_friend_id(params[:id].to_i).destroy
    redirect_to user_friends_path(:user_id => current_user)
  end

  private
  def init_user
    @user = current_user
  end
  
end
