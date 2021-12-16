# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateOfferContent do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:params) { { title: { en: 'Test' }, content: { en: 'Test_test' } } }

  describe '.resolve' do
    context 'with permissions' do
      it 'creates the offer_content record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createOfferContent)
        expect(errors).to be_nil
        expect(OpenStruct.new(response.offerContent)).to have_attributes(
          title: { en: 'Test' }, content: { en: 'Test_test' }
        )
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createOfferContent)
        expect(response.offerContent).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        createOfferContent(input: {
        attributes: {
          title: { en: #{args[:title][:en]} },
          content: { en: #{args[:content][:en]} }
        }
        }){ offerContent { content title } }
      }
    GQL
  end
end
