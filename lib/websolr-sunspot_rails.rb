require "sunspot/rails"
require "sunspot/rails/configuration"
require "sunspot/rails/searchable"
require "sunspot/rails/request_lifecycle"

if ENV["WEBSOLR_URL"]
  require "json"
  require "rest_client"
  require "uri"
  
  api_key = ENV["WEBSOLR_URL"][/[0-9a-f]{11}/] or raise "Invalid WEBSOLR_URL: bad or no api key"
  
  ENV["WEBSOLR_CONFIG_HOST"] ||= "www.websolr.com"
  
  @pending = true
  Rails.logger.info "Checking index availability..."

  response = RestClient.post("http://#{ENV["WEBSOLR_CONFIG_HOST"]}/schema/#{api_key}.json", :client => "sunspot-1.0")
  json = JSON.parse(response)
  case json["status"]
  when "ok"
    Rails.logger.info "Index is available!"
    @pending = false
  when "pending"
    Rails.logger.info "Provisioning index, things may not be working for a few seconds ..."
    sleep 5
  when "error"
    Rails.logger.error json["message"]
    @pending = false
  else
    Rails.logger.error "wtf: #{json.inspect}" 
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
  
  # This code makes saves go though even though solr is down.
  module Sunspot
    module Rails 
      module Searchable
        module InstanceMethods
          %w[solr_index solr_index! solr_remove_from_index solr_remove_from_index!].each do |method|
            new_name = method =~ /!/ ? method.gsub("!", "") + "_with_caught_errors!" : "#{method}_with_caught_errors"
            old_name = new_name.sub("_with_", "_without_")
            define_method(new_name) do
              begin
                send(old_name)
              rescue Exception => e
                logger.error e.message
                logger.error e.backtrace.join("\n")
                false
              end
            end
            alias_method_chain method, :caught_errors
          end
        end
      end
    end
  end 
end
