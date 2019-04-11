require 'spec_helper'

RSpec.describe 'context methods' do
  subject(:taggable) { TaggableModel.create }

  def create_tag_for(taggable:, tag_name:, context: 'bees')
    tag = EasyTags::Tag.find_or_create_by!(name: tag_name)
    taggable.taggings.create!(tag: tag, context: context)
  end

  describe '#context_list' do
    before do
      create_tag_for(taggable: taggable, tag_name: 'bumble')
      create_tag_for(taggable: taggable, tag_name: 'busy')
      taggable.reload
    end

    it 'returns tag names string' do
      expect(taggable.bees_list).to eq('bumble,busy')
    end
  end

  describe '#context' do
    before do
      create_tag_for(taggable: taggable, tag_name: 'bumble')
      create_tag_for(taggable: taggable, tag_name: 'busy')
      taggable.reload
    end

    it 'returns tag names array' do
      expect(taggable.bees).to eq(%w[bumble busy])
    end
  end

  shared_examples 'a proper assignment' do
    describe 'unpersisted' do
      it 'sets proper context_list value' do
        expect(taggable.bees_list).to eq('bumble,busy')
      end

      it 'sets proper context value' do
        expect(taggable.bees).to eq(%w[bumble busy])
      end
    end

    describe 'persisted' do
      subject(:reloaded_taggable) { TaggableModel.find(taggable.id) }

      it 'sets proper context_list value' do
        expect(reloaded_taggable.bees_list).to eq('bumble,busy')
      end

      it 'sets proper context value' do
        expect(reloaded_taggable.bees).to eq(%w[bumble busy])
      end
    end
  end

  describe '#context_list=' do
    context 'return value' do
      it 'removes duplicates' do
        expect(taggable.public_send(:bees_list=, 'cool, angry, cool, cool')).to eq('cool,angry')
      end
    end

    context 'no existing tags' do
      before do
        taggable.bees_list = 'bumble, busy'
        taggable.save!
      end

      it_behaves_like 'a proper assignment'
    end

    context 'with existing tags' do
      before do
        taggable.bees_list = 'cool, angry'
        taggable.reload

        taggable.bees_list = 'bumble, busy'
        taggable.save!
      end

      it_behaves_like 'a proper assignment'
    end

    context 'removing tags' do
      subject(:taggable) { TaggableModel.create(bees: 'bumble,busy') }

      before do
        taggable.bees_list = 'bumble, busy'
        taggable.save!
        taggable.bees_list = 'cool, angry'
      end

      it 'sets proper context_list value' do
        expect(taggable.bees_list).to eq('cool,angry')
      end

      it 'sets proper context value' do
        expect(taggable.bees).to eq(%w[cool angry])
      end
    end
  end

  describe '#context=' do
    context 'return value' do
      it 'removes duplicates' do
        expect(taggable.public_send(:bees=, %w[cool angry cool cool])).to eq(%w[cool angry])
      end
    end

    context 'no existing tags' do
      before do
        taggable.bees = %w[bumble busy]
        taggable.save!
      end

      it_behaves_like 'a proper assignment'
    end

    context 'with existing tags' do
      before do
        taggable.bees = %w[cool angry]
        taggable.reload

        taggable.bees = %w[bumble busy]
        taggable.save!
      end

      it_behaves_like 'a proper assignment'
    end

    context 'removing tags' do
      subject(:taggable) { TaggableModel.create(bees: 'bumble,busy') }

      before do
        taggable.bees = %w[bumble busy]
        taggable.save!
        taggable.bees = %w[cool angry]
      end

      it 'sets proper context_list value' do
        expect(taggable.bees_list).to eq('cool,angry')
      end

      it 'sets proper context value' do
        expect(taggable.bees).to eq(%w[cool angry])
      end
    end
  end
end
