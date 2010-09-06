require "sinatra/base"
require "haml"
require "grit"
require "wikicloth"

module GitWiki
  class << self
    attr_accessor :homepage, :extension, :exportdir, :repository
  end

  def self.new(repository, exportdir, extension, homepage)
    self.homepage   = homepage
    self.extension  = extension
    self.exportdir  = exportdir
    self.repository = Grit::Repo.new(repository)

    App
  end

  class PageNotFound < Sinatra::NotFound
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end

  class Page
    def self.find_all
      return [] if repository.tree.contents.empty?
      repository.tree.contents.collect { |blob| new(blob) }
    end

    def self.find(name)
      page_blob = find_blob(name)
      raise PageNotFound.new(name) unless page_blob
      new(page_blob)
    end

    def self.find_or_create(name)
      find(name)
    rescue PageNotFound
      new(create_blob_for(name))
    end

    def self.css_class_for(name)
      find(name)
      "exists"
    rescue PageNotFound
      "unknown"
    end

    def self.repository
      GitWiki.repository || raise
    end

    def self.exportdir
      GitWiki.exportdir || raise
    end

    def self.extension
      GitWiki.extension || raise
    end

    def self.find_blob(page_name)
      repository.tree/(page_name + extension)
    end
    private_class_method :find_blob

    def self.create_blob_for(page_name)
      Grit::Blob.create(repository, {
        :name => page_name + extension,
        :data => ""
      })
    end
    private_class_method :create_blob_for

    def initialize(blob)
      @blob = blob
    end

    def to_html
      WikiCloth::Parser.new({ 
          :data => content
        }).to_html
    end

    def to_s
      name
    end

    def new?
      @blob.id.nil?
    end

    def name
      @blob.name.gsub(/#{File.extname(@blob.name)}$/, '')
    end

    def content
      @blob.data
    end

    def update_content(new_content)
      return if new_content == content
      File.open(file_name, "w") { |f| f << new_content }
      add_to_index_and_commit!
    end

    def file_name_export(ext)
      File.join(self.class.exportdir, name + ext)
    end

    def file_name_export2(n)
      File.join(self.class.exportdir, n)
    end

    private
      def add_to_index_and_commit!
        Dir.chdir(self.class.repository.working_dir) {
          self.class.repository.add(@blob.name)
        }
        self.class.repository.commit_index(commit_message)
      end

      def file_name
        File.join(self.class.repository.working_dir, name + self.class.extension)
      end

      def commit_message
        new? ? "Created #{name}" : "Updated #{name}"
      end
  end

  class App < Sinatra::Base
    set :app_file, __FILE__
    set :haml, { :format        => :html5,
                 :attr_wrapper  => '"'     }
    enable :inline_templates

    error PageNotFound do
      page = request.env["sinatra.error"].name
      redirect "/#{page}/edit"
    end

    before do
      content_type "text/html", :charset => "utf-8"
      s = request.path_info.chomp(".html")
      request.path_info = s
    end

    get "/" do
      redirect "/" + GitWiki.homepage
    end

    get "/allpages" do
      @pages = Page.find_all
      haml :list
    end

    get "/:page/edit" do
      @page = Page.find_or_create(params[:page])
      haml :edit
    end

    get "/:page/export" do
      @page = Page.find(params[:page])
      haml :export
    end

    get "/:page" do
      @page = Page.find(params[:page])
      haml :show
    end

    post "/:page" do
      @page = Page.find_or_create(params[:page])
      isnew = @page.new?
      @page.update_content(params[:body])
      @request = Rack::MockRequest.new(self)
      str = @request.request('get', params[:page] + '/export').body
      File.open(@page.file_name_export(".html"), "w") { |f| f << str }
      if isnew
        @request = Rack::MockRequest.new(self)
        str = @request.request('get', '/allpages').body
        File.open(@page.file_name_export2("allpages.html"), "w") { |f| f << str }
      end
      redirect "/#{@page}"
    end

    private
      def title(title=nil)
        @title = title.to_s unless title.nil?
        @title
      end

      def list_item(page)
        %Q{<a class="page_name" href="#{page}.html">#{page.name}</a>}
      end
  end
end

__END__
@@ layout
!!!
%html
  %head
    %title= title
    %style{ :type => "text/css" } .editsection { display: none; }
  %body
    %ul
      %li
        %a{ :href => "#{GitWiki.homepage}"+".html" } Home
      %li
        %a{ :href => "allpages.html" } All pages
    #content= yield

@@ show
- title @page.name
#edit
  %a{:href => "#{@page}/edit"} Edit this page
%h1= title
#content
  ~"#{@page.to_html}"

@@ export
- title @page.name
%h1= title
#content
  ~"#{@page.to_html}"

@@ edit
- title "Editing #{@page.name}"
%h1= title
%form{:method => 'POST', :action => "/#{@page}"}
  %p
    %textarea{:name => 'body', :rows => 30, :style => "width: 100%"}= @page.content
  %p
    %input.submit{:type => :submit, :value => "Save as the newest version"}
    or
    %a.cancel{:href=>"#{@page}"} cancel

@@ list
- title "Listing pages"
%h1 All pages
- if @pages.empty?
  %p No pages found.
- else
  %ul#list
    - @pages.each do |page|
      %li= list_item(page)
