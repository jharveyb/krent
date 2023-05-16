# krent, the key renter

Rent secrets by the minute with streaming payments

## Motivation

Many services do not accept Lightning payments, nor do they support streaming payments / access.

## Architecture

Our seller lists what services they support, with corresponding BOLT12 offers.

After a buyer fulfills an offer, the seller generates a secret (private key, password, etc.) and sends it to seller in the invoice.

Once the invoice is paid, the seller register the secret so the buyer can use it.

Both buyer and seller must monitor the offer; once the recurring payments end, the seller deregisters the secret, revoking access to the service.

## Initial Services

VPN access, via Mullvad + Wireguard

## References

Mullvad script for config generation: <https://mullvad.net/en/help/wireguard-and-mullvad-vpn/>
