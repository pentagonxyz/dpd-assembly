// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @title DPDRepository
/// @notice The Decentralized Programmable Data (DPD) Repository stores data content identifiers, versions, authorized owners, and upgraders.
/// @author David Lucid <david@pentagon.xyz>
contract DPDRepository {
    /// @notice Struct for a DPD.
    struct DPD {
        bytes32 cid;
        address owner;
    }

    /// @notice DPD CIDs and owners mapped by DPD ID.
    mapping(uint256 => DPD) public dpds;

    /// @notice Versions mapped by DPD ID.
    /// @dev Excluded from DPD struct to avoid unnecessary allocation memory.
    mapping(uint256 => uint256) public versions;

    /// @notice Updaters mapped by DPD ID.
    /// @dev Excluded from DPD struct to avoid unnecessary allocation memory.
    mapping(uint256 => address) public updater;

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDAdded(uint256 indexed dpdId, address owner, address updater, bytes32 cid);

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDUpdated(uint256 indexed dpdId, uint256 indexed version, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerChanged(uint256 indexed dpdId, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterChanged(uint256 indexed dpdId, address newUpdater);

    /// @notice Function to add a new DPD.
    /// @param owner DPD owner address.
    /// @param newUpdater DPD updater address.
    /// @param cid DPD CID (content identifier).
    function addDpd(
        uint256 dpdId,
        address owner,
        address newUpdater,
        bytes32 cid
    ) external {
        require(
            dpds[dpdId].cid == 0 &&
                dpds[dpdId].owner == address(0) &&
                versions[dpdId] == 0 &&
                updater[dpdId] == address(0),
            "DPD already initialized."
        );
        dpds[dpdId] = DPD(cid, owner);
        updater[dpdId] = newUpdater;
        emit DPDAdded(dpdId, owner, newUpdater, cid);
    }

    /// @notice Function to update a DPD's CID.
    /// @param dpdId DPD's ID in this repository.
    /// @param cid New DPD CID (content identifier).
    function updateDpdData(uint256 dpdId, bytes32 cid) external returns (uint256) {
        address this_updater = updater[dpdId];
        require(
            msg.sender == this_updater || (msg.sender == dpds[dpdId].owner && this_updater == address(0)),
            "Only DPD updater (or owner if no updater) can update this DPD."
        );
        dpds[dpdId].cid = cid;
        uint256 newVersion = versions[dpdId]++;
        emit DPDUpdated(dpdId, newVersion, cid);
        return newVersion;
    }

    /// @notice Function to set a DPD's owner.
    /// @param dpdId DPD's ID in this repository.
    /// @param newOwner New owner address for this DPD.
    function updateDpdOwner(uint256 dpdId, address newOwner) external {
        require(msg.sender == dpds[dpdId].owner, "Only DPD owner can update this DPD's owner.");
        dpds[dpdId].owner = newOwner;
        emit DPDOwnerChanged(dpdId, newOwner);
    }

    /// @notice Function to set a DPD's upgrader.
    /// @param dpdId DPD's ID in this repository.
    /// @param newUpdater New updater address for this DPD.
    function updateDpdUpdater(uint256 dpdId, address newUpdater) external {
        require(msg.sender == dpds[dpdId].owner, "Only DPD owner can update this DPD's updater.");
        updater[dpdId] = newUpdater;
        emit DPDUpdaterChanged(dpdId, newUpdater);
    }
}
