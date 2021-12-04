require "active_storage/variant_with_record"

# Patch in https://github.com/rails/rails/pull/40842/files
module EagerLoadVariant

  private

  def record
    @record ||= if blob.variant_records.loaded?
      blob.variant_records.detect { |v| v.variation_digest == variation.digest }
    else
      blob.variant_records.find_by(variation_digest: variation.digest)
    end
  end
end

raise("Has the PR for this been merged yet?") unless Rails.version =~ /6\.1/

ActiveStorage::VariantWithRecord.prepend(EagerLoadVariant)
