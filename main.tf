locals {
  allowed_methods = {
    "get_head" = [
      "GET",
      "HEAD"
    ]
    "get_head_options" = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
    "all" = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ],
  }

  cached_methods = {
    "get_head" = [
      "GET",
      "HEAD"
    ]
    "get_head_options" = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
  }
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled = var.enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  comment = var.description
  default_root_object = var.default_root_object
  price_class = var.price_class
  http_version = var.http_version
  aliases = length(var.aliases) > 0 ? var.aliases : null
  web_acl_id = var.web_acl_id

  viewer_certificate {
    cloudfront_default_certificate = var.cloudfront_default_certificate
    ssl_support_method = var.cloudfront_default_certificate == true ? null : var.acm_certificate["ssl_support_method"]
    minimum_protocol_version = var.cloudfront_default_certificate == true ? null : var.acm_certificate["minimum_protocol_version"]
    acm_certificate_arn = var.cloudfront_default_certificate == true ? null : var.acm_certificate["acm_certificate_arn"]
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code = custom_error_response.key
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      response_code = lookup(custom_error_response.value, "response_code", null)
      response_page_path = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  # S3 Origins
  dynamic "origin" {
    for_each = var.s3_origins
    iterator = s3_origin

    content {
      origin_path = lookup(s3_origin.value, "origin_path", null)
      domain_name = s3_origin.value["domain_name"]
      origin_id = s3_origin.key

      dynamic "s3_origin_config" {
        for_each = lookup(s3_origin.value, "origin_access_identity", null) == null ? {} : {
          origin_access_identity = s3_origin.value["origin_access_identity"]
        }
        content {
          origin_access_identity = lookup(s3_origin.value, "origin_access_identity", null)
        }
      }
      dynamic "custom_header" {
        for_each = s3_origin.value["custom_headers"]

        content {
          name = custom_header.key
          value = custom_header.value
        }
      }
    }
  }

  # Domain Name Origins
  dynamic "origin" {
    for_each = var.domain_origins
    iterator = domain_origin

    content {
      origin_path = lookup(domain_origin.value, "origin_path", null)
      domain_name = domain_origin.value["domain_name"]
      origin_id = domain_origin.key

      dynamic "custom_header" {
        for_each = domain_origin.value["custom_headers"]

        content {
          name = custom_header.key
          value = custom_header.value
        }
      }

      custom_origin_config {
        http_port = domain_origin.value["http_port"]
        https_port = domain_origin.value["https_port"]
        origin_keepalive_timeout = domain_origin.value["origin_keepalive_timeout"]
        origin_read_timeout = domain_origin.value["origin_read_timeout"]
        origin_protocol_policy = domain_origin.value["origin_protocol_policy"]
        origin_ssl_protocols = [
          domain_origin.value["origin_ssl_protocols"]]
      }
    }
  }

  logging_config {
    bucket = var.logs_bucket_name
    include_cookies = var.logs_include_cookies
    prefix = var.logs_prefix
  }

  default_cache_behavior {
    allowed_methods = local.allowed_methods[var.default_cache_behavior["allowed_methods"]]
    cached_methods = local.cached_methods[var.default_cache_behavior["cached_methods"]]
    target_origin_id = var.default_cache_behavior["target_origin_id"]

    forwarded_values {
      query_string = var.default_cache_behavior["forwarded_value_query_string"]
      headers = var.default_cache_behavior["forwarded_value_headers"] == "none" ? [] : [var.default_cache_behavior["forwarded_value_headers"]]

      cookies {
        forward = var.default_cache_behavior["forwarded_value_cookies"]
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.default_cache_behavior["lambda_function"]
      iterator = lambda_function
      content {
        event_type = lambda_function.key
        lambda_arn = lambda_function.value["lambda_arn"]
        include_body = lambda_function.value["include_body"]
      }
    }

    min_ttl = lookup(var.default_cache_behavior, "min_ttl", null)
    default_ttl = lookup(var.default_cache_behavior, "default_ttl", null)
    max_ttl = lookup(var.default_cache_behavior, "max_ttl", null)
    compress = var.default_cache_behavior["compress"]
    viewer_protocol_policy = var.default_cache_behavior["viewer_protocol_policy"]
  }

  # Dynamic Ordered Cache Behaviors.
  dynamic "ordered_cache_behavior" {
    for_each = var.cache_behaviors
    iterator = behavior
    content {
      path_pattern = behavior.value["path_pattern"]
      allowed_methods = local.allowed_methods[behavior.value["allowed_methods"]]
      cached_methods = local.allowed_methods[behavior.value["cached_methods"]]
      target_origin_id = behavior.value["target_origin_id"]

      dynamic "lambda_function_association" {
        for_each = behavior.value["lambda_function"]
        iterator = lambda_function
        content {
          event_type = lambda_function.key
          lambda_arn = lambda_function.value["lambda_arn"]
          include_body = lambda_function.value["include_body"]
        }
      }

      forwarded_values {
        query_string = behavior.value["forwarded_value_query_string"]
        headers = behavior.value["forwarded_value_headers"] == "none" ? [] : [behavior.value["forwarded_value_headers"]]

        cookies {
          forward = behavior.value["forwarded_value_cookies"]
        }
      }

      min_ttl = lookup(behavior.value, "min_ttl", null)
      default_ttl = lookup(behavior.value, "default_ttl", null)
      max_ttl = lookup(behavior.value, "max_ttl", null)
      compress = behavior.value["compress"]
      smooth_streaming = behavior.value["smooth_streaming"]
      viewer_protocol_policy = behavior.value["viewer_protocol_policy"]
    }
  }

  # Unless specified will default to "none"
  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
    }
  }

  tags = var.tags
}
