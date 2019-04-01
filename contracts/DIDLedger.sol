pragma solidity ^0.5.4;


/**
 * @title DIDLedger
 * @dev DID Ledger for the SelfKey DID method.
 * A DID is controlled by their creator address by default, but control can be assigned to a
 * different adddress by their current controller.
 */
contract DIDLedger {

    struct DID {
        address controller;
        uint256 created;
        uint256 updated;
        bytes32 tag;
    }

    mapping(bytes32 => DID) public dids;
    uint256 public nonce = 0;

    event CreatedDID(bytes32 id, address controller, bytes32 tag, uint256 datetime);
    event UpdatedDIDTag(bytes32 id, address controller, bytes32 tag, uint256 datetime);
    event DeletedDIDData(bytes32 id, address controller, uint256 datetime);
    event ChangedDIDController(
        bytes32 id,
        address oldController,
        address newController,
        uint256 datetime
    );

    modifier onlyController(bytes32 id) {
        require(dids[id].controller == msg.sender, "sender has no control of this DID");
        _;
    }

    /**
     * @dev Register new DID. Only callable by whitelisted admins
     * @param _address — The address to be the controller of the DID
     * @param _data — Arbitrary 32-byte data field. Can be later changed by their owner.
     */
    function createDID(bytes32 _tag)
        public
        onlyWhitelisted
        returns (bytes32)
    {
        bytes32 _hash = keccak256(abi.encodePacked(_address, nonce));
        require(dids[_hash].created == 0, "DID already exists");

        dids[_hash].controller = msg.sender;
        dids[_hash].created = now;
        dids[_hash].updated = now;
        dids[_hash].tag = _tag;
        dids[_hash].data = _data;
        nonce = nonce + 1;

        emit CreatedDID(_hash, msg.sender, _tag, dids[_hash].created);
        return _hash;
    }

    /**
     * @dev Update DID tag. Only callable by DID controller.
     * @param id — The identifier (DID) to be updated
     * @param _data — Arbitrary 32-byte value to be assigned as data.
     */
    function updateTag(bytes32 id, bytes32 _tag)
        public
        onlyController(id)
    {
        dids[id].tag = _tag;
        dids[id].updated = now;
        emit UpdatedDIDTag(id, msg.sender, _tag, dids[id].updated);
    }

    /**
     * @dev Remove DID. Only callable by DID controller.
     * @param id — The identifier (DID) to be deleted
     */
    function deleteDID(bytes32 id)
        public
        onlyController(id)
    {
        delete dids[id];
        emit DeletedDID(id, msg.sender, now);
    }


    /**
     * @dev Returns corresponding controller for given DID
     * @param id — The identifier (DID) to be resolved
     */
    function resolveDID(bytes32 id)
        public
        view
        returns (address)
    {
        return dids[id].controller;
    }
}
