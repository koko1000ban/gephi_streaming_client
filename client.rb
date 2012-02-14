#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'net/http'
require 'json'

class GephiStreamingClient

  def initialize(url="http://127.0.0.1:8080/workspace0",  opts={ })
    @opts = { 
      :autoflush => true,  # 一括送信するかしないか
      :debug => false
    }.merge(opts)
    
    @url = url
    @data = []
  end
  
  def autoflush?
    @opts[:autoflush]
  end
  
  def log(m)
    warn m if @opts[:debug]
  end

  def flush
    if @data.size > 0
      request(@data)
      @data=[]
    end
  end
  
  def add_node(id, attributes)
    @data << {"an"=>{id => attributes }}
    if autoflush?
      flush
    end
  end
  
  def add_edge(id, source, target, attributes={ })
    
    attributes[:source]=source
    attributes[:target]=target
    attributes[:directed] ||= true

    @data << { "ae" => { id => attributes } }
    if autoflush?
      flush
    end
  end
  
  def delete_node(id)
    request({"dn" => { id => { } } })
  end

  def delete_edge(id)
    request({"de" => { id => { } }})
  end
  
  def clean
    request({"dn" => { "filter" => "ALL" }})
  end

  private
  def json_dump(h)
    JSON.dump(h)
  end

  def request(data)
    
    data = case data
           when Array
             data.inject("") { |accum, elem| accum << json_dump(elem) + "\r\n" }
           when Hash
             json_dump(data)
           else
             warn "data has unknown type : #{data.class}"
             data
           end
    
    log "send data : #{data}"
    if @opts[:dry_run]
      return
    end
    
    uri = URI.parse(@url)
    Net::HTTP.start(uri.host, uri.port){ |http|
      http.post(uri.path + "?operation=updateGraph", data)
    }
  end
end
