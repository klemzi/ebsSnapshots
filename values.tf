variable "target_tags" {
  type        = map(string)
  description = "EBS volumes having the specified tags are targeted"
  default = {
    "Snapshot" = "true"
  }
}

variable "retention" {
  type        = number
  description = "number of days to retain the snapshot"
  default     = 14
}

variable "snap_rule" {
  type = object({
    interval = number       # in hours
    times    = list(string) # times to take a snapshot
  })

  default = {
    interval = 24
    times    = ["23:45"]
  }
}