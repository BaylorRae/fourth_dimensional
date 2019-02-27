require 'rails/generators'

module FourthDimensional
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def initializer
      template 'initializer.rb', 'config/initializers/fourth_dimensional.rb'
    end
  end
end
