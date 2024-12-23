import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

transaction (amount: UFix64, receipient: Address) {

    let minter: &AdrocxToken.Admin
    let receiver: &AdrocxToken.Vault{FungibleToken.Receiver}

    prepare (signer: AuthAccount) {
        self.minter = signer.borrow<&AdrocxToken.Admin>(from:AdrocxToken.AdminStoragePath) ?? panic ("You are not the ADRX admin")
        self.receiver = getAccount(receipient).getCapability<&AdrocxToken.Vault{FungibleToken.Receiver}>(/public/ADRX).borrow() ?? panic ("Error, Check your receiver's ADRX Vault status")
    }

    execute {
        let tokens <- self.minter.mint(amount: amount)
        self.receiver.deposit(from: <- tokens)
        log("mint ADRX tokens successfully")
        log(amount.toString().concat(" Tokens minted"))
    }
}