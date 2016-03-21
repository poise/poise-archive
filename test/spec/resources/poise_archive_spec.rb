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

describe PoiseArchive::Resources::PoiseArchive do
  step_into(:poise_archive)

  context 'an absolute path' do
    context 'an implicit destination' do
      recipe do
        poise_archive '/tmp/myapp.tar'
      end

      it { is_expected.to unpack_poise_archive('/tmp/myapp.tar').with(absolute_path: '/tmp/myapp.tar', absolute_destination: '/tmp/myapp') }
    end # /context an implicit destination

    context 'an explicit destination' do
      recipe do
        poise_archive '/tmp/myapp.tar' do
          destination '/opt/myapp'
        end
      end

      it { is_expected.to unpack_poise_archive('/tmp/myapp.tar').with(absolute_path: '/tmp/myapp.tar', absolute_destination: '/opt/myapp') }
    end # /context an explicit destination
  end # /context an absolute path

  context 'a relative path' do
    # Backup and restore the cache path.
    around do |ex|
      begin
        old_cache_path = Chef::Config[:file_cache_path]
        ex.run
      ensure
        Chef::Config[:file_cache_path] = old_cache_path
      end
    end

    context 'an implicit destination' do
      recipe do
        Chef::Config[:file_cache_path] = '/var/chef/cache'
        poise_archive 'myapp.tar'
      end

      it { is_expected.to unpack_poise_archive('myapp.tar').with(absolute_path: '/var/chef/cache/myapp.tar', absolute_destination: '/var/chef/cache/myapp') }
    end # /context an implicit destination

    context 'an explicit destination' do
      recipe do
        Chef::Config[:file_cache_path] = '/var/chef/cache'
        poise_archive 'myapp.tar' do
          destination '/opt/myapp'
        end
      end

      it { is_expected.to unpack_poise_archive('myapp.tar').with(absolute_path: '/var/chef/cache/myapp.tar', absolute_destination: '/opt/myapp') }
    end # /context an explicit destination
  end # /context a relative path

  context 'with a two-extension path' do
    recipe do
      poise_archive '/tmp/myapp.tar.gz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tar.gz').with(absolute_path: '/tmp/myapp.tar.gz', absolute_destination: '/tmp/myapp') }
  end # /context with a two-extension path

  context 'with a hidden file' do
    recipe do
      poise_archive '/tmp/.myapp.tar'
    end

    it { is_expected.to unpack_poise_archive('/tmp/.myapp.tar').with(absolute_path: '/tmp/.myapp.tar', absolute_destination: '/tmp/myapp') }
  end # /context with a hidden file
end
