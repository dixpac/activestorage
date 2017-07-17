require "test_helper"
require "database/setup"

if SERVICE_CONFIGURATIONS[:s3]
  class ActiveStorage::S3DirectUploadsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @blob = create_blob
      @old_service = ActiveStorage::Blob.service
      ActiveStorage::Blob.service = ActiveStorage::Service.configure(:s3, SERVICE_CONFIGURATIONS)
    end

    teardown do
      ActiveStorage::Blob.service = @old_service
    end

    test "creating new direct upload" do
      post rails_direct_uploads_url, params: { blob: {
          filename: "hello.txt", byte_size: 6, checksum: Digest::MD5.base64digest("Hello"), content_type: "text/plain" } }

      details = JSON.parse(@response.body)

      assert_match /#{SERVICE_CONFIGURATIONS[:s3][:bucket]}\.s3.(\S+)?amazonaws\.com/, details["url"]
      assert_equal "hello.txt", GlobalID::Locator.locate_signed(details["sgid"]).filename.to_s
    end
  end
else
  puts "Skipping S3 Direct Upload tests because no S3 configuration was supplied"
end

if SERVICE_CONFIGURATIONS[:gcs]
  class ActiveStorage::GCSDirectUploadsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @blob = create_blob
      @config = SERVICE_CONFIGURATIONS[:gcs]

      @old_service = ActiveStorage::Blob.service
      ActiveStorage::Blob.service = ActiveStorage::Service.configure(:gcs, SERVICE_CONFIGURATIONS)
    end

    teardown do
      ActiveStorage::Blob.service = @old_service
    end

    test "creating new direct upload" do
      post rails_direct_uploads_url, params: { blob: {
          filename: "hello.txt", byte_size: 6, checksum: Digest::MD5.base64digest("Hello"), content_type: "text/plain" } }

      details = JSON.parse(@response.body)

      assert_match %r{storage\.googleapis\.com/#{@config[:bucket]}}, details["url"]
      assert_equal "hello.txt", GlobalID::Locator.locate_signed(details["sgid"]).filename.to_s
    end
  end
else
  puts "Skipping GCS Direct Upload tests because no GCS configuration was supplied"
end
