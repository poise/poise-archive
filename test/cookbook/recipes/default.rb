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

# Holding directory for fixtures.
directory '/test' do
  mode '777'
end

# Tests for each fixture file.
[
  {ext: 'tar', provider: nil},
  {ext: 'tar.gz', provider: nil},
  {ext: 'tar.bz2', provider: nil},
  {ext: 'zip', provider: nil},
  {ext: 'tar', provider: PoiseArchive::ArchiveProviders::Tar},
  {ext: 'tar.gz', provider: PoiseArchive::ArchiveProviders::Tar},
  {ext: 'tar.bz2', provider: PoiseArchive::ArchiveProviders::Tar},
  {ext: 'tar', provider: PoiseArchive::ArchiveProviders::GnuTar, only_if: proc { node['os'] == 'linux' }},
  {ext: 'tar.gz', provider: PoiseArchive::ArchiveProviders::GnuTar, only_if: proc { node['os'] == 'linux' }},
  {ext: 'tar.bz2', provider: PoiseArchive::ArchiveProviders::GnuTar, only_if: proc { node['os'] == 'linux' }},
  {ext: 'zip', provider: PoiseArchive::ArchiveProviders::Zip},
].each do |test|
  next if test[:only_if] && !test[:only_if].call
  test_base = "/test/#{test[:provider].to_s.split('::').last || 'default'}"
  directory test_base do
    mode '777'
  end

  cookbook_file "#{test_base}/myapp-1.0.0.#{test[:ext]}" do
    source "myapp-1.0.0.#{test[:ext]}"
  end

  poise_archive "#{test_base}/myapp-1.0.0.#{test[:ext]}" do
    destination "#{test_base}/#{test[:ext]}"
    provider test[:provider] if test[:provider]
  end

  poise_archive "#{test_base}/myapp-1.0.0.#{test[:ext]}_0" do
    path "#{test_base}/myapp-1.0.0.#{test[:ext]}"
    destination "#{test_base}/#{test[:ext]}_0"
    provider test[:provider] if test[:provider]
    strip_components 0
  end

  poise_archive "#{test_base}/myapp-1.0.0.#{test[:ext]}_2" do
    path "#{test_base}/myapp-1.0.0.#{test[:ext]}"
    destination "#{test_base}/#{test[:ext]}_2"
    provider test[:provider] if test[:provider]
    strip_components 2
  end
end

# Some general tests for core features.
# Test user-specific unpacking.
group 'poise' do
  system true
end

user 'poise' do
  group 'poise'
  system true
end

cookbook_file '/test/myapp-1.0.0.tar' do
  source 'myapp-1.0.0.tar'
end

directory '/test/user' do
  group 'poise'
  mode '700'
  owner 'poise'
end

poise_archive '/test/myapp-1.0.0.tar' do
  destination '/test/user'
  user 'poise'
end

# Test keep_existing true.
directory '/test/keep'

file '/test/keep/EXISTING'

poise_archive '/test/myapp-1.0.0.tar' do
  destination '/test/keep'
  keep_existing true
end

# Test keep_existing false.
directory '/test/existing'

file '/test/existing/EXISTING'

poise_archive '/test/myapp-1.0.0.tar' do
  destination '/test/existing'
end
