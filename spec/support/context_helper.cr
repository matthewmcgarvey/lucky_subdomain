module ContextHelper
  extend self

  private def build_request(
    host = "example.com",
    method = "GET",
    path = "/"
  ) : HTTP::Request
    headers = HTTP::Headers.new
    headers.add("Content-Type", "")
    headers.add("Host", host)
    HTTP::Request.new(method, path, body: "", headers: headers)
  end

  private def build_context(request : HTTP::Request) : HTTP::Server::Context
    HTTP::Server::Context.new request, HTTP::Server::Response.new(IO::Memory.new)
  end

  private def params
    {} of String => String
  end
end
