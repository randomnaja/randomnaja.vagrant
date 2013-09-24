class statsd {
  require addproxy
  include statsd::install, statsd::configure, statsd::service
 
}
