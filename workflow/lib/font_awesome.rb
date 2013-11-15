class FontAwesome
  attr_reader :icons

  ICONS = YAML.load_file(File.expand_path('./icons.yml'))['icons']

  class Icon
    attr_reader :id, :unicode

    def initialize(id)
      @id = id
      unicode = detect_unicode_from_id(id)
      @unicode = unicode ? unicode : detect_unicode_from_aliases(id)
    end

    def detect_unicode_from_id(id)
      detected_icon = ICONS.detect { |icon| icon['id'] == id }
      detected_icon ? detected_icon['unicode'] : nil
    end

    def detect_unicode_from_aliases(id)
      detected_icon = ICONS.detect do |icon|
        icon['aliases'].include?(id) if icon['aliases']
      end
      detected_icon ? detected_icon['unicode'] : nil
    end
  end

  def initialize(query = '')
    icon_filenames = glob_icon_filenames
    @icons = icon_filenames.map { |name| Icon.new(name) }
    select!(query.split)
  end

  def select!(queries, icons = @icons)
    queries.each do |q|
      # use reject! for ruby 1.8 compatible
      icons.reject! { |icon| icon.id.index(q.downcase) ? false : true }
    end
    icons
  end

  def item_hash(icon)
    {
      :uid      => '',
      :title    => icon.id,
      :subtitle => "Copy to clipboard: fa-#{icon.id}",
      :arg      => icon.id,
      :icon     => { :type => 'default', :name => "./icons/fa-#{icon.id}.png" },
      :valid    => 'yes',
    }
  end

  def add_items(feedback, icons = @icons)
    icons.each { |icon| feedback.add_item(item_hash(icon)) }
    feedback
  end

  def to_alfred(alfred)
    add_items(alfred.feedback).to_alfred
  end

  private

  def glob_icon_filenames
    Dir.glob(File.expand_path('./icons/fa-*.png')).map do |path|
      md = /\/fa-(.+)\.png/.match(path)
      (md && md[1]) ? md[1] : nil
    end.compact.uniq.sort
  end
end
