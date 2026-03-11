# BattleChain DevEx

Mono-repo of submodules for the BattleChain project — Cyfrin's PvP security-focused blockchain where smart contracts face open exploitation in a live arena before production deployment.

## Repositories

| Directory | Description |
|---|---|
| [`battlechain-lib`](https://github.com/Cyfrin/battlechain-lib) | Foundry library for deploying on BattleChain and adopting Safe Harbor agreements |
| [`battlechain-prediction`](https://github.com/Cyfrin/battlechain-prediction) | Prediction market AMM using Gaussian-based LMSR with time-decaying liquidity |
| [`battlechain-safe-harbor`](https://github.com/Cyfrin/battlechain-safe-harbor) | Safe Harbor and Attack Registry contracts for BattleChain |
| [`battlechain-starter`](https://github.com/Cyfrin/battlechain-starter) | Starter template for building and deploying on BattleChain |
| [`docs-battlechain`](https://github.com/Cyfrin/docs-battlechain) | Documentation site (Next.js) |
| [`solskill`](https://github.com/Cyfrin/solskill) | Solidity development standards |

## Setup

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/Cyfrin/battlechain-devex.git
```

If already cloned, initialize submodules:

```bash
git submodule update --init --recursive
```

## Usage

Each submodule is an independent repository. `cd` into any directory and follow its own README for build/test instructions.

Pull latest changes across all submodules:

```bash
git submodule update --remote --merge
```
