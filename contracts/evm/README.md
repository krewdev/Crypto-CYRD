EVM Contracts
-------------

Contracts:
- `CYRD.sol`: ERC-20 with owner-controlled mint
- `Redemption.sol`: Holds CYRD and allows backend-authorized redemptions

Setup:
1. `npm install`
2. Copy `.env.example` to `.env` and set keys
3. `npm run build`

Deploy examples (localhost):
- `npm run deploy:token`
- `CYRD_ADDRESS=0x... BACKEND_SIGNER=0x... npm run deploy:redemption`
