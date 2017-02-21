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

require 'rbconfig'

require 'serverspec'

if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  set :backend, :cmd
  set :os, :family => 'windows'
else
  set :backend, :exec
end


RSpec.shared_examples 'a poise_archive test' do |ext|
  base = "/test/#{ext}"

  describe file("#{base}/LICENSE") do
    its(:content) { is_expected.to eq "This is in the public domain.\n" }
  end
  describe file("#{base}/README") do
    its(:content) { is_expected.to eq "This is a project!\n\n" }
  end
  describe file("#{base}/src/main.c") do
    its(:content) { is_expected.to eq "int main(int argc, char **argv)\n{\n  return 0;\n}\n\n" }
  end
  describe file("#{base}/bin/run.sh") do
    its(:content) { is_expected.to eq "#!/bin/sh\necho \"Started!\"\n" }
    it { is_expected.to be_mode '755' } unless os[:family] == 'windows'
  end
  describe file("#{base}_0/myapp-1.0.0/src/main.c") do
    its(:content) { is_expected.to eq "int main(int argc, char **argv)\n{\n  return 0;\n}\n\n" }
  end
  describe file("#{base}_2/main.c") do
    its(:content) { is_expected.to eq "int main(int argc, char **argv)\n{\n  return 0;\n}\n\n" }
  end
  describe file("#{base}_user") do
    it { is_expected.to be_owned_by 'poise' }
    it { is_expected.to be_mode '755' } unless os[:family] == 'windows'
  end
  describe file("#{base}_user/README") do
    it { is_expected.to be_owned_by 'poise' }
    it { is_expected.to be_mode '644' } unless os[:family] == 'windows'
  end
  describe file("#{base}_user/bin/run.sh") do
    it { is_expected.to be_owned_by 'poise' }
    it { is_expected.to be_mode '755' } unless os[:family] == 'windows'
  end
  describe file("#{base}_http/README") do
    its(:content) { is_expected.to eq "This is a project!\n\n" }
  end
  describe file("#{base}_http/src/main.c") do
    its(:content) { is_expected.to eq "int main(int argc, char **argv)\n{\n  return 0;\n}\n\n" }
  end
end

describe 'default provider' do
  describe 'tar' do
    it_should_behave_like 'a poise_archive test', 'default/tar'
  end

  describe 'tar.gz' do
    it_should_behave_like 'a poise_archive test', 'default/tar.gz'
  end

  describe 'tar.bz2' do
    it_should_behave_like 'a poise_archive test', 'default/tar.bz2'
  end

  describe 'tar.xz' do
    it_should_behave_like 'a poise_archive test', 'default/tar.xz'
  end

  describe 'zip' do
    it_should_behave_like 'a poise_archive test', 'default/zip'
  end
end

describe 'Tar provider' do
  describe 'tar' do
    it_should_behave_like 'a poise_archive test', 'Tar/tar'
  end

  describe 'tar.gz' do
    it_should_behave_like 'a poise_archive test', 'Tar/tar.gz'
  end

  describe 'tar.bz2' do
    it_should_behave_like 'a poise_archive test', 'Tar/tar.bz2'
  end
end

describe 'GnuTar provider', if: File.exist?('/test/GnuTar') do
  describe 'tar' do
    it_should_behave_like 'a poise_archive test', 'GnuTar/tar'
  end

  describe 'tar.gz' do
    it_should_behave_like 'a poise_archive test', 'GnuTar/tar.gz'
  end

  describe 'tar.bz2' do
    it_should_behave_like 'a poise_archive test', 'GnuTar/tar.bz2'
  end

  describe 'tar.xz' do
    it_should_behave_like 'a poise_archive test', 'GnuTar/tar.xz'
  end
end

describe 'Zip provider' do
  describe 'zip' do
    it_should_behave_like 'a poise_archive test', 'Zip/zip'
  end
end

describe 'SevenZip provider', if: File.exist?('/test/SevenZip') do
  describe 'tar' do
    it_should_behave_like 'a poise_archive test', 'SevenZip/tar'
  end

  describe 'tar.gz' do
    it_should_behave_like 'a poise_archive test', 'SevenZip/tar.gz'
  end

  describe 'tar.bz2' do
    it_should_behave_like 'a poise_archive test', 'SevenZip/tar.bz2'
  end

  describe 'tar.xz' do
    it_should_behave_like 'a poise_archive test', 'SevenZip/tar.xz'
  end

  describe 'zip' do
    it_should_behave_like 'a poise_archive test', 'SevenZip/zip'
  end
end

describe 'core features' do
  describe file('/test/keep/EXISTING') do
    it { is_expected.to be_a_file }
  end
  describe file('/test/existing/EXISTING') do
    it { is_expected.to_not exist }
  end
end
