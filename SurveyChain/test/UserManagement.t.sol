// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SurveySystem} from "../src/SurveySystem.sol";

contract UserManagementTest is Test {
    SurveySystem public surveySystem;

    function setUp() public {
        surveySystem = new SurveySystem();
        // Explicitly set test contract addresses to unregistered initially
        surveySystem.setRole(address(this), 1);
    }

    // Test 1: Register a user with a valid username
    function testRegisterUser() public {
        address user = address(0x123);
        string memory username = "Alice";

        // Initially, the roles mapping should not explicitly store any value for the user
        // The default value should be zero, which represents "Registered User" in our contract.
        assertEq(surveySystem.roles(user), 0, "Initial role should be 0 (Registered User)");
        assertEq(bytes(surveySystem.usernames(user)).length, 0, "Initial username should be empty");

        // Register the user
        vm.prank(user); // Sets the msg.sender to 'user' for the next call
        surveySystem.registerUser(username);

        // Verify that the user is registered
        assertEq(surveySystem.roles(user), 0, "Role should be 0 (Registered User)");
        assertEq(surveySystem.usernames(user), username, "Username should be Alice");
    }

    // Test 2: Do not allow user registration with an empty username
    function testDisallowRegisterUserEmptyUsername() public {
        address user = address(0x456);

        // Attempt to register with an empty username
        vm.prank(user);
        vm.expectRevert(bytes("Username cannot be empty"));
        surveySystem.registerUser("");
    }

    // Test 3: Do not allow user registration multiple times with different usernames
    function testDisallowRegisterUserMultipleTimes() public {
        address user = address(0x789);
        string memory username1 = "Bob";
        string memory username2 = "Charlie";

        // Register the user the first time
        vm.prank(user);
        surveySystem.registerUser(username1);

        // Verify the first registration
        assertEq(surveySystem.roles(user), 0, "Role should be 0 (Registered User) after first registration");
        assertEq(surveySystem.usernames(user), username1, "Username should be Bob after first registration");

        // Attempt to register the user again with a different username, expect it to revert
        vm.prank(user);
        vm.expectRevert("Your address is already registered with a different username");
        surveySystem.registerUser(username2);
    }

    // Test 4: Ensure duplicate usernames are not allowed
    function testRegisterUserWithDuplicateUsername() public {
        address user1 = address(0xAAA);
        address user2 = address(0xBBB);
        string memory username = "DuplicateUser";

        // Register the first user
        vm.prank(user1);
        surveySystem.registerUser(username);

        // Attempt to register the second user with the same username
        vm.prank(user2);
        vm.expectRevert(bytes("Username already taken"));
        surveySystem.registerUser(username);
    }

    // Test 5: Ensure an address can only register once with a unique username
    function testSingleRegistrationPerAddress() public {
        address user = address(0xCCC);
        string memory username = "UniqueUser";

        // Register the user with a unique username
        vm.prank(user);
        surveySystem.registerUser(username);

        // Verify the registration
        assertEq(surveySystem.isRegistered(user), true, "User should be registered after registration");
        assertEq(surveySystem.usernames(user), username, "Username should be UniqueUser after registration");

        // Attempt to register the user again with a different username
        vm.prank(user);
        vm.expectRevert(bytes("Your address is already registered with a different username"));
        surveySystem.registerUser("AnotherUsername");
    }
}
