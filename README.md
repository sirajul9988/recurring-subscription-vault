# Recurring Subscription Vault

This repository provides a framework for time-based subscriptions on the blockchain. Instead of relying on centralized payment processors, users "Subscribe" by granting the contract permission to pull funds at specific intervals.

## Core Logic
* **Subscription Tiers**: Creators set a `monthlyRate` in a stablecoin (e.g., USDC).
* **Pull Mechanism**: The creator (or a bot) triggers the `collect()` function every 30 days to pull the subscription fee from the user's wallet.
* **Allowance-Based**: Users must `approve()` the contract to spend their stablecoins up to a certain limit.
* **Cancellation**: Users can cancel at any time by revoking the approval or calling `unsubscribe()`.

## Security
* **Interval Guard**: Prevents the creator from pulling funds more than once every 30 days.
* **Grace Period**: Logic to handle accounts that are temporarily underfunded without immediately revoking access.
