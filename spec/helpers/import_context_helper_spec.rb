# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportContextHelper, type: :helper do
  describe '.write_tempfile_path' do
    it 'writes the tempfile path to the cache' do
      file = double('file', original_filename: 'test_file.txt', read: 'test content')
      temp_file_path = Rails.root.join('tmp', 'import_files', 'test_file.txt').to_s
      expect(Rails.cache).to receive(:write).with("import_context/#{file.original_filename}", { file_path: temp_file_path }, expires_in: 1.week)
      ImportContextHelper.write_tempfile_path(file)
    end
  end

  describe '.read_tempfile_path' do
    it 'reads the tempfile path from the cache' do
      file_name = 'test_file.txt'
      expected_path = '/tmp/test_file.txt'
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return({ file_path: expected_path })
      result = ImportContextHelper.read_tempfile_path(file_name)
      expect(result).to eq(expected_path)
    end
  end

  describe '.write_not_importing_rows' do
    it 'writes not importing rows to the cache' do
      file_name = 'test_file.txt'
      rows_hash = { 'row1' => ['data1'], 'row2' => ['data2'] }
      prev_cache = { not_importing_rows: {} }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(prev_cache)
      expect(Rails.cache).to receive(:write).with("import_context/#{file_name}", { not_importing_rows: rows_hash }, expires_in: 1.week)
      ImportContextHelper.write_not_importing_rows(file_name, rows_hash)
    end

    it 'raises ImportCacheExpiredException if cache is nil' do
      file_name = 'test_file.txt'
      rows_hash = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      expect { ImportContextHelper.write_not_importing_rows(file_name, rows_hash) }.to raise_error(ImportCacheExpiredException)
    end
  end

  describe '.read_not_importing_rows' do
    it 'reads not importing rows from the cache' do
      file_name = 'test_file.txt'
      expected_rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return({ not_importing_rows: expected_rows })
      result = ImportContextHelper.read_not_importing_rows(file_name)
      expect(result).to eq(expected_rows)
    end

    it 'raises ImportCacheExpiredException if cache is nil' do
      file_name = 'test_file.txt'
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      expect { ImportContextHelper.read_not_importing_rows(file_name) }.to raise_error(ImportCacheExpiredException)
    end
  end

  describe '.write_importing_rows' do
    it 'writes importing rows to the cache' do
      file_name = 'test_file.txt'
      rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      prev_cache = { importing_rows: {} }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(prev_cache)
      expect(Rails.cache).to receive(:write).with("import_context/#{file_name}", { importing_rows: rows }, expires_in: 1.week)
      ImportContextHelper.write_importing_rows(file_name, rows)
    end

    it 'raises ImportCacheExpiredException if cache is nil' do
      file_name = 'test_file.txt'
      rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      expect { ImportContextHelper.write_importing_rows(file_name, rows) }.to raise_error(ImportCacheExpiredException)
    end
  end

  describe '.read_importing_rows' do
    it 'reads importing rows from the cache' do
      file_name = 'test_file.txt'
      expected_rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return({ importing_rows: expected_rows })
      result = ImportContextHelper.read_importing_rows(file_name)
      expect(result).to eq(expected_rows)
    end

    it 'returns nil if cache is nil' do
      file_name = 'test_file.txt'
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      result = ImportContextHelper.read_importing_rows(file_name)
      expect(result).to be_nil
    end
  end

  describe '.write_importing_duplicate_rows' do
    it 'writes importing duplicate rows to the cache' do
      file_name = 'test_file.txt'
      rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      prev_cache = { importing_duplicate_rows: {} }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(prev_cache)
      expect(Rails.cache).to receive(:write).with("import_context/#{file_name}", { importing_duplicate_rows: rows }, expires_in: 1.week)
      ImportContextHelper.write_importing_duplicate_rows(file_name, rows)
    end

    it 'raises ImportCacheExpiredException if cache is nil' do
      file_name = 'test_file.txt'
      rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      expect { ImportContextHelper.write_importing_duplicate_rows(file_name, rows) }.to raise_error(ImportCacheExpiredException)
    end
  end

  describe '.read_importing_duplicate_rows' do
    it 'reads importing duplicate rows from the cache' do
      file_name = 'test_file.txt'
      expected_rows = { 'row1' => ['data1'], 'row2' => ['data2'] }
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return({ importing_duplicate_rows: expected_rows })
      result = ImportContextHelper.read_importing_duplicate_rows(file_name)
      expect(result).to eq(expected_rows)
    end

    it 'returns nil if cache is nil' do
      file_name = 'test_file.txt'
      expect(Rails.cache).to receive(:read).with("import_context/#{file_name}").and_return(nil)
      result = ImportContextHelper.read_importing_duplicate_rows(file_name)
      expect(result).to be_nil
    end
  end

  describe '.delete_tempfile_and_cache_path' do
    it 'deletes the tempfile path from the cache and the file from the tmp folder' do
      file_name = 'test_file.txt'
      expect(Rails.cache).to receive(:delete).with("import_context/#{file_name}")
      ImportContextHelper.delete_tempfile_and_cache_path(file_name)
    end
  end
end
