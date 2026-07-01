resource "aws_security_group" "control_plane" {
  name        = "${var.environment}-cp-sg"
  description = "Security group for k3s control plane"
  vpc_id      = data.aws_vpc.default.id
  
  tags = merge(var.tags, {
    Name = "${var.environment}-cp-sg"
  })
}

resource "aws_security_group" "worker" {
  name        = "${var.environment}-worker-sg"
  description = "Security group for k3s workers"
  vpc_id      = data.aws_vpc.default.id
  
  tags = merge(var.tags, {
    Name = "${var.environment}-worker-sg"
  })
}

# Control Plane Ingress Rules
resource "aws_security_group_rule" "cp_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_cidrs
  security_group_id = aws_security_group.control_plane.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "cp_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
  description       = "HTTP access"
}

resource "aws_security_group_rule" "cp_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
  description       = "HTTPS access"
}

resource "aws_security_group_rule" "cp_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
}

# Worker Ingress Rules
resource "aws_security_group_rule" "worker_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_cidrs
  security_group_id = aws_security_group.worker.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
}

# Node-to-Node Communication (Internal only)
resource "aws_security_group_rule" "worker_to_cp" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.control_plane.id
  description              = "Worker to control plane"
}

resource "aws_security_group_rule" "cp_to_worker" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.worker.id
  description              = "Control plane to worker"
}
