class EtlBase
  def self.call(current_user: nil, input:)
    new.call(current_user: current_user, input: input)
  end

  private

  def import(current_user, sheet)
    Kiba.run(yield)
  end
end
