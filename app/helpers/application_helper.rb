module ApplicationHelper
  include Pagy::Frontend

  def svg_icon(cil_name, icon_class, options = {})
    options["xlink:href"] = asset_path(cil_name)
    content_tag :svg, nil, class: icon_class do
      content_tag :use, nil, options
    end
  end

  def pretty_json(value)
    JSON.pretty_generate(value)
  rescue JSON::GeneratorError, TypeError
    value.to_s
  end

  def formatted_debug_value(value)
    parsed = if value.is_a?(String)
      JSON.parse(value)
    else
      value
    end

    parsed.is_a?(String) ? parsed : pretty_json(parsed)
  rescue JSON::ParserError, TypeError
    value.to_s
  end

  def opencode_time(value)
    return "-" unless value

    value.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def footer
    content_tag :footer, nil, class: "footer" do
      left_part = content_tag :div, nil do
        concat link_to "CoreUI", "https://coreui.io"
        concat " "
        concat link_to "Rails Starter Template", "https://git.thape.com.cn/Eric-Guo/coreui-pro-rails-starter"
        concat "  © 2023 Eric-Guo."
      end
      right_part = content_tag :div, nil, class: "ms-auto" do
        concat "Powered by "
        concat link_to "CoreUI PRO UI Components", "https://coreui-doc.redwoodjs.cn/"
      end
      left_part.concat(right_part)
    end
  end
end
