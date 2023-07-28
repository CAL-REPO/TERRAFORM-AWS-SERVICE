variable "PROFILE" {
    type = string
    default = null
}

variable "RT53_ZONE" {
    type = list(object({
        NAME = string
        DOMAIN_NAME = string
        TYPE_PRIVATE = bool
        REGION_ID = optional(string)
        VPC_ID = optional(string)
    }))
    default = []
}

variable "RT53_ZONE_RECORD" {
    type = list(object({
        ZONE_ID = string
        NAME = string               
        TYPE = string
        TTL = string
        IPs = list(string)
    }))
    default = []
}

variable "RT53_HC" {
    type = list(object({
        NAME                = string
        DOMAIN              = string
        PROTOCOL            = string
        PORT                = number
        RESOURCE_PATH       = optional(string)
        FAIL_THRESHOLD      = optional(string)
        REQ_INTERVAL        = optional(string)
    }))
    default = []
}

variable "RT53_RESOLV_EP" {
    type = list(object({
        NAME = string
        DIRECTION = string
        SG_IDs = list(string)
        IPs = list(object({
            SN_ID  = string
            IP      = optional(string)
        }))
    }))
    default = []
}

variable "RT53_RESOLV_EP_RULE" {
    type = list(object({
        NAME = string
        EP_ID = string
        DOMAIN_NAME = string
        RULE_TYPE = string
        VPC_ID = string
        IPs = list(object({
            IP    = string
            PORT  = optional(string)
        }))
    }))
    default = []
}

variable "LB_TG" {
    type = list(object({
        NAME = string
        TARGET_TYPE = string # "instance", "ip", "lambda", "alb" 
        PORT = optional(number)
        PROTOCOL = optional(string)
        VPC_ID = optional(string)
        HC_ENABLE = optional(bool)
        HC_PROTOCOL = optional(string)
        HC_PORT = optional(string)
        HC_PATH = optional(string)
        HC_HEALTHY_THRESHOLD = optional(number)
        HC_UNHEALTY_THRESHOLD = optional(number)
        HC_TIMEOUT = optional(number)
        HC_INTERVAL = optional(number)
        HC_MATCHER = optional(number)
    }))
    default = []
}

variable "LB_TG_ATT" {
    type = list(object({
        TG_ID = string
        TARGET_ID = string
        PORT = number
    }))
    default = []
}

variable "LB" {
    type = list(object({
            NAME = string
            TYPE = string # "application", "network"
            INTERNAL = bool
            SNs = list(string)
            DELETE_PROTECTION = optional(bool)
            SGs = optional(list(string)) # "application"
            SNs_MAP = optional(list(object({
                SN_ID     = optional(string)
                EIP_ID    = optional(string)
            })))
    }))
    default = []
}

variable "LB_LS" {  
    type = list(object({
        NAME = string
        PRIORITY = number
        PORT    = number
        DEFAULT_ACTION = list(object({
            TYPE    = string
            TG_ID   = string
            
        }))            
        ACTION = optional(list(object({
            TYPE     = optional(string)
            TG_ID    = optional(string)
        })))
        CONDITION = optional(list(object({
            PATH_PATTERN_VALUE = optional(list(string))
            HOST_HEADER_VALUE = optional(list(string))
            HTTP_HEADER_NAME = optional(string)
            HTTP_HEADER_VALUE = optional(list(string))
            QUERY_STRING_KEY = optional(string)
            QUERY_STRING_VALUE = optional(string)
        })))
        FORWARD = optional(list(object({
            TG_ID = optional(string)
            TG_WEIGHT = optional(number)
            STICK_ENABLE = optional(bool)
            STICK_DURATION = optional(number)
        })))       
    }))
    default = []     
}

variable "GAC" {
    type = list(object({
        NAME = string
        IP_TYPE = optional(string)
        IPS    = optional(list(string))
        ENABLED = optional(bool)
        LS_AFFINITY = optional(string)
        LS_PROTOCOL = optional(string)
        LS_PORT_RANGE = optional(list(object({
            FROM     = optional(number)
            TO    = optional(number)
        })))

    }))
    default = []
}


variable "GAC_EP" {
    type = list(object({
        LS_ID = string
        HC_PROTOCOL = optional(string)
        HC_PORT = optional(number)
        HC_PATH = optional(string)
        HC_INTERVAL = optional(number)
        HC_THRESOLD_COUNT = optional(number)
        HC_DIST_VALUE = optional(number)
        CONFIGURATION = list(object({
            IP_PRESERVATION = bool
            ID = string
            WEIGHT = optional(number)
        }))

    }))
    default = []
}