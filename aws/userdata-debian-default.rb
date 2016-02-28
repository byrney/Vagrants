#!/usr/bin/env ruby

require 'aws-sdk'
require 'syslog'
require 'tempfile'

def log(message)
    Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) do |s|
        s.err message
    end
    puts message
end

def runuserdata()
    log( "starting userdata script" )
    s3 = AWS::S3.new;
    bucket = s3.buckets['dex-scripts']
    obj = bucket.objects['machinestart/host-register-dns.rb']
    obj || raise("error getting data from s3")
    script = obj.read
    log( "downloaded #{script.length} bytes of userdata script from s3" )
    eval(script)
    register()
    log("done")
rescue
    log("Exception")
    raise
end

runuserdata()

