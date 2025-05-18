output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_eu_central_1a" {
  value = aws_subnet.private_subnet_eu_central_1a.id
}

output "private_subnet_eu-central_1b" {
  value = aws_subnet.private_subnet_eu_central_1b.id
}

output "public_subnet_eu_central_1a" {
  value = aws_subnet.public_subnet_eu_central_1a.id
}

output "public_subnet_eu_central_1b" {
  value = aws_subnet.public_subnet_eu_central_1b.id
}

output "subnet_ids" {
  value = [aws_subnet.private_subnet_eu_central_1a.id, aws_subnet.private_subnet_eu_central_1b.id, aws_subnet.public_subnet_eu_central_1a.id, aws_subnet.public_subnet_eu_central_1b.id]
}

output "private_subnet_ids" {
  value =  [aws_subnet.private_subnet_eu_central_1a.id, aws_subnet.private_subnet_eu_central_1b.id ]
}
