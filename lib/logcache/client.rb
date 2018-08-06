require 'logcache/logcache_egress_services_pb'

module Logcache
  class Client

    attr_reader :service
    
    def initialize(host:, port:, client_ca_path:, client_cert_path:, client_key_path:)
      client_ca = IO.read(client_ca_path)
      client_key = IO.read(client_key_path)
      client_cert = IO.read(client_cert_path)

      @service = Logcache::V1::Egress::Stub.new(
        "#{host}:#{port}",
        GRPC::Core::ChannelCredentials.new(client_ca, client_key, client_cert)
      )
    end

    def container_metrics(auth_token: nil, app_guid:)
      response = service.read(build_read_request(app_guid))
      response
    end

    private

    def build_read_request(source_id)
      Logcache::V1::ReadRequest.new(
        {
          source_id: source_id
        }
      )
    end
  end
end
