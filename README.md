# Yudhisthira
Privacy-first communication protocol for decentralized networks providing interoperability in multi-vendor platforms.

[https://yudhisthira.io](https://yudhisthira.io)

## Etymology

Yudhisthira is the eptiome of righteousness in the legendary epic Mahabharata. It seems only appropriate to name our protocol by the king who never lied.

## Use cases

Yudhisthira provides a scalable, decentralized mesh of low footprint, fault tolerant nodes with in-memory-only datastore. The privacy-first communication system is suitable for a wide variety of intra-VPC applications running on multi-vendor platforms. It is built on industry standard Erlang runtime for resilience.

Yudhisthira is ideal for enterprise and permissioned networks where trust is a two-way street. It enables a number of multiparty computation (MPC) and zero-knowledge proof (ZKP) based communication templates for providing proof of knowledge without sharing sensitive data.

From financial institutions, audit firms to Internet of Things (IoT) networks, Yudhisthira can be used out-of-the-box and setup in minutes for a variety of domains. A credit scoring institution proving that a particular user is credit worthy without sharing the credit score? Third-party audit firms ensuring the validity of a transaction between two entitites without knowing the transaction details? Two IoT devices proving to each other that they are from the same manufacturer without sharing the manufacturer details? The possibilities are endless.

## Usage

Before you start, you would need to install Elixir (> 1.6).

NOTE: These scripts are for development use only...

```bash
git clone https://github.com/getonchain/yudhisthira
cd yudhisthira

./yudhisthira install
# You can add a --port <PORT> to override the deafult port of 4001
./yudhisthira run # Warning: This opens a HTTP /admin endpoint in dev mode for modifying & adding secrets
```

Open a new terminal,
```bash
# Navigate to the previous directory on a new terminal

# If your node is running on some other port other than the default 4001, add the --port CLI arg.

# Let's add a secret key value pair
./yudhisthira --addsecret --secret-value secretvalue1234 --secret-key secretkey1234
# Should prompt a secret added sign

# Now let's check if the verification works
./yudhisthira --authenticate --secret-value secretvalue1234 --secret-key secretkey1234
# Should prompt a secret matched sign
# This spins up a server-less version of a Yudhisthira instance and verifies the keys with Socialist Millionaire Protocol

# Now let's see all the secret key-value pairs we have on our node
./yudhisthira --list-secrets

# Now let's delete a key
./yudhisthira --delete-secret --secret-key secretkey1234

# Now let's see of the secrets match or not
./yudhisthira --authenticate --secret-key secretkey1234 --secret-value secretvalue1234
# Should prompt that secrets didn't match

# You can also update a secret
./yudhisthira --update-key --secret-key secretkey1234 --secret-value newsecretvalue4321

# And then verify
./yudhisthira --authenticate --secret-key secretkey1234 --secret-value secretvalue1234
# They won't match...

./yudhisthira --add-peer 
# Would add the node itself as a peer

./yudhisthira --list-peers
# Would list the registered peers on that particular node

./yudhisthira --delete-peer
# Would remove delete the peer
```

Each node listens on two ports,

 1. For authentication and communication needs.
 2. Administrative endpoint that ideally won't be accessible from the outside world.
 
The CLI tool allows three primary modes of operation.

  1. For running the application, on a specific port, with a specific host. Command line parameters, `--port <PORT OF THE NODE>` , `--host <HOST NAME OF THE NODE>`
  2. For secrets the mode paremeter is `--(add|list|delete)-secret(s)` and data parameters are `--admin-port <ADMIN PORT OF THE NODE>`, `--host <HOST NAME OF THE NODE>`, `--secret-key <KEY FOR SECRET>`, `--secret <SECRET VALUE>`
  3. For secrets the mode paremeter is `--(add|list|delete)-peer(s)` and data parameters are `--admin-port <ADMIN PORT OF THE NODE>`, `--host <HOST NAME OF THE NODE>`, `--peer-host <HOST OF THE PEER TO BE ADDED>`, `--peer-port <PORT OF THE PEER TO BE ADDED>`

For example, a complete command line syntax for adding a secret to a generic node would be,

`./yudhisthira --host <NODE HOST> --admin-port <ADMIN PORT OF THE NODE> --add-secret --secret <SECRET VALUE> --secret-key <SECRET KEY>`

However, adding a peer would be like,
`./yudhisthira --host <NODE HOST> ----admin-port <ADMIN PORT OF THE NODE> --add-peer --host <SECRET VALUE> --secret-key <SECRET KEY>`

## Why open-source?

We are open-sourcing Yudhisthira from the very start for well-thought-out reasons:

- a privacy-first application requires industrial-grade scrutiny of its cryptography suites. Opening the application up from early stage enables a broad spectrum of cryptographers, cypherpunks, and corporate to work together.
- This protocol is meant for providing interoperability in multi-vendor platforms. Thus, it is aligned with the goal to build towards an open-source standard.

[Milestones](https://github.com/getonchain/yudhisthira/milestones) and [Projects](https://github.com/getonchain/yudhisthira/projects) provide a transparent view of the project.

