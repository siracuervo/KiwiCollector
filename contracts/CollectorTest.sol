// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface RoyaltyCollectorInterface {
  function withdrawETH() external;
  function withdrawToken(address token) external;  
}

import "@openzeppelin/contracts/access/Ownable.sol";

contract CollectorTest is Ownable {
    address[] contractsAddresses;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint public splitterCount;
    uint public howManyTimes = 0;

    function addContract(address _address) public onlyOwner {
        bool alreadyExists = false;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            if (contractsAddresses[i] == _address) {
                alreadyExists = true;
            }            
        }   
        require(!alreadyExists, "Contract already added");
        contractsAddresses.push(_address);
    }

    function removeContract(address _address) public onlyOwner {
        require (contractsAddresses.length > 0, 'Load a splitter first!');
        bool alreadyExists = false;
        uint32 id;

        for (uint32 i=0; i<contractsAddresses.length; i++) {
            if (contractsAddresses[i] == _address) {
                alreadyExists = true;
                id = i;
            }            
        } 
        require(alreadyExists, "Contract not found");
        delete contractsAddresses[id];
    }

    function listContracts() external onlyOwner returns (address[] memory) {
        require (contractsAddresses.length > 0, 'Load a splitter first!');
        address[] memory splitters = new address[](contractsAddresses.length);
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            splitters[i] = contractsAddresses[i];
        }
        splitterCount = contractsAddresses.length;
        return (splitters);           
    }

    function updateAtIndex(uint32 index, address _newaddress) public onlyOwner {
        bool alreadyExists = false;

        for (uint32 i=0; i<contractsAddresses.length; i++) {
            if (contractsAddresses[i] == _newaddress) {
                alreadyExists = true;
            }            
        }
        require(!alreadyExists, "Address already exists in the list");
        contractsAddresses[index] = _newaddress;
    }
    
    
   function collectAllETH() public {
    require (contractsAddresses.length > 0, 'Load a splitter first!');
    howManyTimes = 0;
        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawETH();
            howManyTimes++;
        }
    }
    
   function collectAllWETH() public {
    require (contractsAddresses.length > 0, 'Load a splitter first!');
    howManyTimes = 0;

        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawToken(WETH);
            howManyTimes++;

        }
    }
    
   function collectToken(address _token) public {
    require (contractsAddresses.length > 0, 'Load a splitter first!');
    howManyTimes = 0;

        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawToken(_token);
            howManyTimes++;
        }
    }

    function getAddressByIndex(uint index) external view returns (address) {
        return contractsAddresses[index];
    }
}
