# frozen_string_literal: true

NAME = {
  en: 'Liegenschaft mit x Einheiten ohne HVA',
  it: 'Liegenschaft mit x Einheiten ohne HVA',
  de: 'Liegenschaft mit x Einheiten ohne HVA',
  fr: 'Liegenschaft mit x Einheiten ohne HVA'
}.freeze

[
  { index: 0, min_apartments: 1, max_apartments: 4, name: NAME, value: 3000 },
  { index: 1, min_apartments: 5, max_apartments: 14, name: NAME, value: 2500 },
  { index: 2, min_apartments: 15, max_apartments: 24, name: NAME, value: 2000 },
  { index: 3, min_apartments: 25, max_apartments: 49, name: NAME, value: 1500 },
  { index: 4, min_apartments: 50, max_apartments: MAX_SIGNED, name: NAME, value: 1000 }
].each do |attributes|
  AdminToolkit::OfferPrice.create!(attributes)
end
