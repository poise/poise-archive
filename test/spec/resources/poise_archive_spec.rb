#
# Copyright 2016-2017, Noah Kantrowitz
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
  context 'an absolute path' do
    context 'an implicit destination' do
      recipe do
        poise_archive '/tmp/myapp.tar'
      end

      it { is_expected.to unpack_poise_archive('/tmp/myapp.tar').with(absolute_path: '/tmp/myapp.tar', destination: '/tmp/myapp') }
    end # /context an implicit destination

    context 'an explicit destination' do
      recipe do
        poise_archive '/tmp/myapp.tar' do
          destination '/opt/myapp'
        end
      end

      it { is_expected.to unpack_poise_archive('/tmp/myapp.tar').with(absolute_path: '/tmp/myapp.tar', destination: '/opt/myapp') }
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

      it { is_expected.to unpack_poise_archive('myapp.tar').with(absolute_path: '/var/chef/cache/myapp.tar', destination: '/var/chef/cache/myapp') }
    end # /context an implicit destination

    context 'an explicit destination' do
      recipe do
        Chef::Config[:file_cache_path] = '/var/chef/cache'
        poise_archive 'myapp.tar' do
          destination '/opt/myapp'
        end
      end

      it { is_expected.to unpack_poise_archive('myapp.tar').with(absolute_path: '/var/chef/cache/myapp.tar', destination: '/opt/myapp') }
    end # /context an explicit destination
  end # /context a relative path

  context 'with .tar.gz' do
    recipe do
      poise_archive '/tmp/myapp.tar.gz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tar.gz').with(absolute_path: '/tmp/myapp.tar.gz', destination: '/tmp/myapp') }
  end # /context with .tar.gz

  context 'with .tgz' do
    recipe do
      poise_archive '/tmp/myapp.tgz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tgz').with(absolute_path: '/tmp/myapp.tgz', destination: '/tmp/myapp') }
  end # /context with .tgz

  context 'with .tar.bz2' do
    recipe do
      poise_archive '/tmp/myapp.tar.bz2'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tar.bz2').with(absolute_path: '/tmp/myapp.tar.bz2', destination: '/tmp/myapp') }
  end # /context with .tar.bz2

  context 'with .tbz2' do
    recipe do
      poise_archive '/tmp/myapp.tbz2'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tbz2').with(absolute_path: '/tmp/myapp.tbz2', destination: '/tmp/myapp') }
  end # /context with .tbz2

  context 'with .tar.xz' do
    recipe do
      poise_archive '/tmp/myapp.tar.xz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.tar.xz').with(absolute_path: '/tmp/myapp.tar.xz', destination: '/tmp/myapp') }
  end # /context with .tar.xz

  context 'with .txz' do
    recipe do
      poise_archive '/tmp/myapp.txz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.txz').with(absolute_path: '/tmp/myapp.txz', destination: '/tmp/myapp') }
  end # /context with .txz

  context 'with .zip' do
    recipe do
      poise_archive '/tmp/myapp.zip'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp.zip').with(absolute_path: '/tmp/myapp.zip', destination: '/tmp/myapp') }
  end # /context with .zip

  context 'with a hidden file' do
    recipe do
      poise_archive '/tmp/.myapp.tar'
    end

    it { is_expected.to unpack_poise_archive('/tmp/.myapp.tar').with(absolute_path: '/tmp/.myapp.tar', destination: '/tmp/.myapp') }
  end # /context with a hidden file

  context 'with a version number' do
    recipe do
      poise_archive '/tmp/myapp-1.0.0.tar'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp-1.0.0.tar').with(absolute_path: '/tmp/myapp-1.0.0.tar', destination: '/tmp/myapp-1.0.0') }
  end # /context with a version number

  context 'with a version number and .tar.gz' do
    recipe do
      poise_archive '/tmp/myapp-1.0.0.tar.gz'
    end

    it { is_expected.to unpack_poise_archive('/tmp/myapp-1.0.0.tar.gz').with(absolute_path: '/tmp/myapp-1.0.0.tar.gz', destination: '/tmp/myapp-1.0.0') }
  end # /context with a version number and .tar.gz

  context 'with a URL' do
    recipe do
      Chef::Config[:file_cache_path] = '/var/chef/cache'
      poise_archive 'http://example.com/myapp-1.0.0.zip' do
        destination '/tmp/myapp'
      end
    end

    it { is_expected.to unpack_poise_archive('http://example.com/myapp-1.0.0.zip').with(path: 'http://example.com/myapp-1.0.0.zip', absolute_path: '/var/chef/cache/aHR0cDovL2V4YW1wbGUuY29tL215YXBwLTEuMC4wLnppcA_myapp-1.0.0.zip', destination: '/tmp/myapp', merged_source_properties: {}) }
  end # /context with a URL

  context 'with a URL and name properties' do
    recipe do
      Chef::Config[:file_cache_path] = '/var/chef/cache'
      poise_archive ['http://example.com/myapp-1.0.0.zip', {retries: 0}] do
        destination '/tmp/myapp'
      end
    end

    it { is_expected.to unpack_poise_archive('http://example.com/myapp-1.0.0.zip, {:retries=>0}').with(path: 'http://example.com/myapp-1.0.0.zip', absolute_path: '/var/chef/cache/aHR0cDovL2V4YW1wbGUuY29tL215YXBwLTEuMC4wLnppcCwgezpyZXRyaWVzPT4wfQ_myapp-1.0.0.zip', destination: '/tmp/myapp', merged_source_properties: {'retries' => 0}) }
  end # /context with a URL and name properties

  context 'with a URL and source properties' do
    recipe do
      Chef::Config[:file_cache_path] = '/var/chef/cache'
      poise_archive 'http://example.com/myapp-1.0.0.zip' do
        destination '/tmp/myapp'
        source_properties do
          retries 0
        end
      end
    end

    it { is_expected.to unpack_poise_archive('http://example.com/myapp-1.0.0.zip').with(path: 'http://example.com/myapp-1.0.0.zip', absolute_path: '/var/chef/cache/aHR0cDovL2V4YW1wbGUuY29tL215YXBwLTEuMC4wLnppcA_myapp-1.0.0.zip', destination: '/tmp/myapp', merged_source_properties: {'retries' => 0}) }
  end # /context with a URL and source properties

  context 'with a URL and both properties' do
    recipe do
      Chef::Config[:file_cache_path] = '/var/chef/cache'
      poise_archive ['http://example.com/myapp-1.0.0.zip', {retries: 100}] do
        destination '/tmp/myapp'
        source_properties do
          retries 0
        end
      end
    end

    it { is_expected.to unpack_poise_archive('http://example.com/myapp-1.0.0.zip, {:retries=>100}').with(path: 'http://example.com/myapp-1.0.0.zip', absolute_path: '/var/chef/cache/aHR0cDovL2V4YW1wbGUuY29tL215YXBwLTEuMC4wLnppcCwgezpyZXRyaWVzPT4xMDB9_myapp-1.0.0.zip', destination: '/tmp/myapp', merged_source_properties: {'retries' => 100}) }
  end # /context with a URL and both properties
end
