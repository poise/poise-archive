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

require 'poise_archive/archive_providers/base'


module PoiseArchive
  module ArchiveProviders
    # The `zip` provider class for `poise_archive` to install from ZIP archives.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Zip < Base
      provides_extension(/\.zip$/)

      private

      def unpack_archive
        check_rubyzip
        unpack_zip
        chown_entries if new_resource.user || new_resource.group
      end

      def check_rubyzip
        require 'zip'
      rescue LoadError
        notifying_block do
          install_rubyzip
        end
        require 'zip'
      end

      def install_rubyzip
        chef_gem 'rubyzip'
      end

      def unpack_zip
        @zip_entry_paths = []
        ::Zip::File.open(new_resource.path) do |zip_file|
          zip_file.each do |entry|
            entry_name = entry.name.split(/\//).drop(new_resource.strip_components).join('/')
            # If strip_components wiped out the name, don't process this entry.
            next if entry_name.empty?
            entry_path = ::File.join(new_resource.destination, entry_name)
            entry.extract(entry_path)
            @zip_entry_paths << [entry.directory? ? :directory : entry.file? ? :file : :link, entry_path]
          end
        end
      end

      def chown_entries
        paths = @zip_entry_paths
        notifying_block do
          paths.each do |type, path|
            send(type, path) do
              group new_resource.group
              owner new_resource.user
            end
          end
        end
      end

    end
  end
end
