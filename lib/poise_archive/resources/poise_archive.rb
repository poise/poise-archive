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
      class Resource < Chef::Resource
        include Poise
        provides(:poise_archive)
        actions(:unpack)

        # @!attribute path
        #   Path to the archive. If relative, it is taken as a file inside
        #   `Chef::Config[:file_cache_path]`.
        #   @return [String]
        attribute(:path, kind_of: String, name_attribute: true)
        # @!attribute destination
        #   Path to unpack the archive to. If not specified, the path of the
        #   archive without the file extension is used.
        #   @return [String, nil, false]
        attribute(:destination, kind_of: [String, NilClass, FalseClass])
        # @!attribute group
        #   Group to run the unpack as.
        #   @return [String, Integer, nil, false]
        attribute(:group, kind_of: [String, Integer, NilClass, FalseClass])
        # @!attribute keep_existing
        #   Keep existing files in the destination directory when unpacking.
        #   @return [Boolean]
        attribute(:keep_existing, equal_to: [true, false], default: false)
        # @!attribute strip_components
        #   Number of intermediary directories to skip when unpacking. Works
        #   like GNU tar's --strip-components.
        #   @return [Integer]
        attribute(:strip_components, kind_of: Integer, default: 1)
        # @!attribute group
        #   User to run the unpack as.
        #   @return [String, Integer, nil, false]
        attribute(:user, kind_of: [String, Integer, NilClass, FalseClass])

        def absolute_path
          ::File.expand_path(path, Chef::Config[:file_cache_path])
        end

        def absolute_destination
          destination || begin
            basename = ::File.basename(path)
            ::File.join(::File.dirname(absolute_path), basename.split(/\./).find {|part| !part.empty? } || basename)
          end
        end
      end

      # Providers can be found in archive_providers/.
    end
  end
end
