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

require 'serverspec'
set :backend, :exec

RSpec.shared_examples 'a poise_archive test' do |ext|
  base = "/test/#{ext}"

  describe file("#{base}/LICENSE") do
    its(:content) { is_expected.to eq "This is in the public domain.\n" }
  end
  describe file("#{base}/README") do
    its(:content) { is_expected.to eq "This is a project!\n\n" }
  end
  describe file("#{base}/src/main.c") do
    it { is_expected.to be_a_file }
  end
  describe file("#{base}_0/myapp-1.0.0/src/main.c") do
    it { is_expected.to be_a_file }
  end
  describe file("#{base}_2/main.c") do
    it { is_expected.to be_a_file }
  end
end

describe 'tar' do
  it_should_behave_like 'a poise_archive test', 'tar'
end

describe 'tar.gz' do
  it_should_behave_like 'a poise_archive test', 'tar.gz'
end

describe 'tar.bz2' do
  it_should_behave_like 'a poise_archive test', 'tar.bz2'
end

describe 'zip' do
  it_should_behave_like 'a poise_archive test', 'zip'
end

describe 'core features' do
  describe file('/test/user') do
    it { is_expected.to be_owned_by 'poise' }
    it { is_expected.to be_mode '700' }
  end
  describe file('/test/user/README') do
    it { is_expected.to be_owned_by 'poise' }
  end
  describe file('/test/keep/EXISTING') do
    it { is_expected.to be_a_file }
  end
  describe file('/test/existing/EXISTING') do
    it { is_expected.to_not exist }
  end
end
