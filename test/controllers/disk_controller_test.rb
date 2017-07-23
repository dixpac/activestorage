require "test_helper"
require "database/setup"

class ActiveStorage::DiskControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_blob
  end

  test "showing blob inline" do
    get rails_disk_blob_url(
      filename: "hello.txt",
      content_type: @blob.content_type,
      encoded_key: ActiveStorage.verifier.generate(@blob.key, expires_in: 5.minutes, purpose: :blob_key)
    )

    assert_equal "inline; filename=\"#{@blob.filename.base}\"", @response.headers["Content-Disposition"]
    assert_equal "text/plain", @response.headers["Content-Type"]
  end

  test "sending blob as attachment" do
    get rails_disk_blob_url(
      filename: @blob.filename,
      content_type: @blob.content_type,
      encoded_key: ActiveStorage.verifier.generate(@blob.key, expires_in: 5.minutes, purpose: :blob_key),
      disposition: :attachment
    )

    assert_equal "attachment; filename=\"#{@blob.filename.base}\"", @response.headers["Content-Disposition"]
    assert_equal "text/plain", @response.headers["Content-Type"]
  end
end
