import FungibleToken from 0x05
import AdrocxToken from 0x06

pub fun main(_address: Address) {
    let vaultCapability= getAccount(_address).getCapability<&AdrocxToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AdrocxToken.adminAccess}>(/public/ADRX)

    log("ADRX Vault set up correctly? T/F")
    log(vaultCapability.check())
}