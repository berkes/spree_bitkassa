##
# Helpers for the Bitkassa API interaction.
module BitkassaApiHelpers
  def api_payload
    if @request_signatures.nil? || @request_signatures.empty?
      fail "@request_signatures is empty"
    end

    first_signature = @request_signatures.first
    if first_signature.nil? || @request_signatures.first.body.nil?
      fail "@request_signatures has no requests"
    end

    request_payload = first_signature.body
    decoded = Base64.urlsafe_decode64(CGI::parse(request_payload)["p"].first)
    JSON.parse(decoded)
  end

  def record_api_requests
    @request_signatures = []
    WebMock.after_request do |request_signature, _response|
      @request_signatures << request_signature
    end
  end
end
