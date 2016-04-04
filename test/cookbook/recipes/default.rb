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
%w{tar tar.gz tar.bz2 zip}.each do |ext|
  cookbook_file "/test/myapp-1.0.0.#{ext}" do
    source "myapp-1.0.0.#{ext}"
  end

  poise_archive "/test/myapp-1.0.0.#{ext}" do
    destination "/test/#{ext}"
  end

  poise_archive "/test/myapp-1.0.0.#{ext}_0" do
    path "/test/myapp-1.0.0.#{ext}"
    destination "/test/#{ext}_0"
    strip_components 0
  end

  poise_archive "/test/myapp-1.0.0.#{ext}_2" do
    path "/test/myapp-1.0.0.#{ext}"
    destination "/test/#{ext}_2"
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
