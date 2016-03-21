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

        attribute(:path, name_attribute: true)
        attribute(:destination, kind_of: [String, NilClass, FalseClass])
        attribute(:group) # TODO: verify
        attribute(:user)

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
