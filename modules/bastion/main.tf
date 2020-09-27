//data "template_file" "bastion_user_data" {
//  template = "${file("${path.module}/bastion_userdata.sh")}"
//
////  vars {
////    REGION = "${var.bastion_region}"
////    EIP_ID = "${aws_eip.bastion_eip.id}"
////  }
//}

resource "aws_launch_configuration" "bastion"{
  name_prefix     = "BastionHost-"
  image_id        = var.amazon_linux
  instance_type   = var.instance_type
  security_groups = [var.security_group_bastion]
  key_name = "terraform-key"

  user_data       = templatefile("../modules/bastion/bastion.sh.tpl", {
    programs_to_install         = ["mysql"]
  })

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_key_pair.ssh]
}

resource "aws_autoscaling_group" "bastion" {
  name = "Bastion-${aws_launch_configuration.bastion.name}"
  max_size = 1
  min_size = 1
  min_elb_capacity = 1
  vpc_zone_identifier = var.subnets
  health_check_grace_period = 60
  #load_balancers = [aws_elb.web.name]
  health_check_type = "EC2"
  #ping or EC2 service will checks
  desired_capacity = 1
  default_cooldown = 60
  #force_delete              = true
  #placement_group           = aws_placement_group.test.id
  launch_configuration = aws_launch_configuration.bastion.name
  dynamic "tag" {
    for_each = {
      Name    = "Bastion Blue/Green"
      Owner   = "Andrii"
      TAGKEY  = "TAGVALUE"
    }
    content {
    key = tag.key
    value = tag.value
    propagate_at_launch = true
    }
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = data.aws_instances.bastion.ids[0]
  allocation_id = aws_eip.bastion_static_ip.id
  depends_on = [aws_eip.bastion_static_ip]
}


resource "aws_eip" "bastion_static_ip" {
  vpc = true
  tags = {
    Name = "Bastion"
  }
  depends_on = [
    aws_autoscaling_group.bastion]
}


resource "aws_key_pair" "ssh" {

  key_name = "terraform-key"

  public_key = file("../modules/bastion/id_rsa.pub")

}

//resource "aws_eip" "amaz_static_ip" {
//  vpc                       = true

//  instance = aws_instance.my_amazon.id
  #tags = merge(var.tags, {Name = "var.tags["Environment"]} Server IP})
//}

data "aws_instances" "bastion" {
  instance_tags = {
    Name = "Bastion Blue/Green"
  }
  depends_on = [aws_autoscaling_group.bastion]
}
