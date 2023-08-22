import {ethers} from 'ethers'
import {writeFileSync} from 'fs'

// for:
//      function toEthSignedMessageHash(bytes32 hash)
const digestHash = ethers.keccak256(ethers.toUtf8Bytes('Michael.W'))
const ethSignedMessageHashFromHash = ethers.hashMessage(ethers.getBytes(digestHash))

// for:
//      function toEthSignedMessageHash(bytes memory s)
const ethSignedMessageHashFromBytes = ethers.hashMessage('Michael.W')

// for:
//      function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
const domain = {
    'name': 'test name',
    'version': '1',
    'chainId': 1024,
    'verifyingContract': '0x7a41fc8b73D6F307830b88878caf48D077128F63',
}

const types = {
    'Student': [
        {'name': 'address', 'type': 'address'},
        {'name': 'age', 'type': 'uint256'},
    ]
}

const value = {
    'address': ethers.ZeroAddress,
    'age': 18,
}

const structHash = ethers.TypedDataEncoder.from(types).hash(value)
const typedDataHash = ethers.TypedDataEncoder.hash(domain, types, value)

// generate signature
const wallet = new ethers.Wallet(ethers.toBeHex(1024, 32))
const signature = wallet.signMessageSync('Michael.W')

// generate compact signature following EIP-2098
const signatureCompact = wallet.signingKey.sign(ethers.hashMessage('Michael.W'))
const signatureCompactR = signatureCompact.r
const signatureCompactVS = signatureCompact.yParityAndS

const output = {
    eth_signed_msg_hash_from_hash: ethSignedMessageHashFromHash,
    eth_signed_msg_hash_from_bytes: ethSignedMessageHashFromBytes,
    struct_hash: structHash,
    typed_data_hash: typedDataHash,
    valid_signature: signature,
    compact_signature_r: signatureCompactR,
    compact_signature_vs: signatureCompactVS
}

writeFileSync('test/utils/cryptography/data/ECDSA_test.json', JSON.stringify(output))