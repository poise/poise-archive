#
# Copyright 2017, Noah Kantrowitz
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

describe PoiseArchive::ArchiveProviders::SevenZip do
  step_into(:poise_archive)
  let(:chefspec_options) { {platform: 'windows', version: '2012R2', file_cache_path: '/cache'} }
  let(:archive_provider) { chef_run.poise_archive('myapp').provider_for_action(:unpack) }
  before do
    # Stub out some stuff from the base class.
    allow(Dir).to receive(:entries).and_call_original
    allow(Dir).to receive(:entries).with('/test/myapp').and_return(%w{. ..})
    # Don't make real temp folders.
    allow(described_class).to receive(:mktmpdir).and_yield('/poisetmp')
    # Stub out what would be in the temp folder if unpacking worked.
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with(/^\/poisetmp/) {|p| %w{/poisetmp /poisetmp/myapp-1.0.0 /poisetmp/myapp-1.0.0/bin /poisetmp/myapp-1.0.0/src}.include?(p) }
    allow(Dir).to receive(:entries).with(/^\/poisetmp/) {|p| %w{. ..} + ({
      '/poisetmp' => %w{myapp-1.0.0},
      '/poisetmp/myapp-1.0.0' => %w{bin src LICENSE README},
      '/poisetmp/myapp-1.0.0/bin' => %w{run.sh},
      '/poisetmp/myapp-1.0.0/src' => %w{main.c},
    }[p] || []) }
  end

  # Because there isn't a built-in matcher for this.
  RSpec::Matchers.define :nothing_execute do |name|
    match do |chef_run|
      chef_run.execute(name).performed_actions == []
    end
  end

  context 'with defaults' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:shell_out!).with('\\cache\\seven_zip_16.04\\7z.exe x -o"\\poisetmp" "\\test\\myapp-1.0.0.tar"')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/bin', '/test/myapp/bin')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/src', '/test/myapp/src')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/LICENSE', '/test/myapp/LICENSE')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/README', '/test/myapp/README')
      run_chef
      expect(archive_provider).to be_a described_class
      expect(chef_run).to create_remote_file('/cache/7z1604-x64.exe').with(source: 'http://www.7-zip.org/a/7z1604-x64.exe')
      expect(chef_run).to nothing_execute('\\cache\\7z1604-x64.exe /S /D=\\cache\\seven_zip_16.04')
    end
  end # /context with defaults

  context 'with tar.gz archive' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar.gz"
        destination '/test/myapp'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:shell_out!).with('\\cache\\seven_zip_16.04\\7z.exe x -so "\\test\\myapp-1.0.0.tar.gz" | \\cache\\seven_zip_16.04\\7z.exe x -si -ttar -o"\\poisetmp"')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/bin', '/test/myapp/bin')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/src', '/test/myapp/src')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/LICENSE', '/test/myapp/LICENSE')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/README', '/test/myapp/README')
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with tar.gz archive

  context 'with strip_components 0' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        strip_components 0
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:shell_out!).with('\\cache\\seven_zip_16.04\\7z.exe x -o"\\poisetmp" "\\test\\myapp-1.0.0.tar"')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0', '/test/myapp/myapp-1.0.0')
      run_chef
      expect(archive_provider).to be_a described_class
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
      expect_any_instance_of(described_class).to receive(:shell_out!).with('\\cache\\seven_zip_16.04\\7z.exe x -o"\\poisetmp" "\\test\\myapp-1.0.0.tar"')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/bin/run.sh', '/test/myapp/run.sh')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/src/main.c', '/test/myapp/main.c')
      run_chef
      expect(archive_provider).to be_a described_class
    end
  end # /context with strip_components 2

  context 'with user and group' do
    recipe do
      poise_archive 'myapp' do
        path "/test/myapp-1.0.0.tar"
        destination '/test/myapp'
        user 'myuser'
        group 'mygroup'
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:shell_out!).with('\\cache\\seven_zip_16.04\\7z.exe x -o"\\poisetmp" "\\test\\myapp-1.0.0.tar"')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/bin', '/test/myapp/bin')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/src', '/test/myapp/src')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/LICENSE', '/test/myapp/LICENSE')
      expect(File).to receive(:rename).with('/poisetmp/myapp-1.0.0/README', '/test/myapp/README')
      allow(Dir).to receive(:[]).and_call_original
      expect(Dir).to receive(:[]).with('/poisetmp/**/*').and_return(%w{/poisetmp/myapp-1.0.0 /poisetmp/myapp-1.0.0/bin /poisetmp/myapp-1.0.0/src /poisetmp/myapp-1.0.0/bin/run.sh /poisetmp/myapp-1.0.0/src/main.c /poisetmp/myapp-1.0.0/LICENSE /poisetmp/myapp-1.0.0/README})
      run_chef
      expect(archive_provider).to be_a described_class
      expect(chef_run).to create_directory('/poisetmp/myapp-1.0.0').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_directory('/poisetmp/myapp-1.0.0/bin').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_directory('/poisetmp/myapp-1.0.0/src').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_file('/poisetmp/myapp-1.0.0/bin/run.sh').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_file('/poisetmp/myapp-1.0.0/src/main.c').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_file('/poisetmp/myapp-1.0.0/LICENSE').with(user: 'myuser', group: 'mygroup')
      expect(chef_run).to create_file('/poisetmp/myapp-1.0.0/README').with(user: 'myuser', group: 'mygroup')
    end
  end # /context with user and group
end
