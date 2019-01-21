require 'spec_helper'

RSpec.describe 'Dirty behavior of taggable objects' do
  context 'with un-contexted tags' do
    let(:taggable) { TaggableModel.create(tags_list: 'awesome, epic') }

    context 'when tags_list changed' do
      before(:each) do
        expect(taggable.changes).to be_empty
        taggable.tags_list = 'one'
      end

      it 'should show changes of dirty object', current: true do
        expect(taggable.changes).to eq({'tags_list' => ['awesome,epic', 'one']})
      end

      it 'should show changes of freshly initialized dirty object' do
        taggable = TaggableModel.find(taggable.id)
        taggable.tags_list = 'one'
        expect(taggable.changes).to eq({'tags_list' => ['awesome,epic', 'one']})
      end

      # TODO: will_save_change_to_tags_list? spec

      it 'preserves original value' do
        expect(taggable.tags_list_was).to eq('awesome', 'epic')
      end

      it 'shows what the change was' do
        expect(taggable.tags_list_change).to eq(['awesome,epic', 'one'])
      end

      it 'should not mark attribute if order change ' do
        taggable = TaggableModel.create(tags_list: %w(d c b a))
        taggable.tags_list =  'a,b,c,d'
        expect(taggable.tags_list_changed?).to be_falsey
      end
    end

    context 'when tags_list is the same' do
      before(:each) do
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
