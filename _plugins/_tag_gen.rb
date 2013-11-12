module Jekyll
  class Tag
    attr_reader :name, :path

    def initialize(name)
      @name = name
      @path = @name.downcase.gsub(' ', '_')
    end

    def to_liquid
      {
        'name' => @name,
        'path' => @path
      }
    end
  end

  class TagPage < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
    end
  end

  class TagGenerator < Generator
    
    def generate(site)
      if site.layouts.key? 'tag_index'
        site.tags.keys.each do |tag|
          paginate(site, tag)
        end
        site.config['tags_list'] = site.tags.keys.each_with_object([]) do |tag, r| 
          r.push Tag.new(tag)
        end.uniq{ |tag| tag.path }.sort_by do |tag|
          tag.name
        end
      end
    end

    def paginate(site, tag)
      tag_posts = site.posts.select do |post|
        post.tags.map{|tag| tag.downcase }.include?(tag.downcase)
      end.reverse
      num_pages = TagPager.calculate_pages(tag_posts, 1)
      tag       = Tag.new(tag)

      (1..num_pages).each do |page|
        pager = TagPager.new(site, page, tag_posts, tag, num_pages)
        dir   = TagPager.dir_path(tag.path, page)
        page  = TagPage.new(site, site.source, dir)
        page.pager = pager
        site.pages << page
      end
    end
  end

  class TagPager < Pager 
    attr_reader :current_tag

    def self.dir_path(tag_path, num_page)
      File.join('tagged', tag_path, num_page > 1 ? "page/#{num_page}" : '')
    end

    def self.paginate_path(tag_path, num_page)
      return nil if num_page.nil?
      format = dir_path(tag_path, num_page)
      ensure_leading_slash(format)
    end

    def initialize(site, page, all_posts, tag, num_pages = nil)
      @current_tag = tag
      @page        = page
      @per_page    = 1
      @total_pages = num_pages || Pager.calculate_pages(all_posts, @per_page)

      init = (@page - 1) * @per_page
      offset = (init + @per_page - 1) >= all_posts.size ? all_posts.size : (init + @per_page - 1)

      @total_posts = all_posts.size
      @posts = all_posts[init..offset]
      @previous_page = @page != @total_pages ? @page + 1 : nil
      @previous_page_path = TagPager.paginate_path(@current_tag.path, @previous_page)
      @next_page = @page != 1 ? @page - 1 : nil
      @next_page_path = TagPager.paginate_path(@current_tag.path, @next_page)
    end

    def to_liquid
      super.merge('current_tag' => @current_tag)
    end
  end
end