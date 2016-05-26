contract RentableObjects {

  struct Client {
    address cliAddress;
    uint since;
    bool exists;
  }

  // Every rentable object has the following properties
  struct Object {
    uint objId;
    string description;
    uint deposit;
    uint pricePerDay;
    Client client;
    uint created;
    address owner;
    bool exists;
  }

  // Public index to reference objects
  mapping (uint => Object) objects;
  address owner;

  // Constructor
  function RentableObjects() {
    owner = msg.sender;
  }

  function registerObject(uint _objId, uint _deposit, uint _pricePerDay, string _descr) returns (bool) {
    if (objectIsRegistered(_objId) == false) {
      Client memory nilClient = Client({cliAddress: 0, since: now, exists: false});
      objects[_objId] = Object({objId: _objId, description: _descr, deposit: _deposit, pricePerDay: _pricePerDay, client: nilClient, created: now, owner: msg.sender, exists: true});
      return true;
    }
    else {
      return false;
    }
  }

  function unregisterObject(uint _objId) returns (bool) {
    if ( (objects[_objId].exists == true) && (objectIsRented(_objId) == false) ) {
      delete objects[_objId];
      return true;
    }
    else {
      return false;
      throw;
    }
  }

  function rentObject(uint _objId) returns (bool) {
    // if ( (objectIsRented(_objId) == false) && (msg.value >= getObjectPrice(_objId)) ) {
    if (msg.value >= objects[_objId].deposit) {
      // add client to object
      objects[_objId].client = Client({cliAddress: msg.sender, since: now, exists: true});
      // send back any excess ether
      objects[_objId].client.cliAddress.send(msg.value - objects[_objId].deposit);
      // send confirmation to object
      //objects[_objId].objId.call.value(0)(objects[_objId].client.cliAddress);
      return true;
    }
    else {
      throw;
      return false;
    }
  }

  function reclaimObject(uint _objId) returns (bool) {
    if ( (objectIsRented(_objId) == true) && (getObjectClientAddress(_objId) == msg.sender) ) {
      msg.sender.send(getReturnDeposit(_objId));
      objects[_objId].client = Client({cliAddress: 0, since: now, exists: false});
      return true;
    }
    else {
      throw;
      return false;
    }
  }

  function objectIsRegistered(uint _objId) returns (bool) {
    return objects[_objId].exists;
  }

  function objectIsRented(uint _objId) returns (bool) {
    if ( (objects[_objId].exists == true) && (objects[_objId].client.exists == true) ) {
      return true;
    }
    else {
      return false;
    }
  }

  function getReturnDeposit(uint _objId) returns (uint) {
    uint day = 86400;
    uint clientTime = getObjectClientTime(_objId);
    uint daysRented = ( (clientTime - 1) / day ) + 1;
    uint rentalCost = daysRented * objects[_objId].pricePerDay;
    uint returnDeposit = objects[_objId].deposit - rentalCost;
    return returnDeposit;
  }

  function getObjectDeposit(uint _objId) returns (uint) {
    return objects[_objId].deposit;
  }

  function getObjectPricePerDay(uint _objId) returns (uint) {
    return objects[_objId].pricePerDay;
  }

  function getObjectDescription(uint _objId) returns (string) {
    return objects[_objId].description;
  }

  function getObjectClientExists(uint _objId) returns (bool) {
    return objects[_objId].client.exists;
  }

  function getObjectClientTime(uint _objId) returns (uint) {
    return now - objects[_objId].client.since;
  }

  function getObjectClientAddress(uint _objId) returns (address) {
    return objects[_objId].client.cliAddress;
  }

  function getObjectOwnerAddress(uint _objId) returns (address) {
    return objects[_objId].owner;
  }

  function getContractOwnerAddress() returns (address) {
    return owner;
  }

  // Fallback function results in nothing
  function () {
    throw;
  }

}
