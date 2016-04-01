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

describe PoiseArchive::ArchiveProviders::Tar do
  step_into(:poise_archive)

  describe '#action_unpack' do
    let(:archive_provider) { chef_run.poise_archive('myapp').provider_for_action(:unpack) }
    before do
      # allow(described_class).to receive(:mktmpdir).and_yield('/test')
      expect(Dir).to receive(:mkdir).and_call_original
      allow(Dir).to receive(:entries).and_call_original
      allow(Dir).to receive(:entries).with('/test/myapp').and_return(%w{. ..})
      # expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(tar_cmd, cwd: '/test', group: nil, user: nil)
      # expect_any_instance_of(described_class).to receive(:entries_at_depth).with('/test', 1).and_return(%w{/test/myapp/bin /test/myapp/src})
      # expect(File).to receive(:rename).with('/test/myapp/bin', '/root/myapp/bin')
      # expect(File).to receive(:rename).with('/test/myapp/src', '/root/myapp/src')
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/test/myapp-1.0.0.tar', 'rb') { File.open(File.join(FIXTURES_PATH, 'myapp-1.0.0.tar')) }
      allow(File).to receive(:open).with('/test/myapp-1.0.0.tar.gz', 'rb') { File.open(File.join(FIXTURES_PATH, 'myapp-1.0.0.tar.gz')) }
      allow(File).to receive(:open).with('/test/myapp-1.0.0.tgz', 'rb') { File.open(File.join(FIXTURES_PATH, 'myapp-1.0.0.tar.gz')) }
      allow(File).to receive(:open).with('/test/myapp-1.0.0.tar.bz2', 'rb') { File.open(File.join(FIXTURES_PATH, 'myapp-1.0.0.tar.bz2')) }
      allow(File).to receive(:open).with('/test/myapp-1.0.0.tbz2', 'rb') { File.open(File.join(FIXTURES_PATH, 'myapp-1.0.0.tar.bz2')) }
    end

    RSpec.shared_examples 'a poise_archive test' do |ext|
      recipe do
        poise_archive 'myapp' do
          path "/test/myapp-1.0.0.#{ext}"
          destination '/test/myapp'
        end
      end

      def expect_file(path, content, mode)
        fake_file = double("file for #{path}")
        expect(fake_file).to receive(:write).with(content)
        allow(File).to receive(:open).with(path, 'wb', mode).and_yield(fake_file)
        expect(FileUtils).to receive(:chown).with(nil, nil, path)
      end

      it do
        expect_file('/test/myapp/LICENSE', "This is in the public domain.\n", 0644)
        expect_file('/test/myapp/README', "This is a project!\n\n", 0644)
        expect(Dir).to receive(:mkdir).with('/test/myapp/src', 0755)
        expect(FileUtils).to receive(:chown).with(nil, nil, '/test/myapp/src')
        expect_file('/test/myapp/src/main.c', "int main(int argc, char **argv)\n{\n  return 0;\n}\n\n", 0644)
        run_chef
        expect(archive_provider).to be_a described_class
      end
    end

    context 'with a .tar path' do
      it_should_behave_like 'a poise_archive test', 'tar'
    end # /context with a .tar path

    context 'with a .tar.gz path' do
      it_should_behave_like 'a poise_archive test', 'tar.gz'
    end # /context with a .tar.gz path

    context 'with a .tar.bz2 path' do
      it_should_behave_like 'a poise_archive test', 'tar.bz2'
    end # /context with a .tar.bz2 path

    context 'with a .tgz path' do
      it_should_behave_like 'a poise_archive test', 'tgz'
    end # /context with a .tgz path

    context 'with a .tbz2 path' do
      it_should_behave_like 'a poise_archive test', 'tbz2'
    end # /context with a .tbz2 path
  end # /describe #action_unpack
end
