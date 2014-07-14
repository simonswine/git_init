require 'spec_helper'

VALID_URLS = {
    'https://github.com/gitlabhq/gitlabhq.git' => {
      :type => :http,
      :domain => 'github.com',
      :path => 'gitlabhq',
      :basename => 'gitlabhq.git',
      :proto => 'https'
    },
    'http://github.com/gitlabhq/gitlabhq.git' => {
      :type => :http,
      :domain => 'github.com',
      :path => 'gitlabhq',
      :basename => 'gitlabhq.git',
      :proto => 'http'
    },
    'git@github.com:gitlabhq/gitlabhq.git' => {
      :type => :ssh,
      :user => 'git',
      :domain => 'github.com',
      :path => 'gitlabhq',
      :basename => 'gitlabhq.git',
    },
    'github.com:gitlabhq/gitlabhq.git' => {
      :type => :ssh,
      :user => nil,
      :domain => 'github.com',
      :path => 'gitlabhq',
      :basename => 'gitlabhq.git',
    },
    'git://github.com/gitlabhq/gitlabhq.git' => {
      :type => :git,
      :domain => 'github.com',
      :path => 'gitlabhq',
      :basename => 'gitlabhq.git',
    },
}



describe GitInit do

  VALID_URLS.each do |url, values|
    describe GitInit::GitUrl do

      describe '#new' do
        subject do
          GitInit::GitUrl.method(:new)
        end


        it 'creates object from url' do
          expect{subject.(url)}.not_to raise_error()
        end

        it 'generates same url as in input' do
          expect(subject.(url).url).to eq(url)
        end
      end

      describe "URL '#{url}'" do
        describe '.parse_url' do
          subject do
            GitInit::GitUrl.method(:parse_url)
          end

          it 'should parse correct urls' do
            expect(subject.(url)).to eq(values)
          end
        end

        describe '.detect_type' do
          subject do
            GitInit::GitUrl.method(:detect_type)
          end

          it 'should parse correct urls' do
            subject.(url)
            expect(subject.(url)).to eq(values[:type])

          end
        end
      end
    end
  end
end