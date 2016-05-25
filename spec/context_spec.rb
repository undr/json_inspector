require 'spec_helper'

describe JsonInspector::Context do
  let(:filename) { File.expand_path('../support/fixtures/simple.json', __FILE__) }
  let(:inspector) { JsonInspector::Context.new(filename) }

  describe '#current' do
    subject { inspector.current }

    it 'returns whole document' do
      expect(subject).to eq(inspector.doc)
    end

    context 'when we went into some scope' do
      before { inspector.into('widget.window') }

      it 'returns current part' do
        expect(subject).to eq(inspector.doc['widget']['window'])
      end
    end
  end

  describe '#reset' do
    subject { inspector.current }

    it 'does noting' do
      inspector.reset
      expect(subject).to eq(inspector.doc)
    end

    context 'when we went into some scope' do
      before { inspector.into('widget.window') }

      it 'resets current scope' do
        inspector.reset
        expect(subject).to eq(inspector.doc)
      end
    end
  end

  describe '#out' do
    subject { inspector.current }

    it 'does noting' do
      inspector.out
      expect(subject).to eq(inspector.doc)
    end

    context 'when we went into some scope' do
      before { inspector.into('widget.window') }

      it 'steps back in the scope' do
        inspector.out
        expect(subject).to eq(inspector.doc['widget'])
      end
    end
  end

  describe '#show' do
    subject { inspector.show(selector) }

    context 'with empty selector' do
      let(:selector) { '' }

      it 'returns whole document' do
        expect(subject).to eq(inspector.doc)
      end
    end

    context 'with wrong selector' do
      let(:selector) { 'window' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with non empty selector' do
      let(:selector) { 'widget.window' }

      it 'returns correct part of document' do
        expect(subject).to eq(inspector.doc['widget']['window'])
      end
    end

    context 'when we went into some scope' do
      before { inspector.into('widget') }

      context 'with empty selector' do
        let(:selector) { '' }

        it 'returns current part' do
          expect(subject).to eq(inspector.doc['widget'])
        end
      end

      context 'with wrong selector' do
        let(:selector) { 'widget' }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'with non empty selector' do
        let(:selector) { 'window' }

        it 'returns correct part of document' do
          expect(subject).to eq(inspector.doc['widget']['window'])
        end
      end
    end
  end

  describe '#into' do
    subject { inspector.current }

    before { inspector.into(selector) }

    context 'with empty selector' do
      let(:selector) { '' }

      it 'does noting' do
        expect(subject).to eq(inspector.doc)
      end
    end

    context 'with wrong selector' do
      let(:selector) { 'window' }

      it 'changes current to nil' do
        expect(subject).to be_nil
      end
    end

    context 'with non empty selector' do
      let(:selector) { 'widget.window' }

      it 'changes current to correct part of document' do
        expect(subject).to eq(inspector.doc['widget']['window'])
      end
    end

    context 'when we went into some scope' do
      before do
        inspector.reset
        inspector.into('widget')
        inspector.into(selector)
      end

      context 'with empty selector' do
        let(:selector) { '' }

        it 'does noting' do
          expect(subject).to eq(inspector.doc['widget'])
        end
      end

      context 'with wrong selector' do
        let(:selector) { 'widget' }

        it 'changes current to nil' do
          expect(subject).to be_nil
        end
      end

      context 'with non empty selector' do
        let(:selector) { 'window' }

        it 'changes current to correct part of document' do
          expect(subject).to eq(inspector.doc['widget']['window'])
        end
      end
    end
  end

  describe '#keys' do
    subject { inspector.keys(selector) }

    context 'with empty selector' do
      let(:selector) { '' }

      it 'returns root keys' do
        expect(subject).to eq(%w{name type widget})
      end
    end

    context 'with wrong selector' do
      let(:selector) { 'window' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end

    context 'with non empty selector' do
      let(:selector) { 'widget' }

      it 'returns keys of scoped object' do
        expect(subject).to eq(%w{debug window image text})
      end
    end

    context 'when we went into some scope' do
      before { inspector.into('widget') }

      context 'with empty selector' do
        let(:selector) { '' }

        it 'returns current object keys' do
          expect(subject).to eq(%w{debug window image text})
        end
      end

      context 'with wrong selector' do
        let(:selector) { 'widget' }

        it 'returns empty array' do
          expect(subject).to be_empty
        end
      end

      context 'with non empty selector' do
        let(:selector) { 'window' }

        it 'returns keys of scoped object' do
          expect(subject).to eq(%w{title name width height})
        end
      end
    end
  end

  describe '#tree' do
    subject { inspector.tree(*args) }

    context 'with empty selector' do
      let(:args) { [] }

      it 'returns all keys' do
        expect(subject).to eq(%w{
          name
          type
          widget.debug
          widget.window.title
          widget.window.name
          widget.window.width
          widget.window.height
          widget.image.src
          widget.image.name
          widget.image.hOffset
          widget.image.vOffset
          widget.image.alignment
          widget.text.debug
          widget.text.data
          widget.text.size
          widget.text.style
          widget.text.name
          widget.text.hOffset
          widget.text.vOffset
          widget.text.alignment
          widget.text.onMouseUp
        })
      end
    end

    context 'with empty selector and limit' do
      let(:args) { [2] }

      it 'returns limited keys' do
        expect(subject).to eq(%w{
          name
          type
          widget.debug
          widget.window...
          widget.image...
          widget.text...
        })
      end
    end

    context 'with non empty selector' do
      let(:args) { ['widget.text'] }

      it 'returns all keys of scoped object' do
        expect(subject).to eq(%w{
          widget.text.debug
          widget.text.data
          widget.text.size
          widget.text.style
          widget.text.name
          widget.text.hOffset
          widget.text.vOffset
          widget.text.alignment
          widget.text.onMouseUp
        })
      end
    end

    context 'with non empty selector and limit' do
      let(:args) { ['widget', 1] }

      it 'returns all keys of scoped object' do
        expect(subject).to eq(%w{
          widget.debug
          widget.window...
          widget.image...
          widget.text...
        })
      end
    end

    context 'with wrong selector' do
      let(:args) { ['window'] }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#find' do
    subject { inspector.find(query) }

    context 'when query is empty' do
      let(:query) { '' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end

    context 'when query value is not found' do
      let(:query) { 'supercalifragilisticexpialidocious' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end

    context 'when query value is found' do
      let(:query) { 'center' }

      it 'returns keys that contain this query' do
        expect(subject).to eq(%w{widget.image.alignment widget.text.alignment})
      end
    end
  end

  describe '#find_key' do
    subject { inspector.find_key(query) }

    context 'when query is empty' do
      let(:query) { '' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end

    context 'when query value is not found' do
      let(:query) { 'supercalifragilisticexpialidocious' }

      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end

    context 'when query value is found' do
      let(:query) { 'name' }

      it 'returns keys with this name' do
        expect(subject).to eq(%w{name widget.window.name widget.image.name widget.text.name})
      end
    end

    context 'when we went into some scope' do
      before { inspector.into('widget') }

      context 'when query is empty' do
        let(:query) { '' }

        it 'returns empty array' do
          expect(subject).to be_empty
        end
      end

      context 'when query value is not found' do
        let(:query) { 'supercalifragilisticexpialidocious' }

        it 'returns empty array' do
          expect(subject).to be_empty
        end
      end

      context 'when query value is found' do
        let(:query) { 'name' }

        it 'returns keys with this name' do
          expect(subject).to eq(%w{window.name image.name text.name})
        end
      end
    end
  end
end
