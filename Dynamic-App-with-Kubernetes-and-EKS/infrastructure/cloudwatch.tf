# Create Cloudwatch log group for EKS cluster
resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "${var.project_name}-${var.environment}-cloudwatch-logs"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudwatch-logs"
    Environment = var.environment
  }
}

# 2. EKS Control Plane Metrics Alarms
resource "aws_cloudwatch_metric_alarm" "eks_cluster_failed_node_count" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-failed-nodes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "cluster_failed_node_count"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This metric monitors EKS failed nodes"

  dimensions = {
    ClusterName = aws_eks_cluster.cluster.name
  }

  # Add SNS topic ARN to receive notifications
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_cpu_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "pod_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EKS pod CPU utilization"

  dimensions = {
    ClusterName = aws_eks_cluster.cluster.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "eks_cluster_memory_utilization" {
  alarm_name          = "${var.project_name}-${var.environment}-eks-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "pod_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EKS pod memory utilization"

  dimensions = {
    ClusterName = aws_eks_cluster.cluster.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# 3. CloudWatch Dashboard for EKS
resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-eks-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", aws_eks_cluster.cluster.name, "Namespace", "All"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Pod CPU Utilization"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "pod_memory_utilization", "ClusterName", aws_eks_cluster.cluster.name, "Namespace", "All"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Pod Memory Utilization"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", aws_eks_cluster.cluster.name]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Node CPU Utilization"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", aws_eks_cluster.cluster.name]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Node Memory Utilization"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 12,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "pod_number", "ClusterName", aws_eks_cluster.cluster.name, "Namespace", "All"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Number of Pods"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 12,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["ContainerInsights", "node_number", "ClusterName", aws_eks_cluster.cluster.name]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Number of Nodes"
        }
      }
    ]
  })
}

# CloudWatch alarm for RDS high CPU utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors RDS database CPU utilization"

  dimensions = {
    DBInstanceIdentifier = "${var.project_name}-${var.environment}-surveys-db"
  }


  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-high-cpu"
  }
}

# CloudWatch alarm for RDS low free storage space
resource "aws_cloudwatch_metric_alarm" "rds_storage_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000 # 5GB in bytes
  alarm_description   = "This alarm monitors RDS database free storage space"

  dimensions = {
    DBInstanceIdentifier = "${var.project_name}-${var.environment}-surveys-db"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-low-storage"
  }
}

# Add a dashboard for RDS metrics visualization
resource "aws_cloudwatch_dashboard" "rds_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-rds-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${var.project_name}-${var.environment}-surveys-db"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "CPU Utilization"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "${var.project_name}-${var.environment}-surveys-db"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Free Storage Space"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "${var.project_name}-${var.environment}-surveys-db"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Database Connections"
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${var.project_name}-${var.environment}-surveys-db"],
            ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", "${var.project_name}-${var.environment}-surveys-db"]
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "Read/Write IOPS"
        }
      }
    ]
  })
}