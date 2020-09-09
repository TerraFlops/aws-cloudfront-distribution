locals {
  # Mangle the supplied name into different cases
  name_title = join("", [ for element in split("_", lower(var.name)): title(element) ])
  name_hyphen = replace("_", "-", var.name)

  # Convert price class to camel case
  price_class = {
    price_class_all = "PriceClass_All"
    price_class_200 = "PriceClass_200"
    price_class_100 = "PriceClass_100"
  }

  # Create fully-qualified domain name
  domain_name_fqdn = "${var.domain_name}.${data.aws_route53_zone.hosted_zone.name}"

  # Create the distribution comment based on whether a description was supplied
  comment = coalesce(var.comment, var.domain_name)
}

# Retrieve the hosted zone
data "aws_route53_zone" "hosted_zone" {
  zone_id = var.hosted_zone_id
}

# Create S3 bucket for logging CloudFront traffic
resource "aws_s3_bucket" "logs" {
  count = var.log_bucket_create == true ? 1 : 0
  bucket = var.log_bucket_name
  # Enable versioning
  versioning {
    enabled = true
  }
  # Grant access to the log delivery group
  acl = "log-delivery-write"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id = "ArchiveLogs"
    enabled = true
    # After 90 days transition logs to Standard-Infrequent Access storage for cost saving
    transition {
      days = 90
      storage_class = "STANDARD_IA"
    }
    # After 180 days transition logs to Glacier storage for cost saving on long term archives
    transition {
      days = 180
      storage_class = "GLACIER"
    }
  }
}

# Create CloudFront distribution for the Manage frontend
resource "aws_cloudfront_distribution" "distribution" {
  aliases = var.aliases
  comment = local.comment

  # Add optional custom error responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code = custom_error_response.value["error_code"]
      error_caching_min_ttl = custom_error_response.value["ttl"]
      response_code = custom_error_response.value["response_code"]
      response_page_path = custom_error_response.value["path"]
    }
  }

  # Configure default cache behavior
  default_cache_behavior {
    allowed_methods = var.default_cache_behavior.allowed_methods
    cached_methods = var.default_cache_behavior.cached_methods
    compress = var.default_cache_behavior.compress
    default_ttl = var.default_cache_behavior.default_ttl
    field_level_encryption_id = var.default_cache_behavior.field_level_encryption_id

    # Configure forwarded values block
    forwarded_values {
      cookies {
        forward = var.default_cache_behavior.forwarded_values.cookies.forward
        whitelisted_names = var.default_cache_behavior.forwarded_values.cookies.whitelisted_names
      }
      headers = var.default_cache_behavior.forwarded_values.headers
      query_string = var.default_cache_behavior.forwarded_values.query_string
      query_string_cache_keys = var.default_cache_behavior.forwarded_values.query_string_cache_keys
    }

    # Add optional Lambda function associations
    dynamic "lambda_function_association" {
      for_each = [
        for behavior in var.default_cache_behavior.lambda_function_associations: behavior
        if behavior != null
      ]
      content {
        event_type = lambda_function_association.value["event_type"]
        include_body = lambda_function_association.value["include_body"]
        lambda_arn = lambda_function_association.value["lambda_arn"]
      }
    }

    max_ttl = var.default_cache_behavior.max_ttl
    min_ttl = var.default_cache_behavior.min_ttl
    smooth_streaming = var.default_cache_behavior.smooth_streaming
    target_origin_id = var.default_cache_behavior.target_origin_id
    trusted_signers = var.default_cache_behavior.trusted_signers
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
  }

  default_root_object = var.default_root_object
  enabled = var.enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  http_version = var.http_version

  # Configure log bucket block
  logging_config {
    bucket = var.log_bucket_create == true ? aws_s3_bucket.logs[0].bucket_regional_domain_name : var.log_bucket_name
    include_cookies = var.log_bucket_include_cookies
    prefix = var.log_bucket_prefix
  }

  # Define cache behavior blocks
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      allowed_methods = ordered_cache_behavior.value["allowed_methods"]
      cached_methods = ordered_cache_behavior.value["cached_methods"]
      compress = ordered_cache_behavior.value["compress"]
      default_ttl = ordered_cache_behavior.value["default_ttl"]
      field_level_encryption_id = ordered_cache_behavior.value["field_level_encryption_id"]
      forwarded_values {
        headers = ordered_cache_behavior.value["headers"]
        query_string = ordered_cache_behavior.value["query_string"]
        query_string_cache_keys = ordered_cache_behavior.value["query_string_cache_keys"]
        cookies {
          forward = ordered_cache_behavior.value["forward"]
          whitelisted_names = ordered_cache_behavior.value["whitelisted_names"]
        }
      }
      # Add optional Lambda function associations
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value["lambda_function_associations"]
        content {
          event_type = lambda_function_association.value["event_type"]
          include_body = lambda_function_association.value["include_body"]
          lambda_arn = lambda_function_association.value["lambda_arn"]
        }
      }
      max_ttl = ordered_cache_behavior.value["max_ttl"]
      min_ttl = ordered_cache_behavior.value["min_ttl"]
      path_pattern = ordered_cache_behavior.value["path_pattern"]
      smooth_streaming = ordered_cache_behavior.value["smooth_streaming"]
      target_origin_id = ordered_cache_behavior.value["target_origin_id"]
      trusted_signers = ordered_cache_behavior.value["trusted_signers"]
      viewer_protocol_policy = ordered_cache_behavior.value["viewer_protocol_policy"]
    }
  }

  # Create S3 origins
  dynamic "origin" {
    for_each = var.origins_s3
    content {
      origin_id = origin.key
      domain_name = origin.value["domain_name"]
      origin_path = origin.value["path"]
      s3_origin_config {
        origin_access_identity = origin.value["origin_access_identity"]
      }
      dynamic "custom_header" {
        for_each = lookup(origin.value, "custom_headers", [])
        content {
          name = custom_header.key
          value = custom_header.value
        }
      }
    }
  }

  # Create custom origins
  dynamic "origin" {
    for_each = var.origins_custom
    content {
      origin_id = origin.key
      domain_name = origin.value["domain_name"]
      origin_path = origin.value["path"]
      custom_origin_config {
        http_port = origin.value["http_port"]
        https_port = origin.value["https_port"]
        origin_protocol_policy = origin.value["protocol_policy"]
        origin_ssl_protocols = origin.value["ssl_protocols"]
        origin_keepalive_timeout = origin.value["keepalive_timeout"]
        origin_read_timeout = origin.value["read_timeout"]
      }
      dynamic "custom_header" {
        for_each = origin.value["custom_headers"]
        content {
          name = custom_header.key
          value = custom_header.value
        }
      }
    }
  }
  price_class = local.price_class[var.price_class]

  # Configure distribution geo-restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations = var.restriction_locations
    }
  }

  # Add any custom tags to the default name tag
  tags = merge({
    Name = "${local.name_title}Distribution"
  }, var.tags)

  # Link to the viewer certificate we created
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = var.acm_certificate_arn
    minimum_protocol_version = var.viewer_certificate_minimum_protocol_version
    ssl_support_method = var.viewer_certificate_ssl_support_method
  }

  web_acl_id = var.web_acl_id
  retain_on_delete = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
}