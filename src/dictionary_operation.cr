require "./dictionary_interface"

class DictionaryOperation(K, V)
  include DictionaryInterface

  property scheduled_creates, scheduled_updates, scheduled_deletes

  def initialize
    @scheduled_creates = Hash(K, V).new
    @scheduled_updates = Hash(K, V).new
    @scheduled_deletes = Set(K).new
  end

  def create(key : K, value : V)
    raise KeyConflictError.new if @scheduled_creates.has_key?(key) || @scheduled_updates.has_key?(key)

    if @scheduled_deletes.includes?(key)
      @scheduled_deletes.delete(key)
      @scheduled_updates[key] = value
    else
      @scheduled_creates[key] = value
    end
  end

  def update(key : K, value : V)
    raise MissingKeyError.new if @scheduled_deletes.includes?(key)

    if @scheduled_creates.has_key?(key)
      @scheduled_creates[key] = value
    else
      @scheduled_updates[key] = value
    end
  end

  def delete(key : K)
    raise MissingKeyError.new if @scheduled_deletes.includes?(key)

    if @scheduled_creates.has_key?(key)
      @scheduled_creates.delete(key)
    else
      @scheduled_updates.delete(key)
      @scheduled_deletes << key
    end
  end

  def apply_to(dictionary : DictionaryInterface)
    @scheduled_deletes.each { |k| dictionary.delete(k) }
    @scheduled_updates.each { |k, v| dictionary.update(k, v) }
    @scheduled_creates.each { |k, v| dictionary.create(k, v) }

    return dictionary
  end

  def +(addend : self)
    addend.apply_to(dup)
  end
end
