module Products
  module Events
    class ProductCreated < ::FourthDimensional::Event
      def title
        data.fetch('title')
      end

      def body
        data.fetch('body')
      end

      def price
        data.fetch('price')
      end
    end
  end
end
