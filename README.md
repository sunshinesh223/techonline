# TechOnline -- disposible vpn in aws with openvpn

This project focuses on leveraging the OpenVPN Docker solution in combination with AWS to quickly set up VPN servers in various countries.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Authors](#authors)
- [License](#license)

## Getting Started


### Prerequisites

What things you need to install the software and how to install them:
- Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- AWS profile: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

### Installation

Please follow the official instructions for each prerequisites.

## Usage

- Configuring the region related variables in the terraform.tfvars. This will be used by the [terraform workspace](https://developer.hashicorp.com/terraform/language/state/workspaces) later. Make sure you have the exact match of the name with your new workspace as them in the terraform.tfvars file. In the example, I have three workplaces as follow: 
  - terraform workspace new hongkong
  - terraform workspace new japan
  - terraform workspace new korea
- Use the terraform init command to initialize the env, and switching between workspaces to have multi az deployment
  - terraform init
  - terraform workspace select hongkong
- Create vpn servers in the selected workspace
  - terraform plan
  - terraform apply
- Download the ovpn configuration 
  - scp ec2-user@ip-you-got-from-terraform-apply:~/*.ovpn
- Then open the ovpn files with your openvpn client on MAC, Windows, iPhone or Android

## Author

Guang Yang

## License

This project is licensed under the [BSD]() License.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
