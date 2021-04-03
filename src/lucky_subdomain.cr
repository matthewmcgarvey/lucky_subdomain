require "lucky"

module LuckySubdomain
  VERSION = "0.1.0"

  alias Matcher = String | Regex | Bool | Array(String | Regex) | Array(String) | Array(Regex)

  macro subdomain(matcher = true)
    before match_subdomain

    private def subdomain : String
      fetch_subdomain.not_nil!
    end

    private def match_subdomain
      match_subdomain({{ matcher }})
    end
  end

  private def fetch_subdomain
    host = request.hostname
    return if host.nil?

    parts = host.split('.')
    parts.pop(2)

    parts.empty? ? nil : parts.join(".")
  end

  private def match_subdomain(matcher : Matcher)
    expected = [matcher].flatten.compact
    return continue if expected.empty?

    actual = fetch_subdomain
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
