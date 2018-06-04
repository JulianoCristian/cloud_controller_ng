require 'presenters/v3/base_presenter'
require 'presenters/helpers/censorship'

module VCAP::CloudController
  module Presenters
    module V3
      class PackagePresenter < BasePresenter

        def initialize(resource, show_secrets: false, censored_message: Censorship::REDACTED_CREDENTIAL)
          super
        end

        def to_hash
          {
            guid:       package.guid,
            type:       package.type,
            data:       build_data,
            state:      package.state,
            created_at: package.created_at,
            updated_at: package.updated_at,
            links:      build_links,
          }
        end

        private

        def package
          @resource
        end

        def build_data
          package.docker? ? docker_data : buildpack_data
        end

        def docker_data
          {
            image: package.image,
            username: package.docker_username,
            password: package.docker_username && Censorship::REDACTED_CREDENTIAL,
          }
        end

        def buildpack_data
          {
            error: package.error,
            checksum:  package.checksum_info,
          }
        end

        def build_links
          url_builder = VCAP::CloudController::Presenters::ApiUrlBuilder.new

          upload_link   = nil
          download_link = nil
          if package.type == 'bits'
            upload_link = if VCAP::CloudController::Config.config.get(:bits_service, :enabled)
                            { href: bits_service_client.blob(package.guid).public_upload_url, method: 'PUT' }
                          else
                            { href: url_builder.build_url(path: "/v3/packages/#{package.guid}/upload"), method: 'POST' }
                          end

            download_link = { href: url_builder.build_url(path: "/v3/packages/#{package.guid}/download"), method: 'GET' }
          end

          links = {
            self:     { href: url_builder.build_url(path: "/v3/packages/#{package.guid}") },
            upload:   upload_link,
            download: download_link,
            app:      { href: url_builder.build_url(path: "/v3/apps/#{package.app_guid}") },
          }

          links.delete_if { |_, v| v.nil? }
        end

        def bits_service_client
          CloudController::DependencyLocator.instance.package_blobstore
        end
      end
    end
  end
end
