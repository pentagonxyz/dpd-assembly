# dpd-assembly

DPD’s, or Decentralized Programmable Data, are a tokenized primitive for contract governed data. The DPD primitive is based on the ERC721 standard but introduces upgradability to underlying data. This data could be anything from data on-chain all the way to IPFS or Arweave instances.
Some use-case examples: token holder governed front-ends, re-creating million dollar webpage, or even a programmable oracle network.

## Setup

First, you need to install huffup, a tool that allows you to easily install the Huff compiler. You can do that by running:

```shell
curl -L get.huff.sh | bash
```

Next, to install the lastest compiler version, run:

```shell
huffup
```

Finally, you can run `make all` to install the necessary Foundry libraries.

## Testing

Before testing, ensure that `ffi` is set to true in the `Foundry.toml` file. This enables Foundry to run the Huff compiler from the Rust VM.

To test your code, you can run:

```shell
forge test
```
