# frozen_string_literal: true

require 'fileutils'
require 'erb'

# Function to read a directory and store its structure in a hash
def read_directory(directory)
  structure = {}
  Dir.foreach(directory) do |item|
    next if ['.', '..'].include?(item)

    path = File.join(directory, item)
    if File.directory?(path)
      structure[item] = read_directory(path)

    # end_with .js or js.erb
    elsif item.end_with?('.js.erb') || item.end_with?('.js')
      structure[item] = analyze_file(path)
    end
  end
  structure
end

# Function to analyze a JavaScript file and count lines and code lines
def analyze_file(file_path)
  total_lines = 0
  code_lines = 0
  File.readlines(file_path).each do |line|
    total_lines += 1
    code_lines += 1 unless line.strip.empty? || line.strip.start_with?('//')
  end
  { total_lines: total_lines, code_lines: code_lines }
end

# Function to generate summary
def generate_summary(structure)
  total_files = 0
  total_lines = 0
  total_code_lines = 0

  structure.each_value do |value|
    if value.is_a?(Hash) && value[:total_lines]
      total_files += 1
      total_lines += value[:total_lines]
      total_code_lines += value[:code_lines]
    elsif value.is_a?(Hash)
      sub_summary = generate_summary(value)
      total_files += sub_summary[:total_files]
      total_lines += sub_summary[:total_lines]
      total_code_lines += sub_summary[:total_code_lines]
    end
  end

  { total_files: total_files, total_lines: total_lines, total_code_lines: total_code_lines }
end

# Function to generate HTML report
def generate_html(structure, summary)
  template = <<-HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>JavaScript Files Summary</title>
    <style>
      body { font-family: Arial, sans-serif; }
      table { width: 100%; border-collapse: collapse; }
      th, td { border: 1px solid #ddd; padding: 8px; }
      th { background-color: #f2f2f2; }
      th, td { text-align: left; }
    </style>
  </head>
  <body>
    <h1>JavaScript Files Summary</h1>
    <table>
      <thead>
        <tr>
          <th>File</th>
          <th>Total Lines</th>
          <th>Code Lines</th>
        </tr>
      </thead>
      <tbody>
        <%= generate_html_table(structure) %>
      </tbody>
      <tfoot>
        <tr>
          <th>Total</th>
          <th><%= summary[:total_lines] %></th>
          <th><%= summary[:total_code_lines] %></th>
        </tr>
      </tfoot>
    </table>
  </body>
  </html>
  HTML

  renderer = ERB.new(template)
  renderer.result(binding)
end

# Function to generate HTML table rows
def generate_html_table(structure, path = '')
  rows = ''
  # sort structure by key
  structure = structure.sort.to_h

  structure.each do |key, value|
    if value.is_a?(Hash) && value[:total_lines]
      rows += "<tr><td>#{File.join(path, key)}</td><td>#{value[:total_lines]}</td><td>#{value[:code_lines]}</td></tr>"
    elsif value.is_a?(Hash)
      rows += generate_html_table(value, File.join(path, key))
    end
  end
  rows
end

# Main execution
directory = './app/assets/javascripts' # Specify your directory here
structure = read_directory(directory)
summary = generate_summary(structure)
html_report = generate_html(structure, summary)

# Write HTML report to file
# add a timestamp to the file name
timestamp = Time.now.strftime('%Y%m%d%H%M')
File.write("analyze_js_report_#{timestamp}.html", html_report)

# Print summary to console
puts "Total files: #{summary[:total_files]}"
puts "Total lines: #{summary[:total_lines]}"
puts "Total code lines: #{summary[:total_code_lines]}"
