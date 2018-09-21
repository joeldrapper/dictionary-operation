require "./dictionary_interface"

class DictionaryOperation(K, V)
  include DictionaryInterface

  property scheduled_updates, scheduled_deletes

  def initialize
    @scheduled_updates = Hash(K, V).new
    @scheduled_deletes = Set(K).new
  end

  def []=(key : K, value : V)
    @scheduled_deletes.delete(key)
    @scheduled_updates[key] = value
  end

  def delete(key : K)
    @scheduled_updates.delete(key)
    @scheduled_deletes << key
  end

  def apply_to(dictionary : DictionaryInterface)
    @scheduled_deletes.each { |k| dictionary.delete(k) }
    @scheduled_updates.each { |k, v| dictionary[k] = v }

    return dictionary
  end

  def +(addend : self)
    addend.apply_to(dup)
  end
end
