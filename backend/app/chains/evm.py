from web3 import Web3
from web3.middleware import geth_poa_middleware
from eth_account import Account
from dataclasses import dataclass
from typing import Optional

from app.core.config import settings


REDEMPTION_ABI = [
    {"inputs": [{"internalType": "address", "name": "_backend", "type": "address"}], "name": "setBackend", "outputs": [], "stateMutability": "nonpayable", "type": "function"},
    {
        "inputs": [
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"}
        ],
        "name": "redeem",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]


@dataclass
class EvmClient:
    w3: Web3
    signer: Account
    redemption_address: str

    def redeem(self, to_address: str, amount_wei: int) -> str:
        contract = self.w3.eth.contract(address=Web3.to_checksum_address(self.redemption_address), abi=REDEMPTION_ABI)
        txn = contract.functions.redeem(Web3.to_checksum_address(to_address), amount_wei).build_transaction({
            'from': self.signer.address,
            'nonce': self.w3.eth.get_transaction_count(self.signer.address),
            'gas': 200000,
            'maxFeePerGas': self.w3.to_wei('30', 'gwei'),
            'maxPriorityFeePerGas': self.w3.to_wei('1', 'gwei')
        })
        signed = self.w3.eth.account.sign_transaction(txn, private_key=settings.evm_backend_private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed.rawTransaction)
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        return receipt.transactionHash.hex()


def make_client(chain: str) -> Optional[EvmClient]:
    if not settings.evm_enabled:
        return None
    if settings.evm_backend_private_key is None:
        return None

    if chain.lower() == 'polygon':
        rpc = settings.evm_polygon_rpc
        redemption = settings.evm_redemption_address_polygon
    elif chain.lower() == 'arbitrum':
        rpc = settings.evm_arbitrum_rpc
        redemption = settings.evm_redemption_address_arbitrum
    else:
        return None

    if not rpc or not redemption:
        return None

    w3 = Web3(Web3.HTTPProvider(rpc))
    # Many L2s and Polygon require POA middleware
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    acct = Account.from_key(settings.evm_backend_private_key)
    return EvmClient(w3=w3, signer=acct, redemption_address=redemption)
