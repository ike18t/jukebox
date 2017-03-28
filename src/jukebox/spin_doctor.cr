module Jukebox
  class SpinDoctor(T)
    def self.get_next_item(list : Array(T), last : T | Nil) : T
      last_index = last.nil? ? nil : list.index { |item| last.id == item.id }
      return list.sample if last_index.nil?
      list.rotate(last_index + 1).first
    end
  end
end
