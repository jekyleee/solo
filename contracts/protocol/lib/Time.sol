/*

    Copyright 2018 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity ^0.5.0;

import { Require } from "./Require.sol";


/**
 * @title Time
 * @author dYdX
 *
 * TODO
 */
library Time {

    // ============ Constants ============

    string constant FILE = "Time";

    // ============ Library Functions ============

    function currentTime()
        internal
        view
        returns (uint32)
    {
        uint32 timestamp = uint32(block.timestamp);

        Require.that(
            uint256(timestamp) == block.timestamp,
            FILE,
            "We live in the future"
        );

        return timestamp;
    }

    function hasHappened(
        uint32 time
    )
        internal
        view
        returns (bool)
    {
        return (time != 0) && (time <= currentTime());
    }
}