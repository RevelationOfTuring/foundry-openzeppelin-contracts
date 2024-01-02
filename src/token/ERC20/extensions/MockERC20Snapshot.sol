// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

contract MockERC20Snapshot is ERC20Snapshot {
    constructor(
        string memory name,
        string memory symbol,
        address richer,
        uint totalSupply
    )
    ERC20(name, symbol)
    {
        _mint(richer, totalSupply);
    }

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint amount) external {
        _burn(account, amount);
    }

    function snapshot() external {
        _snapshot();
    }

    function getCurrentSnapshotId() external view returns (uint){
        return _getCurrentSnapshotId();
    }
}
