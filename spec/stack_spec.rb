require 'spec_helper'

describe JsonInspector::Stack do
  let(:document) { {} }

  subject { JsonInspector::Stack.new(document) }

  describe '#push' do
    it 'adds scope keys' do
      subject.push('some.key')
      expect(subject.path).to eq('some.key')
    end

    context 'when scope keys exist' do
      before { subject.push('some.key') }

      it 'adds more scope keys' do
        subject.push('go.deeper')
        expect(subject.path).to eq('some.key.go.deeper')
      end
    end
  end

  describe '#pop' do
    before { subject.push('some.key') }

    it 'removes last key' do
      subject.pop
      expect(subject.path).to eq('some')

      subject.pop
      expect(subject.path).to eq('')

      subject.pop
      expect(subject.path).to eq('')
    end
  end

  describe '#clear!' do
    before { subject.push('some.key') }

    it 'clears all keys' do
      subject.clear!
      expect(subject.path).to eq('')
    end
  end

  describe '#current' do
    let(:document) { { 'some' => { 'key' => 'value', 'another_key' => 'another value' }} }

    it 'returns whole document' do
      expect(subject.current).to eq(document)
    end

    context 'when scope keys exist' do
      before { subject.push('some') }

      it 'returns scoped document' do
        expect(subject.current).to eq(document['some'])
        expect(subject.current('key')).to eq('value')
        expect(subject.current('another_key')).to eq('another value')
      end
    end
  end
end
