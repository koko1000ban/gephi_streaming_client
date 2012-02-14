# -*- coding: utf-8 -*-

# $LOAD_PATH.push("/path/to/lib")
$LOAD_PATH.push("./gephi_streaming_client")
require "client"

def idx(x, y, n)
  y*n+x
end

# initialize client
g = GephiStreamingClient.new "http://localhost:8080/workspace0"

# when use debug mode or dry_run mode, specify :debug => true , :dry_run => true
# g = GephiStreamingClient.new "http://localhost:8080/workspace0", :debug => true, :dry_run => false


# delete all nodes
g.clean

n=5
(0..n).each do |y|
  (0..n).each do |x|

    # add node 
    g.add_node idx(x, y, n), { :x => x, :y => y, :label => "#{x}_#{y}"}
    
    if y != 0
      src = idx(y,x,n)
      tgt = idx(y-1,x,n)
      
      # add directed edge
      g.add_edge(src+tgt, src, tgt, :directed => true)
    end

    sleep 0.5
  end
end

# send stocked data
g.flush
