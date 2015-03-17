# encoding: utf-8

require 'spec_helper'

describe SchoolLibraryWidget do
	has_widgets do |root|
    root << widget(:school_library)
  end

  let(:user) { FactoryGirl.create(:school_admin) }
  let(:school) { user.school }
  before(:each) do
    School.current_id = school.id
    school.courses = [FactoryGirl.create(:course)]
    school.save!
    controller.request.stub subdomain: school.subdomain
    SchoolLibraryWidget.any_instance.stub current_user: user
  end
  
  it "#show_media - success - should set content and render show media page" do
    wistia_media = Wistia::Media.new(
      embedCode: "<object id=\"wistia_1238341\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\"1280\" height=\"800\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"wmode\" value=\"opaque\" /><param name=\"flashvars\" value=\"videoUrl=http://embed.wistia.com/deliveries/6f43803c698b207c79b1b049b959faae604d6c5d.bin&stillUrl=http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin&playButtonVisible=true&controlsVisibleOnLoad=false&unbufferedSeek=true&autoLoad=false&autoPlay=false&endVideoBehavior=default&embedServiceURL=http://distillery.wistia.com/x&accountKey=wistia-production_15541&mediaID=wistia-production_1238341&mediaDuration=5280.0&hdUrl=http://embed.wistia.com/deliveries/a19616419e83d4dd3ba25d4983774d25c60f8117.bin\" /><param name=\"movie\" value=\"http://embed.wistia.com/flash/embed_player_v2.0.swf\" /><embed src=\"http://embed.wistia.com/flash/embed_player_v2.0.swf\" name=\"wistia_1238341\" type=\"application/x-shockwave-flash\" width=\"640\" height=\"360\" allowfullscreen=\"true\" allowscriptaccess=\"always\" wmode=\"opaque\" flashvars=\"videoUrl=http://embed.wistia.com/deliveries/6f43803c698b207c79b1b049b959faae604d6c5d.bin&stillUrl=http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin&playButtonVisible=true&controlsVisibleOnLoad=false&unbufferedSeek=true&autoLoad=false&autoPlay=false&endVideoBehavior=default&embedServiceURL=http://distillery.wistia.com/x&accountKey=wistia-production_15541&mediaID=wistia-production_1238341&mediaDuration=5280.0&hdUrl=http://embed.wistia.com/deliveries/a19616419e83d4dd3ba25d4983774d25c60f8117.bin\"></embed></object><script src=\"http://embed.wistia.com/embeds/v.js\"></script><script>if(!navigator.mimeTypes['application/x-shockwave-flash'] || navigator.userAgent.match(/Android/i)!==null)Wistia.VideoEmbed('wistia_1238341','640','360',{videoUrl:'http://embed.wistia.com/deliveries/5ea44396109ec88608739db0baec9177012f1a85.bin',stillUrl:'http://embed.wistia.com/deliveries/970de73278327fa6dc9df0220453d4d4183eca3a.bin',distilleryUrl:'http://distillery.wistia.com/x',accountKey:'wistia-production_15541',mediaId:'wistia-production_1238341',mediaDuration:5280.0})</script>",
      name: "Video sobre cozinha 1",
      hashed_id: "abc123",
      type: "Video"
    )
    Wistia::Media.should_receive(:find).and_return(wistia_media)
    response = render_widget :school_library, :show_media, school: school.id, media_hash: "abc123"
    response.should have_text "Video sobre cozinha 1"
    response.should have_text "http://embed.wistia.com/deliveries/5ea44396109ec88608739db0baec9177012f1a85.bin"
  end

  it "#show_media - failure on media - should set alert and render library page" do
    wistia_medias = [
      Wistia::Media.new(name: "Media 1", type: "Video", hashed_id: "abc123"),
      Wistia::Media.new(name: "Media 2", type: "Audio", hashed_id: "xyz456")
    ]
    wistia_project = Wistia::Project.new(medias: wistia_medias)
    Wistia::Project.should_receive(:find).and_return(wistia_project)
    Wistia::Media.should_receive(:find).and_raise
    response = render_widget :school_library, :show_media, school: school.id, media_hash: "abc123"
    response.should have_text "Ocorreu um erro ao o renderizar conteúdo. Tente novamente mais tarde."
  end

  it "#show_media - failure on project - should set alert and render library page" do
    wistia_medias = [
      Wistia::Media.new(name: "Media 1", type: "Video", hashed_id: "abc123"),
      Wistia::Media.new(name: "Media 2", type: "Audio", hashed_id: "xyz456")
    ]
    wistia_project = Wistia::Project.new(medias: wistia_medias)
    Wistia::Project.should_receive(:find).and_raise
    Wistia::Media.should_receive(:find).and_raise
    response = render_widget :school_library, :show_media, school: school.id, media_hash: "abc123"
    response.should have_text 'Servidor de dados não encontrado. Verifique sua conexão com a internet.'
  end

  it "#cancel - success - should set project and render library page" do
    wistia_medias = [
      Wistia::Media.new(name: "Media 1", type: "Video", hashed_id: "abc123"),
      Wistia::Media.new(name: "Media 2", type: "Audio", hashed_id: "xyz456")
    ]
    wistia_project = Wistia::Project.new(medias: wistia_medias)
    Wistia::Project.should_receive(:find).and_return(wistia_project)

    response = render_widget :school_library, :cancel, school: school.id
    response.should have_text "Media 1"
    response.should have_text "Media 2"
    response.should have_text "Video"
    response.should have_text "Audio"
  end

  it "#cancel - failure - shoult set alert" do
    Wistia::Project.should_receive(:find).and_raise
    response = render_widget :school_library, :cancel, school: school.id
    response.should have_text 'Servidor de dados não encontrado. Verifique sua conexão com a internet.'
  end
end