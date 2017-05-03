require "spec_helper"

describe Lita::Handlers::Cthulhu, lita_handler: true do
end

describe 'routes' do
  it { is_expected.to route("Lita rlyeh") }
  it { is_expected.to route("Lita Rlyeh") }
end
