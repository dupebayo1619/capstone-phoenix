resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.control_plane_instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.control_plane.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-control-plane"
    Role = "control-plane"
  })

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y curl
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --disable-agent" sh -
    sleep 10
    echo "K3S_NODE_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)" > /home/ubuntu/k3s-token
    chmod 644 /home/ubuntu/k3s-token
  EOF
}

resource "aws_instance" "workers" {
  count = var.worker_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.worker.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-worker-${count.index + 1}"
    Role = "worker"
  })

  depends_on = [aws_instance.control_plane]
}
