// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface RoyaltyCollectorInterface {
  function withdrawETH() external;
  function withdrawToken(address token) external;  
}

import "@openzeppelin/contracts/access/Ownable.sol";

contract Collector is Ownable {

    address[] contractsAddresses;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

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

    function listContracts() external view onlyOwner returns (address[] memory) {
        require (contractsAddresses.length > 0, 'Load a splitter first!');

        address[] memory splitters = new address[](contractsAddresses.length);
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            splitters[i] = contractsAddresses[i];
        }
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
        
        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawETH();
        }
    }
    
   function collectAllWETH() public {
        require (contractsAddresses.length > 0, 'Load a splitter first!');
        
        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawToken(WETH);
        }
    }
    
   function collectToken(address _token) public {
        require (contractsAddresses.length > 0, 'Load a splitter first!');

        RoyaltyCollectorInterface rc;
        for (uint32 i=0; i<contractsAddresses.length; i++) {
            rc = RoyaltyCollectorInterface(contractsAddresses[i]);
            rc.withdrawToken(_token);
        }
    }
}