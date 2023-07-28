# Standard AWS Provider Block
terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }
}

data "aws_caller_identity" "current" {}

resource "aws_route53_zone" "RT53_ZONE" {
    count = (length(var.RT53_ZONE) > 0 ? length(var.RT53_ZONE) : 0 )

    name         = var.RT53_ZONE[count.index].DOMAIN_NAME
    tags = {
        Name = "${var.RT53_ZONE[count.index].NAME}"
    }

    dynamic "vpc" {
        for_each = var.RT53_ZONE[count.index].TYPE_PRIVATE == true ? [1] : []
        content {
            vpc_region  = var.RT53_ZONE[count.index].REGION_ID
            vpc_id      = var.RT53_ZONE[count.index].VPC_ID
        }
    }
}

resource "aws_route53_record" "RT53_ZONE_RECORD" {
    count = (length(var.RT53_ZONE_RECORD) > 0 ? length(var.RT53_ZONE_RECORD) : 0 )

    zone_id = var.RT53_ZONE_RECORD[count.index].ZONE_ID
    name    = var.RT53_ZONE_RECORD[count.index].NAME
    type    = var.RT53_ZONE_RECORD[count.index].TYPE
    ttl     = var.RT53_ZONE_RECORD[count.index].TTL
    records = var.RT53_ZONE_RECORD[count.index].IPs
}

resource "aws_route53_health_check" "RT53_HC" {
    count = (length(var.RT53_HC) > 0 ? length(var.RT53_HC) : 0 )

    fqdn              = var.RT53_HC[count.index].DOMAIN
    type              = var.RT53_HC[count.index].PROTOCOL
    port              = var.RT53_HC[count.index].PORT
    resource_path     = try(var.RT53_HC[count.index].RESOURCE_PATH, "/")
    failure_threshold = try(var.RT53_HC[count.index].FAIL_THRESHOLD, "5")
    request_interval  = try(var.RT53_HC[count.index].REQ_INTERVAL, "30")

    tags = {
        Name = "${var.RT53_HC[count.index].NAME}"
    }
}

####################################################################
# resource "aws_route53_resolver_config" "RT53_RESOLV" {
#     count = (var.VPC["RESOLVER_DEFAULT_RULE"] != "" ? 1 : 0)
#     resource_id              = aws_vpc.VPC[0].id
#     autodefined_reverse_flag = var.VPC["RESOLVER_DEFAULT_RULE"]
# }
###################################################################

resource "aws_route53_resolver_endpoint" "RT53_RESOLV_EP" {
    count = (length(var.RT53_RESOLV_EP) > 0 ? length(var.RT53_RESOLV_EP) : 0 )
    name      = var.RT53_RESOLV_EP[count.index].NAME
    direction = var.RT53_RESOLV_EP[count.index].DIRECTION

    security_group_ids = var.RT53_RESOLV_EP[count.index].SG_IDs

    dynamic "ip_address" {
        for_each = var.RT53_RESOLV_EP[count.index].IPs
        content {
            subnet_id = try(ip_address.value.SN_ID, null)
            ip = try(ip_address.value.IP, null)          
        }
    }
    tags = {
        Name = "${var.RT53_RESOLV_EP[count.index].NAME}"
    }
}

resource "aws_route53_resolver_rule" "RT53_RESOLV_EP_RULE" {
    count = (length(var.RT53_RESOLV_EP_RULE) > 0 ? length(var.RT53_RESOLV_EP_RULE) : 0 )

    name        = var.RT53_RESOLV_EP_RULE[count.index].NAME
    resolver_endpoint_id = var.RT53_RESOLV_EP_RULE[count.index].EP_ID
    domain_name = var.RT53_RESOLV_EP_RULE[count.index].DOMAIN_NAME
    rule_type = var.RT53_RESOLV_EP_RULE[count.index].RULE_TYPE

    dynamic "target_ip" {
        for_each = var.RT53_RESOLV_EP_RULE[count.index].IPs
        content {
            ip = try(target_ip.value.IP, null)
            port = try(target_ip.value.PORT, 53)
        }
    }
    tags = {
        Name = "${var.RT53_RESOLV_EP_RULE[count.index].NAME}"
    }
}

