from lightning import LightningRpc
import random

# sats for each offer
amount = 10
recurrence = "60seconds"

# track responses / offers
# response id => bolt12
responses = {}

# service-side create offer - this assumes lightningd is run with
# --rpc-file=/tmp/lightningrpc. could do username / pass here as well
l1 = LightningRpc("/tmp/l1-regtest/regtest/lightning-rpc")

# create offer for service - description has a random string for testing.
# lightningd rejects a offers with duplicate descriptions
response = l1.call("offer", [str(amount), "vpn" + str(random.randint(0, 100)), "krent", "", 1, 1, "", recurrence])
responses[response['offer_id']] = response['bolt12']
print(response['bolt12'])

