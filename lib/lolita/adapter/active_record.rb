module Lolita
  module Adapter
    class ActiveRecord
      include Lolita::Adapter::AbstractAdapter
      
      attr_reader :dbi, :klass
      def initialize(dbi)
        @dbi=dbi
        @klass=dbi.klass
      end

      def associations
        klass.reflections
      end

      # Same as in mongoid
      def associations_klass_names
        names=[]
        associations.each{|name,association|
          names << association.class_name
        }
        names
      end

      def reflect_on_association(name)
        klass.reflect_on_association(name)
      end

      def association_macro(association)
        type=association.macro
        case type
        when :has_many
          :many
        when :has_one
          :one
        when :belongs_to
          :one
        when :has_and_belongs_to_many
          :many
        end
      end

      def association_class_name(association)
        association.class_name
      end

      def fields
        @fields||=self.klass.columns.collect{|column|
          field_to_hash(column)
        }.reject{|column|
          column[:options][:primary]
        }
        @fields
      end

      def find_by_id(id)
        self.klass.where(:id=>id).first
      end
      
      def find(*args)
        self.klass.find(*args)
      end

      def paginate(opt={})
        #FIXME depend on will_paginate
        if order=opt.delete(:sort)
          order=order.map{|c| c.join(" ")}.join(", ")
          opt[:order]=order
        end
        self.klass.paginate(opt)
      end

      def db
        self.klass.connection
      end

      def db_name
        db.current_database
      end

      def collection
        self.klass #FIXME not realy same as in mongoid
      end

      def collection_name
        self.klass.table_name
      end

      def collections
        self.klass #FIXME not  realy same as in mongoid
      end

      def collection_names
        self.klass.connection.select_all("show tables from #{db_name}").map{|r| r.values.first}
      end

      private

      def field_to_hash(column)
        {
          :name=>column.name,
          :type=>type_cast(column.type.to_s),
          :title=>column.name.to_s.humanize,
          :options=>{
            :primary=>column.primary,
            :native_type=>column.type.to_s
          }
        }
      end

      # Converts SQL types to normal ruby types
      def type_cast name
        types = {
          'decimal' => 'big_decimal',
          'datetime' => 'time',
          'text' => 'string'
        }
        types[name.to_s] || name
      end
    end
  end
end
