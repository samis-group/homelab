# Test suites for `k3s-ansible`

This folder contains the [molecule](https://molecule.rtfd.io/)-based test setup for this playbook.

## Scenarios

I have these scenarios:

- **default**:
  A docker VM that runs my docker containers
- **k3s_cluster**:
  A 3 control + 2 worker node k3s cluster.
- **k3s_single**:
  Very similar to the `k3s_cluster` scenario, but uses only a single node for all cluster functionality. Quik-Kubes-Brah!

### tl;dr

- default:

  ```bash
  molecule create
  ```

  ```bash
  molecule converge
  ```

- k3s_cluster:

  ```bash
  molecule create -s k3s_cluster
  ```

  ```bash
  molecule converge -s k3s_cluster
  ```

- k3s_single:

  ```bash
  molecule create -s k3s_single
  ```

  ```bash
  molecule converge -s k3s_single
  ```

## How to execute

To test on your local machine, follow these steps:

### System requirements

Make sure that the following software packages are available on your system:

- [Python 3](https://www.python.org/downloads)
- [Vagrant](https://www.vagrantup.com/downloads)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Set up VirtualBox networking on Linux, macOS and WSL

*You can safely skip this if you are working on Windows without WSL.*

Furthermore, the test cluster uses the `192.168.30.0/24` subnet which is [not set up by VirtualBox automatically](https://www.virtualbox.org/manual/ch06.html#network_hostonly).
To set the subnet up for use with VirtualBox, please make sure that `/etc/vbox/networks.conf` exists and that it contains this line:

```bash
* 192.168.30.0/24
* fdad:bad:ba55::/64
```

### Install Python dependencies

You will get [Molecule, Ansible and a few extra dependencies](../requirements.txt) via [pip](https://pip.pypa.io/).
Usually, it is advisable to work in a [virtual environment](https://docs.python.org/3/tutorial/venv.html) for this:

```bash
cd ~/git/personal/homelab/

# Create a virtualenv at ".env". You only need to do this once.
python3 -m venv .env

# Activate the virtualenv for your current shell session.
# If you start a new session, you will have to repeat this.
source .env/bin/activate

# Install the required packages into the virtualenv.
# These remain installed across shell sessions.
python3 -m pip install -r requirements.txt
```

### Run molecule

With the virtual environment from the previous step active in your shell session, you can now use molecule to test the playbook.
Interesting commands are:

- `molecule create`: Create virtual machines for the test cluster nodes.
- `molecule destroy`: Delete the virtual machines for the test cluster nodes.
- `molecule converge`: Run the relevant ansible playbook on the nodes of the virtual machine(s) created.
- `molecule side_effect`: *k3s only*. Run the `reset` playbook on the nodes of the test cluster.
- `molecule verify`: *k3s only*. Verify that the cluster works correctly.
- `molecule test`: *k3s only*. The "all-in-one" sequence of steps that is executed in CI.
  This includes the `create`, `converge`, `verify`, `side_effect` and `destroy` steps.
  See [`molecule.yml`](default/molecule.yml) for more details.

### Copy kube config

This is done in make, run `make setup-pb`. Manual steps below:

```bash
mkdir ~/.kube
scp vagrant@192.168.30.38:~/.kube/config ~/.kube/config
```
