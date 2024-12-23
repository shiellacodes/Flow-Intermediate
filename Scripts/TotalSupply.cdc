import AdrocxToken from 0x06

pub fun main (): UFix64 {
    log("ADRX total supply is: ".concat(AdrocxToken.totalSupply.toString()))
    return AdrocxToken.totalSupply
}