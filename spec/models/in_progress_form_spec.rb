# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InProgressForm, type: :model do
  let(:in_progress_form) { build(:in_progress_form) }

  describe 'form encryption' do
    it 'encrypts the form data field' do
      expect(subject).to encrypt_attr(:form_data)
    end
  end

  describe 'validations' do
    it 'validates presence of form_data' do
      expect_attr_valid(in_progress_form, :form_data)
      in_progress_form.form_data = nil
      expect_attr_invalid(in_progress_form, :form_data, "can't be blank")
    end
  end

  describe '#metadata' do
    it 'adds the form expiration time and id', run_at: '2017-06-01' do
      in_progress_form.save
      expect(in_progress_form.metadata['expiresAt']).to eq(1_501_459_200)
      expect(in_progress_form.metadata['inProgressFormId']).to be_an(Integer)
    end
    context 'when the form is 21-526EZ' do
      before { in_progress_form.form_id = '21-526EZ' }

      it 'adds a later form expiration time and id', run_at: '2017-06-01' do
        in_progress_form.save
        expect(in_progress_form.metadata['expiresAt']).to eq(1_527_811_200)
        expect(in_progress_form.metadata['inProgressFormId']).to be_an(Integer)
      end

      it 'adds a later form expiration time when a leap year', run_at: '2020-06-01' do
        in_progress_form.save
        expect(in_progress_form.metadata['expiresAt']).to eq(1_622_505_600)
      end
    end
  end

  describe '#serialize_form_data' do
    let(:form_data) do
      { a: 1 }
    end

    it 'serializes form_data as json' do
      in_progress_form.form_data = form_data
      in_progress_form.save!

      expect(in_progress_form.form_data).to eq(form_data.to_json)
    end
  end

  describe 'scopes' do
    let!(:first_record) do
      create(:in_progress_form, metadata: { submission: { hasAttemptedSubmit: true,
                                                          errors: 'foo',
                                                          errorMessage: 'bar' } })
    end
    let!(:second_record) { create(:in_progress_form, metadata: { submission: { hasAttemptedSubmit: false } }) }

    it 'includes records within scope' do
      expect(described_class.has_attempted_submit).to include(first_record)
      expect(described_class.has_errors).to include(first_record)
      expect(described_class.has_error_message).to include(first_record)
      expect(described_class.has_no_errors).to include(second_record)
    end
  end
end
