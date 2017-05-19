require 'spec_helper'
describe 'indigo_iam' do

  context 'with defaults for all parameters' do
    it { should contain_class('indigo_iam') }
  end
end
