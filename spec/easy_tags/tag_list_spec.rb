require 'spec_helper'

RSpec.describe EasyTags::TagList do
  let(:tag_list) { EasyTags::TagList.new(%w[bumble busy]) }

  it { expect(tag_list).to include('bumble', 'busy') }

  context 'when tag list given' do
    let(:tag_list) { EasyTags::TagList.new('bumble,busy') }

    it { expect(tag_list).to include('bumble', 'busy') }
  end

  describe '#add' do
    context 'with single tag name' do
      before { tag_list.add('cool') }

      it { expect(tag_list).to include('bumble', 'busy', 'cool') }
    end

    context 'with array of values' do
      before { tag_list.add(%w[cool fast]) }

      it { expect(tag_list).to include('bumble', 'busy', 'cool', 'fast') }
    end

    context 'with another tag list' do
      let(:other_tag_list) { EasyTags::TagList.new(%w[cool fast]) }
      before { tag_list.add(other_tag_list) }

      it { expect(tag_list).to include('bumble', 'busy', 'cool', 'fast') }
    end

    context 'with duplicates' do
      before { tag_list.add(%w[bumble busy]) }

      it { expect(tag_list).to eq(%w[bumble busy]) }
    end

    context 'with symbols' do
      before { tag_list.add(%i[bumble busy]) }

      it { expect(tag_list).to eq(%w[bumble busy]) }
    end
  end

  describe '#to_s' do
    it { expect(tag_list.to_s).to eq('bumble,busy') }
  end
end
