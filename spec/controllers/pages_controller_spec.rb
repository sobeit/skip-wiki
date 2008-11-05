require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  fixtures :notes
  before do
    @current_note = notes(:our_note)
    controller.stub!(:current_note).and_return(@current_note)
  end

  #Delete this example and add some real ones
  it "should use PagesController" do
    controller.should be_an_instance_of(PagesController)
  end

  describe "GET /notes/hoge/pages/our_note_page_1" do
    fixtures  :pages
    before do
      @page = pages(:our_note_page_1)
      get :show, :note_id=>@current_note.name, :id=>@page.name
    end

    it "statusは200であること" do
      response.code.should == "200"
    end

    it "showテンプレートをrenderしていること" do
      response.should render_template("show")
    end
  end

  describe "GET /notes/hoge/pages/not_exists" do
    fixtures  :pages
    before do
      get :show, :note_id=>@current_note.name, :id=>"not_exist"
    end

    it "statusは404であること" do
      response.code.should == "404"
    end

    it "editテンプレートをrenderしていること" do
      response.should render_template("edit")
    end

    it "@pageは未保存であること" do
      assigns(:page).should be_new_record
    end
  end

  describe "POST /notes/hoge/pages [SUCCESS]" do
    before do
      page_param = {:name => "page_1", :display_name => "page_1", :format_type => "html", :content => "<p>foobar</p>"}.with_indifferent_access

      @current_note.pages.should_receive(:add).
        with(page_param, @user).and_return(page = mock_model(Page, page_param))
      page.should_receive(:save!).and_return(true)

      post :create, :note_id => @current_note.name, :page => page_param
    end

    it "responseは/notes/our_note/pages/page_1へのリダイレクトであること" do
      response.should redirect_to(note_page_path(@current_note, assigns(:page)))
    end

    it "editテンプレートをrenderしていること" do
    end
  end

  describe "POST /notes/hoge/pages [FAILED]" do
    before do
      page_param = {:name => "page_1", :display_name => "page_1", :format_type => "html", :content => "<p>foobar</p>"}.with_indifferent_access

      @current_note.pages.should_receive(:add).
        with(page_param, @user).and_return(page = mock_model(Page, page_param))
      page.should_receive(:save!).and_raise(ActiveRecord::RecordNotSaved)

      post :create, :note_id => @current_note.name, :page => page_param
    end

    it "editテンプレートを表示すること" do
      response.should render_template("edit")
    end
  end
end