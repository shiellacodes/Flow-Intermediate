import FungibleToken from 0x05
import AdrocxToken from 0x06
import FlowToken from 0x05

pub contract SwapperContract {

    pub event Swapped (flowAmount: UFix64, ADRXAmount: UFix64 , by: Address)

    pub resource Swapper{
        init() {}

        pub fun Swap (from: &FungibleToken.Vault, amount: UFix64): @FungibleToken.Vault {

            let pool = SwapperContract.account.borrow<&FlowToken.Vault>(from: /storage/flowToken) ?? panic("Swapper account must have a flow Vault")
            
            pool.deposit(from: <- from.withdraw(amount: amount))
            let minter = SwapperContract.account.borrow<&AdrocxToken.Admin>(from: AdrocxToken.AdminStoragePath) ?? panic("Swapper Contract must be deployed to ADRX Admin address")
            return <- minter.mint(amount: 2.0 * amount)
        }

    }

    pub fun mintSwapper() :@Swapper{
        return <- create Swapper()
    }

    init() {
        let signer = self.account
}

}