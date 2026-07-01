output "control_plane_public_ip" {
  description = "Public IP of control plane"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Private IP of control plane"
  value       = aws_instance.control_plane.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of workers"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of workers"
  value       = aws_instance.workers[*].private_ip
}

output "node_ips" {
  description = "All node IPs grouped by role"
  value = {
    control_plane = {
      public  = aws_instance.control_plane.public_ip
      private = aws_instance.control_plane.private_ip
    }
    workers = {
      for idx, worker in aws_instance.workers :
      idx + 1 => {
        public  = worker.public_ip
        private = worker.private_ip
      }
    }
  }
}
