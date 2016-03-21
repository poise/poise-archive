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

require 'chef/provider'
require 'poise'


module PoiseArchive
  module ArchiveProviders
    # The provider base class for `poise_archive`.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Base < Chef::Provider
      include Poise

      def self.provides_extension(match)
        provides(:poise_archive)
        @provides_extension = match
      end

      def self.provides?(node, resource)
        super && (!@provides_extension || @provides_extension.match(resource.path))
      end

      def action_unpack
      end
    end
  end
end
