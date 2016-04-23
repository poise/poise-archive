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

FIXTURES_PATH = File.expand_path('../../../cookbook/files', __FILE__)

describe PoiseArchive::ArchiveProviders::GnuTar do
  step_into(:poise_archive)
  let(:archive_provider) { chef_run.poise_archive('myapp').provider_for_action(:unpack) }
  before do
    chefspec_options.update(platform: 'ubuntu', version: '14.04')
    # Stub out some stuff from the base class.
    expect(Dir).to receive(:mkdir).and_call_original
    allow(Dir).to receive(:entries).and_call_original
    allow(Dir).to receive(:entries).with('/test/myapp').and_return(%w{. ..})
  end

  context 'with a .tar path' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xvf /test/myapp-1.0.0.tar}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with a .tar path

  context 'with a .tar.gz path' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar.gz"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xzvf /test/myapp-1.0.0.tar.gz}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with a .tar.gz path

  context 'with a .tar.bz2 path' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar.bz2"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xjvf /test/myapp-1.0.0.tar.bz2}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with a .tar.bz2 path

  context 'with a .tgz path' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tgz"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xzvf /test/myapp-1.0.0.tgz}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with a .tgz path

  context 'with a .tbz2 path' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tbz2"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xjvf /test/myapp-1.0.0.tbz2}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with a .tbz2 path

  context 'with strip_components 0' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        strip_components 0
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar -xvf /test/myapp-1.0.0.tar}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
    end
  end # /context with strip_components 0

  context 'with strip_components 2' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        strip_components 2
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=2 -xvf /test/myapp-1.0.0.tar}, cwd: '/test/myapp', group: nil, user: nil)
      run_chef
    end
  end # /context with strip_components 2

  context 'with a user' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        user 'myuser'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xvf /test/myapp-1.0.0.tar}, cwd: '/test/myapp', group: nil, user: 'myuser')
      run_chef
    end
  end # /context with a user

  context 'with a group' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        group 'mygroup'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(%w{tar --strip-components=1 -xvf /test/myapp-1.0.0.tar}, cwd: '/test/myapp', group: 'mygroup', user: nil)
      run_chef
    end
  end # /context with a group
end
