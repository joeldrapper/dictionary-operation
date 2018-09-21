require "./spec_helper"
require "../src/dictionary"

describe Dictionary do
  describe "#create" do
    it "raises a KeyConflictError if the key already exists" do
      dictionary = Dictionary(String, Int32).new
      dictionary.create("a", 1)

      expect_raises Dictionary::KeyConflictError do
        dictionary.create("a", 2)
      end
    end

    it "creates a new record" do
      dictionary = Dictionary(String, Int32).new
      dictionary.create("a", 1)

      dictionary.store["a"].should eq(1)
    end
  end

  describe "#update" do
    it "raises a MissingKeyError if the record doesn't exist" do
      dictionary = Dictionary(String, Int32).new

      expect_raises Dictionary::MissingKeyError do
        dictionary.update("a", 2)
      end
    end

    it "updates a record" do
      dictionary = Dictionary(String, Int32).new
      dictionary.create("a", 1)
      dictionary.update("a", 2)

      dictionary.store["a"].should eq(2)
    end
  end

  describe "#delete" do
    it "raises a MissingKeyError if the record doesn't exist" do
      dictionary = Dictionary(String, Int32).new

      expect_raises Dictionary::MissingKeyError do
        dictionary.delete("a")
      end
    end

    it "deletes a record" do
      dictionary = Dictionary(String, Int32).new
      dictionary.create("a", 1)
      dictionary.delete("a")

      dictionary.store.has_key?("a").should be_false
    end
  end
end
