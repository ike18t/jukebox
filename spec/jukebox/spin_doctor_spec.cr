require "../spec_helper"

describe Jukebox::SpinDoctor do
  describe "get_next_item" do
    it "should return the next item in the list except for the last item" do
      list = (0..5).map { |i| Item.new(id: i) }
      list.reject { |i| i == list.last }.each_with_index do |item, index|
        val = Jukebox::SpinDoctor(Item).get_next_item(list, item)
        val.should eq(list[index + 1])
      end
    end

    it "should return the first item if the last from the list is passed in" do
      list = (0..5).map { |i| Item.new(id: i) }
      val = Jukebox::SpinDoctor(Item).get_next_item(list, list.last)
      val.should eq(list.first)
    end

    it "should return a random item from the list if the last item is not in the list" do
      list = (0..5).map { |i| Item.new(id: i) }
      val = Jukebox::SpinDoctor(Item).get_next_item(list, Item.new(6))
      list.should contain(val)
    end

    it "should return a random item from the list if the last item is nil" do
      list = (0..5).map { |i| Item.new(id: i) }
      val = Jukebox::SpinDoctor(Item).get_next_item(list, nil)
      list.should contain(val)
    end
  end
end

struct Item
  getter :id

  def initialize(id : Int32)
    @id = id
  end
end
