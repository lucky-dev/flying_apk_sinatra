require 'spec_helper'

describe ApiHelper do

  describe 'Accept header' do
    it 'has an api version' do
      type_apps = ['application/vnd.flyingapk; version=1', 'application/vnd.flyingapk;version=1']
      type_apps.each do |type_app|
        expect(ApiHelper.get_api_version(type_app)).to eq(1)
      end      
    end

    it 'has no an api version' do
      type_apps = ['applicationvnd.testapk; version1', 'application/vndtestapp; version=1', 'application/vnd.testapk; version=1', 'application/vnd.testapk; version=a']
      type_apps.each do |type_app|
        expect(ApiHelper.get_api_version(type_app)).to eq(0)
      end      
    end
  end

end
