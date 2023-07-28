output "RT53_ZONE_ID" {
    value = try(aws_route53_zone.RT53_ZONE[*].zone_id, null)
}

output "RT53_ZONE_NS" {
    value = try(aws_route53_zone.RT53_ZONE[*].name_servers, null)
}

output "RT53_RESOLVE_EP_ID" {
    value = try(aws_route53_resolver_endpoint.RT53_RESOLV_EP[*].id, null)
}

output "RT53_DOMAIN" {
    value = try(aws_route53_record.RT53_ZONE_RECORD[*].fqdn, null)
}

output "LB_ID"{
    value = try(aws_lb.LB[*].id, null)
}

output "LB_TG_ID"{
    value = try(aws_lb_target_group.LB_TG[*].arn, null)
}

output "GAC_LS_ID" {
    value = try(aws_globalaccelerator_listener.GAC_LS[*].id, null)
}

