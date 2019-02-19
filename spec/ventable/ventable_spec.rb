require 'spec_helper'

describe Ventable do
  describe 'Global Enable and Disable' do
    after { Ventable.enable! }

    it 'is true by default' do
      expect(Ventable.enabled?).to be true
    end

    it 'is false after Ventable is disabled' do
      Ventable.disable!
      expect(Ventable.enabled?).to be false
      expect(Ventable.disabled?).to be true
    end

    it 'is true after Ventable is enabled' do
      Ventable.enable!
      expect(Ventable.enabled?).to be true
      expect(Ventable.disabled?).to be false
    end
  end
end
