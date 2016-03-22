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

require 'spec_helper'

describe PoiseArchive::ArchiveProviders::Zip do
  # step_into(:poise_archive)
  let(:archive_provider) { chef_run.poise_archive('myapp').provider_for_action(:unpack) }

  context 'with a .zip path' do
    recipe do
      poise_archive 'myapp' do
        path 'myapp.zip'
      end
    end

    it { expect(archive_provider).to be_a described_class }
  end # /context with a .zip path
end
