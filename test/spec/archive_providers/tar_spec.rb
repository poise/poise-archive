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

describe PoiseArchive::ArchiveProviders::Tar do
  step_into(:poise_archive)

  describe '#action_unpack' do
    let(:tar_cmd) { [] }
    let(:archive_provider) { chef_run.poise_archive('myapp').provider_for_action(:unpack) }
    before do
      allow(described_class).to receive(:mktmpdir).and_yield('/test')
      expect_any_instance_of(described_class).to receive(:poise_shell_out!).with(tar_cmd, cwd: '/test', group: nil, user: nil)
      expect_any_instance_of(described_class).to receive(:entries_at_depth).with('/test', 1).and_return(%w{/test/myapp/bin /test/myapp/src})
      expect(File).to receive(:rename).with('/test/myapp/bin', '/root/myapp/bin')
      expect(File).to receive(:rename).with('/test/myapp/src', '/root/myapp/src')
    end

    context 'with a .tar path' do
      let(:tar_cmd) { %w{tar -xvf /root/myapp.tar} }
      recipe do
        poise_archive 'myapp' do
          path '/root/myapp.tar'
        end
      end

      it { expect(archive_provider).to be_a described_class }
    end # /context with a .tar path

    context 'with a .tar.gz path' do
      let(:tar_cmd) { %w{tar -xzvf /root/myapp.tar.gz} }
      recipe do
        poise_archive 'myapp' do
          path '/root/myapp.tar.gz'
        end
      end

      it { expect(archive_provider).to be_a described_class }
    end # /context with a .tar.gz path

    context 'with a .tar.bz path' do
      let(:tar_cmd) { %w{tar -xjvf /root/myapp.tar.bz} }
      recipe do
        poise_archive 'myapp' do
          path '/root/myapp.tar.bz'
        end
      end

      it { expect(archive_provider).to be_a described_class }
    end # /context with a .tar.bz path

    context 'with a .tgz path' do
      let(:tar_cmd) { %w{tar -xzvf /root/myapp.tgz} }
      recipe do
        poise_archive 'myapp' do
          path '/root/myapp.tgz'
        end
      end

      it { expect(archive_provider).to be_a described_class }
    end # /context with a .tgz path

    context 'with a .tbz path' do
      let(:tar_cmd) { %w{tar -xjvf /root/myapp.tbz} }
      recipe do
        poise_archive 'myapp' do
          path '/root/myapp.tbz'
        end
      end

      it { expect(archive_provider).to be_a described_class }
    end # /context with a .tbz path
  end # /describe #action_unpack

  describe '#entries_at_depth' do
    let(:depth) { nil }
    subject { described_class.new(nil, nil).send(:entries_at_depth, '/test', depth) }
    before do
      allow(Dir).to receive(:entries).and_call_original
      allow(Dir).to receive(:entries).with('/test').and_return(%w{. .. a})
      allow(Dir).to receive(:entries).with('/test/a').and_return(%w{. .. aa ab})
      allow(Dir).to receive(:entries).with('/test/a/aa').and_return(%w{. .. aaa})
      allow(Dir).to receive(:entries).with('/test/a/ab').and_return(%w{. .. aba abb})
    end

    context 'with depth 0' do
      let(:depth) { 0 }
      it { is_expected.to eq %w{/test/a} }
    end # /context with depth 0

    context 'with depth 1' do
      let(:depth) { 1 }
      it { is_expected.to eq %w{/test/a/aa /test/a/ab} }
    end # /context with depth 1

    context 'with depth 2' do
      let(:depth) { 2 }
      it { is_expected.to eq %w{/test/a/aa/aaa /test/a/ab/aba /test/a/ab/abb} }
    end # /context with depth 2
  end # /describe #entries_at_depth
end
