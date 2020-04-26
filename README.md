# ALB Cost Testing

Some rough code for provisioning AWS test environment, to measure the cost
of adding an Application Load Balancer (ALB).

Two use-cases:
 1. `tf-standalone-server` is a VM hosting a web-server, with an elastic IP.
 2. `tf-alb-server` in a VM with an application load balancer in front of it.

The `/scripts/` directory gives a starting point for generating load against
the web-site to cause a lot of ingress and egress traffic.

To replicate my tests, you'd have to do a few tweaks including:
 * Change the provider.tf to use your IAM Role.
 * Change the security groups' CIDR blocks so you can reach the VM / endpoint.
 * Change the `scripts/`, such as for the file paths and the IP addresses of your
   endpoints.
   (use `nslookup` to get the two IP addresses of the ALB, so you can hit both
   availability zones.)

Warning: consider this code as a starting point; it was only ever used for a
single use-case; it is a very long way from being production quality or from
following best practices!
