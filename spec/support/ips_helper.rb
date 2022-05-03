# frozen_string_literal: true

module IpsHelper
  # defaults to 100 ips
  def perform_atleast
    atleast = ENV.fetch('PERFORM_AT_LEAST', nil)
    atleast ? atleast.to_f : 100
  end

  # defaults to 200 ms
  def perform_within
    within = ENV.fetch('PERFORM_WITHIN', nil)
    within ? within.to_f : 0.2
  end

  # defaults to 100 ms
  def warmup_for
    warmup = ENV.fetch('WARMUP_FOR', nil)
    warmup ? warmup.to_f : 0.1
  end
end
