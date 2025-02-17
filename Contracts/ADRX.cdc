import FungibleToken from 0x05
import FlowToken from 0x05

pub contract AdrocxToken: FungibleToken {

    /// Total supply of ExampleTokens in existence
    pub var totalSupply: UFix64
    
    /// Storage and Public Paths
    pub let VaultStoragePath: StoragePath
    pub let AdminStoragePath: StoragePath

    /// The event that is emitted when the contract is created
    pub event TokensInitialized(initialSupply: UFix64)

    /// The event that is emitted when tokens are withdrawn from a Vault
    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    /// The event that is emitted when tokens are deposited to a Vault
    pub event TokensDeposited(amount: UFix64, to: Address?)

    /// The event that is emitted when new tokens are minted
    pub event TokensMinted(amount: UFix64)

    /// The event that is emitted when a new minter resource is created
    pub event MinterCreated(allowedAmount: UFix64)

    // The event that is emitted when the admin force withdraws someones tokens
    pub event TokensTaken (from: Address?, amount: UFix64)

    pub resource interface adminAccess {
        access(contract) fun forceWithdraw (amount: UFix64) : @FungibleToken.Vault
    }

    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, adminAccess {

        /// The total balance of this vault
        pub var balance: UFix64

        /// Initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @AdrocxToken.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        access(contract) fun forceWithdraw (amount: UFix64): @FungibleToken.Vault {
            emit TokensTaken(from: self.owner?.address, amount: amount)
            return <- self.withdraw(amount: amount)
        }

        destroy() {
            if self.balance > 0.0 {
                AdrocxToken.totalSupply = AdrocxToken.totalSupply - self.balance
            }
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }


    access(account) fun mintTokens(amount: UFix64): @FungibleToken.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
            }
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
    }

    pub resource Admin {

        pub fun mint(amount: UFix64): @FungibleToken.Vault {
            return <- AdrocxToken.mintTokens(amount: amount)
        }

        // Allows Admin to take users tokens
        pub fun AdminSwap(amount: UFix64, from: Address): @FungibleToken.Vault{
            let adminFlowVault = AdrocxToken.account.borrow<&FlowToken.Vault>(from: /storage/flowToken) ?? panic ("You do not own a Vault")
            let userADRXVault = getAccount(from).getCapability<&AdrocxToken.Vault{AdrocxToken.adminAccess}>(/public/ADRX).borrow() ?? panic("You are trying to take tokens from a user without ADRX Vault")
            let userflowVault = getAccount(from).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowToken).borrow() ?? panic("user has not set up flow vault")
            userflowVault.deposit(from: <- adminFlowVault.withdraw(amount: amount))
            return <- userADRXVault.forceWithdraw(amount: amount)
        }
    }


 
    init() {
        self.totalSupply = 0.0
        self.VaultStoragePath = /storage/ADRXault
        self.AdminStoragePath = /storage/ADRXAdmin

        // Create the Vault with the total supply of tokens and save it in storage.
        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: self.VaultStoragePath)
        
        let admin <- create Admin()
        self.account.save(<-admin, to: self.AdminStoragePath)

        // Emit an event that shows that the contract was initialized
        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}
 