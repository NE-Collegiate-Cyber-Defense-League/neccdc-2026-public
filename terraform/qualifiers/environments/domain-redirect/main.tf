resource "aws_acm_certificate" "domain_redirect" {
  lifecycle {
    create_before_destroy = true
  }

  domain_name = "chefops.tech"
  subject_alternative_names = [
    "chefops.tech"
  ]
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "machinemetrics_validation" {
  certificate_arn = aws_acm_certificate.domain_redirect.arn
  validation_record_fqdns = [
    for record in aws_acm_certificate.domain_redirect.domain_validation_options : record.resource_record_name
  ]
}

resource "aws_cloudfront_distribution" "domain_redirect" {
  aliases = ["chefops.tech"]
  origin {
    domain_name = "neccdl.org"
    origin_id   = "chefops.tech"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }
  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "GET"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    target_origin_id       = "chefops.tech"
    viewer_protocol_policy = "allow-all"
  }
  comment     = "neccdl domain redirect"
  price_class = "PriceClass_100"
  enabled     = true
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.domain_redirect.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.3_2025"
    ssl_support_method             = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  http_version    = "http2"
  is_ipv6_enabled = true
}


resource "aws_route53_record" "domain_validation" {
  for_each = {
    for idx, record in aws_acm_certificate.domain_redirect.domain_validation_options :
    record.domain_name => record if record.domain_name == "chefops.tech"
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "chefops.tech"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.domain_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.domain_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
