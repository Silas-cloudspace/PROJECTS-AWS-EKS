# Create EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_app_subnet_az1.id,
      aws_subnet.private_app_subnet_az2.id
    ]

    # Cluster endpoint access configuration
    endpoint_private_access = true
    endpoint_public_access  = true
  }

    enabled_cluster_log_types = [
      "api",
      "audit",
      "authenticator",
      "controllerManager",
      "scheduler"
   ]

  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id
  ]

  # Add instance type configuration
  instance_types = ["t3.medium"]

  # Add capacity type (ON_DEMAND or SPOT)
  capacity_type = "ON_DEMAND"

  # Add disk configuration
  disk_size = 20

  # AMI type (AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, etc.)
  ami_type = "AL2_x86_64"

  # Node tags - enable SSM access by adding the AmazonSSMManagedInstanceCore tag
  tags = {
    "Name" = "${var.project_name}-${var.environment}-eks-node"
    # This tag allows SSM to recognize the instances
    "aws:eks:cluster-name" = aws_eks_cluster.cluster.name
  }

  scaling_config {
    desired_size = 2
    max_size     = 6
    min_size     = 2
  }

  depends_on = [
    aws_iam_role.eks_node_role
  ]
}