# encoding: utf-8

require 'spec_helper'

describe EditCurriculumWidget do
	has_widgets do |root|
    root << widget(:edit_curriculum)
  end

  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
    EditCurriculumWidget.any_instance.stub current_user: user
  end
  let(:course) { user.school.courses.first }
  let(:lesson) { course.lessons.first }
  let(:media) { course.medias.first}
  
  it "#add_content - should set variables and render add content page" do
    Media.should_receive(:find).with(media.id).exactly(1).times.and_return(media)
    Course.should_receive(:find).with(course.id).exactly(1).times.and_return(course)
    response = render_widget :edit_curriculum, :add_content, media: media.id, course: course.id
    response.should have_text "Crie a ementa do seu curso com aulas e conteúdos"
  end

  it "#create_content - success - should update media and render curriculum page" do
    response = render_widget :edit_curriculum, :create_content, media_id: media.id, 
      course: course.id, media: { kind: "Video", wistia_hashed_id: "abc123" }
    response.should have_text "Mídia atualizada com sucesso!"
    media.reload
    media.kind.should == "Video"
    media.wistia_hashed_id.should == "abc123"
  end

  it "#create_content - failure - should not update media and render add content page" do
    response = render_widget :edit_curriculum, :create_content, media_id: media.id, 
      course: course.id, media: { kind: "Slide", wistia_hashed_id: "" }
    response.should have_text "Arquivo não pode ficar em branco"
    response.should have_text "Crie a ementa do seu curso com aulas e conteúdos"
    media.reload
    media.should_not == "Slide"
    media.wistia_hashed_id.should_not be_blank
  end

  it "#view_content - embed media - success - should set content and render view content page" do
    Media.should_receive(:find).with(media.id).exactly(1).times.and_return(media)
    Course.should_receive(:find).with(course.id).exactly(1).times.and_return(course)

    wistia_media = Wistia::Media.new(
      embedCode: "<object id=\"wistia_1238341\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"1280\" height=\"800\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"wmode\" value=\"opaque\" /><param name=\"flashvars\" value=\"videoUrl=http://embed.wistia.com/deliveries/6f43803c698b207c79b1b049b959faae604d6c5d.bin&stillUrl=http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin&playButtonVisible=true&controlsVisibleOnLoad=false&unbufferedSeek=true&autoLoad=false&autoPlay=false&endVideoBehavior=default&embedServiceURL=http://distillery.wistia.com/x&accountKey=wistia-production_15541&mediaID=wistia-production_1238341&mediaDuration=5280.0&hdUrl=http://embed.wistia.com/deliveries/a19616419e83d4dd3ba25d4983774d25c60f8117.bin\" /><param name=\"movie\" value=\"http://embed.wistia.com/flash/embed_player_v2.0.swf\" /><embed src=\"http://embed.wistia.com/flash/embed_player_v2.0.swf\" name=\"wistia_1238341\" type=\"application/x-shockwave-flash\" width=\"640\" height=\"360\" allowfullscreen=\"true\" allowscriptaccess=\"always\" wmode=\"opaque\" flashvars=\"videoUrl=http://embed.wistia.com/deliveries/6f43803c698b207c79b1b049b959faae604d6c5d.bin&stillUrl=http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin&playButtonVisible=true&controlsVisibleOnLoad=false&unbufferedSeek=true&autoLoad=false&autoPlay=false&endVideoBehavior=default&embedServiceURL=http://distillery.wistia.com/x&accountKey=wistia-production_15541&mediaID=wistia-production_1238341&mediaDuration=5280.0&hdUrl=http://embed.wistia.com/deliveries/a19616419e83d4dd3ba25d4983774d25c60f8117.bin\"></embed></object><script src=\"http://embed.wistia.com/embeds/v.js\"></script><script>if(!navigator.mimeTypes['application/x-shockwave-flash'] || navigator.userAgent.match(/Android/i)!==null)Wistia.VideoEmbed('wistia_1238341','640','360',{videoUrl:'http://embed.wistia.com/deliveries/5ea44396109ec88608739db0baec9177012f1a85.bin',stillUrl:'http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin',distilleryUrl:'http://distillery.wistia.com/x',accountKey:'wistia-production_15541',mediaId:'wistia-production_1238341',mediaDuration:5280.0})</script>"
    )
    Wistia::Media.should_receive(:find).and_return(wistia_media)
    response = render_widget :edit_curriculum, :view_content, media: media.id, course: course.id
    response.should have_text media.title
    response.should have_text "http://embed.wistia.com/deliveries/5ea44396109ec88608739db0baec9177012f1a85.bin"
  end

  it "#view_content - embed media - failure - should set alert and render view content page" do
    Wistia::Media.should_receive(:find).and_raise
    response = render_widget :edit_curriculum, :view_content, media: media.id, course: course.id
    response.should have_text "Ocorreu um erro ao o renderizar conteúdo."
    response.should have_text media.title
    response.should have_text lesson.title
  end

  it "#view_content - text - should render view content page and show media text" do
    media.update_attributes!(kind: Media::TEXT, text: "Example of a test", wistia_hashed_id: nil) 
    response = render_widget :edit_curriculum, :view_content, media: media.id, course: course.id
    response.should have_text media.text
    response.should have_text media.title
  end

  it "#load_content - should set media kind and render add content view" do
    media.should_receive(:kind=).with("Audio")
    Media.should_receive(:find).with(media.id).exactly(1).times.and_return(media)
    Course.should_receive(:find).with(course.id).exactly(1).times.and_return(course) 
    response = render_widget :edit_curriculum, :load_content, media: media.id, 
      course: course.id, kind: "Audio"
    response.should have_text "Buscar arquivo"
  end

  it "#cancel_action - should go back to curriculum view" do
    response = render_widget :edit_curriculum, :cancel_action, course: course.id
    response.should have_text media.title
    response.should have_text lesson.title
  end

end