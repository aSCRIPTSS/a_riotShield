# Riot Shield Script for FiveM

This repository contains a **FiveM** script that allows players to use a **riot shield** alongside a handgun. The script includes custom animations, state management, and seamless integration with **ox_inventory**.

## Features

- **Custom Aim Animations** - Players can switch between different aiming styles (`default`, `gang`, `hillbilly`).
- **Riot Shield Mechanics** - The shield attaches to the back when unequipped and moves to the hand when in use.
- **Inventory Integration** - Fully compatible with `ox_inventory`, allowing easy equipping and unequipping.
- **State Management** - Uses FiveM's `state bags` for server-wide synchronization.

## Installation

### 1. Download the Script
Clone or download this repository and place it in your **FiveM resources** folder.

### 2. Add to `server.cfg`
```plaintext
ensure a_riotShield
```

### 3. Configure `ox_inventory`
Ensure you have **ox_inventory** installed and configured. Add the following item to your **ox_inventory items list**:

```lua
["shield"] = {
    label = "Police Shield",
    weight = 8000,
    stack = false,
    consume = 0,
    client = {
        export = "a_riotShield.useShield",
        add = function(total)
            if total > 0 then
                pcall(function() return exports["a_riotShield"]:hasShield(true) end)
            end
        end,
        remove = function(total)
            if total < 1 then
                pcall(function() return exports["a_riotShield"]:hasShield(false) end)
            end
        end
    }
}
```

## Usage

### Equipping the Riot Shield
- **Inventory:** Use the shield item from `ox_inventory` to equip it.
- **Command/Keybind:** Create a custom command or keybind to trigger `enableShield`.

### Unequipping the Riot Shield
- **Inventory:** Use the item again to unequip.
- **Command/Keybind:** Create a command or keybind to trigger `disableShield`.

### Changing Aim Animations
Players can switch between different aiming styles using exports:

```lua
exports["a_riotShield"]:setAimAnim("gang") -- Gang-style aiming
exports["a_riotShield"]:setAimAnim("default") -- Default aiming
```

## Exports

### **setAimAnim(anim)**
Sets the aiming animation for the player.
```lua
exports["a_riotShield"]:setAimAnim("gang")
```

### **getAimAnim()**
Returns the current aiming animation.
```lua
local currentAnim = exports["a_riotShield"]:getAimAnim()
```

### **hasShield(status)**
Sets the shield's state (equipped or unequipped).
```lua
exports["a_riotShield"]:hasShield(true)  -- Equip shield
exports["a_riotShield"]:hasShield(false) -- Unequip shield
```

### **useShield(data, slot)**
Used by `ox_inventory` to equip/unequip the shield.
```lua
exports["a_riotShield"]:useShield(data, slot)
```

## Dependencies
- [ox_inventory](https://github.com/overextended/ox_inventory) - Required for inventory management.
- [lib](https://github.com/overextended/lib) - Required for utility functions.

## Contributing
Feel free to open **issues** or **pull requests** for suggestions and improvements.

## Credits
- **ND-Framework** - Original riot shield code from [ND_Police](https://github.com/ND-Framework/ND_Police).
- **Overextended Team** - Development of `ox_inventory` and `lib`.

Enjoy using the riot shield in your FiveM server! If you need any help, feel free to reach out.