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
import { Types } from "./Types.sol";


/**
 * @title Actions
 * @author dYdX
 *
 * TODO
 */
library Actions {

    // ============ Constants ============

    string constant FILE = "Actions";

    // ============ Enums ============

    enum TransactionType {
        Deposit,   // supply tokens
        Withdraw,  // borrow tokens
        Transfer,  // transfer balance between accounts
        Buy,       // buy an amount of some token (externally)
        Sell,      // sell an amount of some token (externally)
        Trade,     // buy an amount of some token (internally)
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize,  // arbitrage admin funds to save a completely negative account
        Call       // send arbitrary data to an address
    }

    enum AssetDenomination {
        Wei, // the amount is denominated in token amount
        Par  // the amount is denominated in principal
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    // ============ Structs ============

    struct AssetAmount {
        bool sign;
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TransactionArgs {
        TransactionType transactionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    // ============ Action Types ============

    struct DepositArgs {
        AssetAmount amount;
        uint256 acct;
        uint256 mkt;
        address from;
    }

    struct WithdrawArgs {
        AssetAmount amount;
        uint256 acct;
        uint256 mkt;
        address to;
    }

    struct TransferArgs {
        AssetAmount amount;
        uint256 acctOne;
        uint256 acctTwo;
        uint256 mkt;
    }

    struct BuyArgs {
        AssetAmount amount;
        uint256 acct;
        uint256 makerMkt;
        uint256 takerMkt;
        address exchangeWrapper;
        bytes orderData;
    }

    struct SellArgs {
        AssetAmount amount;
        uint256 acct;
        uint256 takerMkt;
        uint256 makerMkt;
        address exchangeWrapper;
        bytes orderData;
    }

    struct TradeArgs {
        AssetAmount amount;
        uint256 takerAcct;
        uint256 makerAcct;
        uint256 inputMkt;
        uint256 outputMkt;
        address autoTrader;
        bytes tradeData;
    }

    struct LiquidateArgs {
        AssetAmount amount;
        uint256 solidAcct;
        uint256 liquidAcct;
        uint256 owedMkt;
        uint256 heldMkt;
    }

    struct VaporizeArgs {
        AssetAmount amount;
        uint256 solidAcct;
        uint256 vaporAcct;
        uint256 owedMkt;
        uint256 heldMkt;
    }

    struct CallArgs {
        uint256 acct;
        address callee;
        bytes data;
    }

    // ============ Parsing Functions ============

    function parseDepositArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (DepositArgs memory)
    {
        assert(args.transactionType == TransactionType.Deposit);
        return DepositArgs({
            amount: args.amount,
            acct: args.accountId,
            mkt: args.primaryMarketId,
            from: args.otherAddress
        });
    }

    function parseWithdrawArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (WithdrawArgs memory)
    {
        assert(args.transactionType == TransactionType.Withdraw);
        return WithdrawArgs({
            amount: args.amount,
            acct: args.accountId,
            mkt: args.primaryMarketId,
            to: args.otherAddress
        });
    }

    function parseTransferArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (TransferArgs memory)
    {
        assert(args.transactionType == TransactionType.Transfer);
        Require.that(
            args.accountId != args.otherAccountId,
            FILE,
            "Transfer accounts must be distinct"
        );
        return TransferArgs({
            amount: args.amount,
            acctOne: args.accountId,
            acctTwo: args.otherAccountId,
            mkt: args.primaryMarketId
        });
    }

    function parseBuyArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (BuyArgs memory)
    {
        assert(args.transactionType == TransactionType.Buy);
        return BuyArgs({
            amount: args.amount,
            acct: args.accountId,
            makerMkt: args.primaryMarketId,
            takerMkt: args.secondaryMarketId,
            exchangeWrapper: args.otherAddress,
            orderData: args.data
        });
    }

    function parseSellArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (SellArgs memory)
    {
        assert(args.transactionType == TransactionType.Sell);
        return SellArgs({
            amount: args.amount,
            acct: args.accountId,
            takerMkt: args.primaryMarketId,
            makerMkt: args.secondaryMarketId,
            exchangeWrapper: args.otherAddress,
            orderData: args.data
        });
    }

    function parseTradeArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (TradeArgs memory)
    {
        assert(args.transactionType == TransactionType.Trade);
        Require.that(
            args.accountId != args.otherAccountId,
            FILE,
            "Trade accounts must be distinct"
        );
        return TradeArgs({
            amount: args.amount,
            takerAcct: args.accountId,
            makerAcct: args.otherAccountId,
            inputMkt: args.primaryMarketId,
            outputMkt: args.secondaryMarketId,
            autoTrader: args.otherAddress,
            tradeData: args.data
        });
    }

    function parseLiquidateArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (LiquidateArgs memory)
    {
        assert(args.transactionType == TransactionType.Liquidate);
        Require.that(
            args.primaryMarketId != args.secondaryMarketId,
            FILE,
            "Liquidate markets must be distinct"
        );
        Require.that(
            args.accountId != args.otherAccountId,
            FILE,
            "Liquidate accounts must be distinct"
        );
        return LiquidateArgs({
            amount: args.amount,
            solidAcct: args.otherAccountId,
            liquidAcct: args.accountId,
            owedMkt: args.primaryMarketId,
            heldMkt: args.secondaryMarketId
        });
    }

    function parseVaporizeArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (VaporizeArgs memory)
    {
        assert(args.transactionType == TransactionType.Vaporize);
        Require.that(
            args.primaryMarketId != args.secondaryMarketId,
            FILE,
            "Vaporize markets must be distinct"
        );
        Require.that(
            args.accountId != args.otherAccountId,
            FILE,
            "Vaporize accounts must be distinct"
        );
        return VaporizeArgs({
            amount: args.amount,
            solidAcct: args.otherAccountId,
            vaporAcct: args.accountId,
            owedMkt: args.primaryMarketId,
            heldMkt: args.secondaryMarketId
        });
    }

    function parseCallArgs(
        TransactionArgs memory args
    )
        internal
        pure
        returns (CallArgs memory)
    {
        assert(args.transactionType == TransactionType.Call);
        return CallArgs({
            acct: args.accountId,
            callee: args.otherAddress,
            data: args.data
        });
    }
}