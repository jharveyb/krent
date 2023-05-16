# Mullvad

- Config generator (DONE)
- - Accepts wireguard private key, writes all possible wirguard configs

- Key manager
- - Can register keys, delete keys, check existing keys, via Mullvad service

- Testing
- - Linux and macOS

# C-Lightning

- Generate offers for recurring payments?

- Generic plugin to interact with key manager
- - Trigger secret creation when offer is pinged
- - Fetch secret to embed into invoice
- - Trigger secret registration when invoice is paid
- - Cronjob / polling to detect end of recurring payment
- - Trigger secret deactivation after end of payment

# Misc

- Demo site?