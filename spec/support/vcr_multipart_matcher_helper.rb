# frozen_string_literal: true

# This is needed for mismatching multi-part boundaries -- replacing random boundaries within the 'Content-Type' header
# Multipart boundaries are most often randomly generated by the HTTP library or browser
# so when VCR tries to match a multipart request with a cassette,
# the boundaries will be different and the match will fail.
# Thischange was introduced when upgrading to Faraday 0.17.0
# The Content-Type header makes the request recognizable as multipart request but also specifies the exact boundary

# example: The boundary is random/unique per request. Upon VCR cassette matching, the request boundary fails:
# before normalizing boundary: "Content-Type"=>[...=-----------RubyMultipartPost-59e4838b71b5b6d9da3596629c7aa4bc"]
# after normalizing boundary: "Content-Type"=>[...=-----------RubyMultipartPost"]

MULTIPART_HEADER_MATCHER = %r{^multipart/form-data; boundary=(.+)$}.freeze
BOUNDARY_STRING = '-----------RubyMultipartPost'

def normalized_multipart_request(request)
  content_type = (request.headers['Content-Type'] || []).first.to_s

  boundary = MULTIPART_HEADER_MATCHER.match(content_type)[1]

  request.headers['Content-Type'].first.gsub!(boundary, BOUNDARY_STRING)
  request.body.gsub!(boundary, BOUNDARY_STRING)
  request.body.gsub!('RubyMultipartPost--\r\n"', 'RubyMultipartPost--\r\n\r\n"')
  request.headers.delete('Content-Length')
end
