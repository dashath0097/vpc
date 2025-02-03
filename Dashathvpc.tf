provider "aws" {
  region     = "us-east-1" # Update with your desired region
}


resource "aws_vpc" "vpc1"{
    cidr_block              = "192.168.0.0/16"
    enable_dns_support      = true
    enable_dns_hostnames    = true
}

resource "aws_subnet" "pub"{
    vpc_id                  = "${aws_vpc.vpc1.id}"
    map_public_ip_on_launch = true
    cidr_block              = "192.168.1.0/24"

}

resource "aws_subnet" "pri"{
    vpc_id                  = "${aws_vpc.vpc1.id}"
    map_public_ip_on_launch = true
    cidr_block              = "192.168.2.0/24"
}

resource "aws_internet_gateway"  "hathway"{
    vpc_id                  = "${aws_vpc.vpc1.id}"
}

resource "aws_route_table" "myrout" {
    vpc_id                  =   "${aws_vpc.vpc1.id}"
    route{
        cidr_block          = "0.0.0.0/0"
        gateway_id          = "${aws_internet_gateway.hathway.id}"
    }
}

resource "aws_route_table_association" "public"{
    subnet_id               = "${aws_subnet.pub.id}"
    route_table_id           = "${aws_route_table.myrout.id}"
}

resource "aws_instance" "public"{
    ami             = "ami-0453ec754f44f9a4a"
    instance_type   = "t2.micro"
    subnet_id       = "${aws_subnet.pub.id}"
}
resource "aws_instance" "private"{
    ami             = "ami-0453ec754f44f9a4a"
    instance_type   = "t2.micro"
    subnet_id       = "${aws_subnet.pri.id}"
}
