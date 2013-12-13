module Jekyll
  module DateFilter
    def format_date(date)
      time(date).strftime("%d/%m/%Y")
    end
  end
end

Liquid::Template.register_filter(Jekyll::DateFilter)