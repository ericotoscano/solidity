pragma solidity 0.8.13;

contract HelloWorld {
    function sayHello() public pure returns (string memory) {
        return "Hello, World!";
    }

    function myHello() public pure returns (string memory) {
        return "Hello, Erico!";
    }

    function personalHello(string memory _pessoa)
        public
        pure
        returns (string memory)
    {
        return string(abi.encodePacked("Hello,", " ", _pessoa));
    }
}
