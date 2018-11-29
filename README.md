# Yudhisthira
Privacy-first communication protocol for decentralized networks providing interoperability in multi-vendor platforms.

Yudhisthira provides a communication mechanism for a scalable, decentralized mesh of low footprint, fault tolerant nodes. The privacy-first communication system is suitable for a wide variety of intra-VPC applications running on multi-vendor platforms. Yudhisthira is built ground-up with industry-standard Erlang runtime.

See more details at [https://yudhisthira.io](https://yudhisthira.io).

## Etymology

Yudhisthira is the epitome of righteousness in the legendary epic Mahabharata. It seems only appropriate to name our protocol by the king who never lied.

## Use cases

Yudhisthira is ideal for enterprise and permissioned networks where trust is a two-way street. It enables a set of multiparty computation (MPC) and zero-knowledge proof (ZKP) based communication templates for providing proof of knowledge without sharing sensitive data.

From financial institutions, audit firms to Internet of Things (IoT) networks, Yudhisthira can be used out-of-the-box and setup in minutes. A credit scoring institution proving that a particular user is creditworthy without sharing the credit score? Third-party audit firms ensuring the validity of a transaction between two entities without knowing the transaction details? Two IoT devices proving to each other that they are from the same manufacturer without sharing the manufacturer details? The possibilities are endless.

# Commands

Each node listens on two ports,

 1. One for authentication and communication needs.
 2. Another administrative endpoint that ideally will not be accessible from the outside world.
 
The CLI tool allows three primary modes of operation.

  1. For running the application, on a specific port, with a specific host. Command line parameters, `--port <PORT OF THE NODE>` , `--host <HOST NAME OF THE NODE>`
  2. For secrets the mode parameter is `--(add|list|delete)-secret(s)` and data parameters are `--admin-port <ADMIN PORT OF THE NODE>`, `--host <HOST NAME OF THE NODE>`, `--secret-key <KEY FOR SECRET>`, `--secret <SECRET VALUE>`
  3. For secrets the mode parameter is `--(add|list|delete)-peer(s)` and data parameters are `--admin-port <ADMIN PORT OF THE NODE>`, `--host <HOST NAME OF THE NODE>`, `--peer-host <HOST OF THE PEER TO BE ADDED>`, `--peer-port <PORT OF THE PEER TO BE ADDED>`
  4. For authentication, as of right now, it can only authenticate against key-value pairs as a client. In order to do that you would need to do that with `--port <NODE PORT>`, `--host <HOST NAME>`, `--secret-value <SECRET VALUE>`, `--secret-key <SECRET KEY>`.

The peer connection relies on `:embedded-secret` on the configuration to authenticate itself with its peers.

## Example usage

As an example, we showcase how two nodes can compare their secret values. We will install Yudhisthira in one location for convenience, and use two local ports to spawn up two nodes. Each node then can have their *secret* which they can match without communicating any part of the *secret* itself.

Before you start, install Elixir (> 1.6).

In Mac, for example, `brew install elixir` should work with homebrew for latest MacOS.

**Caution: This is strictly shown as an example, and not to be used in production. For questions, contact yudhisthira@getonchain.com.**

Install Yudhisthira.
```
git clone https://github.com/getonchain/yudhisthira
cd yudhisthira
./yudhisthira install
```

Open a node in port 4001, with admin port 5001
(Warning: This opens an HTTP /admin endpoint in dev mode. It is not suitable for production.)

```
yudhisthira run --port 4001
```

Add a secret as a (key, value) pair. It can be any secret to the node, for example, for an IoT device, it can be the name of the manufacturer.

```
./yudhisthira --add-secret --admin-port 5001 --secret-key manufacturer --secret-value samsung
```

Open a new terminal to run another node.

```
cd yudhisthira
./yudhisthira run --port 4002
```

Add the secret to the new node.

```
./yudhisthira --add-secret --admin-port 5002 --secret-key manufacturer --secret-value samsung
```

Check if the secrets match (for example, the nodes are from the same manufacturer). In this case, we are providing the secret with the command-line argument, but we will update it in future updates.

```
./yudhisthira --authenticate --port 4001 --secret-key manufacturer --secret-value samsung
```

To let the nodes make aware of each other, you can add them as peers.

```
./yudhisthira --add-peer --admin-port 5001 --peer-port 4002
```
(This adds the node that is running on 4002, through the admin port of node 4001)

You can also list all peers through the admin port.

`./yudhisthira --list-peers --admin-port 5001`


## Why open-source?

We are open-sourcing Yudhisthira from the very start for well-thought-out reasons:

- A privacy-first application requires industrial-grade scrutiny of its cryptography suites. Opening the application up from early stage enables a broad spectrum of cryptographers, cypherpunks, and corporate to work together.
- This protocol provides interoperability in multi-vendor platforms. Thus, it is aligned with the goal to build towards an open-source standard.

[Milestones](https://github.com/getonchain/yudhisthira/milestones) and [Projects](https://github.com/getonchain/yudhisthira/projects) provide a transparent view of the project.

