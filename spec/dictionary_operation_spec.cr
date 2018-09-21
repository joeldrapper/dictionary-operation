require "./spec_helper"
require "../src/hash"
require "../src/dictionary_operation"

describe DictionaryOperation do
  describe "#update" do
    it "schedules an update" do
      operation = DictionaryOperation(String, Int32).new

      operation["a"] = 1

      operation.scheduled_updates["a"].should eq 1
    end

    it "unschedules a delete" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_deletes << "a"

      operation["a"] = 1

      operation.scheduled_updates["a"].should eq 1
      operation.scheduled_deletes.includes?("a").should be_false
    end
  end

  describe "#delete" do
    it "schedules a delete" do
      operation = DictionaryOperation(String, Int32).new

      operation.delete("a")

      operation.scheduled_deletes.includes?("a").should be_true
    end

    it "unschedules an update" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_updates["a"] = 1

      operation.delete("a")

      operation.scheduled_deletes.includes?("a").should be_true
      operation.scheduled_updates.has_key?("a").should be_false
    end
  end

  describe "#apply_to" do
    it "applies itself to a Dictionary" do
      dictionary = {
        "a" => 1,
        "b" => 2,
        "c" => 3,
      }

      operation = DictionaryOperation(String, Int32).new

      operation["a"] = 4
      operation.delete("b")
      operation["d"] = 5

      operation.apply_to(dictionary)

      dictionary.should eq({
        "a" => 4,
        "c" => 3,
        "d" => 5,
      })
    end
  end

  describe "#+" do
    it "combines operations into a new operation" do
      a = DictionaryOperation(String, Int32).new
      b = DictionaryOperation(String, Int32).new

      a["a"] = 1
      a["b"] = 2
      a["c"] = 3

      b["a"] = 4
      b.delete("b")
      b["d"] = 5

      c = a + b

      c.scheduled_updates.should eq({"a" => 4, "c" => 3, "d" => 5})
      c.scheduled_deletes.should eq(Set{"b"})
    end
  end
end
