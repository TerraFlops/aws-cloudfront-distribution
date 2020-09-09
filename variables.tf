variable "name" {
  description = "Name of the CloudFront distribution in snake case. This will be used to tag related resources (e.g. 'manage_frontend')"
  type = string
}

variable "domain_name" {
  description = "The domain name to be linked to the distribution (do not include the hosted zone name, ie. 'www.example.com' should be entered as 'www')"
  type = string
}

variable "hosted_zone_id" {
  description = "The hosted zone in which the distributions primary domain name ACM certificate will be created"
  type = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to be associated with the distribution"
  type = string
}

variable "aliases" {
  description = "Optional set of CNAME records which will be associated with the distribution"
  type = set(string)
  default = []
}

variable "comment" {
  description = "Optional comment to be added to the distribution. If none is supplied the primary domain name will be used"
  type = string
  default = null
}

variable "custom_error_responses" {
  description = "Optional list of custom error responses"
  type = list(object({
    ttl = number
    error_code = number
    response_code = number
    path = string
  }))
  default = []
}

variable "default_cache_behavior" {
  description = "The default cache behavior"
  type = object({
    allowed_methods = set(string)
    cached_methods = set(string)
    compress = bool
    default_ttl = number
    field_level_encryption_id = string
    forwarded_values = object({
      cookies = object({
        forward = string
        whitelisted_names = set(string)
      })
      headers = set(string)
      query_string = bool
      query_string_cache_keys = set(string)
    })
    lambda_function_associations = list(object({
      event_type = string
      include_body = bool
      lambda_arn = string
    }))
    max_ttl = number
    min_ttl = number
    smooth_streaming = bool
    target_origin_id = string
    trusted_signers = set(string)
    viewer_protocol_policy = string
  })
}

variable "default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL"
  type = string
  default = ""
}

variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type = bool
  default = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type = bool
  default = false
}

variable "http_version" {
  description = "The maximum HTTP version to support on the distribution. Allowed values are 'http1.1' and 'http2'. The default is 'http2'."
  type = string
  default = "http2"
}

variable "log_bucket_create" {
  description = "Boolean flag, if true the S3 bucket for logging will be created by the module. Defaults to false"
  type = bool
  default = false
}

variable "log_bucket_name" {
  description = "Optional override for the name of S3 log bucket that CloudFront will use. If not supplied a name will be generated based on the supplied distribution name and hosted zone"
  type = string
  default = null
}

variable "log_bucket_prefix" {
  description = "Optional prefix to add to log files in the bucket"
  type = string
  default = ""
}

variable "log_bucket_include_cookies" {
  description = "Boolean flag, if true cookies will be included in the access logs. Defaults to true"
  type = bool
  default = true
}

variable "ordered_cache_behaviors" {
  description = "An ordered list of cache behaviors for the distribution"
  type = list(object({
    allowed_methods = set(string)
    cached_methods = set(string)
    compress = bool
    default_ttl = number
    field_level_encryption_id = string
    forwarded_values = object({
      cookies = object({
        forward = string
        whitelisted_names = set(string)
      })
      headers = set(string)
      query_string = bool
      query_string_cache_keys = set(string)
    })
    lambda_function_associations = list(object({
      event_type = string
      include_body = bool
      lambda_arn = string
    }))
    max_ttl = number
    min_ttl = number
    path_pattern = string
    smooth_streaming = bool
    target_origin_id = string
    trusted_signers = set(string)
    viewer_protocol_policy = string
  }))
  default = []
}

variable "origins_s3" {
  description = "Map of S3 bucket origins indexed by a unique identifier"
  type = map(object({
    domain_name = string
    path = string
    origin_access_identity = string
  }))
  default = {}
}

variable "origins_custom" {
  description = "Map of custom origins indexed by a unique identifier"
  type = map(object({
    domain_name = string
    path = string
    custom_headers = map(string)
    http_port = number
    https_port = number
    protocol_policy = string
    ssl_protocols = string
    keepalive_timeout = number
    read_timeout = number
  }))
  default = {}
}

variable "price_class" {
  description = "The price class for this distribution, one of 'price_class_all', 'price_class_200', 'price_class_100'. Defaults to 'price_class_all'"
  type = string
  default = "price_class_all"
}

variable "restriction_type" {
  description = "Restrictions to apply to the distribution, one of 'whitelist', 'blacklist' or 'none'. Defaults to 'none'"
  type = string
  default = "none"
}

variable "restriction_locations" {
  description = "If restrictions are enabled via a whitelist or blacklist, this is the set of restricted locations"
  type = set(string)
  default = []
}

variable "tags" {
  description = "Optional map of tags to associate with the distribution"
  type = map(string)
  default = {}
}

variable "viewer_certificate_minimum_protocol_version" {
  description = "The minimum version of the SSL protocol to support for HTTPS connections. Defaults to TLSv1.2_2019"
  type = string
  default = "TLSv1.2_2019"
}

variable "viewer_certificate_ssl_support_method" {
  description = "Specifies how you want CloudFront to serve HTTPS requests, one of 'vip' or 'sni-only'. Defaults to 'sni-only'"
  type = string
  default = "sni-only"
}

variable "web_acl_id" {
  description = "If using AWS WAF to filter CloudFront requests, the ID of the AWS WAF web ACL that is associated with the distribution"
  type = string
  default = null
}

variable "retain_on_delete" {
  description = "Boolean flag, if true the distribution will be disabled rather than deleted on removal form Terraform. Defaults to false"
  type = bool
  default = false
}

variable "wait_for_deployment" {
  description = "Boolean flag, if true Terraform will wait for deployment of the CloudFront distribution. Defaults to true"
  type = bool
  default = true
}