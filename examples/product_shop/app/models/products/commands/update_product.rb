module Products
  module Commands
    class UpdateProduct < FourthDimensional::Command
      attributes :title, :body, :price
      validates_presence_of :title, :body, :price
    end
  end
end
