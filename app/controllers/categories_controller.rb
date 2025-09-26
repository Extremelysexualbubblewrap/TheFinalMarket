class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]

  def index
    @categories = Category.main_categories.includes(:subcategories).order(:position)
  end

  def show
    @items = @category.items.active.includes(:user, :images_attachments)
                     .order(created_at: :desc).page(params[:page])
  end

  def new
    @category = Category.new(parent_id: params[:parent_id])
    @categories = Category.all
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      @categories = Category.all
      render :new
    end
  end

  def edit
    @categories = Category.where.not(id: [@category.id] + @category.descendants.pluck(:id))
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      @categories = Category.where.not(id: [@category.id] + @category.descendants.pluck(:id))
      render :edit
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :parent_id, :active, :position)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end
end