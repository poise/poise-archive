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
    end
  end
end
