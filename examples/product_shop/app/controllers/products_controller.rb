class ProductsController < ApplicationController

  def index
    @products = Product.order(:title)
  end

  def show
    @product = Product.find(params[:id])
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

  private

  def product_params
    params.require(:product).permit(:title, :body, :price)
  end

end