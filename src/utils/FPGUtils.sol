// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IERC20} from "@sablier/v2-core/src/types/Tokens.sol";

library FPGUtils {
    error ZeroBytesLength(bytes);
    error InvalidInput(bytes);
    error FPGNotApproved();

    function verifyBytesLengthNotZero(
        bytes memory item,
        bytes memory errorMessage
    ) public pure {
        if (item.length == 0) {
            revert ZeroBytesLength(errorMessage);
        }
    }

    function verifyApproveAvailable(
        IERC20 token,
        address owner,
        address spender,
        uint256 amount
    ) public view {
        if (token.allowance(owner, spender) < amount) {
            revert FPGNotApproved();
        }
    }

    function verifyGreaterThanZeroAndBlockNow(
        uint40 item,
        bytes memory message
    ) public view {
        if (item <= 0 && item < block.timestamp) {
            revert InvalidInput(message);
        }
    }
}
