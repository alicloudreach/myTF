module "networking" {
  source        = "./networking"
  vpc_cidr      = "10.17.0.0/27"
  public_cidrs  = ["10.17.0.0/28"]
  private_cidrs = ["10.17.0.16/28"]
  access_ip = var.access_ip
}