module DataUrlDownload
  extend ActiveSupport::Concern

  private

  # Returns [mime, payload] for data: URLs, [nil, nil] otherwise.
  def decode_data_url(url)
    match = %r{\Adata:([^;,]+)?(;base64)?,(.*)\z}m.match(url.to_s)
    return [nil, nil] unless match

    [match[1].presence || "application/octet-stream", match[2] ? Base64.decode64(match[3]) : match[3]]
  end
end
