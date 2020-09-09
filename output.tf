output "distribution_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
  description = "The domain name corresponding to the distribution. For example: d604721fxaaqy9.cloudfront.net."
}

output "distribution_id" {
  value = aws_cloudfront_distribution.cloudfront_distribution.id
  description = "The identifier for the distribution. For example: EDFDVBD632BHDS5."
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.cloudfront_distribution.arn
  description = "The ARN (Amazon Resource Name) for the distribution. For example: arn:aws:cloudfront::123456789012:distribution/EDFDVBD632BHDS5"
}
