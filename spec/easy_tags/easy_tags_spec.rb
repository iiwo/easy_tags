# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EasyTags do
  describe '.easy_tags_on' do
    subject(:taggable) { TaggableModel.create }

    describe 'method generation' do
      before(:all) do # rubocop:disable RSpec/BeforeAfterAll
        TaggableModel.tagging_contexts = []
        TaggableModel.easy_tags_on(:tags, :languages, :skills, :needs, :offerings)
      end

      shared_examples 'generates context methods' do
        it 'creates a class attribute for tag types' do
          expect(taggable.class).to respond_to(:tagging_contexts)
        end

        it 'has all tag types' do
          expect(taggable.class.tagging_contexts).to eq(%i[tags languages skills needs offerings])
        end

        it 'generates an association for each tag type' do
          expect(taggable).to respond_to(:tags, :skills, :languages)
        end

        it 'generates tag_list getters for each tag type' do
          expect(taggable).to respond_to(:tags_list, :skills_list, :languages_list)
        end

        it 'generates tag_list setters for each tag type' do
          expect(taggable).to respond_to(:tags_list=, :skills_list=, :languages_list=)
        end
      end

      it_behaves_like 'generates context methods'

      context 'when using subclasses' do
        subject(:taggable) { SubclassTaggableModel.create }

        before do
          subclass = Class.new(TaggableModel)
          stub_const('SubclassTaggableModel', subclass)
        end

        it_behaves_like 'generates context methods'
      end

      context 'with multiple declarations' do
        before do
          TaggableModel.tagging_contexts = []
          TaggableModel.easy_tags_on(:bees)
          TaggableModel.easy_tags_on(:birds)
        end

        it 'does not overwrite first declaration' do
          expect(taggable).to respond_to(:bees_list, :birds_list)
        end
      end
    end

    describe 'options processing' do
      it 'eliminates duplicate tagging contexts' do
        TaggableModel.easy_tags_on(:skills, :skills)
        TaggableModel.easy_tags_on(:skills)
        expect(TaggableModel.tagging_contexts.count(:skills)).to eq(1)
      end

      context 'when passed nil' do
        it 'does not raise error' do
          expect { TaggableModel.easy_tags_on }.not_to raise_error
        end
      end

      context 'when passed [nil]' do
        it 'does not raise error' do
          expect { TaggableModel.easy_tags_on([nil]) }.not_to raise_error
        end
      end

      context 'when passed invalid options' do
        it 'raises an error' do
          expect { TaggableModel.easy_tags_on('%#$%#@#EQESD', [:something]) }.to raise_error('invalid options')
        end
      end

      context 'with callbacks' do
        describe 'after_add' do
          context 'with symbol' do
            before do
              TaggableModel.tagging_contexts = []
              TaggableModel.easy_tags_on(:bees, birds: { after_add: :add_callback })
              taggable.birds.add('sparrow')
            end

            let(:taggable) { TaggableModel.new }

            it 'triggers the callback' do # rubocop:disable RSpec/MultipleExpectations
              expect(taggable).to receive(:add_callback) do |tagging|
                expect(tagging).to eq(EasyTags::Tagging.last)
              end

              taggable.save
            end
          end

          context 'with proc' do
            before do
              TaggableModel.tagging_contexts = []
              TaggableModel.class_eval do
                easy_tags_on(
                  :bees,
                  birds: { after_add: ->(tagging) { add_callback(tagging) } }
                )
              end

              taggable.birds.add('sparrow')
            end

            it 'triggers the callback' do # rubocop:disable RSpec/MultipleExpectations
              expect(taggable).to receive(:add_callback) do |tagging| # rubocop:disable RSpec/SubjectStub
                expect(tagging).to eq(EasyTags::Tagging.last)
              end

              taggable.save
            end
          end
        end

        describe 'after_remove' do
          context 'with symbol' do
            before do
              TaggableModel.tagging_contexts = []
              TaggableModel.easy_tags_on(:bees, birds: { after_remove: :remove_callback })
              taggable.update!(birds: ['sparrow'])
              taggable.birds.remove('sparrow')
            end

            let(:taggable) { TaggableModel.new }

            it 'triggers the callback' do
              expect(taggable).to receive(:remove_callback).with(EasyTags::Tagging.last)

              taggable.save
            end
          end

          context 'with proc' do
            before do
              TaggableModel.tagging_contexts = []
              TaggableModel.class_eval do
                easy_tags_on(
                  :bees,
                  birds: { after_remove: ->(tagging) { remove_callback(tagging) } }
                )
              end
              taggable.update!(birds: ['sparrow'])
              taggable.birds.remove('sparrow')
            end

            it 'triggers the callback' do
              # rubocop:disable RSpec/SubjectStub
              expect(taggable).to receive(:remove_callback).with(EasyTags::Tagging.last)
              # rubocop:enable RSpec/SubjectStub

              taggable.save
            end
          end
        end

        context 'with multiple callbacks' do
          before do
            TaggableModel.tagging_contexts = []
            TaggableModel.class_eval do
              easy_tags_on(
                :bees,
                birds: { after_remove: ->(tagging) { remove_callback(tagging) }, after_add: :add_callback }
              )
            end
            allow(taggable).to receive(:add_callback) # rubocop:disable RSpec/SubjectStub

            taggable.update!(birds: ['sparrow'])

            taggable.birds.remove('sparrow')
            taggable.birds.add('crow')
          end

          it 'triggers both callbacks' do # rubocop:disable RSpec/MultipleExpectations
            expect(taggable).to receive(:remove_callback) # rubocop:disable RSpec/SubjectStub
            expect(taggable).to receive(:add_callback) # rubocop:disable RSpec/SubjectStub

            taggable.save
          end
        end
      end
    end
  end
end
