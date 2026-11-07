class StoredBlob < ApplicationRecord
  include StoredContentHash
  include OpenCodeRecord

  self.table_name = "blob"
  self.primary_key = "hash"

  RASTER_TYPES = %w[image/png image/jpeg image/gif image/webp image/avif image/bmp].freeze

  def previewable?
    RASTER_TYPES.include?(mime)
  end
end
