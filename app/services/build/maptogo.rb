# frozen_string_literal: true

require 'open3'
require 'fileutils'
include ActionView::Helpers::DateHelper
include ActionView::Helpers::NumberHelper

class Build::Maptogo
  def initialize(current_user, map, layer)
    @current_user = current_user
    @map = map
    @layer = layer
  end

  def build
    build_config = Rails.application.config_for('build/maptogo').with_indifferent_access['commands']
    version = Rails.application.config_for('build/maptogo').with_indifferent_access['version']

    meta = initialize_meta(version)
    data = {}
    build_start = Time.now

    build_log = BuildLog.new(map_id: @map.id, layer_id: @layer.id)
    # build_log.status = 'STARTED'

    places = @layer.places.published

    rand_id = SecureRandom.uuid

    client_directory = "client_#{rand_id}"
    tmp_file = "tmp/client_#{rand_id}.json"
    directory_client = "tmp/#{client_directory}"
    directory_to_zip = "tmp/#{client_directory}/dist/"
    output_file = "public/#{client_directory}.zip"
    images_tmp_folder = "tmp/#{client_directory}_images"

    layer, images_on_disc = generate_layer_json(@layer)
    File.write(tmp_file, JSON.generate(layer))

    FileUtils.mkdir_p images_tmp_folder

    images_on_disc.each do |file_hash|
      dest_folder = "#{images_tmp_folder}/#{file_hash['filename']}"
      FileUtils.cp(file_hash['disk'], dest_folder)
    end

    if build_config.length.positive?
      step_count = build_config.count
      BuildChannel.broadcast_to(
        @current_user,
        {
          content: "Build process started (#{build_config.count} Steps)",
          status: 'start',
          step_count: step_count,
          duration: time_ago_in_words(build_start, include_seconds: true)
        }
      )

      build_config.each_with_index do |command, index|
        BuildChannel.broadcast_to(
          @current_user,
          {
            index: index,
            status: 'pre-command',
            duration: time_ago_in_words(build_start, include_seconds: true),
            content: command['label'].to_s,
            step_count: step_count
          }
        )
        cmd = command['cmd'].gsub('CLIENT_PATH', client_directory)
        cmd = cmd.gsub('JSON_FILE', tmp_file)
        cmd = cmd.gsub('IMAGE_FILE_DIRECTORY', images_tmp_folder)
        Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
          sleep 4
          BuildChannel.broadcast_to(
            @current_user,
            {
              index: index,
              status: 'command',
              duration: time_ago_in_words(build_start, include_seconds: true),
              content: command['label'].to_s,
              step_count: step_count,
              command: cmd,
              detail: stdout.read,
              error: stderr.read,
              cmd_status: wait_thr.value.to_s
            }
          )
        end
      end

      filesize = 0
      FileUtils.rm_rf(images_tmp_folder)
      if Dir.exist?(directory_to_zip)
        zf = ZipFileGenerator.new(directory_to_zip, output_file)
        zf.write
        filesize = number_to_human_size(File.size(Pathname.new(output_file)))
      end
      FileUtils.rm_rf(directory_client)

      BuildChannel.broadcast_to(
        @current_user,
        {
          index: 99,
          status: 'finished',
          duration: "#{((Time.current - build_start) / 1.second).round} seconds",
          content: "/#{client_directory}.zip",
          step_count: step_count,
          filesize: filesize
        }
      )
      build_log.output = "/#{client_directory}.zip"
      build_log.size = filesize
      build_log.version = 'x.x.x'
      # build_log.status = 'FINISHED'

      build_log.save
    end
    result = { meta: meta, data: data }
  end

  def generate_layer_json(layer, image_path = '/images/')
    json_data = ApplicationController.new.render_to_string(template: 'public/layers/show', formats: :json, locals: { map: layer.map, layer: layer, places: layer.places.published })

    layer = JSON.parse(json_data, { symbolize_names: true })
    places = layer[:layer][:places]
    images_on_disc = []
    places.each do |place|
      images = place[:images]
      images.each do |image|
        image[:image_url] = image_path + image[:image_filename].to_s
        images_on_disc << { 'filename' => image[:image_filename], 'disk' => Rails.root.to_s + image[:image_on_disk] } unless image[:image_on_disk].nil?
      end
    end
    [layer, images_on_disc]
  end

  private

  def generate_tgz(file)
    content = File.read(file)
    ActiveSupport::Gzip.compress(content)
  end

  def initialize_meta(version)
    {
      version: version || '1.0.0',
      created_at: DateTime.current.to_s
    }
  end
end
