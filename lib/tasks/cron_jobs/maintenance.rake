# frozen_string_literal: true

namespace :cron_jobs do
  namespace :maintenance do
    desc 'periodically cleanup import files older than one week'
    task import_files_cleanup: :environment do
      require 'fileutils'

      directory = Rails.root.join('tmp', 'import')
      cutoff_time = 1.week.ago

      if Dir.exist?(directory)
        Dir.foreach(directory) do |file|
          file_path = File.join(directory, file)
          if File.file?(file_path) && File.mtime(file_path) < cutoff_time
            FileUtils.rm(file_path)
            # puts "Deleted: #{file_path}"
          end
        end
      else
        puts "Directory #{directory} does not exist."
      end
    end
  end
end