resource "aws_route53_resolver_rule_association" "RT53_RESOLV_EP_RULE_ASS" {
    count = (length(var.RT53_RESOLV_EP_RULE) > 0 ? length(var.RT53_RESOLV_EP_RULE) : 0 )

    resolver_rule_id = aws_route53_resolver_rule.RT53_RESOLV_EP_RULE[count.index].id
    vpc_id           = var.RT53_RESOLV_EP_RULE[count.index].VPC_ID
}

resource "aws_lb_target_group" "LB_TG" {
    count = (length(var.LB_TG) > 0 ? length(var.LB_TG) : 0 )
    name     = var.LB_TG[count.index].NAME
    target_type = var.LB_TG[count.index].TARGET_TYPE
    port     = try(var.LB_TG[count.index].PORT, null)
    protocol = try(var.LB_TG[count.index].PROTOCOL, null)
    vpc_id   = try(var.LB_TG[count.index].VPC_ID, null)
    
    health_check {
        enabled = try(var.LB_TG[count.index].HC_ENABLE, true)
        protocol = try(var.LB_TG[count.index].HC_PROTOCOL, "HTTP")
        port = try(var.LB_TG[count.index].HC_PORT, "Traffic-port")
        path = try(var.LB_TG[count.index].HC_PATH, "/") 
        healthy_threshold = try(var.LB_TG[count.index].HC_HEALTHY_THRESHOLD, 5)
        unhealthy_threshold = try(var.LB_TG[count.index].HC_UNHEALTY_THRESHOLD, 5)
        timeout = try(var.LB_TG[count.index].HC_TIMEOUT, 5)
        interval = try(var.LB_TG[count.index].HC_INTERVAL, 30)
        matcher = try(var.LB_TG[count.index].HC_MATCHER, 200)
    }

    tags = {
        Name = "${var.LB_TG[count.index].NAME}"
    }
}

resource "aws_lb_target_group_attachment" "LB_TG_ATT" {
    count = (length(var.LB_TG_ATT) > 0 ? length(var.LB_TG_ATT) : 0 )
    target_group_arn = var.LB_TG_ATT[count.index].TG_ID
    target_id        = var.LB_TG_ATT[count.index].TARGET_ID
    port             = var.LB_TG_ATT[count.index].PORT
}

resource "aws_lb" "LB" {
    count = (length(var.LB) > 0 ? length(var.LB) : 0 )
    
    name               = var.LB[count.index].NAME
    load_balancer_type = var.LB[count.index].TYPE
    internal           = var.LB[count.index].INTERNAL
    subnets            = var.LB[count.index].SNs
    enable_deletion_protection = try(var.LB[count.index].DELETE_PROTECTION, true)
    security_groups    = try(var.LB[count.index].SGs, null)

    tags = {
        Name = "${var.LB[count.index].NAME}"
    }

    dynamic "subnet_mapping" {
        for_each = var.LB[count.index].SNs_MAP != null ? var.LB[count.index].SNs_MAP : []
        content {
            subnet_id     = try(subnet_mapping.value.SN_ID, null)
            allocation_id = try(subnet_mapping.value.EIP_ID, null)    
        }
    }

}

resource "aws_lb_listener" "LB_LS" {
    count = (length(var.LB_LS) > 0 ? length(var.LB_LS) : 0)

    load_balancer_arn = aws_lb.LB[count.index].arn
    port = var.LB_LS[count.index].PORT

    dynamic "default_action" {
        for_each = length(var.LB_LS) > 0 ? var.LB_LS[count.index].DEFAULT_ACTION : []
        content {
            type             = try(default_action.value.TYPE, "forward")
            target_group_arn = try(default_action.value.TG_ID, aws_lb_target_group.LB_TG[count.index].arn)
        }
    }

    tags = {
        Name = "${var.LB_LS[count.index].NAME}"
    }
}


# resource "aws_lb_listener_rule" "LB_LS_RULE" {
#     count = (length(var.LB_LS) > 0 ? length(var.LB_LS) : 0)

#     listener_arn = aws_lb_listener.LB_LS[count.index].arn
#     priority     = var.LB_LS[count.index].PRIOIRTY

#     dynamic "action" {
#         for_each = var.LB_LS[count.index].ACTION != null ? var.LB_LS[count.index].ACTION : []
#         content {
#             type             = try(action.value.TYPE, null)
#             target_group_arn = try(action.value.TG_ID, null)
        
#             # authenticate_cognito {
#             #     user_pool_arn       = aws_cognito_user_pool.pool.arn
#             #     user_pool_client_id = aws_cognito_user_pool_client.client.id
#             #     user_pool_domain    = aws_cognito_user_pool_domain.domain.domain
#             # }

