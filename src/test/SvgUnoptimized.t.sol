// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

import {XConsole} from "./utils/Console.sol";
import {DSTest} from "ds-test/test.sol";
import {SvgUnoptimized} from "../SvgUnoptimized.sol";
import "../stuff/Base64.sol";
import "../stuff/ToHex.sol";
import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

contract SvgUnoptimizedTest is DSTest {
    using stdStorage for StdStorage;
    XConsole console = new XConsole();

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);
    StdStorage public stdStore;

    SvgUnoptimized public svgUnoptimized;
    Base64 public base64;
    ToHex public toHex;

    function setUp() public {
        base64 = new Base64();
        toHex = new ToHex();
        svgUnoptimized = new SvgUnoptimized("GM", "GN", base64, toHex);
    }

    function testMintTo() public {
        for (uint256 i = 0; i < 10000; ++i) {
        svgUnoptimized.mintTo(address(1));
        }
    }

    function testFailMaxSupplyReach() public {
        uint256 slot = stdStore
            .target(address(svgUnoptimized))
            .sig("currentTokenId()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(svgUnoptimized), loc, mockedCurrentTokenId);
        svgUnoptimized.mintTo(address(1));
    }

    function testFailMintToZeroAddress() public {
        svgUnoptimized.mintTo(address(0));
    }

    function testBalanceIncremented() public {
        svgUnoptimized.mintTo(address(1));
    }

    function testSafeContractReceiver() public {
        Receiver receiver = new Receiver();
        svgUnoptimized.mintTo(address(receiver));
        uint256 slotBalance = stdStore
            .target(address(svgUnoptimized))
            .sig(svgUnoptimized.balanceOf.selector)
            .with_key(address(receiver))
            .find();
    }

    function testFailUnsafeContractReceiver() public {
        vm.etch(address(1), bytes("mock code"));
        svgUnoptimized.mintTo(address(1));
    }

    // Lmao
    function testTransfer() public {
        for (uint256 i = 0; i < 10000; ++i) {
        svgUnoptimized.mintTo(address(1));
        }
        vm.startPrank(address(1));
         for (uint256 i = 1; i < 10001; ++i) {
        svgUnoptimized.transferFrom(address(1), address(2), i);
        }
        vm.stopPrank();
        vm.startPrank(address(2));
        for (uint256 i = 1; i < 10001; ++i) {
        svgUnoptimized.transferFrom(address(2), address(1), i);
        }
        vm.stopPrank();
        vm.startPrank(address(1));
        for (uint256 i = 1; i < 10001; ++i) {
        svgUnoptimized.transferFrom(address(1), address(2), i);
        }
        vm.stopPrank();
        vm.startPrank(address(2));
        for (uint256 i = 1; i < 10001; ++i) {
        svgUnoptimized.transferFrom(address(2), address(1), i);
        }
    }

    function testFailTransfer() public {
        svgUnoptimized.mintTo(address(1));
      
        svgUnoptimized.transferFrom(address(1), address(0xBEEF), uint256(1));
    }

    function testTokenURIOutput() public {
        svgUnoptimized.mintTo(address(1));
        string memory output = svgUnoptimized.tokenURI(1);
        string memory IntendedOutput = "data:application/json;base64,eyJuYW1lIjogIlJhaW5ib3ciLCAiZGVzY3JpcHRpb24iOiAiVW5vcHRpbWl6ZWQgUmFpbmJvdyBvbiBjaGFpbiIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MG5hSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY25JSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SjNoTmFXNVpUV2x1SUcxbFpYUW5JSFpwWlhkQ2IzZzlKekFnTUNBek5UQWdNelV3Sno0OGNtVmpkQ0IzYVdSMGFEMG5NVEF3SlNjZ2FHVnBaMmgwUFNjeE1EQWxKeUJtYVd4c1BTZDFjbXdvSTNCaGRIUmxjbTRwSnlBdlBqeGtaV1p6UGp4c2FXNWxZWEpIY21Ga2FXVnVkQ0JwWkQwblozSmhaR2xsYm5RbklIZ3hQU2N4TURBbEp5QjVNVDBuTVRBbEp5QjRNajBuTUNVbklIa3lQU2N4TUNVblBqeHpkRzl3SUc5bVpuTmxkRDBuTmk0eU5TVW5JSE4wYjNBdFkyOXNiM0k5SnlNNE4yWm1abVVuTHo0OGMzUnZjQ0J2Wm1aelpYUTlKekU0TGpjMUpTY2djM1J2Y0MxamIyeHZjajBuSXpnNFptWTRPU2N2UGp4emRHOXdJRzltWm5ObGREMG5NekV1TWpVbEp5QnpkRzl3TFdOdmJHOXlQU2NqWmpobU5UaGhKeTgrUEhOMGIzQWdiMlptYzJWMFBTYzFOaTR5TlNVbklITjBiM0F0WTI5c2IzSTlKeU5sWmpZNU5tRW5MejQ4YzNSdmNDQnZabVp6WlhROUp6WTRMamMxSlNjZ2MzUnZjQzFqYjJ4dmNqMG5JMll6Tm1GaVlTY3ZQanh6ZEc5d0lHOW1abk5sZEQwbk9ERXVNalVsSnlCemRHOXdMV052Ykc5eVBTY2paV1kyT1RaaEp5OCtQSE4wYjNBZ2IyWm1jMlYwUFNjNU15NDNOU1VuSUhOMGIzQXRZMjlzYjNJOUp5Tm1PR1kxT0dFbkx6NDhjM1J2Y0NCdlptWnpaWFE5SnpFd01DVW5JSE4wYjNBdFkyOXNiM0k5SnlNNE9HWm1PRGtuTHo0OEwyeHBibVZoY2tkeVlXUnBaVzUwUGp3dlpHVm1jejQ4Y0dGMGRHVnliaUJwWkQwbmNHRjBkR1Z5YmljZ2VEMG5NQ2NnZVQwbk1DY2dkMmxrZEdnOUp6UXdNQ1VuSUdobGFXZG9kRDBuTVRBd0pTY2djR0YwZEdWeWJsVnVhWFJ6UFNkMWMyVnlVM0JoWTJWUGJsVnpaU2MrUEhKbFkzUWdlRDBuTFRFMU1DVW5JSGs5SnpBbklIZHBaSFJvUFNjeU1EQWxKeUJvWldsbmFIUTlKekV3TUNVbklHWnBiR3c5SjNWeWJDZ2paM0poWkdsbGJuUXBKeUIwY21GdWMyWnZjbTA5SjNKdmRHRjBaU2d0TmpVcEp6NDhZVzVwYldGMFpTQmhkSFJ5YVdKMWRHVlVlWEJsUFNkWVRVd25JR0YwZEhKcFluVjBaVTVoYldVOUozZ25JR1p5YjIwOUp5MHhOVEFsSnlCMGJ6MG5OVEFsSnlCa2RYSTlKekV3TURBd2JYTW5JSEpsY0dWaGRFTnZkVzUwUFNkcGJtUmxabWx1YVhSbEp5OCtQQzl5WldOMFBqeHlaV04wSUhnOUp5MHpOVEFsSnlCNVBTY3dKeUIzYVdSMGFEMG5NakF3SlNjZ2FHVnBaMmgwUFNjeE1EQWxKeUJtYVd4c1BTZDFjbXdvSTJkeVlXUnBaVzUwS1NjZ2RISmhibk5tYjNKdFBTZHliM1JoZEdVb0xUWTFLU2MrUEdGdWFXMWhkR1VnWVhSMGNtbGlkWFJsVkhsd1pUMG5XRTFNSnlCaGRIUnlhV0oxZEdWT1lXMWxQU2Q0SnlCbWNtOXRQU2N0TXpVd0pTY2dkRzg5SnkweE5UQWxKeUJrZFhJOUp6RXdNREF3YlhNbklISmxjR1ZoZEVOdmRXNTBQU2RwYm1SbFptbHVhWFJsSnk4K1BDOXlaV04wUGp3dmNHRjBkR1Z5Ymo0OEwzTjJaejQ9In0=";
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