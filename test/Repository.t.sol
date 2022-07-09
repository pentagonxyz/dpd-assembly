// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

contract RepositoryTest is Test {
    /// @dev Address of the Repository contract.
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

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes8[] memory func_selectors = new bytes8[](7);
        func_selectors[0] = bytes8(hex"32bb50b2");
        func_selectors[1] = bytes8(hex"2acb38eb");
        func_selectors[2] = bytes8(hex"a123c33e");
        func_selectors[3] = bytes8(hex"70424ffb");
        func_selectors[4] = bytes8(hex"7c6e99a4");
        func_selectors[5] = bytes8(hex"f9124637");
        func_selectors[5] = bytes8(hex"9e82b5d6");

        bytes8 func_selector = bytes8(callData >> 0xe0);
        for (uint256 i = 0; i < 7; i++) {
            if (func_selector != func_selectors[i]) {
                return;
            }
        }

        address target = address(repository);
        uint256 OneWord = 0x20;
        bool success = false;
        assembly {
            success := staticcall(
                gas(),
                target,
                add(callData, OneWord),
                mload(callData),
                0,
                0
            )
        }

        assert(!success);
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

        vm.expectEmit(true, true, true, true);
        emit DPDAdded(1, address(this), address(this), bytes32(uint256(69)));
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

    /// @dev Ensure that you can update DPD data as owner.
    function testUpdateDataAsOwner() public {
        repository.addDpd(0, bytes32(uint256(69)), address(this), address(0xBEEF));
        repository.updateDpdData(0, bytes32(uint256(1000)));

        assertEq(uint256(repository.dpds(0)), 1000);
    }

    /// @dev Ensure that you can update DPD data as updater.
    function testUpdateDataAsUpdater() public {
        repository.addDpd(0, bytes32(uint256(69)), address(0xBEEF), address(this));
        repository.updateDpdData(0, bytes32(uint256(1000)));

        assertEq(uint256(repository.dpds(0)), 1000);
    }

    /// @dev Ensure that you cannot update DPD data as non-owner/updater.
    function testFailUpdateDataAsNonUpdaterNonOwner() public {
        repository.addDpd(0, bytes32(uint256(69)), address(0xBEEF), address(0xBEEF));
        repository.updateDpdData(0, bytes32(uint256(1000)));

        assertEq(uint256(repository.dpds(0)), 1000);
    }

    /// @dev Ensure that you can update the updater address of a DPD.
    function testUpdateUpdater() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));

        vm.expectEmit(true, true, true, true);
        emit DPDUpdaterUpdated(0, address(20));
        repository.updateDpdUpdater(0, address(20));

        assertEq(repository.updater(0), address(20));
    }

    /// @dev Ensure that you can update the owner address of a DPD.
    function testUpdateOwner() public {
        repository.addDpd(0, address(this), address(this), bytes32(uint256(69)));

        vm.expectEmit(true, true, true, true);
        emit DPDOwnerUpdated(0, address(20));
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

    /// @notice Event emitted when a DPD is updated.
    event DPDUpdated(uint256 indexed dpdId, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerChanged(uint256 indexed dpdId, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterChanged(uint256 indexed dpdId, address newUpdater);
}
