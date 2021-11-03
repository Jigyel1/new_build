# frozen_string_literal: true

require 'rails_helper'

describe 'Whenever Schedule' do # rubocop:disable RSpec/DescribeClass
  before { load 'Rakefile' }

  let(:whenever) { Whenever::JobList.new(file: Rails.root.join('config/schedule.rb').to_s) }

  it 'makes sure `rake` statements exist' do
    schedule = Whenever::Test::Schedule.new(vars: { environment: 'production' })
    expect(schedule.jobs[:rake].count).to eq(2)
  end
end
