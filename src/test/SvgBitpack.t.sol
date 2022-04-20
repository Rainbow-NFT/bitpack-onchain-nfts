// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.12;

import {XConsole} from "./utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import {SvgBitpack} from "../SvgBitpack.sol";
import "../stuff/Base64.sol";
import "forge-std/stdlib.sol";
import {Vm} from "forge-std/Vm.sol";

contract SvgBitpackTest is DSTest, stdCheats {
    using stdStorage for StdStorage;
    XConsole console = new XConsole();

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);
    StdStorage public stdStore;

    SvgBitpack public svgBitpack;
    Base64 public base64;

    function setUp() public {
        base64 = new Base64();
        svgBitpack = new SvgBitpack("GM", "GN", base64);
    }

    function testMintTo() public {
        for (uint256 i = 0; i < 10000; ++i) {
        svgBitpack.mintTo(address(1));
        }
    }

    function testFailMaxSupplyReach() public {
        uint256 slot = stdStore
            .target(address(svgBitpack))
            .sig("currentTokenId()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(svgBitpack), loc, mockedCurrentTokenId);
        svgBitpack.mintTo(address(1));
    }

    function testFailMintToZeroAddress() public {
        svgBitpack.mintTo(address(0));
    }

    function testBalanceIncremented() public {
        svgBitpack.mintTo(address(1));
    }

    function testSafeContractReceiver() public {
        Receiver receiver = new Receiver();
        svgBitpack.mintTo(address(receiver));
        uint256 slotBalance = stdStore
            .target(address(svgBitpack))
            .sig(svgBitpack.balanceOf.selector)
            .with_key(address(receiver))
            .find();
    }

    function testFailUnsafeContractReceiver() public {
        vm.etch(address(1), bytes("mock code"));
        svgBitpack.mintTo(address(1));
    }

    function testTransfer() public {
         for (uint256 i = 0; i < 10000; ++i) {
        svgBitpack.mintTo(address(1));
        }
        vm.startPrank(address(1));
         for (uint256 i = 1; i < 10001; ++i) {
        svgBitpack.transferFrom(address(1), address(2), i);
        }
        vm.stopPrank();
        vm.startPrank(address(2));
        for (uint256 i = 1; i < 10001; ++i) {
        svgBitpack.transferFrom(address(2), address(1), i);
        }
        vm.stopPrank();
        vm.startPrank(address(1));
        for (uint256 i = 1; i < 10001; ++i) {
        svgBitpack.transferFrom(address(1), address(2), i);
        }
        vm.stopPrank();
        vm.startPrank(address(2));
        for (uint256 i = 1; i < 10001; ++i) {
        svgBitpack.transferFrom(address(2), address(1), i);
        }
    }

    function testFailTransfer() public {
        svgBitpack.mintTo(address(1));
        svgBitpack.transferFrom(address(1), address(0xBEEF), uint256(1));
    }

    function testTokenURIOutput() public {
        svgBitpack.mintTo(address(1));
        string memory output = svgBitpack.tokenURI(1);
        string memory IntendedOutput = "data:application/json;base64,eyJuYW1lIjogIlJhaW5ib3ciLCAiZGVzY3JpcHRpb24iOiAiQml0cGFja2VkIFJhaW5ib3cgb24gY2hhaW4iLCAiaW1hZ2UiOiAiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBuYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNuSUhCeVpYTmxjblpsUVhOd1pXTjBVbUYwYVc4OUozaE5hVzVaVFdsdUlHMWxaWFFuSUhacFpYZENiM2c5SnpBZ01DQXpOVEFnTXpVd0p6NDhjbVZqZENCM2FXUjBhRDBuTVRBd0pTY2dhR1ZwWjJoMFBTY3hNREFsSnlCbWFXeHNQU2QxY213b0kzQmhkSFJsY200cEp5QXZQanhrWldaelBqeHNhVzVsWVhKSGNtRmthV1Z1ZENCcFpEMG5aM0poWkdsbGJuUW5JSGd4UFNjeE1EQWxKeUI1TVQwbk1UQWxKeUI0TWowbk1DVW5JSGt5UFNjeE1DVW5Qanh6ZEc5d0lHOW1abk5sZEQwbk5pNHlOU1VuSUhOMGIzQXRZMjlzYjNJOUp5TTROMlptWm1Vbkx6NDhjM1J2Y0NCdlptWnpaWFE5SnpFNExqYzFKU2NnYzNSdmNDMWpiMnh2Y2owbkl6ZzRabVk0T1NjdlBqeHpkRzl3SUc5bVpuTmxkRDBuTXpFdU1qVWxKeUJ6ZEc5d0xXTnZiRzl5UFNjalpqaG1OVGhoSnk4K1BITjBiM0FnYjJabWMyVjBQU2MxTmk0eU5TVW5JSE4wYjNBdFkyOXNiM0k5SnlObFpqWTVObUVuTHo0OGMzUnZjQ0J2Wm1aelpYUTlKelk0TGpjMUpTY2djM1J2Y0MxamIyeHZjajBuSTJZek5tRmlZU2N2UGp4emRHOXdJRzltWm5ObGREMG5PREV1TWpVbEp5QnpkRzl3TFdOdmJHOXlQU2NqWldZMk9UWmhKeTgrUEhOMGIzQWdiMlptYzJWMFBTYzVNeTQzTlNVbklITjBiM0F0WTI5c2IzSTlKeU5tT0dZMU9HRW5MejQ4YzNSdmNDQnZabVp6WlhROUp6RXdNQ1VuSUhOMGIzQXRZMjlzYjNJOUp5TTRPR1ptT0Rrbkx6NDhMMnhwYm1WaGNrZHlZV1JwWlc1MFBqd3ZaR1ZtY3o0OGNHRjBkR1Z5YmlCcFpEMG5jR0YwZEdWeWJpY2dlRDBuTUNjZ2VUMG5NQ2NnZDJsa2RHZzlKelF3TUNVbklHaGxhV2RvZEQwbk1UQXdKU2NnY0dGMGRHVnlibFZ1YVhSelBTZDFjMlZ5VTNCaFkyVlBibFZ6WlNjK1BISmxZM1FnZUQwbkxURTFNQ1VuSUhrOUp6QW5JSGRwWkhSb1BTY3lNREFsSnlCb1pXbG5hSFE5SnpFd01DVW5JR1pwYkd3OUozVnliQ2dqWjNKaFpHbGxiblFwSnlCMGNtRnVjMlp2Y20wOUozSnZkR0YwWlNndE5qVXBKejQ4WVc1cGJXRjBaU0JoZEhSeWFXSjFkR1ZVZVhCbFBTZFlUVXduSUdGMGRISnBZblYwWlU1aGJXVTlKM2duSUdaeWIyMDlKeTB4TlRBbEp5QjBiejBuTlRBbEp5QmtkWEk5SnpFd01EQXdiWE1uSUhKbGNHVmhkRU52ZFc1MFBTZHBibVJsWm1sdWFYUmxKeTgrUEM5eVpXTjBQanh5WldOMElIZzlKeTB6TlRBbEp5QjVQU2N3SnlCM2FXUjBhRDBuTWpBd0pTY2dhR1ZwWjJoMFBTY3hNREFsSnlCbWFXeHNQU2QxY213b0kyZHlZV1JwWlc1MEtTY2dkSEpoYm5ObWIzSnRQU2R5YjNSaGRHVW9MVFkxS1NjK1BHRnVhVzFoZEdVZ1lYUjBjbWxpZFhSbFZIbHdaVDBuV0UxTUp5QmhkSFJ5YVdKMWRHVk9ZVzFsUFNkNEp5Qm1jbTl0UFNjdE16VXdKU2NnZEc4OUp5MHhOVEFsSnlCa2RYSTlKekV3TURBd2JYTW5JSEpsY0dWaGRFTnZkVzUwUFNkcGJtUmxabWx1YVhSbEp5OCtQQzl5WldOMFBqd3ZjR0YwZEdWeWJqNDhMM04yWno0PSJ9";
        assertEq(output, IntendedOutput);   
    }
}

contract Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external returns (bytes4) {
        return this.onERC721Received.selector;
    }
}