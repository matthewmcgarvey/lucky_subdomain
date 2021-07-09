require "habitat"
require "lucky"

module LuckySubdomain
  VERSION = "0.1.0"
  # Taken from https://github.com/rails/rails/blob/afc6abb674b51717dac39ea4d9e2252d7e40d060/actionpack/lib/action_dispatch/http/url.rb#L8
  IP_HOST_REGEXP = /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/

  Habitat.create do
    setting tld_length : Int32 = 1
  end

  alias Matcher = String | Regex | Bool | Array(String | Regex) | Array(String) | Array(Regex)

  macro register_subdomain(matcher = true)
    before _match_subdomain

    private def subdomain : String
      _fetch_subdomain.not_nil!
    end

    private def _match_subdomain
      _match_subdomain({{ matcher }})
    end
  end

  def subdomain : String
    {% raise "No subdomain available without calling `register_subdomain` first." %}
  end

  private def _fetch_subdomain : String?
    host = request.hostname
    return if host.nil? || IP_HOST_REGEXP.matches?(host)

    parts = host.split('.')
    parts.pop(settings.tld_length + 1)

    parts.empty? ? nil : parts.join(".")
  end

  private def _match_subdomain(matcher : Matcher)
    expected = [matcher].flatten.compact
    return continue if expected.empty?

    actual = _fetch_subdomain
    result = expected.any? do |expected_subdomain|
      case expected_subdomain
      when true
        actual.present?
      when Symbol
        actual.to_s == expected_subdomain.to_s
      else
        expected_subdomain === actual
      end
    end

    if result
      continue
    else
      raise InvalidSubdomainError.new
    end
  end

  class InvalidSubdomainError < Exception
  end
end
