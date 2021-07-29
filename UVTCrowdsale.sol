//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.5.0;

import "../node_modules/@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "../node_modules/@openzeppelin/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "../node_modules/@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "../node_modules/@openzeppelin/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "../node_modules/@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "../node_modules/@openzeppelin/contracts/crowdsale/validation/PausableCrowdsale.sol";
import "../node_modules/@openzeppelin/contracts/access/roles/CapperRole.sol";

contract UVTIDOCrowdsale is Crowdsale, CappedCrowdsale, TimedCrowdsale, PausableCrowdsale, CapperRole {

    using SafeMath for uint256;

    mapping(address => uint256) private _contributions;
    mapping(address => uint256) private _caps;
    
    uint private _individualDefaultCap;

    constructor(
        uint256 rate,
        address payable wallet,
        IERC20 token,
        uint256 cap,
        uint256 individualCap,
        uint256 openingTime,
        uint256 closingTime
    ) public Crowdsale(rate, wallet, token) CappedCrowdsale(cap) TimedCrowdsale(openingTime, closingTime) PausableCrowdsale() CapperRole() {
        _individualDefaultCap = individualCap;
    }

    function setCap(address beneficiary, uint256 cap) external onlyCapper {
        _caps[beneficiary] = cap;
    }

    function getCap(address beneficiary) public view returns (uint256) {
        uint256 cap = _caps[beneficiary];
        if (cap == 0) {
            cap = _individualDefaultCap;
        }
        return cap;
    }

    function getContribution(address beneficiary) public view returns (uint256) {
        return _contributions[beneficiary];
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        // solhint-disable-next-line max-line-length
        require(_contributions[beneficiary].add(weiAmount) <= getCap(beneficiary), "BOTSale: beneficiary's cap exceeded");
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        super._updatePurchasingState(beneficiary, weiAmount);
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
    }
}