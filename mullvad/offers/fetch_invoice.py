from lightning import LightningRpc
import random

# sats for each offer
amount = 10
recurrence = 0

# track responses / offers
# response id => bolt12
responses = {}
offer = "lno1qgsqvgnwgcg35z6ee2h3yczraddm72xrfua9uve2rlrm9deu7xyfzrcgqy9q5ptkwphrzwqwqq2q26mjv4h8g9spqyvqzqg6qgqrc83qzsjnx4dh67fs6ykx66csnx6ujlegpgrq67kg5l4d5v77valhkf8lqs9arrm8mz0f9fra5gvgrwawlnda7s70auypggrnvd5jlfkv7zjyscqvufqf3qkl43vp24u3y6p2m35q9u8vh92p872fpf6yy783262xj"

# service-side create offer - this assumes lightningd is run with
# --rpc-file=/tmp/lightningrpc. could do username / pass here as well
l2 = LightningRpc("/tmp/l2-regtest/regtest/lightning-rpc")

# create offer for service - description has a random string for testing.
# lightningd rejects a offers with duplicate descriptions
response = l2.call("fetchinvoice", [offer, amount, 1, recurrence, "", "vpn", ""])
# response = l1.call("offer", [str(amount), "vpn" + str(random.randint(0, 100)), "krent", "", 1, 1, "", recurrence])
# responses[response['offer_id']] = response['bolt12']
print(response)# ['bolt12'])

