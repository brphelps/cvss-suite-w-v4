# CVSS-Suite, a Ruby gem to manage the CVSS vector
#
# Copyright (c) 2016-2022 Siemens AG
# Copyright (c) 2022 0llirocks
#
# Authors:
#   0llirocks <http://0lli.rocks>
#
# This work is licensed under the terms of the MIT license.
# See the LICENSE.md file in the top-level directory.

require 'cvss_suite/cvss2/cvss2'
require 'cvss_suite/cvss3/cvss3'
require 'cvss_suite/cvss31/cvss31'
require 'cvss_suite/version'
require 'cvss_suite/errors'
require 'cvss_suite/invalid_cvss'

##
# Module of this gem.
module CvssSuite
  CVSS_VECTOR_BEGINNINGS = [
    { string: 'AV:', version: 2 },
    { string: '(AV:', version: 2 },
    { string: 'CVSS:3.0/', version: 3.0 },
    { string: 'CVSS:3.1/', version: 3.1 }
  ].freeze

  ##
  # Returns a CVSS class by a +vector+.
  def self.new(vector)
    return InvalidCvss.new unless vector.is_a? String

    @vector_string = vector
    case version
    when 2
      Cvss2.new(prepare_vector(@vector_string))
    when 3.0
      Cvss3.new(prepare_vector(@vector_string))
    when 3.1
      Cvss31.new(prepare_vector(@vector_string))
    else
      InvalidCvss.new
    end
  end

  private

  def self.version
    CVSS_VECTOR_BEGINNINGS.each do |beginning|
      return beginning[:version] if @vector_string.start_with? beginning[:string]
    end
  end

  def self.prepare_vector(vector)
    vector = vector.clone
    if(version == 2)
      start_of_vector = vector.index('AV')

      if start_of_vector.nil?
        ''
      elsif start_of_vector == 1
        match_array = vector.scan(/\((?>[^)(]+|\g<0>)*\)/)
        if match_array.length == 1 && match_array[0] == vector
          vector.slice!(0)
          vector.slice!(vector.length - 1)
          vector
        else
          ''
        end
      else
        vector[start_of_vector..]
      end
    else
      version_string = CVSS_VECTOR_BEGINNINGS.detect{ |v| v[:version] == version}[:string]
      start_of_vector = vector.index(version_string)

      if start_of_vector.nil?
        ''
      else
        vector[version_string.length..]
      end
    end
  end
end
