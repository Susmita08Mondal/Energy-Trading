// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShamirSecretSharing {
    uint256 constant p = 256; // Prime number
    uint256 constant threshold = 3; // Threshold value

    struct Share {
        uint256 x;
        uint256 y;
    }

    mapping(address => Share) public shares;

    function generateShares(uint256 secret) public {
        require(shares[msg.sender].x == 0, "Shares already generated");

        for (uint256 i = 1; i <= threshold; i++) {
            uint256 randomCoefficient = uint256(keccak256(abi.encodePacked(secret, i))) % p;
            uint256 x = i;
            uint256 y = calculatePolynomial(secret, randomCoefficient, x);
            shares[address(uint160(i))] = Share(x, y);
        }
    }

    function reconstructSecret() public view returns (uint256) {
        require(shares[msg.sender].x != 0, "Shares not generated");

        uint256 result = 0;
        for (uint256 i = 1; i <= threshold; i++) {
            uint256 numerator = shares[address(uint160(i))].y;
            uint256 denominator = 1;

            for (uint256 j = 1; j <= threshold; j++) {
                if (i != j) {
                    numerator = (numerator * (p - shares[address(uint160(j))].x)) % p;
                    denominator = (denominator * (shares[address(uint160(i))].x - shares[address(uint160(j))].x)) % p;
                }
            }

            uint256 lagrangeTerm = (numerator * modInverse(denominator, p)) % p;
            result = (result + lagrangeTerm) % p;
        }

        return result;
    }

    function calculatePolynomial(uint256 secret, uint256 coefficient, uint256 x) internal pure returns (uint256) {
        return (secret + coefficient * x) % p;
    }

    function modInverse(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 m0 = m;
        uint256 y = 0;
        uint256 x = 1;

        while (a > 1) {
            uint256 q = a / m;
            uint256 t = m;

            m = a % m;
            a = t;
            t = y;

            y = x - q * y;
            x = t;
        }

        if (x < 0) {
            x += m0;
        }

        return x;
    }
}
