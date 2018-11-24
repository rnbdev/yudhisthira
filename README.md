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

```bash
git clone https://github.com/getonchain/yudhisthira
cd yudhisthira

# NOTE: These scripts are for development use only...
./yudhisthira install
./yudhisthira run --port 4002 # Warming: This opens a HTTP /admin endpoint in dev mode for modifying & adding secrets
```

Open a new terminal,
```bash
# Navigate to the previous directory on a new terminal

# Let's add a secret key value pair
./yudhisthira --addsecret --port 4002 --secret secretvalue1234 --secret_key secretkey1234
# Should prompt a secret added sign

# Now let's check if the verification works
./yudhisthira --authenticate --port 4002 --secret secretvalue1234 --secret_key secretkey1234
# Should prompt a secret matched sign
# This spins up a server-less version of a Yudhisthira and verifies the keys with Socialist Millionaire Protocol
```

## Why open-source?

We are open-sourcing Yudhisthira from the very start for well-thought-out reasons:

- a privacy-first application requires industrial-grade scrutiny of its cryptography suites. Opening the application up from early stage enables a broad spectrum of cryptographers, cypherpunks, and corporate to work together.
- This protocol is meant for providing interoperability in multi-vendor platforms. Thus, it is aligned with the goal to build towards an open-source standard.

[Milestones](https://github.com/getonchain/yudhisthira/milestones) and [Projects](https://github.com/getonchain/yudhisthira/projects) provide a transparent view of the project.

