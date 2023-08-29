import {ethers} from 'ethers'
import type {TypedDataDomain} from 'ethers'
import {writeFileSync} from 'fs'

const domain: TypedDataDomain = {
    name: 'mock name',
    version: '1',
    chainId: 1024,
    verifyingContract: '0xfc1a36B3eF056c2eC89FdeB4251e90F7935F1b51'
}

const types = {
    'NameCard': [
        {'name': 'name', 'type': 'string'},
        {'name': 'salary', 'type': 'uint256'},
        {'name': 'personalAddress', 'type': 'address'},
    ]
}

// typed data
const value = {
    name: 'Michael.W',
    salary: 1024,
    personalAddress: '0x0000000000000000000000000000000000000400',
}

async function main() {
    const domainSeparator = ethers.TypedDataEncoder.hashDomain(domain)
    const wallet = new ethers.Wallet(ethers.toBeHex(1024, 32))
    const signature = await wallet.signTypedData(domain, types, value)

    // generate domain separator with chain id changed
    domain.chainId = 2048
    const domainSeparatorWithChainIdChanged = ethers.TypedDataEncoder.hashDomain(domain)

    const output = {
        domain_separator: domainSeparator,
        domain_separator_with_chain_id_changed: domainSeparatorWithChainIdChanged,
        value,
        signature,
        signer_address: wallet.address
    }

    writeFileSync('test/utils/cryptography/data/EIP712_test.json', JSON.stringify(output))
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})