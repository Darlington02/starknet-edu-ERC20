# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (Uint256, uint256_add, uint256_le, uint256_lt, uint256_check, uint256_unsigned_div_rem, uint256_eq, uint256_mul)
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address

from openzeppelin.token.erc20.library import ERC20

from openzeppelin.access.ownable.library import Ownable 

#
# Constructor
#

@storage_var
    func allowlist(account: felt) -> (level: felt):
end

@constructor
func constructor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(name: felt, symbol: felt, decimals: felt, recipient: felt, totalSupply: felt):
    alloc_locals
    # initialize an owner
    Ownable.initializer(recipient)

    ERC20.initializer(name, symbol, decimals)
    ERC20._mint(recipient, Uint256(totalSupply, 0))
    return ()
end

# 
# Getters
# 

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (total_supply: Uint256):
    let (total_supply: Uint256) = ERC20.total_supply()
    return (total_supply)
end

@view
func decimals{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

@view
func allowlist_level{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (level: felt):
    # check
    let (level) = allowlist.read(account)
    return (level)
end


# 
# EXTERNALS
#

@external
func transfer{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(recipient: felt, amount: Uint256):
    ERC20.transfer(recipient, amount)
    return ()
end

@external 
func transferFrom{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(sender: felt, recipient: felt, amount: Uint256) -> ():
    ERC20.transfer_from(sender, recipient, amount)
    return ()
end

@external
func approve{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, amount: Uint256):
    ERC20.approve(spender, amount)
    return()
end

@external
func request_allowlist{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (level_granted: felt):
    # get caller address
    let (caller) = get_caller_address()
    # add caller to allowlist
    allowlist.write(caller, 1)
    return (1)
end

@external
func get_tokens{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (amount: Uint256):
    # get recipient
    let (recipient) = get_caller_address()

    # check recipient exist in allowlist
    let (level) = allowlist.read(recipient)

    # mint if allowed
    if level == 1:
        let mintAmount: Uint256 = Uint256(100, 0)
        ERC20._mint(recipient, mintAmount)
        return (mintAmount)
    end
    return (Uint256(0,0))
end