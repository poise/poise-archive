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

require 'tmpdir'

require 'poise_archive/archive_providers/base'


module PoiseArchive
  module ArchiveProviders
    # The `tar` provider class for `poise_archive` to install from TAR archives.
    #
    # @see PoiseArchive::Resources::PoiseArchive::Resource
    # @provides poise_archive
    class Tar < Base
      provides_extension(/\.t(ar|gz|bz|xz)/)

      # `unpack` action for `poise_archive`. Unpack a TAR archive.
      #
      # @return [void]
      def action_unpack
        notifying_block do
          install_prereqs
        end
        unpack_archive
      end

      private

      # Install any needed prereqs.
      #
      # @return [void]
      def install_prereqs
        # Various platforms that either already come with tar or that we don't
        # want to try installing it on yet (read: Windows). This is mostly here
        # for minimalist Linux container images, most normal Linux servers have
        # all of these already.
        return if node.platform_family?('windows', 'mac_os_x', 'aix', 'solaris2')
        utils = ['tar']
        utils << 'bzip2' if new_resource.path =~ /\.t?bz/
        utils << 'xz-utils' if new_resource.path =~ /\.t?xz/
        package utils
      end

      # Unpack the archive and process `strip_components`.
      #
      # @return [void]
      def unpack_archive
        # Build the tar command. -J for xz isn't going to work on non-GNU tar,
        # cry me a river.
        cmd = %w{tar}
        cmd << if new_resource.path =~ /\.t?gz/
          '-xzvf'
        elsif new_resource.path =~ /\.t?bz/
          '-xjvf'
        elsif new_resource.path =~ /\.t?xz/
          '-xJvf'
        else
          '-xvf'
        end
        cmd << new_resource.path

        # Create a temp directory to unpack in to. Do I want to try and force
        # this to be on the same filesystem as the target?
        self.class.mktmpdir do |dir|
          # Run the unpack into the temp dir.
          poise_shell_out!(cmd, cwd: dir, group: new_resource.group, user: new_resource.user)

          # Re-implementation of the logic for tar --strip-components because
          # that option isn't part of non-GNU tar (read: Solaris and AIX).
          entries_at_depth(dir, new_resource.strip_components).each do |source|
            # At some point this might need to fall back to a real copy.
            ::File.rename(source, ::File.join(new_resource.absolute_destination, ::File.basename(source)))
          end
        end
      end

      # Find the absolute paths for entries under a path at a depth.
      #
      # @param path [String] Base path to search under.
      # @param depth [Integer] Number of intermediary directories to skip.
      # @return [Array<String>]
      def entries_at_depth(path, depth)
        entries = [path]
        current_depth = 0
        while current_depth <= depth
          entries.map! do |ent|
            Dir.entries(ent).select {|e| e != '.' && e != '..' }.map {|e| ::File.join(ent, e) }
          end
          entries.flatten!
          current_depth += 1
        end
        entries
      end

      # Indirection so I can stub this for testing without breaking RSpec.
      def self.mktmpdir(*args, &block)
        Dir.mktmpdir(*args, &block)
      end

    end
  end
end
