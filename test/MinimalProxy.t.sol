// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../src/ERC20.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/MinimalProxy.sol";

contract Factory is Test {
    Coins public erc20;
    ContractFactory public factory;

    event ModeSwitched(uint8 indexed from , uint8 to);
    event CloneCreated(address indexed factoryAddress, address cloneAddress);

    /// This is the initial setup function.
    function setUp() public {
        erc20 = new Coins();
        factory = new ContractFactory(address(erc20));
    }

    /** 
     * @dev tests that getClone method works correclt and emits an event.
     */
    function testGetClone() public {
        vm.expectEmit(true, false, false, false);
        emit CloneCreated(address(factory), address(0));
        factory.getClone(100000000000000000000, "Shiva-Token", "SHIVA");
        console.log(factory.addressGenerated());
    }

    /**
     * @dev function to test that switch mode works correctly.
     */
    function testSwitchMode() public {
        assertEq(factory.currentRoleCharge(), 3);
        vm.expectEmit(true, true, false, false);
        emit ModeSwitched(3, 2);
        factory.switchRole();
        assertEq(factory.currentRoleCharge(), 2);
    }

    /**
     * @dev function to test that fees mode can only be executed by owner or revert.
     */
    function testAccessControl() public {
        vm.prank(address(1));
        vm.expectRevert(bytes("you are not authorized to swith roles"));
        factory.switchRole();
    }

    /**
     * @dev function to test that the function getClone to deploy a clone of implementation is deploying a clone,
     * that clone is cloned correctly or not.
     */
    function testClone() external {
        vm.prank(address(0));
        factory.getClone(100000000000000000000, "shiva-token", "SHIVA");
        Coins coin = Coins(factory.addressGenerated());
        assertEq(coin.balanceOf(address(0)), 99970000000000000000);
        assertEq(coin.balanceOf(address(this)), 30000000000000000);
        factory.switchRole();
        vm.prank(address(1));
        factory.getClone(100000000000000000000, "shiva-token2", "SHIVA2");
        coin = Coins(factory.addressGenerated());
        assertEq(coin.balanceOf(address(1)), 99980000000000000000);
        assertEq(coin.balanceOf(address(this)), 20000000000000000);
    }
}
