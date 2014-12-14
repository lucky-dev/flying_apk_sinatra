require 'spec_helper'

describe BuildHelper do

  describe 'App' do
    it 'is android app' do
      files = ['my_app.apk', 'my123APP.apk']
      files.each do |file|
        expect(BuildHelper.android_app?(file)).to be(true)
      end      
    end

    it 'is not android app' do
      files = %w(my_app.txt my123APP.apk1 my123APPapk1)
      files.each do |file|
        expect(BuildHelper.android_app?(file)).to be(false)
      end     
    end
  end

end
