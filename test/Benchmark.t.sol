pragma solidity 0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./benchmarks/DPDRepository.sol";

contract SimpleStoreTest is Test {
    /// @dev Address of the Huff DPDRepository contract.
    Repository public repository;

    /// @dev Address of the Solidity DPDRepository contract.
    DPDRepository public ogRepository;

    /// @dev Setup the testing environment.
    function setUp() public {
        repository = Repository(HuffDeployer.deploy("Repository"));
        ogRepository = new DPDRepository();
    }

    /// @dev Compare the contract sizes.
    function testDeploymentSize() public view {
        uint256 huffSize;
        uint256 soliditySize;

        assembly {
            huffSize := extcodesize(sload(repository.slot))
            soliditySize := extcodesize(sload(ogRepository.slot))
        }

        console.log("    Huff Deployment Size:", huffSize);
        console.log("Solidity Deployment Size:", soliditySize);
    }

    /// @dev Compare DPD Initialization Cost.
    function testDpdInitialization() public {
        Repository _repository = repository;
        DPDRepository _ogRepository = ogRepository;

        uint256 huffGasBefore = gasleft();
        _repository.addDpd(0, 0, address(0), address(0));
        uint256 huffGasCost = huffGasBefore - gasleft();

        uint256 solGasBefore = gasleft();
        _ogRepository.addDpd(0, 0, address(0), address(0));
        uint256 solGasCost = solGasBefore - gasleft();

        console.log("    Huff addDpd Gas Cost:", huffGasCost);
        console.log("Solidity addDpd Gas Cost:", solGasCost);
    }

    /// @dev Ensure that you can update DPD data.
    function testUpdateData() public {
        Repository _repository = repository;
        DPDRepository _ogRepository = ogRepository;

        _repository.addDpd(0, 0, address(this), address(this));
        _ogRepository.addDpd(0, 0, address(this), address(this));

        uint256 huffGasBefore = gasleft();
        _repository.updateDpdData(0, bytes32(uint256(1)));
        uint256 huffGasCost = huffGasBefore - gasleft();

        uint256 solGasBefore = gasleft();
        _ogRepository.updateDpd(0, bytes32(uint256(1)));
        uint256 solGasCost = solGasBefore - gasleft();

        console.log("    Huff updateDPD Gas Cost:", huffGasCost);
        console.log("Solidity updateDPD Gas Cost:", solGasCost);
    }

    /// @dev Ensure that you can update DPD data.
    function testUpdateOwner() public {
        Repository _repository = repository;
        DPDRepository _ogRepository = ogRepository;

        _repository.addDpd(0, 0, address(this), address(this));
        _ogRepository.addDpd(0, 0, address(this), address(this));

        uint256 huffGasBefore = gasleft();
        _repository.updateDpdOwner(0, address(1));
        uint256 huffGasCost = huffGasBefore - gasleft();

        uint256 solGasBefore = gasleft();
        _ogRepository.setDpdOwner(0, address(1));
        uint256 solGasCost = solGasBefore - gasleft();

        console.log("    Huff updateDPDOwner Gas Cost:", huffGasCost);
        console.log("Solidity updateDPDOwner Gas Cost:", solGasCost);
    }

    /// @dev Ensure that you can update DPD data.
    function testUpdateUpdater() public {
        Repository _repository = repository;
        DPDRepository _ogRepository = ogRepository;

        _repository.addDpd(0, 0, address(this), address(this));
        _ogRepository.addDpd(0, 0, address(this), address(this));

        uint256 huffGasBefore = gasleft();
        _repository.updateDpdUpdater(0, address(1));
        uint256 huffGasCost = huffGasBefore - gasleft();

        uint256 solGasBefore = gasleft();
        _ogRepository.setDpdUpdater(0, address(1));
        uint256 solGasCost = solGasBefore - gasleft();

        console.log("    Huff updateDPDOwner Gas Cost:", huffGasCost);
        console.log("Solidity updateDPDOwner Gas Cost:", solGasCost);
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

    /// @notice Given a CID, owner address, and updater address, initialize a new DPD.
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

    /// @notice Event emitted when a new DPD is added to the repository.
    event DPDUpdated(uint256 indexed dpdId, bytes32 cid);

    /// @notice Event emitted when a DPD's owner is changed.
    event DPDOwnerChanged(uint256 indexed dpdId, address newOwner);

    /// @notice Event emitted when a DPD's upgrader is changed.
    event DPDUpdaterChanged(uint256 indexed dpdId, address newUpdater);
}
