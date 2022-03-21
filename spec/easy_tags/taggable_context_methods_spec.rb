# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EasyTags::TaggableContextMethods do
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

  describe '#context_tags' do
    describe 'eager loading' do
      before do
        10.times do
          taggable = TaggableModel.create
          create_tag_for(taggable: taggable, tag_name: 'bumble')
        end
      end

      it 'preloads tags' do
        expect do
          TaggableModel.includes(:bees_tags).map do |tagabble|
            tagabble.bees.to_s
          end
        end.to make_database_queries(count: 2..3) # 5.1 only makes 2 queries
      end
    end

    describe 'association cache' do
      before do
        taggable.bees_list = 'bumble, busy'
        taggable.save!
      end

      it 'resets association cache' do
        expect(taggable.bees_tags.map(&:to_s)).to eq(%w[bumble busy])
      end
    end
  end

  describe '#context_list_persisted' do
    before do
      taggable.bees_list = 'bumble, busy'
      taggable.save!
      taggable.bees_list = 'cool, angry'
    end

    it 'returns persisted tags string' do
      expect(taggable.bees_list_persisted).to eq('bumble,busy')
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
    context 'with duplicates' do
      it 'removes duplicates' do
        expect(taggable.public_send(:bees_list=, 'cool, angry, cool, cool')).to eq('cool,angry')
      end
    end

    context 'with no existing tags' do
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

    context 'when removing tags' do
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
    context 'with duplicates' do
      it 'removes duplicates' do
        expect(taggable.public_send(:bees=, %w[cool angry cool cool])).to eq(%w[cool angry])
      end
    end

    context 'with no existing tags' do
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

    context 'when removing tags' do
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
