require 'spec_helper'

describe Media do

  describe :validations do
  	context :presence do
      context 'if embed media' do
      	let(:media) { Media.new(kind: "Video") }

      	it { media.should validate_presence_of(:wistia_hashed_id) }
      end

  	end

    context :length do
      context 'if text' do
      	let(:media) { Media.new(kind: "Text") }

      	it { media.should ensure_length_of(:text).is_at_least(15).is_at_most(5000) }
      end

      it { should ensure_length_of(:title).is_at_least(5).is_at_most(100) }
    end
  end

  describe :associations do
		[:lessons, :courses, :teachers].each do |model|
			it { should have_many(model) }
		end

		it { should have_many(:lessons_medias).dependent(:destroy) }
  end	

  describe '.text?' do
  	it "should return true if kind is text" do
  		media = Media.new(kind: "Text")
  		media.text?.should be_true
  	end

  	it "should return false if kind is not text" do
  		media = Media.new(kind: "Video")
  		media.text?.should be_false
  	end
  end

  describe '.text?' do
  	it "should return true if kind is text" do
  		media = Media.new(kind: "Video")
  		media.embed?.should be_true
  	end

  	it "should return false if kind is not text" do
  		media = Media.new(kind: "Text")
  		media.embed?.should be_false
  	end
  end  

  describe '.text_sample' do
  	it "should return first characters of text" do
  		media = Media.new(kind: "Text", text: "a"*50)
  		media.text_sample.should == "a"*31
  	end
  end

 	describe '.available?' do
 		it "should return true when text is available" do
 			media = Media.new(text: "a"*50)
 			media.available?.should be_true
 		end

 		it "should return true when wistia_hashed_id is available" do
 			media = Media.new(wistia_hashed_id: "abc123")
 			media.available?.should be_true
 		end

		it "should return false when nor text nor wistia_hashed_id is available" do
			media = Media.new
			media.available?.should be_false
 		end 		
 	end

  # describe '.destroy' do
  # 	it "should delete Wistia media first" do
  # 		media = create(:media)
  # 		Wistia::Media.should_receive(:find).with(media.wistia_hashed_id)
  # 		Wistia::Media.any_instance.should_receive(:destroy)
  # 		media.destroy
  # 	end
  # end

end
