if RUBY_PLATFORM == 'java'

  require 'uri'
  require 'http_client'
  require 'cgi'
  module Curl
    class Easy
      attr_accessor :headers, :encoding
      attr_reader :response_code, :body_str

      def initialize(url, method=nil, payload=nil, headers={})
        @method = method
        @url=url
        @payload=payload
        @headers = headers
        hydra_url = $hydra_url.split(":")
        @http_client = HTTP::Client.new(:host => "#{hydra_url[0]+hydra_url[1]}", :port => "#{hydra_url[2]}")
      end

      def perform
        case @method
          when :post
            request = HTTP::Post.new(@url)
            request.body=@payload
          when :get
            request = HTTP::Get.new(@url)
          when :delete
            request = HTTP::Delete.new(@url)
          when :put
            request = HTTP::Put.new(@url)
            request.body=@payload
          else
            raise "Unrecognized request method"
        end
        request.add_headers(@headers)
        request.encoding=@encoding if @encoding
        response = @http_client.execute(request)
        @response_code=response.status_code
        @body_str=response.body
        @body_str.encode!("ISO-8859-1")
      end

      def http_put(payload=nil)
        #This implementation in original curb sends the request, so we do the same
        @method=:put
        @payload=payload
        perform
      end

       def http_post(payload=nil)
        #This implementation in original curb sends the request, so we do the same
        @method=:post
        @payload=payload
        perform
      end

      def http_delete
        #This implementation in original curb sends the request, so we do the same
        @method=:delete
        perform
      end

      def self.http_post(url, payload)
        Easy.new url, :post, payload
      end

      def self.http_get(url, payload=nil)
        Easy.new url, :get, payload
      end
    end
  end

  class HTTP::Get
    alias create_native_request_old  create_native_request
    def create_native_request
      query_string = org.apache.http.client.utils.URLEncodedUtils.format(@query_params, encoding)
      query_string=query_string.gsub("%5B%22","").gsub("%22%5D","") if query_string
      org.apache.http.client.methods.HttpGet.new(create_uri(query_string))
    end
  end
end

