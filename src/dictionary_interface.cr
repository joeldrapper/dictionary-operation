module DictionaryInterface
  abstract def create(key : K, value : V)
  abstract def update(key : K, value : V)
  abstract def delete(key : K)

  class KeyConflictError < Exception; end

  class MissingKeyError < Exception; end
end
