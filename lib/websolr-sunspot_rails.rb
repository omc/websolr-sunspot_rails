require "sunspot/rails"
require "sunspot/rails/configuration"
require "sunspot/rails/searchable"
require "sunspot/rails/request_lifecycle"

if ENV["WEBSOLR_URL"]
  require "json"
  require "net/http"
  require "uri"
  
  api_key = ENV["WEBSOLR_URL"][/[0-9a-f]{11}/] or raise "Invalid WEBSOLR_URL: bad or no api key"
  
  ENV["WEBSOLR_CONFIG_HOST"] ||= "www.websolr.com"
  
  @pending = true
  puts "Checking index availability..."
  
  begin
    schema_url = URI.parse("http://#{ENV["WEBSOLR_CONFIG_HOST"]}/schema/#{api_key}.json")
    response = Net::HTTP.post_form(schema_url, "client" => "sunspot-1.0")
    json = JSON.parse(response.body.to_s)

    case json["status"]
    when "ok"
      puts "Index is available!"
      @pending = false
    when "pending"
      puts "Provisioning index, things may not be working for a few seconds ..."
      sleep 5
    when "error"
      STDERR.puts json["message"]
      @pending = false
    else
      STDERR.puts "wtf: #{json.inspect}" 
    end
  rescue Exception => e
    STDERR.puts "Error checking index status. It may or may not be available.\n" +
                "Please email support@onemorecloud.com if this problem persists.\n" +
                "Exception: #{e.message}"
  end
  
  module Sunspot #:nodoc:
    module Rails #:nodoc:
      class Configuration
        def hostname
          URI.parse(ENV["WEBSOLR_URL"]).host
        end
        def port
          URI.parse(ENV["WEBSOLR_URL"]).port
        end
        def path
          URI.parse(ENV["WEBSOLR_URL"]).path
        end
      end
    end
  end
  
  module Sunspot #:nodoc:
    module Rails #:nodoc:
      # 
      # This module adds an after_filter to ActionController::Base that commits
      # the Sunspot session if any documents have been added, changed, or removed
      # in the course of the request.
      #
      module RequestLifecycle
        class <<self
          def included(base) #:nodoc:
            base.after_filter do
              begin
                # Sunspot moved the location of the commit_if_dirty method around.
                # Let's support multiple versions for now.
                session = Sunspot::Rails.respond_to?(:master_session) ? 
                            Sunspot::Rails.master_session : 
                            Sunspot
                            
                if Sunspot::Rails.configuration.auto_commit_after_request?
                  session.commit_if_dirty
                elsif Sunspot::Rails.configuration.auto_commit_after_delete_request?
                  session.commit_if_delete_dirty
                end
              rescue Exception => e
                ActionController::Base.logger.error e.message
                ActionController::Base.logger.error e.backtrace.join("\n")
                false
              end
            end
          end
        end
      end
    end
  end
  
  #
  # Silently fail instead of raising an exception when an error occurs while writing to Solr.
  # NOTE: does not fail for reads; you should catch those exceptions, for example in a rescue_from statement.
  #
  class SilentFailSessionProxy < Sunspot::SessionProxy::AbstractSessionProxy
    attr_reader :search_session

    delegate :new_search, :search, :config,
              :new_more_like_this, :more_like_this,
              :delete_dirty, :delete_dirty?, :commit_if_delete_dirty,
              :to => :search_session

    def initialize(search_session = Sunspot.session)
      @search_session = search_session
    end

    def rescued_exception(method, e)
      $stderr.puts("Exception in #{method}: #{e.message}")
    end

    SUPPORTED_METHODS = [
      :batch, :commit, :commit_if_dirty, :dirty?, :index!, :index,
      :remove!, :remove, :remove_all!, :remove_all,
      :remove_by_id!, :remove_by_id
    ]

    SUPPORTED_METHODS.each do |method|
      module_eval(<<-RUBY)
        def #{method}(*args, &block)
          begin
            search_session.#{method}(*args, &block)
          rescue => e
            self.rescued_exception(:#{method}, e)
          end
        end
      RUBY
    end
  end
  
  Sunspot.session = SilentFailSessionProxy.new(Sunspot.session)
  
end
