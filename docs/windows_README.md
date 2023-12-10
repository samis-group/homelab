# Windows Ansible Playbook

![Logo](docs/assets/logo.png)

![badge-windows-10]
![badge-windows-11]
![badge-license]

This playbook installs and configures most of the software I use on my Windows 10/11 PC.

## Contents

- [Playbook capabilities](#playbook-capabilities)
- [Setup the Ansible Control Node](#Setup-the-Ansible-Control-Node-(where-you-will-run-the-playbook-from))
- [Setup the Host Windows PC](#Setup-the-Windows-Host-(where-ansible-playbook-will-be-run-on))
  - [OpenSSH method](#OpenSSH-method)
  - [WinRM method](#WinRM-method)
    - [Network Settings](#Network-Settings)
    - [Ansible Setup](#Ansible-Setup)
    - [Troubleshooting Host Setup](#Troubleshooting-Host-Setup)
- [Running the Playbook](#Running-the-Playbook)
  - [Running a specific set of tagged tasks](#Running-a-specific-set-of-tagged-tasks)
- [Included Applications / Configuration (Defaults)](#Included-Applications-/-Configuration-(Defaults))
- [Overriding Defaults](#Overriding-Defaults)
- [Author](#Author)
- [License](#License)

## Playbook capabilities

> **NOTE:** The Playbook is fully configurable. You can skip or reconfigure any task by [Overriding Defaults](#overriding-defaults).

* **Software**
  * Ensures **Bloatware** is removed (see default config for a complete list of Bloatware).
  * Ensure software and packages selected by the user are installed via Chocolatey.
  * Installs [**hass-workstation-service**](https://github.com/sleevezipper/hass-workstation-service) (Home assistant integration service for Windows PC).
  * Installs [**telegraf**](https://docs.influxdata.com/telegraf/v1.21/) to send metrics to an influxdb instance for monitoring.
* **Windows apps & features**
  * Ensures the Optional Windows Features selected by the user are installed and enabled.
  * Ensures WSL2 distro selected by the user is installed and enabled.
* **Windows Settings**
  * **Explorer**
    * Ensures Explorer includes the file extension in file names.
    * Ensures Explorer opens itself to the Computer view.
    * Ensures Ribbon menu is disabled in Windows Explorer.
    * Ensures Right-click Context Menu enabled (Windows 11).
  * **Start Menu**
    * Ensures Automatic Install of Suggested Apps disabled.
    * Ensures App Suggestions in Start menu disabled.
    * Ensures popup "tips" about Windows disabled.
    * Ensures 'Windows Welcome Experience' disabled.
  * **Taskbar**
    * Ensures 'Search' unpinned from Taskbar.
    * Ensures Task View, Chat and Cortana are unpinned from Taskbar.
    * Ensures 'News and Interests' unpinned from Taskbar.
    * Ensures 'People' unpinned from Taskbar.
    * Ensures 'Edge', 'Store' other built-in shortcuts unpinned from Taskbar.
  * **Desktop**
    * Ensure Desktop icons are removed.
  * **General**
    * Ensure configured hostname selected by the user is set.
    * Ensure remote desktop services configured.
    * Ensure sound scheme set to 'No sounds'.
    * Ensure the power plan selected by the user is set.
    * Ensure Windows updates are selected by the user installed.
    * Ensures mouse acceleration is disabled.

## Setup the Ansible Control Node (where you will run the playbook from)

### If using windows host

:exclamation: **Make sure your user is included in the Administrators group on the OS.**

Start by installing WSL. Open admin powershell session and type (It will default to ubuntu, which is fine for me):

```powershell
wsl --install
wsl --set-default-version 2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Download "Ubuntu XX.XX" from the Microsoft Store.

Restart your pc.

### Continue in your wsl instance

1. Initial Setup (this is my personal preference):

```bash
# Setup SSH Keys
mkdir ~/.ssh
cd .ssh/
vim id_blah
vim id_blah
chmod 600 id_*
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_*
# Do apt updates
sudo apt update
sudo apt install -y git make python3-pip stow
mkdir -p ~/git/personal
mkdir -p ~/git/work
cd ~
git clone --recurse-submodules https://github.com/samis-group/dotfiles
# Continue setting up dotfiles, follow steps in readme -> https://github.com/samis-group/dotfiles
```

2. Clone this repo locally (change to https method if you aren't me):

```bash
cd git/personal/
git clone https://github.com/samis-group/homelab
cd homelab
```

1. Run the following commands to enter a container that goes through setup and allows running windows task.

```bash
task ws:s
```

## Setup the Windows Host (where ansible playbook will be run on)

❗ **This playbook was tested on Windows 10 2004 and Windows 11 21H2 (Pro, Ent). Other versions may work but have not tried.** ❗

Before running ansible, let's setup the computer in order to be able to have ansible run on it.

### OpenSSH method

Copy and paste the code below into your PowerShell terminal to get your Windows machine ready to work with Ansible.

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://gist.githubusercontent.com/sami-shakir/8b62badf9485538570ee0a60e496e4e2/raw/248a515b63fb4cdc50b7f97141108d2ff7a6c7cf/setup.ps1"
$file = "$env:temp\setup.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file -Verbose
```

Figure out which user you will be authenticating as:

```powershell
net user
```

[Make sure you setup the ssh key as well if you used a microsoft online account. Change ownership of the authorized_key file to you so you can add the public keys in](https://adamtheautomator.com/openssh-windows/)

### WinRM method

This method sets up your PC so that ansible can run tasks using the [Windows Remote Management tool](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#winrm-setup).

#### Network Settings

Assign a static IP address or if using DHCP, grab the IP as this will be needed when creating the inventory file for this PC:

```powershell
ipconfig
```

#### Ansible Setup

Let's download the ansible setup file to easily setup the PC for use with ansible. Download [this script](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1) and execute it in powershell:

```powershell
cd C:\
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile ansible_setup.ps1
powershell -executionpolicy bypass -File "C:\ansible_setup.ps1"
```

[Here's the guide from ansible on how to do the above.](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#winrm-setup)

Ensure that your inventory file is setup correctly otherwise it will attempt to connect over SSH (**Hint**: You can run `make decrypt` to decrypt your vaulted files rather than below, if you setup your password in the `make setup` command). Go into your [inventory](inventory) file and ensure that it looks like the [inventory.example](inventory.example) file including filled in vars with a local admin user account's credentials:

```bash
ansible-vault edit --vault-password-file ~/.ansible/password inventory
```

Now let's test to ensure connectivity (specify the inventory file if not running in the same dir as it with the `-i` flag):

```bash
ansible --vault-password-file ~/.ansible/password win10 -m win_ping
```

#### Troubleshooting Host Setup

First, let's ensure that you have a minimum **Powershell v3** and **.NET framework 4.0** or newer installed by opening powershell and running:

```powershell
(Get-Host).Version      # Check powershell version
Get-ChildItem ‘HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP’ -Recurse | Get-ItemProperty -Name version -EA 0 | Where { $_.PSChildName -Match ‘^(?!S)\p{L}’} | Select PSChildName, version       # Check .NET versions
```

**Go and install them if they're not present.**. ([Link to a guide that can assist.](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#upgrading-powershell-and-net-framework))

## Running the Playbook

If you have setup the container successfully, just run the following to execute the playbook in it's entirety:

```bash
task windows:main
```

If it does not run successfully, first check the `hosts: winXXXX` line in inventory, to see which host is being used, and ensure the details such as the IP address, user and even the variables are correct, e.g. For SSH connections, you need to use the variable `ansible_ssh_user` instead of `ansible_user` otherwise it throws a `permission denied` error.

The PC will likely reboot a couple of times. I suggest you pin this repo to you browser. The following command resumes the make once you're back, just type them in your WSL instance:

```bash
cd git/personal/homelab/ && task windows:main
```

:exclamation: Here are a few variables and their location that you may wish to lookup and change:

| Variable      | File Location | Line Number (If Known) |
| ------------- | ------------- | ------------- |
| wsl2_distribution | vars/default.config.yml  | 37 |

## Overriding Defaults

You can override any of the defaults configured in `provision/ansible/vars.yml`. For example, you can customize the installed packages and enable/disable specific tasks with something like:

```yaml
configure_hostname: true
custom_hostname: myhostname

install_windows_updates: true
update_categories:
  - Critical Updates
  - Security Updates

choco_installed_packages:
  - googlechrome
  - vlc
  - 7zip.install

install_fonts: true
installed_nerdfonts:
  - Meslo

install_windows_features: true
windows_features:
  Microsoft-Hyper-V: true

install_wsl2: true
wsl2_distribution: wsl-archlinux

remove_bloatware: true
bloatware:
  - Microsoft.Messaging
```

## Author

This project was created by [Sami Shakir](https://www.linkedin.com/in/nabokih/) (Taking some "inspiration" (code copying) from [Alexander Nabokikh](https://github.com/AlexNabokikh/windows-playbook)).

## License

This software is available under the following licenses:

* **[MIT](./LICENSE)**

[badge-windows-11]: https://img.shields.io/badge/OS-Windows%2011%2021H2-blue
[badge-windows-10]: https://img.shields.io/badge/OS-Windows%2010%2020H2-blue
[badge-license]: https://img.shields.io/badge/License-MIT-informational
