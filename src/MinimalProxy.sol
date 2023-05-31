//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ERC20.sol";

contract ContractFactory {
    address private immutable ERC20ADDRESS;
    uint8 public constant FEE_MANAGER_CHARGE = 3;
    uint8 public constant REFERAL_MANAGER_CHARGE = 2;

    using Clones for address;

    address public owner;
    address public addressGenerated;
    uint8 public decimals = 4;
    uint8 public currentRoleCharge = FEE_MANAGER_CHARGE;

    ///@dev event emitted when clone is created.
    event CloneCreated(address indexed factoryAddress, address cloneAddress);

    ///@dev event emitted when fees mode is switched.
    event ModeSwitched(uint8 indexed from , uint8 to);

    constructor(address _ERC20Address) {
        ERC20ADDRESS = _ERC20Address;
        owner = msg.sender;
    }

    /**
     * @dev modifier to check that msg.sender is owner or not.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "you are not authorized to swith roles");
        _;
    }

    /**
     * @dev this function switches role, can be executed by the owner only.
     */
    function switchRole() external onlyOwner {
        uint8 prevRole = currentRoleCharge;
        currentRoleCharge = currentRoleCharge == FEE_MANAGER_CHARGE ? REFERAL_MANAGER_CHARGE : FEE_MANAGER_CHARGE;
        emit ModeSwitched(prevRole, currentRoleCharge);
    }

    /**
     * @dev this functions deployes an ERC20 contract using create function of clone library
     * @param _totalSupply is the initial total supply of cloned ERC20 token.
     * @param _name is the name of the token
     * @param _symbol is the symbol of the token.
     */
    function getClone(
        uint256 _totalSupply,
        string calldata _name,
        string calldata _symbol
    ) external {
        uint8 charge = currentRoleCharge;
        address deployedAddress = ERC20ADDRESS.clone();
        addressGenerated = deployedAddress;
        Coins coin = Coins(deployedAddress);
        coin.initialize(_totalSupply, _name, _symbol);
        coin.transfer(owner, ((_totalSupply) * (charge)) / 10 ** (decimals));
        coin.transferOwnership(msg.sender);
        emit CloneCreated(address(this), deployedAddress);
    }
}