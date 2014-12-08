require 'json'

module Stove
  class Cookbook
    # Borrowed and modified from:
    # {https://raw.github.com/opscode/chef/11.4.0/lib/chef/cookbook/metadata.rb}
    #
    # Copyright:: Copyright 2008-2010 Opscode, Inc.
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    #
    # == Chef::Cookbook::Metadata
    # Chef::Cookbook::Metadata provides a convenient DSL for declaring metadata
    # about Chef Cookbooks.
    class Metadata
      class << self
        def from_file(path)
          new.from_file(path)
        end

        def def_attribute(field)
          class_eval <<-EOM, __FILE__, __LINE__ + 1
            def #{field}(arg = nil)
              set_or_return(:#{field}, arg)
            end
          EOM
        end

        def def_meta_cookbook(field, instance_variable)
          class_eval <<-EOM, __FILE__, __LINE__ + 1
            def #{field}(thing, *args)
              version = args.first
              @#{instance_variable}[thing] = version || DEFAULT_VERSION
              @#{instance_variable}[thing]
            end
          EOM
        end

        def def_meta_setter(field, instance_variable)
          class_eval <<-EOM, __FILE__, __LINE__ + 1
            def #{field}(name, description)
              @#{instance_variable}[name] = description
              @#{instance_variable}
            end
          EOM
        end
      end

      DEFAULT_VERSION = '>= 0.0.0'.freeze

      COMPARISON_FIELDS = [
        :name, :description, :long_description, :maintainer,
        :maintainer_email, :license, :platforms, :dependencies,
        :recommendations, :suggestions, :conflicting, :providing,
        :replacing, :attributes, :groupings, :recipes, :version
      ]

      def_attribute :name
      def_attribute :maintainer
      def_attribute :maintainer_email
      def_attribute :license
      def_attribute :description
      def_attribute :long_description

      def_attribute :source_url
      def_attribute :issues_url

      def_meta_cookbook :supports,   :platforms
      def_meta_cookbook :depends,    :dependencies
      def_meta_cookbook :recommends, :recommendations
      def_meta_cookbook :suggests,   :suggestions
      def_meta_cookbook :conflicts,  :conflicting
      def_meta_cookbook :provides,   :providing
      def_meta_cookbook :replaces,   :replacing

      def_meta_setter :recipe,    :recipes
      def_meta_setter :grouping,  :groupings
      def_meta_setter :attribute, :attributes

      attr_reader :cookbook
      attr_reader :platforms
      attr_reader :dependencies
      attr_reader :recommendations
      attr_reader :suggestions
      attr_reader :conflicting
      attr_reader :providing
      attr_reader :replacing
      attr_reader :attributes
      attr_reader :groupings
      attr_reader :recipes
      attr_reader :version

      def initialize(cookbook = nil, maintainer = 'YOUR_COMPANY_NAME', maintainer_email = 'YOUR_EMAIL', license = 'none')
        @cookbook         = cookbook
        @name             = cookbook ? cookbook.name : ''
        @long_description = ''
        @platforms        = Stove::Mash.new
        @dependencies     = Stove::Mash.new
        @recommendations  = Stove::Mash.new
        @suggestions      = Stove::Mash.new
        @conflicting      = Stove::Mash.new
        @providing        = Stove::Mash.new
        @replacing        = Stove::Mash.new
        @attributes       = Stove::Mash.new
        @groupings        = Stove::Mash.new
        @recipes          = Stove::Mash.new

        self.maintainer(maintainer)
        self.maintainer_email(maintainer_email)
        self.license(license)
        self.description('A fabulous new cookbook')
        self.version('0.0.0')

        if cookbook
          @recipes = cookbook.fully_qualified_recipe_names.inject({}) do |r, e|
            e = self.name if e =~ /::default$/
            r[e] = ""
            self.provides e
            r
          end
        end
      end

      def from_file(path)
        path = path.to_s

        if File.exist?(path) && File.readable?(path)
          self.instance_eval(IO.read(path), path, 1)
          self
        else
          raise Error::MetadataNotFound.new(path: path)
        end
      end

      def ==(other)
        COMPARISON_FIELDS.inject(true) do |equal_so_far, field|
          equal_so_far && other.respond_to?(field) && (other.send(field) == send(field))
        end
      end

      def version(arg = UNSET_VALUE)
        if arg == UNSET_VALUE
          @version
        else
          @version = arg.to_s
        end
      end

      def to_hash
        {
          'name'             => self.name,
          'version'          => self.version,
          'description'      => self.description,
          'long_description' => self.long_description,
          'maintainer'       => self.maintainer,
          'maintainer_email' => self.maintainer_email,
          'license'          => self.license,
          'platforms'        => self.platforms,
          'dependencies'     => self.dependencies,
          'recommendations'  => self.recommendations,
          'suggestions'      => self.suggestions,
          'conflicting'      => self.conflicting,
          'providing'        => self.providing,
          'replacing'        => self.replacing,
          'attributes'       => self.attributes,
          'groupings'        => self.groupings,
          'recipes'          => self.recipes,
        }
      end

      def to_json(*args)
        JSON.pretty_generate(self.to_hash)
      end

      private

      def set_or_return(symbol, arg)
        iv_symbol = "@#{symbol.to_s}".to_sym

        if arg.nil? && self.instance_variable_defined?(iv_symbol)
          self.instance_variable_get(iv_symbol)
        else
          self.instance_variable_set(iv_symbol, arg)
        end
      end
    end
  end
end
