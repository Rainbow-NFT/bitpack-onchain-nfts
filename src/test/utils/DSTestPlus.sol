// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {XConsole} from "./Console.sol";

import {DSTest} from "@ds/test.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

import "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

contract DSTestPlus is DSTest, Test {
    XConsole console = new XConsole();

}