#             # authenticate_oidc {
#             #     authorization_endpoint = "https://example.com/authorization_endpoint"
#             #     client_id              = "client_id"
#             #     client_secret          = "client_secret"
#             #     issuer                 = "https://example.com"
#             #     token_endpoint         = "https://example.com/token_endpoint"
#             #     user_info_endpoint     = "https://example.com/user_info_endpoint"
#             # }        
#         }

#     }

#     dynamic "condition" {
#         for_each = var.LB_LS[count.index].CONDITION != null ? var.LB_LS[count.index].CONDITION : []
#         content {

#             path_pattern {
#                 values = try(condition.value.PATH_PATTERN_VALUE, null)
#             }    
#             host_header {
#                 values = try(condition.value.HOST_HEADER_VALUE, null)
#             }
#             http_header {
#                 http_header_name = try(condition.value.HTTP_HEADER_NAME, null)
#                 values           = try(condition.value.HTTP_HEADER_VALUE, null)
#             }
#             query_string {
#                 key   = try(condition.value.QUERY_STRING_KEY, null)
#                 value = try(condition.value.QUERY_STRING_VALUE, null)
#             }
#         }
#     }

#     dynamic "forward" {
#         for_each = var.LB_LS[count.index].FORWARD != null ? var.LB_LS[count.index].FORWARD : []        
#         content {
#             target_group {
#                 arn    = try(forward.value.TG_ID, null)
#                 weight = try(forward.value.TG_WEIGHT, null)
#             }

#             stickiness {
#                 enabled  = try(forward.value.STICK_ENABLE, null)
#                 duration = try(forward.value.STICK_DURATION, null)
#             }
#         }
#     }
# }

resource "aws_globalaccelerator_accelerator" "GAC" {
    count = (length(var.GAC) > 0 ? length(var.GAC) : 0)

    name            = var.GAC[count.index].NAME
    ip_address_type = try(var.GAC[count.index].IP_TYPE, "IPV4") # "IPv4", "DUAL_STACK"
    ip_addresses    = try(var.GAC[count.index].IP, null) # Optional
    enabled         = true

    tags = {
        Name = "${var.GAC[count.index].NAME}"
    }

    # attributes {
    #     flow_logs_enabled   = true
    #     flow_logs_s3_bucket = "example-bucket"
    #     flow_logs_s3_prefix = "flow-logs/"
    # }
}

resource "aws_globalaccelerator_listener" "GAC_LS" {
    count = (length(var.GAC) > 0 ? length(var.GAC) : 0)

    accelerator_arn = aws_globalaccelerator_accelerator.GAC[count.index].id
    client_affinity = try(var.GAC[count.index].LS_AFFINITY, "SOURCE_IP") # "NONE", "SOURCE_IP"
    protocol        = try(var.GAC[count.index].LS_PROTOCOL, "TCP") # "TCP", "UDP"

    dynamic port_range {
        for_each = var.GAC[count.index].LS_PORT_RANGE
        content {
            from_port = try(port_range.value.FROM, 80)
            to_port   = try(port_range.value.TO, 80)
        }
    }
}

resource "aws_globalaccelerator_endpoint_group" "GAC_EP_GROUP" {
    count = (length(var.GAC_EP) > 0 ? length(var.GAC_EP) : 0)
    
    listener_arn = var.GAC_EP[count.index].LS_ID
    health_check_protocol = try(var.GAC_EP[count.index].HC_PROTOCOL, "HTTP")
    health_check_port = try(var.GAC_EP[count.index].HC_PORT, 80)
    health_check_path = try(var.GAC_EP[count.index].HC_PATH, "/index.html")
    health_check_interval_seconds = try(var.GAC_EP[count.index].HC_INTERVAL, 30)
    threshold_count = try(var.GAC_EP[count.index].HC_THRESOLD_COUNT, 3)
    traffic_dial_percentage = try(var.GAC_EP[count.index].HC_DIST_VALUE, 100)

    dynamic endpoint_configuration {
        for_each = var.GAC_EP[count.index].CONFIGURATION
        content {
            client_ip_preservation_enabled = try(endpoint_configuration.value.IP_PRESERVATION, false)
            endpoint_id = try(endpoint_configuration.value.ID, null)
            weight      = try(endpoint_configuration.value.WEIGHT, 100)
        }
    }
}