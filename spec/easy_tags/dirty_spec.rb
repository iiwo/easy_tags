require 'spec_helper'

RSpec.describe 'Dirty behavior of taggable objects' do
  context 'with un-contexted tags' do
    let(:taggable) { TaggableModel.create!(tags_list: 'awesome, epic') }

    context 'when tags_list changed' do
      before(:each) do
        expect(taggable.changes).to be_empty
        taggable.tags_list = 'one'
      end

      it 'shows changes of dirty object' do
        expect(taggable.changes).to eq({ 'tags_list' => ['awesome,epic', 'one']})
      end

      context 'freshly initialized dirty object' do
        let(:reloaded_taggable) { TaggableModel.find(taggable.id) }

        before do
          reloaded_taggable.tags_list = 'one'
        end

        it { expect(taggable.changes).to eq({ 'tags_list' => ['awesome,epic', 'one']}) }
      end

      # TODO: will_save_change_to_tags_list? spec

      it 'preserves original value' do
        expect(taggable.tags_list_was).to eq('awesome,epic')
      end

      it 'shows what the change was' do
        expect(taggable.tags_list_change).to eq(['awesome,epic', 'one'])
      end

      context 'when tag order changed' do
        it 'does not mark attribute' do
          taggable = TaggableModel.create(tags_list: %w[d c b a])
          taggable.tags_list =  'a,b,c,d'
          expect(taggable.tags_list_changed?).to be_falsy
        end
      end
    end

    context 'when tags_list is the same' do
      before do
        taggable.tags_list = 'awesome, epic'
      end

      it 'is not flagged as changed' do
        expect(taggable.tags_list_changed?).to be_falsy
      end

      it 'does not show any changes to the taggable item' do
        expect(taggable.changes).to be_empty
      end
    end
  end
end
