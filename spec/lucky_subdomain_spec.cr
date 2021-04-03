require "./spec_helper"

include ContextHelper

abstract class BaseAction < Lucky::Action
  include LuckySubdomain
  accepted_formats [:html], default: :html
end

class Simple::Index < BaseAction
  subdomain

  get "/simple" do
    plain_text subdomain
  end
end

class Specific::Index < BaseAction
  subdomain "foo"

  get "/specific" do
    plain_text subdomain
  end
end

class Regex::Index < BaseAction
  subdomain /www\d/

  get "/regex" do
    plain_text subdomain
  end
end

class Multiple::Index < BaseAction
  subdomain ["test", "staging", /(prod|production)/]

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
end
