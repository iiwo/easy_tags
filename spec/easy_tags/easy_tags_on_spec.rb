require 'spec_helper'

RSpec.describe 'easy_tags_on' do
  subject(:taggable) { TaggableModel.create }

  def create_tag_for(taggable:, tag_name:, context: 'bees')
    tag = EasyTags::Tag.find_or_create_by!(name: tag_name)
    taggable.taggings.create!(tag: tag, context: context)
  end

  describe 'Taggable Method Generation' do
    before(:each) do
      TaggableModel.tagging_contexts = []
      TaggableModel.easy_tags_on(:tags, :languages, :skills, :needs, :offerings)
    end

    it 'creates a class attribute for tag types' do
      expect(taggable.class).to respond_to(:tagging_contexts)
    end

    it 'have all tag types' do
      expect(taggable.class.tagging_contexts).to eq([:tags, :languages, :skills, :needs, :offerings])
    end

    it 'generates an association for each tag type' do
      expect(taggable).to respond_to(:tags, :skills, :languages)
    end

    it 'generates a tag_list accessor/setter for each tag type' do
      expect(taggable).to respond_to(:tags_list, :skills_list, :languages_list)
      expect(taggable).to respond_to(:tags_list=, :skills_list=, :languages_list=)
    end
  end

  describe 'Tagging Contexts' do
    it 'eliminates duplicate tagging contexts ' do
      TaggableModel.easy_tags_on(:skills, :skills)
      expect(TaggableModel.tagging_contexts.count(:skills)).to eq(1)
    end

    context 'when passed nil' do
      subject do
        lambda do
          TaggableModel.easy_tags_on
        end
      end

      it 'does not raise error ' do
        is_expected.to_not raise_error
      end
    end

    context 'when passed [nil]' do
      subject do
        lambda do
          TaggableModel.easy_tags_on([nil])
        end
      end

      it 'does not raise error ' do
        is_expected.to_not raise_error
      end
    end

    context 'when passed invalid options' do
      subject do
        lambda do
          TaggableModel.easy_tags_on('%#$%#@#EQESD', [:something])
        end
      end

      it 'does not raise error ' do
        is_expected.to raise_error('invalid options')
      end
    end
  end

  describe '#context_list' do

    before do
      create_tag_for(taggable: taggable, tag_name: 'bumble')
      create_tag_for(taggable: taggable, tag_name: 'busy')
      taggable.reload
    end

    it { expect(taggable.bees_list).to eq('bumble,busy') }
  end

  describe '#context' do
    before do
      create_tag_for(taggable: taggable, tag_name: 'bumble')
      create_tag_for(taggable: taggable, tag_name: 'busy')
      taggable.reload
    end

    it { expect(taggable.bees).to eq(%w[bumble busy]) }
  end

  describe '#context_list=' do
    subject do
      lambda do
        taggable.bees_list = 'bumble,busy'
        taggable.save
      end
    end

    context 'no existing tags' do
    end

    context 'with existing tags' do
    end
  end

  describe '#context=' do
  end
end