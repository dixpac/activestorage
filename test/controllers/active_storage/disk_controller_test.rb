require "test_helper"
require "database/setup"

require "active_storage/verified_key_with_expiration"

module ActiveStorage
  class DiskControllerTest < ActionDispatch::IntegrationTest
    setup do
      @blob = create_blob
    end

    test "showing blob inline" do
      get rails_disk_blob_url(filename: @blob.filename, encoded_key: ActiveStorage::VerifiedKeyWithExpiration.encode(@blob.key, expires_in: 5.minutes))

      assert_equal "inline; filename=\"#{@blob.filename}\"", @response.headers["Content-Disposition"]
      assert_equal "text/plain", @response.headers["Content-Type"]
    end

    test "sending blob as attachment" do
      get rails_disk_blob_url(filename: @blob.filename, encoded_key: ActiveStorage::VerifiedKeyWithExpiration.encode(@blob.key, expires_in: 5.minutes), disposition: :attachment)

      assert_equal "attachment; filename=\"#{@blob.filename}\"", @response.headers["Content-Disposition"]
      assert_equal "text/plain", @response.headers["Content-Type"]
    end
  end
end
