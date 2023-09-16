import * as fs from 'fs'
import {StandardMerkleTree} from '@openzeppelin/merkle-tree'

// 1. build a tree
const elements = [
    ['0x0000000000000000000000000000000000000001', 10000],
    ['0x0000000000000000000000000000000000000002', 20000],
    ['0x0000000000000000000000000000000000000003', 30000],
    ['0x0000000000000000000000000000000000000004', 40000],
    ['0x0000000000000000000000000000000000000005', 50000],
    ['0x0000000000000000000000000000000000000006', 60000],
]

let merkleTree = StandardMerkleTree.of(elements, ['address', 'uint256'])
const output = {
    merkle_root: merkleTree.root,
    merkle_tree: merkleTree.dump(),
}

fs.writeFileSync('test/utils/cryptography/data/merkle_tree.json', JSON.stringify(output))

// 2. get proof
// read json merkle tree from file
const content = JSON.parse(fs.readFileSync('test/utils/cryptography/data/merkle_tree.json', 'utf8'))
merkleTree = StandardMerkleTree.load(content['merkle_tree'])

const arr = []
for (const [i, element] of merkleTree.entries()) {
    arr.push({'account': element[0], 'amount': element[1], 'proof': merkleTree.getProof(i)})
}

fs.writeFileSync('test/utils/cryptography/data/merkle_proof.json', JSON.stringify(arr))

// 3. generate multi proofs
const {proof, proofFlags, leaves} = merkleTree.getMultiProof([0, 2, 4])

fs.writeFileSync('test/utils/cryptography/data/merkle_multi_proof.json', JSON.stringify({
    proof,
    'proof_flags': proofFlags,
    'leaves': leaves.map(item => {
        return {
            'account': item[0],
            'amount': item[1],
        }
    }),
}))