module Stove
  module Util
    extend self

    # Convert a version string (x.y.z) to a community-site friendly format
    # (x_y_z).
    #
    # @example Convert a version to a version string
    #   format_version('1.2.3') #=> 1_2_3
    #
    # @param [#to_s] version
    #  the version string to convert
    #
    # @return [String]
    def version_for_url(version)
      version
        .to_s
        .gsub('.', '_')
    end

    #
    # Covert the given CaMelCaSeD string to under_score. Graciously borrowed
    # from http://stackoverflow.com/questions/1509915.
    #
    # @param [String] string
    #   the string to use for transformation
    #
    # @return [String]
    #
    def underscore(string)
      string
        .to_s
        .gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr('-', '_')
        .downcase
    end

    #
    # Convert an underscored string to it's camelcase equivalent constant.
    #
    # @param [String]
    #   the string to convert
    #
    # @return [String]
    #
    def camelize(string)
      string
        .to_s
        .split('_')
        .map { |e| e.capitalize }
        .join
    end
  end
end
