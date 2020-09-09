# EC2 Bastion Terraform Module

This Terraform Module handles the creation of Cloudfront Distribution, Cloudfront Log bucket, and if required origin-access-identity's for S3 Origins.

## Usage
```hcl-terraform
module "guild_cloudfront_distribution" {
  source = "git@github.com:eonx-com/eonx-ops-terraform-modules.git?ref=cloudfront_distribution_1.0"

  # Base settings for cloudfront dist
  domain_name = local.domain_name
  enabled = false
  default_root_object = "index.html"
  price_class = "PriceClass_All"
  cloudfront_geo_restriction_type = "none"
  description = "Guild CloudFront"

  # Logging
  log_bucket_identifier = "guild"
  logs_prefix = "guild"

  # Custom Aliases
  # Removed alias until we are ready to migrate
  aliases = [
    "guild.test.ewallet.com.au"
  ]
  
  # Custom Error Responses
  custom_error_responses = {
    403 = {
      error_caching_min_ttl = 0,
      response_code = 200
      response_page_path = "/index.html"
    }
    404 = {
      error_caching_min_ttl = 0,
      response_code = 200
      response_page_path = "/index.html"
    }
  }

  # Custom Origins
  domain_origins = {
    APIELBOrigin = {
      domain_name = "rewardste-elasticl-109i4ri873f5y-1843496252.ap-southeast-2.elb.amazonaws.com"
      origin_keepalive_timeout = 5
      origin_read_timeout = 30
      custom_headers = {
        "X-EonX-Secure" = "TRUE"

      }
    }
  }

  # S3 Origins
  s3_origins = {
    S3StorageBucketOrigin = {
      domain_name = "guild.${local.domain_name}.s3.us-east-1.amazonaws.com"
      custom_headers = {
        "X-EonX-Secure" = "TRUE"
      }
    }
  }

  # ACM Certificates
  acm_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:413021117787:certificate/f5ef0391-d9a2-4fb3-82d5-27d83f65605b"
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method = "sni-only"
  }

  # Default Cache Behaviors
  default_cache_behavior = {
    allowed_methods = "get_head_options"
    cached_methods = "get_head",
    target_origin_id = "S3StorageBucketOrigin"
    forwarded_value_query_string = false
    forwarded_value_cookies = "none"
    forwarded_value_headers = false
    viewer_protocol_policy = "redirect-to-https"
    default_ttl = 600
    max_ttl = 800
  }

  # Ordered Cache Behaviors
  cache_behaviors = [
    {
      path_pattern = "/index.html"
      allowed_methods = "get_head_options"
      cached_methods = "get_head"
      target_origin_id = "S3StorageBucketOrigin"
      viewer_protocol_policy = "redirect-to-https"
      forwarded_value_cookies = "none"
    },
    {
      path_pattern = "/login"
      allowed_methods = "get_head_options"
      cached_methods = "get_head"
      target_origin_id = "APIELBOrigin"
      viewer_protocol_policy = "redirect-to-https"
      forwarded_value_headers = "*"
    }
  ]
}
```

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| s3_origins | Map of S3 origins | object(bucket_name, custom_headers) | {} | no |
| domain_origins | Map of Domain Name origins | object(domain_name, custom_headers) | {} | no |
| iam_certificate | Map of IAM Certificate | object(ssl_support_method, minimum_protocol_version, iam_certificate_id) | null | no |
| acm_certificate | Map of ACM Certificate | object(ssl_support_method, minimum_protocol_version, acm_certificate_id) | null | no |
| default_cache_behavior | The default cache behavior for this distribution (maximum one). | object(path_pattern, allowed_methods, cached_methods, target_origin_id) |  | yes |
| cache_behaviors | An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. | object(allowed_methods, cached_methods, target_origin_id, viewer_protocol_policy, forwarded_value_query_string) |  | yes |
| custom_error_responses | Custom Error Response map | object(error_caching_min_ttl, response_code, response_page_path) |  | yes |
| domain_name | The domain name for the project | string |  | yes |
| log_bucket_identifier | Identifier used in the log bucket name | string |  | yes |
| enabled | Flag to enable/disable the distribution | bool | true  | no |
| is_ipv6_enabled | Flag to enable/disable IPv6 support | bool | false  | no |
| description | Description of the CloudFront distribution | string |   | yes |
| price_class | CloudFront price class | string | PriceClass_All  | no |
| http_version | HTTP version for distribution. | string | http2  | no |
| aliases | Optional set of CNAME aliases to assign to the distribution | set(string) | []  | no |
| ssl_support_method | Distribution SSL support level | string | TLSv1.2_2018  | no |
| minimum_protocol_version | Minimum protocol version. | string | sni-only  | no |
| default_root_object | Default root object for the distribution | string |   | yes |
| allowed_methods | Allowed HTTP methods CloudFront processes and forwards. Allowed values are get_head, get_head_options, or all | string | all  | no |
| cached_methods | CloudFront caches the response to requests using the specified HTTP methods. Allowed values, get_head or get_head_options. | string | get_head | no |
| logs_include_cookies | Specifies whether you want CloudFront to include cookies in access logs. | bool | false | no |
| logs_prefix | String that you want CloudFront to prefix to the access log filenames for this distribution, for example, myprefix/| string |  | yes |
| cloudfront_geo_restriction_type | The restriction configuration for this distribution (maximum one) | string | none | no |
