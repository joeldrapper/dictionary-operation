require "./dictionary_interface"

class Dictionary(K, V)
  include DictionaryInterface

  getter :store

  def initialize
    @store = Hash(K, V).new
  end

  def create(key : K, value : V)
    raise KeyConflictError.new if @store.has_key?(key)
    @store[key] = value
  end

  def update(key : K, value : V)
    raise MissingKeyError.new unless @store.has_key?(key)
    @store[key] = value
  end

  def delete(key : K)
    raise MissingKeyError.new unless @store.has_key?(key)
    @store.delete(key)
  end
end
