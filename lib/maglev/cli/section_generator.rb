# frozen_string_literal: true

module Maglev
  module CLI
    class SectionGenerator < Thor::Group
      include Thor::Actions

      class_option :category, type: :string, default: 'contents'
      class_option :settings, type: :array, default: []
      argument :section_name, type: :string

      attr_reader :theme_name, :settings, :blocks

      def self.source_root
        File.expand_path('templates/section', __dir__)
      end

      def verify_themes_are_present
        raise Thor::Error, set_color('ERROR: You must first create a theme.', :red) if themes.empty?
      end

      def select_theme
        say 'You have to select a theme', :blue
        @theme_name = ask 'Please choose a theme', limited_to: themes, default: themes.first
      end

      def build_settings
        @settings = extract_section_settings
        @blocks = extract_blocks
      end

      def create_section_files
        directory 'app'
      end

      private

      def themes
        @themes ||= Dir.chdir('app/themes') do
          Dir.glob('*').select { |f| File.directory? f }
        end
      end

      def extract_section_settings
        # build section settings only
        sections = options['settings'].map do |raw_setting|
          next if raw_setting.starts_with?('block:') # block setting

          id, type = raw_setting.split(':')
          SectionSetting.new(id, type)
        end.compact

        return sections unless sections.empty?

        default_section_settings
      end

      def extract_blocks
        # build block settings
        blocks = options['settings'].map do |raw_setting|
          next unless raw_setting.starts_with?('block:') # block setting

          _, block_type, id, type = raw_setting.split(':')
          BlockSetting.new(block_type, id, type)
        end.compact

        blocks = default_block_settings if Array(blocks).empty?

        # group them by block types
        blocks.group_by(&:block_type)
      end

      def default_section_settings
        [
          SectionSetting.new('title', 'text', 'My awesome title'),
          SectionSetting.new('image', 'image_picker', 'An image')
        ]
      end

      def default_block_settings
        [
          BlockSetting.new('list_item', 'title', 'text', 'Item title'),
          BlockSetting.new('list_item', 'image', 'image_picker', 'Item image')
        ]
      end

      class SectionSetting
        attr_reader :id, :type, :label

        def initialize(id, type, label = nil)
          @id = id
          @type = type || 'text'
          @label = label || id.humanize
        end

        def default
          case type
          when 'text' then label
          when 'image_picker' then '"/samples/images/default.svg"' # TODO: replace by a real image
          when 'checkbox' then true
          when 'radio', 'select' then 'option_1'
          when 'url' then '"#"'
          end
        end

        def value?
          !%w[hint content_type].include?(type)
        end
      end

      class BlockSetting < SectionSetting
        attr_reader :block_type

        def initialize(block_type, id, type, label = nil)
          super(id, type, label)
          @block_type = block_type
        end
      end
    end
  end
end
