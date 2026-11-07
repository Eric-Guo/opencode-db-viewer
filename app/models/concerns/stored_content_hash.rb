module StoredContentHash
  extend ActiveSupport::Concern

  class_methods do
    # Keep Active Record's object hash; the database column is read through content_hash.
    def instance_method_already_implemented?(name)
      name == "hash" || super
    end
  end

  def content_hash
    self[:hash]
  end
end
