require "./spec_helper"

include ContextHelper

abstract class BaseAction < Lucky::Action
  include LuckySubdomain
  accepted_formats [:html], default: :html
end

class Simple::Index < BaseAction
  register_subdomain

  get "/simple" do
    plain_text subdomain
  end
end

class Specific::Index < BaseAction
  register_subdomain "foo"

  get "/specific" do
    plain_text subdomain
  end
end

class Regex::Index < BaseAction
  register_subdomain /www\d/

  get "/regex" do
    plain_text subdomain
  end
end

class Multiple::Index < BaseAction
  register_subdomain ["test", "staging", /(prod|production)/]

  get "/multiple" do
    plain_text subdomain
  end
end

describe LuckySubdomain do
  it "handles general subdomain expectation" do
    request = build_request(host: "foo.example.com")
    response = Simple::Index.new(build_context(request), params).call
    response.body.should eq "foo"
  end

  it "raises error if subdomain missing" do
    request = build_request(host: "example.com")
    expect_raises(LuckySubdomain::InvalidSubdomainError) do
      Simple::Index.new(build_context(request), params).call
    end
  end

  it "handles specific subdomain expectation" do
    request = build_request(host: "foo.example.com")
    response = Specific::Index.new(build_context(request), params).call
    response.body.should eq "foo"
  end

  it "raises error if subdomain does not match specific" do
    request = build_request(host: "admin.example.com")
    expect_raises(LuckySubdomain::InvalidSubdomainError) do
      Specific::Index.new(build_context(request), params).call
    end
  end

  it "handles regex subdomain expectation" do
    request = build_request(host: "www4.example.com")
    response = Regex::Index.new(build_context(request), params).call
    response.body.should eq "www4"
  end

  it "raises error if subdomain does not match regex" do
    request = build_request(host: "4www.example.com")
    expect_raises(LuckySubdomain::InvalidSubdomainError) do
      Regex::Index.new(build_context(request), params).call
    end
  end

  it "handles multiple options for expectation" do
    request = build_request(host: "test.example.com")
    response = Multiple::Index.new(build_context(request), params).call
    response.body.should eq "test"

    request = build_request(host: "staging.example.com")
    response = Multiple::Index.new(build_context(request), params).call
    response.body.should eq "staging"

    request = build_request(host: "prod.example.com")
    response = Multiple::Index.new(build_context(request), params).call
    response.body.should eq "prod"

    request = build_request(host: "production.example.com")
    response = Multiple::Index.new(build_context(request), params).call
    response.body.should eq "production"
  end

  it "raises error if subdomain does not match any expectations" do
    request = build_request(host: "development.example.com")
    expect_raises(LuckySubdomain::InvalidSubdomainError) do
      Multiple::Index.new(build_context(request), params).call
    end
  end

  it "has configuration for urls with larger tld length" do
    LuckySubdomain.temp_config(tld_length: 2) do
      request = build_request(host: "foo.example.co.uk")
      response = Simple::Index.new(build_context(request), params).call
      response.body.should eq "foo"
    end
  end

  it "will fail if using ip address" do
    request = build_request(host: "development.127.0.0.1:3000")
    expect_raises(LuckySubdomain::InvalidSubdomainError) do
      Simple::Index.new(build_context(request), params).call
    end
  end

  it "will not fail if using localhost and port with tld length set to 0" do
    LuckySubdomain.temp_config(tld_length: 0) do
      request = build_request(host: "foo.locahost:3000")
      response = Simple::Index.new(build_context(request), params).call
      response.body.should eq "foo"
    end
  end
end
