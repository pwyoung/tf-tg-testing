# NOTES

Normally, the subdirs of this would contain the AWS Region names,
e.g. "us-east-1".

Even if we were to follow the TG/TF convention and do that, we might
also have a separate 'multi-region' directory that manages resources
that span regions (e.g. for VPC Peering), or live outside regions
(e.g. S3 buckets).
