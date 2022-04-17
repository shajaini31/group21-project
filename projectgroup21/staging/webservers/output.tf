# Step 10 - Add output variables
#output "public_ip" {
#value = aws_instance.my_amazon.public_ip
#}

/*output "web_eip" {
  value = aws_eip.static_eip[*].public_ip
}
*/
output "security_group_web_sg" {
    value = aws_security_group.web_sg.id
}

output "instance_id"{
    value = aws_instance.my_amazon[*].id
}