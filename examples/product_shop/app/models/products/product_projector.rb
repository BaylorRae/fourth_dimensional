module Products
  class ProductProjector < FourthDimensional::RecordProjector
    self.record_class = 'Product'

    on Products::Events::ProductCreated do |event|
      record.title = event.title
      record.body = event.body
      record.price = event.price
    end

    on Products::Events::ProductUpdated do |event|
      record.title = event.title
      record.body = event.body
      record.price = event.price
    end

    on Products::Events::ProductDeleted do |event|
      record.deleted = true
      record.deleted_at = event.created_at
    end
  end
end
