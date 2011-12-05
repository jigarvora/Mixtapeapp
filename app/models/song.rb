class Song < ActiveRecord::Base
  
  SortOptions = {
   :name => {:column => "name", :order => "ASC"}, 
  }
  
  belongs_to :artist, :counter_cache => true
  
  has_many :playlists, :inverse_of => :song
  has_many :mixtapes, :through => :playlists
  
  has_attached_file :audio

  # http://rubydoc.info/github/thoughtbot/paperclip/master/Paperclip/ClassMethods:validates_attachment_content_type
  # https://netfiles.uiuc.edu/xythoswfs/static/en/content_type.htm
  validates_attachment_presence :audio, :if => lambda {|s| s.audio.exists?}
  validates_attachment_content_type :audio, :content_type => /^audio/, :message => "must be an audio file"
  
  def artist_name
    self.artist.name if self.artist.present?
  end
  
  def artist_name=(string)
    self.artist = Artist.find_or_create_by_name(string)
  end
  
  def self.all_or_search(search, params = {})   
    (search.blank? ? 
                 self :
                 self.starts_with(search)
               ).
               by(params.slice(:sort, :order))
               
  end
  
  def self.page_all_or_search(page, search, sort)
    paginate(:per_page => 10, :page => page,
    :conditions => ['name LIKE ?', "#{search}%"], :order => 'name')
    #Song.all
  end
  
  
  def self.by(options = {})
    options[:sort] = :name if !options[:sort] || !SortOptions.has_key?(options[:sort].to_sym)
    
    sort_sql = "#{SortOptions[options[:sort].to_sym][:column]} "
    sort_sql += "#{options[:order] || SortOptions[options[:sort].to_sym][:order]}"
    order(sort_sql)
  end
  
  def self.starts_with(name)
    self.where("name LIKE :search", :search => "#{name}%")
  end
  
end
