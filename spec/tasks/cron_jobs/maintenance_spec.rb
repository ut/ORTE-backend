# frozen_string_literal: true

# spec/tasks/cron_jobs/maintenance_spec.rb
require 'rails_helper'
require 'rake'

RSpec.describe 'cron_jobs:maintenance:import_files_cleanup' do
  let(:task_name) { 'cron_jobs:maintenance:import_files_cleanup' }
  let(:task) { Rake::Task[task_name] }
  let(:directory) { Rails.root.join('tmp', 'import') }

  before do
    Rake.application.rake_require('tasks/cron_jobs/maintenance')
    Rake::Task.define_task(:environment)
    FileUtils.mkdir_p(directory)
  end

  after do
    FileUtils.rm_rf(directory)
    task.reenable # Allows the task to be invoked multiple times
  end

  it 'removes files older than one week' do
    old_file = File.join(directory, 'old_file.txt')
    new_file = File.join(directory, 'new_file.txt')

    File.write(old_file, 'old file content')
    File.utime(2.weeks.ago.to_time, 2.weeks.ago.to_time, old_file)

    File.write(new_file, 'new file content')
    File.utime(Time.now, Time.now, new_file)

    expect(File.exist?(old_file)).to be true
    expect(File.exist?(new_file)).to be true

    task.invoke

    expect(File.exist?(old_file)).to be false
    expect(File.exist?(new_file)).to be true
  end

  it 'outputs a message if the directory does not exist' do
    FileUtils.rm_rf(directory)

    expect { task.invoke }.to output(/Directory .* does not exist\./).to_stdout
  end
end
