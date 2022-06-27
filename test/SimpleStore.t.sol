// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SimpleStoreTest is Test {
    /// @dev Address of the SimpleStore contract.
    Repository public repository;

    /// @dev Setup the testing environment.
    function setUp() public {
        repository = Repository(HuffDeployer.deploy("Repository"));
    }

    /// @dev Ensure that you can create new DPD contracts.
    function testDpdInitialization() external {
        assertEq(repository.addDpd(bytes32(uint256(69)), address(this), address(this)), 0);
        assertEq(repository.addDpd(bytes32(uint256(70)), address(this), address(this)), 1);
    }
}

interface Repository {
    /// @notice Given a DPD id, return its CID.
    function dpds(uint256) external view returns (bytes32);

    /// @notice Given a DPD id, return its owner address.
    function owners(uint256) external view returns (bytes32);

    /// @notice Given a DPD id, return its updater address.
    function updaters(uint256) external view returns (bytes32);

    /// @notice Given a DPD id, return its current address.

    /// @notice Given a CID, owner address, and updater address, initialize a new DPD.
    function addDpd(
        bytes32,
        address,
        address
    ) external returns (uint256);

    /// @notice Update a DPD CID.
    /// @notice Can only be called by the DPD's Updater address.
    function updateDPD(uint256, bytes32) external;

    /// @notice Set a new DPD owner.
    function setDPDOwner(uint256, address) external;

    /// @notice Set a new DPD updater.
    function setDPDUpdater(uint256, address) external;
}
