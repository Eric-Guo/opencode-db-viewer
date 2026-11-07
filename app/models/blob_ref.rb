class BlobRef < ApplicationRecord
  include StoredContentHash

  self.table_name = "blob_ref"
  self.primary_key = [:session_id, :message_id, :hash]

  belongs_to :stored_blob, foreign_key: :hash, primary_key: :hash
end
