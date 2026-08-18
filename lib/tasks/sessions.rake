namespace :sessions do
  # Converts markdown data-URI images (e.g. "![image_1](data:image/png;base64,...)") embedded in
  # message text content parts into structured file content parts (like opencode's gemini image
  # sessions), so they render as images on the session page.
  # Returns [converted_messages, converted_images].
  def convert_markdown_images_in(scope, dry_run:)
    image_pattern = /!\[([^\]]*)\]\((data:(image\/[a-zA-Z0-9.+-]+);base64,[A-Za-z0-9+\/=\s]+?)\)/

    extension_for = lambda do |mime|
      {"image/jpeg" => "jpg"}.fetch(mime, mime.to_s.split("/").last.presence || "bin")
    end

    converted_messages = 0
    converted_images = 0

    scope.find_each do |message|
      content = message.content
      next if content.empty?
      next unless content.any? { |item| item["type"] == "text" && item["text"].to_s.match?(image_pattern) }

      file_index = content.count { |item| item["type"] == "file" }
      new_content = []

      content.each do |item|
        unless item["type"] == "text" && item["text"].to_s.match?(image_pattern)
          new_content << item
          next
        end

        text = item["text"].to_s
        offset = 0
        text.scan(image_pattern) do |_alt, data_uri, mime|
          match = Regexp.last_match
          prose = text[offset...match.begin(0)].strip
          new_content << {"type" => "text", "text" => prose} if prose.present?

          file_id = "generated-#{message.id}-#{file_index}"
          new_content << {
            "type" => "file",
            "id" => file_id,
            "mime" => mime,
            "filename" => "#{file_id}.#{extension_for.call(mime)}",
            "url" => data_uri
          }
          file_index += 1
          converted_images += 1
          offset = match.end(0)
        end

        tail = text[offset..].to_s.strip
        new_content << {"type" => "text", "text" => tail} if tail.present?
      end

      converted_messages += 1
      puts "  #{message.session_id} / #{message.id}: #{content.size} -> #{new_content.size} content part(s)"
      unless dry_run
        data = message.parsed_data.merge("content" => new_content)
        message.update!(data: data.to_json, time_updated: (Time.current.to_f * 1000).to_i)
      end
    end

    [converted_messages, converted_images]
  end

  desc "Convert markdown data-URI images embedded in a session's message text into structured " \
    "file content parts, so they render as images on the session page. " \
    "Usage: bin/rails 'sessions:convert_markdown_images[session_id]'. Use DRY_RUN=1 to preview."
  task :convert_markdown_images, [:session_id] => :environment do |_t, args|
    abort("Usage: bin/rails 'sessions:convert_markdown_images[session_id]'") if args[:session_id].blank?

    messages, images = convert_markdown_images_in(
      SessionMessage.where(session_id: args[:session_id]).order(:seq),
      dry_run: ENV["DRY_RUN"] == "1"
    )
    puts "Converted #{images} image(s) in #{messages} message(s)."
    puts "Dry run, nothing changed." if ENV["DRY_RUN"] == "1"
  end

  desc "Convert markdown data-URI images embedded in message text into structured file content " \
    "parts across every session in the database. Use DRY_RUN=1 to preview."
  task convert_all: :environment do
    messages, images = convert_markdown_images_in(
      SessionMessage.order(:session_id, :seq),
      dry_run: ENV["DRY_RUN"] == "1"
    )
    puts "Converted #{images} image(s) in #{messages} message(s)."
    puts "Dry run, nothing changed." if ENV["DRY_RUN"] == "1"
  end
end
