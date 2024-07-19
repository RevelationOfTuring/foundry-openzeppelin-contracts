import {ethers} from 'ethers'

// tool to acquire two function signatures with different arguments and same selector
let selectorsA = new Map<string, string>()
let selectorsB = new Map<string, string>()
for (let i = 0; ; i++) {
    const functionSignatureA = `proxy${i}(uint256)`
    const functionSignatureB = `implementation${i}()`
    const selectorA = ethers.keccak256(ethers.toUtf8Bytes(functionSignatureA)).slice(0, 10)
    const selectorB = ethers.keccak256(ethers.toUtf8Bytes(functionSignatureB)).slice(0, 10)
    if (selectorsA.has(selectorB)) {
        console.log(`same selector ${selectorB}: ${selectorsA.get(selectorB)} && ${functionSignatureB}`)
        break
    } else if (selectorsB.has(selectorA)) {
        console.log(`same selector ${selectorA}: ${selectorsB.get(selectorA)} && ${functionSignatureA}`)
        break
    } else {
        selectorsA.set(selectorA, functionSignatureA)
        selectorsB.set(selectorB, functionSignatureB)
    }
}