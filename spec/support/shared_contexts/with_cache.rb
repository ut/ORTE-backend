# frozen_string_literal: true

RSpec.shared_context('with cache', :with_cache) do
  # Inclusion of this context enables and mocks cache.
  # Allows Rails.cache to behave just like it would on dev and prod

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end
end
