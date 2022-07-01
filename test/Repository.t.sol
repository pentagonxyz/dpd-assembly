// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

contract RepositoryTest is Test {
    /// @dev Address of the SimpleStore contract.
    Repository public repository;

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDAdded(uint256 indexed id, address owner, address updater, bytes32 cid);

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDUpdated(uint256 indexed id, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerUpdated(uint256 indexed id, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterUpdated(uint256 indexed id, address newUpdater);

    /// @dev Setup the testing environment.
    function setUp() public {
        repository = Repository(HuffDeployer.deploy("Repository"));
    }

    /// @dev Ensure that you can create new DPDs.
    function testDpdInitialization() public {
        vm.expectEmit(true, true, true, true);
        emit DPDAdded(0, address(this), address(this), bytes32(uint256(69)));
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));

        assertEq(repository.dpds(0), bytes32(uint256(69)));
        assertEq(repository.owner(0), address(this));
        assertEq(repository.updater(0), address(this));
    }

    /// @dev Ensure that you cannot create two DPDs with the same ID.
    function testInitializeMultipleDpds() public {
        testDpdInitialization();
        repository.addDpd(1, address(this), address(this), bytes32(uint256(69)));

        assertEq(repository.dpds(1), bytes32(uint256(69)));
        assertEq(repository.owner(1), address(this));
        assertEq(repository.updater(1), address(this));
    }

    /// @dev Ensure that you cannot create two DPDs with the same ID.
    function testFailNumberMustBeDifferent() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));
    }

    /// @dev Ensure that you can update DPD data.
    function testUpdateData() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));
        repository.updateDpdData(0, bytes32(uint256(1000)));

        assertEq(uint256(repository.dpds(0)), 1000);
    }

    /// @dev Ensure that you can update the updater address of a DPD.
    function testUpdateUpdater() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));
        repository.updateDpdUpdater(0, address(20));
        assertEq(repository.updater(0), address(20));
    }

    /// @dev Ensure that you can update the owner address of a DPD.
    function testUpdateOwner() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));
        repository.updateDpdOwner(0, address(20));

        assertEq(repository.owner(0), address(20));
    }
}

interface Repository {
    /// @notice Given a DPD id, return its CID (aka data).
    function dpds(uint256 id) external view returns (bytes32);

    /// @notice Given a DPD id, return its owner address.
    function owner(uint256 id) external view returns (address);

    /// @notice Given a DPD id, return its updater address.
    function updater(uint256 id) external view returns (address);

    /// @notice Create a new DPD.
    function addDpd(uint256 id, address owner, address updater, bytes32 cid) external;

    /// @notice Update a DPD CID.
    /// @notice Can only be called by the DPD's Updater address.
    function updateDpdData(uint256 id, bytes32 cid) external;

    /// @notice Set a new DPD owner.
    function updateDpdOwner(uint256 id, address newOwner) external;

    /// @notice Set a new DPD updater.
    function updateDpdUpdater(uint256 id, address newUpdater) external;

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDAdded(uint256 indexed id, address owner, address updater, bytes32 cid);

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDUpdated(uint256 indexed id, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerUpdated(uint256 indexed id, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterUpdated(uint256 indexed id, address newUpdater);
}
