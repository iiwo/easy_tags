# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EasyTags::DirtyMethods do
  let!(:taggable) { TaggableModel.create!(tags_list: 'awesome, epic').reload }

  shared_examples 'implements dirty when attribute changes' do
    it 'responds to .changes with changes hash' do
      expect(taggable.changes).to eq(changes_hash)
    end

    it 'responds to attribute_was with previous value' do
      expect(taggable.tags_list_was).to eq(previous_value)
    end

    it 'responds attribute_change with changes array' do
      expect(taggable.tags_list_change).to eq(changes_array)
    end

    describe 'after save' do
      let(:taggable) { TaggableModel.create!(tags_list: 'awesome, epic') }

      before do
        taggable.save!
      end

      it 'responds to .previous_changes with changes hash' do
        expect(taggable.previous_changes).to include(changes_hash)
      end
    end
  end

  shared_examples_for 'implements dirty when attributes do not change' do
    it 'is not flagged as changed' do
      expect(taggable).not_to be_tags_list_changed
    end

    it 'does not show any changes to the taggable item' do
      expect(taggable.changes).to be_empty
    end
  end

  context 'when tags_list string' do
    context 'when changed' do
      before do
        expect(taggable.changes).to be_empty
        taggable.tags_list = 'one'
      end

      it_behaves_like 'implements dirty when attribute changes' do
        let(:changes_hash) { { 'tags_list' => ['awesome,epic', 'one'] } }
        let(:changes_array) { ['awesome,epic', 'one'] }
        let(:previous_value) { 'awesome,epic' }
      end

      context 'with freshly initialized dirty object' do
        let(:reloaded_taggable) { TaggableModel.find(taggable.id) }

        before do
          reloaded_taggable.tags_list = 'one'
        end

        it { expect(taggable.changes).to eq('tags_list' => ['awesome,epic', 'one']) }
      end

      context 'when tag order changed' do
        it 'does not mark attribute' do
          taggable = TaggableModel.create(tags_list: %w[d c b a])
          taggable.tags_list = 'a,b,c,d'
          expect(taggable).not_to be_tags_list_changed
        end
      end
    end

    context 'when did not change' do
      before do
        taggable.tags_list = 'awesome, epic'
      end

      it_behaves_like 'implements dirty when attributes do not change'
    end
  end

  context 'when tags array' do
    context 'when changed' do
      before do
        expect(taggable.changes).to be_empty
        taggable.tags = ['one']
      end

      it_behaves_like 'implements dirty when attribute changes' do
        let(:changes_hash) { { 'tags_list' => ['awesome,epic', 'one'] } }
        let(:changes_array) { ['awesome,epic', 'one'] }
        let(:previous_value) { 'awesome,epic' }
      end
    end

    context 'when did not change' do
      before do
        taggable.tags = %w[awesome epic]
      end

      it_behaves_like 'implements dirty when attributes do not change'
    end

    describe '#add' do
      before do
        expect(taggable.changes).to be_empty
        taggable.tags.add('one')
      end

      it_behaves_like 'implements dirty when attribute changes' do
        let(:changes_hash) { { 'tags_list' => ['awesome,epic', 'awesome,epic,one'] } }
        let(:changes_array) { ['awesome,epic', 'awesome,epic,one'] }
        let(:previous_value) { 'awesome,epic' }
      end
    end

    describe '#remove' do
      before do
        expect(taggable.changes).to be_empty
        taggable.tags.remove('awesome')
      end

      it_behaves_like 'implements dirty when attribute changes' do
        let(:changes_hash) { { 'tags_list' => ['awesome,epic', 'epic'] } }
        let(:changes_array) { ['awesome,epic', 'epic'] }
        let(:previous_value) { 'awesome,epic' }
      end
    end

    context 'when multiple #add/#remove changes' do
      before do
        expect(taggable.changes).to be_empty
        taggable.tags.add('one')
        taggable.tags.add('two')
        taggable.tags.add('three')
        taggable.tags.remove('two')
      end

      it_behaves_like 'implements dirty when attribute changes' do
        let(:changes_hash) { { 'tags_list' => ['awesome,epic', 'awesome,epic,one,three'] } }
        let(:changes_array) { ['awesome,epic', 'awesome,epic,one,three'] }
        let(:previous_value) { 'awesome,epic' }
      end
    end
  end
end
