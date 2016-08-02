#
# Copyright 2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

require 'chef/resource'
require 'poise'


module PoiseArchive
  module Resources
    # (see PoiseArchive::Resource)
    # @since 1.0.0
    module PoiseArchive
      # A `poise_archive` resource to unpack archives.
      #
      # @provides poise_archive
      # @action unpack
      # @example
      #   poise_archive '/opt/myapp.tgz'
      # @example Downloading from a URL with options
      #   poise_archive ['http://example.com/myapp.zip', {headers: {'Authentication' => '...'}}] do
      #     destination '/opt/myapp'
      #   end
      class Resource < Chef::Resource
        include Poise
        provides(:poise_archive)
        actions(:unpack)

        # @!attribute path
        #   Path to the archive. If relative, it is taken as a file inside
        #   `Chef::Config[:file_cache_path]`. Can also be a URL to download the
        #   archive from.
        #   @return [String, Array]
        attribute(:path, kind_of: String, default: lazy { name.is_a?(Array) ? name[0] : name }, required: true)
        # @!attribute destination
        #   Path to unpack the archive to. If not specified, the path of the
        #   archive without the file extension is used.
        #   @return [String, nil, false]
        attribute(:destination, kind_of: [String, NilClass, FalseClass], default: lazy { default_destination })
        # @!attribute group
        #   Group to run the unpack as.
        #   @return [String, Integer, nil, false]
        attribute(:group, kind_of: [String, Integer, NilClass, FalseClass])
        # @!attribute keep_existing
        #   Keep existing files in the destination directory when unpacking.
        #   @return [Boolean]
        attribute(:keep_existing, equal_to: [true, false], default: false)
        # @!attribute source_properties
        #   Properties to pass through to the underlying download resource if
        #   using one. Merged with the array form of {#name}.
        #   @return [Hash]
        attribute(:source_properties, option_collector: true, default: lazy { name.is_a?(Array) ? (name[1] || {}) : {} })
        # @!attribute strip_components
        #   Number of intermediary directories to skip when unpacking. Works
        #   like GNU tar's --strip-components.
        #   @return [Integer]
        attribute(:strip_components, kind_of: Integer, default: 1)
        # @!attribute user
        #   User to run the unpack as.
        #   @return [String, Integer, nil, false]
        attribute(:user, kind_of: [String, Integer, NilClass, FalseClass])

        # Alias for the forgetful.
        # @api private
        alias_method :owner, :user

        # Regexp for URL-like paths.
        # @api private
        URL_PATHS = %r{^(\w+:)?//}

        # Check if the source path is a URL.
        #
        # @api private
        # @return [Boolean]
        def is_url?
          path =~ URL_PATHS
        end

        # Expand a relative file path against `Chef::Config[:file_cache_path]`.
        # For URLs it returns the cache file path.
        #
        # @api private
        # @return [String]
        def absolute_path
          if is_url?
            # Use the last path component without the query string. This might
            # result in collisions in weird cases?
            ::File.join(Chef::Config[:file_cache_path], URI(path).path.split(/\//).last)
          else
            ::File.expand_path(path, Chef::Config[:file_cache_path])
          end
        end

        private

        # Filename components to ignore.
        # @api private
        BASENAME_IGNORE = /(\.(t?(ar|gz|bz2?|xz)|zip))+$/

        # Default value for the {#destination} property
        #
        # @api private
        # @return [String]
        def default_destination
          if is_url?
            raise ValueError.new("Destination for URL-based archive #{self} must be specified explicitly")
          else
            ::File.join(::File.dirname(absolute_path), ::File.basename(path).gsub(BASENAME_IGNORE, ''))
          end
        end
      end

      # Providers can be found in archive_providers/.
    end
  end
end
