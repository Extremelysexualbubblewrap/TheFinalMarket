class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:index, :show]

  def index
    @tags = Tag.all.order(:name)
  end

  def show
    @products = @tag.products.includes(:user).page(params[:page])
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to @tag, notice: 'Tag was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: 'Tag was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_url, notice: 'Tag was successfully deleted.'
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :description)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end
end