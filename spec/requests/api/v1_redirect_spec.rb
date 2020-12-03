RSpec.describe("v1 redirects") do
  include ::Spec::Support::TenantIdentity

  let(:expected_version) { "v1.0" }
  let(:major_version)    { expected_version.match(/^(v[\d]+)\.[\d]+$/)[1] }
  let(:headers)          { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  describe("/api/v1") do
    it "redirects to the latest minor version" do
      get("/api/#{major_version}/vms", :headers => headers)
      expect(response.status).to eq(302)
      expect(response.headers["Location"]).to eq("/api/#{expected_version}/vms")
    end

    it "preserves the openapi.json file extension when using a redirect" do
      get("/api/#{major_version}/openapi.json")
      expect(response.status).to eq(302)
      expect(response.headers["Location"]).to eq("/api/#{expected_version}/openapi.json")
    end

    it "preserves the openapi.json file extension when not using a redirect" do
      get("/api/#{expected_version}/openapi.json")
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end

    it "direct request doesn't break service_instances" do
      get("/api/#{expected_version}/service_instances", :headers => headers)
      expect(response.status).to eq(200)
      expect(response.headers["Location"]).to be_nil
    end
  end
end
