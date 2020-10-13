# Terraflops Terraform Module
 
### AWS CloudFront Distribution

Creates an Amazon CloudFront web distribution.

#### Example usage
```hcl-terraform
module "example" {
  source = "git::https://github.com/TerraFlops/aws-cloudfront-distribution?ref=v2.1"

  enabled = var.enabled
  default_root_object = ""
  price_class = "PriceClass_All"
  cloudfront_geo_restriction_type = "none"
  description = "Example CloudFront"
  web_acl_id = var.web_acl_id

  # Logging
  logs_bucket_name = "logs-bucket.s3.amazonaws.com"
  logs_prefix = "example"

  # Custom Aliases
  aliases = var.disable_aliases == true ? [] : local.aliases

  custom_error_responses = {
    404 = {
      error_caching_min_ttl = 0
      response_code = 200
      response_page_path = "/index.html"
    }
  }

  # Custom Origins
  domain_origins = {
    api = {
      domain_name = "api.example.com.au"
      origin_keepalive_timeout = 5
      origin_read_timeout = 30
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = "TLSv1.2"
      custom_headers = {
        "X-EonX-Secure" = "TRUE"
      }
    }
    frontend = {
      domain_name = "example.frontend.s3-website-ap-southeast-2.amazonaws.com"
      origin_keepalive_timeout = 5
      origin_read_timeout = 30
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = "TLSv1.2"
      custom_headers = {
        "X-EonX-Secure" = "TRUE"
      }
    }
  }

  s3_origins = {
    ssl_verification = {
      domain_name = "ssl-verification.s3.amazonaws.com"
      custom_headers = {}
      origin_access_identity = ""
    }
  }

  # Certificates
  acm_certificate = var.certificate_type == "ACM" ? local.acm_certificates : null
  iam_certificate = var.certificate_type == "IAM" ? local.iam_certificates : null

  # Default Cache Behaviors
  default_cache_behavior = {
    allowed_methods = "get_head"
    cached_methods = "get_head"
    target_origin_id = "frontend"
    forwarded_value_query_string = false
    forwarded_value_cookies = "none"
    forwarded_value_headers = "none"
    viewer_protocol_policy = "redirect-to-https"
    max_ttl = 900
    min_ttl = 900
    default_ttl = 900
    compress = false
    lambda_function = var.enable_lambdas == true ? local.lambda_functions : {}
  }

  # Ordered Cache Behaviors
  cache_behaviors = [
    {
      path_pattern = "/index.html"
      allowed_methods = "get_head"
      cached_methods = "get_head"
      target_origin_id = "frontend"
      viewer_protocol_policy = "redirect-to-https"
      forwarded_value_headers = "none"
      forwarded_value_cookies = "none"
      forwarded_value_query_string = false
      min_ttl = 0
      max_ttl = 0
      default_ttl = 0
      compress = true
      smooth_streaming = false
      lambda_function = {}
    },
    {
      path_pattern = "/1.0/provider*"
      allowed_methods = "get_head"
      cached_methods = "get_head"
      target_origin_id = "api"
      viewer_protocol_policy = "redirect-to-https"
      forwarded_value_cookies = "none"
      forwarded_value_headers = "Host"
      forwarded_value_query_string = true
      min_ttl = 300
      max_ttl = 300
      default_ttl = 300
      compress = true
      smooth_streaming = false
      lambda_function = {}
    }
  ]

  tags = {
    Version = "Example"
    Client = var.client_name
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm\_certificate | Object of ACM Certificate configuration | <pre>object({<br>    ssl_support_method = string<br>    minimum_protocol_version = string<br>    acm_certificate_arn = string<br>  })</pre> | `null` | no |
| aliases | Optional set of CNAME aliases to assign to the distribution | `set(string)` | `[]` | no |
| allowed\_methods | Allowed HTTP methods CloudFront processes and forwards. Allowed values are get\_head, get\_head\_options, or all. Defaults to all | `string` | `"all"` | no |
| cache\_behaviors | An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0. | <pre>list(object({<br>    path_pattern = string<br>    allowed_methods = string<br>    cached_methods = string<br>    target_origin_id = string<br>    min_ttl = number<br>    max_ttl = number<br>    default_ttl = number<br>    compress = bool<br>    smooth_streaming = bool<br>    viewer_protocol_policy = string<br>    forwarded_value_query_string = string<br>    forwarded_value_headers = string<br>    forwarded_value_cookies = string<br>    lambda_function = map(map(string))<br>  }))</pre> | n/a | yes |
| cached\_methods | CloudFront caches the response to requests using the specified HTTP methods. Allowed values, get\_head or get\_head\_options. Defaults to get\_head | `string` | `"get_head"` | no |
| cloudfront\_geo\_restriction\_type | The restriction configuration for this distribution (maximum one). Defaults to none | `string` | `"none"` | no |
| custom\_error\_responses | Map of custom error response objects, with the key as the response code | <pre>map(object({<br>    error_caching_min_ttl = number<br>    response_code = number<br>    response_page_path = string<br>  }))</pre> | n/a | yes |
| default\_cache\_behavior | The default cache behavior for this distribution (maximum one). | <pre>object({<br>    allowed_methods = string<br>    cached_methods = string<br>    target_origin_id = string<br>    min_ttl = number<br>    max_ttl = number<br>    default_ttl = number<br>    compress = bool<br>    viewer_protocol_policy = string<br>    forwarded_value_query_string = string<br>    forwarded_value_cookies = string<br>    forwarded_value_headers = string<br>    lambda_function = map(map(string))<br>  })</pre> | n/a | yes |
| default\_root\_object | Default root object for the distribution | `string` | n/a | yes |
| description | Description of the CloudFront distribution | `string` | n/a | yes |
| domain\_origins | Map of Domain Name origins objects | <pre>map(object({<br>    domain_name = string<br>    custom_headers = map(string)<br>    http_port = number<br>    https_port = number<br>    origin_keepalive_timeout = number<br>    origin_read_timeout = number<br>    origin_protocol_policy = string<br>    origin_ssl_protocols = string<br>  }))</pre> | `{}` | no |
| enabled | Flag to enable/disable the distribution. Defaults to true | `bool` | `true` | no |
| http\_version | HTTP version for distribution. Defaults to http2 | `string` | `"http2"` | no |
| iam\_certificate | Object of IAM Certificate configuration | <pre>object({<br>    ssl_support_method = string<br>    minimum_protocol_version = string<br>    iam_certificate_id = string<br>  })</pre> | `null` | no |
| is\_ipv6\_enabled | Flag to enable/disable IPv6 support. Defaults to false | `bool` | `false` | no |
| logs\_bucket\_name | Name of the cloudfront bucket to place logs in | `string` | n/a | yes |
| logs\_include\_cookies | Specifies whether you want CloudFront to include cookies in access logs. Defaults to false | `bool` | `false` | no |
| logs\_prefix | String that you want CloudFront to prefix to the access log filenames for this distribution, for example, myprefix/. Defaults to empty | `string` | `""` | no |
| minimum\_protocol\_version | Minimum protocol version. Defaults to sni-only | `string` | `"sni-only"` | no |
| price\_class | CloudFront price class. Defaults to PriceClass\_All | `string` | `"PriceClass_All"` | no |
| s3\_origins | Map of S3 origin objects | <pre>map(object({<br>    domain_name = string<br>    custom_headers = map(string)<br>    origin_access_identity = string<br>  }))</pre> | `{}` | no |
| ssl\_support\_method | Distribution SSL support level. Defaults to TLSv1.2\_2018 | `string` | `"TLSv1.2_2018"` | no |
| tags | Map of key value pairs to add to the distribution as tags. Defaults to none | `map(string)` | `{}` | no |
| web\_acl\_id | If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN (Amazon Resource Name) for the distribution. For example: arn:aws:cloudfront::123456789012:distribution/EDFDVBD632BHDS5 |
| domain\_name | The domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net. |
| id | The identifier for the distribution. For example: EDFDVBD632BHDS5. |

