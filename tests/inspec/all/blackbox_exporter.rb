# encoding: utf-8
# author: Mesaguy

describe file('/opt/prometheus/exporters/blackbox_exporter/active') do
    it { should be_symlink }
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'prometheus' }
end

describe file('/opt/prometheus/exporters/blackbox_exporter/active/blackbox_exporter') do
    it { should be_file }
    it { should be_executable }
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'prometheus' }
end

# Verify the 'blackbox_exporter' service is running
control '01' do
  impact 1.0
  title 'Verify blackbox_exporter service'
  desc 'Ensures blackbox_exporter service is up and running'
  describe service('blackbox_exporter') do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end
end

describe processes(Regexp.new("^/opt/prometheus/exporters/blackbox_exporter/([0-9.]+|[0-9.]+__go-[0-9.]+)/blackbox_exporter")) do
    it { should exist }
    its('entries.length') { should eq 1 }
    its('users') { should include 'prometheus' }
end

describe port(9115) do
    it { should be_listening }
end

describe http('http://127.0.0.1:9115/metrics') do
    its('status') { should cmp 200 }
    its('body') { should match /blackbox_exporter_build_info/ }
end
