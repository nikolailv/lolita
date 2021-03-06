module Lolita
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Create lolita initializer, installs other lolita modules, copies tinymce.yml config."

      def copy_initializer
        template "lolita.rb", "config/initializers/lolita.rb" unless File.exist?(Rails.root + "config/initializers/lolita.rb")
      end

      def copy_tinymce
        template "tinymce.yml", "config/tinymce.yml" unless File.exist?(Rails.root + "config/tinymce.yml")
      end

      def install_modules
        Lolita.modules.each do |module_name|
          invoke "lolita:#{module_name.to_s.underscore.gsub("/","_").gsub(/^lolita_/,"")}:install" rescue nil
        end
      end
    end
  end
end
