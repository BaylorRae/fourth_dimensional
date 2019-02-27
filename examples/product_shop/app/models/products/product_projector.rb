module Products
  class ProductProjector < FourthDimensional::RecordProjector
    self.record_class = 'Product'

    on Products::Events::ProductCreated do |event|
      record.title = event.title
      record.body = event.body
      record.price = event.price
    end
  end
end
