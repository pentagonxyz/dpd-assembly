// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract RepositoryTest is Test {
    /// @dev Address of the Repository contract.
    Repository public repository;

    /// @dev Setup the testing environment.
    function setUp() public {
        repository = Repository(HuffDeployer.deploy("Repository"));
    }

    /// @dev Ensure that you can create new DPDs.
    function testDpdInitialization() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));

        assertEq(repository.dpds(0), bytes32(uint256(69)));
        assertEq(repository.owners(0), address(this));
        assertEq(repository.updaters(0), address(this));
    }

    /// @dev Ensure that you cannot create two DPDs with the same ID.
    function testInitializeMultipleDpds() public {
        testDpdInitialization();
        repository.addDpd(1, bytes32(uint256(69)), address(this), address(this));

        assertEq(repository.dpds(1), bytes32(uint256(69)));
        assertEq(repository.owners(1), address(this));
        assertEq(repository.updaters(1), address(this));
    }

    /// @dev Ensure that you cannot create two DPDs with the same ID.
    function testFailNumberMustBeDifferent() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));
    }

    /// @dev Ensure that you can update DPD data.
    function testUpdateData() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));
        repository.updateDpdData(0, bytes32(uint256(1000)));

        assertEq(uint256(repository.dpds(0)), 1000);
    }

    /// @dev Ensure that you can update the updater address of a DPD.
    function testUpdateUpdater() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));
        repository.updateDpdUpdater(0, address(20));
        assertEq(repository.updaters(0), address(20));
    }

    /// @dev Ensure that you can update the owner address of a DPD.
    function testUpdateOwner() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(this));
        repository.updateDpdOwner(0, address(20));

        assertEq(repository.owners(0), address(20));
    }
}

interface Repository {
    /// @notice Given a DPD id, return its CID.
    function dpds(uint256) external view returns (bytes32);

    /// @notice Given a DPD id, return its owner address.
    function owners(uint256) external view returns (address);

    /// @notice Given a DPD id, return its updater address.
    function updaters(uint256) external view returns (address);

    /// @notice Given a DPD id, return its current version.
    function versions(uint256) external view returns (uint256);

    /// @notice Given a DPD id, CID, owner address, and updater address, initialize a new DPD.
    function addDpd(
        uint256,
        bytes32,
        address,
        address
    ) external;

    /// @notice Update a DPD CID.
    /// @notice Can only be called by the DPD's Updater address.
    function updateDpdData(uint256, bytes32) external;

    /// @notice Set a new DPD owner.
    function updateDpdOwner(uint256, address) external;

    /// @notice Set a new DPD updater.
    function updateDpdUpdater(uint256, address) external;

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDAdded(uint256 indexed dpdId, address owner, address updater, bytes32 cid);

    /// @notice Event emitted when a DPD is updated.
    event DPDUpdated(uint256 indexed dpdId, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerChanged(uint256 indexed dpdId, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterChanged(uint256 indexed dpdId, address newUpdater);
}