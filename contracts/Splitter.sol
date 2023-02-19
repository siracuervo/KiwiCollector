// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract uwuSplitter {
    using SafeERC20Upgradeable for IERC20Upgradeable;

     uint32 public wasETHorWETH;

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
    }

    function percentOfTotal(uint256 total, uint256 percentInGwei) internal pure returns (uint256) {
        return (total * percentInGwei) / 1 gwei;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function withdrawETH() external {
        withdrawToken(address(0));
    }

    function withdrawToken(address token) public {
        if (token == address(0)) {
            wasETHorWETH = 1;
        } else {
            wasETHorWETH = 2;
        }
    }

}