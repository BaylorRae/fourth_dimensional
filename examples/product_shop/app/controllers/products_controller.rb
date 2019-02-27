class ProductsController < ApplicationController

  def index
    @products = Product.order(:title)
  end

  def show
    @product = Product.find(params[:id])
  end

  def history
    @events = FourthDimensional.config.event_loader.for_aggregate(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    aggregate_id = SecureRandom.uuid
    command = Products::Commands::CreateProduct.new(
      aggregate_id: aggregate_id,
      title: product_params[:title],
      body: product_params[:body],
      price: product_params[:price]
    )
    FourthDimensional.execute_command(command)
    redirect_to product_path(aggregate_id)
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    aggregate_id = params[:id]
    command = Products::Commands::UpdateProduct.new(
      aggregate_id: aggregate_id,
      title: product_params[:title],
      body: product_params[:body],
      price: product_params[:price]
    )
    FourthDimensional.execute_command(command)
    redirect_to product_path(aggregate_id)
  end

  def destroy
    aggregate_id = params[:id]
    command = Products::Commands::DeleteProduct.new(aggregate_id: aggregate_id)
    FourthDimensional.execute_command(command)
    redirect_to products_path
  end

  private

  def product_params
    params.require(:product).permit(:title, :body, :price)
  end

end
