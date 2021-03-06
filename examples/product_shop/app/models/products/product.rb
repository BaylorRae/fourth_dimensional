module Products
  class Product < FourthDimensional::AggregateRoot
    attr_reader :title, :body, :price

    def create(title:, body:, price:)
      apply(
        Products::Events::ProductCreated,
        data: {
          title: title,
          body: body,
          price: price
        }
      )
    end

    def update(title:, body:, price:)
      raise RuntimeError if @deleted
      apply(
        Products::Events::ProductUpdated,
        data: {
          title: title,
          body: body,
          price: price
        }
      )
    end

    def delete
      apply Products::Events::ProductDeleted
    end

    on Products::Events::ProductCreated do |event|
      @title = event.title
      @body = event.body
      @price = event.price
    end

    on Products::Events::ProductUpdated do |event|
      @title = event.title
      @body = event.body
      @price = event.price
    end

    on Products::Events::ProductDeleted do |event|
      @deleted = true
    end
  end
end
