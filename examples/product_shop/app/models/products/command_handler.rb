module Products
  class CommandHandler < FourthDimensional::CommandHandler
    on Products::Commands::CreateProduct do |command|
      with_aggregate(Products::Product, command) do |product|
        product.create(title: command.title,
                       body: command.body,
                       price: command.price)
      end
    end

    on Products::Commands::UpdateProduct do |command|
      with_aggregate(Products::Product, command) do |product|
        product.update(title: command.title,
                       body: command.body,
                       price: command.price)
      end
    end
  end
end
