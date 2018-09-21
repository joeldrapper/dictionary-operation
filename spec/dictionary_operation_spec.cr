require "./spec_helper"
require "../src/dictionary_operation"

describe DictionaryOperation do
  describe "#create" do
    it "schedules a create" do
      operation = DictionaryOperation(String, Int32).new

      operation.create("a", 1)

      operation.scheduled_creates["a"].should eq 1
    end

    it "schedules an update and unschedules the delete if a delete has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_deletes << "a"

      operation.create("a", 1)

      operation.scheduled_deletes.includes?("a").should be_false
      operation.scheduled_creates.has_key?("a").should be_false
      operation.scheduled_updates["a"].should eq 1
    end

    it "raises a KeyConflictError if a create has already been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_creates["a"] = 1

      expect_raises DictionaryOperation::KeyConflictError do
        operation.create("a", 2)
      end
    end

    it "raises a KeyConflictError if an update has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_updates["a"] = 1

      expect_raises DictionaryOperation::KeyConflictError do
        operation.create("a", 2)
      end
    end
  end

  describe "#update" do
    it "schedules an update" do
      operation = DictionaryOperation(String, Int32).new

      operation.update("a", 1)

      operation.scheduled_updates["a"].should eq 1
    end

    it "updates the create if a create has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_creates["a"] = 1

      operation.update("a", 2)

      operation.scheduled_creates["a"].should eq 2
      operation.scheduled_updates.has_key?("a").should be_false
    end

    it "raises a MissingKeyError if a delete has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_deletes << "a"

      expect_raises DictionaryOperation::MissingKeyError do
        operation.update("a", 1)
      end
    end
  end

  describe "#delete" do
    it "schedules a delete" do
      operation = DictionaryOperation(String, Int32).new

      operation.delete("a")

      operation.scheduled_deletes.includes?("a").should be_true
    end

    it "unschedules the update if an update has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_updates["a"] = 1

      operation.delete("a")

      operation.scheduled_updates.has_key?("a").should be_false
      operation.scheduled_deletes.includes?("a").should be_true
    end

    it "unschedules the create if a create has been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_creates["a"] = 1

      operation.delete("a")

      operation.scheduled_creates.has_key?("a").should be_false
      operation.scheduled_deletes.includes?("a").should be_false
    end

    it "raises a MissingKeyError if a delete has already been scheduled" do
      operation = DictionaryOperation(String, Int32).new
      operation.scheduled_deletes << "a"

      expect_raises DictionaryOperation::MissingKeyError do
        operation.delete("a")
      end
    end
  end

  describe "#apply_to" do
    it "applies itself to a Dictionary" do
      dictionary = Dictionary(String, Int32).new

      dictionary.create("a", 1)
      dictionary.create("b", 2)
      dictionary.create("c", 3)

      operation = DictionaryOperation(String, Int32).new

      operation.create("d", 4)
      operation.create("e", 5)
      operation.create("f", 6)
      operation.create("g", 7)

      operation.update("c", 8)
      operation.update("d", 9)
      operation.update("e", 10)

      operation.delete("a")
      operation.delete("d")
      operation.delete("f")

      operation.apply_to(dictionary)

      dictionary.store.should eq({"b" => 2, "c" => 8, "e" => 10, "g" => 7})
    end
  end

  describe "#+" do
    it "combines operations into a new operation" do
      a = DictionaryOperation(String, Int32).new
      a.create("a", 1)
      a.create("b", 2)
      a.update("c", 3)
      a.delete("d")

      b = DictionaryOperation(String, Int32).new

      b.create("e", 4)
      b.update("a", 5)
      b.delete("b")

      c = a + b

      c.scheduled_creates.should eq({"a" => 5, "e" => 4})
      c.scheduled_updates.should eq({"c" => 3})
      c.scheduled_deletes.should eq(Set{"d"})
    end
  end
end
