variable "s3_origins" {
  type = map(object({
    domain_name = string
    custom_headers = map(string)
    origin_access_identity = any
  }))
  description = "Map of S3 origins"
  default = {}
}

variable "domain_origins" {
  type = map(object({
    domain_name = string
    custom_headers = map(string)
    http_port = number
    https_port = number
    origin_keepalive_timeout = number
    origin_read_timeout = number
    origin_protocol_policy = string
    origin_ssl_protocols = string
  }))
  description = "Map of Domain Name origins"
  default = {}
}

variable "cache_behaviors" {
  type = list(object({
    path_pattern = string
    allowed_methods = string
    cached_methods = string
    target_origin_id = string
    min_ttl = number
    max_ttl = number
    default_ttl = number
    compress = bool
    smooth_streaming = bool
    viewer_protocol_policy = string
    forwarded_value_query_string = string
    forwarded_value_headers = string
    forwarded_value_cookies = string
    lambda_function = map(map(string))
  }))
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
}

variable "cloudfront_default_certificate" {
  type = bool
  default = false
}

variable "acm_certificate" {
  type = object({
    ssl_support_method = string
    minimum_protocol_version = string
    acm_certificate_arn = string
  })
  default = null
}

variable "default_cache_behavior" {
  type = object({
    allowed_methods = string
    cached_methods = string
    target_origin_id = string
    min_ttl = number
    max_ttl = number
    default_ttl = number
    compress = bool
    viewer_protocol_policy = string
    forwarded_value_query_string = string
    forwarded_value_cookies = string
    forwarded_value_headers = string
    lambda_function = map(map(string))
  })
  description = "The default cache behavior for this distribution (maximum one)."
}

variable "custom_error_responses" {
  type = map(object({
    error_caching_min_ttl = number
    response_code = number
    response_page_path = string
  }))
  description = "Custom Error Response map"
}

variable "enabled" {
  type = bool
  description = "Flag to enable/disable the distribution. Defaults to true"
  default = true
}

variable "web_acl_id" {
  type = string
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  default = null
}

variable "is_ipv6_enabled" {
  type = bool
  description = "Flag to enable/disable IPv6 support. Defaults to false"
  default = false
}

variable "description" {
  type = string
  description = "Description of the CloudFront distribution"
}

variable "price_class" {
  type = string
  description = "CloudFront price class. Defaults to PriceClass_All"
  default = "PriceClass_All"
}

variable "http_version" {
  type = string
  description = "HTTP version for distribution. Defaults to http2"
  default = "http2"
}

variable "aliases" {
  type = set(string)
  description = "Optional set of CNAME aliases to assign to the distribution"
  default = []
}

variable "ssl_support_method" {
  type = string
  description = "Distribution SSL support level. Defaults to TLSv1.2_2018"
  default = "TLSv1.2_2018"
}

variable "minimum_protocol_version" {
  type = string
  description = "Minimum protocol version. Defaults to sni-only"
  default = "sni-only"
}

variable "default_root_object" {
  type = string
  description = "Default root object for the distribution"
}

variable "allowed_methods" {
  type = string
  description = "Allowed HTTP methods CloudFront processes and forwards. Allowed values are get_head, get_head_options, or all. Defaults to all"
  default = "all"
}

variable "cached_methods" {
  type = string
  description = "CloudFront caches the response to requests using the specified HTTP methods. Allowed values, get_head or get_head_options. Defaults to get_head"
  default = "get_head"
}

variable "logs_include_cookies" {
  type = bool
  description = "Specifies whether you want CloudFront to include cookies in access logs. Defaults to false"
  default = false
}

variable "logs_prefix" {
  type = string
  description = "String that you want CloudFront to prefix to the access log filenames for this distribution, for example, myprefix/. Defaults to empty"
  default = ""
}

variable "logs_bucket_name" {
  type = string
  description = "Name of the cloudfront bucket to place logs in"
}

variable "cloudfront_geo_restriction_type" {
  type = string
  description = "The restriction configuration for this distribution (maximum one). Defaults to none"
  default = "none"
}

variable "tags" {
  type = map(string)
  description = "Map of key value pairs to add to the distribution as tags. Defaults to none"
  default = {}
}

