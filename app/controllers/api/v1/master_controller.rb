class Api::V1::MasterController < ApplicationController

  # 商材一覧
  def index_product
    products = Product.all.order(:sort_key)
    render json: { status: 200, products: products }
  end

  # 商材登録
  def update_product
    ActiveRecord::Base.transaction do
      sort = 0
      master_params[:products].map do |product_param|
        if product_param[:del].blank? then
          sort += 1
          product = Product.find_or_initialize_by(id: product_param[:id])
          product.code = product_param[:code]
          product.name = product_param[:name]
          product.color_r = product_param[:color_r]
          product.color_g = product_param[:color_g]
          product.color_b = product_param[:color_b]
          product.color_a = product_param[:color_a]
          product.sort_key = sort
          product.save!
        else
          if product_param[:id].present? then
            product = Product.find(product_param[:id])
            product.destroy!
          end
        end
      end
    end
    render json: { status: 200, message: "Update Success!" }
  rescue => e
    render json: { status: 500, message: "Update Error!" }
  end

  private
  # ストロングパラメータ
  def master_params
    params.permit(products: [:id, :code, :name, :color_r, :color_g, :color_b, :color_a, :del])
  end

end
